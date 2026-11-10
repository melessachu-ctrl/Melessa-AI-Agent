# gitlab-org/ci-cd/docker-machine

GitLab's fork of Docker Machine, used by GitLab Runner's `docker+machine` autoscaling executor. `CONTRIBUTING.md` and the project's default MR template say it accepts only critical bug fixes that affect running costs; feature MRs are closed, even after long work. There is no community fork; personal-fork pipelines do run.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | Go |
| Fork to use | Personal fork (no community fork exists, checked 2026-10-22) |
| Merge settings | Squash default off, merge trains on, pipeline must succeed |
| Commit convention | None documented |
| MR template | The project's default description (set in project settings): a warning banner, then what critical bug the MR fixes, how it reduces the cost of usage and by how much, and in which `docker+machine` scenarios it applies |
| Changelog | `CHANGELOG.md` is the release record since !207 (merged 2026-10-19): an MR that changes what users get adds its bullet there (see Rules) |
| Contributor docs | `CONTRIBUTING.md` and `AGENTS.md`; `docs/` is upstream Docker Machine documentation, and the GitLab-specific notes live in the GitLab Runner docs |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Propose only fixes for critical bugs that affect running costs, and answer the template's three questions (the bug, the cost reduction and its scale, the `docker+machine` scenarios). Do not open MRs for features such as new drivers, driver API upgrades or new OS support; a maintainer suggested `rancher/machine` as an alternative for such needs. (documented; `gitlab-org/ci-cd/docker-machine:CONTRIBUTING.md@f9f13f0f`, [!157](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/157), [!51](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/51), [!108](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/108))
- Search closed MRs before proposing a change; the same OS support was declined twice. (observed, 1 MR; [!108](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/108))
- Run `make test` (fmt, short tests, lint, vet and unit tests) and `make validate` (all tests with race detection) before pushing, and add tests for the code you change. (documented; `gitlab-org/ci-cd/docker-machine:CONTRIBUTING.md@f9f13f0f`)
- An MR that changes what users get (a fix, a new or changed flag, environment variable or behaviour, a Go or Go module update) adds one bullet to `CHANGELOG.md`; one that only changes tests, CI or docs does not. Put it in the newest `## v<version>` section while that version is not tagged (`git ls-remote --tags origin 'v*'` against the project lists the tags); if it is tagged, start `## v0.16.2-gitlab.<N+1>` at the top and set `Version` in `version/version.go` to match, and never edit a tagged section. Start the bullet with Add, Fix, Change, Update or Remove, say what a user sees or has to do, and end it with `See <the MR's full URL>.`. GitLab Duo's review asks for the same, and the `release check` job fails an MR that gets the section or the version wrong. (documented; enforced; `gitlab-org/ci-cd/docker-machine:AGENTS.md@123b5ade`, `gitlab-org/ci-cd/docker-machine:.gitlab/duo/mr-review-instructions.yaml@123b5ade`, `gitlab-org/ci-cd/docker-machine:.gitlab/ci/scripts/release_check.sh@a3762821`, [!207](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/207), [!210](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/210))
- Run `.gitlab/ci/scripts/release_check.sh` yourself, in a clone whose `origin` is the canonical project, before you push a changelog change, and delete the `release/` directory it writes. In a pipeline of your fork the job reads the tags of `origin`, which there is your fork, with the tags it had when it was created or last synced, so it can pass there for a section the project has already tagged and fail later in the project's own pipeline. (enforced; `gitlab-org/ci-cd/docker-machine:.gitlab/ci/scripts/release_check.sh@a3762821`)
- Before a dependency or toolchain bump, check `main`, the releases and the runner base images: such bumps often land through other channels, and duplicates were closed. (observed, 2 MRs; [!163](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/163), [!167](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/167))
- Resolve conflicts locally with a rebase rather than in the web UI, and cite where any image or AMI ID comes from; an approved MR dropped from the merge train twice was finished by a maintainer after a conflict in a removed `vendor/` file. (observed, 1 MR; [!111](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/111))
- Keep your fork's pipelines visible to maintainers: a public fork, with CI/CD set to "Everyone With Access" under Settings > General > Visibility, project features, permissions. The project's own CI/CD is visible to its members only (`builds_access_level` `private`, checked 2026-10-23), and a fork copies the project's feature settings when it is created, so a public fork still hides its pipelines until you change that (enforced; `gitlab-org/gitlab:app/services/projects/fork_service.rb@2fc74372`). Expect reviews to take weeks; there is no `CODEOWNERS` file, and runner maintainers review and merge. (observed, 2 MRs; [!91](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/91), [!45](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/45))

## Why MRs here were closed

- Outside the critical-cost policy: new OS support and a driver API upgrade ([!51](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/51), [!108](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/108), [!157](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/157)).
- Stale after unanswered review or long idle drafts ([!37](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/37), [!45](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/45), [!53](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/53), [!91](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/91), [!94](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/94), [!161](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/161)).
- Already done on `main` or superseded ([!121](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/121), [!163](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/163), [!167](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/167), [!101](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/101)); finished by a maintainer ([!111](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/111)); closed minutes after opening while a same-titled MR merged ([!105](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/105)).

## Troubleshooting

**An approved MR drops out of the merge train**
- Cause: a conflict with `main`, for example in a file `main` has removed (a `vendor/` path).
- Fix: rebase locally on `main`, resolve the conflict there rather than in the web UI, force-push with lease, and ask the maintainer to approve and add the MR to the train again.
- Who can fix it: you, then a maintainer.
- Sources: [!111](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/111)

**Maintainers cannot see your pipeline**
- Cause: there is no community fork, and a personal fork hides its pipelines while it is private or while its CI/CD visibility is "Only Project Members", which it copies from the project.
- Fix: make the fork public and set its CI/CD to "Everyone With Access", or post the local `make test` and `make validate` output in the MR.
- Who can fix it: you.
- Sources: `gitlab-org/gitlab:app/services/projects/fork_service.rb@2fc74372`, [!91](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/91), [!45](https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/45)

**Anything else**
- Personal-fork pipelines run on your own CI minutes and runners; see references/troubleshooting.md for those failures.
