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
  if rsync -a --delete --dry-run "$src/" "$dst/" | grep -q .; then
    CHANGED_ITEMS+=("$skill")
  fi
  rsync -a --delete "$src/" "$dst/"
done < <(jq -r '.skills[]' "$MANIFEST")

# Sync rules
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
done < <(jq -r '.rules[]' "$MANIFEST")

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
