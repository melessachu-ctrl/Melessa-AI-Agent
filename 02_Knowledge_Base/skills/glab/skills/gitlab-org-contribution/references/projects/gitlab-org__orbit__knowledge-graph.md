# gitlab-org/orbit/knowledge-graph

GitLab Orbit, a Rust service that turns GitLab SDLC data and source code into a queryable property graph. It has Conventional Commits enforced by commitlint, an MR template with strict word limits, many generated-artifact checks (skill versions, metrics catalog, dashboards, ontology, DDL), and a stale-MR sweeper of its own beside gitlab-bot.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | Rust |
| Fork to use | Community fork `gitlab-community/gitlab-org/orbit/knowledge-graph` |
| Merge settings | Squash always, pipeline must succeed |
| Commit convention | Conventional Commits, checked by commitlint in lefthook and on the MR title in CI |
| MR template | `.gitlab/merge_request_templates/Default.md` |
| Changelog | semantic-release from Conventional Commits; no manual entry |
| Contributor docs | `CONTRIBUTING.md`, `AGENTS.md` (byte-identical `CLAUDE.md`), `CONTEXT.md`, `docs/design-documents/` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Fork and issues

- Open the MR from the community fork. Personal forks lack the runners and dependency proxy the CI needs, and one contributor hit the personal storage limit and could not rebase; several MRs were reopened from the community fork. (documented; `gitlab-org/orbit/knowledge-graph:CONTRIBUTING.md@2b8c4085`, [!1640](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1640), [!978](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/978))
- Start from issues labelled `orbit::hackathon`, and confirm larger changes fit the team's direction first. New documentation sections and changes to shared conventions need a team decision; MRs were closed because the team had not decided on a docs path, preferred another approach, or found the issue itself was wrong. (documented and observed, 3 MRs; `gitlab-org/orbit/knowledge-graph:CONTRIBUTING.md@2b8c4085`, [!1785](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1785), [!2121](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2121), [!1635](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1635))

## Title, commits and description

- Use Conventional Commits for the MR title and commits: `type(scope): short description` (feat, fix, docs, test, chore, refactor). commitlint runs on commits through lefthook and on the title in CI. (enforced; `gitlab-org/orbit/knowledge-graph:.commitlintrc.yml@902e4768`, `gitlab-org/orbit/knowledge-graph:lefthook.yml@d72a5285`)
- Follow the template's limits: "What does this MR do and why?" in at most 80 words and 3 code spans, describing the user-visible symptom and fix without function or type names; one or two lines of Testing with a job link; Related Issues (`Closes` or `Relates to` for anything beyond a typo or minor bump); Performance Analysis; and all mechanics, alternatives and long output inside the collapsed Agent context block. Add one type label and an `orbit::` area label. (documented; `gitlab-org/orbit/knowledge-graph:.gitlab/merge_request_templates/Default.md@adea9b2d`, `gitlab-org/orbit/knowledge-graph:CONTRIBUTING.md@2b8c4085`)
- If an AI agent drafts the MR, `AGENTS.md` asks for the CI-skip marker it names at the end of the Conventional Commits title while it is a draft. Remove the marker and push when you want a pipeline, because editing the title alone starts none. Issues and epics must be created by a person; an agent may only draft them inside the Agent context block, with your approval. (documented; `gitlab-org/orbit/knowledge-graph:AGENTS.md@2b8c4085`)

## Local checks before pushing

