# Phase detail

The six phases of a rewrite, with the work and the quality gate for each. Read
the section for the phase you're in. Steps marked **GitLab service** apply when
the rewrite is a network service that runs at GitLab; the full guidance is in
[gitlab-labkit-rs.md](gitlab-labkit-rs.md) and [gitlab-bench.md](gitlab-bench.md).

## Contents

- [Phase 1: Codebase analysis](#phase-1-codebase-analysis)
- [Phase 2: Migration architecture](#phase-2-migration-architecture)
- [Phase 3: Test infrastructure](#phase-3-test-infrastructure)
- [Phase 4: Idiomatic implementation](#phase-4-idiomatic-implementation)
- [Phase 5: Differential testing](#phase-5-differential-testing)
- [Phase 6: Security hardening](#phase-6-security-hardening)
- [Agent rules](#agent-rules)
- [Final checklist](#final-checklist)
- [Decision tree](#decision-tree)

## Phase 1: Codebase analysis

**Goal:** understand what the code does, not how.

```
Analysis checklist:
- [ ] Map architecture (C4: Context, Containers, Components)
- [ ] Generate call graphs and dependency maps
- [ ] Mine VCS history for hotspots and change frequency
- [ ] Run the existing test suite and measure coverage
- [ ] Write characterization tests for undocumented behavior
- [ ] Document every external interface (APIs, CLI, file formats)
- [ ] GitLab service: inventory the observability contract (see below)
```

Run `scripts/analyze-codebase.sh /path/to/source`. It detects the language,
reports structure and hotspots, and writes `observability-inventory.txt` next
to the other outputs.

**GitLab service:** the log field names, metric names and labels, correlation
and trace headers, health endpoints, and config keys of the original are an
interface other systems depend on (dashboards, alerts, log queries, load
balancer probes). Record each one in the behavioral spec, and mark which ones
labkit-rs will now emit by itself and which are service-specific and must be
kept. See [the inventory table](gitlab-labkit-rs.md#map-the-original-onto-labkit).

**Output needed:** a behavioral spec covering every public interface, edge case,
and side effect; C4 Container and Component diagrams; a user story per major
behavioral contract. Convert the spec to stories with `story-creator`, Gherkin
acceptance criteria included, and run `story-reviewer` on each before moving on.
A story that fails test derivability means the spec was too vague and needs more
characterization work. Save stories to `docs/stories/`.

Techniques: [codebase-analysis.md](codebase-analysis.md) and
[analysis-patterns.md](analysis-patterns.md).

**Quality gate:** written behavioral spec; existing test suite passes;
characterization tests cover critical paths; architecture diagrams; reviewed
stories for each public interface.

## Phase 2: Migration architecture

**Goal:** choose incremental or full rewrite and define the migration path.

Default to incremental. The evidence is in
[migration-architectures.md](migration-architectures.md).

```
Score factors (+1 to +3): infrastructure costs, security incidents,
  performance needs, team Rust capacity
Score risks (-1 to -3): codebase size, internal dependencies, timeline
  pressure

Total >= +8: strong case for rewrite
Total +3 to +7: start with a pilot
Total 0 to +2: targeted Rust modules only
Negative: don't rewrite
```

Incremental strategy: strangler fig (facade, build new, redirect, retire old);
start with leaf modules, parsers, hot paths, and security-critical code; pick an
FFI strategy (bindgen, CXX, PyO3) for the boundaries.

**GitLab service:** decide here whether the rewrite becomes a
[bench](gitlab-bench.md) assembly or stays a standalone binary on labkit-rs, and
list the labkit-rs features it needs. Both decisions go in the migration plan.
A strangler facade in front of a labkit-instrumented Rust service must forward
`X-Request-ID` so one correlation ID spans old and new.

**Quality gate:** a migration plan that states (a) incremental or full, with
justification, (b) the ordered component list, (c) the FFI strategy for
boundaries, (d) the dependency budget, (e) the rollback plan, and, for GitLab
services, (f) the bench-or-not decision and the labkit-rs feature list.

## Phase 3: Test infrastructure

**Goal:** set up testing before writing implementation code.

Run `scripts/generate-test-harness.sh my_project /path/to/original/binary` to
scaffold the layout, lints, and test dependencies. Crate names are snake_case
(`my_project`, not `my-project`): the script refuses anything else before it
creates a file, and `validate-rust-rewrite.sh` fails any `[package]` name that
isn't. One spelling keeps the package name, the library crate name, and
`CARGO_BIN_EXE_<name>` identical.

Test layers:

1. **Characterization**: capture existing behavior (Feathers method)
2. **Compatibility**: run both binaries with identical inputs
3. **Differential**: property-based testing with random inputs
4. **Snapshot**: output comparison with `insta`
5. **Fuzz**: edge-case discovery with `cargo-fuzz`
6. **Benchmarks**: performance comparison with `criterion`

A characterization test documents what exists, not what you want:

```rust
// tests/characterization.rs
#[test]
fn parse_empty_returns_empty_list() {
    assert_eq!(parse(""), Ok(vec![]));
}
```

CI runs, at minimum: `cargo test --all-features`,
`cargo clippy -- -W clippy::all -W clippy::pedantic`, `cargo fmt --check`,
`cargo audit`, and `cargo llvm-cov --fail-under-lines 80`.

**GitLab service:** add a test that asserts the observability contract from
Phase 1: the access log carries the expected fields, the correlation ID round
trips through `X-Request-ID`, and `/-/liveness`, `/-/readiness`, and
`/-/metrics` answer on the probe port. See
[testing the contract](gitlab-labkit-rs.md#test-the-observability-contract).

Patterns: [test-validation-strategies.md](test-validation-strategies.md).

**Quality gate:** `cargo test` runs; every ported characterization test exists
(`#[ignore]` with a reason while failing); CI has clippy, fmt, audit, and
coverage; Miri is configured if `unsafe` is planned.

## Phase 4: Idiomatic implementation

**Goal:** implement with Rust idioms, not line-by-line translation.

- Use `Result<T, E>` and `?` for errors, not panics.
- Use ownership and borrowing instead of GC or manual memory.
- Use enums and pattern matching for closed hierarchies.
- Use traits and generics for extension points.
- Prefer iterators and slices over index loops.
- Apply `#![forbid(unsafe_code)]`; allow `unsafe` only where essential.

Where to look:

- Source-language mappings: [language-pattern-mappings.md](language-pattern-mappings.md)
- Rust design patterns: [idiomatic-rust-patterns.md](idiomatic-rust-patterns.md)
- Project shapes (CLI, daemon, network service): [domain-patterns.md](domain-patterns.md)
- Async or networked programs: [tokio-async-migration.md](tokio-async-migration.md)
- TUI programs: [tui-ratatui-migration.md](tui-ratatui-migration.md)
- GUI desktop programs: [gui-desktop-migration.md](gui-desktop-migration.md)

Python duck typing becomes a trait:

```python
def process(item):
    return item.transform()
```

```rust
trait Transformable {
    fn transform(&self) -> Output;
}

fn process<T: Transformable>(item: &T) -> Output {
    item.transform()
}
```

Workflow:

1. Start with data structures; use Rust types, not transliterated ones.
2. Convert error handling to `Result`.
3. Replace unsafe patterns with ownership.
4. Use async I/O for daemons and services (tokio).
5. Make the characterization tests pass, then add Rust-specific tests.
6. Run clippy with pedantic lints.

**GitLab service:** wire observability through labkit-rs from the first
commit: `Builder::init()` in `main`, the labkit tower layers on the router,
`labkit::fields` constants for log fields, OpenTelemetry meters for metrics.
Don't port the original's logger, metrics client, or health handler. Details:
[gitlab-labkit-rs.md](gitlab-labkit-rs.md). Run
`scripts/check-labkit-usage.sh` before calling the phase done.

**Quality gate:** all characterization tests pass; zero clippy warnings
(pedantic); no `unsafe` without a documented safety invariant; coverage at or
above 80%; Miri passes if `unsafe` is used; for GitLab services,
`check-labkit-usage.sh` reports no findings.

## Phase 5: Differential testing

**Goal:** prove the Rust implementation behaves like the original.

1. **Side by side.** CLI tools: run both with identical inputs and diff the
   output. Services: shadow traffic, mirroring requests and comparing
   responses. Libraries: a harness that calls both implementations.
2. **Property-based differential:**

   ```rust
   use proptest::prelude::*;

   proptest! {
       #[test]
       fn differential_test(input in "\\PC{0,100}") {
           let original = original_impl::process(&input);
           let rust = rust_impl::process(&input);
           prop_assert_eq!(original, rust);
       }
   }
   ```

3. Run the original test suite against the Rust implementation.
4. Fuzz with `cargo-fuzz`.
5. Snapshot with `insta` for output regressions.
6. Track parity quantitatively: X of Y tests passing, % API coverage.

**GitLab service:** compare the wire contract too. Shadow traffic should show
the same status codes and bodies, and the same correlation ID in both access
logs. Expected differences are the ones you listed in Phase 1 (labkit-rs
replaces the original's log layout and metric names); record each as a
documented divergence with a dashboard or alert migration owner.

See [test-validation-strategies.md](test-validation-strategies.md).

**Quality gate:** at least 95% of the original suite passes (divergences
documented); zero unexplained differential differences; fuzzing ran at least an
hour without crashes; **mutation testing on the port
(`cargo mutants --in-diff <(git diff origin/main)`) shows zero surviving
mutants**. A differential test that survives mutation isn't constraining the
port; it's memorizing input and output pairs. The `bugfix` skill's
`references/reproducer-and-mutation.md` has the runbook.

## Phase 6: Security hardening

**Goal:** meet or exceed the original's security posture.

```
Security validation:
- [ ] cargo audit: zero known vulnerabilities
- [ ] cargo deny check: license and source policy passes
- [ ] cargo geiger: unsafe in the dependency tree is documented
- [ ] All unsafe blocks have // SAFETY: comments
- [ ] Dependencies minimized and justified
- [ ] Compiler flags: overflow-checks, debug-assertions
- [ ] ANSSI Secure Rust Guidelines addressed
- [ ] GitLab service: labkit-rs security settings reviewed (below)
```

```bash
cargo audit
cargo deny check
cargo geiger --all-features
cargo clippy -- -W clippy::unwrap_used -W clippy::expect_used
```

**GitLab service:** labkit-rs is a git dependency, so `cargo deny` needs its
source allowed and the dependency pinned to a tag or commit. Review probe-port
TLS and the crypto provider (FIPS builds), and confirm no log field carries
secrets or request bodies. See
[security settings](gitlab-labkit-rs.md#security-settings).

Guidance: [security-patterns.md](security-patterns.md).

**Quality gate:** `cargo audit` clean; every `unsafe` documented; dependencies
minimized; ANSSI checklist addressed; third-party audit if security-critical.

## Agent rules

1. Read the relevant `references/` files before starting a phase.
2. Never skip characterization testing; the existing implementation is the spec.
3. Never translate line by line; idiomatic Rust is the goal.
4. Prefer incremental migration unless there's a documented case for a full rewrite.
5. Set up tests before implementation.
6. Run clippy with pedantic lints to catch non-idiomatic patterns.
7. Use `#![forbid(unsafe_code)]` unless justified.
8. Track feature parity with pass and fail counts.
9. Document every intentional behavioral divergence with its rationale.
10. Run the original project's test suite against the Rust implementation.
11. For GitLab services, use labkit-rs for logging, metrics, tracing, correlation, health, lifecycle, and config. Don't rebuild them.

## Final checklist

```
- [ ] All original functionality replicated
- [ ] Test coverage at or above the original's (or 80%)
- [ ] Zero clippy warnings (-W clippy::pedantic)
- [ ] cargo audit clean
- [ ] cargo mutants: zero surviving mutants on the ported modules
- [ ] cargo crap: no module scores above 30 (Savoia and Evans 2007 formula)
- [ ] Performance within 20% of the original, or better
- [ ] README and changelog written
- [ ] CI configured
- [ ] Integration tests for every public API
- [ ] GitLab service: scripts/check-labkit-usage.sh clean, observability
      contract tests green, divergences and dashboard migrations recorded
```

```bash
bash scripts/validate-rust-rewrite.sh
cargo llvm-cov --fail-under-lines 80
RUSTFLAGS="-Z sanitizer=address" cargo +nightly test
```

## Decision tree

```
User requests a Rust rewrite
├─ Source code available?
│  ├─ yes: Phase 1 (analysis)
│  └─ no: ask for source or docs
├─ Existing test suite?
│  ├─ yes: use as baseline, add characterization tests
│  └─ no: write extensive characterization tests
├─ Small enough for a full rewrite? (<10K LOC, well understood)
│  ├─ yes: full rewrite is acceptable if the user agrees
│  └─ no: incremental migration (strangler fig)
├─ Security-critical? (auth, crypto, untrusted input, runs as root)
│  ├─ yes: apply Phase 6 strictly, minimize dependencies
│  └─ no: standard practices
├─ Side-by-side compatibility needed?
│  ├─ yes: FFI bridging required
│  └─ no: replace after validation
└─ Network service running at GitLab?
   ├─ yes: labkit-rs; then decide on bench (gitlab-bench.md)
   └─ no: skip the GitLab references
```
