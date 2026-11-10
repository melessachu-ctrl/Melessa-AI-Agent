# gitlab-org/omnibus-gitlab

The Linux package: Chef cookbooks, software definitions and the package build, plus its docs. It is a Distribution project, so `@gitlab-bot ready` assigns nobody, and the full package build is a manual job a reviewer starts.

| Fact | Value |
| --- | --- |
| Default branch | `master` |
| Language | Ruby |
| Fork to use | Community fork `gitlab-community/gitlab-org/omnibus-gitlab` (personal forks fail `generate-facts`) |
| Merge settings | Squash default on, squash message template `%{first_commit}`, pipeline must succeed, all threads must be resolved |
| Commit convention | gitlab-dangerfiles defaults; plain imperative titles |
| MR template | `Default.md` with a Definition of done; a Documentation update template. The web form fills new MRs from an older copy kept in project settings, which still asks for `workflow::ready for review` and lacks the reviewer checklist (references/workflow.md, section 7); follow `Default.md` (checked 2026-10-22) |
| Changelog | `Changelog:` git trailer |
| Contributor docs | `CONTRIBUTING.md`, `doc/development/contribute-to-omnibus-gitlab.md`, `AGENTS.md`, `.gitlab/duo/mr-review-instructions.yaml` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Fork and branch

- Open the MR from the community fork. A personal fork fails `generate-facts` with MissingCredentials (it needs an API token only the canonical project and the community fork have) and needs shared runners enabled; one MR was reopened from the community fork for this. (observed, 1 MR; [!9855](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9855))
- Name documentation-only branches with a `docs` prefix or suffix so only the docs jobs run, and do not use that naming for code changes, which need the full pipeline. The project prefers `<issue number>-<description>` branch names. (documented and observed; `gitlab-org/omnibus-gitlab:doc/development/contribute-to-omnibus-gitlab.md@7b8725ab`, [!9715](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9715))
- Get assigned to the issue before opening an MR: three were closed because the issue was assigned to another contributor. (observed, 3 MRs; [!9900](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9900), [!9901](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9901), [!9905](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9905))

## Requesting review

- `@gitlab-bot ready` only sets the label here: triage-ops skips reviewer assignment for Distribution projects. Since 2026-10-20 `Default.md` and Danger's reviewers message ask you to mark the MR ready and request a reviewer, picked from the reviewer roulette or the project maintainers, instead of applying `workflow::ready for review`; a contributor without a role cannot set reviewers. Use the contributor platform's request-review link (it requests the reviewer through its own account), or mention a reviewer you picked from Danger's roulette, `.gitlab/CODEOWNERS` for the touched paths, or the recent history of the files. Docs-only MRs go to the technical writer listed in CODEOWNERS. (enforced; `gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867`, `gitlab-org/distribution/monitoring:lib/data_sources/projects.yaml@b023e99a`, `gitlab-org/omnibus-gitlab:danger/reviewers/Dangerfile@9c46e0db`, `gitlab-org/omnibus-gitlab:.gitlab/merge_request_templates/Default.md@9c46e0db`, [!9808](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9808), [!9855](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9855))

## Changelog

- Add a `Changelog:` trailer (added, fixed, changed, deprecated, removed, security, performance, other) when the change is user-facing, on the first commit: squash uses the first commit's message (`%{first_commit}`). Reviewers asked for missing trailers at merge time. (documented; `gitlab-org/omnibus-gitlab:doc/development/contribute-to-omnibus-gitlab.md@7b8725ab`, [!9749](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9749), [!9778](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9778))

## Tests, settings and builds

