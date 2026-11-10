#!/usr/bin/env bash
# List Sentry issues on new-sentry.gitlab.net that match a search query, or
# show the details of one issue. Uses the API with curl, because
# stack.filename: queries time out in sentry-cli.
#
# Usage:
#   sentry_issues.sh [-p <project id>] [-n <limit>] <query>
#   sentry_issues.sh --details <short ID> [<file>...]
#
#   -p  Sentry project ID: 3 = gitlabcom (default), 4 = gitlabcom-clientside
#   -n  maximum number of issues (default 5)
#   --details  print the real firstSeen and lastSeen of one issue, and the
#       frames of its latest event (with source context) in the given files.
#       Without files, print the in-app frames.
#
# Examples:
#   sentry_issues.sh 'is:unresolved stack.filename:"lib/gitlab/ci/pipeline/chain/seed.rb"'
#   sentry_issues.sh -p 4 'is:unresolved stack.filename:*ci/pipeline_details/foo*'
#   sentry_issues.sh 'is:unresolved firstSeen:>2026-10-26T09:44:00 stack.filename:"app/models/ci/build.rb"'
#   sentry_issues.sh --details GITLABCOM-AB lib/gitlab/ci/pipeline/seed/build.rb
#
# The list always uses statsPeriod=24h: longer periods time out or return
# HTTP 500. Its firstSeen is cut to that period, so it is printed as
# "<date> (capped to 24h)". Use --details for the real date.
# The token comes from SENTRY_AUTH_TOKEN or the `token` line in
# ~/.sentryclirc. It is never printed and is not passed on the command line.
#
# Retries HTTP 429 after 10, 20 and 30 seconds (override with
# SENTRY_RETRY_WAITS="<seconds> ..."), and HTTP 500 once. With --details, an
# HTTP 500 on the latest event is tried once more on the /api/0/issues/ path.
#
# Output (list): one tab-separated line per issue on stdout:
#   shortId  id  count  firstSeen (date, capped to 24h)  title
# Output (--details): plain text, one field or frame per line.
# Diagnostics go to stderr, starting with "HTTP <code>".
#
# Exit codes:
#   0  HTTP 200 (stdout is empty when no issue matches)
#   2  still HTTP 429 after all retries: mark the link "unchecked: Sentry throttled"
#   3  HTTP 500 twice: see references/sentry.md for the firstSeen fallback
#   1  any other failure (no token, network error, other HTTP code, bad usage)
set -Eeuo pipefail
trap 'echo "error: line $LINENO: $BASH_COMMAND" >&2' ERR

die() { echo "error: $*" >&2; exit 1; }
usage() {
  cat >&2 <<'EOF'
Usage: sentry_issues.sh [-p <project id>] [-n <limit>] <query>
       sentry_issues.sh --details <short ID> [<file>...]
  -p  Sentry project ID: 3 = gitlabcom (default), 4 = gitlabcom-clientside
  -n  maximum number of issues (default 5)
  --details  real firstSeen/lastSeen and latest event frames of one issue
EOF
  exit 1
}

mode=list
short_id=
project=3
limit=5
if [ "${1:-}" = --details ]; then
  mode=details
  shift
  [ $# -ge 1 ] || usage
  short_id=$1
  shift
  case $short_id in ''|*[!A-Za-z0-9-]*) die "--details needs a short ID like GITLABCOM-AB, got: $short_id" ;; esac
else
  while getopts 'p:n:h' opt; do
    case $opt in
      p) project=$OPTARG ;;
      n) limit=$OPTARG ;;
      *) usage ;;
    esac
  done
  shift $((OPTIND - 1))
  [ $# -eq 1 ] || usage
  query=$1
  case $project in ''|*[!0-9]*) die "-p must be a number, got: $project" ;; esac
  case $limit in ''|*[!0-9]*) die "-n must be a number, got: $limit" ;; esac
fi

command -v curl >/dev/null || die "curl not found on PATH"
command -v python3 >/dev/null || die "python3 not found on PATH"

token=${SENTRY_AUTH_TOKEN:-}
if [ -z "$token" ] && [ -f "$HOME/.sentryclirc" ]; then
  token=$(awk -F= '/^[[:space:]]*token[[:space:]]*=/ { gsub(/[[:space:]]/, "", $2); print $2; exit }' "$HOME/.sentryclirc")
fi
[ -n "$token" ] || die "no Sentry token: set SENTRY_AUTH_TOKEN or add a token line in ~/.sentryclirc"

out=$(mktemp)
headers=$(mktemp)
issue=$(mktemp)
trap 'rm -f "$out" "$headers" "$issue"' EXIT
# A header file keeps the token out of the process list.
printf 'Authorization: Bearer %s\n' "$token" > "$headers"

