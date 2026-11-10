# Commits, titles, descriptions, changelog and issue links

The common rules come from two shared pieces of machinery: the commit and
changelog rules of the gitlab-dangerfiles gem (imported by gitlab-org/gitlab,
gitaly, gitlab-pages, omnibus-gitlab, charts/gitlab, design.gitlab.com,
dependency-scanning, GDK, gitlab-triage, triage-ops, gitlab-qa and others), and
gitlab-bot's issue-link parser. Several projects replace them with their own
conventions (conventional commits, label-driven releases, title-driven
changelogs); check the project file in references/projects/INDEX.md.

## Contents

- [Commit messages where Danger lints them](#commit-messages-where-danger-lints-them)
- [Changelog entries](#changelog-entries)
- [MR titles](#mr-titles)
- [MR descriptions](#mr-descriptions)
- [Linking the issue](#linking-the-issue)
- [Open questions](#open-questions)

## Commit messages where Danger lints them

These are enforced by gitlab-dangerfiles' CommitLinter in every project whose
Dangerfile imports the `commit_messages` rule:

| Rule | Severity |
| --- | --- |
| Subject of at least 3 words | warning |
| Subject of at most 72 characters | error |
| Subject starts with a capital letter (a lowercase `prefix:` or `[tag]` before it is accepted) | error |
| No leading space, no trailing period in the subject | error |
| A blank line between subject and body | error |
| Body lines of at most 72 characters (a line may run longer only because of a URL) | warning |
| A body when the commit changes more than 30 lines in more than 3 files | warning |
| No short references (`#123`, `!123`, `&123`, `group/project#123`, `%12.3`); backticked references are ignored | error |
| No Markdown emoji (`:+1:`) or Unicode emoji | error |

"Error" means the `danger-review` job fails; with squash enabled, see below.
Reviewers in GDK and gitlab-dangerfiles still asked for a capital letter after a
`docs(...)` prefix, so capitalise anyway where Danger's `commit_messages` rule
runs (observed, 2). The capital-letter rule is that rule's alone: a project
whose Dangerfile does not import it follows its own linter and guide.
gitlab-org/cli, which runs only commitlint, asks for a lowercase first letter
after `type(scope):` (documented; see its project file), and
gitlab-org/gitlab-elasticsearch-indexer, whose Danger imports only
`simple_roulette` and whose commitlint extends `config-conventional`, fails a
capitalised subject (enforced; see references/projects/other-projects.md).

- **Prefer full URLs in the MR description to links in commits.** Short references are rejected, and a full URL in a commit message makes GitLab add a "mentioned in commit" note to the referenced issue on every push of the branch (observed, 3).
- **Lint locally before pushing.** Where the project exposes it, `bundle exec rake danger_local` runs the same rules (with the remotes of references/workflow.md, section 6, run `git fetch upstream` and set `DANGER_LOCAL_BASE=upstream/<default>`, since `origin` is the community fork, whose mirror of the default branch can lag); gitlab-org/gitlab also has `bundle exec ruby scripts/lint/commit_linter.rb`, run with the base and Ruby that references/projects/gitlab-org__gitlab.md, Commits and title, gives (documented).
- **Fix messages before approval.** Rewording means a force-push, which drops the MR from auto-merge or the merge train and, wherever it also changes the diff (a rebase onto a newer default branch can), removes approvals, all of them or the changed files' code owners', as the project sets it (observed, 2 and 31; references/review.md, section 9).

### Squash, fixup and suggestion commits

- With **"Squash commits when merge request is accepted"** on, Danger lints the oldest commit that has a body as the future squash message: its problems still fail the job, while problems in other commits only warn, and `fixup!` and suggestion commits are ignored. Make that commit's message clean and descriptive of the whole MR (enforced).
- With squash **off**, every failing commit fails the job, `fixup!` and `squash!` commits fail (they only warn while the MR is a draft), and "Apply N suggestion(s) to M file(s)" commits fail (enforced).
- Without squash, Danger warns above 10 commits; a separate counter warns above 20 commits because some jobs fetch with a depth of 20, and in gitlab-org/gitlab it fails above 20 unless squash is on (enforced).
- So: if you will have several commits or apply review suggestions, enable squash on the MR (enforced; observed, 7 in gitlab-org/gitlab). Where the project wants a reviewable history instead (each commit a revertable step with passing tests), keep commits few and meaningful and rebase fixups away before review completes (documented in gitlab-org/gitlab and cells/http-router). Where the squash template is null and the change needs a `Changelog:` trailer (gitlab-org/gitlab-pages), keep squash off and make every commit pass the rules above (Changelog entries below).
- **A suggestion applied with your own commit message** (the optional message field in GitLab, or `commit_message` on `PUT /suggestions/:id/apply` and `PUT /suggestions/batch_apply`) replaces both the default `Apply N suggestion(s) to M file(s)` message and the project's own suggestion template, and GitLab still fills in its placeholders. The credit the default gives comes from `%{co_authored_by}`, which becomes a `Co-authored-by:` line for each suggestion author other than you, so end your message with it. Danger recognises a suggestion commit only by the default text in its message: it skips such a commit while squash is on and fails it while squash is off (the bullets above), and a message without that text is linted like every other commit, so write it to the project's commit rules (Conventional Commits where the project uses them). A trailer line over 72 characters, which a long name with a private `users.noreply` commit email can make, only warns (`details_line_too_long`) (enforced; documented; observed, 2: gitlab-org/gitlab commit 38f5bbf2, after which Danger listed no commit problem on !264870, and gitlab-org/gitlab-elasticsearch-indexer commit 6d38b586). What the apply itself does, and does not do, is in references/review.md, section 7.
- **With squash on, what lands is usually a commit GitLab writes, not yours.** Its author is you, the MR's author, under your GitLab account's commit email whatever email your commits carry. In projects that sign web commits its committer is `GitLab <noreply@gitlab.com>` (gitlab-org/gitlab:doc/user/project/merge_requests/squash_and_merge.md@0457b888ebac21085d1e8a48d1bfc283c38561c7 still names the user who initiated the squash as committer; where web commits are signed, the commits and web_commits.md show GitLab) and the signature is GitLab's (`verified_system`), not yours, and the merge commit above it, where the project makes one, is authored by the maintainer who merged, or on a merge train by the one who started the merge (enforced; documented; observed, 32). GitLab keeps your own commit as it is, signature included, only when the MR has one commit whose message equals the squash message, which is the project's squash template as rendered (the MR title where the project sets none), or the text the maintainer typed under **Modify commit messages** when merging; so a maintainer who edits that message lands a new commit even for a single commit (enforced; observed, 1). Whether a project signs web commits is a setting you cannot read, but `GET /projects/:id/repository/commits/<sha>/signature` on its newest merge commit, or its newest squash commit where the project fast-forwards, answers `verification_status: verified_system` where it does, and a 404 (gitlab.com: `Signature Not Found`; doc/api/commits.md's example reads `404 GPG Signature Not Found`) where it does not (the endpoint and its 404 for an unsigned commit are documented; observed, 35 of the 36 projects with a file in references/projects, checked 2026-10-21). A merge GitLab refuses with "For signed Web commits, the commit must be equal to the author" is about these commits, not yours: see references/troubleshooting.md, Threads and merge blockers.

Sources: gitlab-org/ruby/gems/gitlab-dangerfiles:lib/gitlab/dangerfiles/base_linter.rb@38d20dd458648a7740b77208e4a592de6164341d ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/gitlab/dangerfiles/commit_linter.rb@c64980c95b97f830f7801675d5ccc71a210a9bfa ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/plugins/commit_messages.rb@7dccad2f4f8fbff84b00c99421d8396219bad7a1 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/commits_counter/Dangerfile@d67a119e4fe8803fe91483dfb578ac34b9adaf60 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/gitlab/dangerfiles/config.rb@9ba5ab8ee8495fd239be32bc4c4764f7a534966f ;
gitlab-org/ruby/gems/gitlab-dangerfiles:README.md@c8e0ba7151b0d0221bf608576e6194f22b2c44e4 ;
gitlab-org/gitlab:scripts/lint/commit_linter.rb@236ced52d25f9bbeb3b4506eca80c0baa3cb8ce8 ;
gitlab-org/cli:CONTRIBUTING.md@5686d7484e65cb08b6e3b92f86d2ccffb415bdc0 ;
gitlab-org/gitlab-elasticsearch-indexer:Dangerfile@184798d459c55db54f4cb92f9cb002ff51604557 ;
gitlab-org/gitlab-elasticsearch-indexer:.commitlintrc.yml@f6cf341acfd000e5e5b948cfc393a61b6bf57adc ;
gitlab-org/gitlab:app/models/repository.rb@4686d0cbd9a9665a0c9eac19e3cfa2906830f296 ;
gitlab-org/gitlab:app/services/merge_requests/squash_service.rb@9dfef03f2509f8f9a4d68200250497c41c162f3e ;
gitlab-org/gitlab:app/models/merge_request.rb@b30ae611be431291816fb70e6678d011dae4e6fc ;
gitlab-org/gitlab:lib/gitlab/merge_requests/message_generator.rb@b2d3926485cf2c40258bd1a87b5baac01a6e6771 ;
gitlab-org/gitlab:app/services/merge_requests/merge_strategies/from_source_branch.rb@b6943a23cdda748ee603e5a786bb6b228ffd837c ;
gitlab-org/gitlab:lib/gitlab/git/user.rb@011a050c031c5d153b733ec686dff04f302dc280 ;
gitlab-org/gitlab:lib/gitlab/gitaly_client/operation_service.rb@f872a3682b8d7ebd071cb2b0b814c62eb18085cb ;
gitlab-org/gitlab:doc/user/project/repository/signed_commits/web_commits.md@4c8427180bcd1dc0f0bbb96c20f2180064851d1a ;
gitlab-org/gitlab:doc/user/project/merge_requests/squash_and_merge.md@0457b888ebac21085d1e8a48d1bfc283c38561c7 ;
gitlab-org/gitlab:doc/ci/pipelines/merge_trains.md@43ecb41ea18fda993c19544a7e59b43657c7994f ;
gitlab-org/gitlab:doc/api/commits.md@a2ea8aaf67d442b6c89e85a0a417cac11ba6e5f1 ;
gitlab-org/gitlab:ee/lib/ee/api/entities/project.rb@6924dc94a4f8b1f652f52372dfdb94c979b797e6 ;
https://gitlab.com/gitlab-org/gitaly/-/merge_requests/8878 ;
https://gitlab.com/gitlab-org/ruby/gems/gitlab-dangerfiles/-/merge_requests/335 ;
https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5465 ;
gitlab-org/gitlab:lib/gitlab/suggestions/commit_message.rb@bcf22d692f2d994fa89dd9d151bca75b451b22c8 ;
gitlab-org/gitlab:doc/api/suggestions.md@bc7979c0dfd4b430b77b9e27ba0205249ede4ae7 ;
gitlab-org/gitlab:doc/user/project/merge_requests/reviews/suggestions.md@2ac227a86477a009d63100482dc997bbc832cbb2 ;
gitlab-org/gitlab:lib/gitlab/private_commit_email.rb@46489a0f94596510475fe302fef714c43db15555 ;
https://gitlab.com/gitlab-org/gitlab/-/commit/38f5bbf2a751b8774bda2156ceee88d28c0ad21e ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264870#note_4082583191 ;
https://gitlab.com/gitlab-org/gitlab-elasticsearch-indexer/-/commit/6d38b586931451569e44ace4e6ec88e00f72cda6

### Commit conventions that differ by project

- **Conventional commits** (`feat(scope): ...`, `fix: ...`) are linted or expected in several projects that release with semantic-release or generate changelogs from commit or MR titles, for example the GitLab CLI, the VS Code extension, the language server and client-go. Their titles become release notes (enforced in those projects; see their project files).
- **Plain sentences** are the shape of merged community MR titles and commit subjects in gitlab-org/gitlab (observed).
- When you follow a project's own convention, the Danger rules above still apply wherever Danger runs.
- **Check a message with commitlint without making a commit** by piping it in: `git log -1 --format=%B <commit> | npx commitlint`, run in the project's checkout so that commitlint finds the project's configuration (`.commitlintrc.yml` in the elasticsearch and zoekt indexers). With no `--from`, `--to` or `--edit`, commitlint reads the message from standard input; without a configuration it finds no rules and stops with an error that says nothing about your message (documented, https://commitlint.js.org/reference/cli.html).

Sources: gitlab-org/gitlab-elasticsearch-indexer:.commitlintrc.yml@f6cf341acfd000e5e5b948cfc393a61b6bf57adc ;
gitlab-org/gitlab-zoekt-indexer:.commitlintrc.yml@573575e750d1358ff99b2b21dcbcdb88abb944de ;
https://commitlint.js.org/reference/cli.html

## Changelog entries

Where the gitlab-dangerfiles changelog rule runs (enforced):

- Add a **Git trailer** on the commit you want in the changelog: `Changelog: added`, `fixed`, `changed`, `deprecated`, `removed`, `security`, `performance` or `other` (or a category from the project's `.gitlab/changelog_config.yml`). The key is spelled `Changelog` with a capital C; a wrong key or category is an error.
- **Never edit CHANGELOG.md** by hand where trailers generate it; Danger warns. The security-products Danger below is the opposite case.
- A missing trailer only produces a "CHANGELOG missing" message unless a rule requires it, so ignore the message for changes that need no entry.
- Where the project's squash commit template carries a commit message (`%{first_commit}` in gitlab-org/gitlab, charts/gitlab and omnibus-gitlab, `%{first_multiline_commit}` in gitlab-qa and gitlab-triage), put the trailer on the **first commit** and give that commit a body, so that Danger, which lints the oldest commit with a body as the squash message, checks the same commit. The squashed commit is built from it, and a maintainer asked a contributor to move a trailer that sat on the second commit (documented; observed, 1). So when a review change makes that commit's message untrue, reword it in the same push as the fix, and when review redesigns the change, replace the commit rather than add one (references/projects/gitlab-org__gitlab.md, Commits and title). Read `squash_commit_template` from `GET /projects/<url-encoded path>` with any account's token first: an anonymous call leaves the field out, which does not mean it is null. Where it is null, the squash commit is the MR title alone (see Squash, fixup and suggestion commits above), so no trailer on any commit reaches the default branch: in gitlab-org/gitlab-pages a squashed MR lost its `Changelog: fixed` while an MR merged with squash off kept it. There, a change that needs an entry is merged with squash off (untick "Squash commits when merge request is accepted" before the MR joins a merge train), or the merger writes the trailer into the squash message (enforced; settings checked 2026-10-22; observed, 2). As the MR's author you can untick it yourself, in the MR or with `PUT /projects/:id/merge_requests/:iid` and `squash=false`, wherever the project's `squash_option` is `default_on` or `default_off` ("Encourage" or "Allow"; with `always`, "Require", nobody can). Changing it is not a push, so it keeps the approvals: of the changes to the MR itself, only a push to the source branch that changes the diff, or a change of target branch, removes them (references/review.md, section 9), and re-requesting an approver removes theirs (references/review.md, section 8) (documented; enforced; observed, 1, gitlab-org/gitlab-pages!1368, approved before the change and still approved after it).

In **gitlab-org/gitlab** specifically (documented in its changelog guide; Danger enforces parts):

- An entry is needed when users can observe the change, a REST or GraphQL client contract changes, a database migration is added, or a security issue is fixed; Danger fails when a migration is added or a feature flag removed without one. No entry for docs-only, developer-only or pure refactor changes.
- Work behind a feature flag gets no entry while the flag is off by default; it gets one when the flag is enabled by default or removed, or when the MR adds a migration. For a community contribution the guides disagree, and the changelog guide lets a community member keep an entry anyway (references/projects/gitlab-org__gitlab.md, Changelog).
- `EE: true` goes next to `Changelog:` only when the change exists only in GitLab Enterprise Edition. When your MR has a `Changelog:` trailer commit and changes files under `ee/`, Danger warns that `EE: true` is missing (it says nothing when there is no trailer, or when the entry is required, for example for a migration); the changelog guide says not to add it for changes that apply to both editions. **This is a conflict between the docs and the bot**: follow the guide and explain in the Danger thread why you did not add it; reviewers accepted that (observed, 6).

Projects that do **not** use trailers include triage-ops (its Dangerfile excludes the changelog rule), client-go (the MR's `type::` label decides the semantic-release version bump: `type::feature` minor, `type::bug` patch, `type::maintenance` none) and the Terraform provider (the release script uses MR titles). Do not bump a gem version in a feature MR: releases go through a separate Release MR template in gitlab-triage, gitlab-glfm-markdown, gitlab-grape-openapi, gitlab-dangerfiles and gitlab-qa (documented).

The **security-products Danger** (the `danger-bot` image that the
security-products templates' `includes-dev/danger.yml` runs, in the projects
that keep that job, such as analyzers/report; analyzers/dependency-scanning
replaces it with the danger-review component and uses changie entries, see its
project file) has its own changelog rule, in manual mode unless a project sets
`DANGER_CHANGELOG_MODE=trailer`. There `CHANGELOG.md` is written by hand: add a
`## vX.Y.Z` heading for your change, put your entry on the line right after it,
and end that entry with ` (!<iid>)`, the MR's own iid, or Danger fails with
"Merge request ID was not set" or "was incorrectly set". The `v0.12` image the
templates run reads only that line (or, when that line is a `### ` heading, the
second line after it), so a blank line between the heading and your entry fails
too; the fix on `master` that skips blank lines is not in that image. An MR
that leaves `CHANGELOG.md` alone only gets a warning, and none with the
`documentation` label (enforced). That Danger never runs for an MR from a
fork, not even in a pipeline a member runs (references/bots.md, section 2),
but the release is cut from the entry, and a maintainer added a missing one to
a community MR before releasing it (observed, 1): open the MR, then amend the
entry with its iid and force-push before you ask for review.

Sources: gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/plugins/changelog.rb@36e1b034485d736b989a5335c952312d773cf610 ;
gitlab-org/gitlab:doc/development/changelog.md@8ecba73cb0dae6b779b1894c82a5c3d26d447351 ;
gitlab-org/gitlab:doc/development/feature_flags/_index.md@ca626558440807b0ddac9f74d8a8612a953934eb ;
gitlab-org/quality/triage-ops:Dangerfile@11fbe595a2a78dc5bb9b6125c8487e33a6bb4dc4 ;
gitlab-org/api/client-go:.releaserc.json@c31b900a174c7f4142d2933b24cbb69199c7619e ;
gitlab-org/terraform-provider-gitlab:scripts/changelog/main.go@bab674db675a4bc96892c5ec1b319e15d373bee1 ;
gitlab-org/ruby/gems/gitlab-triage:.gitlab/merge_request_templates/Release.md@b57acfb440c421ba38c927f258bcdfa756df806e ;
gitlab-org/security-products/danger-bot:changelog/Dangerfile@0b9aeb318bbb27f57b848511bcc227bdecbe816d ;
gitlab-org/security-products/danger-bot:changelog/changelog.rb@d7277f5bf397558966fc5514eec730584933e48a ;
https://gitlab.com/gitlab-org/security-products/danger-bot/-/blob/da389b33dc873e9e6fc7ebeed6315c0ec338fe5a/changelog/changelog.rb ;
https://gitlab.com/gitlab-org/security-products/danger-bot/container_registry/2117523 ;
gitlab-org/security-products/ci-templates:includes-dev/danger.yml@73b6702121d92097b435e416367618ffb710144c ;
gitlab-org/security-products/analyzers/dependency-scanning:.gitlab-ci.yml@55185c7e8a196aa1b76a95ce7b22017d609b8329 ;
gitlab-org/gitlab:lib/api/projects.rb@20a3771a8ca9fb84cdc96c7f77a8e39638e8fb62 ;
gitlab-org/gitlab:lib/api/entities/project.rb@136cefcd00c6b99dbf114f99aac654035be2f0c7 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/259951 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261813 ;
https://gitlab.com/gitlab-org/gitlab-pages/-/commit/e8425efe1e3ead198f26045099c579bd3a2fad0f ;
https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/1358 ;
https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/1213 ;
https://gitlab.com/gitlab-org/security-products/analyzers/report/-/merge_requests/103 ;
gitlab-org/gitlab:doc/user/project/merge_requests/squash_and_merge.md@0457b888ebac21085d1e8a48d1bfc283c38561c7 ;
gitlab-org/gitlab:doc/api/projects.md@a2ea8aaf67d442b6c89e85a0a417cac11ba6e5f1 ;
gitlab-org/gitlab:ee/app/services/merge_requests/refresh/approval_service.rb@31e0b32d95a2cd92df84935261c15eff94836303 ;
gitlab-org/gitlab:ee/app/services/ee/merge_requests/update_service.rb@d57af02832720526a6252afbb9a27729f2b69739 ;
https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/1368

## MR titles

- **Write the title as the final commit message where it is one, to the commit subject rules**: at least 3 words that say what changes, and at most 72 characters. With squash on and no squash template (`squash_commit_template` null: gitlab-runner, cli, gitlab-pages, container-registry), the title is the commit on the default branch and, in projects that generate changelogs from MRs, the release note line (enforced in cli, VS Code extension, language server; documented in the Terraform provider). Where the template is `%{first_commit}` (gitlab-org/gitlab, charts/gitlab, omnibus-gitlab), the full message of the MR's oldest commit lands and the title appears only in the merge commit, where no rule holds it to those limits (next bullet); where it is `%{first_multiline_commit}` (triage-ops, gitlab-qa, gitlab-triage), the oldest commit with a body lands, or the title when no commit has one; gitlab-triage squashes only the MRs where someone ticks squash, the author or the merging maintainer, since it is off by default there (enforced; documented; settings checked 2026-10-22, gitlab-triage's 2026-10-26).
- **Nothing checks a title unless the project adds a rule.** No gitlab-dangerfiles rule checks a title: the gem lints commits, not the title, since its `commit_messages` rule calls only `lint_commits` and `lint_mr_title` is called only from the gem's own specs. So where Danger runs gitlab-dangerfiles' rules, gitlab-org/gitlab and gitlab-runner included, nothing checks a title's length, word count or capital letter, while a commit subject over 72 characters fails with squash off, and with squash on fails only in the oldest commit that has a body and warns elsewhere (Squash, fixup and suggestion commits, above): merged titles reach 104 characters in gitlab-runner, where the title is the squash commit, and 120 in gitlab-org/gitlab (enforced; observed, 12 and 5 of the last 100 merged MRs there over 72, read 2026-10-26). A title is checked where a project adds its own rule, for example: the security-products danger-bot warns above 72 characters; cli, the VS Code extension, ai-assist and knowledge-graph run commitlint on it; and artifact-registry, gitlab-elasticsearch-indexer and gitlab-zoekt-indexer run a `lint:mr-title` job, the last two only on merge train pipelines (enforced; their project files).
- **Never** leave an auto-generated title such as "Update file", "Add new file", "Delete X" or "Patch 1"; MRs with such titles and an untouched template were closed as unexplained (observed, 16).
- Keep `Draft:` while the MR is not ready; `@gitlab-bot ready` removes a leading `Draft:`, `[Draft]`, `(Draft)`, `WIP:`, `[WIP]` or `(WIP)`, in any case, for you (enforced).
- In gitlab-org/gitlab, the Default template suggests a CI-skip marker in a draft's title to save compute; remove it and push when you want a pipeline, because editing the title alone starts nothing (documented).

Sources: gitlab-org/ruby/gems/gitlab-dangerfiles:lib/gitlab/dangerfiles/base_linter.rb@38d20dd458648a7740b77208e4a592de6164341d ;
gitlab-org/cli:scripts/commit-lint/lint.js@ada4904ff16262641e4df285ea177a744dc431a1 ;
gitlab-org/gitlab:doc/user/project/merge_requests/commit_templates.md@ae75c0d973fefc2e7d0a10debe6dfff9f2432956 ;
gitlab-org/gitlab:lib/gitlab/merge_requests/message_generator.rb@b2d3926485cf2c40258bd1a87b5baac01a6e6771 ;
gitlab-org/gitlab:app/models/merge_request.rb@b30ae611be431291816fb70e6678d011dae4e6fc ;
gitlab-org/gitlab:.gitlab/merge_request_templates/Default.md@4529e892724abdb915a428d017c907a6e3081e70 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:triage/triage/reaction.rb@839eee7fc991f240c66053781c01d6754db849c7 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/1765 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/commit_messages/Dangerfile@6aef04c023ff0dcda60d16a771507266afb2376a ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/plugins/commit_messages.rb@7dccad2f4f8fbff84b00c99421d8396219bad7a1 ;
gitlab-org/gitlab-runner:Dangerfile@a89440e49866ecd29f22a9c03515d9e43725a3d3 ;
gitlab-org/gitlab:Dangerfile@4f9fd1dd605c457a0360a34fb762c8abc987d431 ;
gitlab-org/security-products/danger-bot:metadata/Dangerfile@944ffdf4be65ceede4bba671a2057220496610ed ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7268 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7428 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/251840 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264992 ;
gitlab-org/ruby/gems/gitlab-triage:.gitlab/merge_request_templates/Default.md@664448e8d2cb872686d4de37037f711293b87520

## MR descriptions

Fill the project's template rather than replacing it. Whatever the template,
reviewers look for (documented in templates across projects; observed, 16
closes for unexplained changes):

1. **What changes and why**, including why the code exists, not only what it does.
2. **How a reviewer can validate it locally**: numbered steps, feature flags to enable, commands and versions, and what you saw. For a fix, say that the new test fails without the change.
3. **Screenshots or recordings, before and after**, for any UI change (documented in gitlab-org/gitlab's Default template).
4. **The related issue**, linked and cited as described in Linking the issue, below.
5. **Any behaviour change users or API clients will observe**, with your reasoning against the project's API style guide, so a maintainer can accept it or ask for an additive alternative (documented in gitlab-org/gitlab's acceptance criteria; observed, 5). For example, a change from a 500 to another supported status code is a bug fix, not a breaking change, per the API style guide (`gitlab-org/gitlab:doc/development/api_styleguide.md`); state that reasoning in the description (see references/projects/gitlab-org__gitlab.md, API and GraphQL contracts). State the change for exactly the inputs whose result changes, and check the sentence before you publish it by running the old and the new code on several values across the range it names, not only at its endpoint: Ruby's `String#[]` never raised for a length past the end of the input, only for one too large for a C long (`"test"[1, 2**63-1]` returns `"est"`, `2**63` raises `RangeError`), so "an argument larger than the input no longer raises" would be false where "an argument too large for a C long no longer raises" is true. An absolute claim such as "nothing renders differently" needs the whole input domain; otherwise write "in practice" and name the exception (in JavaScript, `String(1e-7)` is `"1e-7"`, a non-integer without a decimal point) (observed, 2: the descriptions of gitlab-org/gitlab!264870 and !264895).
6. **For database changes in gitlab-org/gitlab**: the full SQL the application runs and its query plans, as the database review guide asks; see references/troubleshooting.md (Danger asks for a database review) for the reminder and its labels, and the project file for details (enforced by Danger; documented).
7. **Large MRs**: Danger warns above 500 changed lines ("quite big") and above 2000 ("definitely too big"); some projects set their own thresholds or fail. Explain why the change cannot be split, or split it into a series and say how the parts relate (enforced; documented in gitlab-org/gitlab). Reviewers count concerns, not lines: on a 1,500-line MR whose description explained that about 1,000 lines were specs and fixtures, a maintainer still asked to split it, because "My concern isn't the line count though, it's how many separate concerns a reviewer has to approve at once", and a behaviour change among unrelated additions "is easy to under-scrutinize". The split asked for was the core change and its docs first, then each further behaviour change, new mailer or audit event as its own follow-up, or GitLab's stacked diffs to keep them chained; the maintainer then left the reviewers and asked the group's engineering manager to route the behaviour change (observed, 1: gitlab-org/gitlab!265240, note 4094622394). Plan the split before you open the MR: one concern per MR, each with its own tests and docs (SKILL.md, non-negotiable 4). When a reviewer asks for the split, open the reduced MR and the follow-ups together, make each follow-up depend on the reduced one (Linking the issue, below), and reply in the reviewer's thread with the MRs in merge order; MRs opened because a reviewer asked for the split are part of the same contribution (observed, 1: gitlab-org/gitlab!265240, reply 4095501773).
8. **AI assistance**: say that AI tools helped where the template asks, and that you checked the result. Several templates open with a checkbox for AI-generated content that points to GitLab's DCO and CLA page (https://about.gitlab.com/community/contribute/dco-cla/); tick it when it applies. What you agree to by submitting is in references/workflow.md, section 1 (documented; observed, 5).
9. **If you work from a personal fork**, say so, and say which jobs cannot run there (observed).
10. **Set the type label after you open.** The `Closes <issue URL>` line makes gitlab-bot copy the issue's first `type::` label onto the MR; check it actually appeared, and if the copier set none (umbrella issue, or the welcome note arrived late) add it yourself with `@gitlab-bot label ~"type::bug"`; you cannot set it directly (SKILL.md step 10; references/review.md, section 6).

Some templates contain variables such as `%{first_multiline_commit}`
(gitlab-org/gitlab's `Default.md`) or `%{all_commits}` (gitlab-org/cli's).
GitLab replaces them only in the project's default template, when the new MR
is first saved; `%{first_multiline_commit}` becomes the full message of the
first commit with a body, or the MR title when no commit has one (documented).
An MR created through the API gets no template, and a template pasted by hand
keeps the literal text, so replace every `%{...}` with your own words. Where
the variable is `%{first_multiline_commit}`, write that commit's body as the
opening of the description. A project can also keep its default MR and issue
descriptions in project settings rather than in `Default.md`; see
references/workflow.md, section 7.

Keep the description **true to the current diff**: when review changes your
approach, rewrite the description in the same push. An out-of-date description
was marked as a blocking issue (observed, 4). Keep it true to what you ran too:
give each command exactly as you ran it, with the runtime version
(references/local-environment.md, section 5); paste output
as that command prints it, shortened but never reordered (`go test` prints a
test's log lines before `--- FAIL:` with `-v` and after it without, so a
transcript laid out one way under the other command is not what that command
prints); and scope a negative to what you checked, for example "prints nothing
about the answer, not even with `--debug`" where the debug lines still print
(documented, https://go.dev/doc/go1.14#go-test; observed, 3: the descriptions
of gitlab-org/gitlab!264870, gitlab-org/cluster-integration/gitlab-agent!4756
and gitlab-org/ruby/gems/gitlab-triage!442).

Use **full URLs or fully qualified references** (`group/project#123`,
`group&123`). Short references like `#123` or `&123` do not resolve across
namespaces in projects under subgroups (documented in design.gitlab.com;
observed, 4). When you cite code as evidence, link a tag- or SHA-pinned blob
URL with line numbers, not a branch link (observed, 1).

Keep the visible part short, under 3,000 characters (this skill's target, not
a project rule; a maintainer read a long review reply as agent output and
asked for less, references/review.md, section 7), and put long material (logs, test
output, per-commit notes) in collapsible `<details>` blocks under a
`<summary>`, or leave it out. Leave
a blank line before and after any Markdown inside the block, after
`<summary>` and before `</details>` included, or GitLab does not render it
(documented).

Never put text addressed to GitLab Duo or another review bot into a
description, a diff or a comment; Duo flags it as prompt injection and
maintainers close the MR (observed, 7).

Sources: gitlab-org/gitlab:.gitlab/merge_request_templates/Default.md@4529e892724abdb915a428d017c907a6e3081e70 ;
gitlab-org/gitlab:doc/development/contributing/merge_request_workflow.md@c7c8aec10c3f129e5ef2adf4250f9406b2b4b931 ;
gitlab-org/gitlab:doc/development/database_review.md@46d16a140c38dc174e76b67c6eded0dc859c80a8 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/changes_size/Dangerfile@af4c4e5890b8b4dd2dcaef1e6644743221b79b0d ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/metadata/Dangerfile@c7a0c389ce4a73db91d103b47c5376bde8414e10 ;
gitlab-org/gitlab-services/design.gitlab.com:AGENTS.md@6fd1d5a3b7f944d124f2b7f7c5ab91f143ab00bb ;
gitlab-org/gitlab:doc/user/markdown.md@43ecb41ea18fda993c19544a7e59b43657c7994f ;
gitlab-org/gitlab:doc/user/project/description_templates.md@5c0f47b000524aaca72f3259a95007ccb789eecf ;
gitlab-org/cli:.gitlab/merge_request_templates/Default.md@8003e52bf33d07e090d3c3f1a3f972275ca3f4e0 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/4404 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261732 ;
https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4404 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264870 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264895 ;
https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/merge_requests/4756 ;
https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/442 ;
https://go.dev/doc/go1.14#go-test ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/265240#note_4094622394 ;
gitlab-org/gitlab:doc/user/project/merge_requests/stacked_diffs.md@f88651d6f7c99af97174c71208c74b9335605363 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3147#note_4094024169

## Linking the issue

- **`Closes` only when merging finishes the issue.** GitLab closes the issue on merge. When the MR is one part, or the feature stays inactive until other work lands, write `Related to <URL>` or `Part of <URL>` and open a follow-up issue for the rest (observed, 4).
- **Use one form that every automation reads:** start a line with `Closes https://gitlab.com/<group>/<project>/-/issues/<iid>` (or `Related to` with the same URL), using the `/-/issues/` path even when the browser shows `/-/work_items/<iid>`. Two separate automations read the link, and only this form satisfies both (observed: of 52 merged community MRs in the samples written this way, 51 carry `linked-issue`).
- **gitlab-bot's label copier.** On open and on every description edit of an MR in a `gitlab-org` project (and only there), gitlab-bot looks for a line that **starts** with one of `related to`, `relates to`, `relate to`, `contributes to`, `contribute to`, `closes`, `close` or `see` (any case), followed by one space and either a full `https://gitlab.com/<group>/<project>/-/issues/<iid>` URL or a same-project `#<iid>`. It ignores `Fixes` and `Resolves`, cross-project short references (`group/project#123`) and `/-/work_items/` URLs. When it finds an issue, it copies the issue's first `type::` label (unless the MR already has one) and its section, stage and group labels onto the MR (enforced). Check the copied `type::` label: a link to an umbrella issue can set the wrong one.
- **The `linked-issue` label** is not added by gitlab-bot. Its label events show a separate GitLab community automation service account (`gl-service-community-contrib-toolbox-bot`) adding it, and it accepts more forms than the label copier: in the samples it was added for short references such as `Closes #<iid>` and `Closes group/project#<iid>`, and for `/-/work_items/` URLs too (observed, 205 and 83 merged MRs). Its parser was not found in any public source (see Open questions below), so check that the label appeared after you save the description. The hackathon leaderboard counts merged MRs carrying `linked-issue` (enforced).
- **Judge the link by the `linked-issue` label and your description**, not by the merge request API's `closes_issues` list, which can stay empty for `Closes gitlab-org/gitlab#<iid>` or `Closes #<iid>` because the issues are work items (observed, 3).
- **When you cite a related issue, take its scope from its own words, not its title**: gitlab-org/gitlab#635559, titled "Key the package processing lease on project, name and version", proposes that key "for every async format" (observed, 1).
- **When a change spans two repositories**, link each MR from the other's description and say which must merge first; each should work on its own (observed, 1).
- **A stacked MR from a fork** cannot target another fork's branch: branch from the first MR's branch, target the default branch, say in the description that it contains the first MR's commits and must merge after it, and rebase once the first merges (observed, 2). As the author, without a role, you can also make it depend on the first MR through merge request dependencies, and the first MR then shows "marked this merge request as blocking !N" (observed, 3: gitlab-org/gitlab!265240, notes 4095465612, 4095483642 and 4095501245). Where the squash template is `%{first_commit}` (gitlab-org/gitlab), a stacked MR merged without that rebase would take the first MR's first commit message as its squash message, so rebase every stacked MR onto the default branch once the first merges, before you ask for its review (enforced). While both are in review, a commit you push to the first MR for its review goes into the stacked MR too, in the same round (`git cherry-pick <sha>` on its branch), and the stacked MR's description names that commit among the first MR's, so a reviewer of the stacked MR reads the first MR's code as it will merge (observed, 1: gitlab-org/gitlab-runner!7677 carries the review commit of !7676). Once the first merges, rebase only your own commits, `git rebase --onto upstream/<default> <the first MR's commit yours start from>`, which drops each review commit you brought over whose change is already upstream; where a later review commit changed lines an earlier one had changed, the earlier one stops on a conflict instead, because the default branch holds those lines as the later one left them: run `git rebase --skip` for it, never for a commit of your own, and the later one is then dropped; where the project squashes, a plain `git rebase upstream/<default>` replays the first MR's commits onto a default branch that holds them as one squash commit and stops on a conflict wherever a review commit changed lines an earlier one added (enforced; https://git-scm.com/docs/git-rebase).

Sources: gitlab-org/quality/triage-ops:triage/triage/related_issue_finder.rb@6ea4023d63e7f4c730250ef92eae2b56df27fc17 ;
gitlab-org/quality/triage-ops:triage/processor/apply_labels_from_related_issue.rb@b4d49ec8be9223319bdaecfdaf3574698bb168a3 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/queries/hackathon_leaderboard_query.rb@0aab5e7e93f587748ab6cd91f42b6fcfb1fc0422 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/4408 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7635 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261343 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261288 ;
https://gitlab.com/gitlab-org/fleeting/fleeting/-/merge_requests/99 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7677 ;
https://gitlab.com/gitlab-org/gitlab/-/issues/635559 ;
https://git-scm.com/docs/git-rebase ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/265240#note_4095501773 ;
gitlab-org/gitlab:doc/user/project/merge_requests/commit_templates.md@ae75c0d973fefc2e7d0a10debe6dfff9f2432956

## Open questions

- Which component adds the `linked-issue` label, and exactly which link forms it accepts. The label events name a community automation service account, but no code for it was found in gitlab-org/quality/triage-ops or in the contributor platform, which only reads the label.
