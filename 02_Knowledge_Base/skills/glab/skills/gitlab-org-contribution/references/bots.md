# Bots: what each one does and what to do about it

Community MRs in GitLab-owned projects collect notes from several automated
accounts. Knowing which ones need action saves rounds of review. Each section
names the source file the behaviour comes from; behaviour changes when those
files change, so old notes on old MRs may describe an earlier version (the
"Improve it" link in a gitlab-bot note's footer points to the current source).

## Contents

- [1. gitlab-bot (gitlab-org/quality/triage-ops)](#1-gitlab-bot-gitlab-orgqualitytriage-ops)
- [2. Danger (gitlab-dangerfiles and project Dangerfiles)](#2-danger-gitlab-dangerfiles-and-project-dangerfiles)
- [3. GitLab Duo Code Review (@GitLabDuo)](#3-gitlab-duo-code-review-gitlabduo)
- [4. The contributors.gitlab.com account](#4-the-contributorsgitlabcom-account)
- [5. GitLab-Security-Bot](#5-gitlab-security-bot)
- [6. Other bots](#6-other-bots)
- [7. What is worth reading: useful notes and noise](#7-what-is-worth-reading-useful-notes-and-noise)

## 1. gitlab-bot (gitlab-org/quality/triage-ops)

gitlab-bot acts on public projects in `gitlab-org`, `gitlab-com`,
`components` and `gitlab-community`, mostly on MRs whose author is not a
GitLab team member, contractor or bot (enforced).

### Commands

Write each command at the very start of its own line in a normal comment;
arguments are read from that line only. A command in the middle of a sentence,
after a quote marker or on the same line as another command is not seen. To
mention a command in prose, wrap it in backticks and do not start the line
with it. A hidden HTML comment containing a command on its own line does
trigger it (enforced). One note can carry several different commands, one per
line, and each runs: every command processor looks through the whole note for
the start of a line with its own command, so a note with a `ready` line and a
`label` line gets both. A second line with the same command is ignored,
because a command takes its arguments from the first line that starts with
it, so put all the labels on one `@gitlab-bot label` line (enforced; observed,
3: gitlab-org/gitlab!263037, !262090 and !263433, each with the labels and the
review request applied from one note). Only the MR's author, an assignee, a
reviewer, a team member or a member of the community forks group can run the
community commands; others are ignored without a reply (enforced).

| Command | What it does | Limit for a non-member |
| --- | --- | --- |
| `@gitlab-bot ready [@user ...]` (aliases `review`, `request_review`) | Marks the MR ready, adds `workflow::ready for review`, requests the named reviewers (or picks one), replies inside your note's thread; a bare ready on a docs-only MR that lists no reviewer but GitLab Duo, whose pages a docs section of CODEOWNERS gives an owner, picks nobody and posts no reply, leaving the request to the documentation automation, which acts only when that ready adds the label to an MR that already carries `Community contribution`. Details in references/review.md. | 1 per hour per MR and note author (keyed on the diff state) |
| `@gitlab-bot label ~"..."` / `@gitlab-bot unlabel ~"..."` | Adds or removes allow-listed labels on MRs and issues (list in references/review.md). | default 60 commands per hour per user |
| `@gitlab-bot help` | On an MR: asks a merge request coach for help in your thread, adds the coach as reviewer (a coach for the MR's group, a frontend coach for frontend MRs) and announces it on the community Discord. On an issue: pings a coach. | 1 per hour |
| `@gitlab-bot handoff` | Labels the MR `workflow::in dev` and `Seeking community contributions`, unassigns everyone, invites another contributor to take over and announces it on Discord. | 1 per hour |
| `@gitlab-bot feedback <text>` | Sends your feedback to the MR coaches and marks your comment with a check mark. Usually used in reply to the feedback request the bot posts on merge or close, but the command itself checks no MR state. You can also react to that request with a thumbs up or down. | 1 per day per MR |
| `@gitlab-bot unassign_review` | Removes the person who writes it from the reviewers. Only works for a current reviewer. | |

Commands that do **not** exist for contributors do nothing and get no reply:
`@gitlab-bot assign`, free text such as "@gitlab-bot please label this",
`delete_bot_comment` (team members only) and `retry_pipeline` or `retry_job`
(team members only: on issue notes in the master-broken incidents and release
tasks projects, and in the Distribution projects for members of the
Distribution team; so the `@gitlab-bot retry_job` lines an incident lists are
not for you either). You cannot retry jobs through the bot (enforced;
observed, 6).

Do not reply to bot notes in prose to argue or chat; only command processors
read notes (observed, 4).

**Where the commands are heading.** In the Contributor Success team's tracker
the stated intent is to retire the bot's labelling and review-request commands
in favour of the contributor platform. The latest decision there kept
`@gitlab-bot ready` and improved it instead (without names it now asks the
project's own reviewers and maintainers before a coach), and the open
follow-up has the command take its reviewer pick from a platform endpoint
rather than switching it off. No deprecation or date has been announced
(checked 2026-10-21). The commands work today (observed, 35 of 37 ready notes
typed in 27 gitlab-org MRs from 2026-10-18 to 2026-10-20 got the bot's answer;
one of the other two was in a project with its own review process, where the
bot posts no reply) and are the path an agent can run, since the platform's
actions need a signed-in browser session. When the person acts in a browser,
prefer the platform.

Sources: gitlab-org/quality/triage-ops:triage/triage/reactive_command.rb@4b4887e0e83f5eb4f60cbdfc401a1980ecaf079b ;
gitlab-org/quality/triage-ops:triage/processor/community/community_processor.rb@8765efcd87e41a34061c6c2e36596d19109e4f06 ;
gitlab-org/quality/triage-ops:triage/triage/rate_limit.rb@4df1365aadbd941540698b83edbbb9c9deeef47a ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_label.rb@46a4823632f3401513d233b99137d836d520e2ad ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_help.rb@1a66c488c7d5dc6b4a9aea55bfa81850cd76cd97 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_issue_help.rb@f818e73ade381f5ea933b63f20f7c81c1aefba96 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_handoff.rb@1814ceb7df50f9a2a67ae3b62ecd47aa343c1485 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_feedback.rb@ae29f6eeee99f8b972eaf45c6271137f5ff9b24e ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_unassign_review.rb@46a4823632f3401513d233b99137d836d520e2ad ;
gitlab-org/quality/triage-ops:triage/triage/handler.rb@317f82e6734f4f85c9862c9c32cbbf0a76b81c87 ;
gitlab-org/quality/triage-ops:triage/processor/gitlab_internal_commands/command_delete_bot_comment.rb@297c0bf7d4c5af4d14769caea6860d07dc408ded ;
gitlab-org/quality/triage-ops:triage/processor/gitlab_internal_commands/command_retry_pipeline_or_job.rb@7d24d51dc7799eab7bdd6f73753da4d1e4cc9f97 ;
https://gitlab.com/gitlab-org/developer-relations/contributor-success/team-task/-/work_items/1401 ;
https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4447 ;
https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/work_items/802 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263037 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/262090 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263433

### Notes it posts on its own, and what to do

| Note | When | Your action |
| --- | --- | --- |
| Welcome / thank-you note | After you open a community MR: within seconds in gitlab-org/cli, usually four minutes or more later in gitlab-org/gitlab (observed, 207; references/review.md, section 1). Adds `Community contribution`, `workflow::in dev` (which replaces a `workflow::ready for review` your ready set before it), `1st contribution` when you have no merged MR in that project yet (GitLab's `first_contribution` flag is per project, so an experienced contributor gets it on a first MR in each new project; `quick win::first-time contributor` looks across all GitLab projects instead), assigns you, links the contributor platform page for the MR and the community forks, and says that AI-generated contributions are welcome, with complimentary GitLab Duo access. It opens with "Thanks for your contribution to GitLab" and includes a "Did you know about our community forks?" paragraph when the MR does not come from a community fork. gitlab-runner and www-gitlab-com get project-specific bodies; the runner one asks you to check that the description explains the problem and how to test it and that Go code follows the Go guidelines. In gitlab-foss it closes the MR and points to gitlab-org/gitlab. | Read it; use its links. No reply needed. Post `@gitlab-bot ready` only after it, or, if none has come about 70 minutes after opening, anyway (references/review.md, section 1). |
| Type label nudge (":x: Please add ~type::bug ~type::feature, or ~type::maintenance label") | Meant for MRs without `Community contribution`: five minutes after open or update, when no valid `type::` label is set and the MR does not carry that label by then. A community MR gets it only when the welcome note, which adds the label, came late (enforced for non-community MRs; observed, 7 MRs labelled `Community contribution`, 5 of them in 2026). | `@gitlab-bot label ~"type::..."`, then resolve the thread yourself: once `Community contribution` is set the bot no longer collapses or resolves it. |
| AI labeller ("We've attempted to automatically add labels") | On new MRs; sets group, category, type, subtype and area labels above a confidence threshold. | Check them; fix wrong ones with `label` / `unlabel` or the platform. |
| Labels copied from the linked issue | On open and on each description edit, when the description links an issue in a form the bot reads. | Check the `type::` label it copied. |
| IssueSummary block, a description edit rather than a note, at the top of an issue's description ("Everyone can contribute. Help move this issue forward ...", between `<!--IssueSummary start-->` and `<!--IssueSummary end-->`) | On each event of a public, open issue in gitlab-org/gitlab, gitlab-org/api/client-go, the Terraform provider, three gitlab-o11y projects and the contributor platform's project; edited again when its links change, removed, leaving blank lines, when none is left (enforced; references/workflow.md, section 4). | None; leave it. A script that compares the description strips it and the leading blank lines first. |
| Hackathon label and eligibility note | On community MRs created inside the event window. | Accept the hackathon rules on contributors.gitlab.com/hackathon if you want them counted. See references/hackathon-and-platform.md. |
| "Please review this ~documentation merge request" | When `workflow::ready for review` is added to a community MR that changes docs; requests an owner of the changed pages from a docs section of CODEOWNERS, usually a technical writer, adds `documentation` and `tw::triaged`. It requests whoever the most specific CODEOWNERS line of the changed doc pages names, so for a page owned by an engineering group, such as `/doc/development/permissions/` in gitlab-org/gitlab, it requests an engineer, who can also be the code owner the MR's code still needs (enforced; observed, 1: gitlab-org/gitlab!261569). Does nothing if one of those owners was already a reviewer when the label was added or another `tw::` label is set; a reviewer named in the `@gitlab-bot ready` that adds the label is not one yet, because the command adds the label first. | Check that your code reviewer was not dropped, and if they were, ask for them again through the platform's Request review (references/review.md, section 4). |
| UX review request | Community MR with the `UX` label (not drafts), once. | None. |
| "Looks like your pipeline failed" | Once, on a failed latest pipeline triggered by an assignee. | Open the failed jobs; fix or explain. |
| Inactivity nudge ("@you, this is still in draft / there's a merge conflict / the pipeline's failing / there's some open review feedback / this hasn't been sent for review yet ... We'd love to help you get this moving again") | Idle (7 days without a human update) and in your court; at most once per 7 days. When the first reason is that no review was requested, the nudge also adds, once per MR, "@<user>, could you take a quick look and assign yourself if this is ready for review?" addressed to a reviewer the bot picks by review capacity. | Fix exactly the reason in its first sentence. The added line asks that person to assign themselves; it does not request their review, so you still request a human review yourself. |
| "We're closing this for now since it's been quiet for a while" | Stale (30 days) and still in your court. | Reopen when you resume and remove the reason in the same sitting. |
| "Marked as workflow::ready for review but no reviewer is assigned", label back to `workflow::in dev` | A ready-for-review MR with no reviewer (often after a coach unassigned themselves or a ready posted before the diff existed). | `@gitlab-bot ready @<reviewer>` again; on a docs-only MR where the project file says so (gitlab-org/gitlab, gitlab-org/gitlab-runner, gitlab-org/ci-cd/runner-tools/grit), a bare `@gitlab-bot ready` (references/troubleshooting.md, gitlab-bot commands). |
| "<reviewer> currently has N active review requests" | Once per review request, in place of a business-day nudge, when a requested reviewer who has not responded has five or more active review requests; no more nudges to that reviewer follow it until they are requested again. | Expect a delay. It is information, not a reminder: your own one reminder still applies, and it is a reason to offer someone else (references/review.md, section 10). |
| "mentioned in issue gitlab-org/quality/triage-reports#<n>" (a system note) | Around 00:15 UTC on the days gitlab-bot's "Community contributions report" issue lists the MR (observed, 1 MR, 2 notes). | None. They are system notes, not replies: a tool that watches the MR for human replies should skip them. |
| "Could you please make sure this merge request gets merged? ... not currently mergeable (discussions_not_resolved)" | Approved MR blocked by unresolved threads. | Resolve your own ready and bot threads; answer reviewer threads. |
| Feedback request after merge or close | Every merged or closed community MR. It mentions the author and every assignee who is not a team member, links the contributor leaderboard, offers GitLab Duo Agent Platform access ("complimentary access" on an MR from a community fork, a "Get started" link otherwise) and ends with "Thanks for your help!" (enforced). | Optional: react, or `@gitlab-bot feedback <text>`. |
| Notes addressed to maintainers: "Before you set this MR to auto-merge" (pipeline tier rules in gitlab-org/gitlab; posted until 2026-09-21, so only older MRs carry it), a new-pipeline-after-approval note (Terraform provider), the technical writing label note, AppSec SLA notes | Various. | None; they are for approvers. Do not answer them. |
| `@<who> thanks for adding the ~"..." label!` for `quick win` (on an issue), `Seeking community contributions` (on an issue without an implementation plan) and `breaking change` (on an MR, as a thread with a checklist) | When a person adds one of those labels, the `quick win` one only when the issue is confidential or assigned or the AI rates it below the threshold; the note mentions whoever added the label (enforced). | Only for whoever it names. If that is you, do what it asks of the label: check that the issue fits the quick win criteria, add an implementation plan to the issue, or assess the breaking change in its thread. If it names someone else, it is not for you. |
| Spam detector | MRs matching its spam heuristics are labelled `Spam` and closed. | Do not paste promotional or spam-like content. |
| Data seeding reminder (":wave: Hi @<you>, Please ensure data seeding scripts ...") | gitlab-org/gitlab MRs labelled `feature::addition` and `group::optimize`. | It is for you: create or update the data seeding scripts as the optimize group's handbook page it links says, or say in a reply why the feature needs none. |
| Review nudge ("⏳ @<reviewer>: this merge request was assigned to you for review more than 1 business day ago") | At most two per reviewer and request; the second ends `cc @<you>`. | None for the first. The second, which mentions you, is a reason to offer someone else (references/review.md, section 10). |
| gitlab-org/cli "**gitlab-bot approval based on Duo Code Review**", one note with a `#### History` list, edited in place | A pilot in which gitlab-bot approves from Duo's review. It is switched off in triage-ops (`GITLAB_CLI_DUO_APPROVALS_ENABLED = false`, read 2026-10-26), and only internal dry-run notes come from it (enforced). | None. If it posts again, its last History entry says whether the approval stands. |
| On an issue: "Thanks for raising this bug ... will be closed in 7 days", adding `stale` | An open bug labelled `vintage` (a year old) with no human update for 12 months, fewer than 11 upvotes and no severity 1 or 2, customer, security or `automation:prevent-auto-close` label. | If it still reproduces on the latest version, say so in a comment, which removes `stale`. |
| On an issue: "Based on the policy for inactive bugs ... this issue is now being closed", adding `auto closed` | The same bug a week later, still with no human update. | If it still reproduces, reopen it with a comment saying so; you can reopen an issue you opened or are assigned to, and no other, so otherwise ask in a comment for its author or a team member to (documented; observed, 1: gitlab-org/gitlab#454471). |
| On an issue: "This issue is being closed automatically as it has had no activity for 1 year" | Older issues only: the policy closed year-old `group::Self Managed` issues that were not bugs until August 2025, when it moved to Operate and started requiring `group::operate`, `group::framework` and `group::Self Managed` at once, which no issue carries, since only one scoped `group::` label can be set (enforced; observed, 110 such notes in gitlab-org/gitlab, the last on 2025-08-11). | On an issue it closed that still matters, reopen it as above and ask in a comment for `automation:prevent-auto-close`. |
| On an issue: "You have been unassigned from this issue because it's marked as ~"workflow::ready for development" but the milestone is not set to a release." | `group::security insights` backend issues with no release milestone. | You lost the assignment. Ask in the issue before you go on working on it (references/workflow.md, section 3). |
| On an issue: "this issue has no milestone. The milestone will be set to %"Backlog"." | `Category:Workspaces` issues with no milestone. | None. |
| On an issue: "our AI believes this is N% likely to be a ~"quick win"" | New issues judged against the quick win criteria, within six hours of opening, but only unassigned, non-confidential issues a GitLab team member opened (the author must be on the team list, not a bot, and the title must not start `[Feature flag]`), so an issue you open as a community contributor never gets it; it adds `quick win` and asks the issue's author to remove it if it is wrong (enforced). | None on your own issues, which it does not judge. On a team member's issue you take later it may already be there, addressed to that author: if it is wrong, `quick win` is not on `@gitlab-bot unlabel`'s list, so say why in the issue (references/workflow.md, section 4). |

The idle, stale, nudge and close rules, and what counts as "your court", are
in SKILL.md (Gotchas that cost contributors the most) and
references/why-mrs-get-closed.md, section 2.

Sources: gitlab-org/quality/triage-ops:triage/processor/community/thank_contribution.rb@c906e23708bdde2d653a931d235d77e65ef935ca ;
gitlab-org/quality/triage-ops:triage/triage/event.rb@6bd2523b3119c773e34efa5075916f2d8c577b88 ;
gitlab-org/gitlab:lib/gitlab/hook_data/merge_request_builder.rb@8e36bd5018f22de66ae83b9d67b67e57ade036cc ;
gitlab-org/gitlab:app/models/merge_request.rb@b30ae611be431291816fb70e6678d011dae4e6fc ;
gitlab-org/gitlab:doc/user/project/labels.md@cba47cde93b86827b9f5fa1d8de324d91c3451c2 ;
https://gitlab.com/gitlab-org/security-products/analyzers/report/-/merge_requests/139 ;
https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1606 ;
https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1615 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263037 ;
gitlab-org/quality/triage-ops:triage/strings/thanks.rb@46a4823632f3401513d233b99137d836d520e2ad ;
gitlab-org/quality/triage-ops:policies/stages/hygiene/label-community-contributions.yml@544fa8e37d2617bd417500e18a55f1e6eeb1ec17 ;
gitlab-org/quality/triage-ops:triage/processor/type_label_nudger.rb@9612ca345c694815694686033441dc31315e7b0f ;
gitlab-org/quality/triage-ops:triage/job/type_label_nudger_job.rb@cdb5156c2bddd18e9c4d8110ebc8aa52cf97e61d ;
gitlab-org/quality/triage-ops:lib/ai_triage_helper.rb@53f716ba08df079938bad29e6cfb865984b7b693 ;
gitlab-org/quality/triage-ops:triage/processor/apply_labels_from_related_issue.rb@b4d49ec8be9223319bdaecfdaf3574698bb168a3 ;
gitlab-org/quality/triage-ops:triage/processor/community/hackathon_label.rb@2d794ba6558a45d05fca8d43c4e3e3ad0199ba01 ;
gitlab-org/quality/triage-ops:triage/processor/community/automated_review_request_doc.rb@57fab1afd23617b35a9be9e7fbc79357361ea542 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:triage/processor/community/automated_review_request_ux.rb@728ed655b9caba94e74aa335b8af9abe00d96044 ;
gitlab-org/quality/triage-ops:triage/processor/community/failed_pipeline_help.rb@8765efcd87e41a34061c6c2e36596d19109e4f06 ;
gitlab-org/quality/triage-ops:policies/community/hygiene/ping-inactive-author.yml@adcb2783c84e20eaf3fef193df65c4a40551785a ;
gitlab-org/quality/triage-ops:policies/stages/hygiene/close-stale-community-contributions.yml@6acf2943033faf15ea02b61ec5bdd311a420d86e ;
gitlab-org/quality/triage-ops:policies/community/hygiene/ping-incorrect-review-label.yml@544fa8e37d2617bd417500e18a55f1e6eeb1ec17 ;
gitlab-org/quality/triage-ops:lib/mr_court_helper.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:triage/processor/nudge_missing_auto_merge.rb@23d4c2e9c1b9e845a6ec007e5ee7e4da5cdac519 ;
gitlab-org/quality/triage-ops:triage/processor/community/code_review_experience_feedback.rb@8765efcd87e41a34061c6c2e36596d19109e4f06 ;
gitlab-org/quality/triage-ops:triage/processor/pipeline_tier_transitions.rb@6bd2523b3119c773e34efa5075916f2d8c577b88 ;
https://gitlab.com/gitlab-org/quality/triage-ops/-/commit/c208dc7b229f0197d9ebec373ec811c8dda7aee1 ;
gitlab-org/quality/triage-ops:triage/processor/gitlab_terraform_provider/new_pipeline_on_approval.rb@b4d49ec8be9223319bdaecfdaf3574698bb168a3 ;
gitlab-org/quality/triage-ops:triage/processor/community/detect_and_flag_spam.rb@b9fa0269aeebba965a633bdb1bd58dbfbb95f166 ;
gitlab-org/quality/triage-ops:lib/mr_reviewer_response_helper.rb@f678c194f285e077f635dfd7b09fcc37407c2b62 ;
gitlab-org/gitlab:.gitlab/CODEOWNERS@8d29a90b562187afe47da25e6be78045bae0a383 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261569 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3085 ;
gitlab-org/quality/triage-ops:triage/processor/issue_summary.rb@d64ea40406b87e62e8125fbbf464d624e7be4482 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/4437#note_4088517638 ;
https://gitlab.com/gitlab-org/ci-cd/docker-machine/-/merge_requests/201#note_4087936592 ;
gitlab-org/quality/triage-ops:triage/processor/optimize_group/feature_mr_seeding_script_reminder.rb@c5da8246e3e2f58557f0a87c511e2cdeb9cbe81c ;
gitlab-org/quality/triage-ops:triage/processor/gitlab_cli.rb@839eee7fc991f240c66053781c01d6754db849c7 ;
gitlab-org/quality/triage-ops:triage/processor/gitlab_cli/duo_review_support.rb@317f82e6734f4f85c9862c9c32cbbf0a76b81c87 ;
gitlab-org/quality/triage-ops:policies/stages/hygiene/close-stale-bugs.yml@e848bbca722eb7a728940dfea48f6a3f1cd97a78 ;
gitlab-org/quality/triage-ops:policies/groups/gitlab-org/operate/auto-close-old-issues.yml@78b4c79eb0e01043971faf37602351de0a5c342d ;
gitlab-org/quality/triage-ops:policies/groups/gitlab-org/security-insights/remove-assignee.yml@544fa8e37d2617bd417500e18a55f1e6eeb1ec17 ;
gitlab-org/quality/triage-ops:policies/groups/gitlab-org/remote-development/workflow-02.yml@544fa8e37d2617bd417500e18a55f1e6eeb1ec17 ;
gitlab-org/quality/triage-ops:policies/community/quick-win-judge.yml@7e375e7f86b1368f88783040ed0eb57302718150 ;
gitlab-org/quality/triage-ops:lib/quick_win_judge_helper.rb@7e375e7f86b1368f88783040ed0eb57302718150 ;
gitlab-org/quality/triage-ops:triage/processor/quick_win_label_advisor.rb@713f39f2a0c5afe5976f790c4a155e30d6127eb9 ;
gitlab-org/quality/triage-ops:triage/processor/seeking_community_contributions_label.rb@1814ceb7df50f9a2a67ae3b62ecd47aa343c1485 ;
gitlab-org/quality/triage-ops:triage/processor/breaking_change_comment.rb@c407250c2b94dde7acabd70eb58af1e71cafc15e ;
gitlab-org/gitlab:doc/user/permissions.md@1d99b23b390f058a6cea64ecf4da7f1b3198f451 ;
https://gitlab.com/gitlab-org/gitlab/-/issues/454471

## 2. Danger (gitlab-dangerfiles and project Dangerfiles)

Danger runs in the `danger-review` CI job and keeps one comment on the MR,
updated on each run (enforced):

- A table of **errors** (:no_entry_sign:), which fail the job, then **warnings** (:warning:) and **messages** (:book:), which do not.
- Project sections such as **Reviewer roulette**, documentation review or database review.
- At the bottom, a link to **retry the danger-review job**. After fixing an error it reported, retry from that link (or push) and check the comment updated.

Fix every error. Treat warnings and messages as advice: act on the ones that
apply, and when you deliberately leave one, say why in a thread so the
maintainer can acknowledge it (documented in gitlab-org/gitlab's code review
guide).

**A row can be met and still on the comment.** Danger rewrites its comment
only when its job runs, and a label change starts no pipeline. Before acting
on a row, compare when the comment was last updated with the label events and
pushes since: a type, subtype or "Labels missing" row whose labels the MR now
carries, or a commit row a later push answered, is met. Leave it and do not
retry the job for it; it clears on the next pipeline (enforced: in
gitlab-dangerfiles 3.x the type warning stops once a `type::` label is there
and the subtype warning once a `bug::`, `feature::` or `maintenance::` one is,
and 4.0 dropped both; observed, 1: [container-registry!2978](https://gitlab.com/gitlab-org/container-registry/-/merge_requests/2978#note_4081891799),
labelled 90 seconds after the warning).

Shared rules you will meet most (enforced; details in
references/commits-and-descriptions.md):

- **Commit messages** and **commit count** (subject length, capital, body wrap, short references, emoji, fixup and suggestion commits, more than 10 or 20 commits).
- **Changelog** trailers.
- **Metadata**: an MR description shorter than 5 characters is an error; "This merge request does not refer to an existing milestone" and "does not have any assignee yet" are warnings a contributor can ignore, since maintainers set milestones and the bot assigns you (enforced; the milestone warning appeared on 233 MRs).
- **Metadata in the security-products Danger** (the `danger-bot` image `includes-dev/danger.yml` runs where a project keeps that job, which imports the gitlab-dangerfiles rules except changelog and adds its own): a description shorter than 5 characters and an MR with no labels are errors; no `Category:` label (gitlab-bot derives the section, stage and group labels from it), no assignee, no milestone, a target other than the default branch and a title over 72 characters are warnings. Set the `Category:` and `type::` labels with `@gitlab-bot label` and leave the assignee and milestone to the maintainers (enforced; it runs only where "Danger in forks" below says).
- **Change size**: warnings above 500 and 2000 changed lines by default.
- **Labels missing**: Danger could not add labels from a fork pipeline. Add the allow-listed ones with `@gitlab-bot label`, leave the rest (for example `roulette-experiment::*`, `database::review pending`) to the reviewer.
- **Reviewer roulette**: a starting point for choosing reviewers, not an assignment; it notifies nobody. GitLab Duo is listed as a bot reviewer and never counts as the human reviewer. Some projects' Danger text recommends "a review from GitLab Duo Code Review by assigning @GitLabDuo"; that advice is for project members (enforced; see section 3).

gitlab-org/gitlab adds many project rules (database, specs, feature flags,
documentation, master pipeline status, cells routes, authorization cop
bypass, bulk database actions, model validations, multi-version GraphQL);
see its project file and references/troubleshooting.md.

**Danger in forks.** Danger needs an API token. In a personal fork, and in some
projects' forks, the job fails with "Danger cannot run without API access",
`secrets_provider_not_found` or `runner_configuration_error`, or Danger posts
"Danger has errored ... 403 Forbidden". Check whether the job is
`allow_failure` (then it does not block); otherwise say in the MR which job
fails and why, and ask a maintainer to run a pipeline in the canonical project
(observed, 8). The community forks run Danger without your own tokens
(documented), where the project runs it in forks at all.

Some projects leave `danger-review` out of fork pipelines on purpose, by a CI
rule rather than for a missing token. gitlab-org/gitlab-pages includes the
danger-review component only when `CI_PROJECT_PATH` is the canonical project
or its security mirror; gitlab-org/cluster-integration/gitlab-agent and
gitlab-org/gitlab-services/design.gitlab.com run the job only in merge request
pipelines of the canonical project; and the security-products template
`includes-dev/danger.yml` (included through `includes-dev/go.yml` by projects
that keep its job, such as analyzers/report) runs it only in branch pipelines
of projects whose namespace starts with `gitlab-org`, which an MR from a fork
never gets. There an MR from the community fork shows no Danger job and no
Danger comment, at most until a member runs a pipeline for it in the canonical
project, and with the security-products template not even then, since a merge
request pipeline cannot meet its rule. That is neither a failure nor something to retry: check the commit message, changelog
and metadata rules yourself before the first push, and take reviewers from
CODEOWNERS and the history of the touched files, since no roulette appears
(enforced).

**Who posts it.** Danger's comment does not come from gitlab-bot: it posts
with the token the pipeline holds. In a community-fork pipeline that is a group
service account (a username starting `service_account_group_`, shown as
"Danger Bot"), and in a canonical pipeline the project's access token bot
(`project_<project id>_bot_...`), so an MR whose fork and canonical pipelines
both ran can carry one comment from each (observed, 1: gitlab-org/gitlab!263037).
Each run rewrites its own comment in place, the last one that carries its
`"generated_by_<id>"` marker, creates one when there is none, and deletes it
only when neither this run nor that comment has anything to report; a row
marked sticky that was fixed since the last run stays in it, struck through
(enforced). The id is six
hex characters of a hash of the token, so when the token is rotated Danger no
longer finds its old comment and starts a new one beside it: the newest comment
per account is the current one (enforced; observed, 1: gitlab-org/gitlab!262090,
two comments from the same project bot five days apart). The retry line carries
the latest job's URL, so the comment changes on every pipeline even when no row
does: compare its rows, not the whole note (enforced).

When you look for human replies or time a review, leave out usernames
starting `service_account_` or `project_<id>_bot_`, as well as gitlab-bot,
GitLabDuo, GitLab-Security-Bot, `duo-security-review-gitlab-org`, the agent
accounts team members start (`duo-developer-gitlab-org`,
`duo-recommend-reviewers-gitlab-org`,
`ai-appsec-security-mr-reviewer-gitlab-org`; section 3) and the
`contributors.gitlab.com` account (observed, 6). A script cannot tell them by a
flag on the note: the notes API's author object has no `bot` field, and
`GET /users/:id`, which has one, answers `bot: false` for gitlab-bot,
gitlab-dependency-update-bot and a few other automation accounts that are
ordinary users, so name those by their fixed user id rather than trust the flag
(observed, read 2026-10-26; section 7).

**Run it locally** where the project exposes the task: `bundle exec rake
danger_local` (documented).

Sources: gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/z_retry_link/Dangerfile@ddf77782ad394258db521b95bbb17b70c8a7bc12 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/type_label/Dangerfile@e042f64c76bfc0fb7117019134cde72c6e0814a5 (v3.13.0) ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/subtype_label/Dangerfile@e8c7653015ac68e196f62d4a932bc4fc50c26d5f (v3.13.0) ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/plugins/internal/helper.rb@fdeae39f661f886ae0a860f0d8cfb5fec5bb05e6 (v3.13.0) ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/z_add_labels/Dangerfile@ddf77782ad394258db521b95bbb17b70c8a7bc12 (v3.13.0) ;
gitlab-org/container-registry:Gemfile@2057380869cc7057d578606574261a2950e1df04 ;
https://gitlab.com/gitlab-org/container-registry/-/merge_requests/2978#note_4081891799 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/metadata/Dangerfile@c7a0c389ce4a73db91d103b47c5376bde8414e10 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/changes_size/Dangerfile@af4c4e5890b8b4dd2dcaef1e6644743221b79b0d ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/z_add_labels/Dangerfile@366450b0266e5e984eaa2f7e0d78402dca5c07e6 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/plugins/roulette.rb@4cdeaf265d52797999ec1a6711ae346db29b7d66 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:README.md@c8e0ba7151b0d0221bf608576e6194f22b2c44e4 ;
gitlab-org/gitlab:doc/development/code_review.md@46d16a140c38dc174e76b67c6eded0dc859c80a8 ;
gitlab-org/gitlab-pages:.gitlab-ci.yml@80b941cceb10cb8c18e6cb09314a20ff08847f3e ;
gitlab-org/cluster-integration/gitlab-agent:.gitlab/.gitlab-ci.yml@b2a96e3a8c2c068595cfbfd5acc1b71a68766d71 ;
gitlab-org/gitlab-services/design.gitlab.com:.gitlab-ci.yml@e513be11ada5f6b073209eab2d2311df9c95221b ;
gitlab-org/security-products/ci-templates:includes-dev/danger.yml@73b6702121d92097b435e416367618ffb710144c ;
gitlab-org/security-products/ci-templates:includes-dev/go.yml@e2a0c8e5ba2e51efd48383b6577c801d000dec8a ;
gitlab-org/security-products/danger-bot:analyzers/Dangerfile@944ffdf4be65ceede4bba671a2057220496610ed ;
gitlab-org/security-products/danger-bot:metadata/Dangerfile@944ffdf4be65ceede4bba671a2057220496610ed ;
https://gitlab.com/gitlab-org/ruby/gems/labkit-ruby/-/merge_requests/381 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3041 ;
https://gitlab.com/gitlab-org/gitlab-services/design.gitlab.com/-/merge_requests/6417 ;
https://gitlab.com/gitlab-org/security-products/analyzers/report/-/merge_requests/103 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261347#note_3992346621 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263185#note_4059002595 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7662 ;
https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/merge_requests/3399 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261840#note_4059727706 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7679 ;
https://gitlab.com/gitlab-org/release-cli/-/merge_requests/201#note_3724720995 ;
https://github.com/danger/danger/blob/v9.6.1/lib/danger/request_sources/gitlab.rb ;
https://github.com/danger/danger/blob/v9.6.1/lib/danger/comment_generators/gitlab.md.erb ;
https://github.com/danger/danger/blob/v9.6.1/lib/danger/helpers/comment.rb ;
gitlab-org/components/danger-review:templates/danger-review/template.yml@f5dd385f11c15a2c412efd6b59c6d19721ea85f3 ;
gitlab-org/gitlab:.gitlab/ci/includes/gitlab-com/danger-review.gitlab-ci.yml@07677afac04386eb2c3b10f957be0234507ba784 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263037 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/262090 ;
gitlab-org/quality/triage-ops:triage/triage/event.rb@6bd2523b3119c773e34efa5075916f2d8c577b88

## 3. GitLab Duo Code Review (@GitLabDuo)

**What it is.** On gitlab.com, Duo Code Review is the Code Review Flow, an
agentic flow that runs as a CI/CD job in the target project on a runner tagged
`gitlab--duo`. The job runs as the flow's service account, under a composite
identity that ties it to the person who requested the review and limits it to
what both may do (documented); @GitLabDuo, the reviewer its notes come from, is
a separate account. Before creating the job, GitLab checks the requester's
permission to create the review pipeline, so the requester needs the
Developer, Maintainer or Owner role in that project; without it no job is
created and Duo answers `DCR4003` naming the requester (enforced and
documented). The troubleshooting page calls that permission to create
pipelines; the code checks a separate one, `create_duo_workflow_for_ci`, which
the Developer role grants together with the pipeline permissions, so for a
contributor without a role both readings agree. It can be started by assigning
@GitLabDuo as reviewer, by `/assign_reviewer @GitLabDuo`, or by mentioning
@GitLabDuo and asking for a review (documented).

**Getting a Duo review as a community contributor.** Most contributors have no
role in the canonical project, and community fork membership does not count
there. Requesting Duo yourself (reviewer field or mention) answered `DCR4003`
in all 19 MRs where it was tried from July 2026 on (observed, 19; 202 MRs with
the error overall). The way that works is the contributor platform's Request
review action, which requests Duo through its own account and a hidden
`@gitlab-bot ready @GitLabDuo` line (observed, 223 runs, 4 failures). A member
can also request it. Typing `@gitlab-bot ready @GitLabDuo` yourself has given
mixed results (observed, a handful of MRs). Prefer the platform. If you type
it, do it once, and do not repeat it if no Duo review starts. Do not re-request
Duo in a loop; a DCR4003 note does not block the merge. Whether or not Duo
reviews, the MR still needs a human reviewer: the inactivity bot does not count
GitLab Duo as one, so an MR only Duo reviewed stays in your court and is nudged
and then closed as "not sent for review" (enforced; references/review.md,
sections 2 to 4, and references/why-mrs-get-closed.md, section 2).

**Error codes** (documented in the Code Review Flow troubleshooting page):

| Code or message | Meaning | Who can fix |
| --- | --- | --- |
| `DCR4003` "you don't have permission to create a pipeline for Code Review Flow in this project" | The requester lacks the role in the target project. | Use the platform's request rather than asking a member, also for a new review after Duo requested changes; request a human reviewer either way. |
| `DCR4004` "you need to set a default GitLab Duo namespace" | The named user has no default GitLab Duo namespace. | That user sets one in their profile preferences and requests once more. |
| `DCR4002`, `DCR4010` | No GitLab Credits left for the period. | Wait for the next period, or a member reruns it. Fork members can see their usage in user settings. |
| `DCR4008`, `DCR4009`, `DCR4011`, `DCR4012`, `DCR5000`, `DCR5001` | Pipeline creation failed, the source branch could not be read, no `gitlab--duo` runner, compute minutes ran out, internal error, or comments could not be posted. | Request once more later; if it repeats, mention it for a member. |
| "Failed to start the Duo workflow" / "Something went wrong and the review request was stopped" | Transient failure, or a reply that mentioned @GitLabDuo started a new session. | Request once more later; answer threads without mentioning Duo. |

**Answering Duo.** Treat its comments like a first-pass reviewer's: verify each
against the code and the project's instructions, apply what holds, and reply
in its thread in plain text when it is wrong, saying what you checked. Duo
never replies in or resolves its own threads. A follow-up review reads only the
Duo threads and the replies in them, accepts a stated explanation, and lists a
finding with no reply as outstanding even if someone resolved the thread, so
reply before resolving (documented). Maintainers can and do overrule it; Duo
advice that broke POSIX sh, contradicted RuboCop or contradicted the project's
conventions was declined (observed, 6). Deal with Duo's comments before you ask
a person to review (documented in gitlab-org/gitlab's code review guide; the
platform's request note invites you to address them, references/review.md,
section 3).

**Follow-up reviews** run when Duo is asked again, or on push if the project
turned on "Start a new review on push". Automatic reviews skip drafts, MRs with
no changes and files matching the project's exclusion rules (documented).
Automatic reviews are requested as the MR's author, not the pusher, and GitLab
checks the author's permission to create the review pipeline first. For an
author without a role the check fails, so Duo is not added when the MR opens
or leaves draft and a push starts no new review, and nothing is posted on the
MR (enforced).
Use the platform's Request review instead, after a push only while Duo's state
reads `requested_changes` or a reviewer asks for a new review: a Duo that
commented or approved needs nothing (references/review.md, section 8). In some
projects a maintainer asks Duo for its new review after your push, which shows
as their "requested review from @GitLabDuo" note: then Duo is already asked
(observed, 2 projects: gitlab-org/terraform-provider-gitlab and
gitlab-org/gitaly; references/review.md, section 8).

**Duo can approve and request changes** (a beta setting from GitLab 19.5, flag
`duo_code_review_decisions`). Where it is on, Duo approves when it finds
nothing and otherwise requests changes, and that request blocks the merge like
a person's until Duo approves a later review or a user bypasses it. Its note
when it finds nothing starts "I finished my review and found nothing to
comment on. Nice work! :tada:", with a short account of what it traced; the
approval follows a second later, and nothing in it needs an answer (observed,
3: gitlab-org/gitlab-pages!1373, gitlab-org/api/client-go!3147,
gitlab-org/gitaly!9445). A Duo approval does not count toward required
approvals. In the sample, of 8 such MRs
that merged, 5 merged after Duo approved a later review and 3 after a member
bypassed the request (documented; observed, 13). A contributor gets that later
review the same way as the first: answer Duo's threads, then use the platform's
Request review with Duo ticked and every person you do not mean to re-request
unticked. Its hidden line has gitlab-bot re-request Duo, a reviewer already
listed, so GitLab checks gitlab-bot's permission to create the review
pipeline, not yours, whereas your own re-request of Duo ends in `DCR4003`
(enforced; references/review.md, section 8). Prefer it to asking a
maintainer: on gitlab-org/api/client-go!3147 Duo approved such a review
within six minutes of the platform's request, which cleared its requested
changes, and on client-go!3148 a maintainer who re-requested Duo for the
author pointed to the platform for this (observed, 1, and recommended by a
maintainer on a second, both on 2026-10-21; references/troubleshooting.md,
GitLab Duo).

**Duo Security Review.** On security-sensitive community MRs (an OAuth flow,
HTML escaping), team members request the `duo-security-review-gitlab-org`
account as a reviewer or mention it in a comment. It posts its findings as an
internal note that only project members can read, and, where it was requested
as a reviewer, its "requested changes" counts as open review
feedback, so the inactivity bot can nudge you while the MR is really waiting on
the security team. If you cannot see the findings, ask the human reviewer to
share what you need to act on, and do not guess (observed, 2). Do not
re-request its review yourself: once you have answered what you can see of its
findings, ask the human reviewer to request it again (references/review.md,
section 8).

**Other agent accounts team members start.** Team members can start other
agent accounts on a community MR; never mention or invoke them yourself, and
leave them out when you look for human replies (observed, 4 MRs in 4 projects):

- `duo-developer-gitlab-org`, asked in a comment, posts its findings as a public reply addressed to the team member, who may turn them into a "requested changes" review: answer them as review feedback, in that thread (gitlab-org/omnibus-gitlab!9929).
- `duo-recommend-reviewers-gitlab-org` writes only "started session ... triggered by @<team member>" and "completed session" (or "failed (dropped)") system notes and asks nothing of you (gitlab-org/editor-extensions/gitlab-lsp!4481, gitlab-org/cli!4062).
- `ai-appsec-security-mr-reviewer-gitlab-org` replies "AppSec Security MR Reviewer has started" with a link to an agent session, and the MR gets `AppSecMRReviewPerformedBy::AutomatedFlow`. Its findings reached the author only when a team member pasted them into the MR, so ask the team member for what you need to act on, as for Duo Security Review (gitlab-org/gitlab!256936).

**Custom review instructions.** `.gitlab/duo/mr-review-instructions.yaml` holds
named groups of instructions, optionally limited to files by `fileFilters`
globs; matching comments start with "According to custom instructions in
'<group>'". The file exists in at least 23 gitlab-org projects. Read it before
opening the MR (documented). Some ask for judgment rather than mechanics,
such as gitlab-org/ai/skills' "Skill Authoring Guidance" group
(documented; references/projects/other-projects.md, gitlab-org/ai/skills).

**Limits.** For a file over 10,000 lines Duo sees only the diff, and its
pre-scan context is capped at about 1 MiB and truncated to about 800 KiB, so
large MRs get reviews with missing context. Split large MRs (documented).

**Never write instructions for Duo** in a description, diff, code, fixture,
commit message or comment. Duo reports them as a critical prompt injection
finding, and maintainers closed every MR that carried them (observed, 7). Do
not click Duo's "Fix failing pipeline" on someone else's project unless you
want a new MR: it opens one with its own branch (observed, 1).

Sources: gitlab-org/gitlab:doc/user/duo_agent_platform/flows/foundational_flows/code_review/_index.md@80a8241c9b6b47980a23f939975a166fdd9aef81 ;
gitlab-org/gitlab:doc/user/duo_agent_platform/flows/foundational_flows/code_review/troubleshooting.md@bd609ec96c351ca7bd412d72adf566bb6554c407 ;
gitlab-org/gitlab:doc/user/duo_agent_platform/composite_identity.md@75a2855607aabb677aad78688067242d61fbedde ;
gitlab-org/gitlab:ee/app/services/ee/merge_requests/base_service.rb@00fb3e11e6b001cba41b2346821be6dffbdc3fa1 ;
gitlab-org/gitlab:ee/app/services/ee/merge_requests/refresh_service.rb@43d553b2e74bc5ee1e3e2b076f73a358e0b90805 ;
gitlab-org/gitlab:ee/app/services/ai/duo_workflows/code_review/review_merge_request_service.rb@9c478f1119434edd64a1d69d00d8e177c01423c2 ;
gitlab-org/gitlab:ee/app/services/ai/duo_workflows/create_and_start_workflow_service.rb@fdf42b991b7168369f4d15d242ec02dca080bc84 ;
gitlab-org/gitlab:ee/app/services/ai/duo_workflows/create_workflow_service.rb@5fbbff89ebd17c1fef1cd558575069cf88718f83 ;
gitlab-org/gitlab:ee/app/services/ai/duo_workflows/code_review/failure_message_resolver.rb@7b2e25fcdd07b8f02818043cd2d2fb7bab1a59b2 ;
gitlab-org/gitlab:ee/app/services/ai/duo_workflows/start_workflow_service.rb@a7c66e0edf372fa8e5767fbbe709ec6ef0c94642 ;
gitlab-org/gitlab:config/authz/roles/developer.yml@19df67068890049a1710f25f0e7ad3a09962b938 ;
gitlab-org/gitlab:doc/user/duo_agent_platform/customize/review_instructions.md@a34ca4afdb8fc93cbbf304cc89a7c2ca98c133aa ;
gitlab-community/meta:docs/duo-usage-guidelines.md@6f1c3fd623d90bdafdec81d8fd0977bf2dd03947 ;
gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/quality/triage-ops:lib/mr_court_helper.rb@837f6867275b316720365d4c94c2bc3307bc7972 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_merge_request_controller.rb@a8b2e17709713e9b4c5cf18dc12c7dac7dc56d4e ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/254507 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261343 ;
https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/6557 ;
https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4399 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260633 ;
https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/368 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3147 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3148 ;
https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/merge_requests/3395 ;
https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/merge_requests/3355 ;
https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9929#note_4015054030 ;
https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/4481#note_4046812998 ;
https://gitlab.com/gitlab-org/cli/-/merge_requests/4062#note_4024483092 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/256936#note_3914715159 ;
https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/1373#note_4088727130 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3147#note_4061242147 ;
https://gitlab.com/gitlab-org/gitaly/-/merge_requests/9445#note_4089530224 ;
gitlab-org/ai/skills:.gitlab/duo/mr-review-instructions.yaml@ac96616f7ea399bab30907c2015bcd1afe68a642 ;
https://gitlab.com/gitlab-org/ai/skills/-/merge_requests/185

## 4. The contributors.gitlab.com account

Notes posted from the contributor platform come from the `contributors.gitlab.com`
account and name the contributor who used the page (enforced). They are:

- **Review request**: a new thread, so resolvable and unresolved from the start, starting "Hey @<you>, thanks for requesting a review!". Its `/ready`, `/label` and `/request_review` lines run and no longer show in the stored note; with Duo, a hidden `@gitlab-bot ready @GitLabDuo` line stays. The platform's account writes the "requested review from" system note for the people ticked or typed; gitlab-bot replies inside the thread, and requests GitLabDuo, only for the hidden Duo line, so a request without Duo gets no reply and needs none. Resolve it once nothing in it is pending (enforced; observed, 50 platform requests: 0 of the 21 without Duo and 26 of the 29 with Duo got a reply; references/review.md, section 5).
- **Help request** (thread asking the chosen person to help and requesting their review).
- **Label request** ("thanks for helping label this merge request" with `/label`).
- **Issue assignment, unassignment, labelling and closing** (manage-issue page). See references/hackathon-and-platform.md.

Each of these records something the contributor did, so a script that looks
for replies owed counts it as the contributor's own word, not as a note
waiting for them; the mention To-Do the review request reply creates is the
same (enforced; the platform's public source posts notes from these four
actions only, with no scheduled reminder or unassignment of its own).

Sources: gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_merge_request_controller.rb@a8b2e17709713e9b4c5cf18dc12c7dac7dc56d4e ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/services/gitlab/rest/notes.rb@86a13b160a682e964a6307a8c7d18074303deb57 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_issue_controller.rb@f39cc821eff099faecf62980cc9ab44d9cd272a4 ;
https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9929 ;
https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/637

## 5. GitLab-Security-Bot

Posts a security policy comment when a scan result policy finds problems in the
MR pipeline, and edits the same comment to "Security policy violations have
been resolved" once fixed (observed, 71).

- If it names findings your change introduced (a dependency, a license, SAST), fix them. Exceptions are for the project's security approvers.
- If it says required security reports are missing, or the policy is in warn mode, on an MR from a personal fork, that is because the fork pipeline did not run the scans. It goes away when a community fork or canonical pipeline runs; do not change your code for it (observed, 8 and 6).

Sources: https://gitlab.com/gitlab-org/gitlab-services/design.gitlab.com/-/merge_requests/6216 ;
https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/71 ;
https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/merge_requests/6386

## 6. Other bots

- **semantic-release**: in projects released this way (client-go, the CLI, the VS Code extension, the language server, ai-assist, lazy-mcp, labkit-ruby and others) a bot comments ":tada: This MR is included in version X" after release. Use it, or the tags containing the merge commit, before telling anyone a fix is released (observed, 30).
- **Test and report bots**: test result summaries, bundle size analysis and Allure reports in gitlab-org/gitlab and charts, a mirror pipeline status from ops.gitlab.net in cells/http-router, a project bot in congregate that mirrors fork branches to run the end-to-end suite. Act only on failures your change caused (observed, 120). In gitlab-org/gitlab the "Test Result Summary" note, which starts with `<!-- test-result-summary -->` and which a project bot edits as the jobs finish, lists under its RSpec part the spec files your MR changes and the examples it adds; when an unrelated job fails, link it to show that your own specs ran and passed. A script that reads the notes after some point meets it as a note from an account that is not a system note, edited after it was posted (observed, 1: gitlab-org/gitlab!261675, note 4066873425).
- **Pre-analysis notes**: in gitlab-org/terraform-provider-gitlab and gitlab-org/api/client-go a collapsed, machine-generated note headed "Personal pre-analysis note (no action needed from anyone else, including the MR author)" can appear soon after review is requested. It is not review feedback: do not answer it or change code because of it, and do not count it as the first review when you decide whether to send a reminder; the human review comes later (observed, 6 MRs in two projects; the two project files link them).
- **AI-assisted reviews from a reviewer's own account are reviews.** Some team members post reviews written with an AI review tool from their own account, wrapped in a robot-emoji tag pair and ending with a line saying the review was performed with the assistance of a review skill; a review can also come from an agent account a reviewer runs, whose note says it is automated. They carry that reviewer's suggestions, verdict and hand-offs: answer them in their threads like any review. Only the collapsed "Personal pre-analysis note" above needs nothing (observed, 2 MRs in 2 projects).
- **Project sweepers**: some projects run their own stale bots on top of gitlab-bot. Orbit's marks MRs idle for 14 days `stale::scheduled_for_closing` and closes them 3 days later unless there is activity or `stale::keep`, but its current configuration excludes MRs labelled `Community contribution`. Earlier community MRs were swept, so check that the label is on yours. See the project file (enforced in that project).
- **gitlab-community/meta's fork policy** closes any MR that targets a community fork's default branch and links the correct MR against the canonical project (enforced).
- **A release account that is an ordinary user**: `gitlab-cli-release-bot`, whose `GET /users/:id` reads `bot: false`, comments on gitlab-org/cli issues when a release carries the fix, like semantic-release above (observed, read 2026-10-26).
- **`support-bot`**, a bot account, carries other people's words: in a Service Desk issue, the messages its end user sends by email are shown as coming from it, so answer such a note as you would that person (documented, GitLab's Service Desk documentation).

Sources: gitlab-org/api/client-go:.releaserc.json@c31b900a174c7f4142d2933b24cbb69199c7619e ;
gitlab-community/meta:.triage-policies-fork-mrs.yml@a14a629fd45c0142bb65c96fa2dfa37c0eea546d ;
gitlab-org/orbit/knowledge-graph:.gitlab/ci/stale-mr.yml@de545736033648d0febb1e98b1f4b96aacfdce9a ;
https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1354 ;
https://gitlab.com/gitlab-org/orbit/knowledge-graph/-/merge_requests/2121 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3040 ;
https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/merge_requests/3333#note_3997858178 ;
https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/merge_requests/3316 ;
https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/merge_requests/3337 ;
https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/merge_requests/3312 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3086#note_3986436354 ;
https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3099#note_3996271615 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261675#note_4005889093 ;
https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261675#note_4066873425 ;
https://gitlab.com/gitlab-org/gitlab-zoekt-indexer/-/merge_requests/1085#note_4022531558 ;
gitlab-org/gitlab:doc/user/project/service_desk/using_service_desk.md@156d20fa249a6043d739de570019adc9afa4c128

## 7. What is worth reading: useful notes and noise

Most automated notes on a community MR or issue ask nothing of you. This table
sorts them for anyone who watches their items. **Act**:
it asks something of you. **Know**: worth reading, asks nothing. **Skip**: noise
for a watcher, though a note marked "read once" is worth one look when it first
comes. Recognise a note by its marker (a hidden comment such as
`<!-- triage-serverless ThankContribution -->` at its top, the "Improve it" link
to the triage-ops file in its footer, Danger's `"generated_by_<id>"`), not by
its account alone: project bot accounts post Danger, test summaries and
release notices, so the account does not tell them apart (enforced).

| Note | From | Worth it? |
| --- | --- | --- |
| Danger's comment: its errors, and the warnings about your commits, changelog or change size | Danger (section 2) | Act on new or changed rows |
| Danger's "Labels missing" row | Danger | Act: add the allow-listed labels with `@gitlab-bot label`, and leave the rest to the reviewer (section 2) |
| A Danger row the MR already meets: a type, subtype or "Labels missing" row whose labels it carries, a commit row a later push answered | Danger | Know: it stays until Danger runs again; no retry (section 2) |
| Danger's milestone, assignee and "Pipelines failing on master" rows | Danger | Know: they are for maintainers, or a reason a job may fail |
| Danger's inline comment on a diff line | Danger | Act |
| Duo's inline finding and its review summary | GitLabDuo | Act: answer in the thread (section 3) |
| Duo's error (`DCR4003` and the other codes) | GitLabDuo | Act once, by its code (section 3, Error codes): `DCR4003` through the platform's Request review; never a loop |
| "I found issues to comment on but was unable to post the inline comments" | GitLabDuo | Act: its findings are in that note |
| "I finished my review and found nothing to comment on" / "found no new issues" | GitLabDuo | Know: an approval follows where Duo's review decisions are on |
| "I'm already reviewing this merge request" / "There's nothing for me to review" | GitLabDuo | Skip |
| Duo's "requested changes" | GitLabDuo (system note) | Act: it blocks the merge until Duo approves a later review or someone bypasses it (section 3) |
| A finding addressed to the team member who asked for it | `duo-developer-gitlab-org` | Act, as review feedback; a `**praise:**` comment is skip |
| An inline SAST finding (`<!-- {"fingerprint"` at its top) | a project bot | Act: fix it or answer in the thread (observed) |
| Security policy comment | GitLab-Security-Bot (section 5) | Act on findings your change introduced |
| Test result summary, Allure report, mirror pipeline status | project bots (section 6) | Know |
| "New unpartitioned CI queries detected" check | a project bot in gitlab-org/gitlab | Act (observed) |
| "This MR is included in version X" | semantic-release, `gitlab-cli-release-bot` | Know: the fix is released |
| "Please open a new merge request targeting the canonical project instead" | gitlab-community/meta's policy | Act |
| Inactivity nudge, stale close, "no reviewer is assigned" | gitlab-bot | Act on the reason it names |
| A ready answered "currently contains no changes" | gitlab-bot | Act: request review again once the diff shows |
| "No labels specified" / "Could not add the following labels" | gitlab-bot | Act |
| "Looks like your pipeline failed", spam close, "make sure this merge request gets merged" | gitlab-bot | Act |
| Data seeding reminder, type label nudge while unresolved | gitlab-bot | Act |
| "Thanks for adding the ~... label!" | gitlab-bot | Act if it names you, as whoever added the label, else skip (section 1) |
| Stale bug warning and close, old issue close (posted until August 2025; section 1), unassignment | gitlab-bot, on issues | Act |
| Hackathon eligibility | gitlab-bot | Know: the one step it names, accepting the event's rules on contributors.gitlab.com, is done once per event, not per MR (references/hackathon-and-platform.md, section 6) |
| Reviewer overload notice, a second review nudge that ends `cc @<you>`, Backlog milestone, the cli Duo approval pilot | gitlab-bot | Know |
| Welcome note, feedback request after merge or close | gitlab-bot | Skip; the welcome note is read once |
| The reply to your ready, help or handoff | gitlab-bot | Skip: it confirms your own action |
| Docs and UX review requests, notes for approvers and team members, reviewer reminders | gitlab-bot | Skip; a reviewer it dropped shows in Reviewers, not here |
| AI labeller, quick win judge, label bookkeeping | gitlab-bot | Skip, read once to check the labels |
| Notes for your own platform actions | `contributors.gitlab.com` (section 4) | Skip: your own action |
| "has started. You can view progress", automated triage assessment, `duo-recommend-reviewers-gitlab-org` session notes | agent accounts | Skip |
| "Personal pre-analysis note (no action needed ...)" | a reviewer's own account (section 6) | Skip |
| System notes: "changed this line in version N of the diff", "mentioned in issue ...", "requested review from", "reset approvals from" | GitLab | Skip as notes; read reviewers, approvals and merge state from the MR itself |

**Their To-Dos.** A note that mentions you creates a To-Do, and automation's
mentions are most of a contributor's list. gitlab-bot's feedback request after
a merge or close and its nudges, the platform's claim greeting and hand-off,
its ready echo and review request acknowledgement, a Duo review that found
nothing and release notes each create one that is settled on sight: mark it
done once you have read the note. Nothing clears the ones a note adds after the
merge (enforced; observed on one contributor's list;
references/troubleshooting.md, To-Do List).

The user ids of these accounts (gitlab-bot 1786152, GitLabDuo 21826781,
`contributors.gitlab.com` 31177744, GitLab-Security-Bot 7849066) were read from
`GET /users/:id` on 2026-10-26, and triage-ops names the first two in
`triage/triage/event.rb` (observed; enforced); the platform account's id comes
from that read alone.

Sources: gitlab-org/quality/triage-ops:triage/triage/event.rb@6bd2523b3119c773e34efa5075916f2d8c577b88 ;
gitlab-org/gitlab:app/services/todo_service.rb@67dccbf8b0e0af92d7375620c8c46dd42769f25a ;
gitlab-org/gitlab:app/models/todo.rb@6c5596c4a6933fa73302f8a9f5aa18a593847e18 ;
gitlab-org/quality/triage-ops:triage/triage/unique_comment.rb@297c0bf7d4c5af4d14769caea6860d07dc408ded ;
gitlab-org/quality/triage-ops:triage/triage/reaction.rb@839eee7fc991f240c66053781c01d6754db849c7 ;
gitlab-org/gitlab:ee/lib/gitlab/duo/code_review/messages.rb@7b2e25fcdd07b8f02818043cd2d2fb7bab1a59b2 ;
gitlab-org/gitlab:ee/app/services/ai/duo_workflows/code_review/failure_message_resolver.rb@7b2e25fcdd07b8f02818043cd2d2fb7bab1a59b2 ;
gitlab-org/gitlab:ee/lib/security/scan_result_policies/policy_violation_comment.rb@f22ea7128a9dcc3c60b17ccc2fc53d4b6bdc9bc8 ;
gitlab-org/gitlab:scripts/post_rspec_test_summary.rb@11d06758f2a03bea30515f338249f510bd117d0e ;
https://github.com/danger/danger/blob/v9.6.1/lib/danger/comment_generators/gitlab_inline.md.erb ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/metadata/Dangerfile@c7a0c389ce4a73db91d103b47c5376bde8414e10 ;
gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/z_add_labels/Dangerfile@366450b0266e5e984eaa2f7e0d78402dca5c07e6 ;
gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/services/gitlab/rest/notes.rb@86a13b160a682e964a6307a8c7d18074303deb57 ;
gitlab-org/api/client-go:.releaserc.json@c31b900a174c7f4142d2933b24cbb69199c7619e ;
gitlab-community/meta:.triage-policies-fork-mrs.yml@a14a629fd45c0142bb65c96fa2dfa37c0eea546d ;
gitlab-org/quality/triage-ops:triage/processor/quick_win_label_advisor.rb@713f39f2a0c5afe5976f790c4a155e30d6127eb9 ;
gitlab-org/quality/triage-ops:triage/processor/seeking_community_contributions_label.rb@1814ceb7df50f9a2a67ae3b62ecd47aa343c1485 ;
gitlab-org/quality/triage-ops:triage/processor/breaking_change_comment.rb@c407250c2b94dde7acabd70eb58af1e71cafc15e ;
gitlab-org/quality/triage-ops:triage/processor/docs/technical_writing_label_base.rb@b4d49ec8be9223319bdaecfdaf3574698bb168a3 ;
gitlab-org/quality/triage-ops:triage/processor/appsec/triage_appsec_mr_ping.rb@b4d49ec8be9223319bdaecfdaf3574698bb168a3 ;
gitlab-org/quality/triage-ops:policies/community/hygiene/ping-inactive-reviewers.yml@e0f9071dc93f7668929e346b32801ba1f5d31f1a ;
gitlab-org/quality/triage-ops:policies/stages/hygiene/nudge-stale-community-contributions.yml@90aa3341bc1b7d56cfd78e6690568f5e08c89fb7
