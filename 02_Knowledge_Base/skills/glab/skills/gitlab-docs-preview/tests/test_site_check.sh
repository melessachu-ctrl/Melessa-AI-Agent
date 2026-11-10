#!/usr/bin/env bash
# Offline tests for scripts/site_check.py.
#
# Serves tests/fixtures/site (a tiny rendered docs section with planted
# failures) with `python3 -m http.server` on a random free local port, then
# runs every check against it. The planted findings must match
# tests/fixtures/expected.tsv exactly (id, file, quote). No network beyond
# 127.0.0.1, no credentials.
#
# Usage: bash skills/gitlab-docs-preview/tests/test_site_check.sh
set -uo pipefail

here=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
scripts="$here/../scripts"
fx="$here/fixtures"
work=$(mktemp -d "${TMPDIR:-/tmp}/site-check-test.XXXXXX")
server_pid=""
cleanup() {
    if [[ -n $server_pid ]]; then
        kill "$server_pid" 2>/dev/null
        wait "$server_pid" 2>/dev/null
    fi
    rm -rf "$work"
}
trap cleanup EXIT

pass=0 fail=0
ok() { pass=$((pass + 1)); printf '  ok   %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL %s\n       %s\n' "$1" "$2"; }
check() { if [[ "$2" == "$3" ]]; then ok "$1"; else bad "$1" "expected [$2] got [$3]"; fi; }
has() { if grep -qF -- "$2" "$3"; then ok "$1"; else bad "$1" "no [$2] in: $(head -c 600 "$3")"; fi; }

free_port() {
    python3 -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1])'
}

# Findings JSON -> sorted "id<TAB>file<TAB>quote" lines, with paths reduced to
# the part after the docs root (or the nav file's base name).
normalize() {
    python3 - "$1" <<'PY'
import json, sys
doc = json.load(open(sys.argv[1]))
rows = []
for f in doc["findings"]:
    path = f["file"]
    path = path.rsplit("/docs/", 1)[1] if "/docs/" in path else path.rsplit("/", 1)[-1]
    rows.append("\t".join([f["id"], path, f["quote"]]))
print("\n".join(sorted(rows)))
PY
}

port=$(free_port)
python3 -m http.server "$port" --bind 127.0.0.1 --directory "$fx/site" >"$work/server.log" 2>&1 &
server_pid=$!
base="http://127.0.0.1:$port"
for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
    python3 -c 'import sys, urllib.request; urllib.request.urlopen(sys.argv[1], timeout=1)' "$base/demo/" 2>/dev/null && break
    sleep 0.5
done

run() { # run <name> <args...>; sets rc, out, err
    out="$work/$1.out" err="$work/$1.err"
    shift
    python3 "$scripts/site_check.py" "$@" >"$out" 2>"$err"
    rc=$?
}
common=(--base "$base" --prefix demo --docs-root "$fx/docs")

