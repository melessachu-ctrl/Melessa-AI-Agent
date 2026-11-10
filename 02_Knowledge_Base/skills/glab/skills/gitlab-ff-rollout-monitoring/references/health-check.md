# Health check

Check a rollout that is already on in gprd: did anything go wrong since the
flag was enabled, and can the rollout continue? Input is the rollout issue
URL. Find the MR from the issue or the flag YAML.

## Contents

- Steps
- Re-run
- Verdict
- Report template

## Steps

1. **Rollout timeline.** Have a subagent (or read directly, see rule 4 in
   [SKILL.md](../SKILL.md#rules)) read the issue notes and return the gprd
   state changes with UTC times: cogbot notes ("Feature flag ... set to
   ...") and the linked `gitlab-com/gl-infra/feature-flag-log` issues (read
   notes as in [signals.md](signals.md)). The check window starts at the
   **last gprd state change**, not `now-24h`. Run `date -u` to get "now".
   - If that change is under 2 hours old, also check the previous window:
     from the **first gprd enable** (explicit actors included) to the last
     change. It can have several states (for example explicit projects, then
     1%). Say the current window has little data.
   - Cogbot notes say "scoped to project" but not which projects. Read the
     feature-flag-log issue
     (`glab api projects/gitlab-com%2Fgl-infra%2Ffeature-flag-log/issues/<iid>`).
     Its "Feature flag scopes" table lists only the scopes of that one
     change (it is empty for a percentage step). The current actors are in
     `gates[key=actors]` in the "Feature flag state" JSON. Explicit actors
     stay on after a percentage step, so the window has both.
   - Actors show as IDs (`Project:<id>`, `Group:<id>`). Resolve them with
     `glab api projects/<id>` or `groups/<id>`. If that fails (private), use
     the names from the planning comment and say they weren't confirmed.
   - For a related flag (an override or ops flag), check that it was really
     set, not only planned in a comment. Ops flags often have no rollout
     issue, so no cogbot notes: search
     `glab api "projects/gitlab-com%2Fgl-infra%2Ffeature-flag-log/issues?search=<flag>"`.
     Read them newest first; the latest has the actors. A set, then a
     delete, then a new set is normal.
2. **Reuse the issue's links.** If the issue has a Monitoring section, turn
   each Kibana link's KQL into ES query DSL. Derive signals from the MR only
   for what the section doesn't cover (see [signals.md](signals.md)). Each
   check uses one of two windows:
   - **Since the first gprd enable**: the new exception class, blocked
     pipelines (step 3) and threshold maxes (step 5). A failure while only
     explicit actors were on still counts. If that is more than a day ago,
     split the query by day ([timeouts](kibana.md#calling-esquery)).
   - **Current window** (plus the previous window when step 1 needs it):
     Flag evaluated and other exceptions (step 4).
   - If the notes name test projects (for example in a verification
     comment), leave them out of every query
     ([snippet](kibana.md#example-queries)).
   - Explicit actors are not test projects unless the notes say so. If an
     actor's name looks like a test project but no note says so, keep it in,
     list it in the report, and ask the user. If you run as a subagent and
     can't ask, keep it in, list it, and continue.
3. **Make sure a zero means something.**
   - First check that the flag's state is logged at all (milestone rule in
     [kibana.md](kibana.md#field-patterns)). If not, every flag-state query is
     0 by design: say so, and in step 4 match exceptions on the changed files
     in the backtrace instead. Rows that match show the code is deployed.
   - Flag evaluated > 0, or exception rows with the flag state, show the code
     is deployed. A 0 doesn't prove much: the flag may be checked only on a
     narrow path. If the notes have a
     verification run, run each query once without the test project
     exclusion. The test row shows that the query and the deploy work.
   - Read the code at `master` and confirm the new exception is logged
     (`log_exception` before `error(...)`). If it is only rescued into
     `error(msg, failure_reason: :x)`, no log appears: the signal is
     `gitlab_ci_pipeline_failure_reasons{reason="x"}` in Grafana.
   - `json.pipeline_persisted` doesn't tell blocked from passed. A failed
     pipeline is saved when its failure reason can be saved and the caller
     passes `save_on_errors: true` (push and schedule pipelines). API, web
     and GraphQL pipelines are never saved on failure. So a blocked pipeline
     can be `persisted:true` or `false`. Count blocked pipelines by the new
     exception class, or by the failure reason metric when the error is only
     rescued. Use `json.pipeline_persisted` over `<field> >= <limit>`
     ([ES|QL](kibana.md#example-queries)) only to see how many pipelines over
     the limit were saved.
   - **Proxy for a rescued error.** When the error is only rescued and you
     can't query Grafana, Pipeline Logger `<field> >= <limit>` with
     `json.pipeline_persisted:false` is a partial signal, if both hold:
     the step records `<field>` before it runs the limit check (read the
     code), and a verification row (a test project over the limit) shows up
     in the query. The logger entry itself is always written (`ensure` in
     `CreatePipelineService#execute`). It counts only pipelines that aren't
     saved (API, web, GraphQL), so it is a lower bound. Compare it with the
     same query for the same length of time before the first gprd enable.
4. **Sort the other exceptions while the flag is on.** The new exception
   class is counted on its own, by `json.exception.class.keyword` alone: its
   rows don't always have the flag's state ([sampling](kibana.md#field-patterns)).
   For the other exceptions, match both flag-state
   fields ([query](kibana.md#example-queries)).
   - At a high rollout percentage there are too many rows to read. Start
     with counts by class ([ES|QL](kibana.md#example-queries)), and count the
     same classes without the flag filter. Flag states are sampled, so
     compare each class's share of the flag-on rows with its share of all
     rows, not raw counts. Pull backtraces only for classes that appear only
     with the flag on, or have a clearly bigger share there. Every class must be accounted for: related, or unrelated
     with a reason.
   - `search` the rows to read with
     `--source-include '@timestamp,json.exception.class,json.meta.caller_id,json.exception.backtrace'`
     and keep only the frames under `lib/`, `app/`, `ee/lib/` and `ee/app/`
     (filter with `python3` before reading; backtraces are large). Also grep
     the full backtrace for the changed file paths: a row with only gem
     frames is external.
   - Related means a frame on a line the MR changed behind the flag, or in
     code called from that line. A frame in a changed method but on an
     unchanged line doesn't count. Neither does an entry point that is on
     every pipeline creation stack (`create_pipeline_service.rb` `execute`,
     `chain/sequence.rb`).
   - `master` can have newer code, so compare the frame's source line (Sentry
     frame `context`) with the `+` lines of the diff, not line numbers.
   - List the rest as unrelated with a short reason (for example an external
     service, or a timeout that fires long before the new limit). See the
     [worked example](worked-example.md#health-check-2026-10-27).
5. **Thresholds** (durations, sizes, counts). Compare the max since the
   first gprd enable ([ES|QL](kibana.md#example-queries)) with the default
   limit and with any override limit. With an override flag,
   group by `json.meta.root_namespace` and give each namespace the limit
   that applies to it (default or override). Pipeline Logger entries have
   no flag state, so this can't tell if the flag was on for those
   pipelines; say so.
6. **Close to or over a time limit: one config or the platform?** Only for
   time-based limits (durations, timeouts); a size or count doesn't change
   when the platform is slow. For each value close to the limit or over it,
   outside override namespaces:
   - Count slow steps per hour across all namespaces over the same window
     ([ES|QL](kibana.md#example-queries)). Many namespaces slow in the same
     hours point to a platform-wide event.
   - Check the same project's values before the rollout. A project that
     normally takes seconds and hit the limit once points to the platform.
   - Look for production incidents in that window:
     `glab api "projects/gitlab-com%2Fgl-infra%2Fproduction/issues?labels=incident&created_after=<start>&created_before=<end>"`.
     An incident that started earlier and was still open counts too
     (`state=opened`, or `updated_after=<start>`).
7. **Newer code on master.** Find later commits that touch the files behind
   the flag:
   `glab api "projects/gitlab-org%2Fgitlab/repository/commits?ref_name=master&since=<first gprd enable>&path=<file>"`
   (or `git log --since=<first gprd enable> origin/master -- <files>` in a
   checkout). Get each commit's MR with
   `glab api "projects/gitlab-org%2Fgitlab/repository/commits/<sha>/merge_requests"`.
   It can also list open MRs whose branch has the commit; use the one with
   `state: merged`.
   - Read only the MR's hunks in the files behind the flag, and say if they
     change how the flagged code behaves (for example when the new check
     runs, or what it counts). A rename or an unrelated method nearby
     doesn't.
   - For each MR that does, say if it is deployed to gprd
     (`workflow::production` label), if it has its own flag, and whether
     that flag is on.
8. **Sentry.** For each changed file behind the flag, list issues with
   `firstSeen` after the first gprd enable (see [sentry.md](sentry.md)). Mark
   each one related (a frame in the new code) or not (for example an
   infrastructure error). Sentry queries cover only the
   last 24h; if the first gprd enable is about 24h ago or more, say that
   early issues can be missing. The script's `firstSeen` is capped to 24h;
   use `--details <short ID>` for the real dates and the frames.
9. **Baseline (only if a count looks high).** Count the same exception
   classes for the same length of time before the rollout. A rise that
   follows the rollout matters more than the absolute number.
10. **Grafana.** If you can't query Grafana, list the failure reason and
    panel links as not checked.

## Re-run

When the user asks for a check again after an earlier one in the same
session or issue, use the previous check time as the cutoff: `firstSeen:>`
in Sentry, and the start of a "new since last check" column in the table.
Report only what changed since then. Steps 1 and 3 can reuse the earlier
results unless the flag state changed. Run step 7 again with
`since=<last check>`: new MRs can land on master at any time.

## Verdict

One line, one of:

- **Continue**: no related errors, values under the limits that apply. If
  the flag is already `true` in gprd, write `fully rolled out, no related
  errors` instead. Removing the flag is the owner's call; link the removal
  MR if one exists. If the last change is under 2 hours old (as in step 1), base the verdict on
  the previous window and write `continue (recheck at <UTC time>)`, with the
  time about 2 hours after the last change.
  If an earlier window had a Hold-type event (for example the limit hit
  during a platform slowdown) and there is no next step, write `fully
  rolled out, <event>: owner decides`, with the rollback command.
- **Hold**: something can't be explained yet (an unknown exception with a
  frame in the changed code, a value close to the limit outside override
  namespaces, a related flag that wasn't set). Say what to check next.
  Also Hold when the limit worked as designed but a platform-wide slowdown
  set it off (step 6): say that the owner decides if this is acceptable
  (pause, or raise the limit), and include the rollback command.
- **Roll back**: related errors or failures that hit users (new timeouts or
  failures outside the expected cases, not explained by a platform-wide
  event). Name the command for the user to
  run; never run it yourself: `/chatops gitlab run feature set <flag> false`.

If the only direct signal is a Grafana metric (the exception is never
logged) and you couldn't check it, say so in the verdict line and ask the
user to look before the next step. This can go together with a recheck
time in the same line. The `persisted:false` proxy (step 3) is a lower
bound, so it doesn't replace the Grafana check: Continue is fine, but the
verdict line still says Grafana wasn't checked.

## Report template

The report is for the user only, so counts and names are fine. Draft a public
comment only when the user asks, and keep it to links and verdict, no counts
or names (rule 3 in [SKILL.md](../SKILL.md#rules)).

Drop rows that don't apply (for example no related flag). With a previous
window, give both: `previous <a> / <b>, current <c> / <d>`. On a re-run, add
`new since <last check time>` to each row that changed.

```markdown
**Verdict: continue (recheck at 10:30 UTC).** <one-line reason>. Grafana `<metric>` not checked; look before the next step.

Window: <last gprd state change, UTC> → now (<state, e.g. 1% of actors>; <duration>)
Previous window: <first gprd enable> → <last change> (<states, e.g. explicit projects, then 1%>), if checked

| Check | Result |
|---|---|
| New exception (`<Class>`), Sidekiq / Rails | 0 / 0, or: not logged (rescued into `<reason>`) |
| Blocked (`<Class>` or `<metric>{reason="<x>"}`; each can be `persisted:true` or `false`), Sidekiq / Rails | <n> / <n> |
| Blocked proxy (`<field>` ≥ <limit>, `persisted:false`; lower bound), Sidekiq / Rails | <n> / <n>, before enable <n> / <n>; verification row seen: yes / no |
| Over the limit (`<field>` ≥ <value>), by `persisted` | <n> saved / <n> not saved |
| Near the limit: platform or one config | <one project> / <many namespaces, incident link> |
| Newer MRs on the files behind the flag | <!iid>: <changes behavior or not> (deployed, flag `<flag>` on/off) |
| Flag evaluated (Rails, lower bound) | <n> |
| Related flag `<flag>` set | yes / no / not seen |
| Other exceptions with the flag on, Sidekiq / Rails | <n> / <n>, none with a frame in the changed files |
| <duration or size> ≥ <value>, by namespace | `<ns1>`: <n>, max <value> / limit <override>; `<ns2>`: <n>, max <value> / limit <default> |
| Sentry, changed files | new since rollout: <short IDs> (<related or not>) |
| Grafana `<metric>{reason="<x>"}` | not checked |

- <what each "other exception" is, in a few words>
- <what couldn't be checked and why>
```
