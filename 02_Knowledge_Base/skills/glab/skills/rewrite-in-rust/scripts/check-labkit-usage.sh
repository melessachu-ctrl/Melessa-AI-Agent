#!/usr/bin/env bash
# check-labkit-usage.sh - static check that a Rust service uses labkit-rs for
# observability instead of hand-rolled logging, metrics, and health code.
#
# Usage: check-labkit-usage.sh [--chassis-owned] [project-dir]
#
#   --chassis-owned  The wiring is generated elsewhere (a bench handler crate),
#                    so skip the "must depend on labkit, init it, and mount the
#                    layers" rules and only look for competing stacks.
#
# Prints one finding per line as `file:line: [rule] message` and exits 1 when
# there are findings, 0 when clean, 2 on a usage error. A line ending in a
# `labkit-ok` comment is skipped. Test code (tests/, benches/, examples/,
# build.rs) is not scanned for the code rules.
#
# This is a heuristic grep, not a parser. It reads Cargo.toml dependency lines
# and Rust source; table-form dependencies ([dependencies.labkit]) are not
# inspected for the pinning rule.
set -Eeuo pipefail

CHASSIS_OWNED=0
DIR=""
for arg in "$@"; do
    case "$arg" in
        --chassis-owned) CHASSIS_OWNED=1 ;;
        -h|--help)
            sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        -*)
            echo "check-labkit-usage: unknown option: $arg" >&2
            exit 2
            ;;
        *)
            if [ -n "$DIR" ]; then
                echo "check-labkit-usage: only one project directory is accepted" >&2
                exit 2
            fi
            DIR="$arg"
            ;;
    esac
done
DIR="${DIR:-.}"
if [ ! -d "$DIR" ]; then
    echo "check-labkit-usage: not a directory: $DIR" >&2
    exit 2
fi

# Work from the project root so the tests/ exclusions apply to paths inside the
# project, not to wherever the project happens to live.
cd "$DIR"
DIR="."

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FINDINGS="$TMP/findings"
MANIFESTS="$TMP/manifests"
SOURCES="$TMP/sources"
: > "$FINDINGS"

find "$DIR" \( -name target -o -name .git -o -name .bench -o -name vendor -o -name node_modules \) -prune \
    -o -name Cargo.toml -type f -print | sort > "$MANIFESTS"
find "$DIR" \( -name target -o -name .git -o -name .bench -o -name vendor -o -name node_modules \) -prune \
    -o -name '*.rs' -type f \
    ! -path '*/tests/*' ! -path '*/benches/*' ! -path '*/examples/*' ! -name build.rs -print | sort > "$SOURCES"

if [ ! -s "$MANIFESTS" ]; then
    echo "check-labkit-usage: no Cargo.toml under $DIR" >&2
    exit 2
fi

report() { # file line rule message
    printf '%s:%s: [%s] %s\n' "$1" "$2" "$3" "$4" >> "$FINDINGS"
}

# scan <list-file> <rule> <ERE> <message>: report each matching line.
scan() {
    local list="$1" rule="$2" regex="$3" message="$4" file hit line
    while IFS= read -r file; do
        grep -nE "$regex" "$file" 2>/dev/null | grep -v 'labkit-ok' | grep -vE '^[0-9]+:[[:space:]]*//' > "$TMP/hits" || true
        while IFS= read -r hit; do
            [ -n "$hit" ] || continue
            line="${hit%%:*}"
            report "$file" "$line" "$rule" "$message"
        done < "$TMP/hits"
    done < "$list"
}

# any_file_matches <list-file> <ERE>: true if some listed file matches.
any_file_matches() {
    local file
    while IFS= read -r file; do
        if grep -qE "$2" "$file" 2>/dev/null; then
            return 0
        fi
    done < "$1"
    return 1
}

# Dependency lines that name the labkit-rs repo but carry neither tag nor rev.
scan_unpinned() {
    local file hit line
    while IFS= read -r file; do
        grep -nE 'labkit-rs' "$file" 2>/dev/null \
            | grep -vE '^[0-9]+:[[:space:]]*(#|\[)' \
            | grep -vE '(tag|rev)[[:space:]]*=' \
            | grep -v 'labkit-ok' > "$TMP/hits" || true
        while IFS= read -r hit; do
            [ -n "$hit" ] || continue
            line="${hit%%:*}"
            report "$file" "$line" unpinned-labkit \
                'labkit-rs git dependency has no tag or rev; pin tag = "vX.Y.Z" or rev = "<sha>"'
        done < "$TMP/hits"
    done < "$MANIFESTS"
}

