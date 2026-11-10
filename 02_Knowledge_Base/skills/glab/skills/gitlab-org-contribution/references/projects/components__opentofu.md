# components/opentofu

The OpenTofu CI/CD component: a POSIX shell wrapper (`src/gitlab-tofu.sh`), Go tooling, images and many job templates. `README.md` is generated, backward compatibility is strict, and the community fork cannot run the jobs that lock OpenTofu state, so a maintainer runs the pipeline in the project. One code owner reviews and merges nearly everything.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | Shell, with Go tooling and CI templates |
| Fork to use | Community fork `gitlab-community/components/opentofu` (personal forks ran out of CI minutes) |
| Merge settings | Squash default off, merge trains on, pipeline must succeed, all threads must be resolved |
| Commit convention | None enforced; merged titles mix plain sentences and `fix:` prefixes |
| MR template | Default description in project settings (`%{all_commits}` plus `/label` lines), which takes priority over `default.md` (checked 2026-10-22; references/workflow.md, section 7) |
| Changelog | `CHANGELOG.md` exists; how it is produced is not documented (see open questions). Maintainers release with `make release VERSION=x.y.z` |
| Contributor docs | `CONTRIBUTING.md`; `README.md` is generated |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Do not edit `README.md` directly: edit `.gitlab/README.md.template`, or the variable header of `src/gitlab-tofu.sh` for variable docs, run `make docs`, and commit both. Several MRs were sent back for editing the generated file. (documented; `components/opentofu:CONTRIBUTING.md@61a171d4`, [!534](https://gitlab.com/components/opentofu/-/merge_requests/534), [!570](https://gitlab.com/components/opentofu/-/merge_requests/570))
- Run the bats tests for `src/gitlab-tofu.sh` and shellcheck, add integration tests in `.gitlab-ci.yml` for new inputs, and run `./.gitlab/scripts/update-opentofu-versions.sh` when you change the `opentofu_versions` input. (observed, 3 MRs; [!506](https://gitlab.com/components/opentofu/-/merge_requests/506), [!537](https://gitlab.com/components/opentofu/-/merge_requests/537), [!577](https://gitlab.com/components/opentofu/-/merge_requests/577))
- Keep changes backward compatible: name new variables with the `GITLAB_TOFU_` prefix, keep old inputs and variables working through a fallback, start a deprecated input's description with `**DEPRECATED**`, log an actionable warning when a deprecated variable is set, and pass a new input through every template that wraps the job (`full-pipeline`, `validate-plan-apply` and the rest). A break is accepted only in a major version. (observed, 5 MRs; [!454](https://gitlab.com/components/opentofu/-/merge_requests/454), [!498](https://gitlab.com/components/opentofu/-/merge_requests/498), [!496](https://gitlab.com/components/opentofu/-/merge_requests/496))
- Keep `src/gitlab-tofu.sh` POSIX sh (no bash arrays), and build command arguments there from environment variables the job sets rather than in the template's script. (observed, 3 MRs; [!506](https://gitlab.com/components/opentofu/-/merge_requests/506), [!498](https://gitlab.com/components/opentofu/-/merge_requests/498), [!568](https://gitlab.com/components/opentofu/-/merge_requests/568))
- Open an issue first for a larger feature (a new tool variant, a new backend mode). The component supports only GitLab-managed HTTP state, which has no workspaces, and its plan output must keep the fields the MR widget reads; options that conflict with either were declined, and a large MR left two years was closed with a request to start from an issue. (observed, 3 MRs; [!175](https://gitlab.com/components/opentofu/-/merge_requests/175), [!95](https://gitlab.com/components/opentofu/-/merge_requests/95), [!319](https://gitlab.com/components/opentofu/-/merge_requests/319))
- Expect the community fork pipeline to fail every job that locks OpenTofu state and the release tests that use the fork's registry (see Troubleshooting). Run the bats tests and the jobs you can, then ask someone with the Maintainer or Owner role in `components/opentofu` to run the pipeline there: a pipeline a Developer starts fails at the state lock too. (documented; observed, 5 MRs; `gitlab-org/gitlab:doc/user/infrastructure/iac/terraform_state.md@b41aa341`, `gitlab-org/gitlab:doc/ci/jobs/ci_job_token.md@43ecb41e`, [!506](https://gitlab.com/components/opentofu/-/merge_requests/506), [!577](https://gitlab.com/components/opentofu/-/merge_requests/577), [!537](https://gitlab.com/components/opentofu/-/merge_requests/537))
- `.gitlab/CODEOWNERS` names one owner for every path, and that person reviews and merges. If the bot assigns someone else, they usually hand over to the code owner; if the owner is away, say the MR can wait rather than asking others to merge it. (documented; `components/opentofu:.gitlab/CODEOWNERS@e6a1e025`, [!577](https://gitlab.com/components/opentofu/-/merge_requests/577))
- Answer review on naming and docs, or say you cannot continue; MRs whose authors stopped after review were closed after many months. (observed, 3 MRs; [!447](https://gitlab.com/components/opentofu/-/merge_requests/447), [!236](https://gitlab.com/components/opentofu/-/merge_requests/236), [!195](https://gitlab.com/components/opentofu/-/merge_requests/195))

## Troubleshooting

**In the community fork, unit and integration jobs fail at "Error acquiring the state lock" with "HTTP remote state endpoint invalid auth" (403)**
- Cause: a CI job token has the access level of the user who started the pipeline, and locking GitLab-managed state takes the Maintainer or Owner role. The fork's job token has no role in the project, and a pipeline a Developer starts in `components/opentofu` fails the same way: on !577 a merged results pipeline started there by a Developer failed all 24 `unit-test:gitlab-tofu` jobs at the lock, while the six `unit-test:gitlab-tofu:source` jobs passed. (documented; observed, 1 MR)
- Fix: list the jobs that failed and ask someone with the Maintainer or Owner role to run the pipeline in `components/opentofu`.
- Who can fix it: a Maintainer or Owner of `components/opentofu`.
- Sources: `gitlab-org/gitlab:doc/ci/jobs/ci_job_token.md@43ecb41e`, `gitlab-org/gitlab:doc/user/infrastructure/iac/terraform_state.md@b41aa341`, [!506](https://gitlab.com/components/opentofu/-/merge_requests/506), [!577](https://gitlab.com/components/opentofu/-/merge_requests/577), https://gitlab.com/components/opentofu/-/pipelines/2974424714

**A personal-fork pipeline stops because the namespace ran out of CI minutes**
- Fix: move the branch to the community fork and open a new MR, copying open comments and linking the old one.
- Who can fix it: you.
- Sources: [!505](https://gitlab.com/components/opentofu/-/merge_requests/505), [!541](https://gitlab.com/components/opentofu/-/merge_requests/541), [!432](https://gitlab.com/components/opentofu/-/merge_requests/432)

**You are asked to redo a `README.md` edit**
- Cause: `README.md` is generated from `.gitlab/README.md.template` and the script header.
- Fix: revert the edit, change the source, run `make docs` and commit both.
- Who can fix it: you.
- Sources: [!534](https://gitlab.com/components/opentofu/-/merge_requests/534)

## Why MRs here were closed

- Reopened from the community fork after the personal fork ran out of CI minutes ([!239](https://gitlab.com/components/opentofu/-/merge_requests/239), [!360](https://gitlab.com/components/opentofu/-/merge_requests/360), [!432](https://gitlab.com/components/opentofu/-/merge_requests/432), [!505](https://gitlab.com/components/opentofu/-/merge_requests/505), [!541](https://gitlab.com/components/opentofu/-/merge_requests/541)).
- Stale drafts and authors who stopped after review ([!175](https://gitlab.com/components/opentofu/-/merge_requests/175), [!236](https://gitlab.com/components/opentofu/-/merge_requests/236), [!447](https://gitlab.com/components/opentofu/-/merge_requests/447), [!195](https://gitlab.com/components/opentofu/-/merge_requests/195)).
- Design limits: workspaces on the HTTP backend ([!95](https://gitlab.com/components/opentofu/-/merge_requests/95)), a filter the MR widget needs ([!319](https://gitlab.com/components/opentofu/-/merge_requests/319)); a large docs restructure with a default change, closed the same day without comment ([!486](https://gitlab.com/components/opentofu/-/merge_requests/486)).
- Replaced by the author's own new MR ([!339](https://gitlab.com/components/opentofu/-/merge_requests/339), [!372](https://gitlab.com/components/opentofu/-/merge_requests/372)); withdrawn without a reason ([!359](https://gitlab.com/components/opentofu/-/merge_requests/359)).

## Open questions

- How `CHANGELOG.md` is produced is not documented; some MRs carry a `Changelog:` line in the description, but no tooling that reads it was confirmed.