base=${SENTRY_URL:-https://new-sentry.gitlab.net}
read -r -a waits <<< "${SENTRY_RETRY_WAITS-10 20 30}"

# fetch <API path> [curl args...]: GET into $out, with retries. Sets $code.
fetch() {
  local path=$1 throttled=0 failed=0
  shift
  while :; do
    code=$(curl -sS -m 90 -o "$out" -w '%{http_code}' -G -H "@$headers" "$base/api/0/$path" "$@") || code=000
    if [ "$code" = 429 ] && [ "$throttled" -lt "${#waits[@]}" ]; then
      echo "HTTP 429, waiting ${waits[$throttled]}s" >&2
      sleep "${waits[$throttled]}"
      throttled=$((throttled + 1))
      continue
    fi
    if [ "$code" = 500 ] && [ "$failed" -eq 0 ]; then
      echo "HTTP 500, retrying once" >&2
      failed=1
      continue
    fi
    break
  done
  echo "HTTP $code" >&2
}

# Exit unless the last fetch returned HTTP 200.
require_ok() {
  case $code in
    200) ;;
    429) exit 2 ;;
    500) exit 3 ;;
    *)
      [ -s "$out" ] && head -c 300 "$out" >&2 && echo >&2
      exit 1
      ;;
  esac
}

if [ "$mode" = list ]; then
  fetch organizations/gitlab/issues/ \
    --data-urlencode "project=$project" \
    --data-urlencode "statsPeriod=24h" \
    --data-urlencode "limit=$limit" \
    --data-urlencode "query=$query"
  require_ok
  python3 - "$out" <<'PY'
import json
import sys

try:
    issues = json.load(open(sys.argv[1]))
except ValueError as e:
    sys.exit(f"error: response is not JSON: {e}")
if not isinstance(issues, list):
    sys.exit("error: expected a list of issues")
for i in issues:
    title = " ".join(str(i.get("title", "")).split())[:100]
    first_seen = str(i.get("firstSeen", ""))[:10]
    print("\t".join([
        str(i.get("shortId", "")),
        str(i.get("id", "")),
        str(i.get("count", "")),
        f"{first_seen} (capped to 24h)" if first_seen else "",
        title,
    ]))
PY
  exit 0
fi

# --details: short ID -> issue ID -> issue (real dates) -> latest event.
fetch "organizations/gitlab/shortids/$short_id/"
require_ok
issue_id=$(python3 - "$out" <<'PY'
import json
import sys

try:
    data = json.load(open(sys.argv[1]))
except ValueError as e:
    sys.exit(f"error: response is not JSON: {e}")
group = data.get("group") or {}
issue_id = str(group.get("id") or data.get("groupId") or "")
if not issue_id.isdigit():
    sys.exit("error: no issue ID in the short ID response")
print(issue_id)
PY
)

fetch "organizations/gitlab/issues/$issue_id/"
require_ok
cp "$out" "$issue"

fetch "organizations/gitlab/issues/$issue_id/events/latest/"
if [ "$code" = 500 ]; then
  fetch "issues/$issue_id/events/latest/"
fi
require_ok

python3 - "$issue" "$out" "$@" <<'PY'
import json
import sys

def load(path):
    try:
        return json.load(open(path))
    except ValueError as e:
        sys.exit(f"error: response is not JSON: {e}")

issue = load(sys.argv[1])
event = load(sys.argv[2])
files = sys.argv[3:]

title = " ".join(str(issue.get("title", "")).split())[:200]
print(f"{issue.get('shortId', '')}\t{issue.get('id', '')}\t{title}")
print(f"firstSeen\t{issue.get('firstSeen', '')}")
print(f"lastSeen\t{issue.get('lastSeen', '')}")
print(f"count\t{issue.get('count', '')}")
print(f"latest event\t{event.get('eventID', '')}\t{event.get('dateCreated', '')}")

def matches(frame):
    if not files:
        return bool(frame.get("inApp"))
    paths = [str(frame.get("filename") or ""), str(frame.get("absPath") or "")]
    return any(f in p for f in files for p in paths if p)

printed = 0
for entry in event.get("entries") or []:
    if entry.get("type") != "exception":
        continue
    for value in (entry.get("data") or {}).get("values") or []:
        message = " ".join(str(value.get("value") or "").split())[:200]
        print(f"exception\t{value.get('type', '')}: {message}")
        frames = ((value.get("stacktrace") or {}).get("frames")) or []
        # Sentry lists the outermost frame first; print the innermost first.
        for frame in reversed(frames):
            if not matches(frame):
                continue
            printed += 1
            print(f"  {frame.get('filename', '')}:{frame.get('lineNo', '')} in {frame.get('function', '')}")
            for line in frame.get("context") or []:
                if len(line) != 2:
                    continue
                n, text = line
                mark = ">" if n == frame.get("lineNo") else " "
                print(f"    {mark} {n}  {text.rstrip()}")
if printed == 0:
    what = ", ".join(files) if files else "in-app code"
    print(f"no frame in {what}")
PY
