# Sentry

Sentry links are for **new errors the change could cause** during rollout
(for example a `NoMethodError` in the new code path). They are not for
tracking the old bug's symptom.

- Instance: `https://new-sentry.gitlab.net`, org `gitlab`, project `gitlabcom`
  (project ID `3`). For auth setup, see
  [`gitlab-sentry-cli`](../../gitlab-sentry-cli/references/CONFIGURATION.md).
- **Sentry events have no feature flag data** (no flag tags, no flag
  context). You can't filter on "flag on". Filter on the changed code instead.

## Link types

1. **Errors in the changed code:** one link per non-spec file that the MR
   changes **behind the flag**: `is:unresolved stack.filename:"<repo path>"`.
   Leave out files whose change isn't behind the flag (it's already live).
   Mention them in the notes instead. A change counts as behind the flag when
   what it does depends on the flag, even if the new line runs every time
   (for example a check that can only raise after the flag sets a deadline).
   If a file has changes both behind and not behind the flag, keep the link
   and list the change that isn't behind the flag in the notes.
   - If the flag turns on existing shared code (middleware, health
     indicators), its errors may not have the changed file in the stack.
     Also link the first file in that path that isn't in every stack.
   - Frontend files (`app/assets/javascripts/`) report to project
     `gitlabcom-clientside` (ID `4`). Frames there are relative to
     `app/assets/javascripts` (like `./ci/pipeline_details/foo.vue?9abf`), so
     use a wildcard: `stack.filename:*ci/pipeline_details/foo*` with
     `project=4`.
2. **New tracked classes:** `error.type:<Full::Class::Name>`, only when the
   class is sent with `track_exception` / `track_and_raise_exception`.
   `log_exception` and classes rescued into a chain `error(...)` never reach
   Sentry.

## Check the links

`stack.filename:` queries time out in `sentry-cli` (see the known problems in
[`gitlab-sentry-cli`](../../gitlab-sentry-cli/references/ISSUES_EVENTS.md)),
so use [`scripts/sentry_issues.sh`](../scripts/sentry_issues.sh). It calls
the API with `curl`, takes the token from `SENTRY_AUTH_TOKEN` or
`~/.sentryclirc` without printing it, always uses `statsPeriod=24h`, and
retries HTTP 429 and 500:

```sh
scripts/sentry_issues.sh 'is:unresolved stack.filename:"lib/gitlab/ci/pipeline/chain/build/associations.rb"'
scripts/sentry_issues.sh -p 4 'is:unresolved stack.filename:*ci/pipeline_details/foo*'
```

It prints one line per issue (`shortId id count firstSeen title`), with
`firstSeen` marked `(capped to 24h)`. Exit 0
means HTTP 200 (no lines: no issues), 2 means still throttled, 3 means
HTTP 500 twice, 1 is any other failure.

- These queries are slow. Use `statsPeriod=24h`, never longer: `2d` and
  `14d` time out or return HTTP 500. The script does this.
- For a health check, add `firstSeen:>2026-10-26T09:44:00` (the first gprd
  enable, explicit actors included) to the query. It is faster, and old high-volume issues (like a
  `Rack::Timeout` with thousands of events) don't hide new ones. It only
  shows issues with events in the last 24h, so for an older rollout an issue
  that stopped before then is not listed.
- Run Sentry calls one at a time. If the script exits 2, mark the link
  `unchecked: Sentry throttled`.
- If it exits 3 (HTTP 500 twice), run it again with `firstSeen:>` set to the
  first gprd enable time, and say in the notes that the list of matching
  issues is partial. If that fails too, mark the link
  `unchecked: Sentry HTTP 500`.
- If every changed-file query is empty, run one control query on a busy file
  in the same code path (for example `app/services/ci/create_pipeline_service.rb`)
  to confirm the filter works. Its results are not findings.
- For other API calls below, check the HTTP code before parsing and use
  `mktemp` for output files.

- `firstSeen` is cut to the `statsPeriod`. For the real first-seen and
  last-seen dates and the latest event's frames (with source `context`) in
  the changed files, run
  `scripts/sentry_issues.sh --details <short ID> <changed file>...`. It
  calls `.../issues/<id>/` and `.../issues/<id>/events/latest/`, and tries
  `/api/0/issues/<id>/events/latest/` once on HTTP 500. Without files it
  prints the in-app frames, innermost first. Those are often client code
  (Gitaly, HTTP), not the change.
- `error.type:<Class>` works with `sentry-cli` too. Don't search a class name
  as free text; queries with `::` return nothing.
- List issues that already match in the notes (short IDs), so a new issue
  during rollout is easy to see. Keep them out of the draft.

## Link format

```
https://new-sentry.gitlab.net/organizations/gitlab/issues/?project=3&query=<encoded query>&statsPeriod=24h
```

Encode the query: space → `%20`, `:` → `%3A`, `"` → `%22`, `/` → `%2F`.

Example:

```
https://new-sentry.gitlab.net/organizations/gitlab/issues/?project=3&query=is%3Aunresolved%20stack.filename%3A%22lib%2Fgitlab%2Fci%2Fpipeline%2Fchain%2Fbuild%2Fassociations.rb%22&statsPeriod=24h
```
