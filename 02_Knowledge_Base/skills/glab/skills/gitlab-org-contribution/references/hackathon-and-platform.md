# The contributor platform, the community forks and hackathons

Three pieces of infrastructure exist for community contributors to GitLab's own
projects: the contributor platform at contributors.gitlab.com, the community
forks under `gitlab-community`, and the hackathons that run on both. This file
says what each one does, what it allows a contributor without a project role to
do, and the limits that apply. Figures such as points, limits and dates come
from the platform's source and change; check the cited file before relying on
a number.

## Contents

- [1. Onboarding: one request for all of it](#1-onboarding-one-request-for-all-of-it)
- [2. Community forks](#2-community-forks)
- [3. The manage-issue page](#3-the-manage-issue-page)
- [4. The manage-merge-request page](#4-the-manage-merge-request-page)
- [5. Points and levels](#5-points-and-levels)
- [6. Hackathons](#6-hackathons)

## 1. Onboarding: one request for all of it

- Start at https://contributors.gitlab.com/start. Within a few minutes an onboarding issue opens in `gitlab-community/community-members/onboarding`. Its `access-request::` label tracks the request: `pending`, then `awaiting-information`, `approved` or `closed` (documented).
- A public profile with a short bio and links speeds the review. Accounts that look like security research accounts (HackerOne participants and similar) are not granted access (documented).
- Approval gives Developer access to every community fork, complimentary GitLab Duo inside the forks, and community member status on the platform's manage pages (enforced).
- Approval is per person and takes a review; request it before you need it, for example before a hackathon starts (documented).

Sources: gitlab-community/meta:README.md@6f1c3fd623d90bdafdec81d8fd0977bf2dd03947 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/concerns/manageable_concern.rb@f39cc821eff099faecf62980cc9ab44d9cd272a4

## 2. Community forks

**Where.** Each fork lives under `gitlab-community` at the canonical project's
full path: `gitlab-community/gitlab-org/gitlab` for `gitlab-org/gitlab`. About
110 upstream projects are configured, across `gitlab-org`, `gitlab-com`,
`components` and `security-products` (documented).

**Does my project have one?** Any of: open `https://gitlab.com/gitlab-community/<project path>`;
look for the community fork badge in the canonical project's sidebar; search
`tofu/states/main/projects_*.tf` in gitlab-community/meta; read the project's
CONTRIBUTING.md (usually a "Forks" section) or gitlab-bot's welcome note.
In October 2026 several corpus projects had none (for example
`gitlab-org/cells/http-router`, `gitlab-org/gitlab-qa`,
`gitlab-org/release-tools`, `gitlab-org/ci-cd/docker-machine` and some Ruby
gems), so check rather than assume (documented; observed).

**Why use it** (documented in the meta README and many CONTRIBUTING files):

- Pipelines run on the GitLab for Open Source program's quota with the runners the project expects; personal CI minute and storage quotas do not apply.
- Danger runs without your own token or CI variables, where the project runs it in fork pipelines at all (references/bots.md, section 2).
- The default branch is pull-mirrored from the canonical project.
- Team members can push to your branch to help.

In the closed-MR sample, 34 MRs were closed and reopened from the community
fork and 2 more died of exhausted CI minutes (observed, 36).

**Fork settings you will notice** (enforced by the fork module): issues, wiki,
snippets, releases, environments, feature flags, monitoring and forking are
off; access requests are off; the default branch is protected and only mirror
accounts push or merge to it. Pull mirroring copies only protected branches,
never overwrites a diverged branch and does not trigger pipelines. So:

- Never commit to the fork's default branch. Branch from it, or better, from the canonical default branch.
- Prefix branches with your username. Members have Developer access to every branch; work on someone else's branch only with their permission (documented).
- Rebase on the canonical project's default branch when the mirror lags.
- Open the MR against the canonical project. A gitlab-community/meta triage policy closes any MR that targets a fork's default branch and links the correct one (enforced).

**Requesting a fork.** Open an issue in gitlab-community/meta with the
`Fork request` template (suggested title `<project> fork request`, the link to
the source project; it mentions the community forks maintainers and applies a
`fork-request` label). A team member adds the project to the OpenTofu
configuration, enabling the container or package registry if the pipeline needs
it, and the fork is created after that MR merges. Until then a personal fork is
the only option; say so in your MR description (documented). Forks were created
on request for several corpus projects (observed, 4).

**Moving an MR from a personal fork.** The source project of an MR cannot be
changed. Push the branch to the community fork, open a new MR with the same
title and description, link the old MR, copy over review comments that still
apply, and close the old MR with a note naming the new one. Do not keep pushing
to the personal-fork MR hoping its pipeline will start working (documented;
observed, 34).

**Duo in the forks.** Members get GitLab Duo and Duo Agent Platform access for
contributing to projects that have a community fork, capped at 500 GitLab
Credits per member per month (reset on the 1st). It is not for personal,
academic or commercial projects, building tools, or unattended or bulk agentic
workloads. To raise the cap for an in-progress contribution, comment on your
onboarding issue (reopen it if closed), mention the contributor success group
as the guidelines write it, `@gitlab-org/developer-relations/contributor-success`,
and link the work.
Fork membership does not let you start Duo Code Review in the canonical
project (documented; see references/bots.md).

Sources: gitlab-community/meta:README.md@6f1c3fd623d90bdafdec81d8fd0977bf2dd03947 ;
gitlab-community/meta:tofu/states/main/projects_gitlab-org.tf@a3493e36312d4327dbd3c5ac7ccb1aee3c0778ef ;
gitlab-community/meta:tofu/modules/fork_project/main.tf@5953f1e608847ffd43daa755574c93167cc7fa0c ;
gitlab-community/meta:.triage-policies-fork-mrs.yml@a14a629fd45c0142bb65c96fa2dfa37c0eea546d ;
gitlab-community/meta:.gitlab/issue_templates/Fork request.md@5acb52047cd8db3d210c3952196111427d5c1e6b ;
gitlab-community/meta:docs/duo-usage-guidelines.md@6f1c3fd623d90bdafdec81d8fd0977bf2dd03947 ;
gitlab-org/gitlab:CONTRIBUTING.md@334527f887d3b1bed8b86da976cb71a1d23dea50 ;
https://gitlab.com/components/opentofu/-/merge_requests/541 ;
https://gitlab.com/gitlab-org/labkit/-/merge_requests/456 ;
https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2904

## 3. The manage-issue page

```text
https://contributors.gitlab.com/manage-issue?projectPath=<group/project>&issueIid=<iid>&action=work
```

`projectId=<numeric id>` works in place of `projectPath`. The page accepts
issues in projects under `gitlab-org`, `gitlab-com`, `gitlab-community` and
`components` (enforced). Everything it posts comes from the
`contributors.gitlab.com` account and names you.

| Action | What happens | Limits |
| --- | --- | --- |
| Assign (Work on this) | A thread thanks you, runs `/assign` for you, and asks the issue's author, assignees and named product or engineering managers (or a random available coach) to confirm the issue is ready. It links back to the page so you can unassign. | Issues you may hold at once: 4 at level 0, 8 at level 1, 12 at level 2, 16 at level 3, and 100 from level 4 (levels 4 and 5 have no entry in the per-level table, so the code falls back to its hard limit of 100). The page also refuses an issue marked blocked ("This issue is marked blocked and likely isn't ready to be worked"). Per-label limits exist in the code, but none is set at the pinned commit. At a limit the Assign button is replaced by a message explaining why. |
| Unassign | Removes you. | |
| Label | Adds labels with a thank-you note. | Rate limited since the build deployed on 2026-10-27 (v2.276.0); earlier builds set no limit. |
| Close | Closes with one of four reasons and its label: complete (`workflow::complete`), not reproducible (`closed::cannot reproduce`), support request (`support request`), duplicate (`Duplicate`). Mentions the author and assignees, or a coach. The duplicate reason asks for the original issue and posts `/duplicate <reference>`, which marks the issue as a duplicate; that quick action works only for someone with a role in the project, so a contributor's own `/duplicate` does nothing. | Any approved community member or team member can close any open issue the page accepts; the page does not check that you are its author or an assignee. So someone who called your issue a duplicate may close it this way. |

Assigning through the page is the documented way for a contributor without a
role; `/assign` and the API do nothing for them. In the sample the page
assigned 16 issues across 9 projects (enforced; observed, 16). Answer any
question the confirmation request gets before you start.

Sources: gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_issue_controller.rb@f39cc821eff099faecf62980cc9ab44d9cd272a4 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/concerns/manageable_concern.rb@f39cc821eff099faecf62980cc9ab44d9cd272a4 ;
https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/releases/v2.276.0 ;
gitlab-org/gitlab:lib/gitlab/quick_actions/issue_actions.rb@f2e6534e7b0e7e266feb0bbe37f02d6b4a30dedd ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/common/IssueUrlRegexUtils.js@e149e13f1d1ce4a83029d2dd9f1d1d738b8b8825 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/common/Constants.js@d2b6b66020a4e1521027d251d864d810108f1497 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/pages/manage-issue-page/WorkAction.vue@fd4fd9323a309be5acae7cf5b29167164f46753f ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/public/docs/user-guide.md@ad349bb7f25fde5756f66751e4ccf91f0f94d19f ;
https://gitlab.com/gitlab-org/cli/-/work_items/8614 ;
https://gitlab.com/components/toolkit/-/work_items/19

## 4. The manage-merge-request page

```text
https://contributors.gitlab.com/manage-merge-request?action=review&projectId=<id>&mergeRequestIid=<iid>
```

gitlab-bot's welcome note links it for each community MR. `<id>` is the
canonical project's numeric id; how to find it, the `mergeRequestId` form and
the other `action` values are in references/review.md, section 3. Three
actions:

- **Request review.** Posts a thread with hidden `/ready`, `/label ~"workflow::ready for review"` and `/request_review` for everyone you tick or type (current reviewers, the suggested reviewer, GitLab Duo, and usernames you enter; up to four people besides Duo), and, when GitLab Duo is included, a hidden `@gitlab-bot ready @GitLabDuo` line so the bot makes the Duo request. Since the build deployed on 2026-10-27 (v2.276.0) it ticks nothing when the MR already has other reviewers, and otherwise Duo alone until it has reviewed and the suggested reviewer alone after that; earlier builds ticked Duo and the current reviewers. The platform never adds a person on its own: after dealing with Duo's comments, request the human you chose there or with `@gitlab-bot ready` (references/review.md, sections 3 and 4). The suggestion is an available team member with review capacity for the project (reviewers and trainee maintainers before maintainers, spread by open review count), or a random available coach (enforced; observed, 223 Duo runs requested this way, 4 refused). Request review is also how a contributor gets a new Duo review after Duo requested changes and its findings are answered, which a re-request of your own cannot do (`DCR4003`): push the fix first, then tick Duo and untick each person you do not mean to re-request; gitlab-bot re-requests Duo, and Duo's approval of that review lifts its own block, with no maintainer needed (observed, 1, gitlab-org/api/client-go!3147 on 2026-10-21; references/review.md, section 8). A request sent before the push reviews the old head, finds nothing new and leaves the block in place, and every request opens a thread of its own to resolve afterwards (observed, 1, gitlab-org/gitlab!266340).
- **Help.** Starts a thread asking the chosen reviewer or coach to help and requests their review. Add the context of what you need in that thread (enforced; documented).
- **Label.** Adds labels with a note.

The review request is a thread from the start, and gitlab-bot answers inside
it only when GitLab Duo was included. Check who was asked from the "requested
review from" system note and the Reviewers list, not from a reply, and resolve
the thread once nothing in it is pending (references/review.md, section 5).

Sources: gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_merge_request_controller.rb@a8b2e17709713e9b4c5cf18dc12c7dac7dc56d4e ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/pages/ManageMergeRequestPage.vue@805fcff1ef8265fafe18aa2ae4cf9dbdc6179d0a ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/pages/manage-merge-request-page/RequestReviewAction.vue@840936a0d635a76536946883caa39b6567439d05 ;
https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/releases/v2.276.0 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/266340 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/lib/review_capacity_picker.rb@9ef430566acda40d0b41a0e619e9ac6780ef98bb ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/services/suggested_reviewer_service.rb@cb638b89b90936ec8fda5da62ea760928654ad01 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/services/gitlab/rest/notes.rb@86a13b160a682e964a6307a8c7d18074303deb57 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261343 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3147

## 5. Points and levels

| Activity | Points |
| --- | --- |
| MR created | 20 |
| Each merged commit | 20 |
| MR merged | 60 (plus 30 when linked to an issue) |
| Issue created | 5 |
| Issue labelled through the platform | 1 |
| Issue closed through the platform | 5 |
| Comment on an issue or MR | 1 |

Discord, forum, translation, event and content activity also count once the
matching account is linked in the platform profile. Levels start at 25 points
(level 1), 500 (2), 2,500 (3), 7,500 (4) and 37,500 (5); each level grants
reward store credits and raises the number of issues you may hold, up to the
hard limit of 100 that applies from level 4 (section 3) (documented;
enforced).

"Linked to an issue" means the MR carries the `linked-issue` label, which the
leaderboard reads (enforced). A community automation account, not gitlab-bot,
adds it. Start a line of the description with
`Closes https://gitlab.com/<group>/<project>/-/issues/<iid>` (or `Related to`
with the same URL), as references/commits-and-descriptions.md explains, and
check the label appeared; the merge request API's `closes_issues` list can stay
empty for work item references, so do not judge by it (observed, 3).

Sources: gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/public/docs/user-guide.md@ad349bb7f25fde5756f66751e4ccf91f0f94d19f ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/common/Constants.js@d2b6b66020a4e1521027d251d864d810108f1497 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/queries/hackathon_leaderboard_query.rb@0aab5e7e93f587748ab6cd91f42b6fcfb1fc0422 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261343 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261288

## 6. Hackathons

**Joining.** Sign in at https://contributors.gitlab.com/hackathon and accept the
rules (terms version `2026-10-v1` at the time of writing). Without accepting,
your MRs do not count; gitlab-bot's hackathon note on each MR says the same
(enforced; observed, 65).

**Rules** (breaking one disqualifies without warning; documented):

1. At most 20 MRs and 20 issues opened per day.
2. No MR for an issue you are not assigned to. Assign through the manage-issue page (section 3), or ask in the issue and wait.
3. AI tools are allowed, but the contribution is yours: review and test it locally before opening the MR, and be able to explain it.
4. At most one typo-fix MR per project. Batch small docs or link fixes for one project into one MR; maintainers closed sets of one-link MRs and asked for a single one (observed, 8).
5. Issues labelled `quick win::first-time contributor` are reserved for people with no merged MR in any GitLab project.

**The label.** gitlab-bot adds the `Hackathon` label to community MRs created
inside the event window. Do not ask maintainers to add it, and do not try to
add it with `@gitlab-bot label`: it is not on the allow-list. Project-specific
event labels (for example one Orbit uses) are for maintainers to add; ask once
(enforced; observed, 6).

**Dates.** Each event has a window and a later merge date, listed on the
platform. For October 2026 the window ran from 2026-10-06 00:00 UTC up to,
not including, 2026-10-13 00:00 UTC (the platform lists it as 2026-10-06 to
2026-10-12), and the merge date was 2026-11-12 (enforced).

**Scoring** (enforced in the leaderboard code):

- Only MRs opened inside the window, in projects under `gitlab-org`, `gitlab-com`, `gitlab-community` and `components`, and merged before the merge date count.
- Each merged MR is worth 80 points, or 110 with the `linked-issue` label, plus 20 for each distinct merged MR containing your commits.
- You score nothing until at least one MR has merged and you have accepted the rules; after that, your other activity points for the period are added.
- An MR that cannot merge before the merge date earns nothing for the event, so plan work that can be reviewed in time, and answer review quickly.

**What hackathon MRs were closed for.** Of 518 closed MRs in the sample, 146
carried the `Hackathon` label; they were closed mainly as author withdrawals
(23), consolidations (21), duplicates (18) and empty placeholders (16). An MR
opened for an issue assigned to someone else was closed by its author once
that was pointed out (observed). A fix "found during the hackathon" with no
issue and no stated reason waited without review and was closed as stale
(observed, 1). See references/why-mrs-get-closed.md.

**Documentation hackathon issues in gitlab-org/gitlab.** Technical writers
assign docs issues with `/assign`; each contributor should hold at most three
at a time and gets another after opening an MR for one; the MR author must be
the assigned person; follow any split the issue sets, such as one file per
contributor (documented). An MR that ignored such a split was closed at the
writer's request (observed, 1).

Contributions are welcome outside hackathons too; the rules above apply only
to counting for an event (observed, 1).

Sources: gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/public/docs/hackathon-rules.md@eddd645fba2ffe5a47bc2b4655ab5cbd31ea4554 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/pages/hackathon-page/DetailsSection.md@6f09594823132d23d66b0c62c8198308f238a5fc ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/models/hackathon.rb@04c47ea001e3018103d0da6c14e5815c5a91b125 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/services/hackathon_leaderboard_service.rb@c877d0870bafe9b054ed52996dcfe35af4a61b6f ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/queries/hackathon_leaderboard_query.rb@0aab5e7e93f587748ab6cd91f42b6fcfb1fc0422 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/services/gitlab/gitlab_owned_namespace_contributions_service.rb@90d6d7332b0b05737cc02515a8760270e3684dfe ;
gitlab-org/quality/triage-ops:triage/processor/community/hackathon_label.rb@2d794ba6558a45d05fca8d43c4e3e3ad0199ba01 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_label.rb@46a4823632f3401513d233b99137d836d520e2ad ;
gitlab-org/gitlab:doc/development/documentation/workflow.md@c482442667336a6d129cf6806bed323f5cb60124 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261632 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7611 ;
https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/320 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/4400
