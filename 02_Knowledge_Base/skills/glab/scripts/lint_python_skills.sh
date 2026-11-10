#!/bin/sh
# Run ruff over the non-synced skills under skills/ (synced skills are the keys
# under `skills:` in synced-skills.yml; fix those upstream). Uses the rules from
# ruff.toml; passing skills/ as an explicit path overrides the config's
# exclusion of it.
set -eu

cd "$(dirname "$0")/.."

synced=$(scripts/list_synced_skills.sh | sed 's|^|skills/|' | paste -sd, -)
exec ruff check skills ${synced:+--extend-exclude "$synced"}
