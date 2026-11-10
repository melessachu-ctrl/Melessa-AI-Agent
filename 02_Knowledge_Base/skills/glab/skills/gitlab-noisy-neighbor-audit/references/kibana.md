# Production usage from Kibana

Code shows what *can* happen. Logs show what happens today: requests per day,
per-actor peaks per minute, the anonymous share, the tail, and whether the
parameter a fix changes is used at all. Those numbers fill the survivable
threshold, settle the customer-impact item of the definition of done, and find
callers the code trace missed. Treat them as verification layer 9
([verification.md](verification.md#disprove-it-layers-to-check)).

## Contents

- [Access](#access)
- [Index and fields](#index-and-fields)
- [Gotchas](#gotchas)
- [Query templates](#query-templates)
- [Reading the results](#reading-the-results)

## Access

Use [`esquery`](https://gitlab.com/gitlab-com/gl-infra/esquery)
(`go install gitlab.com/gitlab-com/gl-infra/esquery@latest`). It sends queries
through Kibana's console proxy with the user's Kibana SSO session, read from
the browser's cookies; `export KIBANA_URL=https://log.gprd.gitlab.net`
(`nonprod-log.gitlab.net` for staging) is the only setup. If no browser
session exists, ask the user to run `esquery login`; do not open the browser
yourself. The repository ships its own skill (`skill/SKILL.md`) with the
subcommands; the ones this audit needs:

```shell
jq -c .query q.json | esquery search --index 'pubsub-rails-inf-gprd*' --aggs "$(jq -c .aggs q.json)"
esquery count  --index 'pubsub-rails-inf-gprd*' --query "$(jq -c .query q.json)"
esquery esql   --query 'FROM pubsub-rails-inf-gprd* | WHERE ... | STATS ... BY ...'
esquery fields --index 'pubsub-rails-inf-gprd*' --field 'json.db_*'       # confirm field names first
```

Save each template below as `q.json`; `--query` takes the clause inside
`"query":` (as a string or on stdin) and `--aggs` the `"aggs"` object as a
string. `esquery mcp` exposes the same operations as MCP tools.

Without esquery, give the user the templates as Dev Tools queries and ask for
each raw response saved to a file; parse the files with `jq`.

Production logs are RED data. Numbers that describe an unprotected surface go
into the confidential task as a comment, never into a public issue.

## Index and fields

GitLab.com Rails logs: `pubsub-rails-inf-gprd*` (staging `pubsub-rails-inf-gstg*`).
Every string field is `text` with a `.keyword` subfield; aggregations,
`terms`, `missing`, `cardinality`, `wildcard` and `prefix` need the `.keyword` form.

| Field | Meaning |
|---|---|
| `json.meta.caller_id.keyword` | Grape: `"<METHOD> <route.origin>"`, for example `POST /api/:version/projects/:id/<path>`. Rails: `Controller#action`. GraphQL: `graphql:<operation>`. |
| `json.meta.user.keyword` | Username; missing on anonymous requests, so `missing` counts them. |
| `json.meta.project.keyword`, `json.meta.remote_ip.keyword` | Project path, client IP. |
| `json.status`, `json.format.keyword` | Numeric status; `html`, `json`, `csv`. |
| `json.duration_s`, `json.cpu_s`, `json.mem_bytes` | Wall time, CPU, allocated bytes per request. |
| `json.db_main_count`, `json.db_main_replica_count` | Queries on the primary and on replicas. Reads show 0 on the first, so count N+1s on the second. |
| `json.db_duration_s` | Integer-truncated; 0 means under 1 s. |
| `json.params` | Array of `{key, value}`; values are strings, long or sensitive ones are `[FILTERED]` or truncated. Filter with `json.params.key:<name>`. |
| `json.correlation_id.keyword` | Joins a request with the events it logged. |
| `json.subcomponent.keyword: graphql_json` | GraphQL stream: `json.operation_name.keyword`, `json.used_fields.keyword` (array of `Type.field`), `json.duration_s`. |
| `json.message.keyword` in `application_json` | Events a feature logs with `Gitlab::AppLogger`; they carry `json.meta.*` and the correlation id, so you can count renders per request and per anonymous visitor. Retention is shorter than for request logs. |

## Gotchas

- `wildcard` on caller ids runs across thousands of shards and takes tens of
  seconds; a `terms` list of exact caller ids runs in a few. Collect the ids
  with one wide query over a short range, then use exact lists.
- `hits.total.value` stops at 10,000 (`"relation": "gte"`); use aggregation `doc_count`.
- `too_many_buckets_exception`: shorten the range or widen `fixed_interval`.
- Dev Tools renders long strings as truncated `"""..."""`, so a response with
  `top_hits` is not valid JSON. Read it; do not parse it.
- Kibana's own request timeout is short; keep each query to one purpose and
  one week at most.

## Query templates

Replace `<CALLER_ID>` with exact caller ids. All queries use `"size": 0` and
`GET pubsub-rails-inf-gprd*/_search`.

**Stats per endpoint** (7 d): count, p95/p99/max, replica queries, status
split, anonymous share, top users and projects.

```json
{ "size": 0,
  "query": { "bool": { "filter": [
    { "range": { "@timestamp": { "gte": "now-7d" } } },
    { "terms": { "json.meta.caller_id.keyword": ["<CALLER_ID>", "<CALLER_ID>"] } } ] } },
  "aggs": { "endpoint": { "terms": { "field": "json.meta.caller_id.keyword", "size": 40 },
    "aggs": {
      "duration_s":   { "percentiles": { "field": "json.duration_s", "percents": [50, 95, 99] } },
      "duration_max": { "max": { "field": "json.duration_s" } },
      "replica_queries": { "percentiles": { "field": "json.db_main_replica_count", "percents": [95, 99] } },
      "mem_p95":      { "percentiles": { "field": "json.mem_bytes", "percents": [95] } },
      "status":       { "terms": { "field": "json.status", "size": 6 } },
      "anonymous":    { "missing": { "field": "json.meta.user.keyword" } },
      "users":        { "terms": { "field": "json.meta.user.keyword", "size": 5 } },
      "projects":     { "terms": { "field": "json.meta.project.keyword", "size": 5 } },
      "with_param":   { "filter": { "term": { "json.params.key": "<PARAM>" } } } } } } }
```

**Per-actor peak per minute** (1 d; the survivable-threshold input):

```json
{ "size": 0,
  "query": { "bool": { "filter": [
    { "range": { "@timestamp": { "gte": "now-1d" } } },
    { "terms": { "json.meta.caller_id.keyword": ["<CALLER_ID>"] } } ] } },
  "aggs": { "endpoint": { "terms": { "field": "json.meta.caller_id.keyword", "size": 40 },
    "aggs": { "users": { "terms": { "field": "json.meta.user.keyword", "size": 3, "missing": "(anonymous)" },
      "aggs": {
        "per_minute":      { "date_histogram": { "field": "@timestamp", "fixed_interval": "1m", "min_doc_count": 1 } },
        "peak_per_minute": { "max_bucket": { "buckets_path": "per_minute>_count" } },
        "distinct_ips":    { "cardinality": { "field": "json.meta.remote_ip.keyword" } } } } } } } }
```

**Slowest requests with their params** (1 d; read, do not parse):

```json
{ "size": 0,
  "query": { "bool": { "filter": [
    { "range": { "@timestamp": { "gte": "now-1d" } } },
    { "terms": { "json.meta.caller_id.keyword": ["<CALLER_ID>"] } } ] } },
  "aggs": { "endpoint": { "terms": { "field": "json.meta.caller_id.keyword", "size": 10 },
    "aggs": { "slowest": { "top_hits": { "size": 2, "sort": [ { "json.duration_s": "desc" } ],
      "_source": ["json.duration_s", "json.db_main_replica_count", "json.mem_bytes", "json.meta.project", "json.meta.user", "json.params", "json.status"] } } } } } }
```

**GraphQL operations that touch a field** (7 d):

```json
{ "size": 0,
  "query": { "bool": { "filter": [
    { "range": { "@timestamp": { "gte": "now-7d" } } },
    { "term":  { "json.subcomponent.keyword": "graphql_json" } },
    { "terms": { "json.used_fields.keyword": ["<Type.field>", "<Type.field>"] } } ] } },
  "aggs": { "operation": { "terms": { "field": "json.operation_name.keyword", "size": 20 },
    "aggs": {
      "duration_s": { "percentiles": { "field": "json.duration_s", "percents": [50, 95, 99] } },
      "anonymous":  { "missing": { "field": "json.meta.user.keyword" } },
      "users":      { "terms": { "field": "json.meta.user.keyword", "size": 5 } } } } } }
```

**Feature log events** (`Gitlab::AppLogger` messages; renders per day, per
caller, per request, anonymous share):

```json
{ "size": 0,
  "query": { "bool": { "filter": [
    { "range": { "@timestamp": { "gte": "now-7d" } } },
    { "terms": { "json.message.keyword": ["<EVENT_A>", "<EVENT_B>"] } } ] } },
  "aggs": {
    "event":     { "terms": { "field": "json.message.keyword", "size": 10 } },
    "per_day":   { "date_histogram": { "field": "@timestamp", "fixed_interval": "1d" } },
    "caller":    { "terms": { "field": "json.meta.caller_id.keyword", "size": 10 } },
    "anonymous": { "missing": { "field": "json.meta.user.keyword" } },
    "projects":  { "terms": { "field": "json.meta.project.keyword", "size": 5 } },
    "per_request": { "terms": { "field": "json.correlation_id.keyword", "size": 5 } } } }
```

## Reading the results

- **Survivable threshold.** The highest legitimate per-actor peak per minute
  is the floor for any per-user request cap. When that peak sits near the
  global throttle, a request cap cannot be the control; bound the cost per
  request instead (item caps, pagination, preloads, scoped queries) and keep
  rate caps as a second layer above the observed peaks.
- **Customer impact.** `with_param` at zero, or a nested GraphQL shape used a
  handful of times a week, means the fix breaks no observed traffic. Say so in
  the issue.
- **Missed callers.** Event callers you did not trace (other controllers,
  streaming endpoints, notes and discussions pages) go into the surface list.
- **The tail.** A `max` near the rack timeout (60 s) or the statement timeout,
  or a p99 far above the p95, is E3 evidence that the finding already happens.
  Status 500s on the path are bugs to file alongside.
- **Anonymous share.** A high `missing` count on a web page means crawlers
  reach it; anonymous findings then have real reach, and the per-IP throttle
  is the only control.
