# Output format

## Contents

- Link order
- Template
- Improve an existing section
- Notes after each draft

## Link order

Use this order, and skip items that don't apply:

1. **Flag evaluated** (Rails only): `json.feature_flag_states:"<flag>:1"`.
   Keep it when the flag is checked in a Rails request and its state is
   logged (see the milestone rule in [kibana.md](kibana.md#field-patterns)).
   It is the only link that shows the flag is on. If the flag is checked only
   in Sidekiq, or its state is not logged, leave it out and say why in the
   notes. In the second case, suggest `log_state_changes: true`. Columns: `json.meta.caller_id,json.status`. Not `json.path`: it is
   long and full of IDs.
2. **New exception classes** from the MR, for Sidekiq and Rails, with the
   `json.extra.*` columns. Add the Sentry link next to them.
3. **Other exceptions while the flag is on**:
   `json.exception.feature_flag_states.keyword:"<flag>:1" and not json.exception.class.keyword:"<new class>"`.
   Leave out the `and not ...` part when the MR adds no logged exception class,
   and label the link "Exceptions while `<flag>` is on".
   Add `or json.extra.feature_flag_states.keyword:"<flag>:1"` only if some
   rows match that field alone ([how to check](kibana.md#example-queries)).
4. **Signals for the changed behavior**: durations near a threshold, new log
   messages, new failure reasons (Kibana and/or Grafana).
   - Threshold: use `>=` with a value between the 3-day max of real traffic
     and the default limit. If the logged value is measured differently from
     the checked one (for example raw bytes vs. JSON size), go lower and say
     why in a short line. When improving an existing section, keep a lower
     threshold if it has only a few hits a day close to the limit.
   - For a flag that enforces a limit on a logged value, add two links, both
     with `json.pipeline_persisted` as a column: `<field> >= <near limit>`
     (close to the limit) and `<field> > <limit>` (over the limit: with the
     flag off these pipelines were saved and ran; with the flag on they fail).
     Don't label `persisted:false` as "blocked" or `persisted:true` as "ran":
     a pipeline that fails on the limit is often still saved
     ([health check step 3](health-check.md#steps)). The blocked signal is the
     new exception class or failure reason. If a `log_when` limit covers the
     field, also add a baseline link at that limit.
   - If the changed methods have `logger.instrument` keys, add
     `json.<key>_duration_s.count` and `.sum` as columns on the duration link.
5. **Sentry**: one `stack.filename:` link per changed file behind the flag,
   plus `error.type:` for new tracked classes.

Rules for all links:

- Every link covers the **last 24 hours**: `now-24h` in Kibana and Grafana,
  `statsPeriod=24h` in Sentry. Check queries can use a longer range.
- Every Kibana log signal gets a link for **each side that can run the code**
  (Sidekiq, Rails, or both), even when one side has no data today. Pipeline
  creation runs in both. Worker-only code gets Sidekiq only, controller-only
  code Rails only; say so in the notes.
- Leave out the template's generic "Exceptions with <flag>:1" link (links 2
  and 3 already cover it) and the "Visualization Library" link.
- If a related flag uses a namespace actor (for example an override flag
  with a higher limit), add `json.meta.root_namespace` as a column to the
  new exception and duration links. Readers can then tell those namespaces
  apart without names in the public issue.
- Columns can show project data, because the link holds no data itself. Add
  `json.meta.project` and `json.meta.caller_id` to exception and threshold
  links. Only `json.path` is out (long, with IDs). The draft text itself has
  no names.
- For any pipeline creation observation (a duration or a size), add
  `json.pipeline_persisted` as a column, so a saved pipeline is easy to tell
  from a failed one.

## Template

One draft per rollout issue, inside a fenced `markdown` block. Use a
4-backtick fence if the draft has a code block inside.

````markdown
## Monitoring

**Kibana**

- [Flag evaluated (`<flag>:1`), Rails](<url>)
- [New `<Class>`, Sidekiq](<url>) / [Rails](<url>)
- [Other exceptions while `<flag>` is on, Sidekiq](<url>) / [Rails](<url>)
- [<signal>, e.g. seed step duration > 600s, Sidekiq](<url>) / [Rails](<url>)

**Grafana**

<one short line when a link needs it, e.g. "Watch for a step change in `config_error` after each rollout step.">

- [<panel title> (<dashboard title>)](<viewPanel url>)
- [`<metric>{reason="<value>"}` in Explore](<url>)

**Sentry**

- [Errors in `<changed file>`](<url>)
- [`<Class>`](<url>)
````

Leave out empty source headings. A short line under a heading is fine when
a link needs it (what to watch for, or why a threshold is lower), with no
production data. Don't add counts or other check results to the draft. Counts go
stale within hours and are production data in a public issue. Put what the
checks found in the notes instead.

## Improve an existing section

When the issue already has a Monitoring section:

1. Compare it with the link order and template above. List what is missing
   (often Grafana for a new failure reason, or Sentry for the changed files),
   what is noisy, and missing columns. Noisy means many hits a day far from
   the limit (for example saved pipelines well under a timeout), or a long
   time range that shows known cases. A few hits close to the limit is what
   the link is for. A threshold equal to a `log_when` limit is a baseline,
   not noise. Hits from override namespaces count against the override
   limit: say so in the notes and keep the link.
2. Keep links that are already fine as they are. Don't rewrite them only to
   match the template. `now-1d` is the same as `now-24h`; keep it.
   - Moving links into the link order is fine; keep their queries and labels.
   - Add a column the template asks for if it is missing. Drop a column only
     when it adds nothing (for example `json.feature_flag_states` on the Flag
     evaluated link, where every row matches).
   - Short explanation lines with no production data can stay.
3. Give a short list of the changes, then the full revised section in one
   fenced block, so the user can paste it.

## Notes after each draft

Add a few short bullets after each block, for the user only:

- which links have data now
- how close current traffic is to each threshold (for example the 3-day max)
- which Sentry issues already match (short IDs), so new ones stand out later
- which links fill in once the flag is on
- which fields aren't in the index yet
- what couldn't be checked (Grafana links, unless you queried Grafana)
