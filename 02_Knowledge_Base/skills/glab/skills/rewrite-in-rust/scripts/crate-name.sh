#!/usr/bin/env bash
# crate-name.sh - shared crate naming rule for the rewrite-in-rust scripts.
# Source it; it defines functions only.
#
# Rule: crate names are snake_case (`my_service`), never hyphenated. A package
# named `my-service` has a library crate called `my_service`, so the two names
# drift apart in `use` paths, logs, and docs. One spelling everywhere avoids it.
# Allowed: lowercase ASCII letters, digits, and single underscores, starting
# with a letter.

# is_snake_case_crate_name <name>
is_snake_case_crate_name() {
    case "$1" in
        *$'\n'*) return 1 ;; # grep checks line by line; don't let a second line slip by
    esac
    printf '%s\n' "$1" | LC_ALL=C grep -qE '^[a-z][a-z0-9]*(_[a-z0-9]+)*$'
}

# suggest_crate_name <name>: best-effort snake_case spelling of <name>.
suggest_crate_name() {
    printf '%s\n' "$1" \
        | LC_ALL=C tr '[:upper:]' '[:lower:]' \
        | LC_ALL=C sed -e 's/[^a-z0-9]/_/g' -e 's/__*/_/g' -e 's/^_//' -e 's/_$//'
}

# crate_name_error <name>: print why <name> is rejected and what to use instead.
crate_name_error() {
    local suggestion
    suggestion="$(suggest_crate_name "$1")"
    if printf '%s\n' "$suggestion" | grep -qE '^[a-z]'; then
        echo "crate name '$1' is not snake_case; use '$suggestion'" >&2
    else
        echo "crate name '$1' is not snake_case and can't be converted; pick a name that starts with a letter" >&2
    fi
}

# package_names <Cargo.toml>: print the [package] name, if the file has one.
package_names() {
    awk '
        /^[[:space:]]*\[/ { in_package = ($0 ~ /^[[:space:]]*\[package\][[:space:]]*$/) }
        in_package && /^[[:space:]]*name[[:space:]]*=/ {
            line = $0
            sub(/^[^"]*"/, "", line)
            sub(/".*$/, "", line)
            print line
            exit
        }
    ' "$1"
}
