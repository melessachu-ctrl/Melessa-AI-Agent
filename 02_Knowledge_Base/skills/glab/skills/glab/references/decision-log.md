# Decision Log widget

The **decision_log** widget records decisions on a work item: a question, optional options, and a resolution with rationale. GraphQL only; `glab work-items` has no decision subcommands. EE, experiment-gated (feature flag plus an `ai_workflows` licence), Issue and Task based types only. Rollout status: gitlab-org/gitlab work item 633878.

> **Schema-derived:** the mutations and a populated read were not run against a live instance. Treat the examples as unverified and check `errors` on every call.

**Check availability first.** If no widget has `type == "DECISION_LOG"`, report "Decision Log not available here"; don't fall back to comments. Use `question`; `title` is deprecated.

**Read** -- `decisions` resolves for only one work item per query. `states` takes `ACTIVE | RESOLVED | ARCHIVED`; there is no `count` field:

```bash
glab api graphql -f query='
{
  project(fullPath: "org/project") {
    workItems(first: 1, iid: "33") {
      nodes {
        id
        widgets {
          type
          ... on WorkItemWidgetDecisionLog {
            decisions(states: [ACTIVE, RESOLVED]) {
              nodes {
                id question description state resolutionRationale resolvedAt
                options { nodes { id content description recommended selected } }
              }
            }
          }
        }
      }
    }
  }
}' | jq '.data.project.workItems.nodes[0].widgets[] | select(.type == "DECISION_LOG")'
```

**Create** -- `options` (max 5, each `{content, description, recommended}`) and `resolution` (`{decision, rationale}`, creates an already-resolved decision) are mutually exclusive. Pass free text as variables, never interpolated; `-F` with `jq` sends the options list as a typed variable:

```bash
glab api graphql -f query='
mutation($workItemId: WorkItemID!, $question: String!, $options: [WorkItemDecisionOptionInput!]) {
  workItemDecisionCreate(input: { workItemId: $workItemId, question: $question, options: $options }) {
    errors decision { id options { nodes { id content } } }
  }
}' -f workItemId="gid://gitlab/WorkItem/<n>" -f question="Which approach?" \
   -F options="$(jq -nc --arg a "Option A" --arg b "Option B" '[{content:$a, recommended:true}, {content:$b}]')"
```

**Resolve** -- `selectedOptionIds` (option GIDs) and `selectedOptionContent` (free text) are mutually exclusive. Resolving an already-resolved decision returns an error:

```bash
glab api graphql -f query='
mutation($id: WorkItemsDecisionID!, $option: WorkItemsDecisionOptionID!, $why: String) {
  workItemDecisionResolve(input: { id: $id, selectedOptionIds: [$option], resolutionRationale: $why }) {
    errors decision { state resolvedAt }
  }
}' -f id="<decision id from a read>" -f option="<option id from a read>" -f why="Reason"
```

Copy both IDs from a read; do not construct them.

Other mutations take `input: { id }` (type `WorkItemsDecisionID`): `workItemDecisionUpdate` (also accepts `question`, `description`), `workItemDecisionArchive`, `workItemDecisionDelete`. Each returns `decision` and `errors`. Update `options` are `WorkItemDecisionOptionUpdateInput` (`{id!, content, description, selected}`, no `recommended`, capped at 6) and are mutually exclusive with `selectedOptionContent`. Prefer `workItemDecisionArchive`; Delete is irreversible. Writes need a token that can update the work item.
