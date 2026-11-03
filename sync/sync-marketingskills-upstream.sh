#!/usr/bin/env bash
# Compare Melessa's pinned marketingskills commit to coreyhaines31/marketingskills main.
# If behind, overwrite the 12 vendored skill directories and refresh each .upstream-sync.json.
#
# Usage:
#   bash sync/sync-marketingskills-upstream.sh [MELESSA_ROOT]
#
# Exit codes:
#   0  already up to date (no file changes)
#   10 synced successfully (working tree changed; caller should commit)
#   1  error
#
# On success, also writes sync/outputs/marketingskills-upstream.env (KEY=value).
set -euo pipefail

MELESSA_ROOT="$(cd "${1:-.}" && pwd)"
SKILLS_ROOT="${MELESSA_ROOT}/02_Knowledge_Base/skills"
UPSTREAM_API="https://api.github.com/repos/coreyhaines31/marketingskills"
TARBALL_URL="https://codeload.github.com/coreyhaines31/marketingskills/tar.gz/refs/heads/main"
OUT_ENV="${MELESSA_ROOT}/sync/outputs/marketingskills-upstream.env"
REPO_URL="https://github.com/coreyhaines31/marketingskills"

SKILLS=(
  product-marketing
  cro
  copywriting
  copy-editing
  offers
  emails
  sms
  ads
  ad-creative
  seo-audit
  social
  influencer-marketing
)

for cmd in curl python3 tar; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "${cmd} is required" >&2
    exit 1
  fi
done

for name in "${SKILLS[@]}"; do
  if [[ ! -d "${SKILLS_ROOT}/${name}" ]]; then
    echo "Skill directory not found: ${SKILLS_ROOT}/${name}" >&2
    exit 1
  fi
done

copy_tree() {
  local src="$1" dst="$2"
  mkdir -p "$dst"
  find "$dst" -mindepth 1 -maxdepth 1 ! -name '.DS_Store' -exec rm -rf {} +
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --exclude '.DS_Store' "${src}/" "${dst}/"
  else
    (cd "$src" && tar cf - .) | (cd "$dst" && tar xf -)
  fi
}

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

write_env() {
  local status="$1"
  mkdir -p "$(dirname "$OUT_ENV")"
  {
    echo "STATUS=${status}"
    echo "UPSTREAM_SHA=${UPSTREAM_FULL}"
    echo "UPSTREAM_SHORT=${UPSTREAM_SHORT}"
    echo "UPSTREAM_DATE=${UPSTREAM_DATE}"
    echo "LOCAL_COMMIT=${LOCAL_COMMIT}"
    echo "UPSTREAM_MSG_B64=$(printf '%s' "$UPSTREAM_MSG" | python3 -c 'import sys,base64; print(base64.b64encode(sys.stdin.buffer.read()).decode())')"
  } > "$OUT_ENV"
  echo "Wrote ${OUT_ENV}"
}

echo "Fetching upstream main HEAD…"
META_FILE="${TMP}/commit.json"
TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
AUTH_ARGS=()
if [[ -n "$TOKEN" ]]; then
  AUTH_ARGS=(-H "Authorization: Bearer ${TOKEN}")
fi
# ${AUTH_ARGS[@]+...} keeps bash 3.2 happy when the array is empty.
HTTP_CODE="$(curl -sS -o "$META_FILE" -w '%{http_code}' \
  -H 'Accept: application/vnd.github+json' \
  -H 'User-Agent: melessa-marketingskills-sync' \
  ${AUTH_ARGS[@]+"${AUTH_ARGS[@]}"} \
  "${UPSTREAM_API}/commits/main")"
if [[ "$HTTP_CODE" != "200" ]]; then
  echo "Failed to fetch upstream commit (HTTP ${HTTP_CODE})" >&2
  head -c 500 "$META_FILE" >&2 || true
  exit 1
fi

