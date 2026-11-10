# Signals to collect (workflow step 1)

Have the subagent that reads each MR and rollout issue return only these:

- flag names, types, actors, and `rollout_issue_url` (ops and override flags
  often have none; note it, don't ask)
- new exception classes and messages
- new log messages and keys
- `Gitlab::ErrorTracking.log_exception` / `track_exception` extras
- new failure reasons or enums
- metrics (name, type, label values)
- instrument keys and `Gitlab::Ci::Pipeline::Logger` observations, new ones
  and existing ones inside the changed methods (for example
  `pipeline_seed_build_inclusion` in `Seed::Build#included?`)
- the thresholds the change adds (timeouts, limits) and their values. If a
  related flag changes a limit (for example an override flag), record both
  values and the actor of each flag. Pick link thresholds against the
  default limit
- the non-spec files changed, split into "behind the flag" and "not behind
  the flag"
- where `Feature.enabled?` runs (Rails request, Sidekiq worker or
  middleware, or frontend through `push_frontend_feature_flag`), and the
  flag YAML's `milestone` and `log_state_changes` (see the milestone rule in
  [kibana.md](kibana.md#field-patterns))
- other flags or settings the new code path needs (for example an
  indicator's ops flag), and their gprd state. If one is off, say at the top
  that the links stay empty until it is on
- for a frontend flag: the backend endpoints the new JS calls
  (controller#action) and any rate limits on them. Link them in Rails by
  `json.meta.caller_id`, with `json.duration_s` and `json.status`; these
  requests carry no flag state
- for a worker behavior change (for example `defer_on_database_health_signal`
  or a concurrency limit): the Sidekiq job fields (`json.job_status`,
  `json.job_deferred_by`, `json.deferred_count`) and counters like
  `sidekiq_jobs_skipped_total`
- the issue's `What could go wrong?` section and its `## Monitoring` (newer
  template) or `Events` (older template) section, with links
- the gprd state changes from cogbot notes ("Feature flag ... set to ..."),
  with UTC times

Read code at `master` without a local checkout:

```sh
glab api "projects/gitlab-org%2Fgitlab/repository/files/<url-encoded path>/raw?ref=master"
```

Read issue notes with the API. `glab issue view --comments` can hide the
cogbot notes, and `glab api --paginate` joins JSON arrays (`][`), which breaks
`json.load`:

```sh
glab api "projects/gitlab-org%2Fgitlab/issues/<iid>/notes?per_page=100&sort=asc"
```

One MR can add several flags, each with its own rollout issue. Match flag to
issue with `rollout_issue_url` in `config/feature_flags/**/<flag>.yml`. An
issue that matches `feature_issue_url` is the feature or bug issue, not a
rollout issue: say so in one line and skip it. If an issue matches no flag,
say so and ask.

Take the flag YAML path from the MR's file list (`config/feature_flags/<type>/<flag>.yml`),
not by guessing the type folder. With only the issue, find the MR first with
`issues/<iid>/related_merge_requests` (it also lists MRs from other projects;
keep only `gitlab-org/gitlab`). The MR's file list is the `new_path` of each
entry in:

```sh
glab api "projects/gitlab-org%2Fgitlab/merge_requests/<iid>/diffs?per_page=100"
```

If no related MR adds the YAML (older flags often have the adding MR
unlinked), try each type folder on master and use the YAML's
`introduced_by_url` as the MR. Don't list the whole `config/feature_flags`
tree: it has thousands of files.

```sh
for d in config ee%2Fconfig; do
  for t in beta ops wip gitlab_com_derisk experiment worker development; do
    glab api "projects/gitlab-org%2Fgitlab/repository/files/$d%2Ffeature_flags%2F$t%2F<flag>.yml/raw?ref=master" 2>/dev/null && break 2
  done
done
```

Also read the related MRs that change the `Feature.enabled?` call for the
flag, because they can change the actor.
