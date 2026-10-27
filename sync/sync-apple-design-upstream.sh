#!/usr/bin/env bash
# Compare Melessa's pinned apple-design commit to dickwu/apple-design-skill main.
# If behind, overwrite 02_Knowledge_Base/skills/apple-design from the repo root,
# narrow SKILL.md description (sync/apple-design-description.txt), and refresh
# .upstream-sync.json.
#
# Usage:
#   bash sync/sync-apple-design-upstream.sh [MELESSA_ROOT]
#
# Exit codes:
#   0  already up to date (no file changes)
#   10 synced successfully (working tree changed; caller should commit)
#   1  error
#
# On success, also writes sync/outputs/apple-design-upstream.env (KEY=value).
set -euo pipefail

MELESSA_ROOT="$(cd "${1:-.}" && pwd)"
SKILL_DIR="${MELESSA_ROOT}/02_Knowledge_Base/skills/apple-design"
STAMP_FILE="${SKILL_DIR}/.upstream-sync.json"
DESC_FILE="${MELESSA_ROOT}/sync/apple-design-description.txt"
UPSTREAM_API="https://api.github.com/repos/dickwu/apple-design-skill"
TARBALL_URL="https://codeload.github.com/dickwu/apple-design-skill/tar.gz/refs/heads/main"
OUT_ENV="${MELESSA_ROOT}/sync/outputs/apple-design-upstream.env"
REPO_URL="https://github.com/dickwu/apple-design-skill"

if [[ ! -f "$DESC_FILE" ]]; then
  echo "Description override not found: $DESC_FILE" >&2
  exit 1
fi

for cmd in curl ruby tar; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "${cmd} is required" >&2
    exit 1
  fi
done

copy_tree() {
  local src="$1" dst="$2"
  mkdir -p "$dst"
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
  ruby - "$OUT_ENV" "$status" "$UPSTREAM_FULL" "$UPSTREAM_SHORT" "$UPSTREAM_DATE" "$LOCAL_COMMIT" "$UPSTREAM_MSG" <<'RUBY'
require "base64"
path, status, full, short, date, local_commit, msg = ARGV
File.write(path, [
  "STATUS=#{status}",
  "UPSTREAM_SHA=#{full}",
  "UPSTREAM_SHORT=#{short}",
  "UPSTREAM_DATE=#{date}",
  "LOCAL_COMMIT=#{local_commit}",
  "UPSTREAM_MSG_B64=#{Base64.strict_encode64(msg)}",
  ""
].join("\n"))
RUBY
  echo "Wrote ${OUT_ENV}"
}

echo "Fetching upstream main HEAD…"
META_FILE="${TMP}/commit.json"
HTTP_CODE="$(curl -sS -o "$META_FILE" -w '%{http_code}' \
  -H 'Accept: application/vnd.github+json' \
  -H 'User-Agent: melessa-apple-design-sync' \
  "${UPSTREAM_API}/commits/main")"
if [[ "$HTTP_CODE" != "200" ]]; then
  echo "Failed to fetch upstream commit (HTTP ${HTTP_CODE})" >&2
  head -c 500 "$META_FILE" >&2 || true
  exit 1
fi

ruby - "$META_FILE" "$TMP/upstream.sh" <<'RUBY'
require "json"
require "shellwords"
d = JSON.parse(File.read(ARGV[0]))
sha = d.fetch("sha")
msg = d.dig("commit", "message").to_s.lines.first.to_s.strip
date = d.dig("commit", "committer", "date").to_s
File.write(ARGV[1], [
  "UPSTREAM_FULL=#{sha.shellescape}",
  "UPSTREAM_SHORT=#{sha[0, 7].shellescape}",
  "UPSTREAM_DATE=#{date.shellescape}",
  "UPSTREAM_MSG=#{msg.shellescape}",
  ""
].join("\n"))
RUBY
# shellcheck disable=SC1091
source "$TMP/upstream.sh"

LOCAL_COMMIT=""
if [[ -f "$STAMP_FILE" ]]; then
  ruby -rjson -e 'File.write(ARGV[1], JSON.parse(File.read(ARGV[0])).fetch("commit", ""))' "$STAMP_FILE" "$TMP/local_commit"
  LOCAL_COMMIT="$(cat "$TMP/local_commit")"
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
tar -xzf "${TMP}/repo.tar.gz" -C "${TMP}/extract" --strip-components=1

SRC="${TMP}/extract"
if [[ ! -f "${SRC}/SKILL.md" ]]; then
  echo "Extracted repo missing SKILL.md" >&2
  find "${TMP}/extract" -maxdepth 3 -type f | head -40 >&2 || true
  exit 1
fi

echo "Syncing ${SRC} → ${SKILL_DIR}"
mkdir -p "$SKILL_DIR"
if [[ -d "$SKILL_DIR" ]]; then
  find "$SKILL_DIR" -mindepth 1 -maxdepth 1 ! -name '.DS_Store' -exec rm -rf {} +
fi
copy_tree "$SRC" "$SKILL_DIR"

ruby - "$SKILL_DIR/SKILL.md" "$DESC_FILE" <<'RUBY'
skill_path, desc_path = ARGV
text = File.read(skill_path)
match = text.match(/\A---\n(.*?)\n---\n/m)
abort("#{skill_path} is missing YAML frontmatter") unless match
frontmatter = match[1]
body = text[match.end(0)..]
desc = File.read(desc_path).strip
abort("#{desc_path} is empty") if desc.empty?
folded = "description: >\n" + desc.lines.map { |line| "  #{line.rstrip}" }.join("\n")
new_frontmatter = frontmatter.sub(/^description:\s*.*?(?=^[A-Za-z0-9_-]+:|\z)/m, "#{folded}\n")
abort("failed to replace SKILL.md description") if new_frontmatter == frontmatter
abort("narrowed description still contains the upstream catch-all trigger") if new_frontmatter.downcase.include?("review my design")
abort("narrowed description is missing Apple Pay") unless new_frontmatter.include?("Apple Pay")
File.write(skill_path, "---\n#{new_frontmatter.rstrip}\n---\n#{body}")
puts "Narrowed description in #{skill_path}"
RUBY

ruby - "$STAMP_FILE" "$UPSTREAM_FULL" "$UPSTREAM_SHORT" "$UPSTREAM_DATE" "$UPSTREAM_MSG" "$REPO_URL" <<'RUBY'
require "json"
require "time"
stamp_path, full, short, date, msg, repo = ARGV
stamp = {
  "repository" => repo,
  "source_path" => ".",
  "commit" => full,
  "commit_short" => short,
  "commit_date" => date,
  "commit_message" => msg,
  "synced_at" => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
}
File.write(stamp_path, JSON.pretty_generate(stamp) + "\n")
puts "Wrote #{stamp_path}"
RUBY

FILE_COUNT="$(find "$SKILL_DIR" -type f | wc -l | tr -d ' ')"
write_env "synced"
echo "STATUS=synced"
echo "FILE_COUNT=${FILE_COUNT}"
echo "Synced apple-design to ${UPSTREAM_SHORT}."
exit 10
