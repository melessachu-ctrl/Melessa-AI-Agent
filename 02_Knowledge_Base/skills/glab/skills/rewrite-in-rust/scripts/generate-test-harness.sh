#!/usr/bin/env bash
# generate-test-harness.sh - scaffold the Phase 3 test layout for a Rust rewrite.
# Usage: generate-test-harness.sh [--no-ci] <project-name> [original-binary]
#
# <project-name> becomes the crate name and must be snake_case (my_service, not
# my-service); the script exits 2 before creating anything otherwise.
#
#   --no-ci  Skip .gitlab-ci.yml. Use it when `bench scaffold` or another
#            template owns the CI config.
#
# Creates tests/characterization.rs, tests/differential.rs, and (when an
# original binary is given) tests/compatibility.rs. Each is a top-level
# integration test, so `cargo test --test <name>` runs it. The cases you still
# have to write are #[ignore]d and call unimplemented!(), so they can never
# pass vacuously: fill them in from the behavioral spec and remove the ignore.
set -euo pipefail

WRITE_CI=1
POSITIONAL=()
for arg in "$@"; do
    case "$arg" in
        --no-ci) WRITE_CI=0 ;;
        -h|--help)
            sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        -*)
            echo "generate-test-harness: unknown option: $arg" >&2
            exit 2
            ;;
        *) POSITIONAL+=("$arg") ;;
    esac
done

if [ "${#POSITIONAL[@]}" -lt 1 ] || [ "${#POSITIONAL[@]}" -gt 2 ]; then
    echo "Usage: $0 [--no-ci] <project-name> [original-binary]" >&2
    exit 2
fi
PROJECT="${POSITIONAL[0]}"
ORIGINAL_BIN="${POSITIONAL[1]:-}"

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/crate-name.sh"

# Cargo names a new package after its directory; an existing project keeps the
# name in its Cargo.toml. Either way the name must be snake_case, and it is
# checked before anything is created.
CRATE="$(basename "$PROJECT")"
if [ -f "$PROJECT/Cargo.toml" ]; then
    EXISTING="$(package_names "$PROJECT/Cargo.toml")"
    CRATE="${EXISTING:-$CRATE}"
fi
if ! is_snake_case_crate_name "$CRATE"; then
    crate_name_error "$CRATE"
    exit 2
fi

echo "=== Generating Rust Test Harness for: $PROJECT ==="

if [ ! -d "$PROJECT" ]; then
    cargo init "$PROJECT"
fi
cd "$PROJECT"

echo ""
echo "Adding test dependencies..."
cargo add --dev proptest 2>/dev/null || echo "  proptest: add manually"
cargo add --dev insta --features yaml 2>/dev/null || echo "  insta: add manually"
cargo add --dev assert_cmd 2>/dev/null || echo "  assert_cmd: add manually"
cargo add --dev predicates 2>/dev/null || echo "  predicates: add manually"
cargo add thiserror 2>/dev/null || echo "  thiserror: add manually"
cargo add anyhow 2>/dev/null || echo "  anyhow: add manually"

if ! grep -q '\[lints.clippy\]' Cargo.toml; then
    cat >> Cargo.toml << 'TOML'

[lints.clippy]
all = "warn"
pedantic = "warn"
unwrap_used = "warn"
expect_used = "warn"
TOML
    echo "Added clippy lint configuration"
fi

mkdir -p tests/fixtures src

# --- Characterization tests ---
if [ ! -f tests/characterization.rs ]; then
    cat > tests/characterization.rs << 'RUST'
//! Characterization tests: capture what the original implementation does, not
//! what we want it to do. If a case captures an original bug, say so:
//!   // Matches original behavior. Possible original bug, see issue #NNN
//!
//! Run: cargo test --test characterization

#[test]
#[ignore = "port the first behavior from the spec, then remove this ignore"]
fn first_characterization_case() {
    unimplemented!("assert the original's output for one concrete input");
}

#[test]
#[ignore = "record what the original does with empty input: value, error, or panic"]
fn empty_input_behavior() {
    unimplemented!("assert the original's behavior for empty input");
}
RUST
fi

# --- Differential tests ---
if [ ! -f tests/differential.rs ]; then
    cat > tests/differential.rs << 'RUST'
//! Differential tests: feed generated inputs to the original and the Rust
//! implementation and assert the same output.
//!
//! Run: cargo test --test differential

use proptest::prelude::*;

