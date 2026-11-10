#!/usr/bin/env bash
# Tests for scripts/check-labkit-usage.sh. No network, no cargo: each case
# writes a tiny project into a temp dir and checks the exit status and rules.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/../scripts/check-labkit-usage.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0

show_out() { printf '%s\n' "$OUT" | sed 's/^/     /'; }
ok() { PASS=$((PASS + 1)); echo "ok   - $1"; }
bad() { FAIL=$((FAIL + 1)); echo "FAIL - $1"; }

# new_project <name> <Cargo.toml body> <main.rs body>
new_project() {
    local dir="$TMP/$1"
    mkdir -p "$dir/src"
    printf '%s\n' "$2" > "$dir/Cargo.toml"
    printf '%s\n' "$3" > "$dir/src/main.rs"
    echo "$dir"
}

# run_check <args...>: sets OUT and CODE.
run_check() {
    OUT="$("$SCRIPT" "$@" 2>&1)"
    CODE=$?
}

expect_code() { # name expected
    if [ "$CODE" -eq "$2" ]; then ok "$1"; else bad "$1 (exit $CODE, wanted $2)"; show_out; fi
}

expect_rule() { # name rule
    if echo "$OUT" | grep -q "\[$2\]"; then ok "$1"; else bad "$1 (no [$2] in output)"; show_out; fi
}

expect_no_rule() { # name rule
    if echo "$OUT" | grep -q "\[$2\]"; then bad "$1 ([$2] reported)"; show_out; else ok "$1"; fi
}

GOOD_TOML='[package]
name = "svc"
[dependencies]
labkit = { git = "https://gitlab.com/gitlab-org/rust/labkit-rs.git", tag = "v0.10.0", features = ["http", "prometheus"] }
axum = "0.8"
tokio = "1"'

GOOD_MAIN='use labkit::http::{AccessLogLayer, CorrelationLayer, GitlabTraceLayer, HttpMetricsLayer};
use labkit::Builder;
fn main() {
    let _guard = Builder::new("svc").init().expect("init");
    let _router = routes()
        .layer(AccessLogLayer::new())
        .layer(GitlabTraceLayer::new())
        .layer(CorrelationLayer::new())
        .layer(HttpMetricsLayer::new());
    tracing::info!(gl_user_id = 1u64, "started");
}'

# --- a correctly wired service is clean
dir="$(new_project good "$GOOD_TOML" "$GOOD_MAIN")"
run_check "$dir"
expect_code "wired service is clean" 0

# --- rev pin is accepted
dir="$(new_project rev "${GOOD_TOML/tag = \"v0.10.0\"/rev = \"abc123\"}" "$GOOD_MAIN")"
run_check "$dir"
expect_code "rev-pinned dependency is clean" 0

# --- a service with no labkit at all
dir="$(new_project none '[package]
name = "svc"
[dependencies]
axum = "0.8"' 'fn main() {}')"
run_check "$dir"
expect_code "no labkit fails" 1
expect_rule "no labkit reports no-dependency" no-dependency
expect_rule "no labkit reports no-init" no-init
expect_rule "no labkit reports missing-layer" missing-layer

# --- competing stacks and hand-rolled code
dir="$(new_project competing '[package]
name = "svc"
[dependencies]
labkit = { git = "https://gitlab.com/gitlab-org/rust/labkit-rs.git", branch = "main" }
axum = "0.8"
env_logger = "0.11"
prometheus = "0.13"' 'use labkit::http::{AccessLogLayer, CorrelationLayer, GitlabTraceLayer, HttpMetricsLayer};
use labkit::Builder;
fn main() {
    let _guard = Builder::new("svc").init().expect("init");
    tracing_subscriber::fmt().init();
    println!("listening");
    let _r = routes().route("/health", get(ok)).route("/metrics", get(ok));
    span.record("correlation_id", id);
    let _ = (AccessLogLayer::new(), GitlabTraceLayer::new(), CorrelationLayer::new(), HttpMetricsLayer::new());
    let _h = headers.get("X-Request-ID");
}')"
run_check "$dir"
expect_code "competing stacks fail" 1
expect_rule "env_logger flagged" competing-logger
expect_rule "prometheus crate flagged" competing-metrics
expect_rule "branch dependency flagged" unpinned-labkit
expect_rule "own subscriber flagged" competing-subscriber
expect_rule "hand-rolled probe flagged" handrolled-probe
expect_rule "println flagged" stdout-logging
expect_rule "raw field name flagged" raw-field-name
expect_rule "raw header flagged" raw-correlation-header
expect_no_rule "wired layers not reported missing" missing-layer

# --- dropped guard
dir="$(new_project dropped "$GOOD_TOML" "${GOOD_MAIN/let _guard/let _}")"
run_check "$dir"
expect_code "dropped guard fails" 1
expect_rule "dropped guard reported" dropped-guard

# --- line-level suppression
dir="$(new_project suppressed "$GOOD_TOML" "$GOOD_MAIN
fn banner() { println!(\"hello\"); } // labkit-ok")"
run_check "$dir"
expect_code "labkit-ok suppresses a finding" 0

# --- comments and test code are not scanned
dir="$(new_project withtests "$GOOD_TOML" "$GOOD_MAIN
// println!(\"in a comment\")")"
mkdir -p "$dir/tests"
printf 'fn t() { println!("fine in tests"); }\n' > "$dir/tests/it.rs"
run_check "$dir"
expect_code "comments and tests/ are ignored" 0

# --- chassis-owned handler crate
HANDLER_TOML='[package]
name = "handler"
[dependencies]
serde = "1"'
dir="$(new_project handler "$HANDLER_TOML" 'pub struct Handler;')"
run_check "$dir"
expect_code "handler crate without --chassis-owned fails" 1
run_check --chassis-owned "$dir"
expect_code "handler crate with --chassis-owned is clean" 0
dir="$(new_project handler_bad "$HANDLER_TOML
env_logger = \"0.11\"" 'pub struct Handler;')"
run_check --chassis-owned "$dir"
expect_code "--chassis-owned still flags competing stacks" 1
expect_rule "--chassis-owned reports competing-logger" competing-logger

# --- usage errors
run_check "$TMP/does-not-exist"
expect_code "missing directory is a usage error" 2
run_check --bogus "$TMP/good"
expect_code "unknown option is a usage error" 2
mkdir -p "$TMP/empty"
run_check "$TMP/empty"
expect_code "directory without Cargo.toml is a usage error" 2
run_check --help
expect_code "--help exits 0" 0

echo
echo "passed: $PASS, failed: $FAIL"
[ "$FAIL" -eq 0 ]
