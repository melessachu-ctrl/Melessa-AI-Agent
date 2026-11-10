#!/usr/bin/env bash
# Offline tests for team-scope.sh and owned-paths.sh.
#
# team-scope.sh reads a fixture through STAGES_YML, so no download happens.
# owned-paths.sh runs against a throwaway git repo built here.
#
# Usage: bash skills/gitlab-noisy-neighbor-audit/tests/test_scripts.sh
set -uo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
scripts="$here/../scripts"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

pass=0; fail=0
ok()  { pass=$((pass+1)); printf '  ok   %s\n' "$1"; }
bad() { fail=$((fail+1)); printf '  FAIL %s\n     %s\n' "$1" "$2"; }
has() { # has <name> <fixed string> <text>
  if grep -qF -- "$2" <<<"$3"; then ok "$1"; else bad "$1" "missing [$2] in: $3"; fi
}
hasnt() {
  if grep -qF -- "$2" <<<"$3"; then bad "$1" "unexpected [$2] in: $3"; else ok "$1"; fi
}

echo "team-scope.sh"
export STAGES_YML="$here/stages.fixture.yml"

out=$("$scripts/team-scope.sh" project_management)
has "matches by key" "group: project_management (Project Management)" "$out"
has "prints categories" "categories: team_planning service_desk" "$out"
has "prints triage projects" "triage_project_ids: 278964" "$out"

out=$("$scripts/team-scope.sh" "group::project management")
has "matches by label" "stage: plan" "$out"

out=$("$scripts/team-scope.sh" "Agent Execution")
has "derives missing label from name" "label: group::agent execution" "$out"

out=$("$scripts/team-scope.sh" service_desk)
has "matches by feature category" "group: project_management (Project Management)" "$out"

"$scripts/team-scope.sh" no_such_group >/dev/null 2>&1
rc=$?
if [[ $rc -eq 1 ]]; then ok "no match exits 1"; else bad "no match exits 1" "rc=$rc"; fi

"$scripts/team-scope.sh" >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then ok "missing argument exits 2"; else bad "missing argument exits 2" "rc=$rc"; fi

echo "owned-paths.sh"
repo="$work/repo"
mkdir -p "$repo/app/workers" "$repo/app/models" "$repo/lib/api" "$repo/app/services" \
  "$repo/spec/models" "$repo/spec/requests/api" "$repo/spec/features" "$repo/spec/services"
cat >"$repo/app/workers/plan_worker.rb" <<'EOF'
class PlanWorker
  feature_category :team_planning
end
EOF
cat >"$repo/app/workers/other_worker.rb" <<'EOF'
class OtherWorker
  feature_category :team_planning_extra
end
EOF
echo 'class Board; end' >"$repo/app/models/board.rb"
echo 'class Group; end' >"$repo/app/models/group.rb"
echo 'module API; class Boards; end; end' >"$repo/lib/api/boards.rb"
echo 'class CreateService; end' >"$repo/app/services/create_service.rb"
echo 'class Label; end' >"$repo/app/models/label.rb"
echo 'RSpec.describe Board, feature_category: :team_planning do; end' >"$repo/spec/models/board_spec.rb"
printf 'RSpec.describe Group do\n  it "x", feature_category: :team_planning do; end\nend\n' \
  >"$repo/spec/models/group_spec.rb"
printf 'RSpec.describe Label, :aggregate_failures,\n  feature_category: :team_planning do\nend\n' \
  >"$repo/spec/models/label_spec.rb"
echo 'RSpec.describe API::Boards, feature_category: :team_planning do; end' \
  >"$repo/spec/requests/api/boards_spec.rb"
echo 'RSpec.describe "Boards", feature_category: :team_planning do; end' \
  >"$repo/spec/features/boards_spec.rb"
echo 'RSpec.describe CreateService, feature_category: :service_desk do; end' \
  >"$repo/spec/services/create_service_spec.rb"
mkdir -p "$repo/ee/spec/services/ee" "$repo/lib/gitlab/background_migration" "$repo/spec/migrations"
echo 'RSpec.describe CreateService, feature_category: :team_planning do; end' \
  >"$repo/ee/spec/services/ee/create_service_spec.rb"
printf 'class BackfillBoards\n  feature_category :team_planning\nend\n' \
  >"$repo/lib/gitlab/background_migration/backfill_boards.rb"
echo 'RSpec.describe AddBoards, feature_category: :team_planning do; end' \
  >"$repo/spec/migrations/add_boards_spec.rb"
git -C "$repo" init -q
git -C "$repo" add -A

out=$(cd "$repo" && "$scripts/owned-paths.sh" team_planning)
has "finds declared worker" "$(printf 'declared\tteam_planning\tapp/workers/plan_worker.rb')" "$out"
hasnt "ignores longer category name" "other_worker.rb" "$out"
has "maps model spec to source" "$(printf 'spec\tteam_planning\tapp/models/board.rb')" "$out"
has "reads a tag on a wrapped describe line" "$(printf 'spec\tteam_planning\tapp/models/label.rb')" "$out"
has "maps request spec to lib/api" "$(printf 'spec\tteam_planning\tlib/api/boards.rb')" "$out"
has "marks example-level tag as partial" "$(printf 'spec-partial\tteam_planning\tapp/models/group.rb')" "$out"
has "keeps unmapped spec" "$(printf 'spec-only\tteam_planning\tspec/features/boards_spec.rb')" "$out"
has "maps EE spec of CE code to CE source" "$(printf 'spec\tteam_planning\tapp/services/create_service.rb')" "$out"
hasnt "drops background migrations" "background_migration" "$out"
hasnt "drops migration specs" "spec/migrations" "$out"

out=$(cd "$repo" && "$scripts/owned-paths.sh" service_desk)
hasnt "excludes other categories" "board" "$out"

out=$(cd "$repo" && "$scripts/owned-paths.sh" no_such_category)
rc=$?
if [[ $rc -eq 0 && -z "$out" ]]; then ok "unknown category prints nothing"; else bad "unknown category prints nothing" "rc=$rc out=$out"; fi

out=$(cd "$repo" && "$scripts/owned-paths.sh" team_planning service_desk)
has "accepts several categories" "$(printf 'spec\tservice_desk\tapp/services/create_service.rb')" "$out"

(cd "$repo" && "$scripts/owned-paths.sh" 'bad;category' >/dev/null 2>&1)
rc=$?
if [[ $rc -eq 2 ]]; then ok "rejects invalid category"; else bad "rejects invalid category" "rc=$rc"; fi

echo
echo "$pass passed, $fail failed"
[[ $fail -eq 0 ]]
