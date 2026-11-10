# Testing and validation strategies for Rust rewrites

## Table of Contents

- [Principle: the test suite IS the specification](#principle-the-test-suite-is-the-specification)
- [Layer 1: Characterization tests](#layer-1-characterization-tests-capture-existing-behavior)
- [Layer 2: Snapshot testing with insta](#layer-2-snapshot-testing-with-insta)
- [Layer 3: Compatibility testing](#layer-3-compatibility-testing-side-by-side-comparison)
- [Layer 4: Differential testing](#layer-4-differential-testing-property-based-comparison)
- [Layer 5: Fuzz testing](#layer-5-fuzz-testing-with-cargo-fuzz)
- [Layer 6: Performance regression](#layer-6-performance-regression-testing)
- [Integration with original test suite](#integration-with-original-test-suite)
- [Quantitative feature parity tracking](#quantitative-feature-parity-tracking)

## Principle: the test suite IS the specification

For a rewrite, tests serve a fundamentally different purpose than in greenfield development.
They are not testing "does my code work" — they are testing "does my code behave identically
to the original." This distinction drives every testing decision.

## Layer 1: Characterization tests (capture existing behavior)

### The Feathers method

Source: Michael Feathers, Working Effectively with Legacy Code (2004)
Also: https://www.artima.com/weblogs/viewpost.jsp?thread=198296

Algorithm:
1. Write a test that calls the existing code with a known input
2. Write an assertion you KNOW will fail (e.g., assert result equals "UNKNOWN")
3. Run the test — the failure message tells you the actual result
4. Update the assertion to match the actual result
5. You now have a test that documents the existing behavior
6. Repeat for all important code paths

### Translating characterization tests to Rust

Record the behavior of the original implementation, then write Rust tests that assert
the same behavior:

```rust
#[cfg(test)]
mod characterization_tests {
    use super::*;

    // These tests document the EXISTING behavior, not desired behavior.
    // If a test captures a bug in the original, add a comment:
    // "NOTE: This matches original behavior. Original bug? See issue #123"

    #[test]
    fn parse_empty_input_returns_empty_list() {
        // Characterization: original returns [] for empty input, not an error
        let result = parse("");
        assert_eq!(result, Ok(vec![]));
    }

    #[test]
    fn parse_preserves_trailing_whitespace() {
        // Characterization: original does NOT trim trailing whitespace
        // This seems like a bug but is preserved for compatibility
        let result = parse("hello  ");
        assert_eq!(result, Ok(vec!["hello  ".to_string()]));
    }

    #[test]
    fn negative_zero_is_treated_as_positive_zero() {
        // Characterization: original treats -0 and 0 identically
        let result_neg = process(-0.0);
        let result_pos = process(0.0);
        assert_eq!(result_neg, result_pos);
    }
}
```

## Layer 2: Snapshot testing with insta

The `insta` crate (https://docs.rs/insta, 34M+ downloads) captures output as reference
snapshots. Ideal for rewrites because you can capture the original's output and verify
the Rust version produces the same output.

```rust
// Cargo.toml:
// [dev-dependencies]
// insta = { version = "1", features = ["yaml"] }

#[cfg(test)]
mod snapshot_tests {
    use insta::assert_snapshot;
    use insta::assert_yaml_snapshot;

    #[test]
    fn cli_help_output_matches_original() {
        let output = run_cli(&["--help"]);
        // First run: creates a snapshot file in snapshots/ directory
        // Subsequent runs: compare against stored snapshot
        assert_snapshot!(output.stdout);
    }

    #[test]
    fn config_parsing_matches_original() {
        let config = parse_config("test-data/sample.conf");
        // Snapshot the parsed structure
        assert_yaml_snapshot!(config);
    }

    #[test]
    fn error_messages_match_original() {
        let err = parse_config("nonexistent.conf").unwrap_err();
        assert_snapshot!(err.to_string());
    }
}
```

Workflow for rewrites:
1. Run original implementation → capture outputs as snapshot files
2. Write Rust tests with `assert_snapshot!` pointing to those files
3. Implement until all snapshots match
4. Use `cargo insta review` to interactively review any differences

```bash
# Review all pending snapshot changes interactively
cargo insta review

# Accept all pending changes (when migrating from original output)
cargo insta accept
```

## Layer 3: Property-based testing with proptest

Source: https://github.com/proptest-rs/proptest (93M+ downloads)

Property-based testing generates random inputs and verifies that properties hold.
For rewrites, the key property is: **both implementations produce the same output
for the same input.**

```rust
// Cargo.toml:
// [dev-dependencies]
// proptest = "1"

use proptest::prelude::*;

proptest! {
    // Differential property test: Rust and original produce same output
    #[test]
    fn rust_matches_original_for_all_inputs(input in ".*") {
        let original_output = run_original(&input);
        let rust_output = run_rust(&input);
        prop_assert_eq!(original_output, rust_output,
            "Divergence on input: {:?}", input);
    }

    // Property: output length is always ≤ input length (if this is an invariant)
    #[test]
    fn output_never_exceeds_input_length(input in prop::collection::vec(any::<u8>(), 0..1000)) {
        let output = process(&input);
        prop_assert!(output.len() <= input.len());
    }

    // Property: function is idempotent
    #[test]
    fn normalize_is_idempotent(input in "\\PC*") {
        let once = normalize(&input);
        let twice = normalize(&once);
        prop_assert_eq!(once, twice, "normalize is not idempotent for: {:?}", input);
    }
}
```

### Custom strategies for domain-specific inputs

```rust
use proptest::prelude::*;

// Generate valid email addresses
fn email_strategy() -> impl Strategy<Value = String> {
    ("[a-z]{1,10}", "[a-z]{1,10}", "[a-z]{2,4}")
        .prop_map(|(user, domain, tld)| format!("{user}@{domain}.{tld}"))
}

// Generate configuration objects
fn config_strategy() -> impl Strategy<Value = Config> {
    (
        "[a-z.]{1,50}",      // host
        1024..65535u16,       // port
        prop::bool::ANY,     // debug
    ).prop_map(|(host, port, debug)| Config { host, port, debug })
}

proptest! {
    #[test]
    fn config_roundtrip(config in config_strategy()) {
        let serialized = config.to_string();
        let deserialized = Config::from_str(&serialized).unwrap();
        prop_assert_eq!(config, deserialized);
    }
}
```

## Layer 4: Running the original project's test suite

This is the most powerful validation technique. Run the ORIGINAL project's own test suite
against the Rust implementation.

### The sudo-rs approach (gold standard)

Source: https://ferrous-systems.com/blog/testing-sudo-rs/

sudo-rs built an implementation-agnostic compliance test suite:
- Each test describes a behavior from sudo's documentation
- Tests run in ephemeral Docker containers with custom configurations
- Switching implementations requires only changing `SUDO_UNDER_TEST` env var
- Test infrastructure is SHARED between original and Rust implementations
- CI enforces: (a) all tests pass against original sudo, (b) no `#[ignore]` test accidentally
  passes against sudo-rs (tracked as feature progress)
- This process discovered and fixed 2 bugs in the ORIGINAL sudo

Implementation pattern:
```rust
// tests/compliance/mod.rs
use std::process::Command;

fn sudo_under_test() -> &'static str {
    // Switch between implementations via environment variable
    std::env::var("SUDO_UNDER_TEST")
        .unwrap_or_else(|_| "sudo-rs".to_string())
        .leak()
}

#[test]
fn sudo_preserves_home_env_with_h_flag() {
    let output = Command::new(sudo_under_test())
        .args(["-H", "env"])
        .output()
        .expect("failed to execute");

    let home = String::from_utf8_lossy(&output.stdout)
        .lines()
        .find(|l| l.starts_with("HOME="))
        .unwrap_or("")
        .to_string();

    assert!(home.starts_with("HOME=/root"), "Expected root home, got: {home}");
}
```

### The uutils approach (quantitative tracking)

Source: https://github.com/uutils/coreutils

uutils runs the entire GNU coreutils test suite against Rust binaries:
1. Build both GNU and Rust coreutils
2. Run GNU tests against Rust binaries
3. Track pass/fail rates quantitatively in CI
4. Compatibility percentage is a release metric: 87.75% → 96.28% (v0.6.0)

```bash
# Run GNU test suite against Rust coreutils
# (simplified — actual setup is more complex)
export PATH="/path/to/rust/coreutils/bin:$PATH"
cd gnu-coreutils-test-suite
make check 2>&1 | tee test-results.log

# Count pass/fail
grep -c "^PASS:" test-results.log
grep -c "^FAIL:" test-results.log
```

### Adapting this pattern for any project

```bash
#!/bin/bash
# run-original-tests.sh: Run the original project's test suite against the Rust implementation

ORIGINAL_TEST_DIR="$1"
RUST_BINARY="$2"

# Replace the original binary with the Rust binary in PATH
export PATH="$(dirname "$RUST_BINARY"):$PATH"

# Run the original test suite
cd "$ORIGINAL_TEST_DIR"
make test 2>&1 | tee /tmp/test-output.log

# Parse results
PASS=$(grep -c "PASS\|ok" /tmp/test-output.log)
FAIL=$(grep -c "FAIL\|FAILED\|ERROR" /tmp/test-output.log)
TOTAL=$((PASS + FAIL))

echo "=== Compatibility Report ==="
echo "Passed: $PASS / $TOTAL ($(( PASS * 100 / TOTAL ))%)"
echo "Failed: $FAIL / $TOTAL"
```

## Layer 5: Differential / shadow testing

Run both implementations with identical inputs and compare outputs.

### For CLI tools

```rust
use std::process::Command;

#[cfg(test)]
mod differential {
    use super::*;

    fn run_both(args: &[&str], stdin: &str) -> (Output, Output) {
        let original = Command::new("original-tool")
            .args(args)
            .stdin(std::process::Stdio::piped())
            .stdout(std::process::Stdio::piped())
            .stderr(std::process::Stdio::piped())
            .spawn().unwrap();
        // write stdin...

        let rust = Command::new("rust-tool")
            .args(args)
            .stdin(std::process::Stdio::piped())
            .stdout(std::process::Stdio::piped())
            .stderr(std::process::Stdio::piped())
            .spawn().unwrap();
        // write stdin...

        (original.wait_with_output().unwrap(), rust.wait_with_output().unwrap())
    }

    #[test]
    fn diff_test_basic_usage() {
        let (orig, rust) = run_both(&["--flag", "input.txt"], "");
        assert_eq!(orig.status.code(), rust.status.code(), "Exit codes differ");
        assert_eq!(orig.stdout, rust.stdout, "Stdout differs");
        assert_eq!(orig.stderr, rust.stderr, "Stderr differs");
    }
}
```

### For services (shadow traffic)

Deploy both implementations. Mirror production traffic to the Rust version. Compare responses.

```
                    ┌──────────────┐
    Request ───────►│   Router     │───────► Original (serves response)
                    │              │
                    │              │───────► Rust (shadow, response compared but not served)
                    └──────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Comparator  │ → Log divergences
                    └──────────────┘
```

Approaches:
- **Istio/Envoy traffic mirroring**: Mirror requests at the service mesh level
- **Custom proxy**: Forward requests to both, compare responses
- **Thoughtworks "merging utility"**: Proxy uses original's response but logs comparison

Source: https://microsoft.github.io/code-with-engineering-playbook/automated-testing/shadow-testing/

## Layer 6: Fuzz testing

```rust
// fuzz/fuzz_targets/parse_input.rs
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    // Fuzz the parser with random bytes
    if let Ok(input) = std::str::from_utf8(data) {
        let _ = my_crate::parse(input);
        // If this doesn't panic, the parser handles the input safely
    }
});
```

```bash
# Setup
cargo install cargo-fuzz

# Create fuzz target
cargo fuzz init
cargo fuzz add parse_input

# Run fuzzing (runs indefinitely — Ctrl+C to stop)
cargo fuzz run parse_input

# Run for a specific duration
cargo fuzz run parse_input -- -max_total_time=3600  # 1 hour
```

### Differential fuzzing (for rewrites)

```rust
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    if let Ok(input) = std::str::from_utf8(data) {
        let original_result = original_crate::process(input);
        let rust_result = rust_crate::process(input);

        // Both should produce the same result OR the same error class
        match (original_result, rust_result) {
            (Ok(a), Ok(b)) => assert_eq!(a, b, "Output divergence on: {:?}", input),
            (Err(_), Err(_)) => {} // Both error — acceptable
            (Ok(a), Err(e)) => panic!("Rust errors but original succeeds: {:?} vs {:?}", a, e),
            (Err(e), Ok(b)) => panic!("Original errors but Rust succeeds: {:?} vs {:?}", e, b),
        }
    }
});
```

## Layer 7: Formal verification (for critical code)

### Kani for bounded model checking

```rust
#[cfg(kani)]
mod proofs {
    use super::*;

    #[kani::proof]
    fn parse_never_panics() {
        let data: [u8; 16] = kani::any();
        let _ = parse(&data); // Kani verifies this for ALL possible 16-byte inputs
    }

    #[kani::proof]
    #[kani::unwind(10)]
    fn encode_decode_roundtrip() {
        let value: u64 = kani::any();
        let encoded = encode(value);
        let decoded = decode(&encoded).unwrap();
        assert_eq!(value, decoded);
    }
}
```

### Design-by-Contract with the contracts crate

```rust
use contracts::*;

#[requires(denominator != 0, "division by zero")]
#[ensures(ret * denominator <= numerator, "quotient too large")]
fn integer_divide(numerator: u64, denominator: u64) -> u64 {
    numerator / denominator
}
```

## Layer 8: BDD / executable specifications with cucumber-rs

```gherkin
# features/config_parsing.feature
Feature: Configuration file parsing

  Scenario: Parse a valid configuration file
    Given a config file with host "localhost" and port 8080
    When I parse the configuration
    Then the host should be "localhost"
    And the port should be 8080

  Scenario: Reject invalid port number
    Given a config file with host "localhost" and port 99999
    When I parse the configuration
    Then parsing should fail with "invalid port"
```

```rust
// tests/cucumber.rs
use cucumber::{given, when, then, World};

#[derive(Debug, Default, World)]
struct ConfigWorld {
    config_content: String,
    parse_result: Option<Result<Config, ParseError>>,
}

#[given(expr = "a config file with host {string} and port {int}")]
fn config_with(world: &mut ConfigWorld, host: String, port: i32) {
    world.config_content = format!("host = \"{host}\"\nport = {port}\n");
}

#[when("I parse the configuration")]
fn parse_config(world: &mut ConfigWorld) {
    world.parse_result = Some(Config::parse(&world.config_content));
}

#[then(expr = "the host should be {string}")]
fn check_host(world: &mut ConfigWorld, expected: String) {
    let config = world.parse_result.as_ref().unwrap().as_ref().unwrap();
    assert_eq!(config.host, expected);
}
```

## Code coverage tracking

```bash
# Install
cargo install cargo-llvm-cov

# Run tests with coverage
cargo llvm-cov --html --output-dir coverage/

# Run with branch coverage
cargo llvm-cov --branch --html --output-dir coverage/

# Get summary in terminal
cargo llvm-cov --summary-only

# Fail CI if coverage drops below threshold
cargo llvm-cov --fail-under-lines 80
```

## Quality gate summary for rewrite validation

| Gate | Tool | Threshold | When |
|------|------|-----------|------|
| All characterization tests pass | `cargo test` | 100% | Phase 4+ |
| Original test suite compatibility | Custom harness | ≥95% | Phase 5 |
| Differential testing | proptest + custom | 0 unexplained divergences | Phase 5 |
| Fuzz testing | cargo-fuzz | ≥1 hour, 0 crashes | Phase 5 |
| Code coverage | cargo-llvm-cov | ≥80% line coverage | Phase 4+ |
| Clippy lints | cargo clippy | 0 warnings (pedantic) | Phase 4+ |
| Dependency audit | cargo audit | 0 vulnerabilities | Phase 6 |
| Unsafe audit | cargo geiger + Miri | All documented, Miri clean | Phase 6 |
| Formatting | cargo fmt | No diffs | Always |
