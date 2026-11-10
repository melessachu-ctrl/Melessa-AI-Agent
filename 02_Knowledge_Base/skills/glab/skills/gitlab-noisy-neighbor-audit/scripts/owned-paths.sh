#!/usr/bin/env bash
# List gitlab-org/gitlab files owned by one or more feature categories.
#
# Usage (from the root of a gitlab-org/gitlab checkout):
#   owned-paths.sh <feature_category>...
# Output (TSV, sorted): <how>\t<category>\t<path>
#   declared   source file declares `feature_category :<cat>`
#   spec          source file whose spec is tagged `feature_category: :<cat>` at the top
#   spec-partial  shared source file; only some examples in its spec carry the tag
#   spec-only     tagged spec with no matching source file (request/feature specs)
# Exit: 0 success, 2 usage error.
set -Eeuo pipefail

if [[ $# -eq 0 ]]; then
  echo "usage: $(basename "$0") <feature_category>..." >&2
  exit 2
fi
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "error: run from inside a gitlab-org/gitlab checkout" >&2
  exit 2
fi
cd "$(git rev-parse --show-toplevel)"

# Map a spec path to the source path it most likely covers, or print nothing.
source_for_spec() {
  local spec="$1" base="" rest candidate
  case "$spec" in
    ee/spec/*) base="ee/"; rest="${spec#ee/spec/}" ;;
    spec/*) rest="${spec#spec/}" ;;
    *) return 0 ;;
  esac
  rest="${rest%_spec.rb}.rb"
  # EE specs often cover an override module (ee/app/models/ee/foo.rb) or CE code,
  # including ee/spec/services/ee/foo_spec.rb for CE app/services/foo.rb.
  for candidate in "${base}app/$rest" "${base}$rest" "${base}app/${rest%%/*}/ee/${rest#*/}" \
    "${base}lib/api/${rest#requests/api/}" "app/$rest" "$rest" "lib/api/${rest#requests/api/}" \
    "app/${rest%%/*}/${rest#*/ee/}"; do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
}

top_level_describes() {
  awk '/^(RSpec\.)?describe/ { on = 1 } on { printf "%s ", $0 } on && / do( |$)/ { on = 0; print "" }' "$1"
}

for category in "$@"; do
  if [[ ! "$category" =~ ^[a-z0-9_]+$ ]]; then
    echo "error: invalid feature category: $category" >&2
    exit 2
  fi
  # Matches `feature_category :cat` and `feature_category: :cat`, not `:cat_other`.
  pattern="feature_category:?[[:space:]]+:${category}([^a-z0-9_]|$)"

  git grep -lE "$pattern" -- 'app/*.rb' 'lib/*.rb' 'ee/app/*.rb' 'ee/lib/*.rb' 2>/dev/null \
    | while IFS= read -r path; do
        printf 'declared\t%s\t%s\n' "$category" "$path"
      done || true

  git grep -lE "$pattern" -- 'spec/*_spec.rb' 'ee/spec/*_spec.rb' 2>/dev/null \
    | while IFS= read -r spec; do
        src=$(source_for_spec "$spec")
        if [[ -n "$src" ]] && grep -qE "^(RSpec\.)?describe.*${pattern}" <<<"$(top_level_describes "$spec")"; then
          printf 'spec\t%s\t%s\n' "$category" "$src"
        elif [[ -n "$src" ]]; then
          printf 'spec-partial\t%s\t%s\n' "$category" "$src"
        else
          printf 'spec-only\t%s\t%s\n' "$category" "$spec"
        fi
      done || true
# Drop code no actor can trigger: batched migrations, cops, migration specs.
done | { grep -vE $'\t(ee/)?(lib/gitlab/background_migration|rubocop|spec/migrations|spec/rubocop)/' || true; } | sort -u