- Any cookbook change needs specs under `spec/` for the attribute or recipe you changed; Danger warns when application files change without specs. If no spec applies (a refactor), say so so a reviewer can add `type::maintenance`. Run `bundle exec rspec` on those specs and `bundle exec rubocop`. (enforced; `gitlab-org/omnibus-gitlab:danger/specs/Dangerfile@2ceee4c8`, `gitlab-org/omnibus-gitlab:doc/development/contribute-to-omnibus-gitlab.md@7b8725ab`)
- Ruby 3.3.12 is pinned in `.ruby-version` and `.tool-versions`, and `Gemfile.lock` was bundled with Bundler 4.0.20. CI runs `build library specs` (`bundle exec rspec spec/lib`) and `ChefSpec specs` (six parallel knapsack nodes over `spec/chef`) in the public image `registry.gitlab.com/gitlab-org/gitlab-omnibus-builder/ubuntu_24.04-ruby:<BUILDER_IMAGE_REVISION>` (the revision is in `gitlab-ci-config/variables.yml`, 5.73.0 at the pin), with a frozen bundle and `ALTERNATIVE_SOURCES=true` "so tests run fine on forks". To run the specs you touched, use that image, or follow "Run specific chefspec tests" in `doc/development/setup.md`, which installs the bundle with the system `bundle` and notes that the tests may need root to read the secrets file. (enforced; documented; observed, anonymous pull of revision 5.72.0, checked 2026-10-22, and 5.73.0 listed in the same public registry repository; `gitlab-org/omnibus-gitlab:.ruby-version@3012cc43`, `gitlab-org/omnibus-gitlab:.tool-versions@3a24d905`, `gitlab-org/omnibus-gitlab:Gemfile.lock@11ce2127`, `gitlab-org/omnibus-gitlab:gitlab-ci-config/gitlab-com.yml@4f69a569`, `gitlab-org/omnibus-gitlab:gitlab-ci-config/variables.yml@b8ed1b93`, `gitlab-org/omnibus-gitlab:doc/development/setup.md@9bd5d811`)
- When you add or change a user-facing setting (`attributes/default.rb` or a cookbook library), update `files/gitlab-config-template/gitlab.rb.template` in the same MR and document the setting; Danger warns otherwise. (enforced; `gitlab-org/omnibus-gitlab:danger/template/Dangerfile@48713b99`)
- Changes under `config/software`, `config/patches`, `config/projects` or `config/templates` need a package rebuild on all platforms and an approved license; a reviewer starts the manual `Trigger:ee-package` jobs (and `build-package-on-all-os`). If your change does not affect the build (a rubocop fix, a comment), say so so a reviewer can add `maintenance::pipelines` or `maintenance::workflow` to silence the Danger warning. (enforced; `gitlab-org/omnibus-gitlab:danger/software/Dangerfile@2ceee4c8`, `gitlab-org/omnibus-gitlab:.gitlab/merge_request_templates/Default.md@9c46e0db`, [!9778](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9778))
- For behavior changes, validate on a real installation (a package build or container) and post the result; reviews asked for end-to-end evidence. (observed, 2 MRs; [!9749](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9749), [!9799](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9799))
- `doc/development/setup.md` describes the container for that: run `gitlab/gitlab-ce:nightly` with a shell, start `/opt/gitlab/embedded/bin/runsvdir-start` and run `gitlab-ctl reconfigure`, then move each cookbook directory under `/opt/gitlab/embedded/cookbooks/` aside and symlink the same directory of your checkout's `files/gitlab-cookbooks/` in its place, and run `gitlab-ctl reconfigure` again after each change. Post what reconfigure changed and the resulting service state as the end-to-end evidence. (documented; `gitlab-org/omnibus-gitlab:doc/development/setup.md@9bd5d811`)
- Lint changed docs with markdownlint-cli2 and Vale (`.markdownlint-cli2.yaml`, `.vale.ini`). CI's `docs-lint content` (`vale --minAlertLevel error doc`) and `docs-lint markdown` (`markdownlint-cli2 'doc/**/*.md'`) run in the docs-gitlab-com lint image that `DOCS_LINT_IMAGE` names in `gitlab-ci-config/variables.yml`, whose tag lists the tool versions; run the same lines in that tag from the repository root. (documented; enforced; `gitlab-org/omnibus-gitlab:doc/development/contribute-to-omnibus-gitlab.md@7b8725ab`, `gitlab-org/omnibus-gitlab:gitlab-ci-config/variables.yml@b8ed1b93`, `gitlab-org/omnibus-gitlab:gitlab-ci-config/gitlab-com.yml@4f69a569`)

## Troubleshooting

**After `@gitlab-bot ready`, the MR is labelled ready but no reviewer is requested**
- Cause: reviewer assignment is skipped for Distribution projects.
- Fix: use the contributor platform's request-review link or mention your chosen reviewer.
- Who can fix it: you.
- Sources: [!9855](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9855)

**`generate-facts` fails with MissingCredentials**
- Cause: a personal fork lacks the API token the job needs.
- Fix: move the branch to the community fork and open the MR there.
- Who can fix it: you.
- Sources: [!9855](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9855)

**The Definition of done asks for green `Trigger:ee-package` jobs you cannot start**
- Cause: the package build jobs are manual and restricted to team members.
- Fix: leave that checkbox for the reviewer, who starts the jobs during review.
- Who can fix it: a maintainer or member.
- Sources: `gitlab-org/omnibus-gitlab:.gitlab/merge_request_templates/Default.md@9c46e0db`, [!9749](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9749)

**`bundle install` fails, so no spec can run**
- Cause: the Gemfile pulls from four places: rubygems.org, the Cinc gem source on packagecloud.io, GitHub (`chefspec` and `fauxhai-chef` are git gems) and gitlab.com (the `omnibus` gem comes from the gitlab-org/omnibus fork). A network that blocks any of them stops the install. The Duo Developer agent a maintainer asked to review one MR could not install the bundle for that reason and reviewed without running the specs.
- Fix: install where all four are reachable, and post your spec commands and their output in the MR so a reviewer, or a reviewing agent, does not have to run them.
- Who can fix it: you.
- Sources: `gitlab-org/omnibus-gitlab:Gemfile@5fc1a241`, `gitlab-org/omnibus-gitlab:Gemfile.lock@11ce2127`, [!9929](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9929#note_4015054030)

## Why MRs here were closed

- Issue already assigned to another contributor ([!9900](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9900), [!9901](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9901), [!9905](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9905)).
- Not needed because the configuration would be restructured ([!9865](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9865)); deprecation announcements are driven from the main project, not from package docs ([!9914](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9914)).
- Nine small hackathon docs MRs withdrawn by their author the same day ([!9874](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9874) to [!9887](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9887)).
- Reopened from the community fork ([!9855](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9855)).
