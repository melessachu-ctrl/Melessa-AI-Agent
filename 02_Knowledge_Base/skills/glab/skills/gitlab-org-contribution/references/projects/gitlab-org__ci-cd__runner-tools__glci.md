# gitlab-org/ci-cd/runner-tools/glci

glci runs `.gitlab-ci.yml` pipelines locally through gitlab-runner against an embedded mock GitLab API. It is written in Go, with a daemon, a TUI and a Hugo documentation site. `CLAUDE.md` (which `AGENTS.md` points to) carries the project's hard rules.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | Go |
| Fork to use | Community fork `gitlab-community/gitlab-org/ci-cd/runner-tools/glci` (almost all community MRs come from it) |
| Merge settings | Squash default off; no merge train |
| Commit convention | Conventional Commits with a capitalized subject (observed) |
| MR template | None |
| Changelog | Generated from MR metadata (`make regenerate_changelog`, `cliff.toml`); never edit `CHANGELOG.md` |
| Contributor docs | `CLAUDE.md` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Title MRs and commits as Conventional Commits with a capitalized subject and a scope naming the area: `fix(config): Refuse local includes that leave the repository`, `feat(mockserver): ...`, `docs: ...`. (observed, 29 of 30 merged community MRs; [!190](https://gitlab.com/gitlab-org/ci-cd/runner-tools/glci/-/merge_requests/190), [!206](https://gitlab.com/gitlab-org/ci-cd/runner-tools/glci/-/merge_requests/206), [!209](https://gitlab.com/gitlab-org/ci-cd/runner-tools/glci/-/merge_requests/209))
- Never edit `CHANGELOG.md`. Keep the Community contribution label on your MR: community MRs get a credited section in each release. (documented; `gitlab-org/ci-cd/runner-tools/glci:CLAUDE.md@16a791d6`)
- Run `go build ./...`, `go vet ./...` and `make test` (unit, no Docker) every time, then the tier for the area you changed: `make test-e2e-parse` (config parsing), `make test-e2e-golden` (pipeline JSON), `make test-tui`, `make test-integration-cli` and `make test-integration-cli-daemon`, `make test-e2e-simulate` (mock server, scheduler, DAG), `make test-integration-docker`, `make test-integration-registry`, `make test-integration-lifecycle`. (documented; `gitlab-org/ci-cd/runner-tools/glci:CLAUDE.md@16a791d6`)
- Fix the bug in glci, never in the user's pipeline or the test fixtures, and never skip or allow-fail a test to get green. (documented; `gitlab-org/ci-cd/runner-tools/glci:CLAUDE.md@16a791d6`)
- Test all new behavior and mock GitLab.com calls with `httptest` (no network in automated tests). For a new CI keyword, runner config field or mock server capability, add a job to `e2e/testdata/comprehensive/ci/jobs.yml` and update the parse test, the full-run test and the three golden fixtures. (documented; `gitlab-org/ci-cd/runner-tools/glci:CLAUDE.md@16a791d6`)
- Update the Hugo docs under `site/content` in the same MR as any new command, flag, config option, CI keyword or behavior change, and `README.md`, `ARCHITECTURE.md` or `.claude/skills/glci/SKILL.md` when affected. (documented; `gitlab-org/ci-cd/runner-tools/glci:CLAUDE.md@16a791d6`)
- The repository has no CODEOWNERS file (checked 2026-10-22 at `.gitlab/CODEOWNERS`, `CODEOWNERS` and `docs/CODEOWNERS`), so there is no owner list to read. To name a reviewer in `@gitlab-bot ready @<reviewer>`, take the person who merged recent MRs touching the same package (the file history and the merged MR list show who). (documented by absence; repository tree of `gitlab-org/ci-cd/runner-tools/glci` on `main`)

## Why MRs here were closed

- None of the 13 community MRs read for this project was closed without merging, so there is no project-specific pattern; the general causes in references/why-mrs-get-closed.md apply.

## Troubleshooting

**A test tier you did not run fails in the pipeline (golden fixtures, the `comprehensive` e2e job, a TUI test)**
- Cause: a change to a CI keyword, a runner config field or the mock server touches fixtures that only the matching `make test-*` tier checks.
- Fix: run the tier for the area you changed (see Rules), update `e2e/testdata/comprehensive/ci/jobs.yml`, the parse test, the full-run test and the three golden fixtures together, and never mark a test allowed to fail.
- Who can fix it: you.
- Sources: `gitlab-org/ci-cd/runner-tools/glci:CLAUDE.md@16a791d6`

**Anything else**
- No project-specific failure appeared in the MRs read here. The community fork runs the project's pipeline, so the general entries in references/troubleshooting.md apply.
