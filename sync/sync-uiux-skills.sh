#!/usr/bin/env bash
# Sync UI/UX skills and cursor rules from Melessa to UIUX-Skills downstream repo.
set -euo pipefail

MELESSA_ROOT="${1:-.}"
OUT_DIR="${2:-./uiux-skills-out}"
MANIFEST="${MELESSA_ROOT}/sync/uiux-skills-manifest.json"
DATE="$(date -u +%Y-%m-%d)"
SHORT_SHA="${GITHUB_SHA:-local}"
SHORT_SHA="${SHORT_SHA:0:7}"

if [[ ! -f "$MANIFEST" ]]; then
  echo "Manifest not found: $MANIFEST" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

SKILLS_SOURCE="${MELESSA_ROOT}/$(jq -r '.skills_source' "$MANIFEST")"
RULES_SOURCE="${MELESSA_ROOT}/$(jq -r '.rules_source' "$MANIFEST")"

mkdir -p "${OUT_DIR}/skills" "${OUT_DIR}/rules"

CHANGED_ITEMS=()

# Sync skills
while IFS= read -r skill; do
  src="${SKILLS_SOURCE}/${skill}"
  dst="${OUT_DIR}/skills/${skill}"
  if [[ ! -d "$src" ]]; then
    echo "Missing skill directory: $src" >&2
    exit 1
  fi
  mkdir -p "$dst"
  # Capture dry-run output. `grep -q` under pipefail closes the pipe early and
  # hides a real change, so a brand-new skill never reaches the changelog.
  dry_out="$(rsync -a --delete --dry-run --out-format='%n' "$src/" "$dst/" || true)"
  if [[ -n "${dry_out//[$' \t\r\n']/}" ]]; then
    CHANGED_ITEMS+=("$skill")
  fi
  rsync -a --delete "$src/" "$dst/"
done < <(jq -r '.skills[]' "$MANIFEST")

# Sync rules (Cursor .mdc + identical portable .md twin for Spaces / other agents)
while IFS= read -r rule; do
  src="${RULES_SOURCE}/${rule}"
  dst="${OUT_DIR}/rules/${rule}"
  if [[ ! -f "$src" ]]; then
    echo "Missing rule file: $src" >&2
    exit 1
  fi
  if [[ ! -f "$dst" ]] || ! cmp -s "$src" "$dst"; then
    CHANGED_ITEMS+=("rule:${rule}")
  fi
  cp "$src" "$dst"

  if [[ "$rule" == *.mdc ]]; then
    md_name="${rule%.mdc}.md"
    md_dst="${OUT_DIR}/rules/${md_name}"
    if [[ ! -f "$md_dst" ]] || ! cmp -s "$src" "$md_dst"; then
      CHANGED_ITEMS+=("rule:${md_name}")
    fi
    cp "$src" "$md_dst"
  fi
done < <(jq -r '.rules[]' "$MANIFEST")

# Claude Code entry points. Relative symlinks so a session opened at the
# UIUX-Skills root loads skills and rules. Recreate every run so skills or
# rules removed from the manifest do not leave stale links.
CLAUDE_SKILLS="${OUT_DIR}/.claude/skills"
CLAUDE_RULES="${OUT_DIR}/.claude/rules"
rm -rf "$CLAUDE_SKILLS" "$CLAUDE_RULES"
mkdir -p "$CLAUDE_SKILLS" "$CLAUDE_RULES"

shopt -s nullglob
for skill_dir in "${OUT_DIR}/skills"/*/; do
  name="$(basename "$skill_dir")"
  if [[ ! -f "${skill_dir}SKILL.md" ]]; then
    echo "skip claude skill link: ${name} (no SKILL.md)"
    continue
  fi
  ln -s "../../skills/${name}" "${CLAUDE_SKILLS}/${name}"
done

for md in "${OUT_DIR}/rules"/*.md; do
  base="$(basename "$md")"
  ln -s "../../rules/${base}" "${CLAUDE_RULES}/${base}"
done

# Cursor project rules. Opening UIUX-Skills loads .cursor/rules/*.mdc.
# Only replace symlinks this script owns (../../rules/*). Leave hand-maintained
# files such as uiux-design-studio.mdc in place.
CURSOR_RULES="${OUT_DIR}/.cursor/rules"
mkdir -p "$CURSOR_RULES"
for existing in "${CURSOR_RULES}"/*; do
  if [[ -L "$existing" ]]; then
    target="$(readlink "$existing")"
    if [[ "$target" == ../../rules/* ]]; then
      rm -f "$existing"
    fi
  fi
done
for mdc in "${OUT_DIR}/rules"/*.mdc; do
  base="$(basename "$mdc")"
  ln -sfn "../../rules/${base}" "${CURSOR_RULES}/${base}"
done
shopt -u nullglob

# Update CHANGELOG when there are changes
CHANGELOG="${OUT_DIR}/CHANGELOG.md"
if [[ ${#CHANGED_ITEMS[@]} -gt 0 ]]; then
  CHANGED_LABEL="$(IFS=', '; echo "${CHANGED_ITEMS[*]}")"
  ENTRY="- ${DATE} — Sync from Melessa @ ${SHORT_SHA} — ${CHANGED_LABEL}"

  if [[ -f "$CHANGELOG" ]]; then
    # Insert after the header block (first two lines: title + blank)
    {
      head -n 2 "$CHANGELOG"
      echo "$ENTRY"
      tail -n +3 "$CHANGELOG"
    } > "${CHANGELOG}.tmp"
    mv "${CHANGELOG}.tmp" "$CHANGELOG"
  else
    cat > "$CHANGELOG" <<EOF
# Changelog

${ENTRY}
EOF
  fi
fi

echo "Sync complete. Changed: ${#CHANGED_ITEMS[@]} item(s)"
if [[ ${#CHANGED_ITEMS[@]} -gt 0 ]]; then
  printf '  - %s\n' "${CHANGED_ITEMS[@]}"
fi
