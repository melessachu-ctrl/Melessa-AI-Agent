#!/usr/bin/env bash
# Link repo skills into ~/.cursor/skills so Cursor loads them globally.
# Run after: git clone / git pull

set -euo pipefail

SKILLS_DST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="${HOME}/.cursor/skills"

mkdir -p "$SKILLS_SRC"

SKILL_NAMES=(
  apply-design-system
  audit-design-system
  email-writer
  figma-file-cleanup
  figma-mcp-server-guide
  fix-design-system-finding
  frontend-design
  google-maps-bookmark
  hktvmall-target-customers
  ricky-design-guideline
  tonight-dinner
  ui-ux-pro-max
  uiux-design-studio
  uiux-review
  update-wanderlog
)

linked=0
skipped=0

for name in "${SKILL_NAMES[@]}"; do
  src="${SKILLS_DST}/${name}"
  dst="${SKILLS_SRC}/${name}"

  if [[ ! -d "$src" ]]; then
    echo "skip: ${name} (missing in repo)"
    skipped=$((skipped + 1))
    continue
  fi

  ln -sfn "$src" "$dst"
  echo "linked: ${dst} -> ${src}"
  linked=$((linked + 1))
done

echo
echo "Done. Linked ${linked} skill(s), skipped ${skipped}."
echo "Restart Cursor or start a new Agent chat if skills do not appear yet."