- Use the mise tasks: `mise build`, `mise test:fast`, `mise test:integration` (Docker), `mise lint:code` (Clippy with warnings as errors), `cargo fmt --check`, and `mise lint:docs` (markdownlint, Vale, lychee) for docs. Install the lefthook hooks: they check formatting, comments, log safety in Rust crates (`mise run lint:logs`, which the `log-safety-check` CI job also runs), prose, that `AGENTS.md` and `CLAUDE.md` are identical, skill and prompt version bumps, the CI configuration (`glab ci lint`), the ontology schema and secrets. (documented; enforced; `gitlab-org/orbit/knowledge-graph:.gitlab-ci.yml@84b03cbc`, `gitlab-org/orbit/knowledge-graph:AGENTS.md@2b8c4085`, `gitlab-org/orbit/knowledge-graph:lefthook.yml@d72a5285`)
- `mise test:integration` and the other `test:integration:*` tasks set `DOCKER_HOST` to `~/.colima/gkg/docker.sock` and say they need the Colima `gkg` profile (`colima start gkg --memory 12`). With another Docker daemon, run `./scripts/dev/run-container-tests.sh` with the task's arguments under your own `DOCKER_HOST`, since the task's `env` overrides yours. Outside CI, mise also sets `RUSTC_WRAPPER=sccache` (it installs sccache 0.13.0); `export RUSTC_WRAPPER=` turns that off. Rust 1.98.1 comes from `mise.toml`, and `rust-toolchain.toml` is generated from it. (documented; `gitlab-org/orbit/knowledge-graph:mise.toml@5e37f962`, `gitlab-org/orbit/knowledge-graph:rust-toolchain.toml@30b2e818`)
- CI lints docs in the docs-gitlab-com lint image at an older tag than other projects use, `alpine-3.23-vale-3.14.1-markdownlint2-0.22.1-lychee-0.24.2`; to reproduce a docs lint failure, run the job's lines (for example `vale --minAlertLevel error docs/source` and `markdownlint-cli2 '*.md' 'docs/dev/**/*.md' 'docs/source/**/*.md'`) in that tag from the repository root. (enforced; `gitlab-org/orbit/knowledge-graph:.gitlab-ci.yml@84b03cbc`)
- Regenerate what your change feeds: bump the skill version under `skills/` when skill or query-language documentation text changes (the CLI caches skills by version, so two open MRs must not ship different content under one version; if another open MR bumps the same version, take a different number and rebase whichever merges second), regenerate the metrics catalog and dashboards with `cargo xtask dashboards` after metric changes, and bump `SCHEMA_VERSION` and run `mise schema:generate:ddl` after ontology storage changes (`mise ontology:validate` too). (enforced; [!2532](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2532), [!2650](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2650), [!2651](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2651))
- A change to Rust code, `Cargo.toml`, `Cargo.lock`, `rust-toolchain.toml` or `.cargo/config.toml` also runs `windows-cli-check`, a `cargo check` of the `orbit` binary (crate `orbit-cli`) for `x86_64-pc-windows-gnullvm`, so everything that binary compiles has to build for Windows; tests are not checked there, because some are Unix-only. (enforced; `gitlab-org/orbit/knowledge-graph:.gitlab-ci.yml@84b03cbc`)
- When no version bump is needed, a marker in the description skips the check (`[skip pinned-version-check]`, `[skip query-dsl-version-check]`); explain why in the Agent context block. The marker is read when the pipeline is created, so start a new pipeline after adding it. (observed, 3 MRs; [!2650](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2650), [!1841](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1841))

## Docs and code style

- Keep `docs/` out of an MR that changes code, and put the docs change in a docs MR of its own. Since [!3004](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/3004) (merged 2026-10-23) the `docs-in-code-mr-check` job fails an MR that changes a file under `docs/`, other than `docs/source/remote/queries/query-language.md` and `docs/dev/agents-crate-map.md`, together with any file outside `docs/` that is not Markdown or docs lint configuration (`.vale*`, `.markdownlint*`, `lychee.toml`); before it, the rule was to update the owning design document in the same MR as a behavior change. When a CI or build check fails without the docs change, the `docs-in-code-mr` label lets it through: `@gitlab-bot label` does not accept that label, so ask a member to add it, then retry the job. Rewrite stale text instead of preserving history, use the canonical terms in `CONTEXT.md`, and keep comments to why rather than what (a narration lint runs). (documented; enforced; `gitlab-org/orbit/knowledge-graph:CONTRIBUTING.md@2b8c4085`, `gitlab-org/orbit/knowledge-graph:AGENTS.md@2b8c4085`, `gitlab-org/orbit/knowledge-graph:.gitlab-ci.yml@84b03cbc`, `gitlab-org/quality/triage-ops:triage/processor/community/command_mr_label.rb@46a48236`, [!3004](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/3004), [!2121](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2121))

