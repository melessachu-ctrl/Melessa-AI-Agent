# Classifying and filing

## Contents

- [Read the program epic first](#read-the-program-epic-first)
- [Fallback classification](#fallback-classification)
  - [Fix risk and fix scope](#fix-risk-and-fix-scope)
- [Inventory rows](#inventory-rows)
- [Issue drafts](#issue-drafts)
- [Creating issues](#creating-issues)
- [Child tasks and the work item API](#child-tasks-and-the-work-item-api)
- [After filing](#after-filing)

## Read the program epic first

If the user named a program epic, read its description before you classify or
draft anything:

```shell
glab api "groups/<url-encoded group>/epics/<iid>" | jq -r '.description, (.labels | join(","))'
```

Take these from the epic and use them exactly. Where they differ from the rest
of this file, the epic wins:

- tier and decision definitions, and their label names, plus any risk or scope
  categories (these replace the fix risk and fix scope fallback below)
- phase or priority rules, including which items need sign-off before they are
  labelled
- issue title format, body template, required labels, parent epic and
  confidentiality
- where inventory rows live (often a confidential spreadsheet) and their
  columns or ID format
- dates, change locks, and the customer-communication process for new limits

If the program's issue template lacks the skill's sections ("What one actor
can do", "Controls checked", the AI footer), add them to it. Don't drop the
program's own sections.

If the epic says which items need a leader's sign-off before they get a label,
do not add that label. Draft a comment proposing the item on the team issue,
and tag the leader.

## Fallback classification

Use this when there is no program epic.

| Tier | Blast radius when one actor abuses the surface |
|---|---|
| A | All of GitLab.com: the primary database, shared Redis, Sidekiq shards everyone uses, or Rails capacity in general |
| B | A shared host, shard or Gitaly node, or many customers at once |
| C | Only the actor's own namespace |

Decision: `protect` (add or enforce a limit), `meter` (count and attribute
usage per namespace so it can be billed or capped), or `both`. An agentic
action that is cheap but unmetered is `meter`.

Rank Tier A first, then Tier B with a past incident, then the rest.

### Fix risk and fix scope

Tier rates the abuse. These two rate the *fix*, so a Tier A finding can have a
high-risk fix. Use the program's own values if it defines any (some programs
define their own risk levels and scope values, such as per-provider); use these
only as the fallback. Record the reason in one line; a bare label isn't enough.

| Fix risk | The fix |
|---|---|
| low | Small and well scoped, with no side effects for legitimate users |
| medium | Has acceptable side effects. The issue needs a note for future on-call engineers or SREs |
| high | Changes billing or metering, access to a provider or to GitLab, or breaks callers or existing customers' workflows (this includes a new limit that production traffic already exceeds) |

Decide risk from the production usage you gathered in
[kibana.md](kibana.md). A limit set below a legitimate actor's observed peak is
at least medium. If there's no usage data, say so and don't rate it low.

| Fix scope | Where the fix has to land |
|---|---|
| single | One component or one owner's code |
| cross-cutting | Several owners, providers, services or repos, or every caller of a shared helper |
| dependency | A third-party library or service that needs a patch, a wrapper or an upstream change |

Don't confuse fix scope with tier: tier is the blast radius of the abuse, scope
is how many places the fix touches.

## Inventory rows

Give the owner one row per finding, as TSV, in the column order the program
uses. If you can't see the program's sheet, use these fields:

```text
id  surface  surface_type  how_one_actor_drains_it  existing_controls  enforced_on_gitlab_com(yes|no|unknown)  survivable_threshold(proposed)  tier  decision  phase  evidence_level  evidence_links  tracking_issue
```

Use the program's ID format if its team issue gives one. Otherwise use
`NEW-<group>-<n>`.

Don't write to a shared spreadsheet yourself unless the user asks. Hand the
rows to the owner to paste.

## Issue drafts

Use the program's template if it has one. Otherwise:

```markdown
**Surface:** <endpoint, worker, field or tool> · **Surface type:** <type> · **Tier:** <A|B|C> · **Decision:** <protect|meter|both> · **Fix risk:** <low|medium|high> · **Fix scope:** <single|cross-cutting|dependency> · **Evidence:** <E2 traced | E3 reproduced>

## What one actor can do
<Plain words: who can do it, what they repeat, what everyone else notices.
For example: "Any signed-in user can ask for the full commit history of a
large project as many times as they like, and each request holds a database
connection for several seconds.">

## Evidence
- Code path: <permalinks at a commit SHA>
- Reproduction or measurement: <steps, numbers, plan link>
- Related incidents or alerts: <links>

## Controls checked
| Layer | Applies? | Why it doesn't stop this |
|---|---|---|

## Possible control (not a fix)
<One line, for example: "a per-user ApplicationRateLimiter key", or "emit a
billable event per tool call".>

## Fix risk
<Why low, medium or high. For medium or high, what on-call should know: who
could be affected, and how to tell the control is the cause.>

## Fix scope
<Why single, cross-cutting or dependency. For cross-cutting, name the owners,
providers, services or repos the fix touches. For dependency, name the library
or service and the patch, wrapper or upstream change needed.>

---
_Found and drafted with an AI agent using the `gitlab-noisy-neighbor-audit`
skill, and reviewed by @<user> before creation._
```

## Creating issues

- **Confidential, always**, in the project that owns the code (usually
  `gitlab-org/gitlab`). Each finding describes how to degrade GitLab.com.
- Labels: the program's labels if there is a program. Otherwise `type::bug`,
  `bug::performance` and the group label. Check that each label exists first.
- Search for duplicates before creating anything, across open and closed
  issues in the owning project and in `gitlab-com/gl-infra/production`, which
  holds both incidents and change requests. The search terms that find
  matches are class name, tool name, route, worker name and rate-limit key.
  Broad keywords like "rate limit" don't. If one exists, comment on
  it with the new evidence and suggest labels instead of filing again.
- Show the user every draft and wait for confirmation. Then create the issues
  with `glab api` and a JSON body (`--input <file> --header "Content-Type: application/json"`).
  Pass content as a file, not interpolated into the command.
- After creating them, post one comment on the team issue listing the new
  issues, and give the user the inventory rows.

## Child tasks and the work item API

The team owner may want findings as child work items (tasks) of the team issue
instead of standalone issues under the leader epic. Ask. Children of a
confidential issue must be confidential. Hand-offs to other teams stay
standalone issues in that team's area, linked from the team issue; a scoped
`group::` label allows one owner, so name a co-owner in the body when the fix
lives in another team's code.

Bulk creation works through `workItemCreate` with a JSON payload file:

```shell
glab api graphql --input payload.json -H "Content-Type: application/json"
```

with `{"query": "mutation($input: WorkItemCreateInput!) { workItemCreate(input: $input) { workItem { iid webUrl } errors } }", "variables": {"input": {...}}}`
and an input of `projectPath`, `workItemTypeId` (`gid://gitlab/WorkItems::Type/5`
is Task, `/1` Issue), `title`, `confidential`, `descriptionWidget: {description}`,
`labelsWidget: {labelIds}`, `assigneesWidget: {assigneeIds}` and
`hierarchyWidget: {parentId: "gid://gitlab/WorkItem/<id>"}`. Resolve label ids with
`project.labels(searchTerm:, includeAncestorGroups: true)` and match the title
exactly (some labels are capitalised). Schema introspection through `glab api
graphql` returns null; take field names from this list or from a failed call.

## After filing

- Post production usage ([kibana.md](kibana.md)) as one comment per task: the
  point first, numbers in a `<details>` block. Keep customer names inside the
  confidential task.
- When logs show callers the trace missed, edit only the surface list and the
  control paragraph of the task.
- Record where the raw query responses live; the owner needs them for the
  survivable-threshold column.
