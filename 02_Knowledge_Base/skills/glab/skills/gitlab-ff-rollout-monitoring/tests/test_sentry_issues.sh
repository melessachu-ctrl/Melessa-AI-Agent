#!/usr/bin/env bash
# `ok` always returns 0, so `test && ok || not_ok` is safe here.
# shellcheck disable=SC2015
# Tests for scripts/sentry_issues.sh. A fake curl on PATH returns the HTTP
# codes listed in $FAKE_DIR/codes, one per call, so no network or token is
# needed.
#
# Usage: bash tests/test_sentry_issues.sh   (exits non-zero if any case fails)

set -uo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$TESTS_DIR/../scripts/sentry_issues.sh"

if ! command -v python3 >/dev/null 2>&1; then
  echo "SKIP: python3 not found; sentry_issues.sh needs it" >&2
  exit 0
fi

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/bin"

cat > "$WORK/bin/curl" <<'SH'
#!/usr/bin/env bash
# Fake curl: logs its arguments, copies the header file, writes
# $FAKE_DIR/body.<call number> (or $FAKE_DIR/body) to the -o file and prints
# the next code from $FAKE_DIR/codes.
printf '%s\n' "$@" >> "$FAKE_DIR/args"
out=
prev=
for a in "$@"; do
  [ "$prev" = -o ] && out=$a
  [ "$prev" = -H ] && case $a in @*) cat "${a#@}" > "$FAKE_DIR/header" ;; esac
  prev=$a
done
n=$(( $(cat "$FAKE_DIR/calls" 2>/dev/null || echo 0) + 1 ))
echo "$n" > "$FAKE_DIR/calls"
code=$(sed -n "${n}p" "$FAKE_DIR/codes")
if [ "$code" = fail ]; then
  echo "curl: (28) Operation timed out" >&2
  printf '000'
  exit 28
fi
if [ -f "$FAKE_DIR/body.$n" ]; then
  cp "$FAKE_DIR/body.$n" "$out"
else
  cp "$FAKE_DIR/body" "$out"
fi
printf '%s' "$code"
SH
chmod +x "$WORK/bin/curl"

pass=0
fail=0
ok() { pass=$((pass + 1)); echo "ok   - $1"; }
not_ok() { fail=$((fail + 1)); echo "FAIL - $1"; }

# setup <codes...>: fresh fake state, default token and body.
setup() {
  export FAKE_DIR="$WORK/case"
  rm -rf "$FAKE_DIR"
  mkdir -p "$FAKE_DIR/home"
  printf '%s\n' "$@" > "$FAKE_DIR/codes"
  printf '[]' > "$FAKE_DIR/body"
  export HOME="$FAKE_DIR/home"
  export SENTRY_AUTH_TOKEN=secret-token-123
  export SENTRY_RETRY_WAITS="0 0 0"
}

# run_script <args...>: sets $status, $stdout, $stderr.
run_script() {
  PATH="$WORK/bin:$PATH" bash "$SCRIPT" "$@" > "$FAKE_DIR/stdout" 2> "$FAKE_DIR/stderr"
  status=$?
  stdout=$(cat "$FAKE_DIR/stdout")
  stderr=$(cat "$FAKE_DIR/stderr")
}

calls() { cat "$FAKE_DIR/calls" 2>/dev/null || echo 0; }

# --- HTTP 200 lists issues as TSV ---
setup 200
cat > "$FAKE_DIR/body" <<'JSON'
[{"id":"101","shortId":"GITLABCOM-AB","count":"42","firstSeen":"2026-10-26T10:00:00Z","title":"TimeoutError:\tseed\ntook too long"},
 {"id":"102","shortId":"GITLABCOM-CD","count":"1","firstSeen":"2026-10-27T08:00:00Z","title":"NoMethodError"}]
JSON
run_script 'is:unresolved stack.filename:"lib/a.rb"'
[ "$status" -eq 0 ] && ok "200 exits 0" || not_ok "200 exits 0 (got $status: $stderr)"
first=$(printf '%s\n' "$stdout" | sed -n 1p)
expected=$(printf 'GITLABCOM-AB\t101\t42\t2026-10-26 (capped to 24h)\tTimeoutError: seed took too long')
[ "$first" = "$expected" ] && ok "prints TSV, marks firstSeen as capped, flattens titles" || not_ok "TSV line (got: $first)"
[ "$(printf '%s\n' "$stdout" | wc -l | tr -d ' ')" = 2 ] && ok "one line per issue" || not_ok "one line per issue"
grep -qx 'statsPeriod=24h' "$FAKE_DIR/args" && ok "uses statsPeriod=24h" || not_ok "uses statsPeriod=24h"
grep -qx 'project=3' "$FAKE_DIR/args" && ok "default project is 3" || not_ok "default project is 3"
grep -qx 'limit=5' "$FAKE_DIR/args" && ok "default limit is 5" || not_ok "default limit is 5"
grep -qx 'query=is:unresolved stack.filename:"lib/a.rb"' "$FAKE_DIR/args" && ok "passes the query as is" || not_ok "passes the query as is"
grep -q 'secret-token-123' "$FAKE_DIR/args" && not_ok "token is on the command line" || ok "token is not on the command line"
grep -qx 'Authorization: Bearer secret-token-123' "$FAKE_DIR/header" && ok "token is sent in the header file" || not_ok "token is sent in the header file"
case $stdout$stderr in *secret-token-123*) not_ok "token is printed" ;; *) ok "token is not printed" ;; esac
case $stderr in *"HTTP 200"*) ok "reports the HTTP code" ;; *) not_ok "reports the HTTP code" ;; esac

