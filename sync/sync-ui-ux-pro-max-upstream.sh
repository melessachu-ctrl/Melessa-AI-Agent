#!/usr/bin/env bash
# Compare Melessa's pinned ui-ux-pro-max commit to upstream main.
# If behind, overwrite 02_Knowledge_Base/skills/ui-ux-pro-max from
# nextlevelbuilder/ui-ux-pro-max-skill (.claude/skills/ui-ux-pro-max) and
# refresh .upstream-sync.json.
#
# Usage:
#   bash sync/sync-ui-ux-pro-max-upstream.sh [MELESSA_ROOT]
#
# Exit codes:
#   0  already up to date (no file changes)
#   10 synced successfully (working tree changed; caller should commit)
#   1  error
#
# On success, also writes sync/outputs/ui-ux-pro-max-upstream.env (KEY=value)
# when MELESSA_ROOT/sync/outputs is writable (created by caller in CI).
set -euo pipefail

MELESSA_ROOT="$(cd "${1:-.}" && pwd)"
SKILL_DIR="${MELESSA_ROOT}/02_Knowledge_Base/skills/ui-ux-pro-max"
STAMP_FILE="${SKILL_DIR}/.upstream-sync.json"
UPSTREAM_API="https://api.github.com/repos/nextlevelbuilder/ui-ux-pro-max-skill"
SOURCE_PATH=".claude/skills/ui-ux-pro-max"
TARBALL_URL="https://codeload.github.com/nextlevelbuilder/ui-ux-pro-max-skill/tar.gz/refs/heads/main"
OUT_ENV="${MELESSA_ROOT}/sync/outputs/ui-ux-pro-max-upstream.env"

if [[ ! -d "$SKILL_DIR" ]]; then
  echo "Skill directory not found: $SKILL_DIR" >&2
  exit 1
fi

for cmd in curl python3 tar; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "${cmd} is required" >&2
    exit 1
  fi
done

copy_tree() {
  local src="$1" dst="$2"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --exclude '.DS_Store' "${src}/" "${dst}/"
  else
    # Fallback when rsync is unavailable (e.g. minimal cloud VMs)
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
    # Message may contain spaces/quotes — base64 for safe transport
    echo "UPSTREAM_MSG_B64=$(printf '%s' "$UPSTREAM_MSG" | python3 -c 'import sys,base64; print(base64.b64encode(sys.stdin.buffer.read()).decode())')"
  } > "$OUT_ENV"
  echo "Wrote ${OUT_ENV}"
}

echo "Fetching upstream main HEAD…"
META_FILE="${TMP}/commit.json"
HTTP_CODE="$(curl -sS -o "$META_FILE" -w '%{http_code}' \
  -H 'Accept: application/vnd.github+json' \
  -H 'User-Agent: melessa-ui-ux-pro-max-sync' \
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
if [[ -f "$STAMP_FILE" ]]; then
  LOCAL_COMMIT="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('commit',''))" "$STAMP_FILE")"
fi

echo "Local pinned:  ${LOCAL_COMMIT:-<none>}"
echo "Upstream main: ${UPSTREAM_FULL} (${UPSTREAM_SHORT})"

if [[ -n "$LOCAL_COMMIT" && "$LOCAL_COMMIT" == "$UPSTREAM_FULL" ]]; then
  write_env "up_to_date"
  echo "STATUS=up_to_date"
  echo "Already up to date."
  exit 0
fi

echo "Downloading upstream tarball…"
curl -sSL -o "${TMP}/repo.tar.gz" "$TARBALL_URL"
mkdir -p "${TMP}/extract"
tar -xzf "${TMP}/repo.tar.gz" -C "${TMP}/extract" --strip-components=3 \
  "ui-ux-pro-max-skill-main/${SOURCE_PATH}"

SRC="${TMP}/extract/ui-ux-pro-max"
if [[ ! -f "${SRC}/SKILL.md" ]]; then
  SRC="$(find "${TMP}/extract" -type f -name 'SKILL.md' | head -1 | xargs -r dirname)"
fi
if [[ ! -f "${SRC}/SKILL.md" ]]; then
  echo "Extracted skill missing SKILL.md" >&2
  find "${TMP}/extract" -maxdepth 4 -type f | head -40 >&2 || true
  exit 1
fi

echo "Syncing ${SRC} → ${SKILL_DIR}"
find "$SKILL_DIR" -mindepth 1 -maxdepth 1 ! -name '.DS_Store' -exec rm -rf {} +
copy_tree "$SRC" "$SKILL_DIR"

python3 - "$STAMP_FILE" "$UPSTREAM_FULL" "$UPSTREAM_SHORT" "$UPSTREAM_DATE" "$UPSTREAM_MSG" <<'PY'
import json, sys
from datetime import datetime, timezone
from pathlib import Path

stamp_path, full, short, date, msg = sys.argv[1:6]
stamp = {
    "repository": "https://github.com/nextlevelbuilder/ui-ux-pro-max-skill",
    "source_path": ".claude/skills/ui-ux-pro-max",
    "commit": full,
    "commit_short": short,
    "commit_date": date,
    "commit_message": msg,
    "synced_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
}
Path(stamp_path).write_text(json.dumps(stamp, indent=2, ensure_ascii=False) + "\n")
print(f"Wrote {stamp_path}")
PY

FILE_COUNT="$(find "$SKILL_DIR" -type f | wc -l | tr -d ' ')"
write_env "synced"
echo "STATUS=synced"
echo "FILE_COUNT=${FILE_COUNT}"
echo "Synced ui-ux-pro-max to ${UPSTREAM_SHORT}."
exit 10
