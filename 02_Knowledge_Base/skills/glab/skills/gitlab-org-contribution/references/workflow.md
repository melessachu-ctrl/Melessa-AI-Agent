# Workflow: from finding an issue to after the merge

This is the end-to-end path for a first-time contributor to a GitLab-owned
project. Each step says what to do, why, and how it is known (enforced,
documented, observed with a count). Project differences live in
references/projects/INDEX.md; read the file for your project alongside this one.

## Contents

- [1. Accounts and access (once)](#1-accounts-and-access-once)
- [2. Find work](#2-find-work)
- [3. Check the issue before writing code](#3-check-the-issue-before-writing-code)
- [4. Creating an issue](#4-creating-an-issue)
- [5. Assign yourself through the contributor platform (browser)](#5-assign-yourself-through-the-contributor-platform-browser)
- [6. Fork and branch](#6-fork-and-branch)
- [7. Read the project's rules](#7-read-the-projects-rules)
- [8. Implement](#8-implement)
- [9. Commit, push and open the MR](#9-commit-push-and-open-the-mr)
- [10. What happens automatically after you open it](#10-what-happens-automatically-after-you-open-it)
- [11. Pipeline](#11-pipeline)
- [12. Request review and answer it](#12-request-review-and-answer-it)
- [13. Approval and merge](#13-approval-and-merge)
- [14. After the merge](#14-after-the-merge)
- [15. If you cannot finish](#15-if-you-cannot-finish)

## 1. Accounts and access (once)

- **Start onboarding at https://contributors.gitlab.com/start (browser).** Within minutes an onboarding issue opens in `gitlab-community/community-members/onboarding`; its label tracks the request (`access-request::pending`, then `awaiting-information`, `approved` or `closed`). A public profile with a short bio and links speeds the review. Approval gives Developer access to every community fork and makes you a community member for the platform's manage pages (documented).
- **Approved members get GitLab Duo inside the forks**, capped at 500 GitLab Credits per member per month, reset on the 1st. It is meant for contributing to projects that have a community fork, not for personal or bulk agentic work; misuse can lower the cap or remove access. To raise the cap for an in-progress contribution, comment on your onboarding issue and link the work (documented).
- **If you will use a personal fork**, gitlab.com may ask new accounts for identity verification before shared runners run jobs, and your own CI minutes and 10 GiB namespace storage apply (observed, 1 and 6).
- **Security problems are not public issues.** gitlab-org/gitlab's CONTRIBUTING.md points to https://about.gitlab.com/security/disclosure/ for vulnerability disclosure (documented). The same holds when a vulnerability turns up while you work on something else (an authorization gap, data another role should not see): do not describe the unpatched behaviour in a public issue, MR description, commit message, test name or review reply, and report it through GitLab's HackerOne program first. That program asks for reproduction evidence (screenshots, video or logs) against a GitLab instance you run yourself, and does not accept reports that rest on static code analysis alone (documented, https://hackerone.com/gitlab).
- **Know what you agree to by submitting.** A project's CONTRIBUTING.md states its terms, usually first: 27 of the 38 CONTRIBUTING files pinned in `sources.json` (references/projects/INDEX.md) carry a Developer Certificate of Origin notice (documented, 27 projects; recounted 2026-10-22). Do not edit that legal text, not even for style; an MR that did was closed (observed, 1). In gitlab-org/gitlab, code you submit outside the `/ee` directory comes under the Developer Certificate of Origin; code you submit to `/ee` comes under the Individual Contributor License Agreement, or the Corporate one when you contribute on behalf of an employer; documentation under `doc/` is licensed CC BY-SA 4.0 (documented). GitLab's DCO and CLA page, https://about.gitlab.com/community/contribute/dco-cla/, explains both.
- **Sign off commits where the project shows it.** gitaly, container-registry, the dependency-scanning analyzer and cells/http-router show `Signed-off-by:` in their commit message examples; add it with `git commit -s` there and wherever a project's CONTRIBUTING.md or examples ask for it (documented, 4 projects).
- **Signing off is not signing.** `Signed-off-by:` is a text trailer. A GPG, SSH or X.509 signature on your commits is not needed for them to merge: the "Reject unsigned commits" push rule checks `git push` only, not the commits a merge made in GitLab brings in, and community MRs with unsigned commits merge normally (documented; enforced; observed, 12 of 15 merged community MRs had unsigned commits). Where squash is on, the commit that lands is usually one GitLab writes, and signs where the project signs web commits (references/commits-and-descriptions.md, Squash, fixup and suggestion commits).
- **Tick the AI checkbox when AI helped.** Several MR templates open with "Please check this box if this contribution uses AI-generated content ... as outlined in the GitLab DCO & CLA" (documented; observed in the container-registry and gitlab-qa templates). None of the 518 closed community MRs read for this skill was closed for a missing sign-off, DCO or CLA (observed, 0 of 518).

Sources: gitlab-community/meta:README.md@6f1c3fd623d90bdafdec81d8fd0977bf2dd03947 ;
gitlab-org/gitaly:CONTRIBUTING.md@7baaf84d91d96f198bb7b883b2b63b8a9072e1cb ;
gitlab-org/container-registry:CONTRIBUTING.md@67a07eb14957e9f38de6a0c09f3eb02c821cf4eb ;
gitlab-org/security-products/analyzers/dependency-scanning:CONTRIBUTING.md@55185c7e8a196aa1b76a95ce7b22017d609b8329 ;
gitlab-org/cells/http-router:CONTRIBUTING.md@f9a43adcbc98cceb12488b6f11cea288f738a647 ;
gitlab-org/gitlab:doc/user/project/repository/push_rules.md@09ba600438db35dc76c8050b4788ece126ea8ee9 ;
gitlab-org/gitlab:ee/lib/ee/gitlab/checks/push_rules/commit_check.rb@2b6fdcbf124696e75252e941350df9a5803eb02f ;
https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5449 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7674 ;
https://about.gitlab.com/community/contribute/dco-cla/ ;
https://gitlab.com/gitlab-org/container-registry/-/merge_requests/2560 ;
https://gitlab.com/gitlab-org/gitlab-qa/-/merge_requests/1324 ;
https://gitlab.com/gitlab-org/gitlab-qa/-/merge_requests/553 ;
gitlab-community/meta:docs/duo-usage-guidelines.md@6f1c3fd623d90bdafdec81d8fd0977bf2dd03947 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/concerns/manageable_concern.rb@f39cc821eff099faecf62980cc9ab44d9cd272a4 ;
gitlab-org/gitlab:CONTRIBUTING.md@334527f887d3b1bed8b86da976cb71a1d23dea50 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7501

## 2. Find work

- **Use the contributor platform's issue finder or the project's labels.** `quick win` issues are open to everyone; `quick win::first-time contributor` issues are reserved for people with no merged MR in any GitLab project, and a bot manages that label (enforced). `Seeking community contributions` marks work the team wants help with (documented).
- **For documentation in gitlab-org/gitlab**, the documentation issue list filtered by `documentation`, `docs-only` and `quick win` is the documented starting point; some docs issues accept several contributors (for example one file each), so read the issue description (documented). See references/docs-style.md.
- **Do not open test MRs, placeholder drafts or MRs from automation buttons you do not understand** (such as "Fix failing pipeline") in a canonical project: they are closed as noise (observed, 44 accidental or test MRs, 17 empty).

Sources: gitlab-org/quality/triage-ops:triage/processor/quick_win_first_time_contributor_label.rb@1814ceb7df50f9a2a67ae3b62ecd47aa343c1485 ;
gitlab-org/gitlab:doc/development/contributing/merge_request_workflow.md@c7c8aec10c3f129e5ef2adf4250f9406b2b4b931 ;
gitlab-org/gitlab:doc/development/documentation/_index.md@a45ac1f25e1087de2d934c1329ee44a57451ac3e ;
https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/368 ;
https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1042

## 3. Check the issue before writing code

Do all of these; each one prevents a common close (see references/why-mrs-get-closed.md):

1. **The project still takes contributions.** Read the project description (a "(Deprecated" prefix), the README's banner ("maintenance mode", "does not accept new features") and the maintainers' latest notes on recently closed community MRs. A deprecated GitLab project closed even small maintenance MRs, the latest with "We are not taking any contributions at the moment" and a pointer to its replacement; send the change to the replacement, or ask in an issue first (documented; observed, 3). A single feature can be on its way out too: search the area's open issues labelled `maintenance::removal`, and when one covers the feature you would fix, ask in the bug issue whether the fix is still wanted before you build it (observed, 1: gitlab-org/gitlab#592637, an open issue to remove OKRs); item 9 says whom to ask.
2. **Assignee and linked MRs.** If someone is assigned or already has an MR, pick another issue or offer help on theirs. 41 MRs were closed as duplicates; in two cases two contributors had self-assigned the same issue and the maintainer kept the MR with better coverage, not the first (observed, 41).
3. **Search open MRs and issues** for the issue number, the file, the route or the behaviour, from any author, including team members (observed, 41). Search for the class or module name too: an open MR that moves or renames the file you change is no duplicate, but whichever MR merges second has to carry the other's change across (observed, 1: gitlab-org/gitlab!263936, which moves `Gitlab::UntrustedRegexp` into the `gitlab-utils` gem). Search closed issues as well: in gitlab-org projects gitlab-bot marks a bug with no human activity for a year `vintage` and `stale`, warns, and a week later closes it with `auto closed`, so a report of your bug can be closed while the bug is still there. Comment on it with what you reproduced on the default branch, and ask its author, whom the bot asked to reopen it, or a team member to reopen it, since reopening someone else's issue takes a role (enforced; documented; observed, 1: gitlab-org/gitlab#454471). Through the API, an error is not an empty result: a search of gitlab-org/gitlab's merge requests without `state`, or with `state=all`, can answer `Request timed out`, and a group-wide `GET /groups/gitlab-org/issues?search=...` answered `500 Internal Server Error` even narrowed to titles and dates (checked 2026-10-22), while the same searches answered per project with `state` set (and `created_after` to narrow further), or through the search API, `GET /groups/:id/search?scope=issues` or `scope=merge_requests`. Split a search that fails that way instead of reading it as "nothing found" (the search API is documented; observed). A `message` key read as an error, or an error body without one, mislead a script too; a repository tree or file `404` for a path is not a failed read: the path, or the ref, does not exist, and the message says which (references/troubleshooting.md, MR mechanics). Repeat the search right before you open the MR (section 9), for related issues as well as duplicates; how to cite a related issue is in references/commits-and-descriptions.md, Linking the issue.
4. **Read the issue's related merge requests by state.** `GET /projects/:id/issues/:iid/related_merge_requests` lists every MR the issue references in its description or any note, the "mentioned in merge request" system note an MR's mention leaves included, plus the MRs linked to it as related, whatever their state, so a merged MR the description cites (the one that introduced the bug, say) sits beside an open fix: read each entry's `state` and whether it fixes this issue rather than counting entries, and read every page (20 per page by default, `per_page` up to 100). Citing the MR that introduced the bug stays useful, since the Bug template's Possible fixes asks for the code that might be responsible; just do not read it back as a competing MR (enforced; documented; observed, 2: gitlab-org/gitlab#636028 and gitlab-org/cli#8684).
5. **Read the whole issue thread**, including the latest notes. Decisions such as "wait until X changes" or "the fix belongs in the backend" are often already there (observed; see references/why-mrs-get-closed.md, section 5).
6. **Check labels** such as `workflow::blocked` or a pending product decision (documented in the cli, VS Code and language server CONTRIBUTING files).
7. **Reproduce on the latest default branch** and confirm no existing setting or feature already solves it (observed, 25).
8. **Agree the approach for anything beyond a clear bug fix**: a feature, a behaviour change, a new setting, new API surface, a changed default or a public contract. Propose additive or opt-in designs; changing an existing contract needs a migration or deprecation path (documented in the GitLab contribution workflow and API style guide; observed, 76 closes about what to build, counted in references/why-mrs-get-closed.md, section 5). Agreeing first stays the rule (SKILL.md, non-negotiable 3). Sending the code before the maintainers answered the "which option do you prefer" you asked in the issue suits only a small change for an issue that already sets out the options, small enough to redo for another one; if you do, say so in one sentence of the description: what you asked, why you send the code anyway, and that you will rework it for another option (observed, 1: gitlab-org/cluster-integration/gitlab-agent!4756, for #1240, approved with "I think this is the right approach" and merged the same day).
9. **Ask the person the issue names.** Before you mention someone with a question in an issue, such as which option they prefer (item 8) or whether a fix is still wanted (item 1), read whom the issue already asked to decide and ask them in that thread; read the person's status (`GET /users/:id_or_username/status`, which needs no token) and their job title, which `GET /users/:id` gives as `job_title` (with a token; it answers 403 without one) and the roulette data gives as `role` (references/review.md, section 4), so that you do not ping an engineer for a product decision. The roulette data does not list every team member, so read `job_title` when it has no entry (documented; observed: the roulette data read 2026-10-26, and 1 issue, whose first note, gitlab-org/gitlab#592637, puts its decision questions to the group's engineering manager and product manager).
10. **Get the issue validated if unsure.** `@gitlab-bot help` on an issue pings a merge request coach (enforced, in any project gitlab-bot serves; once per hour). It posts only "could you please help" and adds no label; validation itself is a human decision, so say in the same comment what you want checked.

Sources: gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/public/docs/hackathon-rules.md@eddd645fba2ffe5a47bc2b4655ab5cbd31ea4554 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_issue_help.rb@f818e73ade381f5ea933b63f20f7c81c1aefba96 ;
gitlab-org/gitlab:doc/development/contributing/_index.md@c0ef4bfa1583bb8327ebf4de247541a4f513681a ;
gitlab-org/gitlab:doc/development/contributing/issue_workflow.md@fe61c2a15cf1eab3abf1d4210827e859a03af7b4 ;
gitlab-org/gitlab:doc/api/search.md@1802481cbb21dde958cefe4239254e2bcca0017a ;
gitlab-org/quality/triage-ops:policies/stages/hygiene/close-stale-bugs.yml@e848bbca722eb7a728940dfea48f6a3f1cd97a78 ;
gitlab-org/gitlab:doc/user/project/issues/managing_issues.md@e3e279695f8b03b7572dd17f8ee1758ded425e77 ;
https://gitlab.com/gitlab-org/gitlab/-/issues/454471 ;
https://gitlab.com/gitlab-org/gitlab/-/issues/592637 ;
https://gitlab.com/gitlab-org/gitlab/-/issues/592637#note_3139434884 ;
gitlab-org/gitlab:doc/api/users.md@037fd3dec6a6786bf5f9b651cf4f1db70b7a094e ;
https://gitlab-org.gitlab.io/gitlab-roulette/roulette.json ;
gitlab-org/gitlab:app/services/issues/referenced_merge_requests_service.rb@18aba84b361aafd9f7be4dcd6bb41dd12d1fcea6 ;
gitlab-org/gitlab:lib/api/issues.rb@c16019c127650c354f22b85712169c4a00bf40c5 ;
gitlab-org/gitlab:doc/api/issues.md@1dac7787f799a993ad33a88badd54e4c1096e000 ;
gitlab-org/gitlab:doc/api/rest/_index.md@e86ce5ee4db419c362c95799cd2a33691d6246c0 ;
gitlab-org/gitlab:.gitlab/issue_templates/Bug.md@f9a343bd004bb3ed53458ca9bbbc11eb7041e65f ;
https://gitlab.com/gitlab-org/gitlab/-/issues/636028 ;
https://gitlab.com/gitlab-org/cli/-/issues/8684 ;
https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/issues/1240 ;
https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/merge_requests/4756#note_4085258202 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263936 ;
gitlab-org/cli:CONTRIBUTING.md@5686d7484e65cb08b6e3b92f86d2ccffb415bdc0 ;
gitlab-org/release-cli:README.md@4a842a47f16977e3a9de13b43f82bde4b53344d1 ;
https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9900 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/255239 ;
https://gitlab.com/gitlab-org/release-cli/-/merge_requests/201 ;
https://gitlab.com/gitlab-org/release-cli/-/merge_requests/182 ;
https://gitlab.com/gitlab-org/release-cli/-/merge_requests/173

## 4. Creating an issue

- **Search for an existing issue first**, then use the project's issue template, and read the issue rules in the project's file under references/projects/ (for gitlab-org/gitlab, Reporting bugs). Leave milestone and assignee fields alone; only members can set them, and a contributor's sidebar edits through the API are dropped silently (observed, 1).
- **Read the settings issue template before you write.** Read `issues_template` from `GET /projects/<url-encoded path>` with any account's token (section 7). When it is set, GitLab puts it into every new issue: the web form pre-fills it, and an issue created through the API or glab gets it in front of the description you send. So send only your filled-in sections, then edit out the settings template GitLab put in front of them, but not gitlab-bot's IssueSummary block (next bullet) (enforced; observed, 1). When it only asks you to pick a template, as in gitlab-org/cli, use the named one from `.gitlab/issue_templates/`. Without a settings template, an issue created with no description gets the repository `Default.md` (enforced). Either template's `/label` lines do nothing for a contributor without a role; use `@gitlab-bot label` (observed, 1).
- **Leave gitlab-bot's IssueSummary block** at the top of the description; it is not yours to remove. In gitlab-org/gitlab, gitlab-org/api/client-go, the Terraform provider, three gitlab-o11y projects and the contributor platform's project, gitlab-bot rewrites a public, open issue's description on each event so that it starts with a block between `<!--IssueSummary start-->` and `<!--IssueSummary end-->`: a collapsed "Everyone can contribute. Help move this issue forward ..." with contributor platform links ("Label this issue" until a type and a group label are set, "Work on this issue" on a curated issue, "Close this issue" once the issue is over seven days old and unassigned). It edits again whenever that list changes, and when nothing is left it removes the block and leaves the description starting with blank lines; a confidential or closed issue gets none, and a description with a quick action line is left alone. The first edit came one or two seconds after creation, the next a second after the platform's assignment. A read-back that compares the description you sent strips the block and the leading blank lines first. gitlab-org/cli and gitlab-org/gitlab-runner issues do not get it (enforced; observed, 2: gitlab-org/gitlab#635968, notes 4082494156 and 4082607899, and #636028).
- **Expect automation on new issues**: a triage policy may add labels later, and a quick win labeller may comment that it "Could not start processing", which only means no quick win label will be added automatically (observed, 1). The quick win judge does not judge an issue you open: it reads only unassigned, non-confidential issues whose author is a GitLab team member (enforced). On such an issue, which you may take later, gitlab-bot comments that "our AI believes this is N% likely to be a quick win", adds `quick win` with `automation:quick-win` and `automation:quick-win-judged`, and asks the issue's author to remove the label if it is wrong (enforced; observed, 3). `quick win` is not on `@gitlab-bot unlabel`'s list, so if it is wrong say in the issue why and leave the removal to a member (enforced; references/review.md, section 6). Correct other labels with `@gitlab-bot label` or the platform's manage-issue page.
- **For a docs issue in gitlab-org/gitlab**, use the Documentation template and start the title with `Docs:` or `Docs feedback:` (documented).
- **If someone calls your issue a duplicate**, first check that it is the same problem. A "Duplicate of <link>" note marks nothing and the issue stays open: only the `/duplicate` quick action marks a duplicate, and it needs a role in the project (enforced). If it is the same, point your MR's `Closes` line at the original (`Related to` when the original is broader), then close your issue, as its author or with the Duplicate reason on the platform's manage-issue page, which also marks it as a duplicate (enforced; references/hackathon-and-platform.md, section 3). If the link answers 404 for you, ask in the thread instead (references/troubleshooting.md, MR mechanics).
- **If you intend to work on it, assign yourself immediately** through the platform (next step).

Sources: gitlab-org/gitlab:doc/development/documentation/workflow.md@c482442667336a6d129cf6806bed323f5cb60124 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_label.rb@46a4823632f3401513d233b99137d836d520e2ad ;
gitlab-org/gitlab:app/services/issues/create_service.rb@902c553b0e45d6b643a7a5702498e89b212c6e7d ;
gitlab-org/gitlab:ee/app/services/ee/issues/build_service.rb@12063ef74238e6a0b993122b339a9dcdf599da1e ;
gitlab-org/gitlab:lib/api/issues.rb@c16019c127650c354f22b85712169c4a00bf40c5 ;
gitlab-org/gitlab:doc/user/project/description_templates.md@5c0f47b000524aaca72f3259a95007ccb789eecf ;
https://gitlab.com/gitlab-org/cli/-/issues/7898 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/257229 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/issues/2856#note_3692432349 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/issues/3282 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/issues/3212 ;
gitlab-org/gitlab:lib/gitlab/quick_actions/issue_actions.rb@f2e6534e7b0e7e266feb0bbe37f02d6b4a30dedd ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_issue_controller.rb@f39cc821eff099faecf62980cc9ab44d9cd272a4 ;
gitlab-org/quality/triage-ops:triage/processor/issue_summary.rb@d64ea40406b87e62e8125fbbf464d624e7be4482 ;
gitlab-org/quality/triage-ops:lib/untriaged_helper.rb@53f716ba08df079938bad29e6cfb865984b7b693 ;
https://gitlab.com/gitlab-org/gitlab/-/issues/635968#note_4082494156 ;
https://gitlab.com/gitlab-org/gitlab/-/issues/635968#note_4082607899 ;
https://gitlab.com/gitlab-org/gitlab/-/issues/636028 ;
https://gitlab.com/gitlab-org/api/client-go/-/issues/2335 ;
gitlab-org/quality/triage-ops:lib/quick_win_judge_helper.rb@7e375e7f86b1368f88783040ed0eb57302718150

## 5. Assign yourself through the contributor platform (browser)

Community contributors usually have no role that makes `/assign` or the API
work. Use the platform's manage-issue page, which posts the assignment through
its own account. It needs the person signed in to contributors.gitlab.com in a
browser; an agent gives the person the link below and waits for confirmation:

```text
https://contributors.gitlab.com/manage-issue?projectPath=<group/project>&issueIid=<iid>&action=work
```

- `projectId=<numeric project id>` can replace `projectPath` (the platform's own notes use `projectId`), and the page also accepts a pasted issue URL in the `/-/issues/` or `/-/work_items/` form (enforced).
- In the corpus it assigned 16 issues across 9 projects in gitlab-org and components (observed, 16).
- The thread it posts thanks you, runs `/assign @you`, and asks the issue's author, assignees and, where the issue names them, its product and engineering managers (or a random available coach when there is nobody) to confirm the issue is ready (enforced). Answer any question they post there.
- Which namespaces the page accepts, who may use it, how many issues you can hold and which issues it refuses are in references/hackathon-and-platform.md, section 3; if the Assign button is missing, see references/troubleshooting.md, Contributor platform.
- Unassign from the same page when you stop, so others can pick it up (enforced).
- During a hackathon, opening an MR for an issue you are not assigned to breaks the rules (documented). Outside hackathons, an MR for an issue assigned to someone else is usually closed as a duplicate (observed, 9).

Sources: gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_issue_controller.rb@f39cc821eff099faecf62980cc9ab44d9cd272a4 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/common/IssueUrlRegexUtils.js@e149e13f1d1ce4a83029d2dd9f1d1d738b8b8825 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/common/Constants.js@d2b6b66020a4e1521027d251d864d810108f1497 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/pages/manage-issue-page/WorkAction.vue@fd4fd9323a309be5acae7cf5b29167164f46753f ;
https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/40102 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7612

## 6. Fork and branch

- **Check for a community fork** at `https://gitlab.com/gitlab-community/<full project path>`; projects with one show a community fork badge in the sidebar. A few forks use a different path, so confirm it from the project's Forks list or gitlab-bot's welcome note (documented; observed).
- **Prefer the community fork.** It runs pipelines on GitLab's open source quota with the runners and settings the project expects, Danger runs without your own tokens where the project runs it in forks at all (references/bots.md, section 2), and team members can push to your branch. Personal-fork MRs ran out of minutes or storage, lacked runners, the dependency proxy or tokens, and 34 were closed and reopened from the community fork (documented; observed, 34).
- **No fork yet?** Open an issue in gitlab-community/meta with the `Fork request` template (title `<project> fork request`, a link to the source project). A team member adds the project to the fork configuration and a pipeline creates the fork after that MR merges. Until then use a personal fork, say so in the MR description, and expect jobs that need project runners, secrets or tags to fail or hang (documented). See references/troubleshooting.md.
- **Branch from the canonical default branch, prefixed with your username** (for example `<username>-fix-board-list`). The forks are shared: members have Developer access to every branch, so the prefix keeps branches apart, and you work on someone else's branch only with their permission (documented).
- **Never commit to the fork's default branch.** It is protected and mirrored; the mirror never overwrites a diverged branch. Add the canonical project as a remote and rebase on its default branch when you need the latest code (enforced).
- **For a personal fork**, push to a topic branch, keep CI/CD enabled, and make pipelines visible to reviewers; MRs from a personal fork's default branch or with CI disabled had no pipeline at all (observed, 3).

The mechanics, for a project whose canonical path is `<group>/<project>` and
whose default branch is `<default>` (read it from the project page or the
`default_branch` field of `GET /projects/<url-encoded path>`):

```shell
git clone https://gitlab.com/gitlab-community/<group>/<project>.git
cd <project>
git remote add upstream https://gitlab.com/<group>/<project>.git
git fetch upstream
git switch -c <username>-<topic> upstream/<default>
# ... commit ...
git push -u origin <username>-<topic>
```

Later, to catch up with the default branch, `git fetch upstream` and
`git rebase upstream/<default>`, then `git push --force-with-lease`. A fetch
from gitlab-org/gitlab that answers "GitLab is currently unable to handle
this request due to load" was refused because it was anonymous: send
credentials with it, or fetch the branch from the fork, and retry with a
pause (references/troubleshooting.md, MR mechanics).

If you cloned the canonical project instead, or a shallow copy of it, and
added the fork as a remote named `fork`, fetch the fork's default branch
before the first push (`git fetch fork <default>`). By default git finds the
commits the
remote already has only among those its branches point to, and leaves them
out of the push only when your clone has them too; a clone that has none of
them can send the whole history behind your branch, which in a large project
such as gitlab-org/gitlab is a very long push.
`git rev-list --count <your branch> --not --remotes=fork` shows about how
many commits the push would send, and `git -c push.negotiate=true push ...`
makes git negotiate the commits in common with the remote instead
(documented,
https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushnegotiate).

Sources: gitlab-community/meta:README.md@6f1c3fd623d90bdafdec81d8fd0977bf2dd03947 ;
gitlab-community/meta:.gitlab/issue_templates/Fork request.md@5acb52047cd8db3d210c3952196111427d5c1e6b ;
gitlab-community/meta:tofu/modules/fork_project/main.tf@5953f1e608847ffd43daa755574c93167cc7fa0c ;
gitlab-org/gitlab:doc/development/contributing/_index.md@c0ef4bfa1583bb8327ebf4de247541a4f513681a ;
https://gitlab.com/components/opentofu/-/merge_requests/541 ;
https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/66 ;
https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushnegotiate

## 7. Read the project's rules

Before writing code, read, in this order:

1. **AGENTS.md**, where it exists. In many projects it is the most current statement of local commands, generated files and review expectations; in some, CONTRIBUTING.md is an older copy (documented in 14 of 15 projects of one cluster).
2. **CONTRIBUTING.md** and the docs it links (in gitlab-org/gitlab, `doc/development/contributing/`).
3. **The MR and issue templates** under `.gitlab/merge_request_templates/` and `.gitlab/issue_templates/`. A project can also set its default MR and issue descriptions in project settings, and a settings template takes priority over a `Default.md` file (documented). GitLab pre-fills it in every new MR made with the web form, from a fork too, and puts it into every new issue (section 4); read it from the `merge_requests_template` and `issues_template` fields of `GET /projects/<url-encoded path>` with any account's token, no role needed (an anonymous call leaves both fields out; checked 2026-10-22). Of the 60 projects the skill covers, read on 2026-10-22, 11 set a settings MR template (components/opentofu and gitlab-org/cluster-integration/gitlab-agent, where it overrides the repository's `default.md`, gitlab-org/omnibus-gitlab, where it is an older copy of `Default.md`, gitlab-org/ci-cd/custom-executor-drivers/fargate, gitlab-org/ci-cd/docker-machine, gitlab-org/professional-services-automation/tools/migration/congregate, gitlab-org/release-cli, gitlab-org/security-products/analyzers/report, gitlab-org/ruby/gems/gitlab-dangerfiles, gitlab-org/ruby/gems/semver_dialects and gitlab-community/meta) and nine a settings issue template (components/opentofu, gitlab-org/gitlab-pages, gitlab-org/charts/gitlab, gitlab-org/cli, gitlab-org/cluster-integration/gitlab-agent, gitlab-org/container-registry, congregate, gitlab-org/release-cli and gitlab-org/security-products/gemnasium-db). Keep its sections in your description; its `/label` lines do nothing for a contributor without a role (documented; observed in the projects API, 60 projects).
4. **`.gitlab/duo/mr-review-instructions.yaml`**: the checklist GitLab Duo reviews against. Meeting it before review saves a round of Duo comments (documented; present in at least 23 gitlab-org projects).
5. **The Dangerfile and `danger/` directory**, and **lefthook or pre-commit config**, which tell you the checks CI will run.
6. **Docs lint configuration** (`.markdownlint-cli2.yaml`, `.vale.ini`) if you touch docs.

Through the API, a `404` for a path on a ref that exists means the project
does not have it there (the repository tree's `invalid revision or path`, the
files API's `File Not Found`): read it as "not on that ref", not as a failed
read. A `404` for the ref itself (`Tree Not Found`, `Commit Not Found`) means
the ref is wrong (references/troubleshooting.md, MR mechanics).

Then open the project's file in references/projects/INDEX.md.

Sources: gitlab-org/ruby/gems/gitlab-exporter:AGENTS.md@62eec5a02ef1ba1d70b754eda42165433af4f1ef ;
gitlab-org/gitlab:doc/user/duo_agent_platform/customize/review_instructions.md@a34ca4afdb8fc93cbbf304cc89a7c2ca98c133aa ;
gitlab-org/gitlab:.gitlab/duo/mr-review-instructions.yaml@c527da35c5153e13d7e1eb62f0d01519b9590ac8 ;
gitlab-org/gitlab:doc/user/project/description_templates.md@5c0f47b000524aaca72f3259a95007ccb789eecf ;
gitlab-org/omnibus-gitlab:.gitlab/merge_request_templates/Default.md@9c46e0db717676530c4bb48ea7847901bfb300d2

## 8. Implement

- **Set up the environment the project's CI uses first**: the tool versions its jobs run, which can differ from the pin files, dependencies installed the way CI installs them, and the services its test jobs start. references/local-environment.md says where to read each and links each project file's local checks (enforced; documented).
- **Write the failing test first**, at the lowest level that exercises the behaviour, and confirm it fails without your change. Reviewers check this by removing the fix and rerunning your tests; tests that pass either way, that assert loosely, or that stub out the code under change are sent back (observed, 8 runner-family MRs; documented in gitlab-org/gitlab and several CONTRIBUTING files). Reviewers elsewhere asked the same: for a test that also fails on the old code, for an assertion that would catch the regression, about stubs that no longer carry any weight, and for a failing test before accepting a fix justified by a specification; one review reported running the new tests on the default branch and mutating each new guard (observed, 5 MRs in 5 other projects). Say in the description which cases fail without the change, and drop stubs and cases that pass either way. Where the code can fall back to another path that also gives the right result, a test that checks only the result passes on the fallback too, so assert which path ran as well, for example by counting the requests it makes (observed, 1: on gitlab-org/gitlab-runner!7676 a reviewer pointed out that a method removed from a wrapper would send the download down its single-stream fallback without any test noticing, note 4077382363).
- **Make the red run fail on behaviour, not on the build.** When the new test needs something only the fix adds, make the red run compile without the fix's behaviour: add the new parameter and pass it through unused, or run the test on the default branch with only the line it cannot have removed. A behavioural failure shows the test catches the bug; a build error does not. Say exactly what the red run left out (observed, 2 MRs in 2 projects: gitlab-org/gitlab-runner!7706, "With the flag passed through but not applied, the 7 `refusedWhenAnchored` cases fail", and gitlab-org/cluster-integration/gitlab-agent!4756, run on master "minus the `gitLabRelativeURLRoot` field master does not have", merged after approval). Make the red run without changing your working tree (references/local-environment.md, section 3).
- **Prove the code you change runs in production**: find its callers outside tests. A fix to an adapter with no production caller was closed as a no-op (observed, 1).
- **Keep the change to the issue.** No unrelated refactors, formatting churn, dependency bumps or CI changes; leave version bumps to the project's dependency bot unless an issue asks (observed, 5 closes for manual bumps).
- **Run the project's local checks** before every push: formatters, linters, tests, the commit message linter (`bundle exec rake danger_local` where gitlab-dangerfiles exposes it, `scripts/lint/commit_linter.rb` in gitlab-org/gitlab, run with the Ruby and base that references/projects/gitlab-org__gitlab.md, Commits and title, gives), docs lint, and regeneration of committed generated files. Installing the project's lefthook hooks runs most of them on push (documented), but several hooks print a warning and pass when their tool is missing, so install the pinned tools first and read the hook output (enforced; references/local-environment.md, section 4).
- **When a job cannot run in your fork**, run its commands locally, in the job's own image where the check depends on tool versions, and post the commands, the image and the results in the MR (observed, 3; references/local-environment.md, section 3).
- **Never commit credentials, connection strings, personal configuration, state or lock files.** If it happens, revoke the secret at once: closing the MR does not remove it (observed, 3).
- **Commit with an author name and email that identify you**, not a shared machine or employer default (observed, 1).
- **AI assistance:** review and test everything yourself, check every claim, command and file name, trim redundant generated comments and tests, and say that AI helped where the template or project asks (documented in the hackathon rules, the Environment Toolkit CONTRIBUTING and the GitLab docs style guide).

Sources: gitlab-org/gitlab:doc/development/contributing/merge_request_workflow.md@c7c8aec10c3f129e5ef2adf4250f9406b2b4b931 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:README.md@c8e0ba7151b0d0221bf608576e6194f22b2c44e4 ;
gitlab-org/gitlab:scripts/lint/commit_linter.rb@236ced52d25f9bbeb3b4506eca80c0baa3cb8ce8 ;
gitlab-org/gitlab:lefthook.yml@43ecb41ea18fda993c19544a7e59b43657c7994f ;
gitlab-org/gitlab-environment-toolkit:CONTRIBUTING.md@f2a0118409967ce1183fc778c08e9fdaaf6154c7 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7428 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7555 ;
https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/1330 ;
gitlab-org/cli:lefthook.yml@f679ecb2f4a1f2f2a508150e8428b4037d15aff6 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/4437#note_4045158435 ;
https://gitlab.com/gitlab-org/ruby/gems/gitlab-grape-openapi/-/merge_requests/77#note_4003487181 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261675#note_4061695932 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3143#note_4064201956 ;
https://gitlab.com/gitlab-org/gitlab-zoekt-indexer/-/merge_requests/1085#note_4022531558 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7676#note_4077382363 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7706 ;
https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/merge_requests/4756

## 9. Commit, push and open the MR

Follow references/commits-and-descriptions.md for messages, changelog, title
and description. When you open the MR:

- **Search again first**, for duplicates and related issues, and check the default branch once more: an MR opened since you started may already fix it (section 3, items 2 to 4 and 7; observed, 41 duplicate closes).
- **Target the canonical project and its default branch.** From a fork, GitLab offers the upstream project as target; check both fields before creating. An MR that targets the fork's own default branch is closed by a gitlab-community/meta policy, whose note links the correct new MR (enforced). The source project and branch cannot be changed later; a wrong one means a replacement MR (observed, 10).
- **Open the MR only when it has commits**, and check the Changes tab shows only yours (observed, 17 empty MRs closed).
- **Fill the project's template**; do not replace it, and do not rely on its `/label` or `/assign` quick actions, which do nothing without a role (documented; enforced).
- **Tick "Allow commits from members who can merge to the target branch".** Maintainers then rebase or fix your branch instead of recreating the MR (observed, 2). In gitlab-org/gitlab, a team member who pushes to your branch becomes a commit author and can no longer approve it (documented).
- **Enable "Squash commits when merge request is accepted"** if the project squashes or you have several or suggestion commits (see references/commits-and-descriptions.md), unless a squash would drop a trailer the change needs (references/commits-and-descriptions.md, Changelog entries) or the project file says otherwise: gitlab-org/gitlab-pages, where a squash drops the `Changelog:` trailer, and the projects where squash is chosen per MR (gitlab-org/gitlab-elasticsearch-indexer, gitlab-org/fleeting/fleeting).
- **Keep it a draft** while it is not ready; a draft counts as "in your court" for the inactivity bot (enforced).

Three ways to open it, all equivalent:

- **The web UI.** After the push, the link git prints, or Code > Merge requests > New merge request in the fork. Set the target project to the canonical one and the target branch to its default branch.
- **glab.** `glab mr create --repo <group>/<project> --head gitlab-community/<group>/<project> --source-branch <username>-<topic> --target-branch <default> --title "<title>" --description-file <file> --allow-collaboration`: `--repo` names the canonical project the MR targets, `--head` the fork that holds your branch (for a personal fork, `<your username>/<project>`), and `--allow-collaboration` ticks the "Allow commits from members" box. In this form, without a local clone, glab takes no `--template`, so put the filled template in the file `--description-file` reads.
- **The API.** `POST https://gitlab.com/api/v4/projects/<fork id>/merge_requests` with `source_branch`, `target_branch` (the canonical default branch), `target_project_id` (the canonical project's numeric id; without it the MR targets the fork), `title`, `description`, `allow_collaboration=true` (the "Allow commits from members" box) and `squash` set as the project expects. A token with `api` scope can create the MR, because you are its author; it still cannot set reviewers or labels (non-negotiable 7). GitLab fills the project's default template in only when it builds the new merge request form, not when the API creates the MR, so put the template's text, filled in, into `description` yourself (enforced).

Sources: gitlab-community/meta:.triage-policies-fork-mrs.yml@a14a629fd45c0142bb65c96fa2dfa37c0eea546d ;
gitlab-org/gitlab:doc/api/merge_requests.md@d1cd3e49cc14259dcb7cccc3f78d081a27fa34ea ;
gitlab-org/gitlab:lib/api/merge_requests.rb@c16019c127650c354f22b85712169c4a00bf40c5 ;
gitlab-org/gitlab:app/services/merge_requests/create_service.rb@f995c1ae9d404e4736981e50c7e80b6481bd6068 ;
gitlab-org/gitlab:app/services/merge_requests/build_service.rb@6997282d29c2329dbac9eb1da3bafa61f6e09a0e ;
gitlab-org/cli:docs/source/mr/create.md@81e9c4f17a906c10fa63e607bdcb93d851199f82 ;
gitlab-org/gitlab:doc/development/code_review.md@46d16a140c38dc174e76b67c6eded0dc859c80a8 ;
gitlab-org/gitlab:doc/development/contributing/first_contribution/mr-review.md@cdf1fd18d13ad94c2185eb9cabcebc7c0256d318 ;
https://gitlab.com/gitlab-org/ci-cd/runner-tools/glci/-/merge_requests/195 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3033

## 10. What happens automatically after you open it

Within minutes on a public project in gitlab-org, gitlab-com, components or
gitlab-community (enforced; see references/bots.md for each):

- gitlab-bot adds `Community contribution` and `workflow::in dev` (and `1st contribution` when you have no merged MR in that project yet, since GitLab's flag for it is per project), assigns you, and posts a thank-you note linking the contributor platform page for this MR. It adds a paragraph about the community forks if you did not use one. In gitlab-org/gitlab it usually comes four minutes or more after the MR opens; request review only after it (or after about 70 minutes without it), because its `workflow::in dev` replaces the `workflow::ready for review` of a ready posted earlier (references/review.md, section 1).
- An AI labeller may add group, category and type labels; check them and correct wrong ones with `@gitlab-bot label` / `@gitlab-bot unlabel`.
- Set a `type::` label yourself with `@gitlab-bot label`. The bot's type label nudge skips MRs labelled `Community contribution`, so you see it only when the welcome note came late; if you do, add the label and resolve the nudge's thread yourself (references/review.md, section 6).
- During a hackathon window, the `Hackathon` label and eligibility instructions.
- Danger posts its comment when the pipeline runs (where the project uses it).
- In `gitlab-org` projects, if your description links an issue in a form gitlab-bot reads, it copies the issue's `type::`, section, stage and group labels onto the MR. The `linked-issue` label comes from a separate community automation account; check that it appeared. Both are described in references/commits-and-descriptions.md (Linking the issue).

## 11. Pipeline

- Fork pipelines may skip or fail jobs that need protected runners, secrets or tags only the canonical project has. That is not a failure of your change; say so once, with the job name and log line, and ask a member to run the pipeline in the canonical project (observed, 76 MRs).
- You cannot start or retry pipelines in the canonical project, and merge-train pipelines run there. Never push empty commits or retry in a loop (observed, 22).
- Rebase onto the current default branch first when a failure looks like one the default branch already fixed (observed, 14). To tell whether it did, for a failing test you did not touch, list the MRs merged there since your branch point that change the failing test's file; if one fixes it, rebase, push once, and say in one note which MR fixed it (observed, 1: in gitlab-org/gitlab-shell!1621 a race in `TestGitUploadArchiveSuccess` was fixed by !1622, which changes only that test's file).
- A `head_pipeline` can be a merged results pipeline a member ran in the canonical project: its `ref` is `refs/merge-requests/<iid>/merge` and its `sha` is the temporary merge commit GitLab made, not your head. Compare that commit's second parent (`parent_ids` in `GET /projects/:id/repository/commits/<sha>`) with your head before you read the pipeline as stale (documented; observed, 1, gitlab-org/cli!4044).

Details: references/troubleshooting.md.

Sources: gitlab-org/gitlab:doc/ci/pipelines/merged_results_pipelines.md@d685a660b99ddd17e25be0655fac347e224db635 ;
https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1621#note_4065676114 ;
https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1622 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/4044

## 12. Request review and answer it

Follow references/review.md: wait until GitLab shows your diff and head
commit and gitlab-bot's welcome note is there, use the platform's Request review (or, the path an agent can run,
post `@gitlab-bot ready @<reviewer>`; on a docs-only MR where the project
file says so (gitlab-org/gitlab, gitlab-org/gitlab-runner,
gitlab-org/ci-cd/runner-tools/grit), a bare `@gitlab-bot ready`), check the "requested review from"
system note and the Reviewers list, resolve your ready thread or the
platform's request thread once nothing in it is pending (a platform request
without Duo gets no bot reply), answer each review thread, and after a push
wait for the "reset approvals" note or about a minute, since until GitLab's
reset job runs an approval the push removes still reads `approved`
(references/review.md, section 9), then re-request review from each
reviewer whose state in `GET .../reviewers` is `reviewed`,
`requested_changes` or `unapproved`, not one still `unreviewed`, never one
that reads `approved` and never `duo-security-review-gitlab-org`, which team
members request (references/bots.md, section 3; references/review.md,
section 8): an agent with the
`mergeRequestReviewerRereview` GraphQL mutation, its `projectPath` being the
project the MR targets and not your fork, a person with the Re-request
review button in the right sidebar's Reviewers list, which an author without
a role sees since October 2026, but not in the reviewer drawer (expand the
sidebar first on a narrow screen such as a phone). GitLab Duo is the
exception: a re-request of your own answers `DCR4003`. Ask for Duo's new
review only while its state reads `requested_changes` (its block stands) or
a reviewer asks for one, and then on the platform's Request review with
only Duo ticked; after a push, a Duo
that commented or approved needs nothing (references/review.md, section 8).
Keep each reply to at most five lines, the answer first
(references/review.md, section 7).

## 13. Approval and merge

- Most GitLab projects need a reviewer's approval and then a maintainer's; the first reviewer often hands the MR to a maintainer. Wait for the person they name (documented in gitlab-org/gitlab's code review guide; observed, 15). If they approve and request nobody while `approval_rules_left` still lists a rule, ask them in a note that mentions them whom to hand it to, or, once the hourly limit allows, post `@gitlab-bot ready @<maintainer>` saying it is approved and green: a ready with a name requests only the people it names, while a bare ready re-requests the approver and removes the approval (references/review.md, section 2; section 4 says how to choose the maintainer). The reviewers' 7-day reminder skips reviewers who approved, so it does not move such an MR (references/review.md, section 10). (documented; enforced; `gitlab-org/gitlab:doc/development/code_review.md@46d16a140c38dc174e76b67c6eded0dc859c80a8`, `gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972`, `gitlab-org/quality/triage-ops:lib/community_contribution_helper.rb@b34c0f99b4c1c91043ab8f1d96cab9f124780f81`)
- Maintainers merge, usually through a merge train or auto-merge. After approval, do not push unless asked: any push aborts the automatic add, and a push that changes the diff removes approvals, every one or only those of the code owners whose files it changed, as the project sets it (observed, 31; references/review.md, section 9, and the project file).
- Count what is missing from the approval rules (`approval_rules_left`), not from `approvals_left`, which is not a head count (references/review.md, section 9).
- An approved MR still needs resolved threads, a green pipeline and no standing "requested changes" (including one from GitLab Duo where that setting is on) to merge (enforced by project settings). That reviewer's approval or withdrawal, or a bypass by someone who can merge, lifts a "requested changes"; a re-request does not (references/review.md, section 8 lists every way; for Duo's, request its new review through the platform).

## 14. After the merge

- gitlab-bot posts a feedback request on merged and closed community MRs: react with a thumbs up or down, or write `@gitlab-bot feedback <text>` (once a day per MR) (enforced).
- **Know when it ships.** Merge and release are different events. Libraries released with semantic-release get a bot comment "This MR is included in version X"; gems and components release through a separate release MR or tag pipeline cut by maintainers; in gitlab-org/gitlab the milestone the maintainer sets usually tells you the release, but the field can still be empty after the merge: the release is then the first `<major>-<minor>-stable-ee` branch that contains the merge commit, or, before that branch exists, the milestone whose dates the merge fell in (observed, 1). The release date of each GitLab minor version is in `data/releases.yml` in gitlab-com/www-gitlab-com (documented), and the gitlab-org milestone of a minor ends on the Friday six days before that date (observed, 3 milestones, 19.4 to 19.6). `GET /projects/278964/repository/commits/<merge commit>/refs?type=tag` lists the release tags that contain the merge, empty until a release carries it, and `type=branch` shows whether a `-stable-ee` branch does (documented). Ask about a release only if a user is waiting (observed, 30 in client-go; documented in several projects).
- **Open the follow-up issues or MRs you promised** in review, and link them from the original threads (documented in gitlab-org/gitlab's code review guide; observed, 30).
- **Then clear the To-Do List for that MR.** The merge resolves only the `assigned`, `review_requested`, `approval_required`, `added_approver`, `build_failed` and `merge_train_removed` To-Dos; the rest stay, and the feedback request above, which mentions you seconds after the merge, adds one the merge can no longer clear. Once nothing since the merge is owed and every promised follow-up is open, mark done what is left on the MR, and give the feedback reaction after that read, since it clears every To-Do of yours there (enforced; references/troubleshooting.md, To-Do List).
- For docs, check the published page once it is rebuilt and fix what renders wrong in a small follow-up (observed, 2).
- **Close the issue if the merge did not.** `Closes <issue>` closes it only when the MR is merged into the default branch and the project has "Auto-close referenced issues on default branch" on (documented). Four projects in references/projects/INDEX.md have it off: gitlab-org/gitlab, gitlab-org/release-tools, gitlab-org/gitlab-services/design.gitlab.com and gitlab-org/step-runner (enforced, project setting `autoclose_referenced_issues`, read through `GET /projects/:id` on 2026-10-22). There, if you opened the issue, close it yourself after the merge with a one-line note such as `Fixed by !<iid>, merged for <milestone>.`; if you did not open it, say in the issue that the MR merged so its author or a team member closes it (observed, 8). The contributor platform's manage-issue Close would accept it from you too (references/hackathon-and-platform.md, section 3), but leave an issue you did not open to them. Elsewhere, check that the issue did close; if the MR said `Related to`, update the issue yourself.

Sources: gitlab-org/quality/triage-ops:triage/processor/community/code_review_experience_feedback.rb@8765efcd87e41a34061c6c2e36596d19109e4f06 ;
gitlab-org/gitlab:app/services/todo_service.rb@67dccbf8b0e0af92d7375620c8c46dd42769f25a ;
gitlab-org/gitlab:ee/app/services/ee/todo_service.rb@4906f08d3a3c457c348f475c7ec9d3d118454626 ;
gitlab-org/gitlab:app/services/award_emojis/add_service.rb@c3b33faee255ed040a47da72ba1328e6c39e5a54 ;
gitlab-org/gitlab:doc/user/project/issues/managing_issues.md@e3e279695f8b03b7572dd17f8ee1758ded425e77 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263025 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_feedback.rb@ae29f6eeee99f8b972eaf45c6271137f5ff9b24e ;
gitlab-org/ruby/gems/gitlab-glfm-markdown:.gitlab/merge_request_templates/Release.md@515222abdfe6977cfdb13e4a56731b54a0ce7967 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3040 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263024 ;
gitlab-com/www-gitlab-com:data/releases.yml@e0067fc3213146d1a9e7afde82d118b9bbf073bd ;
gitlab-org/gitlab:doc/api/commits.md@a2ea8aaf67d442b6c89e85a0a417cac11ba6e5f1 ;
https://gitlab.com/groups/gitlab-org/-/milestones/138 ;
https://gitlab.com/groups/gitlab-org/-/milestones/139 ;
https://gitlab.com/groups/gitlab-org/-/milestones/144

## 15. If you cannot finish

- **Say so.** Write `@gitlab-bot handoff` (it unassigns everyone, labels the MR `workflow::in dev` and `Seeking community contributions`, and invites another contributor), or close the MR yourself with a one-line reason and a link to any replacement (enforced; observed, 51 author closes, 30 without a reason).
- If the issue is scheduled for the current milestone, a team member may finish the MR; when a team member or merge request coach takes over, they credit you with a changelog entry or keep your commits (documented). In the corpus 29 contributions were finished or recreated by maintainers, most with the author's commits or a credit (observed, 29).
- Unassign yourself from the issue on the platform's manage-issue page.

Sources: gitlab-org/quality/triage-ops:triage/processor/community/command_mr_handoff.rb@1814ceb7df50f9a2a67ae3b62ecd47aa343c1485 ;
gitlab-org/gitlab:doc/development/contributing/merge_request_workflow.md@c7c8aec10c3f129e5ef2adf4250f9406b2b4b931 ;
gitlab-com/content-sites/handbook:content/job-description-library/expert/merge-request-coach.md@877b9494a705060060f63c5ee5b11d4ee9a5a1b1
