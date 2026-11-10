# Configuration & Authentication

- [Get access](#get-access) and [Create a token](#create-a-token)
- [Set up for GitLab's Sentry](#set-up-for-gitlabs-sentry)
- [Config File Format](#config-file-format-sentryclirc) and
  [All Configuration Values](#all-configuration-values)

## Authentication Methods (in priority order)

1. **CLI flag**: `--auth-token <TOKEN>`
2. **Environment variable**: `export SENTRY_AUTH_TOKEN=<TOKEN>`
3. **Config file**: `~/.sentryclirc` under `[auth]` section
4. **`.env` file**: auto-loaded unless `SENTRY_LOAD_DOTENV=0`

## Get access

Only GitLab team members can use `new-sentry.gitlab.net`. Access goes
through an Okta group: if sign-in fails, the user must open an access request
for the Sentry Okta group (see the
[error tracking docs](https://gitlab-com.gitlab.io/gl-infra/observability/docs-hub/error-tracking/overview)).
After the first sign-in, join the `#gitlab` team (**Join a team**) to see the
GitLab projects.

## Create a token

Create a **personal** token at
`https://new-sentry.gitlab.net/settings/account/api/auth-tokens/`.
Organization tokens only cover CI tasks (releases, uploads) and can't list
issues or events.

- Read-only work (issues, events, releases list): `org:read`, `project:read`,
  `event:read`.
- Add `event:write` to resolve or mute issues, and `project:releases` for
  releases, deploys, and uploads.
- Personal token scopes can't be edited later. Create a new token to change
  them.

## Set up for GitLab's Sentry

```bash
sentry-cli --url https://new-sentry.gitlab.net/ login --global   # store token in ~/.sentryclirc
```

`login` opens the **organization** token page in the browser. Ignore it and
paste the personal token from the step above.

Then add the defaults to `~/.sentryclirc` so you don't need `--url` and `-o`
on every command:

```ini
[defaults]
url = https://new-sentry.gitlab.net/
org = gitlab
```

Verify with `sentry-cli info --config-status-json`: `auth.successful` should be
`true`, `config.url` should be `https://new-sentry.gitlab.net`, and
`config.org` should be `gitlab`.

Without `--url` (or `defaults.url`), sentry-cli talks to `https://sentry.io/`,
not GitLab's instance.

## Config File Format (`.sentryclirc`)

INI format. Looked up from CWD upward, then `~/.sentryclirc`.

```ini
[auth]
token = sntryu_...

[defaults]
url = https://new-sentry.gitlab.net/
org = gitlab
project = my-project

[http]
verify_ssl = true
proxy_url = http://proxy:8080
max_retries = 5

[log]
level = warn
```

## All Configuration Values

| Env Variable | Config Key | Description |
|---|---|---|
| `SENTRY_AUTH_TOKEN` | `auth.token` | Auth token for API calls |
| `SENTRY_DSN` | `auth.dsn` | DSN for `monitors run` and `send-event` |
| `SENTRY_URL` | `defaults.url` | Server URL (default: `https://sentry.io/`) |
| `SENTRY_ORG` | `defaults.org` | Default organization slug |
| `SENTRY_PROJECT` | `defaults.project` | Default project slug |
| `SENTRY_VCS_REMOTE` | `defaults.vcs_remote` | Git remote name (default: `origin`) |
| `SENTRY_LOG_LEVEL` | `log.level` | Log verbosity: `trace`, `debug`, `info`, `warn`, `error` |
| `SENTRY_NO_PROGRESS_BAR` | — | Set to `1` to disable progress bars |
| `SENTRY_LOAD_DOTENV` | — | Set to `0` to skip `.env` loading |
| `SENTRY_DOTENV_PATH` | — | Custom `.env` file path |
| `SENTRY_HTTP_MAX_RETRIES` | `http.max_retries` | Max HTTP retries (default: 5) |
| `SENTRY_ALLOW_FAILURE` | — | Ignore upload failures (CI safety net) |
| — | `http.proxy_url` | HTTP proxy URL |
| — | `http.verify_ssl` | SSL verification (`true`/`false`) |
| — | `http.keepalive` | HTTP keepalive (`true`/`false`) |

## Specifying Org & Project

In priority order:

1. **CLI flags**: `-o my-org -p my-project`
2. **Environment variables**: `SENTRY_ORG`, `SENTRY_PROJECT`
3. **Config file** `[defaults]` section

## Validate Configuration

```bash
sentry-cli info                 # full check: auth + org + project defaults
sentry-cli info --no-defaults   # verify auth only, skip org/project check
sentry-cli info --config-status-json  # machine-readable config status
```
