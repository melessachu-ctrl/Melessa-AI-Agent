# Agent plan (Workplan) widget

The **agent_plan** widget (the "Workplan" in the UI) holds a coding agent's plan for a work item. Read and write it through `project.workItems(iid:)` (see [work-items.md](work-items.md)), selecting the `WorkItemWidgetAgentPlan` widget. EE, experiment-gated (GitLab 19.0+, `:workplan` feature flag); CE and older instances won't expose it.

**Read** -- capture the work item `id`; you need it to write back. Only one work item's `content` resolves per request (a server-side field-call cap), so fetch one at a time:

```bash
glab api graphql -f query='
{
  project(fullPath: "org/project") {
    workItems(first: 1, iid: "33") {
      nodes {
        id
        widgets { type ... on WorkItemWidgetAgentPlan { content } }
      }
    }
  }
}' | jq -r '.data.project.workItems.nodes[0].widgets[]
            | select(.type == "AGENT_PLAN") | .content'
```

`content` is `null` when no plan exists yet.

**Write** -- `workItemUpdate` with `agentPlanWidget` **replaces** the whole plan (no append/patch; fetch current content first if you want to extend it). Plans are large markdown full of backticks and `$`, so write the plan to a file and pass it via a variable -- see the **Message Escaping** section in `SKILL.md`. Never string-interpolate content into the query:

```bash
glab api graphql -f query='
mutation($id: WorkItemID!, $content: String!) {
  workItemUpdate(input: { id: $id, agentPlanWidget: { content: $content } }) {
    errors
    workItem { widgets { type ... on WorkItemWidgetAgentPlan { content } } }
  }
}' -f id="gid://gitlab/WorkItem/<n>" -f content="$(cat "$PLAN")"
```

Confirm `data.workItemUpdate.errors` is `[]`. The same `agentPlanWidget` input works on `workItemCreate` to seed a plan on a new work item. Reads work under `api` / `read_api` / `ai_workflows`; writes need `update_work_item`. Content limit ~128 KB.

The `gitlab-agent-plan` skill, if installed, wraps this with helper scripts.