echo "== url mapping =="
mapping=$(cd "$scripts" && PYTHONDONTWRITEBYTECODE=1 python3 -c '
from site_check import url_for
print(url_for("_index.md", ""), url_for("user/Foo.md", ""), url_for("a/_index.md", "runner"), url_for("x/index.md", "cli"))')
check "url_for maps _index.md, lowercases, adds prefix" "/ /user/foo/ /runner/a/ /cli/x/" "$mapping"

echo "== all checks, planted failures =="
run all all "${common[@]}" --site-dir "$fx/dgc" --nav-file "$fx/navigation.yaml" --out "$work/all.json"
check "all exits 1 on failures" 1 "$rc"
has "summary line counts failures and warnings" "site-check: FAIL (16 failures, 2 warnings)" "$out"
normalize "$work/all.json" >"$work/actual.tsv"
if diff -u "$fx/expected.tsv" "$work/actual.tsv" >"$work/diff.txt"; then
    ok "findings match expected.tsv exactly (18 planted)"
else
    bad "findings match expected.tsv exactly" "$(cat "$work/diff.txt")"
fi
fp=$(python3 -c 'import json, sys; d = json.load(open(sys.argv[1])); print(all(len(f.get("fingerprint", "")) == 40 for f in d["findings"]), d["version"])' "$work/all.json")
check "every finding has a sha1 fingerprint; version 1" "True 1" "$fp"

echo "== single checks =="
run sidebar sidebar "${common[@]}"
check "sidebar exits 1" 1 "$rc"
has "sidebar names the orphan page" "orphan.md:2 /demo/orphan/" "$out"
run links links "${common[@]}" --json
check "links exits 1" 1 "$rc"
n=$(python3 -c 'import json, sys; print(len(json.load(open(sys.argv[1]))["findings"]))' "$out")
check "links --json reports 3 findings (anchor, page, redirect hop)" 3 "$n"
has "links points at the source line" "quickstart.md:12" "$err"
run cards cards "${common[@]}"
has "cards explains why a card was dropped" "the target is a redirect stub" "$out"
run files files --prefix demo --docs-root "$fx/docs"
check "files needs no server; exits 1 on index.md" 1 "$rc"

echo "== clean subset passes =="
mkdir -p "$work/clean/reference"
cp "$fx/docs/concepts.md" "$fx/docs/old-page.md" "$work/clean/"
cp "$fx/docs/reference/_index.md" "$work/clean/reference/"
run clean all --base "$base" --prefix demo --docs-root "$work/clean"
check "clean docs root exits 0" 0 "$rc"
has "clean run says PASS" "site-check: PASS (0 failures, 0 warnings)" "$out"
has "skips trail without --site-dir" "SKIP trail" "$out"

echo "== stale page metadata =="
cp -R "$fx/dgc" "$work/dgc"
touch -t 202601010000 "$work/dgc/data/en-us/page-metadata.json"
touch -t 202601020000 "$work/dgc/data/en-us/navigation.yaml"
run stale trail "${common[@]}" --site-dir "$work/dgc"
has "warns when navigation.yaml is newer than page-metadata.json" "metadata-stale" "$work/stale.out"
touch -t 202601030000 "$work/dgc/data/en-us/page-metadata.json"
run fresh trail "${common[@]}" --site-dir "$work/dgc"
if grep -q "navigation.yaml is newer" "$out"; then bad "no stale warning when metadata is newer" "$(cat "$out")"; else ok "no stale warning when metadata is newer"; fi
run parentdir trail "${common[@]}" --site-dir "$fx"
check "trail on a dir without page-metadata.json exits 2" 2 "$rc"

echo "== usage and environment errors =="
dead=$(free_port)
run noserver sidebar --base "http://127.0.0.1:$dead" --prefix demo --docs-root "$fx/docs"
check "no server exits 2" 2 "$rc"
has "no server message says what to do" "Start the preview first" "$err"
run notrail trail "${common[@]}"
check "trail without --site-dir exits 2" 2 "$rc"
# A page that the global navigation.yaml lists in another section is not missing.
cp -R "$fx/dgc" "$work/dgc2"
printf -- "# ADMINISTER\n- title: Admin\n  url: 'demo/orphan/'\n" >> "$work/dgc2/data/en-us/navigation.yaml"
run elsewhere nav "${common[@]}" --site-dir "$work/dgc2" --nav-file "$fx/navigation.yaml" --out "$work/elsewhere.json"
# The checks below pass when grep finds nothing, so first make sure the run
# finished: exit 1 (other planted findings), no traceback, and a JSON report.
ran() { # ran <description> <out file>
  if [[ "$rc" == 1 ]] && [ -s "$2" ] && ! grep -q Traceback "$err" \
      && python3 -c 'import json,sys; sys.exit(0 if isinstance(json.load(open(sys.argv[1])), (dict, list)) else 1)' "$2"; then
    ok "$1"
  else
    bad "$1" "rc $rc, $(head -c 300 "$err")"
  fi
}
ran "nav with the global nav listing the page elsewhere finishes and writes its report" "$work/elsewhere.json"
if grep -q '"gitlab-docs-preview.nav-missing-page"' "$work/elsewhere.json" && grep -q 'orphan' "$work/elsewhere.json"; then
  bad "a page listed elsewhere in the global nav is not missing" "$(grep -c nav-missing-page "$work/elsewhere.json")"
else
  ok "a page listed elsewhere in the global nav is not missing"
fi
mkdir -p "$work/nested" && cp -R "$work/dgc2" "$work/nested/docs-gitlab-com"
run nested nav "${common[@]}" --site-dir "$work/nested" --nav-file "$fx/navigation.yaml" --out "$work/nested.json"
ran "nav with a nested docs-gitlab-com finishes and writes its report" "$work/nested.json"
if grep -q 'orphan' "$work/nested.json"; then bad "the global nav is found in a nested docs-gitlab-com" "orphan reported"; else ok "the global nav is found in a nested docs-gitlab-com"; fi

run nonav nav "${common[@]}"
check "nav without --nav-file exits 2" 2 "$rc"
run noroot files --prefix demo --docs-root "$work/missing"
check "missing docs root exits 2" 2 "$rc"

echo "== site_check.py all =="
python3 "$scripts/site_check.py" all --base "$base" --prefix demo --docs-root "$fx/docs" --site-dir "$fx/dgc" --nav-file "$fx/navigation.yaml" >"$work/v.out" 2>&1
check "all exits 1 on the planted fixture" 1 "$?"
python3 "$scripts/site_check.py" all --base "$base" --prefix demo --docs-root "$work/clean" >"$work/v2.out" 2>&1
check "all exits 0 on the clean subset" 0 "$?"

echo
echo "site_check: $pass passed, $fail failed"
[[ $fail -eq 0 ]]
