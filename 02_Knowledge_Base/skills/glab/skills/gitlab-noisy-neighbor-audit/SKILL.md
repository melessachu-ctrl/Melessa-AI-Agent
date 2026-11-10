---
name: gitlab-noisy-neighbor-audit
description: "Audit the code a GitLab product group owns for noisy-neighbor and performance risks (one user, bot, agent or token draining a shared GitLab.com resource; agentic usage that is not limited or metered), verify each finding, and draft confidential issues and inventory rows for the team. Use when asked to find performance problems in a team's code, do a noisy-neighbor or rate-limit audit, fill in a reliability or rate-limit inventory, find unthrottled endpoints, unbounded fan-out, expensive queries, actions that fill the database with records, or walks over large group or other hierarchies, or check whether agent traffic is limited and billable. Finds and files problems; does not fix them."
version: 0.3.0
license: MIT
category: Development Workflow
compatibility: opencode
metadata:
  audience: developers
  workflow: local
---

# GitLab noisy-neighbor audit

Find every place in a product group's code where **one actor (user, bot,
agent or token) can exhaust a resource that all of GitLab.com shares**, and
every agentic action that is neither limited nor metered. Verify each finding,
then draft issues. Other performance problems found along the way are reported
too, ranked below noisy-neighbor findings. **Do not fix anything**: the output
is evidence and issues, not MRs.

## Gotchas (read first)

- **Limits in code are often not limits in production.** A rate-limit key with
  a threshold of `0` means unlimited. Many Rack::Attack throttles are disabled
  by default. Users on an allowlist skip the limit, and a feature flag may be
  off. Record "enforced on GitLab.com" as `yes`, `no` or `unknown`. Never infer
  `yes` from code alone.
- **A per-user request cap does not protect an expensive request.** What
  matters is cost per request times allowed rate. A global throttle of
  thousands of requests per minute still lets one user run that many
  multi-second queries or fan-outs.
- **Check what the limit is keyed on.** A per-project or per-IP limit doesn't
  stop one user who creates many projects or rotates IPs. A per-token limit
  doesn't stop one user who mints many tokens.
- **GraphQL has no per-field `feature_category`.** `GraphqlController` is
  `not_owned`, so find a team's resolvers and mutations through spec metadata
  and CODEOWNERS ([references/scoping.md](references/scoping.md)).
- **Findings are a map for attackers.** Keep them in confidential issues and
  local files outside any repo, including subagent output. Never put them in
  public issues, MR descriptions, commit messages or Slack.
- **Never load-test GitLab.com or staging.** Reproduce locally (GDK) or on a
  Postgres.ai clone.

## Workflow

`<skill>` below is this skill's directory: call scripts by that absolute path,
never `scripts/…` relative to a checkout (gitlab has its own `scripts/`).
Emit `STEP <n>: <done | partial | blocked> (<counts>)` after each step. Keep
working notes in `~/.cache/gitlab-noisy-neighbor-audit/<group>/` so a run can
resume.

1. **Ask for the program epic.** Ask the user whether this audit is part of a
   company-wide reliability or rate-limit effort. If it is, ask for the epic's
   URL. That epic's description defines tiers, labels, templates and sign-off,
   and overrides this skill. Without one, use the fallback in
   [references/filing.md](references/filing.md).
2. **Scope the team.** Run `<skill>/scripts/team-scope.sh "<group>"` to get feature
   categories, the group label, and related projects from `stages.yml`. Find the
   team's program issue and read its starting points: incidents, infradev,
   alerts and existing rows. Those are known surfaces to confirm, not the whole
   list. Ask for the pre-filled inventory rows as a TSV export; the sheet is
   not reachable by agents.
3. **Map owned code.** From a `gitlab-org/gitlab` checkout, run
   `<skill>/scripts/owned-paths.sh <category>...`, then cover the team's other repos
   ([references/scoping.md](references/scoping.md)).
4. **Hunt.** Go surface type by surface type using
   [references/patterns.md](references/patterns.md): endpoints, GraphQL,
   background fan-out, retries, expensive queries and renders, record
   amplification and data growth, hierarchy traversal, Gitaly, long-lived
   connections, bypasses, limits that fail under load, agent actions and
   metering. First record the limits that apply to every request
   and the known issues. If you run subagents, one per surface type, give each
   one that context and have it return candidates, not conclusions.
5. **Verify.** Run a separate skeptical pass that tries to *disprove* each
   candidate, following [references/verification.md](references/verification.md).
   Assign evidence level E1, E2 or E3. Only E2 and E3 become issues. E1 goes in
   the report as "needs a human". Add production usage from Kibana
   ([references/kibana.md](references/kibana.md)): per-actor peaks set the
   survivable threshold and show whether the fix touches real traffic.
6. **Deduplicate** against existing issues, incidents, infradev and the team's
   inventory rows. If an issue already exists, link it and propose labels
   instead of filing a new one.
7. **Classify** each finding by tier, decision, phase, fix risk and fix scope,
   using the program's definitions or the fallback in
   [references/filing.md](references/filing.md). Tier says how bad the abuse
   is; fix risk says how dangerous the fix is. Rate them separately.
8. **Report, confirm, then file.** Show the user the ranked findings, the
   inventory rows and the issue drafts. Create nothing until they confirm.
   Then open confidential issues, link them from the team issue, and give back
   the inventory rows to paste.

## Output

- A ranked report: noisy-neighbor findings first, ordered by tier and then
  evidence level, then other performance findings, then E1 items needing a
  human, then surfaces checked and found protected (this shows coverage).
- One inventory row per finding, in the program's column order.
- Issue drafts that open with what one actor can do, in plain words, before
  the code cause. Each one names the controls checked and why they don't
  apply, and ends with the AI-disclosure footer.

## Contributing Improvements

This skill is maintained in [`gitlab-org/ai/skills`](https://gitlab.com/gitlab-org/ai/skills).
If you discover that any guidance here is **inaccurate or outdated** (e.g. a
command that no longer works, a wrong flag, an incorrect API behavior), confirm
with the user and open an MR against that repository with the fix. Keep changes
focused — one fix per MR.