eval "$(python3 - "$META_FILE" <<'PY'
import json, shlex, sys
from pathlib import Path
d = json.loads(Path(sys.argv[1]).read_text())
sha = d["sha"]
msg = d["commit"]["message"].splitlines()[0]
date = d["commit"]["committer"]["date"]
print(f"UPSTREAM_FULL={shlex.quote(sha)}")
print(f"UPSTREAM_SHORT={shlex.quote(sha[:7])}")
print(f"UPSTREAM_DATE={shlex.quote(date)}")
print(f"UPSTREAM_MSG={shlex.quote(msg)}")
PY
)"

LOCAL_COMMIT=""
MIXED=0
FIRST=""
for name in "${SKILLS[@]}"; do
  stamp="${SKILLS_ROOT}/${name}/.upstream-sync.json"
  pinned=""
  if [[ -f "$stamp" ]]; then
    pinned="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('commit',''))" "$stamp")"
  fi
  echo "Local ${name}: ${pinned:-<none>}"
  if [[ -z "$FIRST" ]]; then
    FIRST="$pinned"
  elif [[ "$pinned" != "$FIRST" ]]; then
    MIXED=1
  fi
done

if [[ "$MIXED" -eq 1 ]]; then
  LOCAL_COMMIT="mixed"
  echo "Local stamps disagree; will resync all 12 skills."
else
  LOCAL_COMMIT="$FIRST"
fi

echo "Upstream main: ${UPSTREAM_FULL} (${UPSTREAM_SHORT})"

if [[ "$MIXED" -eq 0 && -n "$LOCAL_COMMIT" && "$LOCAL_COMMIT" == "$UPSTREAM_FULL" ]]; then
  write_env "up_to_date"
  echo "STATUS=up_to_date"
  echo "Already up to date."
  exit 0
fi

echo "Downloading upstream tarball…"
curl -sSL -o "${TMP}/repo.tar.gz" "$TARBALL_URL"
mkdir -p "${TMP}/extract"
tar -xzf "${TMP}/repo.tar.gz" -C "${TMP}/extract"
TOP="$(find "${TMP}/extract" -mindepth 1 -maxdepth 1 -type d | head -1)"
if [[ -z "$TOP" || ! -d "${TOP}/skills" ]]; then
  echo "Extracted repo missing skills/" >&2
  find "${TMP}/extract" -maxdepth 3 -type d | head -40 >&2 || true
  exit 1
fi

for name in "${SKILLS[@]}"; do
  if [[ ! -f "${TOP}/skills/${name}/SKILL.md" ]]; then
    echo "Upstream skills/${name}/SKILL.md is missing; left local skills unchanged." >&2
    exit 1
  fi
done

for name in "${SKILLS[@]}"; do
  src="${TOP}/skills/${name}"
  dst="${SKILLS_ROOT}/${name}"
  echo "Syncing ${src} → ${dst}"
  copy_tree "$src" "$dst"
  python3 - "$dst/.upstream-sync.json" "$name" "$UPSTREAM_FULL" "$UPSTREAM_SHORT" "$UPSTREAM_DATE" "$UPSTREAM_MSG" "$REPO_URL" <<'PY'
import json, sys
from datetime import datetime, timezone
from pathlib import Path

stamp_path, name, full, short, date, msg, repo = sys.argv[1:8]
stamp = {
    "repository": repo,
    "source_path": f"skills/{name}",
    "commit": full,
    "commit_short": short,
    "commit_date": date,
    "commit_message": msg,
    "synced_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "license": "MIT",
}
Path(stamp_path).write_text(json.dumps(stamp, indent=2, ensure_ascii=False) + "\n")
print(f"Wrote {stamp_path}")
PY
done

FILE_COUNT=0
for name in "${SKILLS[@]}"; do
  n="$(find "${SKILLS_ROOT}/${name}" -type f | wc -l | tr -d ' ')"
  FILE_COUNT=$((FILE_COUNT + n))
done
write_env "synced"
echo "STATUS=synced"
echo "FILE_COUNT=${FILE_COUNT}"
echo "Synced marketingskills to ${UPSTREAM_SHORT}."
exit 10
