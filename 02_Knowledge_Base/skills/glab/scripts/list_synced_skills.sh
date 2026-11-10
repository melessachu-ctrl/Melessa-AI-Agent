#!/bin/sh
# Print the name of each synced skill (one per line): the 2-space-indented
# keys under the top-level `skills:` in synced-skills.yml.
#
# Usage: scripts/list_synced_skills.sh [manifest]   (default: ./synced-skills.yml)
# Prints nothing if the manifest is missing or lists no skills.

manifest="${1:-synced-skills.yml}"
[ -f "$manifest" ] || exit 0

awk '
  /^skills:/ { in_skills = 1; next }
  /^[^ #]/ { in_skills = 0 }
  in_skills && /^  [A-Za-z0-9_-]+:[ ]*$/ { sub(/^  /, ""); sub(/:.*/, ""); print }
' "$manifest"
