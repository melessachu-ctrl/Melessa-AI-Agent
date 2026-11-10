# Preparing a local environment to test a contribution

The pipeline decides what passes; a local run only predicts it. This file is
how to make the prediction hold in any GitLab-owned project: read the versions
the project's CI jobs use, install the way CI installs, run what the jobs run,
and say in the MR what ran where. The commands, services and known traps of
each project are in its file under references/projects/, listed in section 6.

## Contents

- [1. Read the versions from CI first](#1-read-the-versions-from-ci-first)
- [2. Install the way CI installs](#2-install-the-way-ci-installs)
- [3. Run what the job runs](#3-run-what-the-job-runs)
- [4. A passing hook is not a passing check](#4-a-passing-hook-is-not-a-passing-check)
- [5. Say in the MR what ran where](#5-say-in-the-mr-what-ran-where)
- [6. Project files](#6-project-files)

## 1. Read the versions from CI first

- **The CI job decides what passes.** Read the versions in this order: the CI job that runs the check (its `image:` and variables such as `GO_VERSION` or `GOLANGCI_LINT_VERSION`), then the Makefile variable the target uses, then the pin files: `.tool-versions`, `mise.toml` or `mise/config.toml` (which `mise install` reads), `.ruby-version`, `rust-toolchain.toml`, `packageManager` in `package.json`. They disagree inside several projects: gitlab-org/gitlab-shell's `.tool-versions` names golangci-lint 2.14.0 while its Makefile downloads 2.12.2; gitlab-org/fleeting/taskscaler's `.tool-versions` names Go 1.26.2 while its CI runs 1.26.10; in gitlab-org/quality/triage-ops `AGENTS.md` says Ruby 3.3.7, `.ruby-version` 4.0.2, and `.tool-versions` and the CI image 4.0.7. gitlab-org/technical-writing/docs-gitlab-com's `mise.toml` says so itself, in two comment lines: "Versions specified here are development versions" and "See .gitlab-ci.yml for production versions" (enforced; documented).
- **Read the CI configuration the pipeline will run.** A pipeline for your branch, the one your fork runs, reads your branch's own `.gitlab-ci.yml`, while a merged results pipeline, which maintainers run in the canonical project and merge trains use, tests a temporary commit that merges your branch into the target branch, so it also runs the CI changes the target branch made after your branch point. When the target branch changed tool versions or jobs since then, the two pipelines check different things: rebase, or run the checks at both sets of versions. gitlab-org/gitlab-zoekt-indexer!1085, branched from a commit of 2026-10-05, ran its fork pipeline with Go 1.25 to 1.27 and golangci-lint 2.10.1, while the configuration on `main` runs Go 1.27 alone and golangci-lint 2.13.2 (documented; observed, 1).
- **In Go, the `go` line is the oldest Go the module accepts, not the one CI runs.** Under `GOTOOLCHAIN=auto`, the go command's default, the toolchain only moves forward: to the `toolchain` line, or without one to the exact `go` version, while a newer local Go stays in use. The official `golang:<version>` images set `GOTOOLCHAIN=local`, so a job in one runs exactly that Go whatever `go.mod` says; reproduce it in that image, or with that Go and `GOTOOLCHAIN=local`. gitlab-org/gitlab-pages' `go.mod` says `go 1.26.0` with no `toolchain` line while its tests run in the `golang:1.26` and `golang:1.27` images; gitlab-org/security-products/analyzers/report's `go.mod` names `toolchain go1.24.2` while its tests run in `golang:1.23`, and its lint job, in a golangci-lint image that does not set `GOTOOLCHAIN=local`, switched to Go 1.24.2 (documented; enforced; observed in the two public job logs).
- **A linter supports the Go releases up to its own.** golangci-lint added Go 1.27 support in v2.13.0, so an older release can fail in its type checker on code a newer Go loads; gitlab-org/container-registry's CI notes that its golangci-lint "Must be built with a Go toolchain >= GO_VERSION, otherwise golangci-lint's type checker panics when loading the newer standard library". Run a pinned linter in the image its job names (section 3) (documented).
- **A matrix runs more than the pinned version.** The Ruby gems run their specs on several Rubies while `.ruby-version` or `.tool-versions` names one: gitlab-org/ruby/gems/gitlab-triage on Ruby 3.0 to 3.3 with 3.2.4 pinned, gitlab-org/ruby/gems/gitlab-glfm-markdown on Ruby 3.1 to 4.0, on Ruby master (allowed to fail) and in required i386 Debian, AlmaLinux 8 and Arch Linux jobs. A change that uses syntax or standard library newer than the oldest version in the matrix fails that job: run the specs once in the oldest one, in its official `ruby:<version>` image (enforced).

Sources: gitlab-org/gitlab-shell:.tool-versions@ace8ee043e60f061d310337ffc71e94eab8a2127 ;
gitlab-org/gitlab-shell:Makefile@232f5557afd3a57644d953262ecc567c92e56f1b ;
gitlab-org/fleeting/taskscaler:.tool-versions@1215f73ddb09793e4a341da10ed2b4bb145b3152 ;
gitlab-org/fleeting/taskscaler:.gitlab-ci.yml@8dde676159c2df77c089911712863b7c067e90a2 ;
gitlab-org/quality/triage-ops:AGENTS.md@cd6869126ba1c61c66ff78594226882a2e15bbff ;
gitlab-org/quality/triage-ops:.ruby-version@b35215d106e7f196853a31356cec76b30b802163 ;
gitlab-org/quality/triage-ops:.tool-versions@17dd1dddbe4e766017118559d3d09beb9949edc2 ;
gitlab-org/quality/triage-ops:.gitlab-ci.yml@efdc7b5f6c70a9c35f8c1290ffbd4b4144aba224 ;
gitlab-org/technical-writing/docs-gitlab-com:mise.toml@3f0ad7b9360e20daee6a58581465f1ffc809714d ;
gitlab-org/gitlab:doc/ci/pipelines/merged_results_pipelines.md@d685a660b99ddd17e25be0655fac347e224db635 ;
gitlab-org/gitlab-zoekt-indexer:.gitlab-ci.yml@c329ce9d02916f3f0f7d86831452d47c085af7bd ;
https://gitlab.com/gitlab-org/gitlab-zoekt-indexer/-/merge_requests/1085 ;
https://go.dev/doc/toolchain ;
https://github.com/docker-library/golang/blob/650cf2f338d22da87df8c773cfc88afa26699502/1.26/trixie/Dockerfile ;
gitlab-org/gitlab-pages:go.mod@9f8ddcf70facd69a118116a658e6834349a52a3e ;
gitlab-org/gitlab-pages:.gitlab/ci/test.yml@80b941cceb10cb8c18e6cb09314a20ff08847f3e ;
gitlab-org/security-products/analyzers/report:go.mod@ceb1ca65ce17d81fbde027c2b3019ddd485fb62f ;
gitlab-org/security-products/ci-templates:includes-dev/go.yml@e2a0c8e5ba2e51efd48383b6577c801d000dec8a ;
https://gitlab.com/gitlab-community/gitlab-org/security-products/analyzers/report/-/jobs/17373820649 ;
https://gitlab.com/gitlab-community/gitlab-org/security-products/analyzers/report/-/jobs/17373821005 ;
https://github.com/golangci/golangci-lint/blob/v2.14.0/CHANGELOG.md ;
gitlab-org/container-registry:.gitlab-ci.yml@b31cd4ab20e40ab57906ff6c24fd6ba12f159272 ;
gitlab-org/ruby/gems/gitlab-triage:.gitlab-ci.yml@d50a3785749a653329c606b8ed54752b94401d43 ;
gitlab-org/ruby/gems/gitlab-triage:.ruby-version@f72d0714bb87f98343b74e6f9fe3e0b7d6180256 ;
gitlab-org/ruby/gems/gitlab-glfm-markdown:.gitlab-ci.yml@b5ff0a3e0d3cd9e07284a1be339a746872bd8adb

## 2. Install the way CI installs

- **Use the lockfile-respecting command the CI job runs**, not the one a README gives for development: `npm ci` in gitlab-org/gitlab-vscode-extension (`npm install` may rewrite `package-lock.json`), `yarn install --immutable` in gitlab-org/frontend/eslint-plugin, `bundle install` with `BUNDLE_FROZEN=true` in gitlab-org/ruby/gems/gitlab-triage. Then what you test is what CI installs (enforced).

Sources: gitlab-org/gitlab-vscode-extension:.gitlab-ci.yml@1b25b697f8c190dbc41e6eda872db1071e1d6405 ;
gitlab-org/frontend/eslint-plugin:.gitlab-ci.yml@47ded373d57f39d931723c9d738c595237d96120 ;
gitlab-org/ruby/gems/gitlab-triage:.gitlab-ci.yml@d50a3785749a653329c606b8ed54752b94401d43

## 3. Run what the job runs

- **Prefer the project's make target** over a bare `go test` or `golangci-lint run`, or copy what the target sets up, because targets carry environment you do not see: gitlab-org/cli's `make test` clears `VISUAL`, `EDITOR`, `PAGER` and `GITLAB_TOKEN` and exports `CI_PROJECT_PATH`; gitlab-org/gitaly's Makefile exports `GOTOOLCHAIN=local` and builds the Git its tests run; gitlab-org/gitlab-shell's `make lint` compares the output with a committed baseline. When a bare command fails where the target passes, suspect the environment before your change, and narrow a target with its own variables, such as gitaly's `TEST_PACKAGES` and `TEST_OPTIONS` (enforced).
- **Run the job's script in the job's image** when a check depends on tool versions or system packages, linters above all: `docker run --rm -v "$PWD":/src -w /src <image of the job> <script of the job>`, with the job's `variables:`, without the dependency proxy prefix some image names carry (`${GITLAB_DEPENDENCY_PROXY_ADDRESS}`), and with what its `before_script`, or its `script` before the check, installs (for example the `libicu-dev` that the `lint:golangci` job's script installs before `make golangci-lint` in gitlab-org/gitlab-elasticsearch-indexer). Many of these images pull without an account: plain `golang:`, `node:` and `ruby:` tags, and images in GitLab's public registries such as gitlab-org/editor-extensions/gitlab-lsp's `ci-node`, which its CI pulls from the canonical project's public registry so that fork pipelines work (enforced; observed, anonymous pulls of four registry.gitlab.com images, checked 2026-10-22).
- **Start the services the job declares.** When tests need a database, Gitaly, Redis or a GitLab instance, start the image the CI job lists under `services:`, with the job's `variables:` and, where the service has one, its `command:`, rather than a distribution package or a guess: gitlab-org/container-registry's database jobs start the project's PostgreSQL CI image with `REGISTRY_DATABASE_*` variables, and gitlab-org/gitlab-shell's test jobs start the CNG `gitaly` image with a command of their own and `GITALY_CONNECTION_INFO` (enforced).
- **Show the red run without changing your working tree.** A red check made by checking out the base's copy of the fixed file and restoring it afterwards leaves the fix reverted when the run is cut short, and a later green run on that tree is a red run. Run it in a throwaway worktree (`git worktree add --detach <dir> <base>` plus your new tests), or point the test at the base's copy without touching the tree: in Jest, a config that extends `jest.config.js` with a `moduleNameMapper` entry mapping the changed module to a copy of the base file kept outside the tree. Check `git status` before the next run (documented, https://git-scm.com/docs/git-worktree and https://github.com/jestjs/jest/blob/b6146039f2124043f79f95609b72f6144b69f9f6/website/versioned_docs/version-29.7/Configuration.md#L946-L950). When the new test needs something only the fix adds, make the red run compile without the fix's behaviour (references/workflow.md, section 8).

Sources: gitlab-org/cli:Makefile@b5b2e198e8a5fcf6a41439b4a2aeb3d521fad1ee ;
gitlab-org/gitaly:Makefile@0d573533ff23be75a22cfd3f5660d9c47a88e519 ;
gitlab-org/gitlab-shell:support/lint.sh@5eef546a14f393d517eb04d9ace0f24ede33a508 ;
gitlab-org/gitlab-elasticsearch-indexer:.gitlab-ci.yml@7940895912f83439bccb69aae4e013cddc4f2932 ;
gitlab-org/editor-extensions/gitlab-lsp:.gitlab-ci.yml@4cd9c0be47c4c0d887081de587422070de3836ad ;
gitlab-org/container-registry:.gitlab/ci/integration.yml@82537bb0105aa4c677f100ae80af20d0492f1200 ;
gitlab-org/gitlab-shell:.gitlab-ci.yml@eae2499b1eadb1d8806ecc7e1cca41426c8b2c45

## 4. A passing hook is not a passing check

- **Installing a project's lefthook hooks does not prove the checks ran.** Several hooks print a warning and succeed when their tool is missing: gitlab-org/cli's hooks skip golangci-lint, shellcheck, markdownlint-cli2, Vale and lychee when they are not installed, and commit message validation without Node.js; gitlab-org/gitlab-elasticsearch-indexer's skip golangci-lint. Install the pinned tools first (`make bootstrap` in cli, `mise install` elsewhere) and read the hook output (enforced).

Sources: gitlab-org/cli:lefthook.yml@f679ecb2f4a1f2f2a508150e8428b4037d15aff6 ;
gitlab-org/cli:Makefile@b5b2e198e8a5fcf6a41439b4a2aeb3d521fad1ee ;
gitlab-org/gitlab-elasticsearch-indexer:lefthook.yml@5b82d12f6b3ba7fadf48f855dcf5dacbc6800e36

## 5. Say in the MR what ran where

- **Name the image and versions each command ran with**, the tests you ran with their services, and the ones you could not run, so a reviewer knows what your results cover and a maintainer knows which jobs to watch. For example gitlab-org/gitlab-pages!1368 names the `golang:1.26` and `golang:1.27` images its tests ran in and the golangci-lint image its lint ran in, and gitlab-org/gitlab-shell!1621 says which acceptance tests skipped without the Gitaly service (observed). When a job cannot run in your fork at all, post the commands and results as references/workflow.md, section 8 says.
- **Quote a result only with its exit status.** A test runner's summary line does not prove the run finished or passed: RSpec prints its summary in an `ensure` around the run and does not rescue `SignalException`, so a run ended by SIGTERM or SIGHUP (a session or job ending under it) still prints "N examples, 0 failures" for what it ran, and only SIGINT prints "RSpec is shutting down". Record the exit status with the log, treat a log without one as not run, and compare the count with a dry run on the same files (`rspec --dry-run`) before you quote it (enforced; references/projects/gitlab-org__gitlab.md, Local checks before pushing, adds a second reason there).

Sources: https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/1368 ;
https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1621 ;
https://github.com/rspec/rspec-core/blob/v3.13.1/lib/rspec/core/reporter.rb#L71-L78 ;
https://github.com/rspec/rspec-support/blob/v3.13.1/lib/rspec/support.rb#L145-L153 ;
https://github.com/rspec/rspec-core/blob/v3.13.1/lib/rspec/core/runner.rb#L175-L189

## 6. Project files

Each project file keeps its local commands, versions and environment traps in
one section:

| Project | Section |
| --- | --- |
| gitlab-org/gitlab | [Fork and setup](projects/gitlab-org__gitlab.md#fork-and-setup), [Test environment](projects/gitlab-org__gitlab.md#test-environment), [Local checks before pushing](projects/gitlab-org__gitlab.md#local-checks-before-pushing), [Generated artifacts](projects/gitlab-org__gitlab.md#generated-artifacts) |
| gitlab-org/api/client-go | [Local checks before pushing](projects/gitlab-org__api__client-go.md#local-checks-before-pushing) |
| gitlab-org/cli | [Local checks before pushing](projects/gitlab-org__cli.md#local-checks-before-pushing) |
| gitlab-org/gitaly | [Local checks before pushing](projects/gitlab-org__gitaly.md#local-checks-before-pushing) |
| gitlab-org/gitlab-runner | [Local checks before pushing](projects/gitlab-org__gitlab-runner.md#local-checks-before-pushing) |
| gitlab-org/terraform-provider-gitlab | [Local checks before pushing](projects/gitlab-org__terraform-provider-gitlab.md#local-checks-before-pushing) |
| gitlab-org/editor-extensions/gitlab-lsp | [Local checks before pushing](projects/gitlab-org__editor-extensions__gitlab-lsp.md#local-checks-before-pushing) |
| gitlab-org/gitlab-vscode-extension | [Local checks before pushing](projects/gitlab-org__gitlab-vscode-extension.md#local-checks-before-pushing) |
| gitlab-org/orbit/knowledge-graph | [Local checks before pushing](projects/gitlab-org__orbit__knowledge-graph.md#local-checks-before-pushing) |
| gitlab-org/container-registry | [Checks and docs](projects/gitlab-org__container-registry.md#checks-and-docs) |
| gitlab-org/gitlab-services/design.gitlab.com | [Local checks and tests](projects/gitlab-org__gitlab-services__design.gitlab.com.md#local-checks-and-tests) |
| gitlab-org/charts/gitlab | [Tests and checks](projects/gitlab-org__charts__gitlab.md#tests-and-checks) |
| gitlab-org/omnibus-gitlab | [Tests, settings and builds](projects/gitlab-org__omnibus-gitlab.md#tests-settings-and-builds) |
| gitlab-org/gitlab-pages | [Rules](projects/gitlab-org__gitlab-pages.md#rules) |
| gitlab-org/gitlab-shell | [Rules](projects/gitlab-org__gitlab-shell.md#rules) |
| gitlab-org/cluster-integration/gitlab-agent | [Rules](projects/gitlab-org__cluster-integration__gitlab-agent.md#rules) |
| gitlab-org/glql | [Rules](projects/gitlab-org__glql.md#rules) |
| gitlab-org/quality/triage-ops | [Rules](projects/gitlab-org__quality__triage-ops.md#rules) |
| gitlab-org/ruby/gems/gitlab-triage | [Rules](projects/gitlab-org__ruby__gems__gitlab-triage.md#rules) |
| gitlab-org/modelops/applied-ml/code-suggestions/ai-assist | [Rules](projects/gitlab-org__modelops__applied-ml__code-suggestions__ai-assist.md#rules) |
| gitlab-org/cells/http-router | [Rules](projects/gitlab-org__cells__http-router.md#rules) |
| gitlab-org/gitlab-development-kit | [Rules](projects/gitlab-org__gitlab-development-kit.md#rules) |
| gitlab-org/developer-relations/contributor-success/contributors-gitlab-com | [Rules](projects/gitlab-org__developer-relations__contributor-success__contributors-gitlab-com.md#rules) |
| gitlab-org/technical-writing/docs-gitlab-com | [Rules](projects/gitlab-org__technical-writing__docs-gitlab-com.md#rules) |
| gitlab-org/security-products/analyzers/dependency-scanning | [Rules](projects/gitlab-org__security-products__analyzers__dependency-scanning.md#rules) |
| Projects without a file of their own (the elasticsearch and zoekt indexers, taskscaler, the Ruby gems, the security-products report analyzer and others) | [other-projects.md](projects/other-projects.md), one section per project |

For documentation changes, the docs lint and preview tools are in
references/docs-style.md. Every other project file is listed in
[projects/INDEX.md](projects/INDEX.md).
