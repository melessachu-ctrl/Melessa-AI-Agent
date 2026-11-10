# Documentation contributions

Most of this file is about the product documentation in gitlab-org/gitlab
(`doc/`), which is where most documentation MRs go and where the rules are
written down and linted. Other projects keep their own docs tooling and style
(markdownlint configs, Vale packages, `make docs` targets); read the project
file under references/projects/ and the project's own lint config before
assuming the gitlab-org/gitlab rules apply there.

All counts below come from a sample of 80 community documentation MRs in
gitlab-org/gitlab.

## Contents

- [1. Workflow](#1-workflow)
- [2. The MR: template, labels, commits, changelog](#2-the-mr-template-labels-commits-changelog)
- [3. Lint before you push](#3-lint-before-you-push)
- [4. The docs pipeline](#4-the-docs-pipeline)
- [5. Review: who and what](#5-review-who-and-what)
- [6. Style rules reviewers apply most](#6-style-rules-reviewers-apply-most)
- [7. History items, feature flags and deprecations](#7-history-items-feature-flags-and-deprecations)
- [8. API documentation](#8-api-documentation)
- [9. Answering docs review](#9-answering-docs-review)

## 1. Workflow

- **Work from the community fork** `gitlab-community/gitlab-org/gitlab` (onboarding at https://contributors.gitlab.com/start; say you want to contribute to documentation). A personal fork works too, with pipelines on your own minutes (documented).
- **Find work** in the documentation issue list filtered by `documentation`, `docs-only` and `quick win`. Skip assigned issues. Many docs issues accept several contributors without assignment (one file each, for example); otherwise comment and ask to work on it. A docs change with no code behind it may go straight to an MR (documented).
- **Opening an issue instead:** use the Documentation template, start the title with `Docs:` or `Docs feedback:`, leave milestone and assignee empty, and mention the group's technical writer, found as section 5 explains: the page's `group:` front matter and the `[Documentation Pages]` section of `.gitlab/CODEOWNERS` (documented).
- **Search first.** Duplicate docs MRs are closed in favour of the earlier one or the one that meets the issue's criteria (observed, 2).
- **For anything beyond a one-page edit, clone the fork** rather than using the Web IDE, install the hooks as references/projects/gitlab-org__gitlab.md, Local checks before pushing, says (`mise exec ruby@3.3.11 -- bundle install`, then `mise exec ruby@3.3.11 -- bundle exec lefthook install`, and commit and push under the same `mise exec`, the push with `COMMIT_LINT_BASE=upstream/master`), since its `danger` and `commit-message-linting` pre-push hooks run `bundle exec` on every push, and install the pinned markdownlint-cli2 and Vale with `mise install`, so you get the same pre-push checks and tool versions CI uses (documented; enforced).
- **Hackathons:** see references/hackathon-and-platform.md for the three-issue limit on docs issues.

Sources: gitlab-org/gitlab:doc/development/documentation/_index.md@a45ac1f25e1087de2d934c1329ee44a57451ac3e ;
gitlab-org/gitlab:doc/development/documentation/workflow.md@c482442667336a6d129cf6806bed323f5cb60124 ;
gitlab-org/gitlab:doc/development/documentation/testing/_index.md@43ecb41ea18fda993c19544a7e59b43657c7994f ;
gitlab-org/gitlab:doc/development/documentation/authoring_environment.md@2d7d0ac7ca49f1d9f94d792b4bae3dc63b3b411d ;
gitlab-org/gitlab:lefthook.yml@43ecb41ea18fda993c19544a7e59b43657c7994f ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260833 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/262351

## 2. The MR: template, labels, commits, changelog

- **Template.** Choose the `Documentation` MR template. Fill "What does this MR do?", link the issue under "Related issues" with a full URL, and tick the author checklist. Leave the template's quick actions in place (they take effect only for members), and set the labels yourself with `@gitlab-bot label` as the next bullet shows (documented).
- **Labels.** `documentation`, `type::maintenance` with `maintenance::refactor` (content) or `maintenance::workflow` (metadata or tooling), and the `group::` label from the page's `group:` metadata. You cannot set them directly, so post `@gitlab-bot label ~documentation ~"type::maintenance" ~"maintenance::refactor" ~"group::<name>"`. Leave `docs-only` off that line: the label command refuses it, and gitlab-bot adds it by itself five minutes after an update to the MR when every changed file is under `doc/`, `docs/` or `doc-locale/`, and removes it when one is not or `backend` is set, in gitlab-org/gitlab, gitlab-org/omnibus-gitlab, gitlab-org/gitlab-runner, gitlab-org/charts/gitlab, gitlab-org/cloud-native/gitlab-operator and gitlab-org/gitlab-docs (enforced; observed, 6 MRs in gitlab-org/gitlab). Leave `tw::` labels to the technical writer. Danger's "Labels missing" note asks for `documentation` when it is absent (enforced; observed, 28 Danger notes and 36 uses of the label command). Stage and section labels follow the group label automatically; `docs::` labels are for team members, and the bot refuses them (observed, 2).
- **Commits.** The Danger commit linter applies (references/commits-and-descriptions.md): a short capitalised subject without a final period, for example `Fix typo in runner docs`; a body wrapped at 72 when the change is large; full URLs instead of `#123` or `!123` (enforced; observed, 8).
- **No changelog trailer** on a documentation-only MR. A code MR that changes behaviour carries its docs in the same MR and keeps its trailer, as gitlab-org/gitlab's guides have it; section 5 names a project that wants the docs in an MR of their own (documented).
- **Title.** Short, sentence case, imperative, naming the page or feature, for example "Fix curl options in deploy tokens API docs" (observed).

Sources: gitlab-org/gitlab:.gitlab/merge_request_templates/Documentation.md@ba390ce8d1d0605d376d4edae1e5272e4f8a4086 ;
gitlab-org/gitlab:doc/development/documentation/workflow.md@c482442667336a6d129cf6806bed323f5cb60124 ;
gitlab-org/gitlab:tooling/danger/documentation.rb@2539cce668263e7cc9fde83c73ab100c63777b54 ;
gitlab-org/gitlab:doc/development/changelog.md@8ecba73cb0dae6b779b1894c82a5c3d26d447351 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_label.rb@46a4823632f3401513d233b99137d836d520e2ad ;
gitlab-org/quality/triage-ops:triage/processor/docs_only_labeller.rb@ddd8a20b9d14ba5c8ce9ba8a35812f4197b19001 ;
gitlab-org/quality/triage-ops:triage/job/docs_only_labeller_job.rb@b9fa0269aeebba965a633bdb1bd58dbfbb95f166 ;
gitlab-org/quality/triage-ops:triage/triage/event.rb@6bd2523b3119c773e34efa5075916f2d8c577b88 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/254698 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/262693 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264517

## 3. Lint before you push

Run the same script CI runs, on the files you changed:

```shell
scripts/lint-doc.sh doc/path/page.md
```

It runs markdownlint-cli2, Vale at error level and structural checks on the
files you name. Two traps, both in the script (enforced):

- **`MD_DOC_PATH` limits only markdownlint.** The docs testing page gives
  `MD_DOC_PATH=doc/path/page.md bundle exec rake lint:markdown` for one file,
  but with no file arguments the script still hands Vale all of `doc/` and
  `tooling/docs/api/tags/`. Pass the files as arguments instead.
- **The Vale container fallback lints nothing.** markdownlint-cli2 must be on
  your PATH. Vale runs from your PATH or, if it is not installed, from the docs
  lint image through Docker or nerdctl, but there the script passes Vale its
  options and not the files: Vale prints its usage, exits 0, and the script
  reports success without linting any prose (checked 2026-10-22, while
  gitlab-org/gitlab!264217, which passes the files there, was open). The testing
  page offers a working Docker or `containerd` installation as an alternative
  to installing the tools; with the script as it is, that alternative lints no
  prose (documented, with a difference between the page and the script).
  Install Vale (`mise install` installs the versions `.tool-versions` pins), or
  run the whole script inside the image the docs-lint jobs use, named in
  `.docs-markdown-lint-image` in `.gitlab/ci/docs.gitlab-ci.yml` (the script
  names the same tag), mounted as the script mounts it:
  `docker run --rm -v "$PWD:/gitlab" -w /gitlab <image> scripts/lint-doc.sh doc/path/page.md`.
  The same image runs the `docs-lint links` job
  (`lychee --offline --no-progress --include-fragments doc tooling/docs/api/tags`)
  and the `code_quality` job (Vale at `--minAlertLevel warning`).

What `lint-doc.sh` fails on (enforced): curl short options (`-H`, `-X`; use
`--header`, `--request`); a `README.md` under `doc/`; files with the executable
bit (use mode 644); uppercase letters in directory or file names; PNG images
without a milestone suffix such as `_v18_5.png`; restricted directory names;
markdownlint errors; Vale errors.

**Vale levels.** Errors fail CI. Warnings do not, but the `code_quality` job
shows them in the MR diff and reviewers ask for them, so also run
`vale doc/path/page.md` and fix warnings on the lines you touched (with
Lefthook, `VALE_WARNINGS=true`). Suggestions show only locally. Turn a rule off
only for a justified span: `<!-- vale gitlab_base.RuleName = NO -->` then
`= YES` (documented).

**markdownlint.** Disable a rule only for a span:
`<!-- markdownlint-disable MD044 -->` ... `<!-- markdownlint-enable MD044 -->`.
MD044 enforces product name capitalisation; a name used as a literal value
goes in backticks instead (documented).

**Outside gitlab-org/gitlab.** Several projects run their docs lint jobs in
the public image
`registry.gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/lint-markdown:<tag>`,
whose tag names the tool versions (for example
`alpine-3.24-vale-3.21.0-markdownlint2-0.23.2-lychee-0.24.2-rumdl-0.2.69`):
gitlab-vscode-extension (`check-docs-markdown`), gitlab-lsp
(`lint_documentation`), charts/gitlab (`check_docs_content`,
`check_docs_markdown`), omnibus-gitlab, ai-assist and gitlab-runner
(`docs:lint markdown`, all through `DOCS_LINT_IMAGE`), and knowledge-graph,
which pins an older tag (Vale 3.14.1, markdownlint-cli2 0.22.1). Run the
job's script lines (for example
`vale --minAlertLevel error docs README.md` or
`markdownlint-cli2 'docs/**/*.md'`) in the exact tag the project's CI names,
from the repository root, so the project's own `.vale.ini` and markdownlint
configuration apply (enforced). The project files under references/projects/
name each job.

Sources: gitlab-org/gitlab:scripts/lint-doc.sh@19f194a7cf99ddb68d3e48aaaa5a0a92ee733724 ;
gitlab-org/gitlab:doc/development/documentation/testing/_index.md@43ecb41ea18fda993c19544a7e59b43657c7994f ;
gitlab-org/gitlab:doc/development/documentation/testing/vale.md@b51e8ccba6166950e8b26dc96013b362626e4bcb ;
gitlab-org/gitlab:doc/development/documentation/testing/markdownlint.md@c492c7c64ac37fcf3d77e69ccb00b0a6e175fc7e ;
gitlab-org/gitlab:.markdownlint-cli2.yaml@19f194a7cf99ddb68d3e48aaaa5a0a92ee733724 ;
gitlab-org/gitlab:lefthook.yml@43ecb41ea18fda993c19544a7e59b43657c7994f ;
gitlab-org/gitlab:.gitlab/ci/docs.gitlab-ci.yml@54e058bc18fd48b781d55b8789b3148619df07b8 ;
gitlab-org/gitlab:.tool-versions@00dd3e10c1b80408749e99b794d744e8239bbf93 ;
gitlab-org/gitlab:lib/tasks/lint.rake@3fda64de5927bd0e0e6944c521e428d302681877 ;
gitlab-org/gitlab-vscode-extension:.gitlab-ci.yml@1b25b697f8c190dbc41e6eda872db1071e1d6405 ;
gitlab-org/editor-extensions/gitlab-lsp:.gitlab-ci.yml@4cd9c0be47c4c0d887081de587422070de3836ad ;
gitlab-org/charts/gitlab:.gitlab-ci.yml@d090f2c78b93f6a1ec28521e6efe6bfcedcb08a8 ;
gitlab-org/charts/gitlab:.gitlab/ci/checks.gitlab-ci.yml@47a3ae138781ed28299da7ee2f9fda87a1d57e53 ;
gitlab-org/omnibus-gitlab:gitlab-ci-config/variables.yml@b8ed1b93f8b5bc168830d2513d77e529a16536d9 ;
gitlab-org/omnibus-gitlab:gitlab-ci-config/gitlab-com.yml@4f69a569684040068831872abd85f8209bb1318c ;
gitlab-org/modelops/applied-ml/code-suggestions/ai-assist:.gitlab-ci.yml@9b455b23392cdefdfa9c9ccd9adc0d7bf0693727 ;
gitlab-org/modelops/applied-ml/code-suggestions/ai-assist:.gitlab/ci/lint.gitlab-ci.yml@4e19f61e395994929f42033341061e5bdbae2af9 ;
gitlab-org/orbit/knowledge-graph:.gitlab-ci.yml@84b03cbc5fa497f45aba83a50535142577379ffc ;
gitlab-org/gitlab-runner:.gitlab/ci/qa.gitlab-ci.yml@324d49e7b95e0a7adea909deb2339911c65b61fb ;
gitlab-org/gitlab-runner:.gitlab/ci/_common.gitlab-ci.yml@cf36569c28eb20fc9506b0459a94babd1c747667 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264217

## 4. The docs pipeline

- **Jobs you will see** on a docs MR include `docs-lint markdown` (lint-doc.sh), `docs-lint links` (internal links and anchors, with fragments checked), `docs-lint mermaid`, `docs-lint redirects`, `docs hugo_build`, `docs code_quality` (Vale warnings), and jobs for generated content and UI text. Read the failing job's log; it names the file and rule (documented).
- **Anchors from another open MR fail** `docs-lint links` until that heading is on the default branch. Merge the heading first, or link without the anchor and add it later (observed, 1).
- **Long pipeline pages.** A docs-only MR runs a short pipeline, but changes to `doc/_index.md` or `doc/api/settings.md` need the full tier-3 pipeline, and Danger says so. A team member has to add `pipeline::tier-3` and `pipeline:mr-approved` and run a new pipeline before the merge train accepts the MR (enforced).
- **Review apps.** Rendering a preview needs the manual `review-docs-deploy` job, which external contributors cannot run; ask a team member, or rely on the Markdown preview in your fork (documented). You can also build the site yourself: clone gitlab-org/technical-writing/docs-gitlab-com next to your clone of the project whose docs you change (the build reads sibling directories named `gitlab`, `gitlab-runner`, `omnibus-gitlab`, `charts-gitlab`, `gitlab-operator`, `cli` and others), run `mise trust` and `make setup`, `make clone-docs-projects` for the projects you lack (`CI=true` makes shallow clones), then `make view` and open `http://localhost:1313`; in a container set `HUGO_BIND_IP=0.0.0.0` (documented; references/projects/gitlab-org__technical-writing__docs-gitlab-com.md has the details).
- **What is yours to fix.** A docs-lint, Danger or stale generated-file failure is yours. An infrastructure error (Gitaly resource exhausted, too many active jobs, a flaky end-to-end job, a cancelled merge train) is not: ask once for a retry, quoting the job and error line. Never push empty commits to trigger pipelines (observed, 5).
- **Merge train drops on `pre-merge-checks`** usually mean that no pipeline of the MR ran in the canonical project, or that the newest one there ran at the wrong tier; ask a maintainer to run a new pipeline in the canonical project and set auto-merge again (observed, 18). See references/troubleshooting.md.

Sources: gitlab-org/gitlab:.gitlab/ci/docs.gitlab-ci.yml@54e058bc18fd48b781d55b8789b3148619df07b8 ;
gitlab-org/gitlab:doc/development/documentation/testing/links.md@9439a8e64f1e38f178c32338288f076a0c1c624c ;
gitlab-org/gitlab:tooling/danger/documentation.rb@2539cce668263e7cc9fde83c73ab100c63777b54 ;
gitlab-org/gitlab:doc/development/documentation/review_apps.md@fd8bf7abea9958e15220ba1e4862629e7703f51e ;
gitlab-org/gitlab:.gitlab/ci/includes/review-docs.gitlab-ci.yml@f7172ceaf6a768cc4af04961230bef5737c4d849 ;
gitlab-org/technical-writing/docs-gitlab-com:doc/setup.md@9c9f260d2868e85409f1a685f481cbfb40e6584c ;
gitlab-org/technical-writing/docs-gitlab-com:Makefile@85b04f0244e06b505662fc02faf98a89dabac887 ;
gitlab-org/technical-writing/docs-gitlab-com:mise.toml@3f0ad7b9360e20daee6a58581465f1ffc809714d ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/255704 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261306 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/259765

## 5. Review: who and what

- **Front matter decides the writer.** Every page starts with `stage:`, `group:`, `info:` and `title:`. When adding a page, copy front matter from a sibling about the same feature; when editing, do not change metadata unless the content moves to another group (documented).
- **Finding the technical writer.** Read the page's `group:`; look up its path in the rake-managed block of the `[Documentation Pages]` section of `.gitlab/CODEOWNERS` (generated by `bundle exec rake tw:codeowners`), or the handbook's technical writing assignments for that stage group; the CODEOWNERS approval rules on the MR show the same writer. If that writer is away, pick one who reviewed recent changes to the same page (file history) or the writer for an adjacent group, and request them only after the automation's own request: a writer named in the ready that adds `workflow::ready for review` is replaced a second later by the automation's pick, so let the first ready add the label (a bare one on a docs-only MR), then post `@gitlab-bot ready @<writer>` once the hourly limit allows, or use the platform's Request review, which no hourly limit counts (references/review.md, sections 3 and 4) (documented; enforced).
- **Automatic request.** On a community MR that changes `doc/` and already carries `Community contribution` (references/review.md, section 4), adding `workflow::ready for review` (usually by `@gitlab-bot ready`) makes gitlab-bot request an owner of the page's most specific line in the `[Documentation Pages]` section of `.gitlab/CODEOWNERS` (a technical writer for most pages, an engineering group for some; references/projects/gitlab-org__gitlab.md, Requesting review and choosing reviewers), post "Please review this ~documentation merge request", and add `documentation` and `tw::triaged`. On a docs-only MR with no reviewer, the owner it requests is the reviewer: ask with a bare `@gitlab-bot ready`, since a reviewer named in the ready that adds the label is replaced by the automation's pick (references/review.md, section 4). Do not also assign a writer by hand (enforced; observed, 62).
- **Code plus docs.** The automatic writer request has replaced the code reviewer that `ready` requested, seconds after it (observed, 18). Check the Reviewers list and ask the code reviewer again; the MR needs both (references/review.md).
- **Writers review style, not accuracy.** For behaviour claims the writer often asks an engineer or subject matter expert, or Duo, to confirm. Cite the code (a permalink to the file and line) or the issue in the description so that check is quick (observed, 9).
- **Writer review does not block a code MR.** If a code MR with docs is time-sensitive, a maintainer can merge it and the writer reviews afterwards; mention it in the MR (documented).
- **Special areas:** `doc/development/` (outside `doc/development/documentation/`) needs no writer: Danger labels the MR `development guidelines` and says any maintainer can merge it (enforced; observed, 5). A docs-only MR there gets no roulette row, since the roulette leaves docs files out: post the bare `@gitlab-bot ready` and name no maintainer in it, because the documentation automation's request replaces a reviewer named in that ready, and the owner it requests from the page's line in `[Documentation Pages]` can approve and merge; name a maintainer only if that owner hands the MR on (enforced; observed, 2; references/projects/gitlab-org__gitlab.md, Reviewers for docs). `doc/solutions/` needs a Solutions Architect's approval (enforced). `doc-locale/` (translations) does not accept contributions; fix the English source in `doc/` only (enforced).
- **Docs travel with code.** A user-visible change (API field, status code, setting, UI flow) updates the docs in the same MR. A `feature::addition` or `feature::enhancement` MR that touches no doc file gets a Danger warning (enforced; documented). This is gitlab-org/gitlab's rule; gitlab-org/orbit/knowledge-graph wants code and docs in separate MRs (its project file).

Sources: gitlab-org/gitlab:doc/development/documentation/metadata.md@a45ac1f25e1087de2d934c1329ee44a57451ac3e ;
gitlab-org/gitlab:.gitlab/CODEOWNERS@8d29a90b562187afe47da25e6be78045bae0a383 ;
gitlab-org/gitlab:doc/development/documentation/workflow.md@c482442667336a6d129cf6806bed323f5cb60124 ;
gitlab-org/gitlab:tooling/danger/documentation.rb@2539cce668263e7cc9fde83c73ab100c63777b54 ;
gitlab-org/quality/triage-ops:triage/processor/community/automated_review_request_doc.rb@57fab1afd23617b35a9be9e7fbc79357361ea542 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/gitlab:danger/roulette/Dangerfile@4f9fd1dd605c457a0360a34fb762c8abc987d431 ;
gitlab-org/gitlab:tooling/danger/project_helper.rb@ad5810ae87e4dfe38868d677168a1974ec4e1b18 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/254511 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/257752 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261370 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/252180

## 6. Style rules reviewers apply most

All documented in the style guide unless marked otherwise.

- **One sentence per line**, breaking long sentences at about 100 characters between word groups, never inside a link.
- **Do not realign a whole table** to add a few rows; misaligned new rows are fine. Sentence case in headers.
- **Address the reader as "you"**, not "the user" or "the administrator". Active voice; imperative for steps. Check doubtful words against the word list (for example "canceled", "canceling" with one L; "cancellation" with two). Several word list entries are Vale rules.
- **Alerts:** `> [!note]`, `> [!flag]`, `> [!warning]`, `> [!disclaimer]`, used sparingly and never two in a row. Reviewers often ask to fold a note into the paragraph or steps. The old `NOTE:` syntax no longer renders.
- **Links:** link a target once per page; no anchor links to sections the table of contents already shows; descriptive link text, never "here"; lowercase link text for API pages (`see the [import API](...)`).
- **Footnotes** for long cell content, with labels and references matched (markdownlint MD053 fails otherwise).
- **Fake data only:** `https://gitlab.example.com`, `<your_access_token>`, example users and projects, one host per page, values consistent with each other.
- **Topic types:** each topic is one of concept, task, reference or troubleshooting and follows its template. Task titles start with an active verb; troubleshooting topics name the error or symptom.
- **Single source of truth:** keep each page to its subject; link to the API page instead of copying it; one sentence in the right section beats a new section (observed, 4).
- **Moving content:** move and edit in separate commits, and leave a redirect for every old path (checked by `docs-lint redirects`). Delete content about something not yet available rather than commenting it out.
- **Historical pages** (old release notes, past versions) are not edited except for clear typos (observed, 1).
- **AI-drafted docs:** review every sentence, run Vale, check claims against the code, and say in the description that AI helped; a technical writer must review it.

Sources: gitlab-org/gitlab:doc/development/documentation/styleguide/_index.md@53e910e4913fab8094a18c5453a95f6146064df7 ;
gitlab-org/gitlab:doc/development/documentation/styleguide/word_list.md@5951ddba03f01c1077ad5a3799d5f34d475f61e1 ;
gitlab-org/gitlab:doc/development/documentation/topic_types/_index.md@051d9e43f211c0695094c2c1cda0b7163b87778d ;
gitlab-org/gitlab:doc/development/documentation/topic_types/task.md@53e910e4913fab8094a18c5453a95f6146064df7 ;
gitlab-org/gitlab:doc/development/documentation/topic_types/troubleshooting.md@9439a8e64f1e38f178c32338288f076a0c1c624c ;
gitlab-org/gitlab:doc/development/documentation/redirects.md@52deeca9a6096a7c54435dd7ff0b5f0e7e36e633 ;
gitlab-org/gitlab:doc/development/documentation/ai_guide.md@9439a8e64f1e38f178c32338288f076a0c1c624c ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261370 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260143 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/247709

## 7. History items, feature flags and deprecations

- **History items** go inside the `{{< history >}}` shortcode right after the heading (after availability details if any): start with `-`, link the public issue (or the MR when there is none), and use the milestone your MR merges in, for example `- [Changed](https://gitlab.com/...) in GitLab 18.6.` Never link a confidential issue; do not repeat the tier; do not copy the item to other pages (documented).
- **Missed milestone.** If the release cut passes before merge, change the version before merging; if it merged with the wrong version, open a small follow-up MR (observed, 6).
- **Feature flags** use the exact wording from the feature flag guide. While the flag exists:

  ```markdown
  [Introduced](...) in GitLab X.Y [with a feature flag](../administration/feature_flags/_index.md) named `flag_name`. Disabled by default.
  ```

  When the flag is removed, add the line below and delete the `flag` alert. Adjust the relative link to the page's depth (documented).

  ```markdown
  [Generally available](...) in GitLab X.Y. Feature flag `flag_name` removed.
  ```
- **Deprecations** use a `> [!warning]` alert naming and linking the replacement. Entries under `data/deprecations` change only through the deprecation process; run `mise exec ruby@3.3.11 -- bundle exec rake gitlab:docs:check_deprecations` afterwards (the prefix and why: references/projects/gitlab-org__gitlab.md, Test environment) (documented; observed, 1).

Sources: gitlab-org/gitlab:doc/development/documentation/styleguide/availability_details.md@a17099c64d025302924e98bc1dcef8a6cbc1a120 ;
gitlab-org/gitlab:doc/development/documentation/feature_flags.md@e7403dc3097bb0f0c5ec874a51069f813ebd3589 ;
gitlab-org/gitlab:doc/development/documentation/styleguide/deprecations_and_removals.md@49536284012b47a99da19a0d6e106cc4fcdc7bbc ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/256936 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263024

## 8. API documentation

- **REST page template.** Description metadata starts "REST API to"; the intro "Use this API to"; operation titles use List all, Retrieve, Create, Update, Delete. Each operation: attribute table, then the success line below (with the right code and relative path), response attribute table, example request, example response (documented).

  ```markdown
  If successful, returns [`200 OK`](rest/troubleshooting.md#status-codes) and the following response attributes:
  ```
- **Attribute tables:** path attributes first, then required, then the rest alphabetically; no description starting with "The"; tier or version notes in the description column. Response tables alphabetical, with dot notation for nested keys. A status code table follows the attributes (documented).
- **curl examples:** long options only, `--request <METHOD>` first even for GET, `--header "PRIVATE-TOKEN: <your_access_token>"`, `--url "https://gitlab.example.com/api/v4/..."` in double quotes, long commands broken with a trailing backslash. `lint-doc.sh` fails on short options; the order rules are checked by reviewers (enforced; documented).
- **Generated OpenAPI.** If you change a Grape endpoint's `desc`, `detail`, params, success or failure entities, regenerate with `mise exec ruby@3.3.11 -- bin/rake gitlab:openapi:v3:generate` (the prefix and why: references/projects/gitlab-org__gitlab.md, Test environment), commit the YAML in the same MR, and check with `mise exec ruby@3.3.11 -- bundle exec rake gitlab:openapi:v3:check_docs`. Both tasks run only in the development or test environment and rerun themselves with `GITLAB_SIMULATE_SAAS` (from `OPENAPI_SIMULATE_SAAS`, default `false`) and a fixed `GITLAB_CONFIG`. When the check fails, `OPENAPI_CHECK_DEBUG=true` makes it write `doc/api/openapi/openapi_v3.yaml.generated` and print the diff; do not commit that file. After editing a tag page under `tooling/docs/api/tags/`, run `mise exec ruby@3.3.11 -- bin/rake gitlab:openapi:v3:validate_tag_docs`, which the EE static analysis also runs. If the YAML changes on the default branch while your MR is open, rebase and regenerate rather than resolving the conflict by hand (enforced; observed, 2). Only the v3 document is regenerated this way.
- **Pages moving to OpenAPI.** Most REST reference pages are being replaced by the generated spec; ask before expanding one, since reviewers asked contributors to hold off (observed, 2).
- **GraphQL.** After changing a type, field, argument or description, run `mise exec ruby@3.3.11 -- bundle exec rake gitlab:graphql:update_all`, which runs `docs:compile` (`compile_docs`, its former name, is deprecated), `schema:dump` and `generate_all_introspection_schemas`, and commit what it changes under `doc/api/graphql/reference/`, which holds one page for each kind of schema item, and `public/-/graphql/`. Never edit the generated reference by hand. The `graphql-verify` job also validates every frontend query and the frontend's list of possible types; references/projects/gitlab-org__gitlab.md, Generated artifacts, lists its steps (enforced).

Sources: gitlab-org/gitlab:doc/development/documentation/restful_api_styleguide.md@6c57ec5a1cde2111bce484d5e9a926e88c42ac4e ;
gitlab-org/gitlab:doc/development/documentation/graphql_styleguide.md@b620a799b9273ce8bf97a8154022a06b3e5e9f8d ;
gitlab-org/gitlab:scripts/lint-doc.sh@19f194a7cf99ddb68d3e48aaaa5a0a92ee733724 ;
gitlab-org/gitlab:lefthook.yml@43ecb41ea18fda993c19544a7e59b43657c7994f ;
gitlab-org/gitlab:doc/development/rake_tasks.md@43ecb41ea18fda993c19544a7e59b43657c7994f ;
gitlab-org/gitlab:lib/tasks/gitlab/graphql.rake@43ecb41ea18fda993c19544a7e59b43657c7994f ;
gitlab-org/gitlab:.gitlab/ci/graphql.gitlab-ci.yml@43ecb41ea18fda993c19544a7e59b43657c7994f ;
gitlab-org/gitlab:lib/tasks/gitlab/openapi/v3.rake@32dbc8ec0d8b4a5cf79606eea27c7937ff325a4c ;
gitlab-org/gitlab:lib/tasks/gitlab/openapi/pinned_environment.rb@32dbc8ec0d8b4a5cf79606eea27c7937ff325a4c ;
gitlab-org/gitlab:scripts/static-analysis@d0dcbad35157d2814d0183b785539987cdfb1d90 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/255702 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/259766 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261534

## 9. Answering docs review

- **Read suggestions together before applying a batch.** Overlapping suggestions make each other outdated, and a batch can orphan a footnote label (MD053) or drop the blank line around a list, code block or heading (MD031, MD022). After applying, pull and run markdownlint before resolving threads (observed, 2).
- **A suggestion whose opening suggestion fence is not on its own line** cannot be applied from the UI; make the change in a commit and reply with it (observed, 1).
- **When a suggestion conflicts with the word list or the API template**, reply with a link to the rule and keep the documented form unless the reviewer confirms otherwise (observed, 3).
- **Duo comments** follow `.gitlab/duo/mr-review-instructions.yaml`; check each against the style guide and reply in its thread. It often flags duplicate links and API template deviations (observed).
- **After auto-merge is set, do not push** unless asked; a push stops the merge and removes the approvals of the code owners whose files it changed, the technical writer's included when it changes their pages (observed, 8). The "reset approvals" system note names the approvers to re-request and ask to approve again; references/projects/gitlab-org__gitlab.md, CI on the fork and how merging works, has the detail.
- **After merge,** check the page on docs.gitlab.com once rebuilt and open a follow-up for anything that renders wrong (observed, 2).

Sources: gitlab-org/gitlab:.gitlab/duo/mr-review-instructions.yaml@c527da35c5153e13d7e1eb62f0d01519b9590ac8 ;
gitlab-org/gitlab:doc/user/project/merge_requests/approvals/settings.md@2ac227a86477a009d63100482dc997bbc832cbb2 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/256936#note_4065608860 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/254543 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/259764 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/255704 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/254699 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260930
