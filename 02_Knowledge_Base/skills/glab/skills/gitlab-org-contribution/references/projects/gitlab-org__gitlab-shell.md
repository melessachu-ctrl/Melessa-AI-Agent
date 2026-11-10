# gitlab-org/gitlab-shell

The SSH entry points of GitLab (`gitlab-shell` and `gitlab-sshd`), in Go. Commit messages are not linted, squash is off, and its process docs live in `gitlab-org/gitlab`.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | Go |
| Fork to use | Community fork `gitlab-community/gitlab-org/gitlab-shell` |
| Merge settings | Squash default off (your commits land as written), merge trains on, pipeline must succeed, all threads must be resolved |
| Commit convention | Not enforced (the Dangerfile excludes the commit message and changelog rules); DCO applies |
| MR template | None |
| Changelog | `CHANGELOG` and `VERSION` are updated by maintainers in a release MR |
| Contributor docs | `gitlab-org/gitlab` under `doc/development/gitlab_shell/` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Open the MR only when it has commits; do not open placeholder drafts to claim hackathon work. Twelve of 15 closed community MRs here were empty hackathon drafts, most closed about 250 days later as having no changes. (observed, 12 MRs; [!1042](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1042), [!1603](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1603))
- Work from the community fork, so reviewers can apply suggestions and push fixes to your branch; a reviewer could not apply a suggestion to a personal-fork branch. Personal-fork pipelines also skip dependency scanning, which the security policy bot reports. (observed, 1 MR; [!1284](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1284))
- Before pushing, run `make test`, `make verify` (gofmt) and `make lint`; lefthook's pre-push hook runs `make test` and `make lint`. `make check` is not one of these checks: it runs `bin/gitlab-shell-check`, which the developer docs describe as checking that the GitLab API and Redis with the internal API can be reached. Gitaly-backed tests need `GITALY_CONNECTION_INFO` or the docker-compose setup from the developer docs. (documented; enforced; `gitlab-org/gitlab-shell:lefthook.yml@e154d2df`, `gitlab-org/gitlab-shell:Makefile@232f5557`, `gitlab-org/gitlab:doc/development/gitlab_shell/_index.md@69a3ff35`)
- `make lint` is a baseline comparison: `support/lint.sh` runs `make golangci` (golangci-lint 2.12.2 from `GOLANGCI_LINT_VERSION` in the Makefile, downloaded into `support/bin/`, with `--issues-exit-code 0`) and fails when its output differs from `support/lint_last_known_acceptable.txt`. That file is empty (checked 2026-10-22), so any finding fails; if you fix an old finding while the file still lists it, regenerate it with `make golangci > support/lint_last_known_acceptable.txt`, as the script says, with the Go version CI uses, since the output depends on it. `.tool-versions` names golangci-lint 2.14.0, which `make lint` does not use. CI lints and runs `tests` in `gitlab-build-images/debian-<version>-golang-1.25` (`GO_VERSION` 1.25), and also tests on 1.26 and 1.27. (enforced; observed, 1 MR; `gitlab-org/gitlab-shell:support/lint.sh@5eef546a`, `gitlab-org/gitlab-shell:support/lint_last_known_acceptable.txt@1b33ff1c`, `gitlab-org/gitlab-shell:Makefile@232f5557`, `gitlab-org/gitlab-shell:.tool-versions@ace8ee04`, `gitlab-org/gitlab-shell:.gitlab-ci.yml@eae2499b`, [!1621](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1621))
- The `tests` job runs `make build` and `cp config.yml.example config.yml` before `make verify test_fancy`, with the CNG `gitaly` image as a service, started with a command that removes its hooks and sets `GITALY_TESTING_NO_GIT_HOOKS=1` so that no GitLab API is needed, and with `GITALY_CONNECTION_INFO` set to `{"address":"tcp://gitaly:8075", "storage":"default"}`; without that variable the gitlab-sshd tests that need Gitaly skip ("GITALY_CONNECTION_INFO is not set"). Do the same two setup steps locally, start the service with the job's command if you run it, and say in the MR whether Gitaly ran. `make acceptance-test` (`./acceptance/...`, tag `acceptance`) builds the binaries it runs itself, and its CI job has no services. (enforced; `gitlab-org/gitlab-shell:.gitlab-ci.yml@eae2499b`, `gitlab-org/gitlab-shell:cmd/gitlab-sshd/acceptance_test.go@c08c9e66`, `gitlab-org/gitlab-shell:acceptance/acceptancetest/binary.go@b78fb69f`, `gitlab-org/gitlab-shell:Makefile@232f5557`)
- Follow the LabKit logging rules: use the standard field names and add fields to the existing log line instead of logging a new line. Duo reviews against them and human reviewers asked for the same. (documented; `gitlab-org/gitlab-shell:.gitlab/duo/mr-review-instructions.yaml@7b12e9ad`, [!1534](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1534), [!1597](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1597))
- Write table-driven tests, use named constants and avoid duplicated code. (observed, 2 MRs; [!1597](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1597), [!1615](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1615))
- Expect review from the gitlab-shell maintainers group, whose Code Owner approval is required on `main` per `.gitlab/CODEOWNERS`; if the bot assigns a coach, they forward the MR there. (enforced; `gitlab-org/gitlab-shell:.gitlab/CODEOWNERS@4283599f`, [!1284](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1284))
- Treat Danger's milestone and type warnings as information. (documented; `gitlab-org/gitlab-shell:Dangerfile@b83c3189`, [!1555](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1555))
- Rebase on `main` instead of merging it into your branch, and answer review before it goes quiet. (observed, 1 MR; [!1148](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1148))
- Do not edit `VERSION` or `CHANGELOG`; maintainers release in a separate MR and then bump `GITLAB_SHELL_VERSION` in `gitlab-org/gitlab`. (documented; `gitlab-org/gitlab:doc/development/gitlab_shell/process.md@69a3ff35`)

## Troubleshooting

**A reviewer cannot apply a suggestion to your branch**
- Cause: the branch is in a personal fork they cannot push to.
- Fix: apply it yourself, or move the MR to the community fork.
- Who can fix it: you.
- Sources: [!1284](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1284)

## Why MRs here were closed

- Empty hackathon placeholder drafts ([!1041](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1041) to [!1051](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1051), [!1603](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1603), [!1604](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1604)).
- Stale after review said the test fix did not solve the goroutine problem ([!1148](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1148)); trivial changes ([!1158](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1158)); a duplicate ([!1596](https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1596)).
