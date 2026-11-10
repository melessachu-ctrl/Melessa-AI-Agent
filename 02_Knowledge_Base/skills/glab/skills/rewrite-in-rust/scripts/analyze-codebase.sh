#!/usr/bin/env bash
# analyze-codebase.sh — Static analysis helper for pre-rewrite codebase understanding
# Usage: ./analyze-codebase.sh /path/to/source [language]
# Supported languages: c, cpp, python, ruby, javascript, go, java, auto
set -euo pipefail

SOURCE_DIR="${1:?Usage: $0 /path/to/source [language]}"
SRC_LANG="${2:-auto}"
OUTPUT_DIR="${SOURCE_DIR}/rewrite-analysis"

mkdir -p "$OUTPUT_DIR"

echo "=== Rewrite-in-Rust Codebase Analysis ==="
echo "Source: $SOURCE_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

# --- Auto-detect language ---
if [ "$SRC_LANG" = "auto" ]; then
    C_COUNT=$(find "$SOURCE_DIR" -name '*.c' -o -name '*.h' 2>/dev/null | wc -l)
    CPP_COUNT=$(find "$SOURCE_DIR" -name '*.cpp' -o -name '*.cc' -o -name '*.hpp' 2>/dev/null | wc -l)
    PY_COUNT=$(find "$SOURCE_DIR" -name '*.py' 2>/dev/null | wc -l)
    RB_COUNT=$(find "$SOURCE_DIR" -name '*.rb' 2>/dev/null | wc -l)
    JS_COUNT=$(find "$SOURCE_DIR" -name '*.js' -o -name '*.ts' 2>/dev/null | wc -l)
    GO_COUNT=$(find "$SOURCE_DIR" -name '*.go' 2>/dev/null | wc -l)
    JAVA_COUNT=$(find "$SOURCE_DIR" -name '*.java' 2>/dev/null | wc -l)

    MAX=0
    for pair in "c:$C_COUNT" "cpp:$CPP_COUNT" "python:$PY_COUNT" "ruby:$RB_COUNT" \
                "javascript:$JS_COUNT" "go:$GO_COUNT" "java:$JAVA_COUNT"; do
        l="${pair%%:*}"
        n="${pair##*:}"
        if [ "$n" -gt "$MAX" ]; then
            MAX=$n
            SRC_LANG=$l
        fi
    done
    echo "Auto-detected language: $SRC_LANG"
fi

# --- LOC count ---
echo ""
echo "--- Lines of Code ---"
if command -v cloc &>/dev/null; then
    cloc "$SOURCE_DIR" --quiet --out="$OUTPUT_DIR/loc-summary.txt" 2>/dev/null || true
    cat "$OUTPUT_DIR/loc-summary.txt"
elif command -v tokei &>/dev/null; then
    tokei "$SOURCE_DIR" > "$OUTPUT_DIR/loc-summary.txt" 2>/dev/null || true
    cat "$OUTPUT_DIR/loc-summary.txt"
else
    echo "Install 'cloc' or 'tokei' for detailed LOC statistics"
    find "$SOURCE_DIR" -type f | wc -l | xargs echo "Total files:"
fi

# --- File structure ---
echo ""
echo "--- Directory Structure (2 levels deep) ---"
find "$SOURCE_DIR" -maxdepth 2 -type d \
    ! -path '*/\.*' ! -path '*/node_modules/*' ! -path '*/target/*' \
    ! -path '*/__pycache__/*' ! -path '*/vendor/*' ! -path '*/.git/*' \
    | sort > "$OUTPUT_DIR/directory-structure.txt"
cat "$OUTPUT_DIR/directory-structure.txt"

# --- VCS hotspot analysis ---
if [ -d "$SOURCE_DIR/.git" ]; then
    echo ""
    echo "--- VCS Hotspots (most-changed files) ---"
    (cd "$SOURCE_DIR" && git log --format=format: --name-only --since="1 year ago" \
        | grep -v '^$' | sort | uniq -c | sort -rn | head -20) \
        > "$OUTPUT_DIR/vcs-hotspots.txt" 2>/dev/null || true
    cat "$OUTPUT_DIR/vcs-hotspots.txt"

    echo ""
    echo "--- Bug/Security Fix Commits ---"
    (cd "$SOURCE_DIR" && git log --oneline --since="2 years ago" \
        --grep="fix\|bug\|security\|CVE\|crash\|memory\|leak\|overflow\|vulnerability" \
        | wc -l | xargs echo "Bug/security-related commits:") \
        > "$OUTPUT_DIR/security-commits.txt" 2>/dev/null || true
    cat "$OUTPUT_DIR/security-commits.txt"
fi

