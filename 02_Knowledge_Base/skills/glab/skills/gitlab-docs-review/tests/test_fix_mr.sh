#!/usr/bin/env bash
# Tests scripts/fix_mr.py with a stubbed glab. No network, no real writes.
set -Eeuo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scripts="$here/../scripts"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

failures=0
ok() { echo "ok - $1"; }
fail() {
  echo "FAIL - $1"
  failures=$((failures + 1))
}

stub="$tmp/stub"
mkdir -p "$stub/responses"
export STUB_DIR="$stub"
glab="$here/fixtures/glab-stub/glab"
r="$stub/responses"
echo '{"id": 10, "username": "docs-reviewer"}' > "$r/user.json"
echo '{"message": "429 Too Many Requests"}' > "$r/429.json"
echo '{"id": 7}' > "$r/project.json"
echo '{"iid": 42, "state": "opened", "source_branch": "docs-v2", "source_project_id": 7}' > "$r/mr.json"
echo '{"iid": 42, "state": "merged", "source_branch": "docs-v2", "source_project_id": 7}' > "$r/mr-merged.json"
echo '{"iid": 42, "state": "opened", "source_branch": "docs-v2", "source_project_id": 99}' > "$r/mr-fork.json"
echo '{"name": "gitlab-docs-review/mr-42"}' > "$r/branch.json"
echo 'glab: 404 Branch Not Found (HTTP 404)' > "$r/404.json"
echo '[]' > "$r/none.json"
ours='{"iid": 50, "web_url": "https://gitlab.example/p/-/merge_requests/50", "source_project_id": 7, "author": {"username": "docs-reviewer"}}'
fork='{"iid": 60, "web_url": "https://gitlab.example/p/-/merge_requests/60", "source_project_id": 99, "author": {"username": "drive-by-user"}}'
other='{"iid": 61, "web_url": "https://gitlab.example/p/-/merge_requests/61", "source_project_id": 7, "author": {"username": "someone-else"}}'
echo "[$ours]" > "$r/ours.json"
echo "[$fork]" > "$r/fork-only.json"
echo "[$fork, $ours]" > "$r/fork-then-ours.json"
echo "[$other]" > "$r/other.json"
echo '{"iid": 51, "web_url": "https://gitlab.example/p/-/merge_requests/51"}' > "$r/created.json"

routes() { # MR-RESPONSE BRANCH-RESPONSE LIST-RESPONSE [USER-RESPONSE] [BRANCH-2-RESPONSE]
  local user="${4:-user.json}" b2="${5:-404.json}"
  {
    if [ "$user" = "429.json" ]; then printf 'GET\t^user$\tresponses/429.json\t1\n'; else printf 'GET\t^user$\tresponses/%s\n' "$user"; fi
    printf 'GET\t^projects/example-org%%2Fexample-docs$\tresponses/project.json\n'
    printf 'GET\t^projects/example-org%%2Fexample-docs/merge_requests/42$\tresponses/%s\n' "$1"
    for pair in "gitlab-docs-review%2Fmr-42-2:$b2" "gitlab-docs-review%2Fmr-42:$2"; do
      b="${pair%%:*}" f="${pair##*:}"
      if [ "$f" = "404.json" ]; then
        printf 'GET\t/repository/branches/%s$\tresponses/404.json\t1\n' "$b"
      else
        printf 'GET\t/repository/branches/%s$\tresponses/%s\n' "$b" "$f"
      fi
    done
    printf 'GET\t/repository/branches/\tresponses/404.json\t1\n'
    printf 'GET\t^projects/example-org%%2Fexample-docs/merge_requests\\?state=opened&source_branch=gitlab-docs-review%%2Fmr-42-2&\tresponses/none.json\n'
    printf 'GET\t^projects/example-org%%2Fexample-docs/merge_requests\\?state=opened\tresponses/%s\n' "$3"
    printf 'POST\t^projects/example-org%%2Fexample-docs/merge_requests$\tresponses/created.json\n'
  } > "$stub/routes"
}
run() { # args...
  rc=0
  : > "$stub/calls"
  rm -rf "$stub/bodies"
  python3 "$scripts/fix_mr.py" --project example-org/example-docs --mr 42 --glab "$glab" "$@" \
    > "$tmp/out" 2> "$tmp/err" || rc=$?
}
posted() { grep -q '^POST' "$stub/calls"; }

routes mr.json branch.json none.json
run --branch gitlab-docs-review/mr-42
if [ "$rc" -eq 0 ] && python3 - "$tmp/out" "$stub/bodies" << 'PY'; then ok "opens a draft fix MR into the reviewed MR's source branch"; else fail "create: rc $rc $(cat "$tmp/err")"; fi
import glob, json, sys
out = json.load(open(sys.argv[1]))
body = json.load(open(glob.glob(sys.argv[2] + "/*.json")[0]))
assert out == {"iid": 51, "web_url": "https://gitlab.example/p/-/merge_requests/51", "created": True,
               "target_branch": "docs-v2"}, out
assert body["source_branch"] == "gitlab-docs-review/mr-42" and body["target_branch"] == "docs-v2", body
assert body["title"].startswith("Draft: ") and body["remove_source_branch"] is True
assert body["description"].startswith(":robot: Agent docs review") and "!42" in body["description"]
PY

routes mr.json branch.json ours.json
run --branch gitlab-docs-review/mr-42
if [ "$rc" -eq 0 ] && ! posted && grep -q '"iid": 50' "$tmp/out" && grep -q '"created": false' "$tmp/out"; then
  ok "a later cycle reuses our open fix MR"
