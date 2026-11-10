---
name: gitlab-sentry-cli
description: "Query and manage GitLab's Sentry instance (new-sentry.gitlab.net, org gitlab) with sentry-cli: list and triage issues and events, manage releases and deploys, upload sourcemaps, run cron monitors, or send test events. Use when asked to look up Sentry errors, check Sentry issues for a project, create or finalize a Sentry release, or set up sentry-cli. Triggers: sentry, sentry-cli, new-sentry.gitlab.net, Sentry issue, Sentry event, Sentry release, sourcemaps, cron monitor."
version: 1.0.2
license: MIT
category: Development Workflow
compatibility: opencode
metadata:
  audience: developers
  author: furkanayhan
  workflow: sentry
  keywords: sentry, sentry-cli, errors, issues, events, releases, sourcemaps, monitors
---

# GitLab Sentry CLI

Use `sentry-cli` to work with GitLab's Sentry instance: issue triage, releases,
sourcemap uploads, and cron monitors.

| Setting | Expected value |
|---------|----------------|
| URL | `https://new-sentry.gitlab.net/` |
| Org | `gitlab` |
| Config | `~/.sentryclirc` (or `SENTRY_*` env vars) |

## Before you start: check install and config

Current status (injected at load time on Claude Code; run it yourself elsewhere):

!`sentry-cli info --config-status-json 2>&1 || echo "sentry-cli not installed"`

1. **Not installed** (`command -v sentry-cli` prints nothing): tell the user
   and stop. Install with `brew install getsentry/tools/sentry-cli` or
   `npm install -g @sentry/cli`. Cron monitors need 2.16.1+. sentry-cli 3.x
   supports self-hosted Sentry 24.11.1+ (ours: `curl -sL https://new-sentry.gitlab.net/auth/login/ | grep -o '"version":{"current":"[^"]*"'`).
   If ours is older and a 3.x command fails, try `npm install -g @sentry/cli@2`.
2. **Not configured**: warn the user and point them to
   [references/CONFIGURATION.md](references/CONFIGURATION.md) when any of these
   is true in the JSON output:
   - `auth.successful` is not `true` (missing or invalid token)
   - `config.url` is not `https://new-sentry.gitlab.net`
   - `config.org` is not `gitlab`

   Do not run API commands until this is fixed. They fail with unclear errors
   or hit the wrong server (the default is `sentry.io`). No Sentry account
   yet? See [Get access](references/CONFIGURATION.md#get-access).
3. **No DSN** (`have_dsn` is `false`): fine for most commands. Only
   `monitors run` and `send-event` need it; ask the user for the project DSN
   before running those.

## Rules

- **Ask before writing.** These change data on production Sentry: `issues
  resolve/mute/unresolve`, `releases new/finalize/delete/archive/restore/set-commits`,
  `deploys new`, `sourcemaps upload`, `debug-files upload`, `monitors run`
  (sends check-ins; with `-s` it creates or updates the monitor), `send-event`.
  `sourcemaps inject` edits local files in place. Show the exact command and
  get the user's OK first, even after "do it now". If you can't ask, don't run
  it; show the command instead. Read-only commands (`list`, `info`) are fine.
- **Pass `-p PROJECT` for project-scoped commands** (issues, events,
  releases). Find slugs with `sentry-cli projects list -o gitlab`.
- **`--log-level debug`** shows hidden network and rate-limit errors.
- **`monitors run` and `send-event` use DSN auth** (`SENTRY_DSN`), not the
  auth token. `monitors list` uses the auth token.
- `issues resolve/mute` act on the selection: `-i ISSUE_ID`, `-s STATUS`, or
  `-a`. Prefer `-i`; `-s` and `-a` touch every matching issue in the project.

## Quick reference

```bash
sentry-cli info                                       # verify config and auth
sentry-cli organizations list
sentry-cli projects list -o gitlab

sentry-cli issues list -o gitlab -p PROJECT --query "is:unresolved"
sentry-cli issues list -o gitlab -p PROJECT --query "is:unresolved firstSeen:-24h" --max-rows 20
sentry-cli events list -o gitlab -p PROJECT -U -T     # with users and tags columns

sentry-cli releases list -o gitlab -p PROJECT
sentry-cli releases info VERSION -o gitlab
sentry-cli deploys list -o gitlab -r VERSION

sentry-cli monitors list -o gitlab
```

## References

- Full command list (live `--help`): [references/CLI_HELP.md](references/CLI_HELP.md)
- Configuration, auth, env vars: [references/CONFIGURATION.md](references/CONFIGURATION.md)
- Issues and events, query syntax: [references/ISSUES_EVENTS.md](references/ISSUES_EVENTS.md)
- Releases, deploys, sourcemaps, debug files: [references/RELEASES.md](references/RELEASES.md)
- Cron monitors: [references/MONITORS.md](references/MONITORS.md)

## Contributing Improvements

This skill is maintained in [`gitlab-org/ai/skills`](https://gitlab.com/gitlab-org/ai/skills).
If you discover that any guidance here is **inaccurate or outdated** (e.g. a
command that no longer works, a wrong flag, an incorrect API behavior), confirm
with the user and open an MR against that repository with the fix. Keep changes
focused — one fix per MR.
