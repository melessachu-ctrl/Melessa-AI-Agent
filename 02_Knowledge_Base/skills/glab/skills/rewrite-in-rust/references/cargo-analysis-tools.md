# Cargo Analysis Tools for Rust Migration

Tools organized by migration phase: analysis, implementation, validation.

## Phase 1: Source codebase analysis

Before writing any Rust, understand what you're migrating.

### Source language tools

Depending on the source language, run these to understand complexity and dependencies:

| Source language | Metrics tool | Dependency tool |
|----------------|-------------|-----------------|
| C | cppcheck + CMetrics | include-gardener |
| C++ | cppcheck + CScout | include-gardener |
| Python | radon + vulture | pipdeptree |
| Go | gocyclo + deadcode | go mod graph |
| JavaScript | eslint + madge | npm ls |

## Phase 2: Implementation tooling

### cargo clippy (pedantic configuration)

Run clippy with pedantic lints during migration to catch non-idiomatic patterns early.

```bash
# Pedantic pass — catches non-idiomatic Rust
cargo clippy -- -W clippy::pedantic

# Recommended clippy.toml for migration projects
```

```toml
# clippy.toml
warn = ["clippy::pedantic"]
deny = [
    "clippy::unwrap_used",
    "clippy::expect_used",
    "clippy::panic",
    "clippy::todo",
    "clippy::dbg_macro",
    "clippy::undocumented_unsafe_blocks"
]
```

### cargo-expand

Shows macro expansion results. Essential when migrating code that uses complex macros.

```bash
cargo install cargo-expand
cargo expand module::name
```

### rust-analyzer

The language server provides rename, inline, extract-function, and other refactoring operations that speed up migration work.

## Phase 3: Testing and validation

### cargo-fuzz

Coverage-guided fuzzing. Critical for validating that the Rust implementation handles the same edge cases as the original.

```bash
cargo install cargo-fuzz
cargo fuzz init
cargo fuzz add my_target

# Run fuzzer
cargo fuzz run my_target -- -max_total_time=300

# With AddressSanitizer (default)
cargo fuzz run my_target
```

**When to use:** after implementing parsers, serializers, or anything handling untrusted input. Run against the same corpus you'd test the original code with.

### proptest

Property-based testing. Define properties the Rust code must satisfy, and proptest generates random inputs to verify them.

```toml
[dev-dependencies]
proptest = "1.4"
```

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn roundtrip_preserves_data(data in any::<Vec<u8>>()) {
        let encoded = encode(&data);
        let decoded = decode(&encoded).unwrap();
        prop_assert_eq!(data, decoded);
    }
}
```

### insta (snapshot testing)

Captures output snapshots for regression testing. Good for verifying that migrated code produces identical output.

```bash
cargo install cargo-insta

# Run tests and review new/changed snapshots
cargo insta test
cargo insta review
```

### criterion (benchmarking)

Statistically rigorous benchmarks. Compare Rust implementation performance against the original.

```toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }

[[bench]]
name = "my_benchmark"
harness = false
```

```bash
# Run benchmarks
cargo bench

# Compare against baseline
cargo bench -- --save-baseline original
# ... make changes ...
cargo bench -- --baseline original
```

### cargo-llvm-cov

Source-based code coverage using LLVM instrumentation.

```bash
cargo install cargo-llvm-cov

# Generate coverage report
cargo llvm-cov --html

# Coverage with specific test filtering
cargo llvm-cov --html -- --test-threads=1

# Minimum coverage threshold
cargo llvm-cov --fail-under-lines 80
```

### cargo-mutants

```bash
cargo install cargo-mutants
cargo mutants --in-diff <(git diff origin/main)
```

Mutates the ported code and reruns the tests. A surviving mutant means no test
constrains that behavior, so a passing differential suite is not proof of parity.
Aim for zero survivors on ported modules.

### cargo-crap

```bash
cargo llvm-cov --lcov --output-path lcov.info
cargo crap --lcov lcov.info
```

CRAP score (complexity weighted by missing coverage) finds complex Rust with thin
tests. Treat a module above 30 as a refactor or test-writing target.

## Phase 4: Security hardening

### cargo-audit

```bash
cargo install cargo-audit
cargo audit
```

Run before declaring migration complete. Ensure no dependencies have known vulnerabilities.

### cargo-deny

```bash
cargo install cargo-deny
cargo deny init
cargo deny check
```

Check licenses, advisories, bans, and sources. Particularly relevant for migrations where the original project had specific licensing requirements.

### cargo-geiger

```bash
cargo install cargo-geiger
cargo geiger
```

Measure the unsafe surface area. For a migration from C to safe Rust, the geiger report should show minimal unsafe code outside of FFI boundaries.

### cargo-udeps

```bash
cargo +nightly install cargo-udeps
cargo +nightly udeps
```

Find unused dependencies. Migration projects tend to accumulate trial dependencies — clean them up.

### cargo-bloat

```bash
cargo install cargo-bloat
cargo bloat --release --crates
```

Identify which crates contribute most to binary size. Useful for comparing the Rust binary size against the original.

## Tool selection by migration phase

| Phase | Tools |
|-------|-------|
| Analysis | Source-language metrics + cppcheck/radon/gocyclo |
| Scaffolding | cargo clippy (pedantic) + cargo-expand |
| Implementation | clippy + insta + proptest |
| Validation | cargo-fuzz + cargo-llvm-cov + criterion + cargo-mutants + cargo-crap |
| Security | cargo-audit + cargo-deny + cargo-geiger |
| Cleanup | cargo-udeps + cargo-bloat |
