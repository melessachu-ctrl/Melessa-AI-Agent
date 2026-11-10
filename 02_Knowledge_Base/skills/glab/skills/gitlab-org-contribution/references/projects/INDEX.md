# Project index

Read the general rules of this skill first; the files below add only what is specific to one project. Find the project you are contributing to, read its file, and follow the project's own rule where it differs from the general one.

The table is ordered by merged community contributions since 2026-04, so the projects where you are most likely to contribute come first.

## Legend

Each rule in a project file ends with its kind and its sources:

- **enforced**: a bot, linter, Danger rule or CI job checks it; the source is that file.
- **documented**: written in the project's `CONTRIBUTING.md`, `AGENTS.md`, templates or development docs; the source is that file.
- **observed (N MRs)**: reviewers asked for it, or it happened, in N merge requests; the sources are those MRs. Where an observed preference conflicts with the docs, the rule says so.

A source is either a link to a public MR or issue on gitlab.com, or a file written as `<project path>:<file path>@<sha>`. The sha is the last commit that touched the file when it was read, written in full in the general reference files and as its first eight characters in the project files. `sources.json` in [jmrp/gitlab-org-contribution-skill](https://gitlab.com/jmrp/gitlab-org-contribution-skill), the repository each release of this skill comes from, pins every watched file by blob id (`sha`, which is what the drift check compares) and records that same commit beside it (`commit`). Facts marked "checked <date>" or "read <date>" (2026-10-19, 2026-10-21, 2026-10-22, 2026-10-23, 2026-10-24 or 2026-10-26) were read live on that date. Each project file has the same parts where material exists: a facts table (default branch, fork to use, merge settings, commit convention, MR template, changelog, docs), rules, troubleshooting (symptom, cause, fix, who can fix it), why MRs were closed, and open questions.

## Project not listed

The skill covers every project in `gitlab-org`, the public `gitlab-com`
projects and `components`, but has a file for only some of them. For any other
project, before you write code:

1. Read `AGENTS.md`, `CONTRIBUTING.md` (and the docs it links), the MR and issue templates under `.gitlab/`, the `Dangerfile` and `danger/` directory, `CODEOWNERS` (often `.gitlab/CODEOWNERS`) and any `lefthook.yml` or pre-commit config. Some projects keep their default MR and issue descriptions in project settings rather than in a `Default.md` file; read `merge_requests_template` and `issues_template` from the API call in step 3 (references/workflow.md, section 7).
2. Check for a community fork at `https://gitlab.com/gitlab-community/<full project path>`; if there is none, read references/workflow.md, section 6.
3. Read the merge settings through the API, `GET https://gitlab.com/api/v4/projects/<url-encoded path>` with any account's token (an anonymous call leaves out every field below but `default_branch`, which does not mean they are null): `default_branch`, `squash_option`, `squash_commit_template` (null means a squashed MR lands as its title alone; references/commits-and-descriptions.md, Changelog entries), `merge_method`, `merge_trains_enabled` and `only_allow_merge_if_all_discussions_are_resolved`.
4. Sample recent merged MRs labelled `Community contribution` (`GET /projects/<id>/merge_requests?state=merged&labels=Community%20contribution`) for how titles, commits, descriptions and labels look there, and who reviewed and merged them.
5. Then apply the general rules in SKILL.md and its references.

## Projects

| Project | Language | Community fork | File | What is special |
| --- | --- | --- | --- | --- |
| `gitlab-org/gitlab` | Ruby, JavaScript, Vue, Go | yes | [gitlab-org__gitlab.md](gitlab-org__gitlab.md) | Monorepo with the strictest Danger, `Changelog:` trailers, EE rules, docs reviewed by technical writers, and pre-merge checks that need a recent canonical pipeline |
| `gitlab-org/developer-relations/contributor-success/contributors-gitlab-com` | JavaScript, Ruby, Vue | yes | [gitlab-org__developer-relations__contributor-success__contributors-gitlab-com.md](gitlab-org__developer-relations__contributor-success__contributors-gitlab-com.md) | The contributor platform itself; squash always, Duo reviews, hackathon rules and the platform guide live here |
| `gitlab-org/cli` | Go | yes | [gitlab-org__cli.md](gitlab-org__cli.md) | glab: the squashed MR title is a Conventional Commit and a release-note line; command docs are generated from help text |
| `gitlab-org/terraform-provider-gitlab` | Go | yes | [gitlab-org__terraform-provider-gitlab.md](gitlab-org__terraform-provider-gitlab.md) | Acceptance tests against real GitLab containers, a mandatory `type::` label, plain-sentence commits rather than Conventional Commits |
| `gitlab-org/api/client-go` | Go | yes | [gitlab-org__api__client-go.md](gitlab-org__api__client-go.md) | Every merge is released; the version bump comes from MR labels; small maintainer team reviews by hand |
| `gitlab-org/gitlab-runner` | Go | yes | [gitlab-org__gitlab-runner.md](gitlab-org__gitlab-runner.md) | MR title becomes the changelog entry; new `.gitlab-ci.yml` keywords must be accepted in `gitlab-org/gitlab` first; no new executors |
| `gitlab-org/orbit/knowledge-graph` | Rust | yes | [gitlab-org__orbit__knowledge-graph.md](gitlab-org__orbit__knowledge-graph.md) | commitlint, an MR template with word limits, many generated-artifact checks and a stale-MR sweeper of its own |
| `gitlab-org/gitlab-development-kit` | Ruby | yes | [gitlab-org__gitlab-development-kit.md](gitlab-org__gitlab-development-kit.md) | Maintenance mode: critical bug fixes only, new features go to its successor |
| `gitlab-org/charts/gitlab` | Ruby, Helm templates | yes | [gitlab-org__charts__gitlab.md](gitlab-org__charts__gitlab.md) | Distribution project: `@gitlab-bot ready` assigns nobody; QA verified by a reviewer label; `Changelog:` trailers |
| `gitlab-org/ci-cd/runner-tools/glci` | Go | yes | [gitlab-org__ci-cd__runner-tools__glci.md](gitlab-org__ci-cd__runner-tools__glci.md) | Local pipeline runner with hard rules in `CLAUDE.md`; no `CODEOWNERS`, so pick reviewers from recent merges |
| `gitlab-org/omnibus-gitlab` | Ruby | yes | [gitlab-org__omnibus-gitlab.md](gitlab-org__omnibus-gitlab.md) | Distribution project: `@gitlab-bot ready` assigns nobody; the package build is a manual job a reviewer starts |
| `gitlab-org/editor-extensions/gitlab-lsp` | TypeScript | yes | [gitlab-org__editor-extensions__gitlab-lsp.md](gitlab-org__editor-extensions__gitlab-lsp.md) | bun and turbo monorepo; deep multi-round reviews that often prefer a server-side or simpler fix |
| `gitlab-org/theseus/theseus` | Hugo site | no | [other-projects.md](other-projects.md) | Documentation site; no outside contributions in the corpus |
| `gitlab-org/professional-services-automation/tools/migration/congregate` | Python | yes | [gitlab-org__professional-services-automation__tools__migration__congregate.md](gitlab-org__professional-services-automation__tools__migration__congregate.md) | A maintainer mirrors your branch into an MR in the project that runs the e2e suite and fast-forwards your commits |
| `gitlab-org/modelops/applied-ml/code-suggestions/ai-assist` | Python | yes | [gitlab-org__modelops__applied-ml__code-suggestions__ai-assist.md](gitlab-org__modelops__applied-ml__code-suggestions__ai-assist.md) | commitlint also lints the MR title; Danger fails at 1000 changed lines; members trigger parent pipelines |
| `gitlab-org/gitlab-services/design.gitlab.com` | JavaScript, Vue | yes | [gitlab-org__gitlab-services__design.gitlab.com.md](gitlab-org__gitlab-services__design.gitlab.com.md) | Changesets for `@gitlab/ui`; from a fork, a pipeline's visual test screenshots are applied locally with a script; layered `CODEOWNERS` |
| `gitlab-org/technical-writing/docs-gitlab-com` | JavaScript, Go, Hugo | yes | [gitlab-org__technical-writing__docs-gitlab-com.md](gitlab-org__technical-writing__docs-gitlab-com.md) | Site and navigation only (content lives in source projects); no review app for forks; writer chosen by stage group |
| `gitlab-org/glql` | Rust, Ruby | yes | [gitlab-org__glql.md](gitlab-org__glql.md) | Conventional Commits on every commit, squash or not; Example Usage section for query changes; generated GraphQL validated against GitLab's schema |
| `gitlab-org/gitaly` | Go | yes | [gitlab-org__gitaly.md](gitlab-org__gitaly.md) | No squash: every commit lands, scoped subjects checked as errors, `Changelog:` per user-facing commit |
| `gitlab-org/release-tools` | Ruby | no | [gitlab-org__release-tools.md](gitlab-org__release-tools.md) | Start in the delivery issue tracker; release paths run only on the ops mirror; merges held during releases |
| `gitlab-org/ruby/gems/labkit-ruby` | Ruby | yes (since 2026-10-19) | [other-projects.md](other-projects.md) | Conventional Commits drive releases; fork MRs were ported because protected jobs cannot run from forks |
| `gitlab-org/labkit` | Go | yes (since 2026-10-19) | [gitlab-org__labkit.md](gitlab-org__labkit.md) | Conventional Commits with module scopes drive releases; strict MR size limits; v2 design rules |
| `gitlab-org/gitlab-shell` | Go | yes | [gitlab-org__gitlab-shell.md](gitlab-org__gitlab-shell.md) | No commit lint and no squash; LabKit logging rules; maintainers release and bump the version in `gitlab-org/gitlab` |
| `gitlab-org/gitlab-vscode-extension` | TypeScript | yes | [gitlab-org__gitlab-vscode-extension.md](gitlab-org__gitlab-vscode-extension.md) | Conventional Commits drive semantic-release; many language features belong in gitlab-lsp instead |
| `gitlab-org/ci-cd/runner-tools/grit` | HCL, Go | yes | [gitlab-org__ci-cd__runner-tools__grit.md](gitlab-org__ci-cd__runner-tools__grit.md) | Generated module READMEs; integration tests need GitLab's cloud credentials; roulette may find no reviewer |
| `gitlab-org/quality/triage-ops` | Ruby | yes | [gitlab-org__quality__triage-ops.md](gitlab-org__quality__triage-ops.md) | The source of every gitlab-bot command and policy; read it to know what a command does |
| `gitlab-org/gitlab-environment-toolkit` | HCL, Ansible | yes | [gitlab-org__gitlab-environment-toolkit.md](gitlab-org__gitlab-environment-toolkit.md) | Issue reviewed by maintainers before any MR; optional settings through Custom Config, not new variables |
| `gitlab-org/rust/labkit-rs` | Rust | yes | [other-projects.md](other-projects.md) | commitlint; testing steps and doc comments required by the template |
| `gitlab-org/frontend/eslint-plugin` | JavaScript | no | [other-projects.md](other-projects.md) | Conventional Commits on every commit; Changesets; generated files checked by a hook |
| `gitlab-org/step-runner` | Go | yes | [other-projects.md](other-projects.md) | Issue first; `make precommit`; hand-written changelog line ending in `See !<iid>.` |
| `gitlab-org/ops/artifact-registry` | Go | no | [gitlab-org__ops__artifact-registry.md](gitlab-org__ops__artifact-registry.md) | Conventional title becomes the squash commit; Danger fails code changes without tests; label edits by non-members do nothing |
| `gitlab-org/ruby/gems/gitlab-exporter` | Ruby | no | [other-projects.md](other-projects.md) | `Changelog:` trailers; maintainers ask you to bump the version, which triggers the release |
| `gitlab-org/container-registry` | Go | yes | [gitlab-org__container-registry.md](gitlab-org__container-registry.md) | commitlint on every commit; semantic-release; the MR title must stay conventional because the squash commit carries it |
| `gitlab-org/ruby/gems/gitlab-dangerfiles` | Ruby | no | [other-projects.md](other-projects.md) | The shared Danger rules; `danger dry_run` locally; `Changelog:` trailers |
| `gitlab-org/ai/lazy-mcp` | TypeScript | no | [other-projects.md](other-projects.md) | commitlint hook contradicts the guide's examples; Duo reviews work from personal forks here |
| `gitlab-org/gitlab-pages` | Go | yes | [gitlab-org__gitlab-pages.md](gitlab-org__gitlab-pages.md) | Danger's blocking commit rule runs only in canonical pipelines; a squash drops the `Changelog:` trailer; ships through `GITLAB_PAGES_VERSION` in `gitlab-org/gitlab` |
| `gitlab-org/security-products/gemnasium-db` | YAML, Ruby | yes | [gitlab-org__security-products__gemnasium-db.md](gitlab-org__security-products__gemnasium-db.md) | Advisories are never deleted; external review process, so `@gitlab-bot ready` requests nobody |
| `gitlab-org/cluster-integration/gitlab-agent` | Go | yes | [gitlab-org__cluster-integration__gitlab-agent.md](gitlab-org__cluster-integration__gitlab-agent.md) | Bazel; no Conventional Commits prefixes; user docs in `gitlab-org/gitlab` |
| `gitlab-org/fleeting/fleeting` | Go | yes | [other-projects.md](other-projects.md) | Protocol changes append protobuf fields; cross-project series start here; squash chosen per MR (off by default) |
| `gitlab-org/gitlab-elasticsearch-indexer` | Go | yes | [other-projects.md](other-projects.md) | Conventional Commits on every commit and, on the merge train, on the title; squash chosen per MR (off by default): a squashed MR lands its title, an unsquashed one every commit subject, as git-cliff changelog lines |
| `gitlab-org/security-products/analyzers/dependency-scanning` | Go | yes | [gitlab-org__security-products__analyzers__dependency-scanning.md](gitlab-org__security-products__analyzers__dependency-scanning.md) | changie entries; golden-file parser tests; two reviews |
| `gitlab-org/ruby/gems/prometheus-client-mmap` | Ruby, Rust | yes | [other-projects.md](other-projects.md) | `CONTRIBUTING.md` is upstream Prometheus text to ignore; file-mode check in CI |
| `gitlab-org/ruby/gems/gitlab-triage` | Ruby | yes | [gitlab-org__ruby__gems__gitlab-triage.md](gitlab-org__ruby__gems__gitlab-triage.md) | The policy engine behind triage-ops; Danger commit rules with squash off |
| `gitlab-org/ruby/gems/gitlab-glfm-markdown` | Ruby, Rust | yes | [other-projects.md](other-projects.md) | A file-mode check fails in forks; a maintainer runs the parent pipeline |
| `gitlab-org/ruby/gems/gitlab-grape-openapi` | Ruby | no | [other-projects.md](other-projects.md) | No Rails dependencies; reviewer says not to use the OpenSpec workflow the docs describe |
| `gitlab-org/ci-cd/custom-executor-drivers/fargate` | Go | yes | [gitlab-org__ci-cd__custom-executor-drivers__fargate.md](gitlab-org__ci-cd__custom-executor-drivers__fargate.md) | Slow reviews with manual AWS testing; mocks must be regenerated; ask a coach for another reviewer |
| `gitlab-org/cells/http-router` | TypeScript | no | [gitlab-org__cells__http-router.md](gitlab-org__cells__http-router.md) | Route snapshot MRs that must merge before the `gitlab-org/gitlab` MR; fork pipelines fail before starting |
| `gitlab-org/cloud-native/charts/openbao` | Helm templates | no | [other-projects.md](other-projects.md) | Regenerate the values schema and bump the chart version in every MR; e2e jobs are manual |
| `gitlab-org/fleeting/taskscaler` | Go | yes | [other-projects.md](other-projects.md) | Squash off by default and no commit lint; a mock drift check; fork pipelines are enough to merge |
| `gitlab-org/ai/skills` | Markdown, Python | no | [other-projects.md](other-projects.md) | GitLab's agent skills; a new skill is one MR from the New Skill template with generated files committed; a skill kept elsewhere goes in as a local copy, not a sync |
| `gitlab-org/ci-cd/docker-machine` | Go | no | [gitlab-org__ci-cd__docker-machine.md](gitlab-org__ci-cd__docker-machine.md) | Only critical bug fixes that affect running costs are accepted |
| `gitlab-org/gitlab-qa` | Ruby | no | [other-projects.md](other-projects.md) | `Changelog:` trailer on the first commit; jobs need `gitlab-org` runners |
| `gitlab-org/ruby/gems/semver_dialects` | Ruby | no | [other-projects.md](other-projects.md) | Version, changelog and lock file change together; issues go to `gitlab-org/gitlab` |
| `gitlab-community/meta` | HCL | yes | [other-projects.md](other-projects.md) | Where to request community fork access or a new fork |
| `gitlab-org/gitlab-zoekt-indexer` | Go | no | [other-projects.md](other-projects.md) | Conventional Commits; MR title checked only on the merge train; git-cliff changelog |
| `gitlab-org/security-products/analyzers/report` | Go | yes | [other-projects.md](other-projects.md) | Hand-written `CHANGELOG.md` entry ending in the MR iid; Danger never runs on fork MRs; issues go to `gitlab-org/gitlab` |
| `gitlab-org/release-cli` | Go | no | [other-projects.md](other-projects.md) | Deprecated in favour of glab; maintainers decline community MRs |
| `components/toolkit` | CI/CD templates | no | [other-projects.md](other-projects.md) | Tests run through the project's own pipeline; `Changelog:` trailers in commits, not descriptions |
| `components/opentofu` | Shell, Go | yes | [components__opentofu.md](components__opentofu.md) | Generated README; strict backward compatibility; fork pipelines cannot lock OpenTofu state |
| `components/ruby` | CI/CD templates, Ruby | no | [other-projects.md](other-projects.md) | Example child pipelines are the tests; `Changelog:` trailers |
| `gitlab-com/gl-infra/platform/runway/scrood` | Go | no | [other-projects.md](other-projects.md) | MR title is the release-note bullet; `make check` matches CI |
