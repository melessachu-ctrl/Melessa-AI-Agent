#!/usr/bin/env bash
# Link repo skills into ~/.cursor/skills so Cursor loads them globally.
# Run after: git clone / git pull
# Discovers every subdirectory that contains SKILL.md (no hard-coded list).

set -euo pipefail

SKILLS_DST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="${HOME}/.cursor/skills"

mkdir -p "$SKILLS_SRC"

linked=0
skipped=0

shopt -s nullglob
for src in "$SKILLS_DST"/*/; do
  name="$(basename "$src")"
  dst="${SKILLS_SRC}/${name}"

  if [[ ! -f "${src}SKILL.md" ]]; then
    echo "skip: ${name} (no SKILL.md)"
    skipped=$((skipped + 1))
    continue
  fi

  ln -sfn "${src%/}" "$dst"
  echo "linked: ${dst} -> ${src%/}"
  linked=$((linked + 1))
done
shopt -u nullglob

echo
echo "Done. Linked ${linked} skill(s), skipped ${skipped}."
echo "Restart Cursor or start a new Agent chat if skills do not appear yet."
