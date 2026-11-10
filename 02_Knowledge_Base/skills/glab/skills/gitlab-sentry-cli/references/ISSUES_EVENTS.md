# Issues & Events

- [Issues](#issues): list, [query syntax](#query-syntax-examples), bulk operations
- [Events](#events)
- [Send Manual Events](#send-manual-events)

## Issues

Issues are groups of similar events. An issue can contain many events.

### List Issues

```bash
sentry-cli issues list -o ORG -p PROJECT
sentry-cli issues list -o ORG -p PROJECT --query "is:unresolved"
sentry-cli issues list -o ORG -p PROJECT -s unresolved
sentry-cli issues list -o ORG -p PROJECT --max-rows 50
sentry-cli issues list -o ORG -p PROJECT --pages 10   # 100 issues/page, default 5 pages
```

### Filter Options

- `-s, --status <STATUS>` — `resolved`, `muted`, `unresolved`
- `-a, --all` — select all issues (may be limited)
- `-i, --id <ID>` — select specific issue by ID
- `--query <QUERY>` — Sentry search syntax (see https://docs.sentry.io/concepts/search/)

### Query Syntax Examples

```bash
--query "is:unresolved"
--query "is:unresolved assigned:me"
--query "is:unresolved level:error"
--query "is:unresolved firstSeen:-24h"
--query "is:unresolved timesSeen:>100"
--query "error.type:Gitlab::Ci::SomeError"
```

Use camelCase keys (`firstSeen`, `timesSeen`, `lastSeen`). The hyphenated
forms (`first-seen:`) match nothing and print `No issues found`.
`-30d` means within the last 30 days; `+30d` means older than 30 days (so
`lastSeen:+30d` finds stale issues).

Known problems on `new-sentry.gitlab.net`:

- On large projects (for example `gitlabcom`), `level:error`, `assigned:me`
  and `timesSeen:` queries, and sometimes `events list`, fail with HTTP 500.
  Retrying, or narrowing the query (add `firstSeen:-24h`), may help.
- `stack.filename:"<path>"` queries often time out (>90s). Use the API with
  `curl` instead (read the token from `~/.sentryclirc`, never print it):
  `GET https://new-sentry.gitlab.net/api/0/organizations/gitlab/issues/?project=<id>&query=...`
  with `Authorization: Bearer <token>`.
- A free-text query with `::` (for example a class name) returns
  `No issues found` even when issues exist. Use `error.type:<Class>` instead.

### Bulk Operations

```bash
sentry-cli issues resolve -o ORG -p PROJECT -i ISSUE_ID
sentry-cli issues resolve -o ORG -p PROJECT -s unresolved      # resolves EVERY unresolved issue in the project
sentry-cli issues mute -o ORG -p PROJECT -i ISSUE_ID
sentry-cli issues unresolve -o ORG -p PROJECT -i ISSUE_ID
```

## Events

Events are individual error occurrences within an issue.

### List Events

```bash
sentry-cli events list -o ORG -p PROJECT
sentry-cli events list -o ORG -p PROJECT -U           # show Users column
sentry-cli events list -o ORG -p PROJECT -T           # show Tags column
sentry-cli events list -o ORG -p PROJECT --max-rows 50
sentry-cli events list -o ORG -p PROJECT --pages 10   # 100 events/page, default 5 pages
```

## Send Manual Events

Send a test or manual event directly to Sentry:

```bash
sentry-cli send-event -m "Test message"
sentry-cli send-event -m "Deploy failed" -l error
sentry-cli send-event -m "Something happened" -l warning

# With tags
sentry-cli send-event -m "Error" -t env:production -t component:api

# With extra data
sentry-cli send-event -m "Error" -e request_id:abc123 -e user_count:42

# With user info
sentry-cli send-event -m "Error" -u id:42 -u username:admin

# With release and environment
sentry-cli send-event -m "Error" -r "1.0.0" -E production

# With custom fingerprint (for grouping)
sentry-cli send-event -m "Error" -f "custom-fingerprint"

# With breadcrumbs from logfile
sentry-cli send-event -m "Error" --logfile /var/log/app.log

# From JSON file
sentry-cli send-event /path/to/event.json
```

For all options, run `sentry-cli send-event --help`.

Note: `send-event` is not guaranteed to arrive due to network errors, rate limits, or sampling. Use `--log-level debug` to see transmission errors.
