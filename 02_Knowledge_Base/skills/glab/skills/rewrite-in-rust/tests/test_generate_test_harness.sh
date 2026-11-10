#!/usr/bin/env bash
# Tests for scripts/generate-test-harness.sh with a fake cargo on PATH.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/../scripts/generate-test-harness.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0
ok() { PASS=$((PASS + 1)); echo "ok   - $1"; }
bad() { FAIL=$((FAIL + 1)); echo "FAIL - $1"; }

check() { # name command...
    local name="$1"
    shift
    if "$@"; then ok "$name"; else bad "$name"; fi
}

# Fake cargo: `init <dir>` creates a bin crate, everything else succeeds.
mkdir -p "$TMP/bin"
cat > "$TMP/bin/cargo" <<'FAKE'
#!/usr/bin/env bash
if [ "$1" = "init" ]; then
    mkdir -p "$2/src"
    printf '[package]\nname = "%s"\nversion = "0.1.0"\n' "$2" > "$2/Cargo.toml"
    echo 'fn main() {}' > "$2/src/main.rs"
fi
exit 0
FAKE
chmod +x "$TMP/bin/cargo"

gen() { (cd "$TMP" && PATH="$TMP/bin:$PATH" "$SCRIPT" "$@" >"$TMP/out.log" 2>&1); }

# --- default run with an original binary
gen demo /usr/bin/true
P="$TMP/demo"
check "exits cleanly" test -f "$P/Cargo.toml"
check "characterization.rs is a top-level test target" test -f "$P/tests/characterization.rs"
check "differential.rs is a top-level test target" test -f "$P/tests/differential.rs"
check "compatibility.rs generated with an original binary" test -f "$P/tests/compatibility.rs"
check "no mod.rs test files that cargo would not run" test ! -e "$P/tests/characterization/mod.rs"
check "compatibility test names the project binary" grep -q 'CARGO_BIN_EXE_demo' "$P/tests/compatibility.rs"
check "compatibility test records the original binary" grep -q '/usr/bin/true' "$P/tests/compatibility.rs"
check "lib.rs forbids unsafe" grep -q 'forbid(unsafe_code)' "$P/src/lib.rs"
check "lib.rs names the project" grep -q '# demo' "$P/src/lib.rs"
check "clippy lints appended" grep -q 'lints.clippy' "$P/Cargo.toml"
check "GitLab CI generated" test -f "$P/.gitlab-ci.yml"
check "no GitHub Actions config" test ! -e "$P/.github"
check "no vacuous assert!(true) anywhere" test -z "$(grep -rn 'assert!(true' "$P/tests" "$P/src" || true)"
check "unwritten cases are ignored" grep -q '#\[ignore' "$P/tests/characterization.rs"
check "unwritten cases cannot pass" grep -q 'unimplemented!' "$P/tests/characterization.rs"

# --- crate names must be snake_case, checked before anything is created
gen my-service /usr/bin/true; code=$?
check "hyphenated name is rejected with exit 2" test "$code" -eq 2
check "rejection names the snake_case spelling" grep -q "use 'my_service'" "$TMP/out.log"
check "rejected name creates no directory" test ! -e "$TMP/my-service"
gen MyService; code=$?
check "uppercase name is rejected" test "$code" -eq 2
check "uppercase suggestion is lowercased" grep -q "use 'myservice'" "$TMP/out.log"
gen 9lives; code=$?
check "name starting with a digit is rejected" test "$code" -eq 2
check "unconvertible name says why" grep -q "starts with a letter" "$TMP/out.log"
gen double__underscore; code=$?
check "double underscore is rejected" test "$code" -eq 2
gen nested/path/my-service; code=$?
check "only the last path segment is the crate name" test "$code" -eq 2
check "nothing created for a rejected nested path" test ! -e "$TMP/nested"
gen my_service /usr/bin/true; code=$?
check "snake_case name is accepted" test "$code" -eq 0
check "compat test uses the snake_case binary name" grep -q 'CARGO_BIN_EXE_my_service' "$TMP/my_service/tests/compatibility.rs"

# An existing project keeps the name in its Cargo.toml, wherever it lives.
mkdir -p "$TMP/legacy_dir"
printf '[package]\nname = "old-name"\n[dependencies]\nname = "x"\n' > "$TMP/legacy_dir/Cargo.toml"
gen legacy_dir; code=$?
check "existing package name is validated, not the directory" test "$code" -eq 2
check "rejection quotes the Cargo.toml name" grep -q "'old-name'" "$TMP/out.log"

# --- no original binary, no CI
gen --no-ci plain
P="$TMP/plain"
check "no compatibility test without an original binary" test ! -e "$P/tests/compatibility.rs"
check "--no-ci skips .gitlab-ci.yml" test ! -e "$P/.gitlab-ci.yml"

# --- re-running keeps hand-written tests
echo '// hand-written' > "$P/tests/characterization.rs"
gen --no-ci plain
check "re-run keeps an edited characterization.rs" grep -q 'hand-written' "$P/tests/characterization.rs"
before="$(grep -c 'lints.clippy' "$P/Cargo.toml")"
check "re-run does not duplicate lint config" test "$before" -eq 1

# --- usage errors
gen; code=$?
check "no arguments is a usage error" test "$code" -eq 2
gen --bogus demo; code=$?
check "unknown option is a usage error" test "$code" -eq 2
gen --help; code=$?
check "--help exits 0" test "$code" -eq 0

echo
echo "passed: $PASS, failed: $FAIL"
[ "$FAIL" -eq 0 ]
