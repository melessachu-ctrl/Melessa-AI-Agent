# labkit-rs in rewritten services

When the rewrite is a network service that runs at GitLab (HTTP, gRPC, or a
message-driven worker), its observability comes from
[labkit-rs](https://gitlab.com/gitlab-org/rust/labkit-rs), not from the
original's logger, metrics client, or health handler, and not from hand-rolled
`tracing` setup. labkit-rs mirrors Go LabKit's wire semantics (header names,
gRPC metadata keys, log field names), so the Rust service shows up in the same
dashboards, log queries, and traces as every other GitLab service.

Not every rewrite needs it. A CLI, TUI, GUI, or library has no probe port,
access log, or correlation ID to emit. A library should depend on `tracing` only
and leave initialization to the binary.

Source of truth for APIs and features: the labkit-rs
[README](https://gitlab.com/gitlab-org/rust/labkit-rs/-/blob/main/README.md) and
rustdoc. Read them before writing wiring code; this page covers the decisions
and traps, not the full API.

## Contents

- [Gotchas](#gotchas)
- [Map the original onto labkit](#map-the-original-onto-labkit)
- [Choose features](#choose-features)
- [Wire it up](#wire-it-up)
- [Outbound calls and non-HTTP work](#outbound-calls-and-non-http-work)
- [Config, lifecycle, and the rest](#config-lifecycle-and-the-rest)
- [Test the observability contract](#test-the-observability-contract)
- [Security settings](#security-settings)
- [Verify and contribute upstream](#verify-and-contribute-upstream)

## Gotchas

- **Not on crates.io.** Depend on a git tag (or a commit `rev`), and pin it.
  List tags with
  `git ls-remote --tags https://gitlab.com/gitlab-org/rust/labkit-rs.git`.
  Check the workspace `rust-version` and edition in the repo's `Cargo.toml`
  against your toolchain; they are newer than the skill's baseline rustc.
  `cargo deny` needs the git source allowed.
- **One `Builder::init()` per process, and keep the `Guard`.** It installs the
  global subscriber, metrics, and the probe server. A second init fails with
  `ConfigAlreadySet`. Dropping the guard early flushes and stops telemetry, so
  bind it in `main` (`let _guard = ...`, never `let _ = ...`).
- **Never install your own subscriber.** No `tracing_subscriber::fmt().init()`,
  `env_logger`, or `println!` logging next to labkit; the second install fails
  or splits output into two formats. Use `tracing::info!` and friends.
- **Layer order matters.** In axum the last `.layer()` runs first. Copy the
  order from the [wiring example](#wire-it-up): metrics outermost, then
  correlation, then trace, then access log, with auth inside them so rejected
  requests are still logged and counted.
- **`propagate_correlation` defaults to `false`.** Without it, labkit ignores an
  upstream `X-Request-ID` and mints a new one. Enable it behind a trusted
  gateway or strangler facade so one ID spans old and new systems; don't
  enable it on an edge that faces untrusted clients.
- **Probe port is separate from the service port.** `/-/liveness`,
  `/-/readiness`, and (with `prometheus`) `/-/metrics` share one internal port.
  Whichever of the two binds second fails; `init()` returns `ProbeServerBind`
  if the probe port is already taken. Readiness starts green, so register real
  checks with `add_readiness_check`; they must not block.
- **The probe server starts inside `init()`.** A service that must answer
  liveness before init (long startup migration) can't use labkit's probe server
  for that window.
- **Metrics are OpenTelemetry meters.** Record them with
  `opentelemetry::global::meter(...)` using dotted names; the Prometheus
  exporter converts them (`jobs.processed` becomes `jobs_processed_total`).
  Don't add the `prometheus` crate or a second registry.
- **No bundled TLS crypto provider.** If you serve TLS, install the provider
  through `labkit::rustls::...`; certificates are read at startup and not
  reloaded, so restart on rotation. The `otel` exporter still links aws-lc, so
  check the lockfile if FIPS matters.
- **Field names are a contract.** The log keys in `labkit::fields` (for example
  `gl_user_id`, `error_message`, `duration_s`) match Go LabKit exactly. Spell
  them as the constant's value in `tracing` macros, and use the constants
  wherever a name is a runtime value (`Span::record`, policy predicates, tests),
  so a rename upstream is a compile error instead of a silent dashboard break.

## Map the original onto labkit

Fill this table in Phase 1 from `observability-inventory.txt` and the source.
"Replace" means delete the original's version; "keep" means it's a
service-specific signal labkit can't know about.

| Original concern | In the rewrite |
|---|---|
| Logger setup (logrus, zap, slog, Ruby `AppLogger`, Python `logging`) | Replace with `Builder::init()`; log with `tracing` macros |
| Request/access logging middleware | Replace with `AccessLogLayer` (or `GrpcAccessLogLayer`) |
| Request ID or trace header handling | Replace with `CorrelationLayer`; `X-Request-ID` on HTTP, `x-gitlab-correlation-id` on gRPC |
| Outbound request-ID forwarding | Replace with `http_client` / `grpc_client` layers |
| Prometheus client, StatsD, custom `/metrics` | Replace with OTel meters plus the `prometheus` feature; keep service-specific metrics, ported to OTel instruments |
| Health or ping endpoints | Replace with `/-/liveness`, `/-/readiness`; move dependency checks into `add_readiness_check` |
| Custom log fields | Use `labkit::fields` constants when one exists; otherwise keep, with names in `snake_case` |
| Version or build banner | Replace with `BuildInfo` (`version`, `commit`, `build-date` on every JSON line) |
| Config file loading | Use `labkit-config` for protobuf-schema configs |
| Signal handling, ordered startup and shutdown | Use the `app` feature, or axum graceful shutdown for a single listener |
| Per-user or per-namespace rate limits backed by Redis | Use the `ratelimit` feature so limits interoperate with other LabKit SDKs |
| Product analytics (Snowplow) | Use `labkit-events` |
| Error tracking (Sentry) | Not in labkit-rs; errors go to logs and the collector routes them |

Anything in the "replace" rows that you keep porting is a divergence from the
GitLab standard. Record it in the migration plan with a reason.

## Choose features

The `labkit` crate gates everything behind cargo features; enable only what the
service uses. The README table has the full list. Typical sets:

| Service | Features |
|---|---|
| HTTP API on axum | `http`, `prometheus` (implies `otel` and `health`) |
| gRPC on tonic | `grpc`, `prometheus` |
| Calls other services | add `http-client` and/or `grpc-client` |
| Needs readiness only | `health` |
| Pushes to an OTLP collector | `otel`, then `otel_grpc_endpoint(...)` on the builder |
| Redis-backed rate limits | `ratelimit`, plus `ratelimit-redis` for the `redis` adapter |
| Structured service settings | `config` |
| Multi-component lifecycle | `app` |
| Tenant-scoped detailed logs | `verbose-logs` |

Don't enable `full` outside tests.

## Wire it up

```toml
[dependencies]
labkit = { git = "https://gitlab.com/gitlab-org/rust/labkit-rs.git", tag = "vX.Y.Z", features = ["http", "prometheus"] }
```

```rust
use labkit::http::{AccessLogLayer, CorrelationLayer, GitlabTraceLayer, HttpMetricsLayer};
use labkit::{BuildInfo, Builder};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let _guard = Builder::new("my-service")
        .prometheus_metrics_port(probe_port())          // probe + metrics, internal port
        .build_info(BuildInfo::from_env())              // LABKIT_VERSION / _COMMIT / _BUILD_DATE
        .add_readiness_check("database", || db_ping())  // Result<(), String>, non-blocking
        .init()?;

    let router = routes()
        .layer(auth_layer())             // innermost: rejected requests still get logged
        .layer(AccessLogLayer::new())
        .layer(GitlabTraceLayer::new())
        .layer(CorrelationLayer::new())
        .layer(HttpMetricsLayer::new()); // outermost

    let listener = tokio::net::TcpListener::bind(("0.0.0.0", service_port())).await?;
    axum::serve(listener, router)
        .with_graceful_shutdown(shutdown_signal())
        .await?;
    Ok(())
}
```

`shutdown_signal` waits for SIGTERM and Ctrl-C. In a container the binary is PID 1
and gets no default SIGTERM handler, so without it Kubernetes waits out the grace
period and kills in-flight requests. For several subsystems, use the `app`
feature instead (see below). Use `LogFormat::Text` through `log_format(...)`
only for local development; services emit JSON.

Build metadata: Rust has no `-ldflags -X`, so either set `GIT_COMMIT` and
`BUILD_DATE` in a `build.rs` and pass `BuildInfo { .. }`, or inject
`LABKIT_VERSION`, `LABKIT_COMMIT`, and `LABKIT_BUILD_DATE` at container start and
use `BuildInfo::from_env()`. The README shows a reproducible-build-friendly
`build.rs`.

For gRPC, swap in `GrpcCorrelationLayer`, `GrpcTraceLayer`,
`GrpcAccessLogLayer`, and `GrpcMetricsLayer` from `labkit::grpc`.

Logging in handlers: structured fields, no string formatting of context.

```rust
tracing::info!(gl_user_id = user.id, "project created");
tracing::warn!(error_message = %err, "upstream call failed");
```

The JSON output carries the correlation ID automatically from the request span.
Don't log request bodies, tokens, or URLs with query strings. `AccessLogLayer`
logs the request URI as received, query string included, so keep secrets and
personal data out of query strings, or strip them before the layer runs.

## Outbound calls and non-HTTP work

- **HTTP clients:** put `labkit::http_client::CorrelationPropagationLayer` in the
  tower stack so outbound requests carry the correlation ID and
  `X-GitLab-Client-Name` (set the name with `Builder::client_name`).
- **gRPC clients:** `labkit::grpc_client::GrpcClientCorrelationLayer`.
- **Background jobs, cron, NATS or queue consumers:** there is no middleware, so
  open a span yourself: `labkit::context::span_with_id("job.name", id)` when an
  upstream ID exists (message header, database record), `labkit::context::span`
  when the work starts here. Wrap the work with `.instrument(span)`.
- **`tokio::spawn`:** carry the span into spawned tasks with `.in_current_span()`
  or the correlation ID and tenant fields are lost.

## Config, lifecycle, and the rest

- **`labkit-config`** (feature `config`): the schema is a `.proto` with
  `buf.validate` rules; the loader reads YAML, JSON, or (opt-in) TOML, validates,
  and returns the prost type. It needs `buf` and `protoc` in the toolchain.
  `resolve_path()` finds the file: `$CONFIG_DIR/config.yaml`, then `$CONFIG_PATH`,
  then `config/local.yaml`. Don't hand-roll a config loader or a second validator
  for GitLab services.
- **`app`**: implement `Component` per subsystem, register in dependency order;
  `App::run` starts them in order, waits for SIGINT or SIGTERM, shuts them down in
  reverse under a shared budget (default 30s; size it against
  `terminationGracePeriodSeconds`), and flushes telemetry last when you pass the
  guard with `with_guard`. Use `register_non_critical` for a dependency whose
  absence should degrade the service rather than abort startup.
- **`ratelimit`**: shares Redis key shape, headers, and `gitlab_labkit_rate_limiter_*`
  metrics with the other SDKs. `check` never errors: an unreachable Redis fails
  open and logs a warning, so set a timeout on the Redis connection.
- **`verbose-logs`**: declare which fields are safe on every line; detailed fields
  and debug lines appear only for chosen namespaces, requests, or environments.
  Prefer this to ad hoc `if debug` logging. See
  [expanded logs](https://gitlab.com/gitlab-org/rust/labkit-rs/-/blob/main/docs/expanded-logs.md).
  Product analytics goes through the separate `labkit-events` crate (Snowplow
  events), not a ported analytics client.

## Test the observability contract

Add these in Phase 3 and keep them green through Phase 5. Use axum's `oneshot`
or a bound test listener; none needs a collector.

1. **Access log fields:** capture the JSON line for one request and assert the
   fields from the Phase 1 inventory, using `labkit::fields` constants.
2. **Correlation round trip:** with `propagate_correlation(true)`, send
   `X-Request-ID: <id>` and assert the same value in the access log and, with
   `echo_response_header(true)`, in the response. Without the header, assert a
   26-character ULID is generated.
3. **Probes:** `/-/liveness` returns 200; `/-/readiness` returns 503 with a
   failing check and 200 after recovery; `/-/metrics` includes
   `http_server_request_duration_seconds`.
4. **Wire compatibility with Go services:** if the service talks to Go LabKit
   services, run the labkit-spec conformance harness
   ([README](https://gitlab.com/gitlab-org/rust/labkit-rs#conformance-harness)).

Mutation testing applies here too: a surviving mutant that deletes a readiness
check or a field means the test isn't asserting the contract.

## Security settings

- **Probe TLS:** services that must encrypt pod-to-pod traffic call
  `Builder::probe_tls(Some(ServerTls::builder(cert, key).build()?))`. Probes then
  need `scheme: HTTPS`, and the PodMonitor needs `scheme: https` plus a `tlsConfig`.
  For FIPS, install only the validated crypto provider through
  `labkit::rustls::crypto::...::default_provider().install_default()` before
  building `ServerTls`; labkit links none by default.
- **Log hygiene:** log fields are an allowlist problem. Use `verbose-logs` for
  anything beyond the safe set, never log bodies or credentials, and remember
  that `AccessLogLayer` records the full URI, query string included.
- **Supply chain:** pin the git dependency to a tag or commit, bump it in a
  reviewable commit, and run `cargo deny` and `cargo audit` on the updated lockfile.
- **Panics:** labkit warns on `unwrap`, `expect`, and `panic` in its own code.
  Hold service code to the same standard so a bad request can't take down a
  worker thread.

## Verify and contribute upstream

Run `scripts/check-labkit-usage.sh <project-dir>`. It flags a missing labkit
dependency or `Builder::init`, missing layers, competing logging or metrics
stacks, and raw field-name literals. Exit status 1 means findings; each finding
names the file and the fix. It's a static check, not a substitute for the tests
above.

If labkit-rs lacks something the original needs, open an issue or MR against
[labkit-rs](https://gitlab.com/gitlab-org/rust/labkit-rs) instead of forking or
re-implementing it in the service. Keep a temporary local shim behind a
documented divergence entry until the upstream change lands. For bench-built
services, read [gitlab-bench.md](gitlab-bench.md): the chassis already does
most of this wiring.
