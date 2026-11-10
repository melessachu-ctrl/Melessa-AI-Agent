# gitlab-org/ci-cd/custom-executor-drivers/fargate

The AWS Fargate driver for GitLab Runner's custom executor, in Go. It is a small project where reviews can take a long time, because changes are tested by hand on a real AWS setup and releases are cut manually after merges. Some MRs waited more than a year and were closed. If nobody answers after a week or two, ask a coach for another reviewer with `@gitlab-bot help` rather than pinging the same person again.

| Fact | Value |
| --- | --- |
| Default branch | `master` |
| Language | Go |
| Fork to use | Community fork `gitlab-community/gitlab-org/ci-cd/custom-executor-drivers/fargate` (pipelines run there) |
| Merge settings | Squash default off (commits land as written), merge trains on, pipeline must succeed |
| Commit convention | None documented; plain imperative titles |
| MR template | The project's default description (set in project settings, not a file): what the MR does, why, how to test, related issues |
| Changelog | None; maintainers publish releases on the project's Releases page |
| Contributor docs | `CONTRIBUTING.md` (DCO and code of conduct only); configuration reference in `docs/README.md` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Run `go test ./...` and `make lint` (golangci-lint with a strict gocyclo limit; existing long functions carry `//nolint:gocyclo`) before pushing. After changing any interface, run `make mocks` and commit the regenerated mocks; the `check_mocks` job fails otherwise. (enforced; [!94](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/94), [!72](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/72), [!81](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/81), [!106](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/106))
- Test on a real AWS setup when you can (`make compile_all`, then replace the driver binary on the runner) and describe how a reviewer can reproduce it: the `fargate.toml` section, the task definition fragment and a job that exercises the change. "The test suite should catch any issues" was not accepted. (observed, 4 MRs; [!92](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/92), [!81](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/81), [!85](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/85), [!72](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/72))
- Document every new option or behavior in `docs/README.md`: a row in the configuration table (option, type, required, default, description) and, for bigger features, a short section on when to use it. (observed, 4 MRs; [!93](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/93), [!94](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/94), [!76](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/76), [!85](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/85))
- For connection reliability problems (SSH refused, task not ready), do not send a fixed sleep and one retry; propose a configurable wait or retry, or a health-check based wait, and agree on it in the issue first. Read earlier closed MRs for the same problem. (observed, 3 MRs; [!73](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/73), [!84](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/84), [!85](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/85))
- Keep new behavior opt-in and protect configurations you do not use: a change that required new sshd configuration was closed as breaking and belonging in gitlab-runner, and hardcoding the Fargate launch type would have broken ECS clusters on EC2. (observed, 2 MRs; [!94](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/94), [!40](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/40))
- One concern per MR: send unrelated fixes and dependency updates separately, make new waits configurable instead of leaving a TODO, and add tests. (observed, 1 MR; [!61](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/61))
- There is no `CODEOWNERS` file; reviews come from runner engineers. `@gitlab-bot ready` routes the MR to a coach, who forwards it. If one reviewer stays silent, ask the coach (or a reviewer from the history of the files you touched) for another rather than pinging the same person for months. (observed, 3 MRs; [!39](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/39), [!42](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/42), [!52](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/52))
- Work on a topic branch with CI/CD enabled in your fork (or in the community fork), and check that a pipeline appears on the MR; one MR from a `master` branch ran no pipeline and another from a fork with CI/CD disabled had to be finished by a maintainer. (observed, 2 MRs; [!59](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/59), [!66](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/66))
- A merged change reaches users only when a maintainer cuts a release, usually after a batch of MRs; ask politely in the merged MR if you need to know when. (observed, 3 MRs; [!107](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/107), [!93](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/93), [!81](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/81))

## Troubleshooting

**`check_mocks` fails, or tests fail after you regenerated mocks**
- Cause: an interface changed and the committed mocks were not regenerated, or test expectations do not match the new mock call signatures.
- Fix: run `make mocks`, commit the regenerated files, then update the mock expectations in the tests (for example the arguments expected on `ExecuteScript`); ask the reviewer if one still fails.
- Who can fix it: you.
- Sources: [!94](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/94), [!72](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/72)

**`TestSSHIntegration` fails in CI but not locally, or you cannot run it locally**
- Cause: the test needs the SSH service image and is known to be flaky.
- Fix: run `make prepare_ssh_service_image` (with the CI Go and Alpine versions), `docker run -p8888:8888 -p2222:2222 fargate-ssh-service-image`, then `go test -count=1 -run TestSSHIntegration ./executors/ssh/...`. If it passes locally, say so and ask the maintainer to retry.
- Who can fix it: a maintainer or member.
- Sources: [!62](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/62)

## Why MRs here were closed

- Waits for review of a year or more, after which the authors stopped ([!39](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/39), [!42](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/42), [!52](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/52)); a WIP fix left with unresolved design concerns ([!40](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/40)); an empty draft ([!99](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/99)).
- Approach rejected: simplistic retries ([!73](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/73), [!84](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/84)), a breaking change in the wrong project ([!94](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/94)).
- Superseded: the capability landed in gitlab-runner ([!59](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/59)), split into smaller MRs ([!61](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/61)), finished by a maintainer with credit because the fork ran no pipeline ([!66](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/66)), and taken over by a coach from the community fork when the author had no time ([!95](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/95)).