proptest! {
    #[test]
    #[ignore = "wire up the original implementation, then remove this ignore"]
    fn same_output_for_text_input(input in "\\PC{0,100}") {
        unimplemented!("compare original and Rust output for {input:?}");
    }
}
RUST
fi

# --- Compatibility tests (need the original binary) ---
if [ -n "$ORIGINAL_BIN" ] && [ ! -f tests/compatibility.rs ]; then
    cat > tests/compatibility.rs << RUST
//! Compatibility tests: run the original binary and the Rust binary with the
//! same arguments and assert the same exit code, stdout, and stderr.
//!
//! Set ORIGINAL_BIN to the original binary's path.
//! Run: ORIGINAL_BIN=$ORIGINAL_BIN cargo test --test compatibility

use std::process::Command;

fn original_binary() -> String {
    std::env::var("ORIGINAL_BIN").unwrap_or_else(|_| "$ORIGINAL_BIN".to_string())
}

fn rust_binary() -> &'static str {
    env!("CARGO_BIN_EXE_$CRATE")
}

fn run_and_capture(binary: &str, args: &[&str]) -> (String, String, i32) {
    let output = Command::new(binary)
        .args(args)
        .output()
        .unwrap_or_else(|e| panic!("failed to run {binary}: {e}"));
    (
        String::from_utf8_lossy(&output.stdout).to_string(),
        String::from_utf8_lossy(&output.stderr).to_string(),
        output.status.code().unwrap_or(-1),
    )
}

fn assert_same_behavior(args: &[&str]) {
    let (orig_out, orig_err, orig_code) = run_and_capture(&original_binary(), args);
    let (rust_out, rust_err, rust_code) = run_and_capture(rust_binary(), args);

    assert_eq!(orig_code, rust_code, "exit code differs for args {args:?}");
    assert_eq!(orig_out, rust_out, "stdout differs for args {args:?}");
    assert_eq!(orig_err, rust_err, "stderr differs for args {args:?}");
}

#[test]
fn same_behavior_with_no_args() {
    assert_same_behavior(&[]);
}

#[test]
fn same_behavior_for_help() {
    assert_same_behavior(&["--help"]);
}

#[test]
fn same_behavior_for_version() {
    assert_same_behavior(&["--version"]);
}
RUST
    echo "Created compatibility tests targeting: $ORIGINAL_BIN"
fi

# --- Library root ---
if [ ! -f src/lib.rs ]; then
    cat > src/lib.rs << RUST
#![forbid(unsafe_code)]
// Remove the line above only when unsafe is justified and documented. Then use
// #![deny(unsafe_code)] with a per-module #[allow(unsafe_code)] and a SAFETY comment.

//! # $CRATE
//!
//! Rust rewrite of the original implementation. The behavioral spec and the
//! characterization tests in \`tests/\` define what compatible means.
RUST
fi

# --- CI ---
if [ "$WRITE_CI" -eq 1 ] && [ ! -f .gitlab-ci.yml ]; then
    cat > .gitlab-ci.yml << 'YAML'
default:
  image: rust:1

stages: [lint, test, security]

fmt:
  stage: lint
  script:
    - rustup component add rustfmt
    - cargo fmt --check

clippy:
  stage: lint
  script:
    - rustup component add clippy
    - cargo clippy --all-targets --all-features -- -D warnings

test:
  stage: test
  script:
    - cargo test --all-features

coverage:
  stage: test
  script:
    - cargo install cargo-llvm-cov --locked
    - cargo llvm-cov --all-features --fail-under-lines 80

audit:
  stage: security
  script:
    - cargo install cargo-audit --locked
    - cargo audit
YAML
fi

echo ""
echo "=== Test Harness Generated ==="
echo "  src/lib.rs                  (#![forbid(unsafe_code)])"
echo "  tests/characterization.rs   behavior capture, cases #[ignore]d until written"
echo "  tests/differential.rs       property-based comparison, ignored until wired up"
if [ -n "$ORIGINAL_BIN" ]; then
    echo "  tests/compatibility.rs      original vs Rust binary comparison"
fi
if [ "$WRITE_CI" -eq 1 ]; then
    echo "  .gitlab-ci.yml              fmt, clippy, test, coverage, audit"
fi
echo ""
echo "Next steps:"
echo "  1. Fill in tests/characterization.rs from the behavioral spec"
echo "  2. cargo test  (ignored cases are listed, none pass vacuously)"
echo "  3. Implement until each ported case passes; remove its #[ignore]"
echo "  4. cargo clippy -- -W clippy::all -W clippy::pedantic"
