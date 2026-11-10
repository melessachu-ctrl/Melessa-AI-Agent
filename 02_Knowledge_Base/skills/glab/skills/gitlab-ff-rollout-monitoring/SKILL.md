---
name: gitlab-ff-rollout-monitoring
description: "Builds the Monitoring section for gitlab-org/gitlab feature flag rollout issues - Kibana, Grafana and Sentry links, checked against production data where the tools allow - from the merged MR that added the flag, and health-checks a rollout that is already in progress. Use when asked to write or improve the Events or Monitoring section of a rollout issue, find logs, dashboards or Sentry errors to watch during a feature flag rollout, prepare a feature flag rollout, or health-check the rollout metrics after enabling a flag (is it safe to continue the rollout, did anything break since the flag was enabled). Not for general Sentry triage (use gitlab-sentry-cli) or for creating or flipping the flag."
version: 0.3.0
category: Development Workflow
license: MIT
compatibility: opencode
argument-hint: <merged MR URL> [<MR URL>...] <rollout issue URL> [<rollout issue URL>...]
metadata:
  audience: developers
  workflow: gitlab
---

# gitlab-ff-rollout-monitoring

Turn merged MRs and their feature flag rollout issues into one `## Monitoring`
section per issue. It fills the issue's `## Monitoring` section (newer
template) or replaces its `Events` section (older template). Every link is
checked against production data, or clearly marked when it can't be.

**Read-only.** Never post, edit, or comment on an issue or MR unless the user asks.

## Modes

- **Draft or improve**: the issue has no Monitoring section yet, or the user
  wants the current one reviewed. Follow the [Workflow](#workflow).
- **Health check**: the flag is already on in gprd and the user wants to know
  if anything went wrong and if the rollout can continue. Follow
  [references/health-check.md](references/health-check.md).

If the flag is on in gprd and the user doesn't ask for a draft or review,
run the health check only, and offer to draft or review the section in one
line at the end. If the user asks for both, run the health check first, then
the review. Output the verdict and table first, then the revised section.

## Inputs

One or more MR URLs and rollout issue URLs (gitlab-org/gitlab). The rollout
issue alone is enough. One MR can add several flags, and some issues are
feature issues, not rollout issues. See [references/signals.md](references/signals.md)
for finding the MR, matching flags to issues, and finding the flag YAML.

## Prerequisites

- **Required:** `glab`, logged in to gitlab.com (see the [`glab` skill](../glab/SKILL.md)).
- **To check Kibana links:** `esquery` with `KIBANA_URL` set and an SSO session ([setup](../gitlab-noisy-neighbor-audit/references/kibana.md#access)).
- **To check Sentry links:** `curl` and a new-sentry.gitlab.net token (see [`gitlab-sentry-cli`](../gitlab-sentry-cli/SKILL.md)), used by [`scripts/sentry_issues.sh`](scripts/sentry_issues.sh).
- **Helpers:** `python3`. Searching dashboards for a metric needs a runbooks checkout.
- Run `command -v glab esquery curl python3` first. Without `glab`, stop. If
  `KIBANA_URL` is unset, run `export KIBANA_URL=https://log.gprd.gitlab.net`.
  Then always check access with
  `esquery count --index 'pubsub-rails-inf-gprd*' --query '{"range":{"@timestamp":{"gte":"now-5m"}}}'`.
  When a tool or that check fails, still build the links, mark them
  `unchecked: <reason>`, and tell the user what to set up.

## Gotchas

- **Kibana queries go through `esquery`** (CLI or `esquery mcp`). They take ES
  query DSL, not KQL, and have a short timeout. On `kibana session expired`,
  stop and ask the user to run `esquery login`. See [references/kibana.md](references/kibana.md).
- **Never guess Kibana data view IDs.** See [references/kibana.md](references/kibana.md#indices-and-data-view-ids).
- **`json.feature_flag_states` exists only in Rails logs**, not on Pipeline
  Logger entries, and the Flag evaluated count is a lower bound
  ([references/kibana.md](references/kibana.md#field-patterns)).
- **Flag states are logged only for current flags** (`milestone` or
  `log_state_changes`). Otherwise every flag-state query is 0 by design
  ([milestone rule](references/kibana.md#field-patterns)).
- **Flag states are sampled**, so flag-state counts are a lower bound. Count
  the new exception class by class alone ([why](references/kibana.md#field-patterns)).
- **`json.pipeline_persisted:true` doesn't mean the pipeline ran.** Count
  blocked pipelines by exception class or failure reason ([step 3](references/health-check.md#steps)).
- **Fields new in the MR** are not in the index until the first event. Report
  them as "not in the index yet", not as broken.
- **A new exception class doesn't always reach logs or Sentry.** CI chain steps
  often rescue it into a failure reason metric ([references/grafana.md](references/grafana.md#notes)).
- **Grafana links are unchecked** unless you can query Grafana ([references/grafana.md](references/grafana.md)).
  **Sentry events have no flag data**, so filter on the changed code ([references/sentry.md](references/sentry.md)).

## Workflow

1. **Read the change.** Have a subagent (or read directly, see rule 4) fetch
   each MR (description and diff) and rollout issue with `glab`, and return
   only the signals in [references/signals.md](references/signals.md). If the
   flag is already on in gprd, pick the mode again ([Modes](#modes)); when
   still drafting, offer a health check in one line at the top.
2. **Map signals to sources.** Every signal goes to at least one source:
   - logs, exceptions, durations → Kibana ([references/kibana.md](references/kibana.md))
   - Prometheus metrics, failure reasons → Grafana ([references/grafana.md](references/grafana.md))
   - new errors in the changed code, new tracked classes → Sentry ([references/sentry.md](references/sentry.md))
3. **Check with real data.** For each Kibana link, run a `count` or a small
   `search`. For each Sentry link, list the matching issues. For each
   threshold, find how close current traffic is (for example the 3-day max).
4. **Build the links** in the order from [references/output-format.md](references/output-format.md#link-order).
   Every link covers the last 24 hours. Kibana links go only to the side
   that runs the code ([references/kibana.md](references/kibana.md#indices-and-data-view-ids)).
5. **Draft the output** with the format in [references/output-format.md](references/output-format.md).
   Write short and plain. If the issue already has a Monitoring section,
   review it first ([references/output-format.md](references/output-format.md#improve-an-existing-section)).

## Rules

1. Every Kibana and Sentry link needs a real query result behind it. If it
   can't be checked, keep it, mark it `unchecked: <reason>`, and say why in
   the notes. Never guess what a link will show.
2. When a query times out, make the time range smaller or drop the
   aggregation. Don't send the same query again.
3. Rollout issues are public. The draft has links and code thresholds only:
   no counts, project, namespace or user names, or log message content.
   A health check report is for the user only, so it can have them; a
   public comment drafted from it can't.
4. Keep the main thread clean: send MR and issue reading to a subagent, and
   filter big tool output before reading it. If you can't start a subagent,
   read directly and filter with `python3` first.

Full worked example (MR 263899, seed timeout): [references/worked-example.md](references/worked-example.md).

## Contributing Improvements

Maintained in [`gitlab-org/ai/skills`](https://gitlab.com/gitlab-org/ai/skills).
If guidance here is wrong or outdated, confirm with the user and open an MR
with the fix.