# --- Test suite inventory ---
echo ""
echo "--- Test Files ---"
find "$SOURCE_DIR" -type f \( \
    -name '*test*' -o -name '*spec*' -o -name '*_test.*' -o -name 'test_*' \
\) ! -path '*/\.*' ! -path '*/node_modules/*' ! -path '*/target/*' \
    | head -30 > "$OUTPUT_DIR/test-files.txt"
TEST_COUNT=$(wc -l < "$OUTPUT_DIR/test-files.txt")
echo "Found $TEST_COUNT test files"
cat "$OUTPUT_DIR/test-files.txt"

# --- Public interface inventory ---
echo ""
echo "--- Public Interface Scan ---"
case "$SRC_LANG" in
    c|cpp)
        echo "Header files (public API surface):"
        find "$SOURCE_DIR" -name '*.h' -o -name '*.hpp' | head -20
        ;;
    python)
        echo "Public modules (__init__.py files):"
        find "$SOURCE_DIR" -name '__init__.py' | head -20
        ;;
    go)
        echo "Exported functions:"
        grep -rn '^func [A-Z]' "$SOURCE_DIR" --include='*.go' | head -20
        ;;
    javascript)
        echo "Export statements:"
        grep -rn 'export ' "$SOURCE_DIR" --include='*.ts' --include='*.js' | head -20
        ;;
    ruby)
        echo "Public methods:"
        grep -rn 'def [a-z]' "$SOURCE_DIR" --include='*.rb' | head -20
        ;;
    java)
        echo "Public methods:"
        grep -rn 'public.*(' "$SOURCE_DIR" --include='*.java' | head -20
        ;;
esac > "$OUTPUT_DIR/public-interfaces.txt" 2>/dev/null || true
cat "$OUTPUT_DIR/public-interfaces.txt"

# --- Observability inventory (log fields, metrics, headers, probes, config) ---
# Feeds the "observability contract" in the behavioral spec. For a GitLab
# service, see references/gitlab-labkit-rs.md to decide which of these labkit-rs
# replaces and which are service-specific and must be kept.
echo ""
echo "--- Observability Inventory ---"
OBS_FILE="$OUTPUT_DIR/observability-inventory.txt"
obs_scan() { # label ERE
    echo "## $1"
    grep -rnE "$2" "$SOURCE_DIR" \
        --include='*.c' --include='*.h' --include='*.cc' --include='*.cpp' --include='*.hpp' \
        --include='*.py' --include='*.rb' --include='*.js' --include='*.ts' \
        --include='*.go' --include='*.java' --include='*.yaml' --include='*.yml' --include='*.toml' \
        --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=target \
        --exclude-dir=vendor --exclude-dir=rewrite-analysis 2>/dev/null | head -25 || true
    echo ""
}
{
    obs_scan "Logging libraries and setup" '(logrus|zap\.|slog\.|log/slog|winston|pino|bunyan|log4j|logback|structlog|logging\.(basicConfig|getLogger)|Logger\.new|AppLogger)'
    obs_scan "Metrics instruments and endpoints" '(prometheus|statsd|datadog|opentelemetry|otel|/metrics|Counter\(|Histogram\(|Gauge\()'
    obs_scan "Request and correlation IDs, trace headers" '(X-Request-ID|x-request-id|correlation[_-]?id|traceparent|X-B3-|Cf-Ray|X-GitLab-Client-Name)'
    obs_scan "Health, readiness, and liveness endpoints" '(/healthz?|/ready(z)?|/livez?|/ping|/-/liveness|/-/readiness|/-/metrics)'
    obs_scan "Config loading" '(viper|os\.Getenv|ENV\[|os\.environ|process\.env|dotenv|ConfigMap|config\.(yaml|yml|toml))'
} > "$OBS_FILE"
grep -c '^[^#[:space:]].*:[0-9]*:' "$OBS_FILE" 2>/dev/null | xargs echo "Observability references found (first 25 per category):" || true
echo "Details: $OBS_FILE"

# --- Summary ---
echo ""
echo "=== Analysis Complete ==="
echo "All output saved to: $OUTPUT_DIR/"
echo ""
echo "Next steps:"
echo "  1. Review $OUTPUT_DIR/vcs-hotspots.txt — these are your highest-priority rewrite targets"
echo "  2. Review $OUTPUT_DIR/test-files.txt — these are your behavioral baseline"
echo "  3. Review $OUTPUT_DIR/public-interfaces.txt — these are the contracts you must preserve"
echo "  4. Run the existing test suite and record pass/fail baseline"
echo "  5. Write characterization tests for undocumented behavior"
echo "  6. Review $OUTPUT_DIR/observability-inventory.txt — for a GitLab service, record which signals labkit-rs replaces"