else
  fail "reuse: rc $rc $(cat "$tmp/out" "$tmp/err")"
fi

# Anyone can open an MR from a fork with the fix branch's name: it is never the fix MR.
routes mr.json branch.json fork-only.json
run --branch gitlab-docs-review/mr-42
if [ "$rc" -eq 0 ] && posted && grep -q '"iid": 51' "$tmp/out"; then
  ok "a fork MR with the fix branch's name is not the fix MR: ours is created"
else
  fail "fork only: rc $rc $(cat "$tmp/out" "$tmp/err")"
fi
routes mr.json branch.json fork-then-ours.json
run --branch gitlab-docs-review/mr-42
if [ "$rc" -eq 0 ] && ! posted && grep -q '"iid": 50' "$tmp/out"; then
  ok "a newer fork MR listed first does not replace our fix MR"
else
  fail "fork then ours: rc $rc $(cat "$tmp/out")"
fi
routes mr.json branch.json other.json
run --branch gitlab-docs-review/mr-42
if [ "$rc" -eq 2 ] && ! posted && grep -q "did not open" "$tmp/err"; then
  ok "an MR from the fix branch that another account opened stops the run"
else
  fail "other author: rc $rc $(cat "$tmp/out" "$tmp/err")"
fi

routes mr.json branch.json none.json 429.json
run --branch gitlab-docs-review/mr-42
if [ "$rc" -eq 2 ] && ! posted; then ok "an unknown current user stops the run"; else fail "unknown user: rc $rc"; fi

routes mr.json branch.json none.json
run --branch gitlab-docs-review/mr-42 --dry-run
if [ "$rc" -eq 0 ] && ! posted && grep -q '"would_create": true' "$tmp/out"; then
  ok "--dry-run creates nothing"
else
  fail "dry run: rc $rc $(cat "$stub/calls")"
fi

routes mr.json branch.json none.json
for b in docs-v2 fixes/mr-42 gitlab-docs-review/../docs-v2 gitlab-docs-review/mr-43 gitlab-docs-review/mr-42-1 gitlab-docs-review/mr-42-x gitlab-docs-review/mr-420; do
  run --branch "$b"
  if [ "$rc" -eq 2 ] && ! posted; then ok "refuses fix branch $b"; else fail "branch $b: rc $rc"; fi
done

routes mr-merged.json branch.json none.json
run --branch gitlab-docs-review/mr-42
if [ "$rc" -eq 2 ] && grep -q "not open" "$tmp/err"; then ok "refuses a merged MR"; else fail "merged: rc $rc"; fi

routes mr-fork.json branch.json none.json
run --branch gitlab-docs-review/mr-42
if [ "$rc" -eq 2 ] && grep -q "fork" "$tmp/err"; then ok "refuses a fork MR's branch in the wrong project"; else fail "fork: rc $rc"; fi

routes mr.json 404.json none.json
run --branch gitlab-docs-review/mr-42
if [ "$rc" -eq 2 ] && ! posted; then ok "refuses a fix branch that was not pushed"; else fail "unpushed: rc $rc"; fi

# --plan: which branch a run uses, and whether it starts fresh or continues.
plan_case() { # NAME EXPECTED-BRANCH EXPECTED-START EXPECTED-FIX-MR
  run --plan
  if [ "$rc" -eq 0 ] && ! posted && python3 - "$tmp/out" "$2" "$3" "$4" << 'PY'; then ok "$1"; else fail "$1: rc $rc $(cat "$tmp/out" "$tmp/err")"; fi
import json, sys
out = json.load(open(sys.argv[1]))
fix = None if sys.argv[4] == "none" else int(sys.argv[4])
assert out == {"branch": sys.argv[2], "start": sys.argv[3], "fix_mr": fix}, out
PY
}
routes mr.json 404.json none.json
plan_case "--plan starts a fresh fix branch when none exists" gitlab-docs-review/mr-42 fresh none
routes mr.json branch.json ours.json
plan_case "--plan continues the branch of our open fix MR" gitlab-docs-review/mr-42 continue 50
routes mr.json branch.json none.json
plan_case "--plan never reuses a branch with no open fix MR of ours" gitlab-docs-review/mr-42-2 fresh none
routes mr.json branch.json fork-only.json
plan_case "--plan ignores a fork MR with the fix branch's name" gitlab-docs-review/mr-42-2 fresh none

# Round 6: a branch is absent only on HTTP 404, never because "404" is in the
# error text: the endpoint in the message holds the IID.
if python3 - "$scripts" << 'PY'; then ok "a failed branch read is not an absent branch, even for an IID with 404 in it"; else fail "branch_exists on a 500"; fi
import sys
sys.path.insert(0, sys.argv[1])
import fix_mr
from lib import gitlab_api
class Api:
    def __init__(self, status):
        self.status = status
    def get(self, ep):
        raise gitlab_api.GlabError("glab api GET projects/p/repository/branches/gitlab-docs-review%2Fmr-404 failed",
                                   self.status)
assert fix_mr.branch_exists(Api(404), "p", "gitlab-docs-review/mr-404") is False
try:
    fix_mr.branch_exists(Api(500), "p", "gitlab-docs-review/mr-404")
    raise SystemExit(1)
except gitlab_api.GlabError:
    pass
PY

if [ "$failures" -gt 0 ]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "all fix_mr tests passed"
