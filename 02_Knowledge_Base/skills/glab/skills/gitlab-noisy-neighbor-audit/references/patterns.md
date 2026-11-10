# Noisy-neighbor patterns to hunt

For each surface, ask three questions:

1. **Who can reach it?** Anonymous users, any signed-in user (on GitLab.com
   anyone can sign up for free), paid users only, or project maintainers only.
2. **What does one call cost?** Count queries, Gitaly RPCs, jobs enqueued,
   rows written, bytes rendered or upstream calls (for example LLM calls), and
   how that cost grows with input the caller controls.
3. **What stops a single actor from repeating it?** Name the limit, what it is
   keyed on, and whether it is enforced on GitLab.com.

## Contents

- [Limit layers to know](#limit-layers-to-know)
- [Endpoints (REST and web)](#endpoints-rest-and-web)
- [GraphQL](#graphql)
- [Background fan-out](#background-fan-out)
- [Retries and thundering herds](#retries-and-thundering-herds)
- [Expensive queries](#expensive-queries)
- [Record amplification and unbounded data growth](#record-amplification-and-unbounded-data-growth)
- [Hierarchy traversal](#hierarchy-traversal)
- [Expensive renders and Gitaly](#expensive-renders-and-gitaly)
- [Long-lived connections](#long-lived-connections)
- [Bypasses](#bypasses)
- [Limits that fail under load](#limits-that-fail-under-load)
- [Agentic actions and metering](#agentic-actions-and-metering)
- [Other performance findings](#other-performance-findings)

## Limit layers to know

| Layer | Where | Gotcha |
|---|---|---|
| Rack::Attack throttles | `lib/gitlab/rack_attack.rb`, `lib/gitlab/rack_attack/request.rb`; settings via `Gitlab::Throttle` | Broad per-user or per-IP request caps. Each throttle has an `*_enabled` application setting, and several are off by default. A new throttle needs a Labkit ThrottleRegistry entry. |
| Labkit plan rules | `ee/lib/ee/gitlab/rate_limit/plan_rules.rb`, `ee/lib/gitlab/rate_limit/flag_policy.rb`, `lib/gitlab/rack_attack/labkit_rate_limit/` | Per-plan, per-user rules, including the MCP rules. Each has separate `*_info` (log only) and `*_enforce` flags. The user's tier is their best across all memberships, and trials count as paid. The flag actor may be the request, so a partial rollout enforces on random requests. |
| `Gitlab::ApplicationRateLimiter` | Keys and thresholds in `lib/gitlab/application_rate_limiter/labkit_adapter/supported_rate_limits.rb` and its EE copy under `ee/lib/ee/gitlab/application_rate_limiter/`; called from `check_rate_limit!` (`app/controllers/concerns/check_rate_limit.rb`, `lib/api/helpers/rate_limiter.rb`) or from services | Threshold `0` means unlimited, including a `-> { 0 }` callable. `users_allowlist` skips the limit. Check `scope:`, because that is what the limit is keyed on. |
| Plan limits | `app/models/plan_limits.rb`, `Namespace#actual_limits` | They cap sizes and counts per plan. A value of `0` usually means no limit. Free-plan values matter most. |
| GraphQL | `app/graphql/gitlab_schema.rb` (max complexity, depth, `default_max_page_size`); field `complexity:`, `calls_gitaly: true`, `max_page_size:`, `Gitlab::Graphql::Limit::FieldCallCount` | Complexity is a static estimate. A field with a constant complexity that does N Gitaly calls or a heavy query is underpriced. |
| Sidekiq | `app/workers/concerns/worker_attributes.rb`: `concurrency_limit`, `deduplicate`, `defer_on_database_health_signal`, `urgency`, `worker_resource_boundary` | Deduplication merges identical arguments. It does nothing when each job has distinct arguments. |
| Documented GitLab.com limits | `doc/user/gitlab_com/rate_limits.md`, `doc/security/rate_limits.md` | This is the closest public statement of what is enforced, but some sections describe proposed limits that aren't in effect yet. Missing from the docs is not proof that a limit is off. |
| JSON body limits | `lib/gitlab/middleware/json_validation.rb` (`DEFAULT_LIMITS`, `ROUTE_CONFIGS`) | Caps array size and total elements per body, not bytes, unless a route overrides it. It bounds "items per request" for every JSON endpoint; record it, then check whether the per-item cost makes the cap too loose. |
| Request body size | `workhorse/internal/upstream/routes.go` (`withBodyLimit`), `WORKHORSE_REQUEST_LIMIT`, edge proxies | The generic API body limit is off unless the environment sets it. Package uploads bypass it through the Workhorse uploader and rely on plan limits checked after the bytes land. |
| Which throttle bucket | `lib/gitlab/rate_limit/request_classification.rb`, `Gitlab::Regex::Packages::API_PATH_REGEX` | Decide by regex which Rack::Attack bucket a path falls in. `/packages/<format>/` paths get the packages throttle; other API paths only the general one. |

**In-process dispatch skips layers.** Some features call other code paths
directly instead of over HTTP. Examples are `GitlabSchema.execute` without
`context[:request]`, and running a Grape route's app in-process. When that
happens, Rack middleware (Rack::Attack) and any limiter that reads the request
are skipped, but Grape `before` hooks still run. When your code dispatches
this way, list which limits the original route relies on and check each one
still applies.

## Endpoints (REST and web)

- Write actions (create, update, import, retry, trigger, export) with no
  `check_rate_limit!` anywhere on the path: controller, API class or service.
- Actions whose cost grows with stored data the caller controls: a large
  project, many members, a long thread, a big diff, many pipelines.
- `per_page` or batch parameters that can exceed 100, or that are not capped
  at all. Offset pagination on large tables, where deep pages get slow.
- Search or filter parameters that cause `ILIKE '%x%'`, regex or full scans.
  User-supplied regex that doesn't go through `Gitlab::UntrustedRegexp`.
- Synchronous external calls (webhooks, integrations, LLM, object storage) on
  the request path, with no timeout or a long one.
- Unauthenticated endpoints. Treat these as Tier A candidates by default.
- Grape entities that `expose` an association the finder does not preload.
  Each exposed association is one query per record; check `lib/api/entities`
  against the finder's `includes`, and look for list endpoints with no
  pagination at all.
- A broad `rescue_from` (for example `ActiveRecord::ActiveRecordError`) that
  answers 400. It turns statement timeouts into client errors, hides them from
  error tracking, and lets the caller retry a drain. It also shadows the 404
  handler and can echo PostgreSQL detail to the client.
- Upload paths: call the `authorize` endpoint in a spec and read the response.
  No `MaximumSize` means Workhorse streams any size before Rails rejects it;
  a `tmp/uploads` path means Rails copies the object inside its transaction.

## GraphQL

- Mutations from your categories that skip `ApplicationRateLimiter`. The
  global request throttles apply to GraphQL as a whole, not to each mutation.
- Connection fields whose node resolution does per-node queries or Gitaly
  calls. Check for `BatchLoader` and look for a multi-record `QueryRecorder`
  spec.
- Fields priced lower than they cost: constant `complexity` on a field that
  calls Gitaly, renders markdown or runs an aggregate.
- Nested connections and aliases. A numeric `complexity:` counts once per
  connection, not per node: `a(first: 100) { b(first: 100) { field } }`
  resolves `field` 10,000 times at a score near 50.
- Connection fields with no resolver (a bare `has_many`). They get a constant
  complexity, the page-size multiplier applies only to resolver-backed fields,
  and `GraphqlController` disables query limiting, so the execution timeout is
  the only bound. Check for `FieldCallCount` on every `has_many` connection.

## Background fan-out

- One request or event enqueues jobs in proportion to something the caller
  controls: members, projects in a group, MRs, pipelines, subscribers. Look for
  `perform_async` inside loops, `bulk_perform_async` on unbounded collections,
  and `each_batch` that enqueues one job per batch with no cap.
- Workers with no `concurrency_limit` on a path the caller can trigger again
  and again. Arguments differ on each call, so `deduplicate` doesn't help.
- Notification, webhook and email fan-out per event.
- Cron workers that scan whole tables, or that process every namespace on a
  schedule without health-signal deferral.
- Workers that one actor can keep busy for minutes at a time
  (`worker_resource_boundary :cpu` or `:memory`, large imports and exports).

## Retries and thundering herds

A retry turns one failure into several calls. When a dependency is slow
because it is overloaded, retries add load at the worst moment. Look for:

- **Nested retries.** A Sidekiq job retries (`sidekiq_options retry:`,
  `sidekiq_retry_in`), the HTTP client inside it retries, and the SDK below
  that retries too. The attempts multiply. Count the worst case through every
  layer: one failing call can become dozens.
- **Retries with no backoff or no jitter.** Clients that failed together
  retry together.
- **Retries on errors that mean "slow down"**: 429, 503, statement timeouts,
  a lock held by someone else (`Gitlab::ExclusiveLease`). Retrying these at
  once feeds the overload.
- **Work that restarts from the beginning.** A job that fails on its last
  step and then re-reads every page or re-renders everything.
- **Caches that expire for every caller at the same moment.**
- **No circuit breaker** on calls to a shared or external dependency. Check
  whether the path uses `Gitlab::CircuitBreaker`
  (`doc/development/utilities.md`).

Record the worst-case attempts per failed action, multiplied through every
layer.

## Expensive queries

- Missing `LIMIT`. `pluck` or `ids` over unbounded relations. `count` on large
  relations shown in the UI or API.
- `NOT IN` or `OR` across large tables. Sorting on columns with no index.
  Cross-joins between namespaces.
- A grouped or `DISTINCT ON` subquery joined to a scoped outer query (a
  per-parent count, a "latest row per key"). The planner cannot push the
  outer predicate into the subquery, so it scans the whole table for every
  tenant's rows. Scope the subquery itself.
- A "latest row per key" query with an index only on the parent id: it reads
  and sorts every row of the parent on each call, so cost follows history
  length, not page size.
- Use the `postgresai` skill to EXPLAIN against a production-sized clone
  instead of guessing (see [verification.md](verification.md)).

## Record amplification and unbounded data growth

Database storage is shared too. If one cheap action makes the server write
rows in proportion to something the caller controls, one actor can fill
tables. That slows queries, vacuum, replication, backups and migrations for
everyone. Look for:

- **Writes that grow with caller-controlled input.** For example, each MR diff
  version stores one `merge_request_diff_commits` row per commit
  (`MergeRequestDiff#save_commits`). A branch with a million commits writes a
  million rows on every push, and then again whenever anything rebuilds the
  diff. Ask the same question of diff files, pipelines with many jobs or
  includes, CI artifacts and logs, todos and notifications per mention, events
  and audit events per item, webhook logs, imports, and anything copied per
  member or per project in a group.
- **Rows copied rather than shared.** A new version, fork, retry or clone that
  duplicates every child row instead of pointing at the old ones.
- **Rows created by reads.** Metadata built on first view (find-or-create),
  caches persisted to tables, tracking rows written for every call.
- **No cap on how many an actor can create.** Notes, labels, tokens, webhooks,
  saved views, agent sessions, schedules: check `plan_limits`, validations and
  rate limits on *create*, not only on read. A per-IP limit on a signed-out
  create is weak, because one actor can rotate IPv6 addresses.
- **No cap on how big one row can get.** Unbounded `text` or `jsonb` columns
  filled from caller input, such as a list joined into one string. One
  multi-megabyte row can matter more than many small ones.
- **No cleanup.** Look for a retention worker, a TTL, partition dropping or
  loose-foreign-key cleanup. Cleanup that runs only when an admin changes a
  setting is not retention. Rows that live forever turn a slow trickle into
  the same problem as a single huge write.

Rows written per call for metering or telemetry are expected. Don't flag them
when they are bounded per request and have retention (for example buffered
upserts into partitioned tables).

Measure it as rows written per action, and bytes per row, and how both grow with the input
(see [verification.md](verification.md#ways-to-reach-e3)). Treat large
writes to shared primary-database tables as Tier A candidates.

## Hierarchy traversal

Many costs grow with the size of a tree or graph. Creating groups, projects,
work items or pipelines is cheap, so one actor can build a huge structure and
then trigger something that walks all of it. Often they don't even need to:
large public groups owned by others already exist, and any user can read them. For each
hierarchy your code walks, find its **depth** cap and its **breadth** cap.
They differ:

- **Groups:** depth is capped (`Namespace#nesting_level_allowed`,
  `NUMBER_OF_ANCESTORS_ALLOWED`), but the number of subgroups and projects
  per group isn't. "Every descendant" or "every project in the group" can
  mean tens of thousands of rows.
- **Group sharing:** `group_group_links` and project shares add edges, so
  "everyone with access" isn't a tree walk. Members of shared groups multiply
  the set.
- **Others to check:** work item parent links (`WorkItems::ParentLink`
  caps children per parent), CI parent-child and multi-project pipelines
  (`Ci::Bridge` caps descendant depth), CI `include` nesting, fork networks,
  issue and MR links, and dependency graphs.

Watch for:

- **Traversal forced on.** A tool or query that hard-codes
  `includeDescendants`, `includeSubgroups` or `allAvailable` with no way for
  the caller to opt out.
- **Walks with no bound on the result.** `self_and_descendants`,
  `all_projects`, `self_and_hierarchy` or member inheritance used to load,
  pluck, count or enqueue work for everything, with no `LIMIT` and no batching.
- **Per-node work while walking.** A query, Gitaly call, permission check or
  job for each descendant or ancestor, or a Ruby loop over `.parent` instead
  of one `traversal_ids` query. The most common form is per-parent N+1 in
  field resolution: a page of N items spread across N projects runs a query
  per project for fields like `webUrl`, `reference` or type, even when the
  walk itself is one query.
- **The slow path.** `Gitlab::ObjectHierarchy` and the recursive traversal
  scopes use recursive CTEs, and they still run when `use_traversal_ids?` is
  false. They cost far more than the linear scopes on deep or wide trees.
- **Cascading reads on every request.** Settings that cascade down the group
  tree resolve by walking ancestors. Check that the walk is cached and
  happens once per request.
- **Fan-out on a hierarchy change.** Moving, transferring, archiving,
  enabling a setting on, or deleting a large group can touch every
  descendant. Check for batching, `concurrency_limit` and deferral (see
  [Background fan-out](#background-fan-out)).

To verify, build a wide tree in GDK (for example 1 group with 100
subgroups, or 20 levels with a few children each). Then measure queries and
time for the operation at 1, 10 and 100 descendants. Add a control that
separates breadth from page size: the same N items under 1 parent versus
under N parents.

## Expensive renders and Gitaly

- Markdown (Banzai) rendering of large content the caller controls: issue
  descriptions, notes, wiki pages, release notes. Watch for re-rendering on
  every reply (the per-thread note pattern).
- Diffs, blame, archives, compare, file tree or commit lists on caller-chosen
  refs or paths. Gitaly calls in loops, or
  `Gitlab::GitalyClient.allow_n_plus_1_calls`.
- Repository-wide operations triggered per request, such as language
  detection, size calculation or search indexing.
- Rendering done before the cache is consulted, or a cache that is written
  on one path and never on another (anonymous visitors often take a different
  default path from signed-in users). Count the expensive calls on a second,
  warm request and on a conditional GET; a 304 can still do the work.
- Timeouts that wrap only part of the work. A lazy object or a subprocess
  created inside the timeout and consumed outside it is unbounded.
- Metadata or stats endpoints that decorate every file of a diff although
  their response needs only paths and counts.

## Long-lived connections

WebSockets, server-sent events, long polling and streaming responses stay
open for minutes. Each one holds a socket, a thread or process slot, and
often memory, for as long as it lives. Look for:

- **No cap on open connections per actor.** A limit on requests per minute
  doesn't bound connections that never close. Check per user, per token and
  per session.
- **No idle timeout and no maximum lifetime.**
- **Messages read whole into memory** with no size limit. Check proxies such
  as Workhorse as well as Rails.
- **Work per message, per subscriber.** On each trigger, GraphQL
  subscriptions re-run the query once per subscriber
  (`lib/gitlab/graphql/subscriptions/action_cable_with_load_balancing.rb`).
- **Work that continues after the client disconnects**, such as a streaming
  response or an upstream call that nobody cancels.
- **A connection that pins a Puma or Sidekiq thread** instead of an event
  loop.

To verify, in GDK (never GitLab.com or staging), open many connections from
one account and watch threads, memory and file descriptors.

## Bypasses

- `Gitlab::QueryLimiting.disable!(<issue>)`. Its issue link points to a known
  N+1, which is a ready-made candidate.
- `allow_n_plus_1_calls`, and `rubocop:disable` for performance or
  `CodeReuse` cops on hot paths.
- Allowlists: rate-limit `users_allowlist`, Rack::Attack user allowlist, bot or
  service-account exemptions, admin-only skips, and internal API paths
  (`/api/v4/internal`) reachable with shared secrets.
- Headers or parameters that skip caching or limits.
- `ON DELETE CASCADE` foreign keys with no Ruby `dependent:` option. The
  delete runs as one statement in the request, unbatched, over every child
  row; the statement timeout then makes the record undeletable and the
  request retryable. Grep `db/structure.sql` for the table's foreign keys.

## Limits that fail under load

A limit is code too. It can have its own bug, and when it fails it can stop
far more than the actor it was meant to stop. Look for:

- **Deferral that blocks everyone.** When a limiter defers work into a queue
  (for Sidekiq, `lib/gitlab/sidekiq_middleware/concurrency_limit/`), check
  what happens while that queue is never empty. Work that is under the limit
  must still run.
- **Behavior when the limiter's store is slow or down.** Most limits keep
  their counters in Redis (`Gitlab::ApplicationRateLimiter`, Rack::Attack,
  the concurrency limit). Failing closed blocks all traffic; failing open
  stops limiting exactly when load is high. Record which one happens and
  whether it is deliberate.
- **Expensive work before the check.** If authentication, authorization or
  the rate limit runs after a query, a Gitaly call or a render, a rejected
  caller still costs the resource. Read the order of `before` hooks and
  service calls, not only whether the check exists.

## Agentic actions and metering

Agentic usage must be both *controlled* and *monetized*. For every action
an agent can take in your area (MCP tools, Duo Agent Platform tools and flows,
API calls made by service accounts with composite identity, `ai_workflows`- or
`mcp`-scoped tokens), check:

- **Limited per actor?** Agents loop. An action that is fine at human pace
  (a few per minute) may run at hundreds per minute per session, and there may
  be many sessions per user. Check the Labkit plan rules for the surface (the
  MCP rules live there), any Rack::Attack throttle such as
  `throttle_authenticated_mcp` (off unless enabled), and any per-tool or
  per-flow limit. A rule that counts requests doesn't bound a single expensive
  call.
- **Attributable?** Can the request be tied to a root namespace and to the
  human behind the agent (composite identity), or does it look like ordinary
  user traffic?
- **Metered?** Is a billable event emitted
  (`Gitlab::BillingEvents::Client.track_billing_event`, AI usage events under
  `ee/app/models/ai/usage_event.rb`)? An unmetered agent action is a `meter`
  finding even if it is cheap.
- **Fan-out from a single prompt.** Flows that create issues, MRs, pipelines
  or comments in bulk. Tools that return large payloads (whole files, long
  logs) on each call.

## Other performance findings

Report any other performance defect you find: slow endpoints with no
single-actor angle, N+1s, missing indexes. List them after the
noisy-neighbor findings. File them as ordinary `bug::performance` issues, not
under the program's labels.
