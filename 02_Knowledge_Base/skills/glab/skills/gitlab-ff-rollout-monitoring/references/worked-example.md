# Worked example: pipeline seed timeout

- MR: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263899
- Rollout issue: https://gitlab.com/gitlab-org/gitlab/-/work_items/635123

The numbers below are a snapshot from the dates given. Always run the
queries again; never copy them.

## What step 1 found

- Flags: `ci_pipeline_seed_timeout` (beta, project actor),
  `ci_pipeline_seed_timeout_override` (ops, root namespace actor).
- New exception: `Gitlab::Ci::Pipeline::Seed::Context::TimeoutError`, logged
  with extras `pipeline_source`, `job_candidates_count`,
  `evaluated_job_candidates_count`.
- New failure reason: `seed_timeout`.
- Threshold: 900s seed timeout.
- Duration field: `json.pipeline_step_gitlab_ci_pipeline_chain_seed_duration_s`.

## What step 3 found (2026-10-26)

- Longest seed step over 3 days: 745s in Sidekiq, 33s in Rails, below the
  900s timeout.
- Flag evaluated 31 times in Rails in 24h (on for some projects).
- `TimeoutError` and the `json.extra.job_candidates_count` fields: not in the
  index yet (no pipeline has timed out).
- 4 other Sidekiq exceptions while the flag was on, all unrelated classes.
  Class names stay out of the draft (public issue).

## Draft

````markdown
## Monitoring

**Kibana**

