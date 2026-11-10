# gitlab-org/charts/gitlab

The GitLab Helm chart (cloud-native GitLab on Kubernetes). It is a Distribution project, so `@gitlab-bot ready` assigns nobody. It uses `Changelog:` trailers, RSpec template specs under `spec/`, a QA job whose result a reviewer records with `QA:verified`, and an e2e job that posts an Allure report.

| Fact | Value |
| --- | --- |
| Default branch | `master` |
| Languages | Ruby (specs), Go templates (Helm) |
| Fork to use | Community fork `gitlab-community/gitlab-org/charts/gitlab` |
| Merge settings | Squash default on, squash message template `%{first_commit}`, all threads must be resolved |
| Commit convention | gitlab-dangerfiles defaults; plain-sentence titles |
| MR template | `Default.md` (asks for e2e validation evidence for template changes), `Documentation.md` |
| Changelog | `Changelog:` git trailer, optional `MR:` trailer |
| Contributor docs | `CONTRIBUTING.md`, `doc/development/changelog.md`, `AGENTS.md`, `.gitlab/duo/mr-review-instructions.yaml` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Requesting review

- `@gitlab-bot ready` only changes the label here: triage-ops skips reviewer assignment for every project on the Distribution team's list, which includes this chart. Danger's message telling you to use `@gitlab-bot ready <@user>` does not reflect that. Request the review through the contributor platform's request-review link, or mention the reviewer you chose from Danger's roulette or `.gitlab/CODEOWNERS` in a comment. (enforced; `gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867`, `gitlab-org/distribution/monitoring:lib/data_sources/projects.yaml@b023e99a`, [!5458](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5458))

## Commits and changelog

- Add a `Changelog:` trailer (added, fixed, changed, deprecated, removed, security, performance, other) and put it on the first commit of the branch: squash uses the first commit's message (`%{first_commit}`), so a trailer on a later commit is dropped. Add an `MR:` trailer with the full MR URL only to point at a different MR. (documented and enforced by the project's squash template; `gitlab-org/charts/gitlab:doc/development/changelog.md@5f6d4be1`, [!5394](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5394), [!5369](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5369))
- Start with a single commit (`git rebase -i`) and rebase when the branch no longer merges cleanly, as `CONTRIBUTING.md` asks. (documented; `gitlab-org/charts/gitlab:CONTRIBUTING.md@74bad3e2`)

## Tests and checks

