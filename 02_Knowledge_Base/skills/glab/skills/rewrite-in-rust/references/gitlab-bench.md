# Bench for bootstrapping, testing, and deploying rewrites

[LabBench](https://gitlab.com/gitlab-org/lab-bench/bench) (`bench`) is GitLab's
composition layer for new modular services. A language-neutral spec
(`bench.yaml`) describes what the service serves; `bench` scaffolds the repo,
generates a chassis around the developer's handler code (labkit-rs wiring,
probe port, graceful shutdown, auth middleware), builds an OCI image, and
generates the Fairway manifest and Caproni fragment that Runway and local
Kubernetes development consume. The developer writes business logic only.

Bench is early and moving. Treat this page as the decision guide and workflow
map; confirm commands and limits against `bench --help`, the repo's
[docs](https://gitlab.com/gitlab-org/lab-bench/bench/-/tree/main/docs), and
[AGENTS.md](https://gitlab.com/gitlab-org/lab-bench/bench/-/blob/main/AGENTS.md)
before relying on them.

## Contents

- [Decide whether the rewrite fits bench](#decide-whether-the-rewrite-fits-bench)
- [Map the rewrite onto the spec](#map-the-rewrite-onto-the-spec)
- [Workflow](#workflow)
- [Handler contract](#handler-contract)
- [What bench generates](#what-bench-generates)
- [Testing and CI](#testing-and-ci)
- [Deploying](#deploying)
- [When bench is not the answer](#when-bench-is-not-the-answer)

## Decide whether the rewrite fits bench

Bench's stated target is new modular services (the docs name GKG, Artifact
Registry, and Secret Manager). Forcing existing services onto it is an explicit
non-goal: "migrate, then mandate". So ask the user before choosing bench for a
rewrite; don't assume it.

Check each of these against current bench behavior before committing to it.
Any "no" means labkit-rs directly, not bench:

| Question | Why it matters |
|---|---|
| Is it a long-running network service, deployed as an OCI image through Runway? | Bench produces images and Fairway manifests, nothing else. |
| Is the inbound surface supported for Rust? | HTTP is wired. `bench build` warns that gRPC and NATS endpoints it can't wire are absent from the binary; check the warning list and the docs for current status. |
| Can the handlers be expressed as `Handler` methods that take a JSON request and return a JSON response? | The generated adapter doesn't pass headers, path parameters, or query parameters to the handler, and can't return a non-JSON body (tracked in the bench repo). Check the [adapter contract](https://gitlab.com/gitlab-org/lab-bench/bench/-/blob/main/docs/design/http-adapter-contract.md). |
| Can the business logic live in a handler crate with the dependencies bench allows? | `bench build` copies each handler crate into `.bench/workspace/<assembly>/` and overwrites the copy's `Cargo.toml` with a manifest that depends on `serde` only (when last checked). The `Cargo.toml` in `src/<crate>` is ignored, so a handler that needs other crates fails to compile until that changes; check `prepare_crate` in `cli/src/build/rust.rs` and the docs. |
| Are its backends ones the platform provides? | Postgres backends become the `infrastructure:` block of the Fairway manifest (HTTP and gRPC backends produce no entry); connections are read from the platform at runtime, not named in the spec. |
| Does it need more than one listener per assembly? | An assembly takes at most one published listener, and the probe port (9090 by default) is reserved; a binary that serves two ports becomes two assemblies. |

If it fits, use bench for the whole lifecycle. If only some fit, split: bench
for the compatible domains, a standalone labkit-rs binary for the rest.

## Map the rewrite onto the spec

| Bench term | Meaning | In a rewrite |
|---|---|---|
| bench | One repo, one `bench.yaml` | The Rust repo for the rewritten service |
| assembly | One OCI image, one process, one runtime | One per deployable binary; set `RUNTIME_RUST` |
| domain | Endpoints plus handler plus backends | A cohesive group of the original's routes |
| handler | Your code, a Rust crate with a `Handler` | The ported business logic |
| service | The deployment target in the Release Platform | Created by `bench register` |

Reserve "service" for the deployed unit and "domain" for the spec entity;
bench's docs and review comments enforce that vocabulary. A bench holds one
runtime, so a rewrite that keeps some components in another language needs its
own bench for those.

The Phase 1 inventory feeds the spec directly: routes and verbs become HTTP
endpoints, ports become listeners (the probe port is reserved), and backends
become outbound declarations. The strangler plan from Phase 2 decides which
domains move first; each can be a separate assembly behind the existing facade.

## Workflow

Run `bench <command> --help` for exact flags. The sequence:

1. **Install** a release build (`mise use -g gitlab:gitlab-org/lab-bench/bench`).
   A `cargo install --git` build is a dev build that stops working when Cargo
   prunes its checkout; don't adopt bench on one. `scaffold` needs `copier` and
   `mise`, and runs `git init` in the new repo.
2. **`bench init <name> --group <canonical-group>`** creates `bench.yaml`.
   `--group` is the owning GitLab group path (it must start with
   `gitlab-org/`); `scaffold`, `build`, and `register` all read it.
3. **`bench assembly create --runtime rust <assembly>`** and
   **`bench domain create <assembly> <domain>`**; declare endpoints and handlers
   with `bench set` or by editing the file. The
   [examples](https://gitlab.com/gitlab-org/lab-bench/bench/-/tree/main/examples)
   show the shapes; `http-service` is the smallest.
4. **`bench check --strict`** validates the spec against the protobuf schema.
   Errors (missing required field, impossible value) fail it; warnings fail it
   under `--strict`. Run it in CI.
5. **`bench scaffold`** renders the repo (copier template, `.mise.toml`, CI
   config, CODEOWNERS), a handler skeleton per crate under `src/<crate>`, and a
   starter OpenAPI 3.1 document at `openapi/<assembly>-v1.yaml` that the team
   completes. Rerunning it adds what's missing and never overwrites existing files.
6. **Write the handler** (below), test-first.
7. **`bench build`** compiles each assembly and generates its deployment files.
   Add `--release` to cross-compile for Linux and package the OCI image; that
   needs docker or podman, `zig`, and `cargo-zigbuild` (`mise install` provides
   the last two).
8. **`bench register --dry-run`**, then without `--dry-run`, opens the infra-mgmt
   MR that registers the service with the Release Platform. It needs a GitLab
   token in `GITLAB_TOKEN` or `GL_TOKEN`, and `--runtime` when the bench has
   zero or several assemblies.

The spec stays language-neutral and the same file serves every environment;
per-environment variation lives in the infrastructure contract, not the spec.

## Handler contract

A scaffolded Rust handler is a crate whose `lib.rs` exposes a `Handler` with the
method named by the endpoint's `func`. The adapter calls
`Handler::new().<func>(request)` and serializes the `Response` as JSON.

Name handler crates in snake_case (`catalog_api`, as the bench examples do). The crate's
basename is its identity, so two crates with the same basename collide, and one
spelling keeps the `bench.yaml` `crate` value, the package name, and `use` paths
the same.

- `Request` and `Response` derive serde traits. Derive `Default` on `Request` and
  add `#[serde(default)]`, so a `GET` with no body decodes like Go's zero value;
  skeletons from recent templates already do both.
- The adapter returns 415 for a non-JSON `Content-Type` on a non-empty body, 400
  for malformed JSON, and plain-text error bodies. These are bench's behavior,
  not yours; characterize the original's differences and record them as
  divergences.
- Keep handlers free of logging setup, metrics registries, and server code. Use
  `tracing` macros for logs and OpenTelemetry meters for custom metrics; the
  chassis has already initialized labkit-rs. See the
  [gotchas](gitlab-labkit-rs.md#gotchas) for field names and metrics.
- Unit-test the handler as a plain Rust type; no HTTP needed. Cover the
  Phase 1 characterization cases and the differential suite here.

## What bench generates

Don't rewrite or duplicate any of these in the handler crate.

| Generated | Where | Notes |
|---|---|---|
| Entrypoint and assembly crate | `.bench/workspace/<assembly>/` (gitignored) | `main.rs` calls `labkit::Builder`, mounts the routes, sets graceful shutdown |
| labkit-rs middleware | Same | Metrics, correlation, trace, and access-log layers, in the order [described here](gitlab-labkit-rs.md#wire-it-up) |
| Probe and metrics port | Same | `/-/liveness`, `/-/readiness`, `/-/metrics`; `PROBE_PORT` overrides the default |
| Bearer auth layer | `bench-chassis` crate | Checks that a bearer token is present, not that it is valid (the chassis logs a warning saying so); don't rely on it for authorization |
| Build metadata | `BuildInfo::from_env()` | Version, commit, and build date on every JSON log line |
| Fairway manifest | `.runway/<assembly>/fairway.yaml` (committed) | Image, command, listeners, metrics port, infrastructure |
| Caproni fragment | `caproni/fragments/caproni.<assembly>.yaml` (committed) | Deploys the rendered chart into the local Kubernetes environment |
| Helm chart | `chart/<assembly>` (gitignored) | Rendered by Fairway |
| OCI image | With `--release` | One Linux image per build, for the host architecture by default (`--platform` picks the other; build twice for both) |

Generated files carry a header and are marked `gitlab-generated` so MR diffs
collapse them. Don't hand-edit them; change the spec and rebuild.

## Testing and CI

The scaffolded repo's CI and `mise` tasks are the source of truth for gates. At
minimum a bench-based rewrite runs, per MR:

- `bench check --strict` on the spec.
- `cargo fmt --check`, `cargo clippy --all-targets --all-features -- -D warnings`,
  and `cargo nextest run` (bench uses nextest, not `cargo test`).
- `cargo deny check`; labkit-rs and `bench-chassis` are git dependencies.
- `buf lint` (and `buf breaking` when the app config schema changes) if the repo
  has an app config proto.
- Redocly lint on `openapi/<assembly>-v1.yaml`, which fails until each
  operation is filled in.
- `bench build` (release in the pipeline that produces the image) so a spec
  change that breaks generation fails before merge.
- The Phase 3 observability-contract tests from
  [gitlab-labkit-rs.md](gitlab-labkit-rs.md#test-the-observability-contract).

Run the differential suite from Phase 5 against the built binary or container,
with the original behind the same facade. Run `scripts/check-labkit-usage.sh`
against the assembly's handler crates as well: it should report nothing, since
the chassis owns the wiring.

Bench's own end-to-end scripts (`tests/integration-rust.sh`) show the full
slice: init, scaffold, build, start the binary, curl each route with and
without a token, and check that SIGTERM exits 0. Reproduce that shape for the
rewritten service.

## Deploying

Bench stops at artifacts. Runway delivers them: `bench register` creates the
Release Platform entry, the committed `.runway/<assembly>/fairway.yaml` declares
the image, listeners, and backends, and Fairway renders per-environment Helm
charts. Locally, Caproni deploys the fragment against the same chart.

Roll out a rewrite through the strangler facade: shift a percentage of traffic,
compare access logs and metrics by correlation ID, and keep the original
deployable for rollback until the Phase 5 gate passes in production traffic.
Dashboards and alerts that used the original's metric names need migrating to
the OpenTelemetry names; list them in the migration plan.

## When bench is not the answer

Use labkit-rs directly, wired as in
[gitlab-labkit-rs.md](gitlab-labkit-rs.md#wire-it-up), when the rewrite is:

- a service bench can't express yet (unsupported inbound protocol, handlers that
  need headers or path parameters, extra handler dependencies);
- an existing service that has not agreed to move onto bench;
- a daemon, worker, or job that isn't a request-serving assembly;
- a service that won't be delivered through Runway.

Use neither for CLIs, TUIs, GUIs, and libraries. If a gap in bench blocks an
otherwise good fit, file it in the bench repo and link it from the migration
plan rather than working around it in the generated tree.
