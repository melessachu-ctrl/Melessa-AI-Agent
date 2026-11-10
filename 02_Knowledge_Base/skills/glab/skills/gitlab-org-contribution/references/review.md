# Getting a review and answering it

Most GitLab-owned projects route community reviews through gitlab-bot
(gitlab-org/quality/triage-ops) and the contributor platform. This file covers
when to ask, how to ask, whom to ask, how to answer, and how the merge happens.
Project exceptions (projects with their own review process, projects that
require resolved threads, projects with their own sweepers) are in
references/projects/INDEX.md.

## Contents

- [1. Before you ask](#1-before-you-ask)
- [2. Asking with `@gitlab-bot ready`](#2-asking-with-gitlab-bot-ready)
- [3. Asking through the contributor platform](#3-asking-through-the-contributor-platform)
- [4. Choosing whom to ask](#4-choosing-whom-to-ask)
- [5. Right after asking: check reviewers and resolve your ready thread](#5-right-after-asking-check-reviewers-and-resolve-your-ready-thread)
- [6. Labels you can and cannot set](#6-labels-you-can-and-cannot-set)
- [7. Answering review](#7-answering-review)
- [8. Resolving threads and re-requesting review](#8-resolving-threads-and-re-requesting-review)
- [9. Approvals, merge trains and merging](#9-approvals-merge-trains-and-merging)
- [10. Waiting: the reminder schedule](#10-waiting-the-reminder-schedule)
- [11. What moves an MR and what does not](#11-what-moves-an-mr-and-what-does-not)

## 1. Before you ask

- **GitLab has processed your push.** The MR's Changes tab shows your diff and the new head commit (through the API, the MR's diffs list your files and `sha` matches your branch head; the MR's `sha` can lag the fork branch by a little). A ready note posted earlier is answered "this merge request currently contains no changes ... We will wait 5 minutes before assigning a reviewer"; five minutes later a job only marks the MR ready and adds `workflow::ready for review`, and **nobody is asked to review** (enforced), except on an MR that changes docs and already carries `Community contribution`, where the documentation automation reacts to the label the job adds, as to any other addition of it (section 4), and requests the owner the page's CODEOWNERS line names within seconds (enforced; observed, 2: gitlab-org/gitlab!263078 and !261522, 2 of the 3 MRs answered "no changes" among the 100 latest docs-only community MRs in gitlab-org/gitlab, opened 8 to 24 October 2026). If that happened, check Reviewers, then post `@gitlab-bot ready @<reviewer>` again (on a docs-only MR only if no docs owner was requested) as soon as the Changes tab shows your head commit and gitlab-bot's welcome note is there (next bullet): the hourly limit is counted separately for a ready posted with no diff and one posted with a diff, so it does not hold you back. Then resolve both the "no changes" reply and the new ready thread (section 5). The platform's Request review (section 3) works as well: the people you tick or type are requested by its own `/request_review`, which no hourly limit counts, and if you include GitLab Duo, its hidden ready follows the same diff and hourly rules as a typed one. If a push does not show up in the MR at all, force-push the branch one commit back and then the real head again (pushing the same commits again changes nothing), check the Commits tab, and never push an empty commit (observed, 1).
- **gitlab-bot's welcome note is there.** It adds `workflow::in dev`, and a scoped label replaces any other with the same key, so a ready processed before the welcome note loses its `workflow::ready for review` a moment later. The reviewers it names are still requested, but the MR then stays in `workflow::in dev`, and the reviewers' 7-day reminder (section 10) looks only at MRs labelled `workflow::ready for review` (enforced; observed, 4: on gitlab-org/gitlab!263037 the ready came 3 minutes 40 seconds after the MR opened, its label at 18:29:52 UTC, and the welcome note replaced it at 18:29:53; the same happened on !259375, !260638 and !255300). A ready posted before the welcome note can also keep its label, as on gitlab-org/gitlab!263025, where its label landed half a second after the welcome's `workflow::in dev`, so either order can happen and only waiting is safe. Wait for the note itself, whose body starts with `<!-- triage-serverless ThankContribution -->`, not for the `Community contribution` label: gitlab-bot can add that label before the note, while `workflow::in dev` comes with the note (observed, 2: 18 seconds before the note on gitlab-org/gitlab!263025, almost three minutes before it on !255702). In gitlab-org/gitlab the welcome note usually comes four minutes or more after the MR opens (124 of the 167 MRs labelled `Community contribution` opened from 13 to 21 October 2026 that got the note, 119 of the 139 from the community fork; the longest more than an hour), in gitlab-org/cli within seconds (the 40 most recent, opened 11 to 21 October 2026, all within 14 seconds) (observed, 207). If no note has come about 70 minutes after the MR opened, request review anyway: the longest wait seen was 66 minutes, and 5 of those 172 gitlab-org/gitlab MRs got the `Community contribution` label but no welcome note at all (observed, 172); if the note comes later, add the label back as below. If your ready came first, add the label back in a new note, `@gitlab-bot label ~"workflow::ready for review"`, which the label command accepts (enforced; section 6), rather than with a second ready, which the hourly limit counts and which requests the reviewers again; then check Reviewers (section 5). On an MR that changes docs, the label added back also brings the documentation automation's writer request (section 4; it adds the writer beside the reviewers already listed, because the automation merges its pick into the reviewers the label event carries; only a ready that adds the label itself loses the reviewer it names) (enforced; observed, 1: gitlab-org/gitlab!260638, where the label came back 4 seconds after the note and a writer was requested 7 seconds later, beside the code reviewer).
- **The pipeline is green, or each failure is explained** in one comment with the job link, the error line and why it is not your change (documented in gitlab-org/gitlab's code review guide; observed, 25).
- **You have read your whole diff**: no unrelated changes, no debug code, comments only for the non-obvious why. In gitlab-org/gitlab the guide also asks authors to add diff comments on decisions, trade-offs, new libraries and benchmarks, and to say which domain each reviewer should cover (documented).
- **GitLab Duo's comments, if any, are dealt with**: fixed, or answered in their threads (documented in the code review guide; the platform's request note invites you to address them, section 3).

Sources: gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:triage/job/mark_ready_for_review_job.rb@46a4823632f3401513d233b99137d836d520e2ad ;
gitlab-org/quality/triage-ops:triage/processor/community/thank_contribution.rb@c906e23708bdde2d653a931d235d77e65ef935ca ;
gitlab-org/quality/triage-ops:policies/community/hygiene/ping-inactive-reviewers.yml@e0f9071dc93f7668929e346b32801ba1f5d31f1a ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_label.rb@46a4823632f3401513d233b99137d836d520e2ad ;
gitlab-org/quality/triage-ops:triage/processor/community/automated_review_request_doc.rb@57fab1afd23617b35a9be9e7fbc79357361ea542 ;
gitlab-org/quality/triage-ops:triage/triage/reaction.rb@839eee7fc991f240c66053781c01d6754db849c7 ;
gitlab-org/gitlab:doc/user/project/labels.md@cba47cde93b86827b9f5fa1d8de324d91c3451c2 ;
gitlab-org/gitlab:doc/development/code_review.md@46d16a140c38dc174e76b67c6eded0dc859c80a8 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260276 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/255704 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263037 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/259375 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260638 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/255300 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263025 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/255702 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263078 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261522

## 2. Asking with `@gitlab-bot ready`

When the person acts in a browser, the contributor platform's Request review
(section 3) comes first. The command keeps working and is the path an agent
can run; where it and `@gitlab-bot label` are heading is in
references/bots.md, section 1 (Commands).

Write a normal comment whose line **starts** with the command:

```text
@gitlab-bot ready @<reviewer>
@gitlab-bot label ~"type::bug" ~backend
Short sentence saying why you picked this reviewer.
```

Rules (all enforced by triage-ops unless marked):

- **Start of a line, one command per line.** Arguments are read from that line only, and every `@word` on it becomes a requested reviewer, punctuation included. Names on the following lines are ignored, and the bot then picks someone at random (observed, 6). A `@gitlab-bot label` line in the same note runs too, as in the example above, since each command reads the first line that starts with it (enforced; observed, 3; references/bots.md, section 1).
- **Aliases**: `@gitlab-bot review` and `@gitlab-bot request_review` (underscore). The hyphenated `request-review` that some docs list matches nothing; trust the code.
- **Quoting a command in prose**: put it in backticks inside a sentence and never at the start of a line, or the bot runs it. A hidden HTML comment containing the command on its own line does trigger it.
- **Who can run it**: the MR's author, an assignee, a reviewer, a GitLab team member or a member of the community forks group. Others are ignored silently.
- **Once per hour per MR** for a non-member, counted for the note's author. A second ready by the same author on the same MR within the hour, with the diff in the same state, is ignored without any reply by the bot process that counted the first one. A ready posted before the diff existed does not use up the next one (the limit's key includes whether the diff exists); see section 1 for what to do then. The count is kept in the memory of each bot process, so a repeat within the hour is sometimes answered after all: read neither outcome as proof, and check who was asked instead (section 5) (enforced; observed on 2026-10-20 with the platform's hidden ready: 6 repeats within the hour, 3 answered).
- **What it does**: removes a leading `Draft:`, `[Draft]`, `(Draft)`, `WIP:`, `[WIP]` or `(WIP)` in any case, adds `workflow::ready for review`, removes `automation:author-reminded`, requests the reviewers you named (keeping the ones already on the MR, so a read-back finds the person you named beside the earlier reviewers, not in their place; observed, 2: gitlab-org/fleeting/fleeting!149 and gitlab-org/gitlab-runner!7554), re-requests any of them who already are reviewers, through the same GraphQL mutation as section 8, which removes an approval they had given, and replies **inside your note's thread** with a note asking the reviewer whether they have capacity and reminding them that the group's product manager should validate the linked issue.
- **Without names** it re-requests the current reviewers (GitLabDuo excluded), approvers included, so after an approval a bare ready removes it; if there are none, it picks the project reviewer or maintainer with the lowest review load from reviewer roulette data, and only then a random available merge request coach, except on a docs-only MR whose pages a docs section of CODEOWNERS gives an owner: there it requests nobody and posts no reply, and the documentation automation requests that owner only when that ready is what adds `workflow::ready for review` to an MR that already carries `Community contribution`; while the label is already set, a bare ready requests nobody at all (sections 4 and 5). Naming someone is better: bot picks are often coaches or people outside the area who hand the MR on, which costs days (observed, 25 hand-offs).
- **Projects with their own review process** (gitlab-org/security-products/gemnasium-db, gitlab-org/gitlab-environment-toolkit, gitlab-org/quality/performance and the Distribution team's projects, which include omnibus-gitlab and charts/gitlab): the command only marks the MR ready and adds the label; it requests nobody, even with names, and posts no reply (observed, 82 such ready notes). There, use the contributor platform's request-review link or the process in the project's CONTRIBUTING or Danger comment. Danger's own text in charts/gitlab suggests `@gitlab-bot ready @user`; that advice does not work there. In omnibus-gitlab it asks, since 2026-10-20, to mark the MR ready and request a reviewer, which a contributor without a role does through the platform's link.
- **Do not use it to bump a draft** you want to keep as a draft: it marks the MR ready.

Mentioning a person or a group in a plain comment does **not** request a
review or set the label, and MRs whose only "request" was such a mention were
nudged and closed as never sent for review (enforced through the court rules;
observed, 40).

Sources: gitlab-org/quality/triage-ops:triage/triage/reactive_command.rb@4b4887e0e83f5eb4f60cbdfc401a1980ecaf079b ;
gitlab-org/quality/triage-ops:triage/processor/community/community_processor.rb@8765efcd87e41a34061c6c2e36596d19109e4f06 ;
gitlab-org/quality/triage-ops:triage/triage/rate_limit.rb@4df1365aadbd941540698b83edbbb9c9deeef47a ;
gitlab-org/quality/triage-ops:triage/triage.rb@f41b7365c9862046b4e883a641bf374bcbd0c65c ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:triage/triage/reaction.rb@839eee7fc991f240c66053781c01d6754db849c7 ;
gitlab-org/quality/triage-ops:triage/triage/api_strategy/graph_ql.rb@70b7dad825b2d659a6954297ab74dd587097b000 ;
gitlab-org/gitlab:app/services/merge_requests/request_review_service.rb@8c5023ca3803ed42b32430c337113e405f48f98e ;
gitlab-org/quality/triage-ops:lib/www_gitlab_com.rb@128ac6f35a825526138ee450eec06a321ef41b8a ;
gitlab-org/quality/triage-ops:REACTIVE.md@f98daef9c5fc51dac669759f7b6c783c6147aae1 ;
gitlab-org/omnibus-gitlab:danger/reviewers/Dangerfile@9c46e0db717676530c4bb48ea7847901bfb300d2 ;
gitlab-org/charts/gitlab:danger/reviewers/Dangerfile@0e197e8dd43ce45272394f2f03d7654f28b0365d ;
https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5458 ;
https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/merge_requests/7175 ;
https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/merge_requests/7558 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/259961 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/258026 ;
https://gitlab.com/gitlab-org/fleeting/fleeting/-/merge_requests/149 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7554

## 3. Asking through the contributor platform

`https://contributors.gitlab.com/manage-merge-request?action=review&projectId=<id>&mergeRequestIid=<iid>`
(linked from gitlab-bot's welcome note and nudges) has three actions: Request
review, Help and Label (enforced).

- **Filling in the link.** `<id>` is the canonical project's numeric id: the `id` field of `GET https://gitlab.com/api/v4/projects/<URL-encoded full path>`, which answers without a token for a public project, or **Copy project ID** in the **Actions** menu of the project's overview page (documented). `mergeRequestId=<the MR's global id>` (the MR's `id` field in the API) can replace both `projectId` and `mergeRequestIid`; the page takes no project path. `action=review` opens Request review, `action=help` the Help action and `action=label` the Label action; with no `action`, Request review and Help are open (enforced).
- **Request review** starts a thread from the contributors.gitlab.com account that runs `/ready`, `/label ~"workflow::ready for review"` and `/request_review` for everyone you tick or type: the current reviewers (to re-request them), the platform's suggested reviewer, GitLab Duo, and any usernames you enter, one per line, up to four people besides Duo. The suggestion comes from available team members with review capacity for the project, preferring reviewers and trainee maintainers, and falls back to a random available coach (enforced).
- **What is ticked for you.** The page ticks nothing when the MR already has reviewers other than Duo and you, and otherwise ticks GitLab Duo alone until Duo has reviewed and the suggested reviewer alone after that; this is the build deployed on 2026-10-27 (v2.276.0), while builds up to v2.274.0 ticked Duo together with the current reviewers and never the suggested reviewer. The platform requests only the people ticked or typed when you submit, and never adds a person later on its own (enforced).
- With Duo included, the note also carries a hidden `@gitlab-bot ready @GitLabDuo` line and reads: "Please review all feedback from `@GitLabDuo`: apply the suggestions you're confident about, and leave a note on any you are unsure or disagree with. Then, request a review from the suggested reviewer." With only Duo ticked, its greeting to the reviewers reads "Hey  :wave:" with no names: harmless, and no person was requested. It still starts "Hey @<you>, thanks for requesting a review!", which is how section 5 finds it, and gitlab-bot answers inside its thread ("`@GitLabDuo`, this Community contribution is ready for review"), so resolve the thread once nothing in it is pending (enforced; observed, 2 live notes: gitlab-org/gitlab!265240 and !266340). gitlab-org/gitlab's code review guide asks authors to address all Duo comments before requesting human reviewers (documented), so deal with them rather than wait, then request the human you chose (next bullet). Reviews requested this way ran 223 times and failed 4 times (observed, 223).
- **Then request the human you chose** (section 4): open the page again, untick Duo if it is ticked, and the suggested reviewer if it is ticked and you chose someone else, type the username and submit. A request without Duo carries no hidden ready, so no hourly limit applies to it. Alternatively, post `@gitlab-bot ready @<reviewer>`: the hourly limit is counted for each note's author, and the hidden ready is posted by the platform's account, so it does not use up yours (enforced). Until a person is in Reviewers, the MR stays in your court (references/why-mrs-get-closed.md, section 2).
- The hidden command behaves like a typed one posted by the platform's account: the diff must be processed, and the hourly limit counts it for that account, so a second request with Duo on the same MR within the hour may bring no Duo request and no reply from gitlab-bot (enforced; observed, 3). A "no changes" answer to it is addressed to that account, not to you (enforced). Either way the people you ticked or typed were requested by the platform's own `/request_review`, and the thread is yours to resolve once nothing in it is pending (section 5; observed, 16).
- On a draft it marks the MR ready as a side effect (observed, 1).
- **Help** starts a thread asking the chosen reviewer or coach to help you and requests their review; add the context about where you are stuck in that thread (enforced).
- Check the ticks before you submit: every request adds everyone ticked. Where the suggestion is ticked by default (builds before May 2026 ticked the suggested coach, and the current build ticks the suggested reviewer once Duo has reviewed, on an MR with no other reviewer), repeated requests that kept it each added another platform-picked reviewer (observed, 2).

Sources: gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_merge_request_controller.rb@a8b2e17709713e9b4c5cf18dc12c7dac7dc56d4e ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/pages/ManageMergeRequestPage.vue@805fcff1ef8265fafe18aa2ae4cf9dbdc6179d0a ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/pages/manage-merge-request-page/RequestReviewAction.vue@840936a0d635a76536946883caa39b6567439d05 ;
https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/releases/v2.274.0 ;
https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/releases/v2.276.0 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/265240#note_4110587430 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/266340#note_4119993882 ;
https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/commit/8e453a4a28dac0ecba2491ed0ef7a4416c6d1382 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/lib/review_capacity_picker.rb@9ef430566acda40d0b41a0e619e9ac6780ef98bb ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:triage/triage/rate_limit.rb@4df1365aadbd941540698b83edbbb9c9deeef47a ;
gitlab-org/gitlab:doc/development/code_review.md@46d16a140c38dc174e76b67c6eded0dc859c80a8 ;
gitlab-org/gitlab:doc/api/projects.md@a2ea8aaf67d442b6c89e85a0a417cac11ba6e5f1 ;
gitlab-org/gitlab:doc/user/project/working_with_projects.md@d6ecb05e0eee9cb798597b1d0808d22759f5c75d ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261343 ;
https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/merge_requests/3236 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3149 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/258026 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/259961

## 4. Choosing whom to ask

Never guess a name, and never write a sample or example username in your answer, even to illustrate: a username in the text reads as a real recommendation. Keep `@<reviewer>` as a literal placeholder and tell the person to fill it from CODEOWNERS for the paths they changed where it names a person, otherwise from the roulette or the file history, as the project file says. Build a short list from evidence, then pick the strongest
candidate who is available:

1. **CODEOWNERS** (often `.gitlab/CODEOWNERS`): the most specific line matching each path you changed. Some sections make a code owner's approval required, so a reviewer who is also a code owner saves a round (documented). Once the MR exists, `GET /projects/:id/merge_requests/:iid/approval_state` lists each of its approval rules with the users who can meet it (`eligible_approvers`), so you can check a candidate against the rules still open; for a code owner rule that names a group the list can come back empty to an account without a role (documented; observed, 2 MRs in gitlab-org/security-products/analyzers/dependency-scanning).
2. **Danger's reviewer roulette comment**: one random available reviewer and maintainer per category, never the author, with each person's time zone relative to yours. It does not notify anyone, and it exists only once Danger has run on the MR (on gitlab-org/gitaly!9445 it came about a minute after the MR opened), so where Danger runs on your MR's pipeline, read it before you choose; where the project file or references/bots.md, section 2, says Danger does not run on fork pipelines, read the roulette data yourself (Reading the roulette data from a script, below). How strongly to hold to its picks is each project's rule, and whoever you ask instead, say why (both in Say why, below). In gitlab-org/gitlab, documentation, changelog, feature flag and database changes have no roulette row: docs go to the owner the page's `[Documentation Pages]` line names, usually a technical writer (Specific cases below), and database changes get a separate database review section with a suggested database reviewer and maintainer. Some gitlab-org/gitlab MRs show only a maintainer column (an experiment) (enforced). A required CODEOWNERS approval rule gets a row of its own there, except in the sections gitlab-org/gitlab's Dangerfile excludes: `[Maintainers]`, which the category rows cover, `[Database]`, `[Analytics Instrumentation]` and `[Advanced Search Migration]`. An optional section gets a row only where the Dangerfile includes it, as it does `^[Backend Static Code Analysis]`, and a `*` line outside any section never does. Danger picks the row's person from the rule's `eligible_approvers` who have a roulette entry for the project and are available, other than the author, and when that finds nobody, from any eligible approver, available or not (enforced).
3. **The stage or group label** on the issue, or the `feature_category` of the code you touch, and that group's handbook page (observed, 3).
4. **The history of the touched files**: who authored, reviewed or merged recent changes (`merge_user` on recent MRs that touched them; `merged_by` is its deprecated twin) (documented; observed). Where CODEOWNERS names only a group, the MR that added or last changed the function you fix is the strongest evidence: `git log -S'<function>' -- <file>` finds the commit, and `GET /projects/:id/repository/commits/<sha>/merge_requests` returns the MR that introduced it, with its merger and reviewers (documented; observed, 1: the ready of gitlab-org/gitlab!264894 names the merger of the MR that added the function). The roulette does not list everyone who merges: of the 19 people who merged the last 100 merged gitlab-runner MRs (read 2026-10-26), 2 had only a `reviewer` or `trainee_maintainer` entry for it and 4 had none, so for who merges, read `merge_user` (observed). It carries the account's `state`, so the MR list shows without a token whether the person who merged still has an active account: prefer one that reads `active`, and check the account and its membership before you name someone from the history (Does the account still hold the role, below) (documented).
5. **Reviewers of similar merged MRs** in the project (observed, 25).
6. **The handbook's Engineering Projects page** (https://handbook.gitlab.com/handbook/engineering/projects/), for a project the roulette does not cover: it lists each project's maintainers and reviewers, built from the team members' YAML files (`data/team_members/person/*`), which the handbook's code review page names as where to find a reviewer (documented; observed, 1: on gitlab-org/ruby/gems/semver_dialects!130 a ready to a maintainer it lists was answered within three hours by a hand-over to the other one it lists; not merged on 2026-10-26).
7. **The platform's suggested reviewer** (capacity-based) when nothing above gives a candidate.

Then, for the candidates on that list:

- **Is the candidate available?** Before you name someone:
  1. Read their GitLab status and its Busy badge:
     `GET /users/:id_or_username/status`, which needs no token, gives
     `availability` (`busy`) and `clear_status_at`. Check too whether the bot
     recently posted that they "currently have N active review requests".
  2. Read their entry in the roulette data (next bullet): `out_of_office`,
     `has_capacity` and `available`.
  3. Read both again right before you post the ready.
  4. Tell the person you work for what they show: away (`out_of_office`
     true), at capacity, or busy until `clear_status_at`. On the MR, say no
     more than section 10 does when it offers someone else.

  Prefer a candidate without the Busy badge, and name a Busy person only when
  their status message says they take this kind of review (documented: the
  handbook's availability definition; the exception observed); prefer
  someone with fewer open review requests (documented: the handbook's review
  load and the code review guide's Review Workload Dashboard; observed); and
  prefer someone active in recent weeks over an old roster entry (observed,
  4). What the reads mean:
  - The roulette skips people whose status says `OOO`, `PTO`,
    `Parental Leave`, `Friends and Family` or `Conference`, and people at the
    review capacity they set with a number status emoji (documented).
    GitLab's Busy badge is not among them: in the data read on 2026-10-26, 35
    of the 138 entries whose status is Busy read `available: true`, so a
    Danger pick can carry the badge, while the handbook's maintainer demand
    dashboard defines availability as the time maintainers are "accepting
    reviews, and not busy, out of office, on vacation, or at capacity"
    (documented; observed).
  - In the roulette data, `out_of_office` true means away, and can read so
    while the GitLab status is empty; `has_capacity` false means their
    `gitlab_mrs_awaiting_review_count` has reached `assigned_max_capacity`
    (20 by default; a `two` to `eight` status emoji sets that number, and
    `zero`, `one`, `red_circle` and `bulb` all read 2 in the data read on
    2026-10-24); and `available` is false in either case. So a person with
    `available` false and `out_of_office` false is at capacity, not away:
    they still review, slowly, and a reminder to them should offer someone
    else (section 10) (documented; observed in the data read on 2026-10-22:
    146 of 570 entries at capacity, 101 away).
  - Availability moves within hours, which is why step 3 reads again: between
    two reads 75 minutes apart on 2026-10-26 `available` changed for 11 of
    568 entries, and for 17 between two reads nine hours apart on 2026-10-24
    (observed, 4 reads).
  - For a person's open review requests across GitLab,
    `GET /merge_requests?scope=all&state=opened&reviewer_username=<name>`
    lists them (documented). It counts every open MR that names them as a
    reviewer, those they already reviewed or approved included, so it reads
    higher than `gitlab_mrs_awaiting_review_count` in the roulette data
    (observed, 2).
- **Reading the roulette data from a script.** The data is
  `https://gitlab-org.gitlab.io/gitlab-roulette/roulette.json`, which needs no
  token, and not every team member has an entry in it (observed). A person's
  `projects.<project>` value there is a string for one role, a list for
  several, and absent for none (for `gitlab` on
  2026-10-26: 161 strings, 243 lists and 164 absent of 568 entries), and Danger
  reads both forms alike (`Array(capabilities)`), so normalise before you
  filter, for example
  `(.projects.gitlab // []) | if type == "array" then . else [.] end`. A
  category's own spin picks a person only when that list holds the exact
  element `<role> <category>` (`reviewer backend`, `maintainer frontend`,
  `trainee_maintainer backend`), or the bare role in a project without
  categories (gitlab-runner's read `maintainer`, `reviewer` or
  `maintainer docs`). Two categories match differently: for `tooling` a
  reviewer also matches with `reviewer backend`, and for `ux` the entry must
  also match one of the MR's `group::` labels through the person's group
  (`specialty`). The job title (`role`) plays no part. When a category's own
  spin finds nobody, Danger fills the slot from elsewhere: an empty reviewer
  slot takes another of the category's maintainers when it has more than one;
  `tooling` and `ci_template` take the backend maintainer,
  `analytics_instrumentation` the backend or else the frontend maintainer,
  `qa` and `test` the backend reviewer, and the UX row of an MR labelled
  `Community contribution` a fallback reviewer the gem names, whatever that
  person's entry holds (enforced). gitlab-org/gitlab maps files to `tooling`,
  `ci_template` and `analytics_instrumentation`, and a community MR labelled
  `UX` gets a UX row (enforced). So a script that requires the category's own
  element, such as `maintainer tooling`, can rule out the person Danger
  picked. Match whole elements as Danger does: a substring test over-reads,
  since `trainee_maintainer backend` contains `maintainer backend` and
  `maintainer docs` starts with `maintainer` (enforced; observed). The data
  covers the projects that have a roulette configuration, so a maintainer of
  a smaller project can have no entry; then their GitLab status and their
  recent activity (`GET /users/:id/events`) are what you have (observed, 2
  projects).
- **Does the account still hold the role?** CODEOWNERS and a project's
  maintainer table can name someone who has left, whose account
  `GET /users/:id` (with a token; it answers 403 without one) shows as
  `blocked` and `GET /users?username=<name>` no longer returns. A review
  requested from such an account never comes, and the bot nudges a reviewer
  at most twice per request (section 10), so check the account before you
  name someone (documented; enforced). To check that a candidate holds a
  role, such as maintainer of an area, read the group's direct members
  (`GET /groups/:id/members/:user_id`), not `members/all`, which adds what a
  person inherits from parent groups: there every GitLab team member shows the
  Developer role in each `gitlab-org/maintainers/*` group (documented;
  observed, 3). Where CODEOWNERS names a maintainers group for the path
  (gitlab-org/gitlab's `[Verify]` section gives `/lib/**/ci/` to
  `@gitlab-org/maintainers/cicd-verify`), that group's direct members maintain
  the code (documented).
- **Say why.** Say in one line why you picked them: on its own line below the
  ready, since every `@word` on the ready line becomes a requested reviewer
  (section 2), or, after a platform request, which has no ready of yours, in
  a reply in its thread (section 3), before you resolve that thread
  (section 5). Give their own change to the file, function or field your MR
  fixes where they have one ("You reviewed and merged !<iid>, which moved
  ..."), otherwise the evidence that named them: the roulette, CODEOWNERS,
  the group's handbook page, the Engineering Projects page, a similar MR they
  reviewed, recent merges in the project, or the platform's suggestion. Never
  write a link to a change you have not found. A reason that points at their
  change to the code works better than their area or group (observed, 18;
  three readies worded so were reviewed and merged within two days:
  gitlab-org/cli!4211 and !4201, gitlab-org/gitlab!264946). The code review
  guide of gitlab-org/gitlab lists both among its ways to find a domain
  expert: the team members of the stage or group, and those who contributed
  to or reviewed the files (documented). How strongly to hold to the
  roulette's picks is each project's rule: Gitaly's `REVIEWING.md` says it is
  "generally recommended to assign these two" and "not uncommon to swap out
  one or two of them when: they are OOO; they know the context of the change
  already"; gitlab-org/gitlab's code review guide assigns domain experts
  first for code reviews and the roulette's pick for UX reviews, falls back
  to any team member or the roulette when no domain expert is available, and
  says "Override the suggestion if you know a better fit"; Danger's own text
  invites overriding it "if you think someone else would be better-suited"
  (documented). Give the reason whenever you name someone the roulette did
  not pick: on gitlab-org/gitaly!9445 a ready that named someone else without
  one drew the question why, quoted in
  references/projects/gitlab-org__gitaly.md (observed, 1).

Specific cases:

- **Technical writer** for gitlab-org/gitlab docs: read the page's `group:` front matter and the rake-managed block of the `[Documentation Pages]` section in `.gitlab/CODEOWNERS`, or the handbook's technical writing assignments for that group. For a docs-only MR, a bare `@gitlab-bot ready` skips the code reviewer and the documentation automation requests an owner of the page's most specific line in the `[Documentation Pages]` section, a technical writer for most pages. The automation acts only on an MR that already carries `Community contribution`, so a bare ready processed before gitlab-bot adds that label requests nobody and gets no reply; if you request review under the 70-minute rule of section 1 while the label is still missing, name the writer, `@gitlab-bot ready @<writer>`, whom the automation then leaves in place, since it does not react (enforced; observed, 1: on gitlab-org/gitlab!260638 `workflow::ready for review` came a second before `Community contribution`, and no writer was requested until the label was added back). Do not name a reviewer in the ready that adds `workflow::ready for review`: the command adds the label before it requests reviewers, so the automation, reacting to the label, sees no reviewer, requests its own pick and replaces the one you named a second later unless it picked the same person (enforced; observed, 1, gitlab-org/gitlab-runner!7661, an MR that also changed code; the gitlab-runner project file has the details). If the automation requests nobody, a new `@gitlab-bot ready @<writer>`, once the hourly limit allows (section 2), keeps the writer while the MR still has `workflow::ready for review`, since the automation reacts only when the label is added; a scheduled gitlab-bot job moves an MR with the label and no reviewer back to `workflow::in dev`, and after that a bare ready, which adds the label again, lets the automation request the writer (enforced; observed, 3 MRs that waited 10 to 12 days with no reviewer). See references/docs-style.md.
- **MRs that touch `doc/` and code**: when `workflow::ready for review` is added, the documentation automation requests the owner the page's CODEOWNERS line names, usually a technical writer, and on many MRs that request **replaced** the code reviewer you had just asked for. Check the Reviewers list a few seconds after gitlab-bot's own "requested review from" note (section 5) and ask for the dropped reviewer again; they are no longer listed, so the re-request in section 8 answers "Reviewer not found" for them (observed, 29 code MRs and 18 docs MRs in gitlab-org/gitlab; also seen in gitlab-runner). A file under `doc/` that a generator writes counts too: `doc/api/openapi/openapi_v3.yaml` after a change to a Grape endpoint's description, and `doc/auth/tokens/fine_grained_access_tokens_graphql.md` after a change to a granular token directive (`gitlab-org/gitlab:lib/tasks/gitlab/permissions/graphql/docs_task.rb@672fcb245fb315150aef1e0261744353f83289d6`), so expect it on any MR that runs those generators. The automation adds `documentation` and `tw::triaged`, posts "Please review this documentation merge request" and requests the owner; it means to add them beside the reviewers, but it merges with the reviewer list the label event carried, which can predate the request gitlab-bot made a few seconds earlier (a reading of the code, `gitlab-org/quality/triage-ops:triage/triage/reaction.rb@839eee7fc991f240c66053781c01d6754db849c7`). It does not act on an MR that carries a `tw::` label other than `tw::triaged`, nor on a ready that adds no `workflow::ready for review` because the label is already set (enforced; observed, 6 gitlab-org/gitlab MRs, among them !266340 and !266080, each replaced about five seconds after gitlab-bot's request). Do it through the platform's Request review (section 3), with only that person ticked or typed (with the writer listed the page ticks nothing; check that nobody else is): no hourly limit counts its `/request_review`, and the documentation automation does not act again, since `workflow::ready for review` is already set and it skips an MR that already has a CODEOWNERS writer as reviewer, so the writer stays and the reviewer comes back (enforced; observed, 6: on gitlab-org/gitlab!265240 the platform's request restored the code reviewer 52 minutes after the replacement, and the automation posted nothing more). An agent without the person's browser posts `@gitlab-bot ready @<reviewer>` once the hourly limit allows (section 2). The replacement had already notified the dropped reviewer, so say in the request's thread why you ask for them again (Say why, above).
- **Database review** (gitlab-org/gitlab): request it after the backend reviewer approves, from the database section Danger posts (documented).
- **UX review**: get the `UX` label on the MR (`@gitlab-bot label ~UX`); the bot pings the UX team and says so in a note. Do not mention individual designers (enforced).
- **Order** (gitlab-org/gitlab, documented): one reviewer per category first, then a maintainer once the reviewer approves; domain-specific approvals (authentication, authorization, database) before generic ones; small obvious changes may go straight to a maintainer. Do not request many reviewers at once (observed, 3).
- **If the reviewer says they are away, overloaded or not the right person**, ask the next candidate with `@gitlab-bot ready @<other>`; do not edit reviewers yourself. The first reviewer stays listed (section 2); a reviewer can drop themselves with `@gitlab-bot unassign_review` (enforced). Before time off, the handbook asks a reviewer either to leave a message on the MR with their dates and expected return or to reassign the review to another available reviewer, and it expects authors to find a different reviewer themselves when a status says out of office (documented; observed, 1: gitlab-org/editor-extensions/gitlab-lsp!4437, in its project file).

Sources: gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/simple_roulette/Dangerfile@a7e475f467e5845a85f6072fec72c17c26f5979e ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/plugins/roulette.rb@4cdeaf265d52797999ec1a6711ae346db29b7d66 ;
gitlab-org/gitlab:danger/roulette/Dangerfile@4f9fd1dd605c457a0360a34fb762c8abc987d431 ;
gitlab-org/gitlab:Dangerfile@4f9fd1dd605c457a0360a34fb762c8abc987d431 ;
gitlab-org/gitlab:tooling/danger/project_helper.rb@ad5810ae87e4dfe38868d677168a1974ec4e1b18 ;
gitlab-org/gitlab:danger/database/Dangerfile@46d16a140c38dc174e76b67c6eded0dc859c80a8 ;
gitlab-org/gitlab:doc/development/code_review.md@46d16a140c38dc174e76b67c6eded0dc859c80a8 ;
gitlab-org/gitlab:doc/development/database_review.md@46d16a140c38dc174e76b67c6eded0dc859c80a8 ;
gitlab-org/quality/triage-ops:triage/processor/community/automated_review_request_doc.rb@57fab1afd23617b35a9be9e7fbc79357361ea542 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:triage/processor/community/community_processor.rb@8765efcd87e41a34061c6c2e36596d19109e4f06 ;
gitlab-org/quality/triage-ops:triage/triage/event.rb@6bd2523b3119c773e34efa5075916f2d8c577b88 ;
gitlab-org/quality/triage-ops:triage/triage/reaction.rb@839eee7fc991f240c66053781c01d6754db849c7 ;
gitlab-org/quality/triage-ops:triage/processor/community/automated_review_request_ux.rb@728ed655b9caba94e74aa335b8af9abe00d96044 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_unassign_review.rb@46a4823632f3401513d233b99137d836d520e2ad ;
gitlab-org/quality/triage-ops:policies/community/hygiene/ping-incorrect-review-label.yml@544fa8e37d2617bd417500e18a55f1e6eeb1ec17 ;
gitlab-org/gitlab:app/services/merge_requests/request_review_service.rb@8c5023ca3803ed42b32430c337113e405f48f98e ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/259765 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7630 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7661 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/254538 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260638 ;
https://docs.gitlab.com/api/users/ ;
gitlab-org/gitlab:lib/api/users.rb@037fd3dec6a6786bf5f9b651cf4f1db70b7a094e ;
gitlab-org/release-cli:CONTRIBUTING.md@4531015db8ca916e93056024a1e0acd7af8f514c ;
https://docs.gitlab.com/api/merge_requests/#list-merge-requests ;
gitlab-org/gitlab:doc/api/merge_request_approvals.md@bd47f4ae8f76b64fac9c96b2179e399c37dcb83d ;
gitlab-org/gitlab:doc/api/group_members.md@77f956a112204b0a8f95d2ee05883bbc57fcda6d ;
https://gitlab-org.gitlab.io/gitlab-roulette/roulette.json ;
https://docs.gitlab.com/api/events/#retrieve-contribution-events-for-a-user ;
https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/639 ;
gitlab-org/gitaly:REVIEWING.md@145f8c0041a5d8201cb8eff97297fb7d94ecc49f ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/gitlab/dangerfiles/capability.rb@921f6da7e607f5cbcc3ab69b95197e4990d4eb61 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/gitlab/dangerfiles/teammate.rb@7301afcaf3696d03356ec1bd8e132ef9deefee74 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/gitlab/dangerfiles/spinner.rb@b605f866e0f1ee9dff7ea8cea85ccc41576100b7 ;
gitlab-org/gitlab:.gitlab/CODEOWNERS@8d29a90b562187afe47da25e6be78045bae0a383 ;
gitlab-org/gitlab:doc/api/users.md@037fd3dec6a6786bf5f9b651cf4f1db70b7a094e ;
gitlab-org/gitlab:doc/user/profile/_index.md@d5ce348a6db8f05b3415c4237154e5746339ff33 ;
gitlab-org/gitlab:doc/api/merge_requests.md@d1cd3e49cc14259dcb7cccc3f78d081a27fa34ea ;
gitlab-org/gitlab:doc/api/commits.md@a2ea8aaf67d442b6c89e85a0a417cac11ba6e5f1 ;
gitlab-com/content-sites/handbook:content/handbook/engineering/workflow/code-review.md@5f92de4547bca68f41f5ec784e621f097c1e8b38 ;
gitlab-com/www-gitlab-com:data/projects.yml@804f986e2374bf3259397981c3a4794f7d46ffcc ;
https://handbook.gitlab.com/handbook/engineering/projects/ ;
https://git-scm.com/docs/git-log ;
https://gitlab.com/gitlab-org/gitaly/-/merge_requests/9445#note_4081868717 ;
https://gitlab.com/gitlab-org/gitaly/-/merge_requests/9445#note_4085252467 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264894#note_4083804139 ;
https://gitlab.com/gitlab-org/ruby/gems/semver_dialects/-/merge_requests/130#note_4089595495 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/4211 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/4201 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264946 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/4437#note_4019992480 ;
gitlab-org/quality/triage-ops:triage/processor/community/automated_review_request_doc.rb@57fab1afd23617b35a9be9e7fbc79357361ea542 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/266340#note_4118153657 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/266080 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/266028#note_4111377132 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/266059#note_4112127163

## 5. Right after asking: check reviewers and resolve your ready thread

1. **Check who was asked, once the note has come.** The proof is a system note "requested review from @<name>" after your request, and that person in the Reviewers list. A platform request writes the note from the `contributors.gitlab.com` account within about a second of its thread; a typed ready gets it from gitlab-bot usually within seconds, but on gitlab-org/gitlab-runner!7661 it took 69 seconds, so give it two minutes before you read its absence as a failure, and on an MR that changes docs look again a few seconds after it (Who replaced whom, below); GitLab Duo, through the platform, gets its own from gitlab-bot, within about a minute (enforced; observed, 50). Three things prove nothing: the workflow label, which is set either way and which gitlab-bot can take back seconds later when no reviewer is listed; `detailed_merge_status`, which can stay `requested_changes` after a successful re-request, because GitLab records a reviewer's requested changes apart from their review state (after a platform request for a new Duo review it reads so until Duo approves, within six minutes on gitlab-org/api/client-go!3147); and a reply from gitlab-bot, which a platform request often does not get (enforced; observed: the label on 3 MRs, the merge status on 3, no reply on 21 requests). If Reviewers lists only GitLabDuo, no person was asked: request one (section 3).
2. **Know which thread your request made.** A typed `@gitlab-bot ready` is a standard comment until gitlab-bot replies inside it, which turns it into a resolvable thread that starts unresolved; where the bot posts no reply (a project with its own review process, a repeat within the hour that it does not answer, a bare ready on a docs-only MR that has no reviewer yet and whose pages a docs section of CODEOWNERS gives an owner, which leaves the request to the documentation automation's own note, section 4), it stays a standard comment and there is nothing to resolve (documented; enforced; the docs-only case observed, 1: on gitlab-org/gitlab-runner!7493 the documentation automation's note and the "requested review from" note for the writer came 9 and 10 seconds after the ready, and gitlab-bot did not reply to it). The platform's Request review is posted as a new thread, resolvable and unresolved from the start whether or not anyone answers. gitlab-bot replies in it only to the hidden Duo line, so a request without Duo never gets a reply, and one with Duo gets none on a project with its own review process, and often none on a repeat within the hour (section 2). A missing reply there is not a failure: the platform's own `/request_review` has already run (enforced; observed, 50 platform requests, all of them threads: 0 of the 21 without Duo and 26 of the 29 with Duo got a reply).
3. **Resolve it once nothing in it is pending.** As the MR's author you may resolve it without a role (documented). After a platform request, post the reason line first (section 4, Say why), then resolve: a reply in a resolved thread is created resolved (section 7). With Duo included, wait for gitlab-bot's reply or about two minutes; if a person replied in it, answer them first, since reviewers do discuss the change in the platform's thread (observed, 1). The MR reads `discussions_not_resolved` until you do, wherever the project requires resolved threads (enforced). In the corpus 337 ready notes became threads; some MRs that were otherwise ready sat unmergeable on them (observed, 337).
4. **Do the same for the other bot threads you have dealt with**: the type label nudge after the label is set, a Danger or database reminder after you replied with what you did (observed). A `@gitlab-bot label` note whose labels were all accepted gets no reply and stays a standard comment with nothing to resolve; gitlab-bot replies inside it only to refuse ("Could not add the following labels: ..." or "No labels specified"), which makes it a thread to resolve once you have dealt with the refusal (enforced; observed, 1: gitlab-org/gitlab!264217).

The same checks through the API, for an agent working with the person's token
(a mechanical how-to; `:id` is the canonical project's id or URL-encoded path):

- **Is the diff processed?** `GET /api/v4/projects/:id/merge_requests/:iid`: wait until `diff_refs.head_sha` equals your branch head and `changes_count` is not empty. Both are filled asynchronously after a push; `sha` can lag the fork branch briefly.
- **Who was asked?** `GET /api/v4/projects/:id/merge_requests/:iid/reviewers` lists each reviewer with a `state`, `unreviewed` after a request or re-request, and the reviewer's numeric id in `user.id`, which the re-request mutation takes (section 8); the `reviewers` array of the merge request shows who is listed but not the state. This endpoint only reads, and the REST API has no call that re-requests a review. The "requested review from" lines are the notes with `system: true` in `GET /api/v4/projects/:id/merge_requests/:iid/notes`, each with its author. A reviewer's `created_at` on the endpoint is the time of the first request: a re-request only sets that row back to `unreviewed`, so it does not move. Every request or re-request leaves its own "requested review from @<name>" note, signed by the account that made it: gitlab-bot for a ready, `contributors.gitlab.com` for a platform request, you for a re-request through the mutation or the sidebar (section 8), with "and removed approval" at the end for someone who had approved. To know when someone was last asked, read those notes, not `created_at` (enforced; documented; observed, 3: gitlab-org/gitlab-runner!7661, whose reviewer row kept its first `created_at` through a re-request a day and a half later, gitlab-org/fleeting/taskscaler!127 and gitlab-org/ai/skills!154).
- **Who replaced whom.** The documentation automation's replacement of a reviewer (section 4) is one system note signed by gitlab-bot, "requested review from @<writer> and removed review request for @<reviewer>", right after gitlab-bot's "requested review from @<reviewer>" (1.4 seconds after it on gitlab-org/gitlab-runner!7661, where that request came 69 seconds after the ready and the replacement 70). GitLab writes that combined wording for any one change of the reviewer list that adds and removes people, whoever makes it. A reviewer who hands the MR on either writes the same note under their own account when they add the next person (gitlab-org/ai/skills!168), or only removes themselves, which writes "removed review request for @<them>", and names the next person in a comment (gitlab-org/ruby/gems/semver_dialects!130, twice, the second time naming someone already listed as a reviewer). So judge it by the note's author and its time against the ready, read the comment beside a removal, and look a few seconds after gitlab-bot's own "requested review from" note, which can itself come a minute after the ready, not in the ready's first seconds (enforced; observed, 3 MRs in 3 projects).
- **Label changes are not notes.** A label that gitlab-bot or a person adds or removes shows up in `GET /api/v4/projects/:id/merge_requests/:iid/resource_label_events`, never among the notes, so a script that reads notes to see what changed since it last looked misses a relabel (documented; observed, 2 MRs: gitlab-org/gitlab!260459, gitlab-org/gitlab-runner!7628).
- **A mention writes a note on the other MR.** Naming another MR or issue (`!N`, `#N` or its URL) in a note or a description adds a system note "mentioned in merge request !M" to it, written as you, and only the first time that pair is mentioned. A script that reads the notes of !N must not take it for something you did there: skip `system: true` notes (enforced; documented; observed, 2: gitlab-org/gitlab-runner!7677 note 4081665158 came two seconds after !7679 note 4081665095 named !7677, and !7676 note 4055977973 five seconds after !7677 opened with !7676 in its description).
- **A title change's system note is HTML** (`<p>changed title from <code class="idiff">...`, the changed words in `<span>` elements), so a script matches it by `system: true` and that prefix, and reads the new title from the MR or issue itself (observed, 2: gitlab-org/api/client-go!3143, note 4081532499, and gitlab-org/gitlab-elasticsearch-indexer!972, note 4077475898). The push note's list of commits comes as HTML too (`<ul><li>...`). Its "added N commits" named each commit by its first 8 characters in notes up to mid-October 2026 and by its full SHA from about 2026-10-21. After a force-push that also moved the branch onto a newer default branch, N counts every target-branch commit between the old and the new base, summed up in one item (`<li>SHA...SHA - K commits from branch <code>gitlab-org:master</code></li>`) before your own commits: on gitlab-org/gitlab that is thousands, which you did not add. A script that waits for its push to show matches the first 8 characters of its commit in an `<li>` item, which fits both forms, or compares the MR's diff versions (observed, 4: gitlab-org/gitlab!265435, note 4118682102, "added 3463 commits"; gitlab-org/quality/triage-ops!4482, note 4092287899; gitlab-org/gitlab!260459 and !266046 for the two forms). Other answers that mislead a script reading before it writes, a `message` key read as an error, or an error body without one, and a repository tree path that answers `404`, are in references/troubleshooting.md, MR mechanics.
- **Read every page of notes.** The notes endpoint cuts the page first and then drops the notes the reader may not see, so a page can hold fewer than `per_page` notes while more pages follow. Follow the `Link` header's `next` (or `x-next-page`), which count the notes before that cut, or read until a page comes back empty; never stop at a short page (enforced).
- **Resolve your ready thread.** `GET /api/v4/projects/:id/merge_requests/:iid/discussions`, pick the discussion whose first note is yours and starts with `@gitlab-bot ready`, read its later notes, then `PUT /api/v4/projects/:id/merge_requests/:iid/discussions/<discussion_id>?resolved=true`. A platform request is instead the discussion whose first note is by `contributors.gitlab.com`, starts "Hey @<you>, thanks for requesting a review!" and whose raw body, as the API returns it, ends with `_Posted via [contributors.gitlab.com](https://contributors.gitlab.com)._`; a search for `@gitlab-bot ready` misses it. Its stored body no longer shows the `/ready`, `/label` and `/request_review` lines, which GitLab ran, while the hidden Duo line stays (observed). Do the same for the "no changes" reply and the other threads listed above.

Whether an unresolved thread blocks the merge depends on the project's "All
threads must be resolved" setting; it is on in many projects (cli, the
Terraform provider, the VS Code extension, gitlab-org/gitlab, labkit and others)
and off in some (the language server, gitlab-runner). Resolve your own anyway
(observed, 29 and 35).

Sources: gitlab-org/quality/triage-ops:triage/triage/reaction.rb@839eee7fc991f240c66053781c01d6754db849c7 ;
gitlab-org/quality/triage-ops:triage/processor/nudge_missing_auto_merge.rb@23d4c2e9c1b9e845a6ec007e5ee7e4da5cdac519 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_label.rb@46a4823632f3401513d233b99137d836d520e2ad ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_merge_request_controller.rb@a8b2e17709713e9b4c5cf18dc12c7dac7dc56d4e ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/services/gitlab/rest/notes.rb@86a13b160a682e964a6307a8c7d18074303deb57 ;
gitlab-org/gitlab:doc/user/discussions/_index.md@7887d944ac2c0765b3a11bfbc483d80e424f36cd ;
gitlab-org/gitlab:ee/app/models/ee/merge_request.rb@dd2f08701e6273a23be652b281dfd8693ad7e681 ;
gitlab-org/gitlab:doc/api/merge_requests.md@d1cd3e49cc14259dcb7cccc3f78d081a27fa34ea ;
gitlab-org/gitlab:lib/api/merge_requests.rb@c16019c127650c354f22b85712169c4a00bf40c5 ;
gitlab-org/gitlab:doc/api/discussions.md@7f3a60e01fa8dedda747ee9a41d1aac475422b21 ;
gitlab-org/gitlab:lib/api/notes.rb@f7682fd3f423bb94cb5f4d60bf05a15f180b31c0 ;
gitlab-org/gitlab:doc/api/resource_label_events.md@9b9b233e00be358ca28a554fb6699f1bb9ee1de8 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260459 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7628 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7493 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261343 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261260 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/4070 ;
https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9929 ;
https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/637 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263036 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263828 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/258026 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3147 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264217 ;
gitlab-org/gitlab:app/services/merge_requests/request_review_service.rb@8c5023ca3803ed42b32430c337113e405f48f98e ;
gitlab-org/gitlab:app/services/system_notes/issuables_service.rb@9592c3ab9972b721124fe9f9a9689120d1901728 ;
gitlab-org/quality/triage-ops:triage/processor/community/automated_review_request_doc.rb@57fab1afd23617b35a9be9e7fbc79357361ea542 ;
gitlab-org/gitlab:app/models/concerns/mentionable.rb@3338694ef27fee20cf525d744db0df7368d39bab ;
gitlab-org/gitlab:app/services/notes/post_process_service.rb@2b7f9ba865fae4980d90015ccba90725c3169173 ;
gitlab-org/gitlab:doc/user/project/issues/crosslinking_issues.md@5c0f47b000524aaca72f3259a95007ccb789eecf ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7661#note_4046243502 ;
https://gitlab.com/gitlab-org/fleeting/taskscaler/-/merge_requests/127 ;
https://gitlab.com/gitlab-org/ai/skills/-/merge_requests/154 ;
https://gitlab.com/gitlab-org/ai/skills/-/merge_requests/168 ;
https://gitlab.com/gitlab-org/ruby/gems/semver_dialects/-/merge_requests/130 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7677#note_4081665158 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7676#note_4055977973 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3143#note_4081532499 ;
https://gitlab.com/gitlab-org/gitlab-elasticsearch-indexer/-/merge_requests/972#note_4077475898 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/265435#note_4118682102 ;
https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4482#note_4092287899 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/266046

## 6. Labels you can and cannot set

- **`@gitlab-bot label ~"..."` and `@gitlab-bot unlabel ~"..."`** accept only: any `type::`, `bug::`, `feature::`, `maintenance::` or `group::` scoped label, any `Category:` label, and a fixed list (ActivityPub, automation:ml wrong, aws:first-review-approved, aws:second-review-approved, backend, Contributor Success, database, documentation, frontend, handbook, pipeline:run-all-jest, pipeline:run-all-rspec, UX, labels, merge requests, merge request widget, issues, issue list, the `workflow::` states blocked, in dev, ready for review, in review and complete, and the "reproduced on" labels). `security` can be added but not removed, and a `severity::` label can be added only while no `severity::` label is set, and not removed. Everything else (Hackathon, Community contribution, `docs::`, `component:*`, `devops::`, `section::`, pipeline tier labels, project labels) is refused with "Could not add the following labels"; ask the reviewer or let automation set it. It works on issues too (enforced).
- **Set a `type::` label early** (`type::bug`, `type::feature`, `type::maintenance`, with a subtype if the project uses them) with `@gitlab-bot label`; it routes the MR and feeds the changelog in some projects. If review changes what the MR does (a fix that becomes a removal or a refactor), change the label to match the same way: a scoped label replaces the one with the same key, so `@gitlab-bot label ~"type::maintenance"` takes the place of `type::bug` (documented). The bot's type label nudge is meant for MRs without `Community contribution`: it checks again five minutes after the MR opens and skips any MR that carries that label by then, so a community MR sees the nudge only when gitlab-bot's welcome note, which adds the label, came late (enforced for non-community MRs; observed, 7 MRs labelled `Community contribution`, 5 of them in 2026). If you get it, add the type label and resolve the nudge's thread yourself: once `Community contribution` is set the bot no longer collapses or resolves it (enforced).
- **Take the group label from the issue, CODEOWNERS or the code's `feature_category`**, not from a guess; it routes the MR to reviewers and the technical writer (observed, 14).
- **Check labels the AI labeller adds** ("We've attempted to automatically add labels") and correct wrong ones (enforced; observed, 401).
- **Milestones are not yours to set.** When timing matters (a version baked into the change), write the version you expect and ask the reviewer (observed, 51).
- **Reviewers and assignees are not yours to set either** without a role in the project: quick actions in a template or description are ignored, and the API drops `reviewer_ids` without an error (enforced). Ask with `@gitlab-bot ready @<reviewer>` (section 2) or the contributor platform (section 3).
- **Danger's "Labels missing: please ask a reviewer or maintainer to add ~X"** means Danger lacked permission on your fork MR. Add the allow-listed ones yourself; leave the rest to the reviewer; it is not a merge blocker (enforced).
- **Never automate or batch labels.** Label one merge request or issue at a time, each label chosen by someone who has read it and has the context to be accurate, whether through the platform's Label action or `@gitlab-bot label`. The community forks' Duo usage guidelines already rule out unattended or bulk agentic workloads for the complimentary Duo access (documented), and a pending change to the contributor platform's user guide and hackathon rules, not merged on 2026-10-21, bans scripted, automated or programmatic labelling, with a warning, then disqualification from events and possible removal from the community forks. An agent never uses the platform's Label action, never loops a label command and never posts one across several merge requests or issues; several labels on the one `@gitlab-bot label` line of a note, beside its ready line, are one command. It proposes a single label line for the person to check, and posts it only on the person's own merge request or issue (documented; the platform ban is pending, checked 2026-10-21).

Sources: gitlab-org/quality/triage-ops:triage/processor/community/command_mr_label.rb@46a4823632f3401513d233b99137d836d520e2ad ;
gitlab-org/quality/triage-ops:triage/processor/type_label_nudger.rb@9612ca345c694815694686033441dc31315e7b0f ;
gitlab-org/quality/triage-ops:triage/job/type_label_nudger_job.rb@cdb5156c2bddd18e9c4d8110ebc8aa52cf97e61d ;
gitlab-org/gitlab:doc/user/project/labels.md@cba47cde93b86827b9f5fa1d8de324d91c3451c2 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/254699 ;
gitlab-org/quality/triage-ops:lib/ai_triage_helper.rb@53f716ba08df079938bad29e6cfb865984b7b693 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/z_add_labels/Dangerfile@366450b0266e5e984eaa2f7e0d78402dca5c07e6 ;
gitlab-org/gitlab:app/services/merge_requests/base_service.rb@873fbd4864f0214c926d4de53f783a55c57c8f8b ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260305 ;
gitlab-community/meta:docs/duo-usage-guidelines.md@6f1c3fd623d90bdafdec81d8fd0977bf2dd03947 ;
https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2939

## 7. Answering review

- **Read the prefix on each comment.** Many reviewers use conventional comments (`issue`, `suggestion`, `nitpick`, `question`, `thought`, `chore`; `blocking` or `non-blocking`). Fix or answer every blocking one; apply non-blocking ones or say why not; offer a follow-up issue for points outside the MR's scope (observed, 16). Other reviews head each comment with a severity (`**Severity:**` High, Medium, Low or Nit) and the aspect reviewed (`**Lens:**`, for example Testing or Code Quality), say in the text when a point is optional, and can end in a "requested changes" review although every point is Low or Nit, which blocks the merge until that reviewer approves (section 8). Answer every point the same way, give the reason when you leave an optional one, and plan for a re-request and an approval round even when every open point is Low or Nit (observed, 8 MRs in 2 projects, from more than one reviewer: gitlab-org/gitlab-runner!7280, !7661 and !7676 to !7679, gitlab-org/step-runner!600 and !604; on gitlab-runner!7661 the reviewer approved and started the merge train after the fixes were pushed and the review re-requested).
- **Answer first, in at most five lines.** Start the reply with the answer (what you changed and the commit, or yes or no and the reason), then add only what the reviewer needs to check it; a log, a transcript or a long reasoning goes in a `<details>` block or a commit message, or is left out. Five lines is this skill's own ceiling. What it rests on is one maintainer who read a long reply as agent output and asked for less: on gitlab-org/api/client-go!3147 a maintainer called a 286-word reply hard to read, "very verbose (probably because you're having an agent help you ...) ... a little bit less may be more", and asked for "a concise implementation detail"; the answer that followed took 73 words in four lines (observed, 1: notes 4094024169 and 4094236255). For a description, this skill's own target is a visible part under 3,000 characters (references/commits-and-descriptions.md, MR descriptions).
- **Reply inside each thread**, not in a new top-level comment: what you changed and the commit (for example "Applied in <sha>"), or the evidence for not changing it. Answer every thread, Duo's and Danger's included. One summary comment does not replace per-thread answers (documented in gitlab-org/gitlab's code review guide; observed, 54). Through the API, a reply goes to `POST /projects/:id/merge_requests/:iid/discussions/:discussion_id/notes` with the thread's full discussion id; `POST /projects/:id/merge_requests/:iid/notes` starts a new top-level comment instead. Read the thread back after posting to check the reply landed in it (documented). A reviewer's standalone comment (`individual_note: true` in `GET .../discussions`) is not a thread and is the exception: answer it in a new top-level note that mentions its author, since a reply under it opens a thread that blocks the merge where threads must be resolved (section 8).
- **A reply inside a thread clears only that thread's To-Dos.** Mentions from other threads stay on your To-Do List, and so does every To-Do with no note behind it (`assigned`, `review_submitted`, `build_failed`), while a standalone top-level note (`individual_note: true`), a reaction on the MR, a push or an approval clears all of yours on the MR (enforced; observed, 1: on gitlab-org/security-products/gemnasium-db!57662 a reply cleared its thread's mention and a mention posted the same minute in another thread stayed). After you answer, read what is left (`currentUserTodos` on the MR) and mark done what your answers settled: a mention whose note you answered, a `review_submitted` once every thread of that review has your answer. references/troubleshooting.md, To-Do List, has the rules and the commands; never post a note only to clear one.
- **When a reviewer's point is about a failure path**, force that path once in a throwaway run before you answer, and say what happened with and without the change. When a test can reach only part of the path, name the part you could not test and why, rather than writing that no test reaches it (observed, 2: on gitlab-org/gitlab-runner!7677, note 4081717281, the replacement upload went to an address that refuses connections and the reply reports both outcomes; on !7679, note 4081666092, a new test covers the Azure case and the reply says the S3 case is untested because the S3 SDK in `go.mod` always returns the response type the check needs).
- **Read resolved threads too.** A reply posted in a thread that is already resolved is created resolved, so a reviewer's note added under your resolved ready thread arrives resolved and a search for unresolved threads misses it (enforced; observed, 1: gitlab-org/cli!4044, where the reviewer's "one suggestion" note landed there and the suggestion itself in a diff thread).
- **A push adds a system note to the threads on lines it changed.** When your push changes a line a diff comment is on, GitLab adds "changed this line in version N of the diff" inside that discussion, written as you, the pusher, with `system: true` and not resolvable; where the project resolves outdated threads automatically, the push also resolves the thread, so read `resolve_outdated_diff_discussions` in `GET /projects/:id` first, which answers it without a role (documented; checked 2026-10-22). The thread's last note is then that system note, not a reply: a script that reads the last note to tell whether the reviewer or you answered, or a guard that stops when someone else wrote in the thread, must skip system notes, or it stops after your own push (enforced; observed, 2: gitlab-org/cli!4044, and gitlab-org/gitaly!9445, where the push that answered GitLab Duo's finding wrote "changed this line in version 3 of the diff" into Duo's thread, note 4093370990). The push moves the other diff comments too: one on a line the push left alone moves to the new diff version, so its `position` then names the new head and, where lines above it changed, a new line number, while one on a line the push changed keeps the old version's position and becomes outdated. A reply posted in an outdated thread takes the thread's old position too. Identify a thread by its discussion id, never by its `position` (enforced; observed, 2: on gitlab-org/gitlab-runner!7661, note 4058569771, made on the first diff version, reads the third version's head, and notes 4060211688 and 4060211718, whose lines the third version changed, still read the second's; on !7678, in discussions 2cf4137d and 1ad19837, whose lines eb3d336e changed, every note, the replies posted after that push included, still reads head 887fcc21).
- **Submit your review** if you replied from the diff: pending review comments are visible only to you until you click Submit review or Add comment now (observed, 1).
- **Mention the reviewer in a new comment** when you need their action. Adding a username by editing an existing comment notifies nobody (documented; observed, 1).
- **Push review fixes as new commits** on top; rebase only when a reviewer asks, a conflict needs it or a failing job requires it. Reviewers read follow-up commits to see what changed (documented). Collect fixes into as few pushes as you can and run the formatters and linters first, because a push that changes the diff removes approvals, all of them or the changed files' code owners', as the project sets it (section 9) (observed, 9). After any rebase, compare the old and new head (for example with `git range-diff`) before pushing; a rebase once silently reverted three review fixes (observed, 1).
- **Review suggestions**: read them together before applying; overlapping suggestions make each other outdated, and batches have broken Markdown footnotes and blank lines. Use "Add suggestion to batch" and keep squash on where the project squashes, or apply them locally in one commit crediting the reviewer with a `Co-authored-by:` trailer. When you apply one by hand, a `suggestion:-2+1` block replaces the commented line together with the 2 lines above and the 1 line below it, so compare those lines of your edit with the block before you write that you applied it as suggested (documented). Where the project squashes, a trailer in a commit body reaches the default branch only if the squash commit template copies that commit's message: `%{all_commits}` copies every commit's, while `%{first_commit}` (gitlab-org/gitlab) copies the first commit's and `%{first_multiline_commit}` that of the first commit with a body, which references/commits-and-descriptions.md (Changelog entries) has you make the first commit, so under either of those a trailer on a later review-fix commit is lost, and where there is no template the squash commit is the MR title alone and keeps none; the `Co-authored-by` lines a template writes with `%{co_authored_by}` name the commits' authors, not reviewers credited inside them (documented; observed, 1: gitlab-org/gitlab-runner!7661, with the details in the gitlab-runner project file). Do not apply a wording suggestion to a generated file; change the source and regenerate (observed, 11).
- **Applying a suggestion in GitLab** writes the commit on your branch as you, from the web UI or through the API (`PUT /suggestions/:id/apply`, `PUT /suggestions/batch_apply`):
  1. Where squash is off, or every commit is linted (gitlab-org/gitlab-elasticsearch-indexer), give a commit message (`commit_message` through the API) in the project's form that keeps `%{co_authored_by}`; where only squash is off, turning it on first, where the project allows it, also works, unless the MR has to stay unsquashed for its `Changelog:` trailers (references/commits-and-descriptions.md, Squash, fixup and suggestion commits, and Changelog entries).
  2. If applying times out, check the branch first. When the commit is there, do not apply it again, and take that commit as the proof, since the suggestion can stay `applied: false` (observed, 1). Apply it again only when the branch does not have it.
  3. Wait as after any push (section 5, "Is the diff processed?"), fetch the branch, and confirm from the branch that the commit is there and, unless step 2 applied, from the thread that the suggestion reads `applied: true`, not from the API's answer.
  4. Run the project's formatter and linters on the result and push a fix if they change anything (gofmt broke on applied suggestions).
  5. Reply in the thread with the commit. The web UI resolves the thread for you; through the API, resolve it as the web UI does, unless the reviewers there resolve their own threads (section 8; the project file).

  Why: GitLab's policy checks only the right to push to that branch, not a role in the target project, while the API page lists the Developer, Maintainer or Owner role as a prerequisite (enforced; documented, with a difference between the page and the code). The commit's message is the `commit_message` you give, else the target project's own suggestion template, else GitLab's default; what each writes, the `%{co_authored_by}` credit included, and how Danger lints the commit are in references/commits-and-descriptions.md (Squash, fixup and suggestion commits) (enforced; documented). The web UI resolves each applied suggestion's thread with a second request after the apply; the API resolves nothing. It answers `200` with the suggestions as it loaded them before the apply, `applied: false` included, and a second apply is refused with "Can't apply this suggestion." (enforced; documented; observed, 2: gitlab-org/gitlab!264870 and gitlab-org/gitlab-elasticsearch-indexer!973). GitLab has then pushed to your branch: `detailed_merge_status` reads `preparing` until the new diff version exists, and the MR's `sha` and `diff_refs.head_sha` name the new commit only after that (3 seconds after the commit on !973, almost 4 minutes after it on !264870) (enforced; documented; observed, 2). For approvals it is a push like any other (section 9).
- **When a reviewer's suggestion conflicts with the project's written rules** (for example the docs word list or an API template), reply with a link to the rule and keep the documented form unless the reviewer confirms otherwise (observed, 3).
- **Keep scope.** When review reveals more pre-existing problems, offer a follow-up MR or issue instead of widening this one, then open it and link it in the thread (documented in gitlab-org/gitlab's code review guide; observed, 30).
- **When a reviewer hesitates over a behaviour change that no report asks for**, offer the smallest change that removes the defect and leaves every input that works today as it was, and leave the broader change for when users report the case. Once they agree, retitle the MR and rewrite its description for the narrower change (references/commits-and-descriptions.md, MR titles; MR descriptions): where the squash commit is the title, as in gitlab-org/api/client-go, the old title would become the commit on the default branch and the release-note line, and where the release type comes from the `type::` label, as there, change the label too if the kind of change moved (section 6) (observed, 1: on gitlab-org/api/client-go!3143 a maintainer, wary of changing the core client file without a failing case, note 4072353831, took the author's offer to narrow the MR to the panic alone, notes 4077839127 and 4080562310; the title and description changed with the narrowed commit, notes 4081532499 and 4081532500).
- **A file two of your MRs add byte for byte**, so that either can merge first: make a change a reviewer asks for in that file in both MRs at once, identical (`git rev-parse <branch>:<path>` gives the same blob id on each branch), or in neither, and say which in the reply. A change to one alone turns the second merge into an add/add conflict. If the other MR is already approved, set to auto-merge or on a merge train, a push to it aborts that merge and can remove its approvals, and section 9 says not to push after approval unless asked: change neither, say so in both MRs, and make the change once the other has merged, after rebasing the MR still open on the target branch, which then has the file, so that the change is an ordinary edit. Say in both descriptions that the file is shared, so the reviewer knows (enforced; observed, 1: on gitlab-org/gitlab-runner!7679 the reviewer, who had read it in the description, offered to leave an optional change to such a file for both MRs together, note 4077384472). When a reviewer offers two fixes and one of them changes the shared file, prefer the one inside a file only this MR has, and say why, so the shared file needs no change in either MR. Answer MRs that were reviewed together in the same round, and say in each reply what its change means for the others (observed, 1: gitlab-org/gitlab-runner!7677, note 4081717281, which kept the shared helper as it was, and !7679, note 4081668309).
- **Answers to several of your open MRs that change the same code** can make two of them conflict that merged cleanly before: a refactor one reviewer asked for can move lines another of your MRs changes. Before you push the answers, merge each pair of new heads without touching your worktree: `git merge-tree --write-tree --name-only <head1> <head2>` exits 0 for a clean merge and 1 for a conflict, and lists the conflicting files. Say in the reply which MRs now change the same lines and that you will rebase whichever merges second (documented, https://git-scm.com/docs/git-merge-tree; observed, 1: on gitlab-org/gitlab-runner!7679 the review commit 957603b8, which moved a check into a shared helper, made it conflict with !7677 in `commands/helpers/cache_extractor.go` where the heads before that round merged cleanly, and note 4081665095 says so).
- **An MR stacked on one in review** takes each commit you push to that MR for its review in the same round, and is rebased with `git rebase --onto` once that MR merges: references/commits-and-descriptions.md, Linking the issue, says how (enforced; observed, 1: gitlab-org/gitlab-runner!7677 carries the review commit of !7676).
- **When a reviewer agrees but asks to hear from others first**, prepare the change and hold the push until those people answer or the reviewer says to go ahead, and say in your reply that you are waiting for them; a push before that may have to be redone (observed, 1: gitlab-org/gitlab-elasticsearch-indexer!972, note 4067540267, where the reviewer chose removing the code over fixing it and asked to hear two people before acting on it). The same holds whenever a reviewer, approving or not, puts a question about your change to the maintainer or another person: it is theirs to decide. You may add facts you can cite, offered for that decision, but do not answer for them: when the reviewer's note is a standalone comment, put them in a new top-level note that mentions the reviewer and the person asked, not under the reviewer's note (section 8); when it sits in a thread (a diff thread, or a discussion that already has replies), add them in that thread. Do not re-request anyone else meanwhile. Check in `GET .../reviewers` that the person asked is listed and reads `unreviewed`, as after the hand-off on gitlab-org/gitlab-pages!1368; a mention alone requests nobody (section 2), so if they are not listed, ask for them once with `@gitlab-bot ready @<them>`, which requests only the people it names, so the approving reviewer keeps their approval (section 2). If they are listed but read `reviewed`, `requested_changes` or `unapproved`, the MR is not back on their list: re-request them once (section 8), which sets them back to `unreviewed` and gives them a to-do item. If they read `approved`, leave it at the mention, since a re-request would remove their approval (section 8) (observed, 2: gitlab-org/gitlab-pages!1368, where the reviewer approved, handed the MR back to the maintainer with two questions for them, a "requested review from" note followed and the maintainer read `unreviewed`, and the author's facts went in note 4065614223; on gitlab-org/api/client-go!3143 a maintainer who had not approved put a question to a code owner of the project's `*` rule, a listed reviewer reading `unreviewed`, in a discussion that already had replies, note 4072348543).
- **GitLab Duo threads**: answer in plain text without mentioning @GitLabDuo. Replies that mention it start a new Duo session and get "Failed to start the Duo workflow" (observed, 5). A reply that does not mention it starts no Duo session, so nothing answers it at once: it is read by the human reviewers who resolve the thread and by Duo's next follow-up review, which reads only its own threads and the replies in them and accepts a stated explanation (documented; references/bots.md, section 3). Write it for both, stating what holds and what you changed or kept and why, without thanking or addressing the bot. See references/bots.md.

Sources: gitlab-org/gitlab:doc/development/code_review.md@46d16a140c38dc174e76b67c6eded0dc859c80a8 ;
gitlab-org/gitlab:doc/api/discussions.md@7f3a60e01fa8dedda747ee9a41d1aac475422b21 ;
gitlab-org/gitlab:doc/user/project/merge_requests/reviews/suggestions.md@2ac227a86477a009d63100482dc997bbc832cbb2 ;
gitlab-org/gitlab:doc/user/duo_agent_platform/flows/foundational_flows/code_review/_index.md@80a8241c9b6b47980a23f939975a166fdd9aef81 ;
gitlab-org/gitlab:app/services/notes/build_service.rb@e85c10513144873f8ab3b9a274cf03b54e107b88 ;
gitlab-org/gitlab:app/services/system_notes/merge_requests_service.rb@b99595c49c6b0ad37b35aa0fbb89588af780c2e5 ;
gitlab-org/gitlab:app/services/discussions/update_diff_position_service.rb@e02aa23fe18d8bc6678db1b8a70ad8ea8bf48cbf ;
gitlab-org/gitlab:doc/api/projects.md@a2ea8aaf67d442b6c89e85a0a417cac11ba6e5f1 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/4044 ;
https://gitlab.com/gitlab-org/gitlab-elasticsearch-indexer/-/merge_requests/972#note_4067540267 ;
https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/1368#note_4065614223 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3143#note_4072348543 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3143#note_4080562310 ;
gitlab-org/gitlab:doc/user/project/merge_requests/commit_templates.md@ae75c0d973fefc2e7d0a10debe6dfff9f2432956 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7280 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7661 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7676 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7677 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7678 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7679#note_4077384472 ;
https://gitlab.com/gitlab-org/step-runner/-/merge_requests/600 ;
https://gitlab.com/gitlab-org/step-runner/-/merge_requests/604 ;
https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/637#note_4031282126 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7630 ;
https://gitlab.com/gitlab-org/container-registry/-/merge_requests/2828 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/255702 ;
https://gitlab.com/gitlab-org/ruby/gems/gitlab-exporter/-/merge_requests/104 ;
https://gitlab.com/gitlab-org/ai/lazy-mcp/-/merge_requests/54 ;
https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1554 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261547 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3041 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/255704 ;
https://git-scm.com/docs/git-rebase ;
https://git-scm.com/docs/git-merge-tree ;
gitlab-org/gitlab:lib/api/suggestions.rb@484303d89265c2781044e0907ffe97efcb31320e ;
gitlab-org/gitlab:app/services/suggestions/apply_service.rb@cff5dfe92383cc83abaab01220fd96e66028322e ;
gitlab-org/gitlab:lib/gitlab/suggestions/commit_message.rb@bcf22d692f2d994fa89dd9d151bca75b451b22c8 ;
gitlab-org/gitlab:app/assets/javascripts/notes/store/legacy_notes/actions.js@011359e1ff7085f267b70fec567f3a561bf367d6 ;
gitlab-org/gitlab:app/models/suggestion.rb@dbf2a80ac84437b6c877363fc26580556a0da97a ;
gitlab-org/gitlab:app/policies/suggestion_policy.rb@1c64a7a6f4e61ae7bc0d926cb19d1250af50df0e ;
gitlab-org/gitlab:doc/api/suggestions.md@bc7979c0dfd4b430b77b9e27ba0205249ede4ae7 ;
gitlab-org/gitlab:app/models/merge_request.rb@b30ae611be431291816fb70e6678d011dae4e6fc ;
gitlab-org/gitlab:app/services/merge_requests/mergeability/detailed_merge_status_service.rb@591f377197ad88c56177a5593ebfb279fe4ec8ec ;
gitlab-org/gitlab:doc/api/merge_requests.md@d1cd3e49cc14259dcb7cccc3f78d081a27fa34ea ;
gitlab-org/gitlab-elasticsearch-indexer:.commitlintrc.yml@f6cf341acfd000e5e5b948cfc393a61b6bf57adc ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264870#note_4089345065 ;
https://gitlab.com/gitlab-org/gitlab-elasticsearch-indexer/-/merge_requests/973#note_4085057210 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7677#note_4077383119 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7677#note_4081717281 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7679#note_4081665095 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7679#note_4081666092 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7679#note_4081668309 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7678#note_4077385817 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7678#note_4077385861 ;
gitlab-org/gitlab:app/services/todo_service.rb@67dccbf8b0e0af92d7375620c8c46dd42769f25a ;
gitlab-org/gitlab:app/finders/pending_todos_finder.rb@e6e1a52c017f7fbc22c60b13b9b99b2e13153d2c ;
gitlab-org/gitlab:app/graphql/types/current_user_todos.rb@d55c9d9b7666fba0312a01808ee8ee2269718b73 ;
https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/57662

## 8. Resolving threads and re-requesting review

- **On your own MR, resolve only threads you have fully addressed**, and leave open the ones that need the reviewer's decision. Some reviewers prefer to resolve their own threads after checking the commit; follow what they do in the MR (documented in gitlab-org/gitlab's code review guide; observed).
- **A reply under any standalone note turns it into a thread** that starts unresolved, whoever writes the reply: your answer under a reviewer's standalone comment, a member's reply under your own note (a pipeline explanation), a reply under a bot's standalone note. Where threads must be resolved, the MR then reads `discussions_not_resolved` until someone resolves it (documented; enforced; observed, 3: gitlab-org/api/client-go!3143, where the author's reply under a maintainer's standalone question did it, gitlab-org/gitlab-pages!1367 and gitlab-org/gitlab-runner!7630). So answer a reviewer's standalone comment in a new top-level note that mentions them, which keeps the MR mergeable (observed, 1, gitlab-org/gitlab-pages!1368), and add information to your own note the same way; if a reply must sit under the note, resolve that thread once it needs nothing more from anyone. A reply in a thread already resolved stays resolved (section 7). After any reply on an MR that was mergeable, read `detailed_merge_status` again. On an issue a reply under a standalone note makes a thread as well, but no merge waits on it there, so replying in place is fine (documented).
- **To thank a reviewer for a closing or approving comment**, add an award emoji to that comment, which adds no thread, and put any words of thanks inside a thread you are resolving anyway, such as the reply that names the commit of their suggestion (observed, 3: gitlab-org/gitlab!264870, note 4088789920 and the suggestion thread's reply 4089345065; gitlab-org/editor-extensions/gitlab-lsp!4437, note 4088393283; gitlab-org/ci-cd/docker-machine!201, note 4087891743).
- **After you push the changes a reviewer asked for, re-request their review.** Pushing alone, or a reply that mentions them, does not return the MR to them: neither changes any reviewer's state, other than the approvals a push removes (section 9) (enforced; observed, 1: on gitlab-org/gitlab!260459 a reviewer mentioned in a "ready for your re-review" reply still read `reviewed` 17 hours later). A re-request sets that reviewer's state back to `unreviewed`, gives them a to-do item and a notification, and adds a system note "requested review from @<name>" written by you (enforced). It needs only the right to update the merge request, which GitLab gives the MR's author and assignees, so a contributor with no role in the project can do it (enforced; observed, 1: on gitlab-org/gitlab!261933 an author with no role re-requested two reviewers and GitLab Duo). Editing the reviewer list is different: it needs a role, and the API drops `reviewer_ids` without one (section 6). Re-request a reviewer already listed who has reviewed, that is whose `state` in `GET /api/v4/projects/:id/merge_requests/:iid/reviewers` reads `reviewed`, `requested_changes` or `unapproved` (their approval was reset by your push or withdrawn; the sidebar shows them as Awaiting review, but the button is there). The state follows the reviewer's last review action, so one who withdrew an approval and then submitted a comment review reads `reviewed` (observed, 1: gitlab-org/gitlab!260459). After a push that changes the diff, read the states only after the "reset approvals" note, or about a minute (section 9): GitLab sets an approver whose approval the push removes to `unapproved` in the same job that removes the approval, so until that job runs they still read `approved` (enforced). Not one still `unreviewed`: they already have your request, GitLab's own button is hidden for them, and the mutation does not check the state, so it would only notify them again with a second to-do item and system note (enforced). A reviewer who only commented, without submitting a review, still reads `unreviewed` too, because GitLab changes the state only when a reviewer starts or submits a review or approves: mention them in your reply in their thread instead, or, for a standalone comment, in the new top-level note of section 7 (enforced; observed, 1, gitlab-org/cli!4044). Never an approver (next bullet), and never `duo-security-review-gitlab-org`, which team members request: once you have answered what you can see of its findings, ask the human reviewer to request it again (references/bots.md, section 3). Three ways to re-request:
  - **An agent: the GraphQL mutation.** The REST API has no re-request endpoint; it only lists reviewers, so a REST path guessed for it answers `404 Not Found` whoever calls it, and a `PUT` of the same `reviewer_ids` changes nothing (enforced). Take the reviewer's numeric id from `GET /api/v4/projects/:id/merge_requests/:iid/reviewers` (`user.id`), then run it with glab signed in, or with a token; either needs the `api` scope, since a `read_api` token is refused for any mutation:

    ```shell
    glab api graphql -f query='mutation { mergeRequestReviewerRereview(input: {projectPath: "<group/project>", iid: "<iid>", userId: "gid://gitlab/User/<id>"}) { mergeRequest { iid } errors } }'
    ```

    or send the same `query` as JSON in a `POST` to `https://gitlab.com/api/graphql` with the headers `Authorization: Bearer <token>` and `Content-Type: application/json`. Send one mutation per request, one request per reviewer: a document that holds two anonymous operations, such as two `mutation { ... }` blocks, fails validation as a whole and runs neither, because the GraphQL specification allows an anonymous operation only as the document's only operation (documented, https://spec.graphql.org/October2021/#sec-Lone-Anonymous-Operation). `<group/project>` is the full path of the project the MR targets (for example `gitlab-org/gitlab`), not your fork, and `<iid>` is the MR's number there. It worked when the response has no top-level `errors`, `data.mergeRequestReviewerRereview.errors` is `[]`, its `mergeRequest` is the MR (the payload's `iid` is its number), the reviewers endpoint shows that person `unreviewed`, and a new "requested review from @<name>" system note by you follows. A refusal, which a `projectPath` or `iid` naming no MR you may update also gets, comes back in the top-level `errors` array, "The resource that you are attempting to access does not exist or you don't have permission to perform this action", with `mergeRequestReviewerRereview` set to `null` (documented). `"Reviewer not found"` in `data.mergeRequestReviewerRereview.errors` means that person is not a reviewer (for example the documentation automation replaced them, section 4): ask for them with `@gitlab-bot ready @<name>` or the platform (sections 2 and 3) instead.
  - **A person: the Re-request review button** (the redo arrow) next to the reviewer's name in the Reviewers list of the right sidebar. GitLab shows it to the author for a reviewer who has reviewed (any state but `unreviewed`) and for one who approved. An author without a role sees it since gitlab-org/gitlab!261381 (merged 2026-10-13): the sidebar now asks for the right to update the MR, which the author has, where it asked for the right to administer it, so until then a contributor used the platform or the mutation. It is in the Reviewers list only: the approval rule rows of the reviewer drawer still ask for the admin right, so the icon stays hidden there. For GitLab Duo, where the choice is enabled, the icon opens a Standard or Deep review menu rather than acting at once, and it is still not the way to Duo's new review (last bullet of this list). On a narrow screen, such as a phone, the right sidebar starts collapsed: expand it first to see the button (enforced; documented). The `/request_review` quick action that GitLab's documentation also offers needs a role, so it does nothing for a contributor (enforced).
  - **Fallback: `@gitlab-bot ready @<that reviewer>`.** For a reviewer already listed, gitlab-bot runs the same mutation for you, within the command's hourly limit and with its other effects (section 2) (enforced).
  - **Neither the mutation nor the button is for GitLab Duo.** Ask for Duo's new review only while its state reads `requested_changes` (its block stands) or a reviewer asks for one; after a push, a Duo that commented (`reviewed`) or approved needs nothing, and a needless request through the platform also requests every person left ticked (section 3). Push the fix first, then ask: a request made before the push spends a review on the old head, and the block stays (observed, 1: on gitlab-org/gitlab!266340 a platform request sent before the push found "no new issues" and listed its finding as still outstanding, note 4120148413, and the MR stayed `requested_changes`; a second request after the push gave a clean review and Duo's approval, notes 4120580272 and 4120580365). Each platform request also opens a thread, with gitlab-bot's reply in it, to resolve afterwards (section 5). The mutation and the button go through for Duo as for anyone: the mutation's `errors` is `[]`, a "requested review from @GitLabDuo" note appears, and Duo's approval is removed if it had one. You then started the review, so GitLab checks your permission to create its pipeline, and Duo posts `DCR4003` in a separate note, which the mutation's answer does not show (observed, 1, on gitlab-org/gitlab!261933; references/bots.md, section 3). Typing `@gitlab-bot ready @GitLabDuo` has given mixed results, although triage-ops handles it as it handles the platform's hidden line, with gitlab-bot re-requesting Duo when Duo is already listed, within your own hourly limit rather than the platform account's (enforced); use the platform's Request review instead (section 3), with Duo ticked and every person you do not mean to re-request unticked. Its hidden line has gitlab-bot re-request Duo, so GitLab checks gitlab-bot's permission to create the review pipeline, not yours (enforced; the Code Review Flow troubleshooting page reads `DCR4003` as the named user lacking permission to create pipelines in the project), and when Duo finds nothing it approves, which lifts its "requested changes" (the "requested changes" bullet below). Prefer it to asking a maintainer to request Duo for you (observed, 1, and a maintainer's recommendation: gitlab-org/api/client-go!3147, platform note 4061201228 and Duo's approval, note 4061242865, within six minutes on 2026-10-21; on client-go!3148 a maintainer who re-requested Duo for the author pointed to the platform for this, note 4060585061).
- **Do not re-request someone who already approved**: in any project the re-request removes their approval, and its system note ends "and removed approval" (enforced). The button is shown for approvers too, a bare `@gitlab-bot ready` re-requests approvers as well (section 2), and the platform's Request review requests whoever is ticked, so check that no approver is (section 3). Ask them in a comment instead (observed, 4).
- **When a new Duo review is due, get it before the people's.** This applies only where Duo's new review is due: its state reads `requested_changes`, a reviewer asks for one, or a maintainer requested it after your push; a Duo that commented or approved needs nothing after a push (above). Then, where a push removes every approval (section 9), a person who approves before Duo's new review is in loses that approval again if Duo asks for one more change and you push it: ask for Duo's review first (above), and re-request the people the reset note named once Duo's new review is in (observed, 1: on gitlab-org/gitaly!9445 a reviewer approved seven minutes before Duo requested changes, and the push that answered Duo reset that approval). Read the notes since your push before you ask for Duo through the platform: in some projects a maintainer asks Duo again for you, and their "requested review from @GitLabDuo" note means it is already asked (observed, 2 projects: on gitlab-org/gitaly!9445 a maintainer did so after each of two pushes, and a platform request 12 seconds after the second added nothing visible, since one review came; gitlab-org/terraform-provider-gitlab, in its project file).
- **A "requested changes" review** does two separate things (enforced; documented):
  - It sets that reviewer's state to `requested_changes`, which is what the inactivity bot reads: while a human reviewer's state reads so, the MR is in your court, and the bot keeps nudging and finally closes it even after you pushed everything. A re-request resets the state to `unreviewed`, which takes the MR out of your court for that reason and back to the reviewer (observed, 1).
  - It blocks the merge ("Change requests must be approved by the requesting user", `detailed_merge_status` reading `requested_changes`), a Premium and Ultimate feature. The block belongs to that reviewer and is not lifted by your push, by a re-request, or by a comment-only review from them. It goes away when that same reviewer approves, or removes their own request in the merge checks; someone who can merge the MR can bypass it instead; and in a project where people who committed to the MR may not approve it, a push by that reviewer to your branch drops their request. If they are away, ask a maintainer in a comment to bypass it once the reviewers agree. For GitLab Duo, the same reviewer approving means Duo approving a later review, which you request through the platform (above) rather than through a maintainer (documented; the platform route observed, 1, above).
- **If the block is not yours** (a freeze, a pending decision), say so and ask a maintainer to add `automation:prevent-auto-close` (enforced; observed, 7).

Sources: gitlab-org/quality/triage-ops:lib/mr_court_helper.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:triage/triage/reaction.rb@839eee7fc991f240c66053781c01d6754db849c7 ;
gitlab-org/quality/triage-ops:triage/triage/api_strategy/graph_ql.rb@70b7dad825b2d659a6954297ab74dd587097b000 ;
gitlab-org/gitlab:app/graphql/mutations/merge_requests/reviewer_rereview.rb@00fb3e11e6b001cba41b2346821be6dffbdc3fa1 ;
gitlab-org/gitlab:app/graphql/mutations/merge_requests/base.rb@e8806b0ab7f77c257ae17c69403a5f0cfe190ed3 ;
gitlab-org/gitlab:app/services/merge_requests/request_review_service.rb@8c5023ca3803ed42b32430c337113e405f48f98e ;
gitlab-org/gitlab:app/policies/issuable_policy.rb@55a6beb784e36d2b7bdc93a35582a62d2c5dda99 ;
gitlab-org/gitlab:app/services/system_notes/issuables_service.rb@9592c3ab9972b721124fe9f9a9689120d1901728 ;
gitlab-org/gitlab:lib/api/merge_requests.rb@c16019c127650c354f22b85712169c4a00bf40c5 ;
gitlab-org/gitlab:lib/gitlab/quick_actions/merge_request_actions.rb@49d9373be079cdece8a330de43d0be3479e62533 ;
gitlab-org/gitlab:doc/api/graphql/_index.md@43ecb41ea18fda993c19544a7e59b43657c7994f ;
gitlab-org/cli:docs/source/api/_index.md@8003e52bf33d07e090d3c3f1a3f972275ca3f4e0 ;
gitlab-org/gitlab:app/assets/javascripts/sidebar/components/reviewers/sidebar_reviewers.vue@d26f8f793376df562b1b90a1b86ec93faaa23712 ;
gitlab-org/gitlab:app/assets/javascripts/sidebar/components/reviewers/reviewers.vue@4826dee1fd159fb724996ab2958f9fe4e5bc0e04 ;
gitlab-org/gitlab:app/assets/javascripts/sidebar/queries/get_merge_request_reviewers.query.graphql@4826dee1fd159fb724996ab2958f9fe4e5bc0e04 ;
gitlab-org/gitlab:app/assets/javascripts/sidebar/components/reviewers/uncollapsed_reviewer_list.vue@9a2633558508318c8409942416031a733d444229 ;
gitlab-org/gitlab:ee/app/assets/javascripts/merge_requests/components/reviewers/approval_rules.vue@03a290ff67748141822ff7e56b7d5358bd35dbce ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261381 ;
gitlab-org/gitlab:app/assets/javascripts/right_sidebar.js@70e10ede2375e4760b626894988939a92b066a44 ;
gitlab-org/gitlab:doc/user/project/merge_requests/reviews/_index.md@691170325429eed40cb4b61c188a5d37295e95c9 ;
gitlab-org/gitlab:app/services/merge_requests/update_reviewer_state_service.rb@fb5c7cb67de8733c2b0c9c68786b30aa0668f782 ;
gitlab-org/gitlab:ee/app/services/merge_requests/reset_approvals_service.rb@bbef49e2d513a826b8087998131cb9e1ef125a77 ;
gitlab-org/gitlab:app/controllers/projects/merge_requests/drafts_controller.rb@e8d785c2666e98f8c9749a7586af70707b3665b6 ;
gitlab-org/gitlab:app/services/draft_notes/create_service.rb@87362347a367ebe1b8a649029e8cd95ce909ab20 ;
gitlab-org/gitlab:app/services/notes/build_service.rb@e85c10513144873f8ab3b9a274cf03b54e107b88 ;
gitlab-org/gitlab:doc/user/discussions/_index.md@7887d944ac2c0765b3a11bfbc483d80e424f36cd ;
https://spec.graphql.org/October2021/#sec-Lone-Anonymous-Operation ;
gitlab-org/gitlab:app/services/merge_requests/approval_service.rb@84a25d4d92442b4d134c1c35d4820e6b3bd96457 ;
gitlab-org/gitlab:app/services/merge_requests/remove_approval_service.rb@88bedb8e42216b428deb5df0167e87e6923d96bc ;
gitlab-org/gitlab:ee/app/models/ee/merge_request.rb@dd2f08701e6273a23be652b281dfd8693ad7e681 ;
gitlab-org/gitlab:ee/app/services/merge_requests/mergeability/check_requested_changes_service.rb@86fa5a3bca0d5f8b044f303e6f47161f9744bdb5 ;
gitlab-org/gitlab:ee/app/services/merge_requests/destroy_requested_changes_service.rb@cdf6b00e744cfa42c10e60f741ba6803fad02221 ;
gitlab-org/gitlab:ee/app/services/ee/merge_requests/refresh_service.rb@43d553b2e74bc5ee1e3e2b076f73a358e0b90805 ;
gitlab-org/gitlab:ee/app/services/ee/merge_requests/base_service.rb@00fb3e11e6b001cba41b2346821be6dffbdc3fa1 ;
gitlab-org/gitlab:ee/app/services/ai/duo_workflows/create_workflow_service.rb@5fbbff89ebd17c1fef1cd558575069cf88718f83 ;
gitlab-org/gitlab:doc/user/duo_agent_platform/flows/foundational_flows/code_review/_index.md@80a8241c9b6b47980a23f939975a166fdd9aef81 ;
gitlab-org/gitlab:doc/user/duo_agent_platform/flows/foundational_flows/code_review/troubleshooting.md@bd609ec96c351ca7bd412d72adf566bb6554c407 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_merge_request_controller.rb@a8b2e17709713e9b4c5cf18dc12c7dac7dc56d4e ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/pages/manage-merge-request-page/RequestReviewAction.vue@840936a0d635a76536946883caa39b6567439d05 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/266340#note_4120148413 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/266340#note_4120580365 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/4404 ;
https://gitlab.com/gitlab-org/container-registry/-/merge_requests/2932 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261933 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/254699 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3147 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3148 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3143#note_4065621189 ;
https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/1367#note_4059714076 ;
https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/1368#note_4065614223 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7630#note_4059833340 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/4044 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260459 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264870#note_4088789920 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/4437#note_4088393283 ;
https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/201#note_4087891743

## 9. Approvals, merge trains and merging

- **Two steps are common**: a reviewer approves and hands the MR to a maintainer, who does the maintainer review and merges. Authors cannot approve their own MR; in gitlab-org/gitlab a team member who pushed commits to your branch can no longer approve it (documented; observed, 15). If the reviewer approves and requests nobody while `approval_rules_left` still lists a rule (below), ask them in a note that mentions them whom to hand it to, or, once the hourly limit allows, post `@gitlab-bot ready @<maintainer>` saying it is approved and green: a ready with a name requests only the people it names, while a bare ready re-requests the approver and removes the approval (section 2; section 4 says how to choose the maintainer). The reviewers' 7-day reminder skips reviewers who approved, so it does not move such an MR (section 10) (documented; enforced). It can go the other way too: the maintainer you named can pass the first review to a reviewer, who requests the maintainer again after approving (observed, 1; references/projects/gitlab-org__gitlab.md, Requesting review and choosing reviewers).
- **Maintainers merge**, usually by setting auto-merge or adding the MR to a merge train. A train runs a merged results pipeline in the canonical project; you cannot start or retry it (observed).
- **After approval, do not push unless asked.** Any push aborts the automatic add ("aborted automatic add to merge train because the source branch was updated"); read the system notes for "set to auto-merge" before pushing (observed, 31). A push that changes the diff also removes approvals, and which ones is a project setting you cannot read (`GET /projects/:id/approvals` answers `403 Forbidden` to an account without a role, checked 2026-10-22): every approval, GitLab Duo's included, where "Remove all approvals when commits are added to the source branch" is on (gitlab-org/api/client-go, gitlab-org/terraform-provider-gitlab and gitlab-org/gitaly, where one push's note read "reset approvals from @GitLabDuo and @<reviewer>"), or only the approvals of the code owners whose rules match the files the push changed, where "Remove approvals by Code Owners if their files changed" is on (gitlab-org/gitlab and gitlab-org/cli). Under the second, a push that touched only `doc/` kept a backend maintainer's approval, and an approval that meets no code owner rule (a reviewer counted only under All Members, GitLab Duo) stays through every push. So in gitlab-org/gitlab never assume, nor tell a reviewer, that a push reset every approval: read the reviewers' states once the reset note has come or a minute has passed, and re-request only a reviewer whose approval is gone (observed, 2: on gitlab-org/gitlab!266080 a force push that changed `doc/` turned the technical writer's approval into `unapproved`, while on !266340 one that changed only a helper and a regenerated file left the backend reviewer `approved`, with no reset note three minutes later). The "reset approvals from @<user> by pushing to the branch" note names whose approvals went. Either way GitLab compares the `git patch-id` of the MR's diff before and after the push and keeps an approval given at an unchanged patch id, so a rebase that leaves the diff, context lines included, as it was keeps approvals, while one that resolves a conflict or picks up changed context does not; `GET /projects/:id/merge_requests/:iid/versions` shows each diff version's `patch_id_sha` (documented; enforced; observed, 8 MRs in 5 projects, each project's setting inferred from its reset notes; the project files say which applies where it is known). Changing the MR's target branch removes every approval wherever either setting is on, the code owners' one included, without comparing patch ids (enforced; `gitlab-org/gitlab:ee/app/services/ee/merge_requests/update_service.rb@d57af02832720526a6252afbb9a27729f2b69739`). If you must push (a conflict, a requested change), say exactly what changed since the approval, re-request the people the reset note names, GitLab Duo aside (each reads `unapproved`; section 8), ask them to approve again and ask the maintainer to set auto-merge again.
- **Approvals read right after a push are not final.** GitLab removes them in a job it schedules 10 seconds after it processes the push and marks the MR temporarily unapproved meanwhile, so approvals read in that window still list the approvers the push will remove; the reset note came 11 to 38 seconds after the "added N commits" note. Wait for the reset note, or about a minute, before you read approvals or tell anyone what the push removed (enforced; observed, 12 pushes on 8 MRs in 5 projects).
- **Approved with an optional suggestion.** Reviewers often approve and leave an optional, non-blocking suggestion in the same review. Which approvals a push removes is in "After approval, do not push unless asked" above or in the project file; where neither says, treat it as every approval going. Where only code owners' approvals go, read `approval_state` first: while no code owner rule for the file the suggestion changes has an approval yet (its `approved_by` is empty), applying the suggestion removes nothing, so apply it before such a code owner approves. Where every approval goes, applying it removes the approval. Applying it in GitLab (section 7) is a push like a local one: where every approval goes, it removed the approver's, who approved again (gitlab-org/gitlab-elasticsearch-indexer!973), and where only code owners' approvals go, an approval that met no code owner rule stayed (gitlab-org/gitlab!264870) (enforced; observed, 2). Where threads must be resolved, the suggestion's thread holds the merge until it is resolved. Either reply why you leave it as it is and resolve the thread, which keeps the approval, or apply it in one push, locally in one commit, with the formatters and linters run and a `Co-authored-by:` trailer for the reviewer, or in GitLab where the suggested lines already pass the project's formatter and linters (both in section 7; its step 4 adds a push otherwise), then wait for the reset note or about a minute (previous bullet), and say in the reply what changed. Re-request every approver the note names, the reviewer included when it names them, except GitLab Duo, which needs nothing after a push (section 8) although the note names it where every approval goes: each reads `unapproved`, which allows it, and the re-request gives them a to-do item; say that their approval went and ask them to approve again (section 8). An approver the note does not name still reads `approved`: do not re-request them, which would remove that approval. When the note does not name the reviewer, resolve their thread yourself once your reply names the commit. If auto-merge or the merge train was set, the push cancelled it: ask the maintainer to set it again (enforced; documented; observed, 2 MRs in 2 projects).
- **`detailed_merge_status` names one blocker, and the pipeline last.** It reads `preparing`, `checking` or `unchecked` while GitLab is still working, and otherwise names the first check that fails, cheapest first: not open, draft, blocked by another MR, requested changes, then unresolved threads, approvals and the rest, then rebase and conflicts. The pipeline is left out of that pass and reported (`ci_still_running`, `ci_must_pass`) only when every other check passes, so `not_approved` or `discussions_not_resolved` can stand while the pipeline runs or after it failed. Read the pipeline from the MR's `head_pipeline`, and after you clear the blocker named, read the status again for the next one (enforced).
- **Read the missing approvals from the rules, not from a count.** `GET /projects/:id/merge_requests/:iid/approvals` gives `approvals_left` and `approval_rules_left`, the rules still missing an approval; `GET /projects/:id/merge_requests/:iid/approval_state` lists every rule with its CODEOWNERS section, the approvals it requires and who met it. Both answer any signed-in account on a public project. `approvals_left` is not a head count: it is the larger of what the code owner and named rules still need together and what the All Members rule needs, and one approval can meet several rules, so it can read 2 where one person eligible for both open rules would do; a rule from another CODEOWNERS section needs someone eligible in that section (documented; enforced; observed, 5 MRs in 2 projects).
- **A failed pipeline does not cancel auto-merge.** GitLab cancels it when commits are added to the MR, but a failed pipeline leaves it set, and the MR merges, or joins the merge train, once a retried or new pipeline succeeds. Before asking the maintainer to set auto-merge again, read `merge_when_pipeline_succeeds` on the MR: while it reads true, ask only for what the pipeline needs. Where the project checks which pipeline may merge (gitlab-org/gitlab's `pre-merge-checks`), a retry is not always enough; see the project file (documented; observed, 1: gitlab-org/gitlab!261675, still set to "automatic add to merge train when checks pass" hours after its pipeline failed).
- **If the train drops the MR** ("removed this merge request from the merge train because the pipeline did not succeed"), open the failed job; fix and push if it is yours; otherwise comment once with the job link and why it is unrelated, and let the maintainer re-add it. A train pipeline can also fail with no job at all when its CI configuration could not be read: read its failure reason (references/troubleshooting.md). Where that is a remote include that timed out and your MR does not touch CI configuration, there is nothing to retry and nothing of yours to fix (observed, 1: gitlab-org/gitlab!264895), so ask the maintainer who added it to add it again, and say until when the MR's last green pipeline still satisfies the project's merge checks; that a re-add then succeeds is this skill's inference, not yet seen. See references/troubleshooting.md (observed, 13).
- **If the merge stops with "Something went wrong during merge pre-receive hook."** (the MR's `merge_error`, or a train note "because the merge could not be completed"), the text after it names the check. For "For signed Web commits, the commit must be equal to the author", do not push and do not re-sign your commits: the check is about the commits GitLab writes when it merges, not yours. Ask the maintainer to merge it again; see references/troubleshooting.md, Threads and merge blockers (enforced). Every refusal seen came on 2026-10-20 between 05:35 and 21:59 UTC, on 160 MRs across gitlab-org, and squash merges went through the merge trains again after it, so outside that window it is not the usual behaviour; the same fix applies (observed, 160).
- **Leave the squash setting alone while the MR is on a merge train**: the merge of an MR whose squash setting changed after it joined fails as an "Outdated merge train" (enforced).
- **gitlab-org/gitlab has extra merge-time checks** (the newest pipeline of the MR in the canonical project that is not a train pipeline must be a merged results pipeline that succeeded, with `tier:3` in its name when the name gives a numeric tier (a docs-only pipeline's `tier:N/A` passes; observed, https://gitlab.com/gitlab-org/gitlab/-/pipelines/2955455068) and a first type that is not predictive (unless the name says `spec-only`), created less than 16 hours earlier, 72 for a `-stable-ee` target; only a member can start one), enforced by the `pre-merge-checks` job on the merge train. Until 2026-09-21 gitlab-bot also posted a "Before you set this MR to auto-merge" note listing them; it was addressed to the maintainer, and older MRs still carry it. See the project file (enforced).
- **An approved MR still waits on** unresolved threads, a standing "requested changes" (including one from GitLab Duo where "Duo can approve and request changes" is on), which that reviewer's approval or withdrawal, or a bypass, lifts (section 8 lists every way; for Duo's, request its new review through the platform), required code owner approvals and a green pipeline. If a maintainer approved but did not merge, ask them in a comment to merge once the pipeline is green (observed, 1). If two such comments over a week get no answer, use `@gitlab-bot help` rather than a third: on gitlab-org/gitlab!261348, where the approved MR needed a new pipeline, it brought a team member who started one the same day (observed, 1).

Sources: gitlab-org/gitlab:doc/development/code_review.md@46d16a140c38dc174e76b67c6eded0dc859c80a8 ;
gitlab-org/gitlab:doc/development/pipelines/_index.md@6206e089ea558c91f176efff4dc31b34e3837b5a ;
gitlab-org/gitlab:scripts/pipeline/pre_merge_checks.rb@054e3432b1934505703e533e8ff14a95f5d0e0c7 ;
https://gitlab.com/gitlab-org/gitlab/-/pipelines/2955455068 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:policies/community/hygiene/ping-inactive-reviewers.yml@e0f9071dc93f7668929e346b32801ba1f5d31f1a ;
gitlab-org/quality/triage-ops:lib/community_contribution_helper.rb@b34c0f99b4c1c91043ab8f1d96cab9f124780f81 ;
gitlab-org/quality/triage-ops:triage/processor/pipeline_tier_transitions.rb@6bd2523b3119c773e34efa5075916f2d8c577b88 ;
https://gitlab.com/gitlab-org/quality/triage-ops/-/commit/c208dc7b229f0197d9ebec373ec811c8dda7aee1 ;
gitlab-org/gitlab:doc/user/duo_agent_platform/flows/foundational_flows/code_review/_index.md@80a8241c9b6b47980a23f939975a166fdd9aef81 ;
gitlab-org/gitlab:doc/user/project/merge_requests/reviews/_index.md@691170325429eed40cb4b61c188a5d37295e95c9 ;
gitlab-org/gitlab:ee/app/services/merge_requests/mergeability/check_requested_changes_service.rb@86fa5a3bca0d5f8b044f303e6f47161f9744bdb5 ;
gitlab-org/gitlab:app/services/merge_requests/merge_service.rb@acc196ed585122f83d47bb981ec56ea77f7335e6 ;
gitlab-org/gitlab:ee/app/services/merge_trains/refresh_merge_request_service.rb@fad36962fd6f667d054bf92c83672fe4e89a4566 ;
gitlab-org/gitlab:ee/app/services/merge_requests/merge_strategies/from_train_ref.rb@3500dc0d3886e53609d53c3d1725281a52ecc286 ;
gitlab-org/gitlab:doc/user/project/merge_requests/approvals/settings.md@2ac227a86477a009d63100482dc997bbc832cbb2 ;
gitlab-org/gitlab:ee/app/services/merge_requests/reset_approvals_service.rb@bbef49e2d513a826b8087998131cb9e1ef125a77 ;
gitlab-org/gitlab:ee/app/services/ee/merge_requests/base_service.rb@00fb3e11e6b001cba41b2346821be6dffbdc3fa1 ;
gitlab-org/gitlab:ee/app/services/ee/merge_requests/update_service.rb@d57af02832720526a6252afbb9a27729f2b69739 ;
gitlab-org/gitlab:app/models/approval.rb@a1422ff794dd55ca6e9c7ee2a1eac3f95b765af0 ;
gitlab-org/gitlab:doc/user/project/merge_requests/auto_merge.md@99807d181dbf7a01f128aa2d99d05c0dabdfed6d ;
gitlab-org/gitlab:doc/ci/pipelines/merge_trains.md@43ecb41ea18fda993c19544a7e59b43657c7994f ;
gitlab-org/gitlab:ee/app/services/merge_requests/refresh/approval_service.rb@31e0b32d95a2cd92df84935261c15eff94836303 ;
gitlab-org/gitlab:doc/api/merge_requests.md@d1cd3e49cc14259dcb7cccc3f78d081a27fa34ea ;
gitlab-org/gitlab:doc/api/merge_request_approvals.md@bd47f4ae8f76b64fac9c96b2179e399c37dcb83d ;
gitlab-org/gitlab:ee/app/models/approval_state.rb@e943a12a1ca2922b15898830cbf9931609dbe181 ;
gitlab-org/gitlab:doc/user/project/codeowners/reference.md@dee712e7ab9946e501edb0802e4a84958712e15e ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/256936 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261675 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261569 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260459 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/4062 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/4061 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/3891 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/4134 ;
https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/merge_requests/3344#note_4055962561 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3082 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7661 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7630 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/262072 ;
https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1618 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/4409 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/257229 ;
https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/merge_requests/3297 ;
https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1761 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3147 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261348 ;
gitlab-org/gitlab:app/services/merge_requests/mergeability/detailed_merge_status_service.rb@591f377197ad88c56177a5593ebfb279fe4ec8ec ;
gitlab-org/gitlab:ee/app/services/ee/merge_requests/mergeability/detailed_merge_status_service.rb@cf86c61d6ac8c27980d0942bb5d02708eedd87f5 ;
gitlab-org/gitlab:app/services/merge_requests/mergeability/run_checks_service.rb@86fa5a3bca0d5f8b044f303e6f47161f9744bdb5 ;
gitlab-org/gitlab:app/services/merge_requests/mergeability/check_ci_status_service.rb@86fa5a3bca0d5f8b044f303e6f47161f9744bdb5 ;
gitlab-org/gitlab:app/models/merge_request.rb@b30ae611be431291816fb70e6678d011dae4e6fc ;
gitlab-org/gitlab:ee/app/models/ee/merge_request.rb@dd2f08701e6273a23be652b281dfd8693ad7e681 ;
https://gitlab.com/gitlab-org/gitlab-elasticsearch-indexer/-/merge_requests/973#note_4085051684 ;
https://gitlab.com/gitlab-org/gitlab-elasticsearch-indexer/-/merge_requests/973#note_4085186462 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264870#note_4089343150 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/266080 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/266340

## 10. Waiting: the reminder schedule

The bot reminds reviewers for you (enforced), so do not add your own pings on
the same schedule:

- Team-member reviewers who have not responded get a nudge after one business day (three days on Mondays, never at weekends, at most two nudges per review request; an informational note instead, once per review request, when they have five or more active review requests, after which the bot nudges that reviewer no more until they are requested again; you are copied on the last one).
- A community MR labelled `workflow::ready for review` with no update for 7 days gets a "was recently assigned to you" reminder, once, to its reviewers other than GitLab Duo and those who approved or requested changes, and the `automation:reviewers-reminded` label; after 14 more idle days the group's engineering manager or the Contributor Success team is pinged. The 7 days count from the MR's last update, which any note moves, whoever writes it: another reviewer's activity, your own reply or a gitlab-bot note postpones the reminder, so a silent reviewer beside an active one may never get it. This is not the author's idle clock, which bot notes do not reset (references/why-mrs-get-closed.md, section 2) (enforced; observed, 2: none on gitlab-org/gitlab!261569 eleven days after review was requested, and on gitlab-org/ruby/gems/gitlab-grape-openapi!77 gitlab-bot's review-load note was the MR's last update).

When the bot says a reviewer "currently has N active review requests", or the
roulette data shows them at capacity (`has_capacity` false; section 4), expect
a delay, and offer someone else in your reminder or ask the next candidate
straight away. After about a week of silence, post one short reminder saying
the pipeline is green and there are no conflicts, after checking both: a
pipeline that passed with a failed `allow_failure` job reads `success` with a
warning, so look at its jobs and name such a job (documented), and
`has_conflicts` can lag behind the target branch
(references/troubleshooting.md, "Conflicts need to be resolved"). Offer to
ask someone else; if there is still no answer, ask the next candidate with
`@gitlab-bot ready @<other>`, which keeps the first reviewer listed
(observed, 26). Address people by name, not by honorifics, and do not repeat
"please merge" pings (observed, 2). Use `@gitlab-bot help` or the
platform's Help action when you are stuck rather than contacting individuals
by email or chat (documented).

Sources: gitlab-org/quality/triage-ops:lib/mr_reviewer_response_helper.rb@f678c194f285e077f635dfd7b09fcc37407c2b62 ;
gitlab-org/quality/triage-ops:policies/community/hygiene/ping-inactive-reviewers.yml@e0f9071dc93f7668929e346b32801ba1f5d31f1a ;
gitlab-org/quality/triage-ops:policies/stages/hygiene/nudge-stale-community-contributions.yml@90aa3341bc1b7d56cfd78e6690568f5e08c89fb7 ;
gitlab-org/quality/triage-ops:lib/community_contribution_helper.rb@b34c0f99b4c1c91043ab8f1d96cab9f124780f81 ;
gitlab-org/gitlab:doc/development/code_review.md@46d16a140c38dc174e76b67c6eded0dc859c80a8 ;
gitlab-org/gitlab:doc/ci/yaml/_index.md@d23cf40423b99d0030a248392db2077bc1a3dbc2 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261569 ;
https://gitlab.com/gitlab-org/ruby/gems/gitlab-grape-openapi/-/merge_requests/77 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7630 ;
https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/433

## 11. What moves an MR and what does not

| Moves it | Does not move it |
| --- | --- |
| `@gitlab-bot ready @<right reviewer>` once the diff and gitlab-bot's welcome note are there | Posting ready again within the hour, or before the diff exists |
| A green pipeline, or each red job explained with a link | Empty commits, repeated retries, pushes only to retrigger CI |
| A reply in every thread with the commit, then a re-request | One summary comment; resolving a reviewer's thread without an answer |
| Resolving your own ready, platform and bot threads once nothing in them is pending | Leaving them open on a project that requires resolved threads |
| Fixing the exact reason the bot's nudge names | Replying to the bot in prose; it does not read replies |
| Asking the next candidate when a reviewer is away | Pinging a group or a person without a review request |
| A change that already meets the style guides and generated-file checks | Requesting GitLab Duo yourself; setting `workflow::ready for review` by hand without a reviewer |

Titles, templates, trailers and labels shape the release but do not make
anyone review sooner (observed).
