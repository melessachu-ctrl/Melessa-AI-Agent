# Scoping: from team to owned code

## Contents

- [Team to feature categories](#team-to-feature-categories)
- [Feature categories to code in gitlab-org/gitlab](#feature-categories-to-code-in-gitlab-orggitlab)
- [Other repositories](#other-repositories)
- [Finding the team's program issue](#finding-the-teams-program-issue)

## Team to feature categories

Product groups, their feature categories and their labels live in
[`data/stages.yml`](https://gitlab.com/gitlab-com/www-gitlab-com/-/blob/master/data/stages.yml).
`<skill>/scripts/team-scope.sh` downloads it and prints one group. `<skill>` is
this skill's directory; use the absolute path, because the gitlab checkout has
its own unrelated `scripts/` directory.

```shell
<skill>/scripts/team-scope.sh "agent execution"      # key, name, label or category
STAGES_YML=./stages.yml <skill>/scripts/team-scope.sh code_review   # use a local copy
```

It needs `curl` and `ruby`. It also matches a feature category, such as
`team-scope.sh code_review_workflow`, and prints the group that lists it.
Stages with no `label:` field use `group::<name in lower case>`. Before you
apply a label, check that it exists:
`glab api "projects/gitlab-org%2Fgitlab/labels/<url-encoded label>"`.

If more than one group matches, ask the user which one. Don't guess.

**A category in `stages.yml` may not be the group's code.** Categories move
between groups and `stages.yml` lags; a category listed under the group can
map to code another group owns today (check `.gitlab/CODEOWNERS` and the spec
tags). Name it in the report as excluded or ask the user before including it.

**The category may be missing from `stages.yml`.** Code can keep using a
category that `stages.yml` has merged into another one, because
`config/feature_categories.yml` in the gitlab repo lags behind. If the script
finds nothing, check `config/feature_categories.yml` and the `[Category:…]`
sections of `.gitlab/CODEOWNERS`, then ask the user which group owns it. Use
the old name with `owned-paths.sh`, because that is what the code declares.

## Feature categories to code in gitlab-org/gitlab

Run from inside a `gitlab-org/gitlab` checkout, calling the script by its
skill path:

```shell
cd ~/gdk/gitlab   # or wherever the checkout is
<skill>/scripts/owned-paths.sh agent_tools duo_agent_platform > owned.tsv
```

Output is `<how>\t<category>\t<path>`:

| `how` | Meaning |
|---|---|
| `declared` | The source declares `feature_category :<cat>`: controllers, Grape API classes, Sidekiq workers, background migrations. These are entry points; start here. |
| `spec` | The source file mapped from a spec tagged `feature_category: :<cat>` on its top-level `describe`: services, finders, models, GraphQL resolvers and mutations. |
| `spec-partial` | A shared file, such as `app/models/group.rb`, where only some examples in its spec carry the tag. Only the methods those examples cover are yours. |
| `spec-only` | A tagged spec with no matching source path: request, feature and integration specs. Read them to find entry points, especially GraphQL operations. |

The script skips code no actor can trigger: batched background migrations,
RuboCop cops and migration specs. Gaps to cover by hand:

- **Files with no tagged spec.** Registries, base classes and dispatchers
  often have no spec of their own. Add your group's paths from
  `.gitlab/CODEOWNERS`, and read the whole directory where most files are
  yours.

- **Controllers and API classes shared across categories** declare
  per-action categories (`feature_category :x, [:action]`). The file shows up
  as `declared`, but only some of its actions are yours.
- **GraphQL.** Resolvers and mutations carry no category. Use `spec` and
  `spec-only` rows, plus `.gitlab/CODEOWNERS` entries for your group's paths.
- **Routes and Workhorse.** Some heavy paths (archives, LFS, uploads, Git
  HTTP) are served or accelerated by Workhorse. Check `workhorse/internal/upstream/routes.go`
  if your feature serves files.
- **Surfaces you expose but don't own.** Features that wrap other teams' code
  (an MCP server, an agent tool registry, a GraphQL facade) make that code
  reachable in new ways, for example by an agent in a loop. List everything
  your feature exposes, such as tool registries or route settings like
  `route_setting :mcp`, and audit each exposed path *as reached through your
  feature*. File findings in the owning team's code under that team's group
  label, and mention the exposing team. If you can't verify a path, hand it
  off as E1.
- **Cron jobs** are scheduled in `config/schedule.yml`, `ee/config/schedule.yml`
  and `ee/config/schedule_saas.yml`. Each one is a worker that may scan whole
  tables.

## Other repositories

`team-scope.sh` prints `gitlab_group` and any `triage_ops_config` project IDs.
These are often empty. If so, ask the user, or take repository links from the
team's program issue. Otherwise, list the group's projects with `glab api "groups/<url-encoded gitlab_group>/projects?include_subgroups=true&archived=false&per_page=100"`.
Not every project serves GitLab.com traffic. Ask the user which ones run in
production, for example AI Gateway, Duo Workflow Service, Gitaly, the
Kubernetes agent server or Runway services. For Go and Python services, the
same patterns apply. Look for request handlers with no per-actor limit, and
unbounded upstream calls such as LLM, Gitaly or Rails internal API calls,
made on behalf of one caller.

## Finding the team's program issue

Skip this section if the user gave no program epic. Programs usually give each
team one confidential team issue, often under a per-leader child epic. Find it
by listing the child epics' issues and matching the group label:

```shell
glab api "groups/gitlab-org/epics/<program epic iid>/epics?per_page=50" | jq -r '.[].iid'
glab api "groups/gitlab-org/epics/<leader epic iid>/issues?per_page=100" \
  | jq -r --arg l "group::<name>" '.[] | select(.labels | index($l)) | "\(.iid) \(.title)"'
```

The REST epics API is deprecated in favour of work items. If it stops
working, walk the hierarchy through the GraphQL work-item hierarchy widget
instead.

If no issue has the group's label, stop. Ask the user to get a team issue
from the program leader first.

The team issue's starting points list incidents, infradev, alerts and the
team's existing inventory rows. Every one of them is a candidate to verify.
If a team issue already lists a surface, update its row instead of adding a
new one.

Programs often keep the inventory rows in a spreadsheet the agent cannot open.
Ask for the team's pre-filled rows as a TSV export at this step; without them
you cannot dedupe or update rows, only add new ones.

`owned-paths.sh` finds code through declared categories and tagged specs, so
files whose spec carries no tag are missing (repositories, service helpers,
GraphQL mutations). For every directory where some files are owned, list the
siblings and read them too.
