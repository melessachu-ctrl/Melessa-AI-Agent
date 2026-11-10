# Why community MRs get closed, and how to avoid or rescue each case

This file comes from reading 518 community MRs closed without merging, across
46 projects in `gitlab-org` and `components`, one by one. Use it before you
start (most causes are avoidable before the first commit) and when your MR is
in trouble.

## Contents

- [1. The numbers](#1-the-numbers)
- [2. Stale (113)](#2-stale-113)
- [3. Superseded (100)](#3-superseded-100)
- [4. Noise (91)](#4-noise-91)
- [5. Product or design decision (65), missing agreement (7) and scope (4)](#5-product-or-design-decision-65-missing-agreement-7-and-scope-4)
- [6. Withdrawn by the author (53)](#6-withdrawn-by-the-author-53)
- [7. Wrong place (42) and CI minutes (2)](#7-wrong-place-42-and-ci-minutes-2)
- [8. Duplicate (41)](#8-duplicate-41)
- [9. Before you open an MR: the checklist this file implies](#9-before-you-open-an-mr-the-checklist-this-file-implies)

## 1. The numbers

| Cause | MRs | Breakdown |
| --- | --- | --- |
| Stale | 113 | 76 auto-closed by gitlab-bot; 28 closed by a maintainer after long silence; 5 author ran out of time or resources; 4 author gave up waiting for a review |
| Superseded | 100 | 29 finished or recreated by a maintainer; 24 replaced by someone else's MR; 23 replaced by the author's own new MR; 21 folded into one combined MR; 3 split or replaced by an alternative |
| Noise | 91 | 44 test, accidental or research MRs; 17 empty; 16 unexplained or invalid changes; 12 automation; 2 unreviewed AI output |
| Product or design decision | 65 | 27 approach rejected; 21 not wanted; 15 not needed; 2 other |
| Withdrawn by the author | 53 | 30 with no reason given |
| Wrong place | 42 | 34 reopened from the community fork; 5 belonged in another project; 3 wrong branch or no CI |
| Duplicate | 41 | 26 duplicate of another MR or an assigned issue; 10 already fixed on the default branch; 5 competing or overlapping work |
| Missing agreement | 7 | 5 premature; 2 no agreement on the approach |
| Scope | 4 | outside what the project accepts, or against the issue's rules |
| CI minutes | 2 | personal fork out of minutes or storage |

The table classifies each MR by its underlying cause, so one close counts
once. Who closed them: the author 218, another person (maintainers, reviewers,
coaches) 219, gitlab-bot 81. The 81 bot closes include the 76 in the Stale
row; the few others are classified under their underlying cause (for example a
product decision a maintainer had already stated before the bot closed the
idle MR). These are the counts the rest of the skill refers to. 337 carried the `1st contribution` label and 146
the `Hackathon` label, so a contributor's first MRs in a project and hackathon bursts are where the
avoidable closes cluster (observed, 518).

About 110 of the closes were administrative (an own replacement, a resubmission
from the community fork, a maintainer takeover, a consolidation, a split): the
work continued elsewhere. A close is not always a rejection.

None of the 518 was closed for a missing `Signed-off-by:`, a Developer
Certificate of Origin or Contributor License Agreement problem, or another
licensing reason. That does not make the terms optional: what you agree to by
submitting is in references/workflow.md, section 1 (observed, 0 of 518).

Other files of this skill quote these figures and point here. Counts taken over
a different sample (for example every MR read for the skill, open and merged
ones included, where some auto-closed MRs were later reopened) differ slightly
and are not used.

Sources: https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4377 ;
https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/3621 ;
https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6245 ;
https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9900 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3118

## 2. Stale (113)

**How the clock works** (enforced, in `gitlab-org` projects; no such nudge or
close appeared in `components` or `gitlab-com` projects of the sample):

- An open community MR gets `idle` after 7 days without a human update (drafts included) and `stale` after 30. Bot notes do not reset the clock; any human comment or commit does. The labels themselves are removed only when the author or a team member comments, pushes or reopens the MR.
- While idle and in your court, gitlab-bot nudges at most once every 7 days, naming the reason.
- Once `stale` and still in your court, gitlab-bot closes it. Bot closes started on 2026-07-02 (31 long-idle MRs that day) and continued: 81 closes by gitlab-bot in the sample (76 classified as stale, see section 1), each at least 30 days after the last human comment (median 35), after a median of 3 nudges (up to 8).

**Your court** means any of: the MR is a draft; it has a conflict or needs a
rebase; its head pipeline failed or was cancelled; a human reviewer has
"requested changes"; or no human reviewer is assigned. GitLab Duo does not count
as a reviewer. When none hold and the MR is ready for review, the bot reminds
the reviewers instead and never auto-closes it.

The nudges on the 76 auto-closed MRs named a failing pipeline on 24, a draft on
10, no review requested on 10 and open review feedback on 6. Several MRs that
only Duo had reviewed were closed as "not sent for review".

**Avoid:**

- Fix exactly what the nudge's first sentence names: "still in draft" (mark ready), "merge conflict" (rebase), "the pipeline's failing" (fix it; retry a flaky job yourself if the pipeline ran in the community fork; otherwise explain with a link to the same job failing in other recent MRs or on the default branch, ask a member for a retry, and still request review), "open review feedback" (push and re-request review), "hasn't been sent for review yet" (request a human review). A comment alone buys at most 30 days: a failing head pipeline keeps the MR in your court until a pipeline passes, so each human comment only restarts the idle count, the nudges resume a week later and the close follows 30 days after the last human update.
- After addressing feedback, re-request review from the reviewer who asked for changes; a standing "requested changes" keeps the MR in your court even while you wait for something else (observed, 7). The re-request resets that reviewer's state, which is what the bot reads, so it takes the MR out of your court for that reason; the merge block stays until they approve (enforced). How to re-request without a role, an agent included: references/review.md, section 8.
- Answer every reviewer question within days, even with "I can't continue, feel free to take it over". The nudge itself says closing is fine. An MR kept alive only by "still on my list" comments was closed after 1042 days (documented; observed).
- If you are blocked by something outside your control (a freeze, a dependency, a decision), say so in the MR, link it, and ask a maintainer for `automation:prevent-auto-close` (only maintainers can add it).
- Do not wait silently for a first review: three authors gave up after asking for a review for 580 to 640 days, and another MR routed to a group that did not own the project waited more than three years (observed, 4). See references/review.md, section 10.

**Rescue:** reopen it yourself and, in the same sitting, remove the reason it
was in your court. Reopening by you or a team member removes `idle` and
`stale` (enforced), but the MR can go idle again while it is still in your
court: one MR was closed, reopened and updated, and closed again the next day
until a maintainer added `automation:prevent-auto-close` (observed, 1).

**Before the bot existed, and in projects it does not cover,** maintainers
closed idle MRs by hand after unanswered questions: 28 MRs, open a median of
596 days (observed, 28).

**Conflict between documents:** the merge request triage handbook page says
"all decisions to close a merge request are made by a human, and are not
automated", while the triage-ops close policy closes stale community MRs
automatically. Plan for the enforced behaviour.

Sources: gitlab-org/quality/triage-ops:policies/stages/hygiene/label-idle-community-mrs.yml@cd239f9fe4e47165898345f9c136acf7980d3c70 ;
gitlab-org/quality/triage-ops:policies/community/hygiene/ping-inactive-author.yml@adcb2783c84e20eaf3fef193df65c4a40551785a ;
gitlab-org/quality/triage-ops:policies/stages/hygiene/close-stale-community-contributions.yml@6acf2943033faf15ea02b61ec5bdd311a420d86e ;
gitlab-org/quality/triage-ops:lib/idle_mr_helper.rb@b2047a41aafc36e2798890e4ccd8f28e946b2a2a ;
gitlab-org/quality/triage-ops:triage/processor/community/remove_idle_labels_on_activity.rb@b4d49ec8be9223319bdaecfdaf3574698bb168a3 ;
gitlab-org/quality/triage-ops:lib/mr_court_helper.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/gitlab:app/services/merge_requests/request_review_service.rb@8c5023ca3803ed42b32430c337113e405f48f98e ;
gitlab-org/gitlab:ee/app/services/merge_requests/mergeability/check_requested_changes_service.rb@86fa5a3bca0d5f8b044f303e6f47161f9744bdb5 ;
gitlab-org/quality/triage-ops:policies/community/hygiene/ping-inactive-reviewers.yml@e0f9071dc93f7668929e346b32801ba1f5d31f1a ;
gitlab-com/content-sites/handbook:content/handbook/engineering/infrastructure-platforms/developer-experience/merge-request-triage.md@8af74dc37459fa5b5e561c3d5874630353cfa786 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/1765 ;
https://gitlab.com/gitlab-org/container-registry/-/merge_requests/2932 ;
https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/3360 ;
https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/merge_requests/39

## 3. Superseded (100)

- **Finished or recreated by a maintainer (29).** When you cannot finish, say so and invite a takeover; maintainers and coaches may finish it and credit you (your original commits or a changelog entry), or close it, depending on how important the change is (documented). In some projects (LabKit, LabKit for Ruby, design.gitlab.com, the Fargate driver) pipelines cannot complete from any fork, and the usual outcome is a maintainer porting your commits into a project branch; check the new MR keeps your commits (observed, 13).
- **Replaced by someone else's MR (24).** Usually a competing fix or a team member's MR; see Duplicate.
- **Replaced by your own new MR (23), often the same day.** Keep one MR per change and update its branch; open a replacement only when the source project or scope must change, and link it and carry the open threads over (observed, 23).
- **Folded into one combined MR (21).** Batch small docs or link fixes for one project into one MR; maintainers closed sets of one-link MRs and asked for one (observed, 21).
- **Split or alternative chosen (3).** One concern per MR; ask in the issue before proposing parallel alternatives (documented).

Sources: gitlab-org/gitlab:doc/development/contributing/merge_request_workflow.md@c7c8aec10c3f129e5ef2adf4250f9406b2b4b931 ;
gitlab-com/content-sites/handbook:content/job-description-library/expert/merge-request-coach.md@877b9494a705060060f63c5ee5b11d4ee9a5a1b1 ;
https://gitlab.com/gitlab-org/labkit/-/merge_requests/767 ;
https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/422 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3099

## 4. Noise (91)

- **Tests, accidents, research (44).** "Test", "Add new file", "TEST MR - DELETE ME", an MR created by Duo's "Fix failing pipeline" button, MRs meant for your own fork. Experiment in your fork, and check the target project and branch in the new MR form: from a fork GitLab offers the upstream project. Close an accident yourself at once.
- **Empty (17).** Hackathon placeholder drafts never filled (closed about 250 days later), branches left with no diff after the default branch was merged in, an approved MR whose changes were never pushed. Open the MR only when it has commits; check the Changes tab after every push; to claim an issue, assign yourself instead.
- **Unexplained or invalid (16).** Deleted CI config, CODEOWNERS or docs with no reason, a revert of a deliberate change. Fill the description template with what and why, and keep the diff to that purpose.
- **Automation (12).** Bot-generated updates that do not apply.
- **Unreviewed AI output (2), plus AI-assisted MRs closed for other reasons.** Review and test every AI-generated change; do not submit scanner or link checker output without checking each finding (documented in the hackathon rules and the Environment Toolkit's CONTRIBUTING.md).
- **Secrets.** Three accidental MRs exposed a credential, connection strings or personal Terraform state. Never commit them; revoke at once if it happens, since closing does not remove them.

Sources: gitlab-com/content-sites/handbook:content/job-description-library/expert/merge-request-coach.md@877b9494a705060060f63c5ee5b11d4ee9a5a1b1 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/public/docs/hackathon-rules.md@eddd645fba2ffe5a47bc2b4655ab5cbd31ea4554 ;
gitlab-org/gitlab-environment-toolkit:CONTRIBUTING.md@f2a0118409967ce1183fc778c08e9fdaaf6154c7 ;
https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/merge_requests/3162 ;
https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1042 ;
https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/1330

## 5. Product or design decision (65), missing agreement (7) and scope (4)

These three rows of the table add up to 76 closes about what to build rather
than how it was built.

- For a feature, a behaviour change or a new setting, get agreement in the issue from the product manager (named on the group's handbook page, which the issue's `group::` label leads to) or a maintainer (from CODEOWNERS for the code you would touch) before building it, and read the whole thread: "wait until X changes" or "the fix belongs in the backend" is often already written there (documented; observed, 76, the three rows of this section).
- Do not change a default, a public contract or a dependency pin without a migration path; propose the additive or deprecation route first (observed, 4).
- Leave dependency and toolchain bumps to the project's dependency bot or schedule unless an issue asks (observed, 5).
- Some projects state narrow acceptance rules (for example GitLab's docker-machine fork accepts only critical fixes affecting running costs, the GDK accepts no new features, the Environment Toolkit wants a maintainer-reviewed issue first, gemnasium-db never deletes advisories, and the deprecated release-cli, whose README says only that it accepts no new features, while a maintainer said in 2026 that it takes no contributions at all and pointed to glab, gitlab-org/cli). Read the project description, CONTRIBUTING.md and AGENTS.md, and the project file under references/projects/.

Sources: gitlab-org/gitlab:doc/development/contributing/merge_request_workflow.md@c7c8aec10c3f129e5ef2adf4250f9406b2b4b931 ;
gitlab-org/ci-cd/docker-machine:CONTRIBUTING.md@f9f13f0f2a52185b4c9b3e6242cd931e5a6239e3 ;
gitlab-org/gitlab-development-kit:AGENTS.md@3942e100fa4efd14d3722e3bd8023a22bdc8764a ;
gitlab-org/release-cli:README.md@4a842a47f16977e3a9de13b43f82bde4b53344d1 ;
https://gitlab.com/gitlab-org/release-cli/-/merge_requests/201 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/3899 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/255239 ;
https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/207

## 6. Withdrawn by the author (53)

30 carried no reason. When you close your own MR, leave a one-line reason and a
link to any replacement or to the change that made it unnecessary ("closing in
favour of !N", "the fix landed in !N"), so the issue can move on (observed, 51).

Sources: https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/merge_requests/3219 ;
https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2514

## 7. Wrong place (42) and CI minutes (2)

- **From a personal fork (34 reopened, 2 died of minutes).** Use the community fork; see references/hackathon-and-platform.md. Several maintainers requested changes only to ask for the move (documented; observed, 36).
- **Wrong project (5).** Read the issue for where the fix belongs (for example language server versus editor extension); changes were moved to the other repository (observed).
- **Wrong branch (3).** Work on a dedicated branch from the current default branch and target the default branch; MRs from a fork's default branch or against a feature, stable or smoke-test branch were redone or closed (observed, 9).

Sources: gitlab-community/meta:README.md@6f1c3fd623d90bdafdec81d8fd0977bf2dd03947 ;
https://gitlab.com/components/opentofu/-/merge_requests/541 ;
https://gitlab.com/gitlab-org/glql/-/merge_requests/85 ;
https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/merge_requests/3155

## 8. Duplicate (41)

- **Duplicate of another MR or an assigned issue (26).** Check the assignee and linked MRs, search open MRs for the issue number, and get assigned first. In two cases both contributors had self-assigned the same unassigned issue and the maintainer kept the MR with better coverage, not the first one (documented; observed, 41).
- **Already fixed on the default branch (10).** Reproduce on the latest default branch before you start, and rebase before asking for review (observed, 25 including "not needed").
- **Competing or overlapping work (5),** including a team member already working on the issue with internal details a contributor could not know. Ask in the issue first.

Sources: gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/public/docs/hackathon-rules.md@eddd645fba2ffe5a47bc2b4655ab5cbd31ea4554 ;
https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9900 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7612 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261288

## 9. Before you open an MR: the checklist this file implies

1. The issue is yours (assigned through the platform), free of competing MRs, and agreed if it is more than a clear bug fix.
2. The problem exists on the latest default branch.
3. You work from the community fork, on a dedicated branch, targeting the default branch.
4. The MR has commits, a filled description and one concern.
5. You request a human review once the pipeline is green or the failures are explained, and you answer within days.
6. If you stop, you say so and close with a reason.
