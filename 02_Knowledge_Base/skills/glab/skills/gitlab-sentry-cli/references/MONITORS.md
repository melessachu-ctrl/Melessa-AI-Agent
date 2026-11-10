# Cron Monitors

Monitor uptime and performance of scheduled/recurring jobs. Alerts on missed or timed-out check-ins.

## Requirements

- sentry-cli >= 2.16.1
- `monitors run` needs **DSN authentication** (not auth token) — set `SENTRY_DSN`.
  `monitors list` uses the normal auth token.

## Configuration

Copy the DSN from the project's **Settings > Client Keys (DSN)** page on
`new-sentry.gitlab.net`. Do not build it by hand. The host is the instance
itself, not `ingest.sentry.io`.

```bash
export SENTRY_DSN=https://<key>@new-sentry.gitlab.net/<project_id>
```

Or in `~/.sentryclirc`:

```ini
[auth]
dsn = https://<key>@new-sentry.gitlab.net/<project_id>
```

## List Monitors

```bash
sentry-cli monitors list -o ORG
```

## Run a Monitored Job

Wraps a command with automatic check-in/check-out:

```bash
sentry-cli monitors run <monitor-slug> -- <command> <args>
```

Examples:

```bash
sentry-cli monitors run my-cron -- python /path/to/job.py
sentry-cli monitors run my-cron -- node /path/to/script.js
sentry-cli monitors run my-cron -- /usr/local/bin/backup.sh
```

## Create/Update Monitor via Check-In

Create or update a monitor's schedule inline with `--schedule` (`-s`):

```bash
# Every minute
sentry-cli monitors run -s "* * * * *" my-monitor -- my-command

# Every hour
sentry-cli monitors run -s "0 * * * *" my-monitor -- my-command

# With additional config
sentry-cli monitors run \
  -s "0 * * * *" \
  --check-in-margin 5 \
  --max-runtime 30 \
  --timezone "Europe/Berlin" \
  my-monitor -- my-command
```

For all schedule options, run `sentry-cli monitors run --help`.

## Specify Environment

For monitors running in multiple environments:

```bash
sentry-cli monitors run -e dev my-monitor -- node job.js
sentry-cli monitors run -e production my-monitor -- python job.py
```
