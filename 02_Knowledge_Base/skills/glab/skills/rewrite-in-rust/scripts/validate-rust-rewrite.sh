#!/usr/bin/env bash
# Validation suite for Rust rewrites. Run from the Rust project root.
#
# RIR_LABKIT controls the labkit-rs usage check for GitLab services:
#   auto           (default) run it when Cargo.toml depends on axum or tonic
#   chassis-owned  run it with --chassis-owned (bench handler crates)
#   off            skip it
#
# RIR_CRATE_NAMES=off skips the snake_case crate name check, for a workspace
# that already has hyphenated package names you can't rename.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
RIR_LABKIT="${RIR_LABKIT:-auto}"
RIR_CRATE_NAMES="${RIR_CRATE_NAMES:-on}"

# shellcheck source=/dev/null
. "$HERE/crate-name.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

passed=0
failed=0

# Run one check, keep going on failure, and show the output of a failed check.
check() {
    local name="$1" log
    shift
    echo -n "Checking $name... "
    log="$(mktemp)"
    if "$@" >"$log" 2>&1; then
        echo -e "${GREEN}✓${NC}"
        passed=$((passed + 1))
    else
        echo -e "${RED}✗${NC}"
        failed=$((failed + 1))
        tail -n 20 "$log" | sed 's/^/    /'
    fi
    rm -f "$log"
}

# Every [package] name under the project must be snake_case, except the
# manifest cargo-fuzz generates.
crate_names_ok() {
    local manifest name bad=0
    while IFS= read -r manifest; do
        # `cargo fuzz init` writes a `<crate>-fuzz` package and marks it with
        # `cargo-fuzz = true`; it's tool output, not a crate we named.
        if grep -qE '^[[:space:]]*cargo-fuzz[[:space:]]*=[[:space:]]*true' "$manifest"; then
            continue
        fi
        name="$(package_names "$manifest")"
        [ -n "$name" ] || continue
        if ! is_snake_case_crate_name "$name"; then
            echo "$manifest: $(crate_name_error "$name" 2>&1)"
            bad=1
        fi
    done < <(find . \( -name target -o -name .git -o -name .bench -o -name vendor -o -name node_modules \) -prune \
        -o -name Cargo.toml -type f -print | sort)
    return "$bad"
}

echo "===== Rust Rewrite Validation Suite ====="
echo

# Check Rust toolchain
check "Rust toolchain" cargo --version
check "rustfmt" rustfmt --version
check "clippy" cargo clippy --version

if [ "$RIR_CRATE_NAMES" != "off" ]; then
    check "snake_case crate names" crate_names_ok
    echo
fi

# Run tests
check "Unit tests" cargo test --all-features --lib
check "Integration tests" cargo test --all-features --test '*'
check "Doc tests" cargo test --doc

echo

# Format and lint
check "rustfmt" cargo fmt --check
check "clippy (warnings)" cargo clippy --all-targets --all-features -- -D warnings

echo

# Security checks
if command -v cargo-audit &>/dev/null; then
    check "cargo audit" cargo audit
else
    echo -e "${YELLOW}⚠ cargo-audit not installed, skipping${NC}"
fi

if command -v cargo-geiger &>/dev/null; then
    check "cargo geiger" cargo geiger --all-features
else
    echo -e "${YELLOW}⚠ cargo-geiger not installed, skipping${NC}"
fi

echo

# labkit-rs usage (GitLab services)
case "$RIR_LABKIT" in
    off) ;;
    chassis-owned)
        check "labkit-rs usage (chassis-owned)" "$HERE/check-labkit-usage.sh" --chassis-owned .
        ;;
    auto)
        if grep -qE '^[[:space:]]*(axum|tonic)[[:space:]]*(=|\.)' Cargo.toml 2>/dev/null; then
            check "labkit-rs usage" "$HERE/check-labkit-usage.sh" .
        else
            echo -e "${YELLOW}⚠ no axum or tonic dependency, skipping labkit-rs check${NC}"
        fi
        ;;
    *)
        echo "RIR_LABKIT must be auto, chassis-owned, or off" >&2
        exit 2
        ;;
esac

echo

# Build check
check "Release build" cargo build --release --all-features

echo
echo "===== Summary ====="
echo -e "Passed: ${GREEN}$passed${NC}"
echo -e "Failed: ${RED}$failed${NC}"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
