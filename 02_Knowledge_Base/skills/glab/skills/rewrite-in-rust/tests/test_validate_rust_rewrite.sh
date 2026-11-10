#!/usr/bin/env bash
# Tests for scripts/validate-rust-rewrite.sh with a fake cargo on PATH, so no
# toolchain or network is needed.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/../scripts/validate-rust-rewrite.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0
show_out() { printf '%s\n' "$OUT" | sed 's/^/     /'; }
ok() { PASS=$((PASS + 1)); echo "ok   - $1"; }
bad() { FAIL=$((FAIL + 1)); echo "FAIL - $1"; }

# Fake toolchain: every command succeeds unless FAKE_FAIL names the subcommand.
mkdir -p "$TMP/bin"
cat > "$TMP/bin/cargo" <<'FAKE'
#!/usr/bin/env bash
if [ -n "${FAKE_FAIL:-}" ] && [ "$1" = "$FAKE_FAIL" ]; then
    echo "fake cargo: $1 failed" >&2
    exit 1
fi
exit 0
FAKE
cat > "$TMP/bin/rustfmt" <<'FAKE'
#!/usr/bin/env bash
exit 0
FAKE
chmod +x "$TMP/bin/cargo" "$TMP/bin/rustfmt"

PROJECT="$TMP/project"
mkdir -p "$PROJECT"
printf '[package]\nname = "p"\n[dependencies]\nserde = "1"\n' > "$PROJECT/Cargo.toml"

run_validate() { # env assignments are passed through the environment
    OUT="$(cd "$PROJECT" && PATH="$TMP/bin:$PATH" "$SCRIPT" 2>&1)"
    CODE=$?
}

run_validate
if [ "$CODE" -eq 0 ]; then ok "all checks passing exits 0"; else bad "all passing exited $CODE"; show_out; fi
if echo "$OUT" | grep -q "Failed: .*0"; then ok "summary reports zero failures"; else bad "summary missing zero failures"; fi

OUT="$(cd "$PROJECT" && FAKE_FAIL=test PATH="$TMP/bin:$PATH" "$SCRIPT" 2>&1)"
CODE=$?
if [ "$CODE" -eq 1 ]; then ok "a failing check exits 1"; else bad "failing check exited $CODE"; fi
if echo "$OUT" | grep -q "Release build"; then ok "later checks still run after a failure"; else bad "stopped at first failure"; fi

# axum projects get the labkit-rs check, and an unwired one fails it.
printf '[package]\nname = "p"\n[dependencies]\naxum = "0.8"\n' > "$PROJECT/Cargo.toml"
mkdir -p "$PROJECT/src"
echo 'fn main() {}' > "$PROJECT/src/main.rs"
run_validate
if echo "$OUT" | grep -q "Checking labkit-rs usage"; then ok "axum project runs the labkit-rs check"; else bad "labkit-rs check not run for axum"; fi
if [ "$CODE" -eq 1 ]; then ok "unwired axum service fails validation"; else bad "unwired axum service exited $CODE"; fi

OUT="$(cd "$PROJECT" && RIR_LABKIT=off PATH="$TMP/bin:$PATH" "$SCRIPT" 2>&1)"
CODE=$?
if [ "$CODE" -eq 0 ]; then ok "RIR_LABKIT=off skips the labkit-rs check"; else bad "RIR_LABKIT=off exited $CODE"; fi

OUT="$(cd "$PROJECT" && RIR_LABKIT=bogus PATH="$TMP/bin:$PATH" "$SCRIPT" 2>&1)"
CODE=$?
if [ "$CODE" -eq 2 ]; then ok "bad RIR_LABKIT value is a usage error"; else bad "bad RIR_LABKIT exited $CODE"; fi

# --- crate names must be snake_case
printf '[package]\nname = "my-service"\n[dependencies]\nserde = "1"\n' > "$PROJECT/Cargo.toml"
run_validate
if [ "$CODE" -eq 1 ]; then ok "hyphenated package name fails validation"; else bad "hyphenated name exited $CODE"; fi
if echo "$OUT" | grep -q "use 'my_service'"; then ok "failure suggests the snake_case name"; else bad "no suggestion in output"; fi

mkdir -p "$PROJECT/crates/inner"
printf '[package]\nname = "inner_ok"\n' > "$PROJECT/crates/inner/Cargo.toml"
printf '[package]\nname = "my_service"\n' > "$PROJECT/Cargo.toml"
run_validate
if [ "$CODE" -eq 0 ]; then ok "snake_case workspace passes"; else bad "snake_case workspace exited $CODE"; fi

printf '[package]\nname = "bad-member"\n' > "$PROJECT/crates/inner/Cargo.toml"
run_validate
if [ "$CODE" -eq 1 ]; then ok "a hyphenated workspace member fails"; else bad "hyphenated member exited $CODE"; fi

mkdir -p "$PROJECT/target/debug"
printf '[package]\nname = "bad-member"\n' > "$PROJECT/target/debug/Cargo.toml"
printf '[package]\nname = "inner_ok"\n' > "$PROJECT/crates/inner/Cargo.toml"
run_validate
if [ "$CODE" -eq 0 ]; then ok "target/ manifests are ignored"; else bad "target/ manifest tripped the check ($CODE)"; fi

# cargo-fuzz writes `<crate>-fuzz`; that generated manifest is skipped, but a
# real crate in a directory named fuzz is not.
mkdir -p "$PROJECT/fuzz"
printf '[package]\nname = "my_service-fuzz"\nversion = "0.0.0"\n\n[package.metadata]\ncargo-fuzz = true\n' > "$PROJECT/fuzz/Cargo.toml"
run_validate
if [ "$CODE" -eq 0 ]; then ok "cargo-fuzz generated manifest is skipped"; else bad "cargo-fuzz manifest tripped the check ($CODE)"; printf '%s\n' "$OUT" | sed 's/^/     /'; fi
printf '[package]\nname = "fuzz-helpers"\nversion = "0.1.0"\n' > "$PROJECT/fuzz/Cargo.toml"
run_validate
if [ "$CODE" -eq 1 ]; then ok "a real crate under fuzz/ is still checked"; else bad "hand-written fuzz/ crate skipped ($CODE)"; fi
rm -rf "$PROJECT/fuzz"

printf '[package]\nname = "my-service"\n' > "$PROJECT/Cargo.toml"
OUT="$(cd "$PROJECT" && RIR_CRATE_NAMES=off PATH="$TMP/bin:$PATH" "$SCRIPT" 2>&1)"
CODE=$?
if [ "$CODE" -eq 0 ]; then ok "RIR_CRATE_NAMES=off skips the check"; else bad "RIR_CRATE_NAMES=off exited $CODE"; fi

echo
echo "passed: $PASS, failed: $FAIL"
[ "$FAIL" -eq 0 ]
