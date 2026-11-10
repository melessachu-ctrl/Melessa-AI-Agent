#!/usr/bin/env bash
# The git-using tests must not touch the caller's repository when git has
# exported GIT_DIR, as it does to hooks. No network.
set -Eeuo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_PREFIX
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

if ! command -v git > /dev/null; then
  echo "skip - git isolation (git not installed)"
  exit 0
fi

mkdir "$tmp/victim"
git -C "$tmp/victim" init -q
echo keep > "$tmp/victim/file"
git -C "$tmp/victim" add -A && git -C "$tmp/victim" commit -qm victim
before="$(git -C "$tmp/victim" rev-parse HEAD)"
failures=0
# Every suite runs under the foreign GIT_DIR and must itself pass, so a suite that
# dies before its first git call cannot make this check pass.
for t in test_smoke.sh test_apply_findings.sh test_post_review.sh test_visibility.sh; do
  if ! (cd "$tmp/victim" && GIT_DIR="$tmp/victim/.git" bash "$here/$t") > "$tmp/$t.log" 2>&1; then
    echo "FAIL - $t did not pass under a foreign GIT_DIR (see below)"
    tail -5 "$tmp/$t.log"
    failures=1
  fi
done
if [ "$(git -C "$tmp/victim" rev-parse HEAD)" = "$before" ] && [ -z "$(git -C "$tmp/victim" status --porcelain)" ] \
  && [ -f "$tmp/victim/file" ]; then
  [ "$failures" -eq 0 ] && echo "ok - the tests leave the caller's repository alone under GIT_DIR"
else
  echo "FAIL - a test wrote into the repository named by GIT_DIR"
  failures=1
fi
exit "$failures"
