# Grafana (from the runbooks repo)

Links are built from the dashboard source in
[runbooks](https://gitlab.com/gitlab-com/runbooks), so they **can't be
checked against data** unless you can query Grafana yourself. Say that in the
notes bullets.

- Use a local runbooks checkout if you have one (`<runbooks>` below).
- If not, read files with
  `glab api "projects/gitlab-com%2Frunbooks/repository/files/<url-encoded path>/raw?ref=master"`
- Production Grafana: `https://dashboards.gitlab.net`
- gprd datasource UID: `mimir-gitlab-gprd`

## Find the dashboard for a metric

```sh
cd <runbooks>
grep -rn --include='*.jsonnet' --include='*.libsonnet' -E '<metric>' dashboards libsonnet metrics-catalog
```

`rg` may not be installed. Use `grep -rn`.

Dashboards built from shared libsonnet can build the query from parts, so
the metric name may not appear as one string in the source. No match does
not prove there is no dashboard; say so in the notes and fall back to an
Explore link.

## Dashboard UID from the file path

From `dashboards/grafana-tools.lib.sh` (`generate_dashboards_for_file`):

- `dashboards/<folder>/<name>.dashboard.jsonnet` → UID `<folder>-<name>`
  (the name is cut at the first dot)
- `*.shared.jsonnet` files make several dashboards with UID `<folder>-<key>`

## Link one panel, not a dashboard

```
https://dashboards.gitlab.net/d/<uid>?viewPanel=panel-<id>&var-environment=gprd&var-stage=main&from=now-24h&to=now
```

Panel IDs are set when the dashboard is built. `dashboards/generated` is
build output (gitignored), so it is not in the repo.

- If the panel source has a `stableId`, its ID is fixed
  (`libsonnet/stable-ids/stable-ids.libsonnet`):
  `python3 -c 'import hashlib,sys;print(1000+int(hashlib.md5(sys.argv[1].encode()).hexdigest()[:8],16))' '<stableId>'`
- Otherwise use the [Known CI panels](#known-ci-panels) table. For any other
  dashboard, use only the Explore link, or ask the user for the `viewPanel`
  ID from the panel URL.

## Known CI panels

Both panels are on the dashboard titled "Pipeline Observability".

| Metric | Dashboard UID | Panel ID | Panel |
|---|---|---|---|
| `gitlab_ci_pipeline_failure_reasons` / `pipelines_created_total` (leaves out `filtered_by_*` and `unknown_failure`) | `ci-orchestration-pipeline-observability` | 25 | Pipeline creation failure ratio |
| `gitlab_ci_pipeline_failure_reasons{reason=~"unknown_failure\|^$"}` | `ci-orchestration-pipeline-observability` | 42 | Pipeline processing failures |

`stage-groups-pipeline_execution` also has CI panels (Pipeline Failure
Reasons, creation duration, step durations), but their panel IDs aren't
known, so link the dashboard or use Explore.
`stage-groups-pipeline_authoring` only has the default template.

## Explore link for one label value

Dashboard panels group by all values. For a new label value (for example a
new failure reason), also add an Explore link that filters by it.

PromQL: `sum by (reason) (rate(gitlab_ci_pipeline_failure_reasons{env="gprd",reason="<value>"}[5m]))`

URL: `https://dashboards.gitlab.net/explore?schemaVersion=1&orgId=1&panes=<url-encoded JSON>`, with this JSON:

```json
{"a":{"datasource":"mimir-gitlab-gprd","queries":[{"refId":"A","expr":"<PromQL>","range":true,"datasource":{"type":"prometheus","uid":"mimir-gitlab-gprd"},"editorMode":"code"}],"range":{"from":"now-24h","to":"now"}}}
```

Encode it with something like:

```sh
python3 -c 'import json,sys,urllib.parse;print(urllib.parse.quote(json.dumps(json.loads(sys.argv[1]),separators=(",",":"))))' '<json>'
```

## Notes

- A new metric or label value has no data until the flag is on and the code
  path runs. Say so.
- A new exception class in a CI chain step is often rescued into
  `error(msg, failure_reason: :x)`, so it never reaches logs or Sentry. Then
  the signal is `gitlab_ci_pipeline_failure_reasons{reason="x"}`. Leave out
  the new-exception links and say why. If `x` already exists, tell the reader
  to watch for a step change.
- `gitlab_ci_pipeline_failure_reasons` goes up for unsaved pipelines too
  (`Chain::Helpers#error`), so it also counts failures that never reach the
  pipelines list.
- Check the metric name and labels in the MR diff (`Gitlab::Metrics.counter`
  etc.) before building the PromQL. Don't guess label names.