DEP_LABKIT='^[[:space:]]*labkit(-[a-z]+)?[[:space:]]*(=|\.)'
HAS_LABKIT=0
any_file_matches "$MANIFESTS" "$DEP_LABKIT" && HAS_LABKIT=1

if [ "$CHASSIS_OWNED" -eq 0 ]; then
    if [ "$HAS_LABKIT" -eq 0 ]; then
        report "$DIR" 0 no-dependency "no labkit dependency in any Cargo.toml; add labkit-rs as a git dependency pinned to a tag"
    fi

    if ! any_file_matches "$SOURCES" 'Builder::new\('; then
        report "$DIR" 0 no-init "no labkit::Builder::new(...).init() found; initialize labkit once in main"
    fi
    scan "$SOURCES" dropped-guard '^[[:space:]]*let[[:space:]]+_[[:space:]]*=[[:space:]]*(labkit::)?Builder::new' \
        "the labkit Guard is dropped immediately; bind it (let _guard = ...) so telemetry lives until exit"

    if any_file_matches "$MANIFESTS" '^[[:space:]]*axum[[:space:]]*(=|\.)'; then
        for layer in CorrelationLayer AccessLogLayer GitlabTraceLayer HttpMetricsLayer; do
            if ! any_file_matches "$SOURCES" "$layer"; then
                report "$DIR" 0 missing-layer "axum service without labkit::http::$layer"
            fi
        done
    fi
    if any_file_matches "$MANIFESTS" '^[[:space:]]*tonic[[:space:]]*(=|\.)'; then
        for layer in GrpcCorrelationLayer GrpcTraceLayer GrpcAccessLogLayer GrpcMetricsLayer; do
            if ! any_file_matches "$SOURCES" "$layer"; then
                report "$DIR" 0 missing-layer "tonic service without labkit::grpc::$layer"
            fi
        done
    fi
fi

scan "$MANIFESTS" competing-logger \
    '^[[:space:]]*(env_logger|pretty_env_logger|log4rs|slog[a-z_-]*|fern|flexi_logger|tracing-bunyan-formatter)[[:space:]]*(=|\.)' \
    "second logging stack; labkit installs the one global subscriber, log with tracing macros"
scan "$MANIFESTS" competing-metrics \
    '^[[:space:]]*(prometheus|prometheus-client|metrics|metrics-exporter-prometheus|opentelemetry-prometheus|statsd|cadence)[[:space:]]*(=|\.)' \
    "second metrics stack; record OpenTelemetry instruments and let labkit's prometheus feature export them"
scan_unpinned
scan "$SOURCES" competing-subscriber \
    'tracing_subscriber::(fmt\(|fmt::init|registry\(|FmtSubscriber)|set_global_default\(' \
    "own tracing subscriber; Builder::init installs the only one"
scan "$SOURCES" handrolled-probe \
    '\.route\([[:space:]]*"/(health|healthz|ready|readyz|livez|ping|metrics|-/liveness|-/readiness|-/metrics)"' \
    "hand-rolled probe route; labkit serves /-/liveness, /-/readiness, /-/metrics on the probe port"
scan "$SOURCES" stdout-logging \
    '(^|[^a-zA-Z_])(println|eprintln|dbg)!\(' \
    "stdout/stderr printing in service code; use tracing macros"
scan "$SOURCES" raw-field-name \
    '"(correlation_id|gl_user_id|gl_user_name|gl_project_id|gl_namespace_id|gl_root_namespace_id|error_type|error_message|duration_s)"' \
    "raw log field name; use the matching labkit::fields constant"
scan "$SOURCES" raw-correlation-header \
    '"[Xx]-[Rr]equest-[Ii][Dd]"' \
    "raw X-Request-ID literal; use labkit::correlation::HTTP_HEADER"

if [ -s "$FINDINGS" ]; then
    sort -u "$FINDINGS"
    count="$(sort -u "$FINDINGS" | wc -l | tr -d ' ')"
    echo "check-labkit-usage: $count finding(s)" >&2
    exit 1
fi
echo "check-labkit-usage: clean"
