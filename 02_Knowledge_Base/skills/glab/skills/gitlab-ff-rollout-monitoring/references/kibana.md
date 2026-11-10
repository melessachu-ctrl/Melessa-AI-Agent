# Kibana (esquery)

## Contents

- Calling esquery
- Indices and data view IDs
- Field patterns
- Example queries
- Discover URL format

## Calling esquery

Use [`esquery`](https://gitlab.com/gitlab-com/gl-infra/esquery). Install and
access are described in
[gitlab-noisy-neighbor-audit's Kibana reference](../../gitlab-noisy-neighbor-audit/references/kibana.md#access).
In short: `export KIBANA_URL=https://log.gprd.gitlab.net`, and it reads your
Kibana SSO session from the browser.

```sh
esquery count  --index 'pubsub-sidekiq-inf-gprd*' --query '<ES query DSL JSON>'
esquery search --index 'pubsub-sidekiq-inf-gprd*' --query '<JSON>' --size 3 --source-include 'json.meta.project,json.exception.class' --output source
esquery esql   --query 'FROM pubsub-sidekiq-inf-gprd* | WHERE ... | STATS ...'
esquery fields --index 'pubsub-sidekiq-inf-gprd*' --field 'json.pipeline_step_*seed*'
```

`esquery mcp` exposes the same operations as MCP tools (`count`, `search`,
`esql`, `list_fields`, `list_indices`, `export`) with the same parameters.

- `kibana session expired...` → stop and ask the user to run `esquery login`.
  Don't retry.
- Kibana times out after about 10s. Run one or two queries at a time. Use
  `now-24h` for exceptions and `now-3d` for maxes and thresholds. 7d with
  aggregations times out. For a longer window (for example a health check
  since the first gprd enable), run one query per day or less and combine
  the results.
- Always single-quote index patterns, also in loops. zsh globs an unquoted
  `pubsub-sidekiq-inf-gprd*` and fails with `no matches found`.
- Always narrow field lists with `--field '<wildcard>'`. The full list for
  rails is ~780KB. Through MCP, `list_fields` has no filter, so filter the
  output before reading it.

## Indices and data view IDs

| Source | Index pattern (esquery) | Data view ID (Discover URL) |
|---|---|---|
| Rails | `pubsub-rails-inf-gprd*` | `7092c4e2-4eb5-46f2-8305-a7da2edad090` |
| Sidekiq | `pubsub-sidekiq-inf-gprd*` | `AWNABDRwNDuQHTm2tH6l` |

Give each log signal a link for each side that runs the code: pipeline
creation runs in both (API and trigger pipelines in Rails, most others in
Sidekiq), workers only in Sidekiq, controllers only in Rails.

esquery can't read Kibana data views. Never guess an ID. For any other index,
look up `indexPattern` in `metrics-catalog/index_catalog.libsonnet` in runbooks:

```sh
# with a local runbooks checkout:
grep -n -B2 -A6 '<index name>' <runbooks>/metrics-catalog/index_catalog.libsonnet
# without one:
glab api "projects/gitlab-com%2Frunbooks/repository/files/metrics-catalog%2Findex_catalog.libsonnet/raw?ref=master"
```

## Field patterns

| Signal | Field |
|---|---|
| Flag evaluated (Rails only) | `json.feature_flag_states` (e.g. `"<flag>:1"`) |
| Flag on at exception time (the only flag fields in Sidekiq, so Sidekiq durations can't be filtered by flag state) | `json.exception.feature_flag_states`, `json.extra.feature_flag_states` |
| Exception class / message | `json.exception.class.keyword`, `json.exception.message` |
| `log_exception` extras | `json.extra.<key>` |
| Log message | `json.message` (exact: `json.message.keyword`) |
| Sidekiq worker | `json.class.keyword` |
| Pipeline Logger chain step | `json.pipeline_step_<chain_class_snake>_duration_s` |
| Pipeline Logger instrument | `json.<instrument_key>_duration_s.{count,max,sum}` |
| Correlation | `json.correlation_id`, `json.meta.project`, `json.meta.root_namespace` |

- `<chain_class_snake>` is the full class name in snake case, for example
  `Gitlab::Ci::Pipeline::Chain::Seed` → `gitlab_ci_pipeline_chain_seed`.
- Use `.keyword` for exact matches on text fields.
- Fields that are new in the MR are missing from `list_fields` until the first
  event. Report them as "not in the index yet". `esquery fields` prints
  nothing (or only the parent `json` row) for a missing field.
- `Ci::CreatePipelineService` writes one pipeline creation log entry only when
  a `log_when` condition is true (slow, big, or a new MR condition). Any
  `*_duration_s` of 3s or more is enough, so the entry is common (hundreds of
  thousands a day); its count is not the number of rare cases. Every
  observation is a top-level `json.<key>` field on that entry, so the field
  can be in the index already from other conditions. The entry has
  `json.pipeline_persisted`, `json.pipeline_source` and `json.meta.caller_id`,
  but **not** the pipeline error message, and **no** `json.feature_flag_states`
  (not even in Rails). To tie it to a request with the flag on, match
  `json.correlation_id` with the Flag evaluated rows.
- `json.feature_flag_states` is not on every request that evaluates the
  flag. Treat the Flag evaluated count as a lower bound, never as proof of
  zero traffic. 0 is common even when the path ran (for example API
  requests from explicit actors). Read the code before `Feature.enabled?`
  for early returns (like `return if variables.empty?`) and say when the
  flag is checked only on a narrow path. Exception rows with
  `json.exception.feature_flag_states` also show the flag was evaluated,
  in Sidekiq too.
- Flag states are logged only when `Feature::Definition.log_states?` is
  true: the flag YAML's `milestone` is the running version or later
  (`glab api "projects/gitlab-org%2Fgitlab/repository/files/VERSION/raw?ref=master"`),
  or the YAML has `log_state_changes: true`. If not, every
  `feature_flag_states` field stays empty for that flag. Match exceptions on
  the changed file in the backtrace instead:
  `{"match_phrase":{"json.exception.backtrace":"<repo path of changed file>"}}`.
- `log_states?` also checks the `feature_flag_state_logs` ops flag on every
  `Feature.enabled?` call. In gprd that flag can be on for a percentage of
  time (check
  `glab api "projects/gitlab-com%2Fgl-infra%2Ffeature-flag-log/issues?search=feature_flag_state_logs"`),
  so each flag's state is logged only on some calls, at random. One row can
  have `<override flag>:0` and miss `<flag>:1` even though `<flag>` was on.
  Every flag-state count is a lower bound, and a query for the new exception
  class must not depend on a flag-state field.

## Example queries

`count` and `search` take **Elasticsearch query DSL** JSON, not a KQL
string. KQL is only for the Discover URLs. They have no time parameter, so
put the time range in a `range` filter on `@timestamp`. Through MCP, `query`
must be an object; a string fails with
`validating /properties/query: ... want "object"`.

Count new exceptions (24h):

```sh
esquery count --index 'pubsub-sidekiq-inf-gprd*' --query '{"bool":{"filter":[
  {"range":{"@timestamp":{"gte":"now-24h"}}},
  {"term":{"json.exception.class.keyword":"Gitlab::Ci::Pipeline::Seed::Context::TimeoutError"}}]}}'
```

Other exceptions while the flag is on (both flag-state fields; drop the
`must_not` when the MR adds no logged exception class):

```sh
esquery count --index 'pubsub-sidekiq-inf-gprd*' --query '{"bool":{
  "filter":[{"range":{"@timestamp":{"gte":"now-24h"}}}],
  "should":[{"term":{"json.exception.feature_flag_states.keyword":"<flag>:1"}},
            {"term":{"json.extra.feature_flag_states.keyword":"<flag>:1"}}],
  "minimum_should_match":1,
  "must_not":[{"term":{"json.exception.class.keyword":"<new class>"}}]}}'
```

To see if any rows match only `json.extra.feature_flag_states`, run it again
without that `should` term and compare the counts. To leave out a test
project, add `{"term":{"json.meta.project.keyword":"<group/project>"}}` to
`must_not`.

Flag evaluated (Rails, 24h): `{"match_phrase":{"json.feature_flag_states":"<flag>:1"}}`.
Threshold sample: `search` with `--size 3`, `--source-include` and
`{"range":{"<field>":{"gte":<value>}}}`.

Max of a duration (3d) with ES|QL:

```
FROM pubsub-sidekiq-inf-gprd*
| WHERE @timestamp > NOW() - 3 days AND json.pipeline_step_gitlab_ci_pipeline_chain_seed_duration_s IS NOT NULL
| STATS max = MAX(json.pipeline_step_gitlab_ci_pipeline_chain_seed_duration_s), n = COUNT(*)
| LIMIT 1
```

Without a `LIMIT`, ES|QL prints `No limit defined, adding default limit of [1000]`.

Max since a fixed time (health check), per namespace and outside override
namespaces:

```
FROM pubsub-sidekiq-inf-gprd*
| WHERE @timestamp >= "2026-10-26T09:44:00Z" AND <field> IS NOT NULL
| STATS max = MAX(<field>), n = COUNT(*) BY json.meta.root_namespace
| SORT max DESC | LIMIT 10

FROM pubsub-sidekiq-inf-gprd*
| WHERE @timestamp >= "2026-10-26T09:44:00Z" AND <field> IS NOT NULL
  AND (NOT json.meta.root_namespace IN ("<ns1>", "<ns2>") OR json.meta.root_namespace IS NULL)
| STATS max = MAX(<field>), n = COUNT(*) | LIMIT 1
```

- `NOT ... IN` and `!=` drop rows where the field is null, so add
  `OR <field> IS NULL` as above.
- Check that a max doesn't come from a test project named in the notes (for
  example a verification run). Leave it out with
  `AND (json.meta.project != "<group/project>" OR json.meta.project IS NULL)`
  and report both values.
- Pipelines over a limit (health check step 3):
  `WHERE <field> >= <limit> | STATS n = COUNT(*) BY json.pipeline_persisted`.
  This doesn't count blocked pipelines: a failed pipeline is often saved.
- Platform or one config (health check step 6): slow steps per hour
  across all namespaces. Use a slow value well under the limit (for
  example 60s for a 900s timeout) so normal hours show a baseline:

  ```
  FROM pubsub-sidekiq-inf-gprd*
  | WHERE @timestamp >= "<start>" AND @timestamp < "<end>" AND <field> >= <slow value>
  | EVAL hour = DATE_TRUNC(1 hour, @timestamp)
  | STATS n = COUNT(*), namespaces = COUNT_DISTINCT(json.meta.root_namespace), max = MAX(<field>) BY hour
  | SORT hour | LIMIT 48
  ```

- Other exceptions by class with the flag on (health check step 4).
  `MV_EXPAND` the multi-valued flag field first, then filter it:

  ```
  FROM pubsub-sidekiq-inf-gprd*
  | WHERE @timestamp >= "<start>" AND json.exception.feature_flag_states.keyword IS NOT NULL
  | MV_EXPAND json.exception.feature_flag_states.keyword
  | WHERE json.exception.feature_flag_states.keyword == "<flag>:1"
  | STATS n = COUNT(*) BY json.exception.class.keyword
  | SORT n DESC | LIMIT 20
  ```

  The same classes without the flag filter:
  `WHERE @timestamp >= "<start>" AND json.exception.class.keyword IN ("<class>", ...) | STATS n = COUNT(*) BY json.exception.class.keyword`.
  This covers `json.exception.feature_flag_states` only; check
  `json.extra.feature_flag_states` the same way if the DSL query found
  rows there.

Small sample with `search`: `--size` 2-3 and `--source-include` only the
columns you plan to put in the link. `--output source` prints one JSON
object per line (NDJSON), not an array.

ES|QL traps:

- `json.exception.feature_flag_states.keyword` is multi-valued. `==` on it
  fails with `single-value function encountered multi-value` and matches
  nothing. `MV_EXPAND` it first (example above), or use a DSL `term`
  filter with `search`.
- `first` and `last` are reserved: `STATS first = MIN(@timestamp)` fails with
  `no viable alternative at input 'first='`. Use other names, like `t_first`.

## Discover URL format

```
https://log.gprd.gitlab.net/app/discover#/?_g=(time:(from:now-24h,to:now))&_a=(index:'<DATA_VIEW_ID>',query:(language:kuery,query:'<KQL>'),columns:!(<col1>,<col2>),sort:!(!(json.time,desc)))
```

- Encode the KQL: `"` → `%22`, space → `%20`, `>` → `%3E`, `>=` → `%3E=`, `<` → `%3C`. Leave `:` alone.
- Rison escaping inside `'...'`: `'` → `!'`, `!` → `!!`. Prefer double quotes in KQL.
- Time: `now-24h` for every link. Check queries can use a longer range
  (`now-3d`), but the links stay at 24 hours.
- Columns: always add `json.exception.class`/`json.message` and the
  `json.extra.*` or duration fields the reader needs. Columns that aren't in
  the index yet are fine in the URL.

Example (seed duration over 600s, Sidekiq, 24h):

```
https://log.gprd.gitlab.net/app/discover#/?_g=(time:(from:now-24h,to:now))&_a=(index:'AWNABDRwNDuQHTm2tH6l',query:(language:kuery,query:'json.pipeline_step_gitlab_ci_pipeline_chain_seed_duration_s%20%3E%20600'),columns:!(json.meta.project,json.pipeline_step_gitlab_ci_pipeline_chain_seed_duration_s),sort:!(!(json.time,desc)))
```