## Review

- Pick a reviewer from Danger's roulette or `.gitlab/CODEOWNERS` (or the engineer who last worked on the area) and request with `@gitlab-bot ready @<reviewer>`; the reviewer approves and asks a maintainer. Mentioning a maintainers group is not a review request; an MR that only did that was auto-closed. Project bots also post benchmark results and an AI review. (observed, 1 MR closed for it; [!1841](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1841))
- Verify each review point against the code before replying, and reply with what you checked, the commit that fixed it and the exact wording you changed. (observed, 3 MRs; [!2531](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2531), [!2532](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2532))

## Stale MRs

- Besides gitlab-bot, a daily project sweeper labels MRs with no activity for 14 days `stale::scheduled_for_closing` and closes them 3 days later unless a push, a comment or `stale::keep` resets it. Its current configuration skips MRs labelled Community contribution, but earlier community MRs were swept, so check the label is on yours. (enforced; `gitlab-org/orbit/knowledge-graph:.gitlab/ci/stale-mr.yml@de545736`, [!1764](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1764), [!2121](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2121))

## Troubleshooting

**`lint:prose` fails with "diff base ... is unreachable" in a fork pipeline**
- Cause: `CI_MERGE_REQUEST_SOURCE_BRANCH_SHA` is empty outside merged results pipelines; fixed by [!2676](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2676) in October 2026.
- Fix: rebase onto current `main`.
- Who can fix it: you.
- Sources: [!2651](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2651)

**`pinned-version-check` fails with "fatal: origin/main...HEAD: no merge base"**
- Cause: the job fetched `main` at depth 1; fixed by [!2746](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2746) in October 2026, after which the job exits 0 without a base.
- Fix: rebase onto `main`; if no bump is needed, add `[skip pinned-version-check]` and start a new pipeline. If a check still cannot pass outside a merged results pipeline, explain why and ask a member to run the pipeline in the canonical project.
- Who can fix it: you, then a member.
- Sources: [!2532](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2532), `gitlab-org/orbit/knowledge-graph:.gitlab-ci.yml@84b03cbc`

**`migration-ledger-check`: "SCHEMA_VERSION must be exactly base + 1", or `dashboards-check` reports stale dashboards**
- Cause: `main`'s ledger advanced under your branch, or metric labels changed without regenerating.
- Fix: rebase onto `main`; run `cargo xtask dashboards` and commit.
- Who can fix it: you.
- Sources: [!2532](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2532)

**A project bot adds `stale::scheduled_for_closing`: "will be closed in 3 days"**
- Cause: 14 days without activity.
- Fix: push or comment within 3 days, or ask a maintainer for `stale::keep`.
- Who can fix it: you.
- Sources: [!1764](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1764)

**Personal fork pipeline fails for missing runners or dependency proxy, or you cannot push for storage**
- Cause: personal forks use your quotas and lack the community fork's runners and dependency proxy.
- Fix: push to the community fork, open the MR there, close the old one with a link.
- Who can fix it: you.
- Sources: [!1640](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1640), [!978](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/978)

**A new MR appears after you clicked "Fix failing pipeline"**
- Cause: the Duo button creates a separate MR.
- Fix: close the extra MR and fix your original branch.
- Who can fix it: you.
- Sources: [!368](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/368)

## Why MRs here were closed

- Reopened from the community fork after personal-fork CI or storage problems ([!1633](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1633), [!1640](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1640), [!1641](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1641), [!978](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/978)).
- Stale: failing pipeline and no review requested ([!1764](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1764), [!1842](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1842), [!1878](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1878), [!2119](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2119)), or a group mention instead of a review request ([!1841](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1841)).
- Team decisions: an undecided docs path ([!1785](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1785)), another approach chosen for consistency ([!2121](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2121)), a more fundamental starting point requested ([!886](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/886)), an issue filed in error ([!1635](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/1635)).
- Accidental MR from the Fix failing pipeline button ([!368](https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/368)).

## Open questions

- When the sweeper's exclusion of Community contribution MRs started; earlier community MRs were swept.