# --- empty result ---
setup 200
run_script 'is:unresolved'
[ "$status" -eq 0 ] && [ -z "$stdout" ] && ok "no issues: exit 0, empty stdout" || not_ok "no issues (got $status)"

# --- options ---
setup 200
run_script -p 4 -n 10 'is:unresolved'
grep -qx 'project=4' "$FAKE_DIR/args" && grep -qx 'limit=10' "$FAKE_DIR/args" && ok "-p and -n are passed" || not_ok "-p and -n are passed"

setup 200
run_script -p abc 'is:unresolved'
[ "$status" -eq 1 ] && [ "$(calls)" = 0 ] && ok "non-numeric -p fails before curl" || not_ok "non-numeric -p (got $status)"

setup 200
run_script
[ "$status" -eq 1 ] && [ "$(calls)" = 0 ] && ok "missing query fails" || not_ok "missing query (got $status)"
case $stderr in *"Usage: sentry_issues.sh"*"-p "*"-n "*) ok "missing query prints usage" ;; *) not_ok "missing query prints usage (got: $stderr)" ;; esac

# --- token from ~/.sentryclirc ---
setup 200
unset SENTRY_AUTH_TOKEN
printf '[auth]\ntoken = rc-token-456\n' > "$HOME/.sentryclirc"
run_script 'is:unresolved'
grep -qx 'Authorization: Bearer rc-token-456' "$FAKE_DIR/header" && ok "reads the token from ~/.sentryclirc" || not_ok "reads the token from ~/.sentryclirc"

setup 200
unset SENTRY_AUTH_TOKEN
run_script 'is:unresolved'
[ "$status" -eq 1 ] && [ "$(calls)" = 0 ] && ok "no token: exit 1 before curl" || not_ok "no token (got $status)"

# --- retries ---
setup 429 429 200
run_script 'is:unresolved'
[ "$status" -eq 0 ] && [ "$(calls)" = 3 ] && ok "429 is retried" || not_ok "429 retry (got $status, $(calls) calls)"

setup 429 429 429 429 200
run_script 'is:unresolved'
[ "$status" -eq 2 ] && [ "$(calls)" = 4 ] && ok "429 after all retries: exit 2" || not_ok "429 give up (got $status, $(calls) calls)"

setup 500 200
run_script 'is:unresolved'
[ "$status" -eq 0 ] && [ "$(calls)" = 2 ] && ok "500 is retried once" || not_ok "500 retry (got $status, $(calls) calls)"

setup 500 500 200
run_script 'is:unresolved'
[ "$status" -eq 3 ] && [ "$(calls)" = 2 ] && ok "500 twice: exit 3" || not_ok "500 give up (got $status, $(calls) calls)"

# --- other failures ---
setup 404
printf '{"detail":"not found"}' > "$FAKE_DIR/body"
run_script 'is:unresolved'
[ "$status" -eq 1 ] && ok "404: exit 1" || not_ok "404 (got $status)"
case $stderr in *'not found'*) ok "404: shows the body" ;; *) not_ok "404: shows the body" ;; esac

setup fail
run_script 'is:unresolved'
[ "$status" -eq 1 ] && ok "network error: exit 1" || not_ok "network error (got $status)"
case $stderr in *"HTTP 000"*) ok "network error: reports HTTP 000" ;; *) not_ok "network error: reports HTTP 000" ;; esac

setup 200
printf '<html>oops</html>' > "$FAKE_DIR/body"
run_script 'is:unresolved'
[ "$status" -ne 0 ] && ok "non-JSON body fails" || not_ok "non-JSON body fails"