- [Flag evaluated (`ci_pipeline_seed_timeout:1`), Rails](https://log.gprd.gitlab.net/app/discover#/?_g=(time:(from:now-24h,to:now))&_a=(index:'7092c4e2-4eb5-46f2-8305-a7da2edad090',query:(language:kuery,query:'json.feature_flag_states:%22ci_pipeline_seed_timeout:1%22'),columns:!(json.meta.caller_id,json.status),sort:!(!(json.time,desc))))
- [`Seed::Context::TimeoutError`, Sidekiq](https://log.gprd.gitlab.net/app/discover#/?_g=(time:(from:now-24h,to:now))&_a=(index:'AWNABDRwNDuQHTm2tH6l',query:(language:kuery,query:'json.exception.class.keyword:%22Gitlab::Ci::Pipeline::Seed::Context::TimeoutError%22'),columns:!(json.meta.project,json.meta.root_namespace,json.extra.pipeline_source,json.extra.job_candidates_count,json.extra.evaluated_job_candidates_count),sort:!(!(json.time,desc)))) / [Rails](https://log.gprd.gitlab.net/app/discover#/?_g=(time:(from:now-24h,to:now))&_a=(index:'7092c4e2-4eb5-46f2-8305-a7da2edad090',query:(language:kuery,query:'json.exception.class.keyword:%22Gitlab::Ci::Pipeline::Seed::Context::TimeoutError%22'),columns:!(json.meta.project,json.meta.root_namespace,json.extra.pipeline_source,json.extra.job_candidates_count,json.extra.evaluated_job_candidates_count),sort:!(!(json.time,desc))))
- [Other exceptions while the flag is on, Sidekiq](https://log.gprd.gitlab.net/app/discover#/?_g=(time:(from:now-24h,to:now))&_a=(index:'AWNABDRwNDuQHTm2tH6l',query:(language:kuery,query:'json.exception.feature_flag_states.keyword:%22ci_pipeline_seed_timeout:1%22%20and%20not%20json.exception.class.keyword:%22Gitlab::Ci::Pipeline::Seed::Context::TimeoutError%22'),columns:!(json.exception.class,json.exception.message),sort:!(!(json.time,desc)))) / [Rails](https://log.gprd.gitlab.net/app/discover#/?_g=(time:(from:now-24h,to:now))&_a=(index:'7092c4e2-4eb5-46f2-8305-a7da2edad090',query:(language:kuery,query:'json.exception.feature_flag_states.keyword:%22ci_pipeline_seed_timeout:1%22%20and%20not%20json.exception.class.keyword:%22Gitlab::Ci::Pipeline::Seed::Context::TimeoutError%22'),columns:!(json.exception.class,json.exception.message),sort:!(!(json.time,desc))))
- [Seed step over 600s, Sidekiq](https://log.gprd.gitlab.net/app/discover#/?_g=(time:(from:now-24h,to:now))&_a=(index:'AWNABDRwNDuQHTm2tH6l',query:(language:kuery,query:'json.pipeline_step_gitlab_ci_pipeline_chain_seed_duration_s%20%3E%20600'),columns:!(json.meta.project,json.meta.root_namespace,json.pipeline_persisted,json.pipeline_step_gitlab_ci_pipeline_chain_seed_duration_s),sort:!(!(json.time,desc)))) / [Rails](https://log.gprd.gitlab.net/app/discover#/?_g=(time:(from:now-24h,to:now))&_a=(index:'7092c4e2-4eb5-46f2-8305-a7da2edad090',query:(language:kuery,query:'json.pipeline_step_gitlab_ci_pipeline_chain_seed_duration_s%20%3E%20600'),columns:!(json.meta.project,json.meta.root_namespace,json.pipeline_persisted,json.pipeline_step_gitlab_ci_pipeline_chain_seed_duration_s),sort:!(!(json.time,desc))))

**Grafana**

- [Pipeline creation failure ratio (ci-orchestration: Pipeline Observability)](https://dashboards.gitlab.net/d/ci-orchestration-pipeline-observability?viewPanel=panel-25&var-environment=gprd&var-stage=main&from=now-24h&to=now)
- [`gitlab_ci_pipeline_failure_reasons{reason="seed_timeout"}` in Explore](https://dashboards.gitlab.net/explore?schemaVersion=1&orgId=1&panes=%7B%22a%22%3A%7B%22datasource%22%3A%22mimir-gitlab-gprd%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22sum%20by%20%28reason%29%20%28rate%28gitlab_ci_pipeline_failure_reasons%7Benv%3D%5C%22gprd%5C%22%2Creason%3D%5C%22seed_timeout%5C%22%7D%5B5m%5D%29%29%22%2C%22range%22%3Atrue%2C%22datasource%22%3A%7B%22type%22%3A%22prometheus%22%2C%22uid%22%3A%22mimir-gitlab-gprd%22%7D%2C%22editorMode%22%3A%22code%22%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-24h%22%2C%22to%22%3A%22now%22%7D%7D%7D)

**Sentry**

- [Errors in `lib/gitlab/ci/pipeline/chain/seed.rb`](https://new-sentry.gitlab.net/organizations/gitlab/issues/?project=3&query=is%3Aunresolved%20stack.filename%3A%22lib%2Fgitlab%2Fci%2Fpipeline%2Fchain%2Fseed.rb%22&statsPeriod=24h)
- [Errors in `lib/gitlab/ci/pipeline/seed/build.rb`](https://new-sentry.gitlab.net/organizations/gitlab/issues/?project=3&query=is%3Aunresolved%20stack.filename%3A%22lib%2Fgitlab%2Fci%2Fpipeline%2Fseed%2Fbuild.rb%22&statsPeriod=24h)
- [Errors in `lib/gitlab/ci/pipeline/seed/context.rb`](https://new-sentry.gitlab.net/organizations/gitlab/issues/?project=3&query=is%3Aunresolved%20stack.filename%3A%22lib%2Fgitlab%2Fci%2Fpipeline%2Fseed%2Fcontext.rb%22&statsPeriod=24h)
````

- Has data now: flag evaluated, other exceptions (Sidekiq; the Rails side was
  empty in 24h), Sentry links for `chain/seed.rb` and `seed/build.rb`.
- Threshold: longest seed step over 3 days was 745s in Sidekiq and 33s in
  Rails; the timeout is 900s.
- Sentry issues that already match: GITLABCOM-4D, GITLABCOM-ESEC (and a few
  more); `seed/context.rb` has none.
- Empty in 24h but can fill in: seed step over 600s (2 in Sidekiq over 3 days).
- Fills in when a pipeline times out: `TimeoutError` links, the `seed_timeout`
  Explore link.
- Not in the index yet: `json.extra.job_candidates_count`,
  `json.extra.evaluated_job_candidates_count`.
- No Sentry `error.type:` link: `TimeoutError` goes through `log_exception`,
  so it never reaches Sentry.
- Left out of Sentry: `app/models/concerns/enums/ci/pipeline.rb` and
  `app/presenters/ci/pipeline_presenter.rb`. They only add the `seed_timeout`
  reason and its message, which aren't behind the flag.
- Not checked: Grafana links (built from runbooks).

## Health check (2026-10-27)

The flag was enabled for explicit projects in gprd on 2026-10-26 09:45 UTC
and went to 1% of actors at 10:14. That last change was about a day old, so
the check window starts at 10:14 and no previous window was needed. The override flag is an ops flag with no rollout
issue, so it has no cogbot note. Its latest feature-flag-log issue
(#67263) lists three namespace gates, so it was set.

| Check | Result |
|---|---|
| `Seed::Context::TimeoutError`, Sidekiq / Rails | 0 / 0 |
| Flag evaluated (Rails, since rollout) | 108 |
| Other exceptions with the flag on, Sidekiq / Rails | 12 / 2, no frame under `pipeline/seed/` |
| Seed step ≥300s | 13, max 678s, all in the three override namespaces, all persisted |
| Sentry `seed/context.rb` | none |
| Sentry `chain/seed.rb`, `seed/build.rb` | 3 new since rollout, all Gitaly `connections to all backends failing` |
| Grafana `seed_timeout` | not checked |

- The zero is real: `handle_timeout` calls `log_exception` before
  `error(..., failure_reason: :seed_timeout)`.
- Other exceptions: external validation service errors, NATS timeouts in
  Sidekiq middleware, a merge train ref lock, and two `Rack::Timeout` in
  `chain/create.rb`. A web request stops at 60s, long before the 900s
  deadline, so the Rails timeout link stays empty in practice.
- ES|QL `==` on `json.exception.feature_flag_states.keyword` failed (multi
  value); a DSL `term` with `search` worked.
- A comment with only a screenshot of a pipeline was not treated as a
  verification run, so no project was left out of the queries.

Verdict: **continue**.