- Cover template changes with RSpec specs under `spec/` (render the chart with the new values and assert the output), and add a `checkConfig` rule (`templates/_checkConfig_*.tpl`) plus its spec when you introduce a configuration constraint. For runtime behavior changes, show an install on a cluster or point to the e2e job's result, as the Default template asks. (observed, 6 MRs; [!5188](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5188), [!5215](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5215), [!5462](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5462))
- Locally: `bundle exec rspec` on the specs for the templates you touched, `helm template` or `helm lint` with the values you changed, and markdownlint-cli2 and Vale on changed docs. `AGENTS.md` lists the commands (`bundle install`, `bundle exec rspec spec/path/to_spec.rb`, `bundle exec rubocop`, `helm dependency update`, `helm lint .`, `helm template . -f values.yaml`), with Vale and markdownlint for docs and mise for the tools; `CONTRIBUTING.md` names none. (documented; `gitlab-org/charts/gitlab:AGENTS.md@042bd4b7`)
- The specs render the chart with `helm template` and parse the output, some of it with gomplate, so they need Ruby 3.3.12 (`RUBY_VERSION` in `.gitlab-ci.yml`; there is no `.ruby-version`), Helm 4.3.1 (`HELM_VERSION`, also in `mise.toml`), gomplate and the dependency charts in `charts/` (`helm dependency update`, or `scripts/ci/ensure_chart_deps.sh`, which skips `helm dependency build` when `charts/` already matches `Chart.lock`). The spec job installs gomplate v5.0.0 only when its image has none (or with `STRICT_VERSIONS=true`), while `mise.toml` pins 5.2.0. Specs under `spec/features` need a cluster and run only when `kubectl get nodes` succeeds. Each `it` block runs a Helm template, which `doc/development/rspec.md` calls time and resource intensive, so run the files for the templates you touched, or tag examples `:focus` while you work. The spec jobs run in a public `gitlab-build-images` image named in `.gitlab-ci.yml` if you need CI's environment. (enforced; documented; observed, anonymous pull checked 2026-10-22; `gitlab-org/charts/gitlab:.gitlab-ci.yml@d090f2c7`, `gitlab-org/charts/gitlab:scripts/ci/install_spec_dependencies.sh@28a21e25`, `gitlab-org/charts/gitlab:mise.toml@28a21e25`, `gitlab-org/charts/gitlab:scripts/ci/run_specs.sh@ee5964f1`, `gitlab-org/charts/gitlab:scripts/ci/ensure_chart_deps.sh@ee5964f1`, `gitlab-org/charts/gitlab:doc/development/rspec.md@8d4b0a17`, `gitlab-org/charts/gitlab:AGENTS.md@042bd4b7`)
- `check_docs_content` (`vale --minAlertLevel error doc`) and `check_docs_markdown` (`markdownlint-cli2 'doc/**/*.md'` and `rumdl check --config doc/.rumdl.toml doc`) run in the docs-gitlab-com lint image that `DOCS_LINT_IMAGE` names in `.gitlab-ci.yml`; run those lines from the repository root in that tag. (enforced; `gitlab-org/charts/gitlab:.gitlab-ci.yml@d090f2c7`, `gitlab-org/charts/gitlab:.gitlab/ci/checks.gitlab-ci.yml@47a3ae13`)
- Leave `QA:verified` to the reviewer: Danger asks for it after someone compares the QA job with `master`. (enforced; `gitlab-org/charts/gitlab:danger/metadata/Dangerfile@1eed5bfd`, [!5215](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5215))

## Before you start

- Check that the issue is not assigned and that no other MR exists. When two contributors fixed the same unassigned issue, the maintainer kept the MR with better test coverage, not the first one. (observed, 2 MRs; [!5347](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5347), [!5335](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5335))
- Check that existing settings do not already solve the problem; an MR was closed when maintainers showed they did. (observed, 1 MR; [!5188](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5188))

## Troubleshooting

**After `@gitlab-bot ready`, the MR is labelled ready but no reviewer is requested**
- Cause: reviewer assignment is skipped for Distribution projects.
- Fix: use the contributor platform's request-review link, or mention your chosen reviewer.
- Who can fix it: you.
- Sources: `gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867`

**The community fork pipeline is not created, or `review-docs-deploy` is blocked on a gitlab-org secret source**
- Cause: fork pipelines cannot read the secret source that job uses; an old base also affected pipeline creation.
- Fix: rebase onto `master` and push; if it still fails, ask the reviewer to run the pipeline upstream.
- Who can fix it: you, then a maintainer.
- Sources: [!5455](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5455), [!5458](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5458)

**The MR shows no diff after you merged `master` into your branch**
- Cause: the merge or a reset left your commits out.
- Fix: restore them from `git reflog` and push before asking for review.
- Who can fix it: you.
- Sources: [!5463](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5463), [!5464](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5464)

## Why MRs here were closed

Nine of 15 closed community MRs were auto-closed after reviewers asked for specs, docs or rebases that never came, some after two or three years open ([!3360](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/3360), [!3621](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/3621), [!3833](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/3833), [!4231](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/4231), [!4971](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/4971)), or with a failing pipeline and no review requested ([!5282](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5282), [!5291](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5291)). Others: existing settings already solved the problem ([!5188](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5188)), competing MRs for one issue ([!5335](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5335), [!5347](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5347)), branches left with no diff ([!5463](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5463)), and a reopen from the community fork ([!5312](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5312)).