# --- --details ---
# details_bodies: short ID, issue and latest event responses for calls 1-3.
details_bodies() {
  printf '{"shortId":"GITLABCOM-AB","groupId":"101","group":{"id":"101"}}' > "$FAKE_DIR/body.1"
  printf '{"id":"101","shortId":"GITLABCOM-AB","count":"42","title":"TimeoutError","firstSeen":"2026-10-20T08:00:00Z","lastSeen":"2026-10-28T09:00:00Z"}' > "$FAKE_DIR/body.2"
  cat > "$FAKE_DIR/body.3" <<'JSON'
{"eventID":"abc","dateCreated":"2026-10-28T09:00:00Z","entries":[{"type":"exception","data":{"values":[{"type":"TimeoutError","value":"Timed out","stacktrace":{"frames":[
 {"filename":"lib/gitlab/ci/pipeline/chain/seed.rb","lineNo":20,"function":"perform!","inApp":true,"context":[[20,"  seed!"]]},
 {"filename":"gems/foo.rb","lineNo":5,"function":"call","inApp":false,"context":[]},
 {"filename":"lib/gitlab/ci/pipeline/seed/build.rb","lineNo":42,"function":"included?","inApp":true,"context":[[41,"  def included?"],[42,"    check_execution_time!"],[43,"  end"]]}]}}]}}]}
JSON
}

setup 200 200 200
details_bodies
run_script --details GITLABCOM-AB lib/gitlab/ci/pipeline/seed/build.rb
[ "$status" -eq 0 ] && ok "--details exits 0" || not_ok "--details exits 0 (got $status: $stderr)"
grep -q '/api/0/organizations/gitlab/shortids/GITLABCOM-AB/$' "$FAKE_DIR/args" && ok "--details resolves the short ID" || not_ok "--details resolves the short ID"
grep -q '/api/0/organizations/gitlab/issues/101/events/latest/$' "$FAKE_DIR/args" && ok "--details reads the latest event" || not_ok "--details reads the latest event"
grep -qx 'statsPeriod=24h' "$FAKE_DIR/args" && not_ok "--details uses statsPeriod" || ok "--details has no statsPeriod"
printf '%s\n' "$stdout" | grep -qx "$(printf 'firstSeen\t2026-10-20T08:00:00Z')" && ok "--details prints the real firstSeen" || not_ok "--details firstSeen (got: $stdout)"
printf '%s\n' "$stdout" | grep -qx "$(printf 'lastSeen\t2026-10-28T09:00:00Z')" && ok "--details prints lastSeen" || not_ok "--details lastSeen"
printf '%s\n' "$stdout" | grep -qx '  lib/gitlab/ci/pipeline/seed/build.rb:42 in included?' && ok "--details prints the matching frame" || not_ok "--details matching frame (got: $stdout)"
printf '%s\n' "$stdout" | grep -qx '    > 42      check_execution_time!' && ok "--details marks the frame line in the context" || not_ok "--details context (got: $stdout)"
case $stdout in *chain/seed.rb*|*gems/foo.rb*) not_ok "--details prints frames in other files" ;; *) ok "--details prints only frames in the given files" ;; esac

setup 200 200 200
details_bodies
run_script --details GITLABCOM-AB
case $stdout in *chain/seed.rb:20*seed/build.rb:42*) not_ok "--details without files: innermost first" ;; *seed/build.rb:42*chain/seed.rb:20*) ok "--details without files: in-app frames, innermost first" ;; *) not_ok "--details without files (got: $stdout)" ;; esac
case $stdout in *gems/foo.rb*) not_ok "--details without files prints gem frames" ;; *) ok "--details without files skips non-app frames" ;; esac

setup 200 200 200
details_bodies
run_script --details GITLABCOM-AB app/models/none.rb
printf '%s\n' "$stdout" | grep -qx 'no frame in app/models/none.rb' && ok "--details says when no frame matches" || not_ok "--details no match (got: $stdout)"

setup 200 200 500 500 200
details_bodies
cp "$FAKE_DIR/body.3" "$FAKE_DIR/body.5"
run_script --details GITLABCOM-AB
[ "$status" -eq 0 ] && grep -q '/api/0/issues/101/events/latest/$' "$FAKE_DIR/args" && ok "--details falls back to /api/0/issues/ on 500" || not_ok "--details 500 fallback (got $status, $(calls) calls)"

setup 200 200 500 500 500 500
details_bodies
run_script --details GITLABCOM-AB
[ "$status" -eq 3 ] && ok "--details: 500 on both paths exits 3" || not_ok "--details 500 give up (got $status)"

setup 404
run_script --details GITLABCOM-AB
[ "$status" -eq 1 ] && [ "$(calls)" = 1 ] && ok "--details unknown short ID: exit 1" || not_ok "--details 404 (got $status)"

setup 200
run_script --details 'GITLABCOM-AB;rm'
[ "$status" -eq 1 ] && [ "$(calls)" = 0 ] && ok "--details rejects a bad short ID before curl" || not_ok "--details bad short ID (got $status)"

setup 200
run_script --details
[ "$status" -eq 1 ] && [ "$(calls)" = 0 ] && ok "--details without a short ID fails" || not_ok "--details without a short ID (got $status)"

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
