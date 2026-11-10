# Verifying findings

Every candidate starts as a claim that one actor can drain a shared resource.
Your job in this pass is to **try to disprove it**. If you ran the hunt, hand
verification to a fresh subagent where you can, so it doesn't inherit your
assumptions.

## Contents

- [Evidence levels](#evidence-levels)
- [Is it enforced on GitLab.com?](#is-it-enforced-on-gitlabcom)
- [Disprove it: layers to check](#disprove-it-layers-to-check)
- [Running local measurements](#running-local-measurements)
- [Ways to reach E3](#ways-to-reach-e3)
- [Common false positives](#common-false-positives)
- [Common false negatives](#common-false-negatives)

## Evidence levels

| Level | Meaning | Outcome |
|---|---|---|
| **E3 reproduced** | Measured: a local repro shows cost growing with input the caller controls, a production-sized query plan shows the cost, or an incident or alert shows it happened | File |
| **E2 traced** | The whole path was read from entry point to resource. Every limit layer below was checked and recorded. The input that drives the cost was shown to be unbounded or bounded too loosely | File, and mark it "traced, not reproduced" |
| **E1 suspected** | Pattern match only, or part of the code path wasn't traced | Don't file. List it in the report under "needs a human", with the open question |

If the whole code path and every layer were traced, and the only unknown is a
GitLab.com setting or flag value, the finding is still E2. Record
`enforced: unknown` and list the value under "needs a human".

Record evidence as permalinks at a commit SHA, commands, and numbers.
"Looks unbounded" is not evidence.

## Is it enforced on GitLab.com?

Code shows what *can* be enforced. These sources show what *is*:

- the flag's state, through ChatOps
  (`/chatops gitlab run feature get <flag>`), if the user can run it
- change requests in `gitlab-com/gl-infra/production` that enable a throttle
  or move it out of dry run
- the flag's rollout issue, and whether its cleanup issue is still open
- `doc/user/gitlab_com/rate_limits.md`, which marks proposed limits as such

When sources disagree (for example, a closed rollout issue claims enforcement
but the docs say "disabled by default"), record `unknown` and link every
source. Don't pick the most convenient one.

## Disprove it: layers to check

Go through every layer and write down what you found, even when the answer is
"not applicable". This list becomes the issue's **Controls checked** table.

1. **Reachability.** Is the surface on GitLab.com at all? Check for
   self-managed-only code, `Gitlab::Saas.feature_available?`, licensed
   features, and feature flags. For a flag, read
   `config/feature_flags/**/<name>.yml` (`default_enabled`, rollout issue). If
   the GitLab.com state is unclear, record it as `unknown` and don't guess.
   Admin-only surfaces on GitLab.com are not noisy-neighbor findings.
2. **Who can call it.** Anonymous, any user, paid only, or role-gated. Check
   the policy, not the UI.
3. **Rack::Attack.** Does a throttle match this path? Is its `*_enabled`
   setting on by default? What is it keyed on?
4. **ApplicationRateLimiter.** Is there a key on this path? Check the
   controller, API, service and worker. Is the threshold `0` (unlimited) by
   default? Check `scope:` and `users_allowlist`.
5. **Size bounds.** Validations (maximum length, maximum items), plan limits
   (where `0` means no limit), pagination caps, GraphQL complexity and page
   size, and timeouts.
6. **Async protection.** `concurrency_limit`, `deduplicate` (useless when
   arguments differ), `defer_on_database_health_signal`, and the worker's
   urgency and shard.
7. **Caching.** Is the expensive part cached in a way the caller can't bust
   (for example by changing a parameter)?
8. **Existing guard tests.** A `QueryRecorder` or `exceed_query_limit` spec
   with several records, or a Gitaly call-count spec, may show the N+1 is
   already handled. A guard whose control is taken on the first request of
   the example, or that adds only two records, passes while the N+1 grows;
   a quarantined N+1 spec is a signal, not protection.
9. **Production usage.** Requests per day, per-actor peak per minute,
   anonymous share, p99 and max, and whether the parameter the fix changes is
   used at all ([kibana.md](kibana.md)). This sets the survivable threshold
   and often finds callers the code trace missed.

## Ways to reach E3

Pick the cheapest one that answers the question. **Never** send load to
GitLab.com, staging or any shared environment.

- **Local scaling check in GDK.** Write a throwaway spec or runner script that
  calls the path with N = 1, 10 and 100, and records query count (with
  `ActiveRecord::QueryRecorder`), Gitaly calls, jobs enqueued, rows written
  (`expect { ... }.to change { Model.count }`, or count `INSERT`s in the
  recorder), or wall time.
  If cost grows with N while the limit stays flat, that is E3. Don't commit
  the spec; keep it in the run's working directory. Gotchas:
  - put the spec under a `spec/requests/...`-style path, even outside the
    repo, or the test-level loader refuses it;
  - stub `Gitlab::QueryLimiting::Transaction.threshold` so large query
    counts don't fail the run;
  - services that rely on the request store need
    `Gitlab::SafeRequestStore.ensure_request_store` when you call them from a
    Rails runner, or composite-identity checks silently fail;
  - for CPU or regex cost, time plain inputs of 1, 10 and 100 KB, not
    worst-case inputs.
- **Production-sized query plan.** Use the `postgresai` skill to EXPLAIN the
  query on a Database Lab clone. Keep plans out of public places. Raw
  production row counts are SAFE data.
- **Production logs.** A request on the path that already takes seconds, a
  `max` at the rack or statement timeout, or one actor at hundreds of requests
  per minute is E3 for "it happens". Query templates and field names are in
  [kibana.md](kibana.md).
- **Incident history.** Search incidents and infradev for the class name,
  route or worker:
  `glab api "projects/gitlab-com%2Fgl-infra%2Fproduction/issues?search=<Class>&per_page=20"`.
  Also check the team issue's starting points. A past single-actor incident
  on this path is strong evidence, and it usually moves the item up.
- **Logs and dashboards** (Kibana, Grafana, Sentry), if the user has access:
  ask them to run the query and paste the result. Don't guess at numbers.

## Running local measurements

Throwaway specs live outside the repo under a `spec/requests/...` path and run
with `bundle exec rspec /tmp/<dir>/spec/requests/.../x_spec.rb` from the
checkout. Gotchas:

- Request specs that render HAML pages need the built CSS
  (`app/assets/builds/*.css`, copy them from a full checkout) and may need a
  stub for `Gitlab::Webpack::Manifest`.
- Give each verifier its own `/tmp` directory, and do not run several specs
  that write the same tables at once; they deadlock on shared tables.
- A `rails runner` probe inside a transaction you roll back is cheaper than
  an rspec boot when you only need query counts or `GitlabSchema.execute`.
- On Database Lab, a long `joe exec` dies with `conn closed`; keep commands
  short, use `EXPLAIN` through `joe explain`, and roll back `DELETE`s with an
  `EXPLAIN ANALYZE` inside a transaction.
- Ask each verifier for a "corrections to the hunter" list; it catches wrong
  mechanisms (a top-N sort mistaken for a full sort, a cost that is capped)
  before they reach an issue.

## Common false positives

- The surface is behind a flag that is off on GitLab.com, or is
  self-managed-only. The finding drops out, or becomes E1 until someone
  checks the flag.
- A limit lives one layer away from where you looked: in the service called
  by the API, in a `before_action` on a parent controller, or in a GraphQL
  base mutation.
- The input that looks unbounded is capped by a validation or a plan limit.
- The work is async on a shard with a `concurrency_limit`, so the actor slows
  only their own jobs. This may still be Tier C.

## Common false negatives

These are real problems even though they look protected:

- A limit exists, but its default threshold is `0`, or the throttle is
  disabled by default.
- A limit is keyed per project or per IP, and one user can create many
  projects or rotate IPs.
- A request cap is in place, but each request is expensive.
- `deduplicate` is set, but each call has distinct arguments.
- GraphQL complexity is set to a constant on a field that does N Gitaly calls.
- A closed "slow endpoint" issue whose fix changed only the serializer or
  entity. The payload shrank; the database work did not. Re-trace it.
