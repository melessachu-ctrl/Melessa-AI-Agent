---
name: rewrite-in-rust
description: "Rewrites existing codebases (C, C++, Go, Python, Ruby, JavaScript, TypeScript, Java) into idiomatic, secure Rust through analysis, characterization tests, incremental migration, differential testing, and security hardening. For rewritten GitLab services it wires in labkit-rs for logging, metrics, tracing, correlation IDs, health probes, and lifecycle, and uses bench to bootstrap, test, and deploy. Use when asked to rewrite, port, migrate, or convert a project to Rust (RIIR), to replace a service with Rust, or to add GitLab-standard observability to a Rust rewrite. Not for adding Rust FFI to existing C (rust-unsafe-ffi-review) or reviewing Rust that already exists (rust-idioms)."
version: 2.2.0
license: MIT
category: Development Workflow
compatibility: opencode
metadata:
  audience: developers
  workflow: rust-migration
---

# Rewrite in Rust

Guides the full lifecycle of rewriting software in idiomatic, secure Rust, based
on production migrations (Cloudflare Pingora, Discord, sudo-rs, uutils, Fish 4.0).
Rewritten GitLab services also adopt [labkit-rs](https://gitlab.com/gitlab-org/rust/labkit-rs)
for observability and, where they fit, [bench](https://gitlab.com/gitlab-org/lab-bench/bench)
to bootstrap, test, and deploy.

## When to use

- A request to rewrite, port, migrate, or convert code to Rust, or "RIIR".
- Modernizing legacy code for memory safety, type safety, or performance.
- Replacing an existing tool or service with a Rust implementation.
- A Rust rewrite of a GitLab service: observability, probes, config, and
  deployment follow the GitLab standard, not the original's.

## Gotchas

- The existing implementation is the spec: write characterization tests before
  any Rust, and default to incremental migration (strangler fig).
- Don't transliterate; line-by-line ports carry the source language's habits
  (error codes, manual buffers, blocking I/O) into Rust.
- A passing differential test proves little if mutants survive; run
  `cargo mutants` on the ported modules.
- **GitLab services:** don't port the original's logger, metrics client, request
  ID handling, or health endpoint. labkit-rs provides them with the same wire
  names as Go LabKit, and dashboards depend on that.
- labkit-rs isn't on crates.io (pin a git tag), and bench is early and may not
  express every service. Check fit before committing to either.
- Don't claim a rewrite is faster or safer without benchmarks or audit evidence;
  apply `natural-writing-style` to specs and docs.
- The original's metric names, log layout, and health paths are an interface.
  Inventory them in Phase 1 and migrate each dashboard and alert that uses them.

## The six phases

Each phase ends in a quality gate; don't start the next without it. Detail,
checklists, and gates: [references/phases.md](references/phases.md).

| Phase | Output | Gate (short form) |
|---|---|---|
| 1. Codebase analysis | Behavioral spec, diagrams, reviewed user stories, observability inventory | Spec exists; existing suite passes; critical paths characterized |
| 2. Migration architecture | Incremental plan, component order, FFI strategy, rollback; bench-or-not decision | Plan covers all of those |
| 3. Test infrastructure | Characterization, compatibility, differential, snapshot, fuzz tests; CI | `cargo test` runs; ported cases present |
| 4. Idiomatic implementation | Rust that passes the characterization tests | Clippy pedantic clean; no undocumented `unsafe`; coverage at least 80% |
| 5. Differential testing | Parity numbers, documented divergences | 95% of the original suite; zero unexplained diffs; zero surviving mutants |
| 6. Security hardening | Audit, deny, geiger results | `cargo audit` clean; `unsafe` documented |

Turn the Phase 1 spec into stories with `story-creator` and `story-reviewer`.
Pair Phase 4 with `rust-idioms`; use `rust-unsafe-ffi-review` if `unsafe` remains.

## GitLab services: labkit-rs and bench

For a network service that runs at GitLab, add these to the phases:

1. **Phase 1:** inventory log fields, metrics, correlation headers, probes, and
   config keys; decide what labkit-rs replaces.
2. **Phase 2:** bench or standalone labkit-rs? Ask the user; bench targets new
   modular services and has limits ([gitlab-bench.md](references/gitlab-bench.md)).
3. **Phase 3:** write observability-contract tests (access-log fields,
   correlation round trip, probes).
4. **Phase 4:** wire `labkit::Builder`, the tower layers, `labkit::fields`, and
   OpenTelemetry meters ([gitlab-labkit-rs.md](references/gitlab-labkit-rs.md));
   run `scripts/check-labkit-usage.sh`.
5. **Phases 5 and 6:** compare wire behavior under shadow traffic; review probe
   TLS, crypto provider, and log hygiene; pin and audit the git dependency.

CLIs, TUIs, GUIs, and libraries skip this section.

## Scripts

Run them; don't read them into context. All need bash and standard Unix tools.

| Script | Use |
|---|---|
| `scripts/analyze-codebase.sh <src> [lang]` | Language, LOC, hotspots, tests, public interfaces, observability inventory |
| `scripts/generate-test-harness.sh [--no-ci] <name> [orig-bin]` | Test layout, lints, GitLab CI; needs `cargo`; `<name>` must be snake_case |
| `scripts/validate-rust-rewrite.sh` | Final suite: tests, fmt, clippy, audit, geiger, labkit check (`RIR_LABKIT=auto\|chassis-owned\|off`), and snake_case crate names |
| `scripts/check-labkit-usage.sh [--chassis-owned] [dir]` | Flags missing or competing observability wiring; exit 1 on findings |

## References

- Phase detail, gates, agent rules, decision tree: [phases.md](references/phases.md)
- labkit-rs wiring, gotchas, tests, security: [gitlab-labkit-rs.md](references/gitlab-labkit-rs.md)
- bench fit, workflow, handler contract, deploy: [gitlab-bench.md](references/gitlab-bench.md)
- Project shapes and pitfalls: [domain-patterns.md](references/domain-patterns.md)
- Strategy: [reference-projects.md](references/reference-projects.md), [migration-architectures.md](references/migration-architectures.md)
- Analysis: [codebase-analysis.md](references/codebase-analysis.md), [analysis-patterns.md](references/analysis-patterns.md)
- Translation: [language-pattern-mappings.md](references/language-pattern-mappings.md), [idiomatic-rust-patterns.md](references/idiomatic-rust-patterns.md)
- Testing, security, tools: [test-validation-strategies.md](references/test-validation-strategies.md), [security-patterns.md](references/security-patterns.md), [cargo-analysis-tools.md](references/cargo-analysis-tools.md)
- Async, TUI, GUI: [tokio-async-migration.md](references/tokio-async-migration.md), [tui-ratatui-migration.md](references/tui-ratatui-migration.md), [gui-desktop-migration.md](references/gui-desktop-migration.md)

## Contributing Improvements

This skill is maintained in [`gitlab-org/ai/skills`](https://gitlab.com/gitlab-org/ai/skills).
If any guidance here is **inaccurate or outdated** (a labkit-rs or bench command
or limit that changed, a wrong flag), confirm with the user and open an MR
there with the fix. Keep changes focused: one fix per MR.
