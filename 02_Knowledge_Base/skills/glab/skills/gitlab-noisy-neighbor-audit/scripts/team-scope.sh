#!/usr/bin/env bash
# Print a product group's feature categories, label and projects from stages.yml.
#
# Usage: team-scope.sh <group key, name, label or feature category>
#   team-scope.sh agent_execution
#   team-scope.sh "group::agent execution"
#   team-scope.sh agent_tools
# Env: STAGES_YML=<path> reads a local copy instead of downloading.
# Requires: ruby, curl (unless STAGES_YML is set).
# Exit: 0 one or more matches, 1 no match, 2 usage error.
set -Eeuo pipefail

STAGES_URL="https://gitlab.com/gitlab-com/www-gitlab-com/-/raw/master/data/stages.yml"

if [[ $# -ne 1 || -z "$1" ]]; then
  echo "usage: $(basename "$0") <group key, name, label or feature category>" >&2
  exit 2
fi

src="${STAGES_YML:-}"
if [[ -z "$src" ]]; then
  src=$(mktemp)
  trap 'rm -f "$src"' EXIT
  curl -fsSL "$STAGES_URL" -o "$src"
fi

ruby -ryaml -e '
  norm = ->(s) { s.to_s.downcase.sub(/\Agroup::/, "").gsub(/[\s-]+/, "_") }
  query = norm.(ARGV[1])
  data = YAML.safe_load(File.read(ARGV[0]), aliases: true)

  matches = []
  data.fetch("stages").each do |stage_key, stage|
    (stage["groups"] || {}).each do |group_key, group|
      label = group["label"] || "group::#{group["name"].to_s.downcase}"
      names = [group_key, group["name"], label] + (group["categories"] || [])
      if names.any? { |v| norm.(v) == query }
        matches << [stage_key, group_key, group, label]
      end
    end
  end

  if matches.empty?
    warn "no group or category matches #{ARGV[1].inspect}; a category the code " \
      "still uses may have been merged in stages.yml (check config/feature_categories.yml " \
      "and .gitlab/CODEOWNERS)"
    exit 1
  end

  matches.each do |stage_key, group_key, group, label|
    projects = group.dig("triage_ops_config", "default_labeling", "projects") || []
    puts "stage: #{stage_key}"
    puts "group: #{group_key} (#{group["name"]})"
    puts "label: #{label}"
    puts "gitlab_group: #{group["gitlab_group"]}"
    puts "categories: #{(group["categories"] || []).join(" ")}"
    puts "triage_project_ids: #{projects.join(" ")}"
    puts
  end
' "$src" "$1"
