#!/usr/bin/env bash
# Tests for scripts/crate-name.sh, the shared crate naming rule.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=/dev/null
. "$HERE/../scripts/crate-name.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0
ok() { PASS=$((PASS + 1)); echo "ok   - $1"; }
bad() { FAIL=$((FAIL + 1)); echo "FAIL - $1"; }

accepts() { if is_snake_case_crate_name "$1"; then ok "accepts '$1'"; else bad "should accept '$1'"; fi; }
rejects() { if is_snake_case_crate_name "$1"; then bad "should reject '$1'"; else ok "rejects '$1'"; fi; }
suggests() { # name expected
    local got
    got="$(suggest_crate_name "$1")"
    if [ "$got" = "$2" ]; then ok "'$1' -> '$2'"; else bad "'$1' -> '$got', wanted '$2'"; fi
}

for name in demo my_service a1 log_parser_v2 x; do accepts "$name"; done
rejects "$(printf 'ok_name\nBad-Name')"
for name in my-service MyService 9lives _lead trail_ double__under "" "has space" naïve; do rejects "$name"; done

suggests my-service my_service
suggests MyService myservice
suggests "Log Parser" log_parser
suggests "--odd--name--" odd_name
suggests 9lives 9lives

# package_names reads only the [package] table.
cat > "$TMP/Cargo.toml" <<'TOML'
[workspace.package]
name = "not_this"

[dependencies]
name = "nor_this"

[package]
version = "0.1.0"
name = "the-real-one"  # trailing comment
TOML
got="$(package_names "$TMP/Cargo.toml")"
if [ "$got" = "the-real-one" ]; then ok "package_names reads the [package] name"; else bad "package_names returned '$got'"; fi

printf '[workspace]\nmembers = []\n' > "$TMP/ws.toml"
if [ -z "$(package_names "$TMP/ws.toml")" ]; then ok "package_names is empty for a virtual workspace"; else bad "virtual workspace returned a name"; fi

err="$(crate_name_error my-service 2>&1)"
if [ "$err" = "crate name 'my-service' is not snake_case; use 'my_service'" ]; then ok "error message names the fix"; else bad "error message: $err"; fi

echo
echo "passed: $PASS, failed: $FAIL"
[ "$FAIL" -eq 0 ]
