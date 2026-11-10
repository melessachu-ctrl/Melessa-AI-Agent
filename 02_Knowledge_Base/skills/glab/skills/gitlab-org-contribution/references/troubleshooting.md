# Troubleshooting: symptom, cause, fix, who can fix it

Find the symptom, read the cause, do the fix. "Who" says whether the
contributor can fix it alone or has to ask a member (a person with a role in
the canonical project). When you need a member, ask once, in the MR, quoting the
job name or note and the exact error line. For project-specific failures (for
example gitlab-org/gitlab's `pre-merge-checks` or its database review), see the
project file through references/projects/INDEX.md.

Counts are MRs in the sample where the symptom appeared.

## Contents

- [Pipelines](#pipelines)
- [gitlab-bot commands](#gitlab-bot-commands)
- [Threads and merge blockers](#threads-and-merge-blockers)
- [Danger](#danger)
- [GitLab Duo](#gitlab-duo)
- [Security bot](#security-bot)
- [Contributor platform](#contributor-platform)
- [Silence, nudges and closes](#silence-nudges-and-closes)
- [MR mechanics](#mr-mechanics)
- [To-Do List](#to-do-list)

## Pipelines

### Fork pipeline never starts, or every job fails at once

`ci_quota_exceeded` with an empty log, "no instance runners", a request for
identity verification, "You have reached the free storage limit of 10 GiB", or
every pipeline waiting for a team member to start it.

- **Cause:** a personal fork runs on your own CI minutes, storage and runner access (observed, 36).
- **Fix:** if the personal fork is minutes old and every job failed with `ci_quota_exceeded` (read each job's `failure_reason`) before any started, run the pipeline once more from the MR first: on such a fork the first push and MR pipelines failed that way, and a new MR pipeline on the same commit ten minutes later passed (observed, 1: gitlab-org/ai/skills!154, which has no community fork). Otherwise move to the community fork (references/hackathon-and-platform.md, section 2). If none exists, request one, and meanwhile complete identity verification or ask the reviewer to run the pipeline in the canonical project, posting your local results. Never push empty commits to retrigger.
- **Who:** contributor; a member for the canonical pipeline.
- **Evidence:** gitlab-community/meta:README.md@6f1c3fd623d90bdafdec81d8fd0977bf2dd03947 ; https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7501 ; https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1512 ; https://gitlab.com/components/opentofu/-/merge_requests/505 ; https://gitlab.com/gitlab-org/ai/skills/-/merge_requests/154/pipelines

### Jobs stuck or failing only in the fork

`no_matching_runner`, "no active online runners with the label ...",
`MissingCredentials`, a 403 from a remote state endpoint, group secrets
unavailable, image push "invalid reference format", package upload refused, or
a downstream trigger that never runs.

- **Cause:** the job needs runners, secrets, registries or upstream jobs only the canonical project has; some are missing even in the community fork (observed, 34 and 13).
- **Fix:** check the same job passes on the canonical default branch, then comment with the job names, the error line and why your change cannot affect them, and ask a maintainer to run a pipeline for the MR in the canonical project. Do not change CI configuration to make your fork pass. If a maintainer ports your commits into a project branch, follow the new MR and check it keeps your commits. One comment is enough, for example:

  ```text
  The `<job name>` job fails in the fork pipeline: <job link>
  Error: <the exact error line>
  It needs <the protected runner, secret or registry> that only the canonical
  project has, and the same job passes on the default branch: <link>.
  Could a maintainer run a pipeline for this MR in the canonical project?
  ```

- **Who:** member. As a community fork member (Developer there) you can retry jobs in your own fork pipeline; only members of the canonical project can start or retry its pipelines, so try the fork retry first and ask a member only for the canonical one.
- **Evidence:** https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9855 ; https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7628 ; https://gitlab.com/gitlab-org/labkit/-/merge_requests/768 ; https://gitlab.com/gitlab-org/ruby/gems/labkit-ruby/-/merge_requests/358

### Every job of a personal fork fails before its script, pulling the image

`runner_system_failure` on every job of the first stage and every later stage
skipped, where the job's image is written as
`${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}/<image>`.

- **Cause:** the dependency proxy exists for groups only ("not available for projects"), so in a fork under your own user namespace that prefix points at a proxy that does not exist and the image pull fails (documented; observed, 1). Forks under `gitlab-community` belong to a group and have the proxy.
- **Fix:** use the community fork. If you must use a personal fork, add a project CI/CD variable `CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX` with the value `docker.io/library` on your fork only (not protected, not masked): project variables take precedence over predefined ones, so official Docker Hub images such as `ruby:<version>` are pulled directly. It changes nothing in the MR. Images outside Docker Hub's official library need their own registry path instead.
- **Who:** contributor.
- **Evidence:** gitlab-org/gitlab:doc/user/packages/dependency_proxy/_index.md@84c7ab495b46a03e8e365d1dd361c78108a4e3b8 ; gitlab-org/gitlab:doc/ci/variables/_index.md@554930f75ed502b092be1dd1a7063767db80e199 ; gitlab-org/ruby/gems/semver_dialects:.gitlab-ci.yml@277b463cd1d7aecbe9e0a9f109167171dd25da6d

### A job failed and you cannot retry it

- **Cause:** contributors cannot retry or start jobs in the canonical project, and gitlab-bot has no retry command for MRs (enforced). A pipeline that ran in your community fork is different: as a community fork member (Developer there) you can retry its jobs yourself.
- **Fix:** first check which project ran the pipeline. Job links under `gitlab-community/...`, or a `head_pipeline.project_id` on the MR that is the fork's id rather than the canonical project's, mean a fork pipeline: retry its jobs yourself from the fork's pipeline page. Only a job in the canonical project needs a member. Then open the log. A lint, test, Danger or generated-file failure caused by your change is yours: fix it and push. An infrastructure error (Gitaly "resource exhausted", "bad pack header", "unable to handle this request due to load", image pull or dependency proxy errors, a known flaky job, a cancelled train) is not: retry it once yourself in a fork pipeline, or, for a canonical job, ask once for a retry, quoting the job and line. In gitlab-org/gitlab a retried pipeline keeps the tier and types it started with, so once every approval is in and the MR waits to merge, read the pipeline's name (`GET /projects/278964/pipelines/<id>`): a retry of a pipeline whose name reads `tier:1` or `tier:2`, or whose `types:` list starts with a predictive type outside a `spec-only` pipeline, cannot pass `pre-merge-checks` even when green, so ask for a new pipeline instead (its project file, Troubleshooting). Post a failure's retry link only if Danger's comment offers one.
- **Who:** contributor for code failures and for retries in a fork pipeline; member for retries in the canonical project.
- **Evidence:** gitlab-org/quality/triage-ops:triage/triage/handler.rb@317f82e6734f4f85c9862c9c32cbbf0a76b81c87 ; gitlab-org/gitlab:doc/development/pipelines/_index.md@6206e089ea558c91f176efff4dc31b34e3837b5a ; gitlab-org/gitlab:scripts/pipeline/pre_merge_checks.rb@054e3432b1934505703e533e8ff14a95f5d0e0c7 ; gitlab-org/gitlab:scripts/pipeline/set_pipeline_name.rb@aaf0935ac1430f6c729f325ac4fcb82a9ba5f99d ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261675 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/254542 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261202 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/256644

### Merge train drop: "removed this merge request from the merge train because the pipeline did not succeed"

- **Cause:** often no pipeline of the MR ran in the canonical project, or the newest one there is too old or the wrong tier for the project's pre-merge job; sometimes an infrastructure flake (observed, 13 and 18 in gitlab-org/gitlab docs MRs). A train pipeline can fail with no job at all when its CI configuration could not be read: read its failure reason, which then says "The pipeline failed due to an error on the CI/CD configuration file", and unless your MR changes the CI configuration, the failure is not your change's. The pipeline page, or `errorMessages` of the pipeline in GraphQL (the REST `yaml_errors` stays empty), names the cause, such as "Remote file `<url>` could not be fetched after 3 attempts because of a timeout error!" for a remote include that timed out (enforced; observed, 1: gitlab-org/gitlab!264895, pipeline 2991187301, whose `include:remote` of untamper-my-lockfile timed out).
- **Fix:** do not push. Ask the approving maintainer to run a new pipeline in the canonical project and to start the train or auto-merge again. In gitlab-org/gitlab, `pre-merge-checks` needs a recent merged results pipeline in the canonical project, at tier 3 where its name gives a tier; see that project's file. For a train pipeline with no job whose configuration error your MR did not cause, there is nothing to retry: ask the maintainer who added the MR to add it again, link the pipeline and its error, and say that the MR's last merged results pipeline is still green and until when `pre-merge-checks` accepts it (16 hours after it was created) (observed, 1, the request; that the re-add then succeeds is this skill's inference, not yet seen).
- **Who:** member.
- **Evidence:** gitlab-org/gitlab:doc/development/pipelines/_index.md@6206e089ea558c91f176efff4dc31b34e3837b5a ; gitlab-org/gitlab:scripts/pipeline/pre_merge_checks.rb@054e3432b1934505703e533e8ff14a95f5d0e0c7 ; gitlab-org/gitlab:doc/ci/pipelines/merge_trains.md@43ecb41ea18fda993c19544a7e59b43657c7994f ; gitlab-org/gitlab:lib/gitlab/ci/config/external/file/remote.rb@1792d0f3f2e96cf0efcfb591f22a759bce1293f3 ; gitlab-org/gitlab:.gitlab-ci.yml@bfb0b760acea4972d5a39e49ad80c320dcab47c4 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261200 ; https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1552 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/264895 ; https://gitlab.com/gitlab-org/gitlab/-/pipelines/2991187301

### Web IDE edits keep failing formatters or generators

- **Cause:** the Web IDE cannot run the linters, formatters and generators the pipeline checks.
- **Fix:** clone the fork, run the project's local checks (references/workflow.md, step 8), and push from there.
- **Who:** contributor.
- **Evidence:** https://gitlab.com/gitlab-org/gitlab/-/merge_requests/256644

## gitlab-bot commands

### `@gitlab-bot ready` (or `label`, `help`) did nothing

- **Cause, one of:** the command was not at the start of its own line; it used the `request-review` spelling (hyphen); it was a second `ready` within an hour on the same MR and diff; you are not the author, an assignee, a reviewer, a team member or a community forks member; or the project has its own review workflow (gemnasium-db, GitLab Environment Toolkit, quality/performance, Distribution projects such as omnibus-gitlab and the charts), where the bot only adds the label (enforced; observed, 82).
- **Fix:** check whether `workflow::ready for review` appeared. If it did, the bot ran: on a project with its own review process, request the reviewer through the contributor platform's Request review action, which runs `/request_review` from its own account and so puts a person in the Reviewers list. A mention in a comment only notifies the person; it adds nobody to Reviewers, so the MR stays in your court for the inactivity bot (references/review.md, section 2). If the label did not appear, repost the command alone on the first line, spelled `ready`, after the hour. If it still does nothing, use the platform's Request review.
- **Who:** contributor.
- **Evidence:** gitlab-org/quality/triage-ops:triage/triage/reactive_command.rb@4b4887e0e83f5eb4f60cbdfc401a1980ecaf079b ; gitlab-org/quality/triage-ops:triage/processor/community/community_processor.rb@8765efcd87e41a34061c6c2e36596d19109e4f06 ; gitlab-org/quality/triage-ops:triage/triage/rate_limit.rb@4df1365aadbd941540698b83edbbb9c9deeef47a ; gitlab-org/quality/triage-ops:lib/mr_court_helper.rb@837f6867275b316720365d4c94c2bc3307bc7972 ; gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_merge_request_controller.rb@a8b2e17709713e9b4c5cf18dc12c7dac7dc56d4e

### "this merge request currently contains no changes ... We will wait 5 minutes before assigning a reviewer"

- **Cause:** you posted `ready` before GitLab showed the pushed diff. The delayed job only marks the MR ready and adds the label; it requests nobody itself (enforced; observed, 14), but on an MR that changes docs the documentation automation reacts to that label and can request a docs owner (enforced; observed, 2; references/review.md, section 1).
- **Fix:** check Reviewers first; as soon as the Changes tab shows your head commit and gitlab-bot's welcome note is there, post `@gitlab-bot ready @<reviewer>` again (on a docs-only MR, only if no docs owner was requested); the hourly limit does not apply, because it is counted separately before and after the diff exists. Then resolve the "no changes" reply and the new ready thread. If the push itself never appears in the MR, force-push the branch one commit back and then the real head again. The platform's Request review (references/review.md, section 3) works as well: the people you tick or type are requested by its own `/request_review`, which no hourly limit counts, and if you include GitLab Duo, its hidden ready follows the same diff and hourly rules as a typed one. The single rule is in references/review.md, section 1.
- **Who:** contributor.
- **Evidence:** gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ; gitlab-org/quality/triage-ops:triage/job/mark_ready_for_review_job.rb@46a4823632f3401513d233b99137d836d520e2ad ; gitlab-org/quality/triage-ops:triage/processor/community/automated_review_request_doc.rb@57fab1afd23617b35a9be9e7fbc79357361ea542 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/255704 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263078 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261522

### A stranger was asked to review

- **Cause:** reviewer names were on the lines after the command (only the command's own line is read), or no name was given and the bot picked one; the platform also suggests a reviewer itself (enforced; observed, 6 and 96).
- **Fix:** post `@gitlab-bot ready @<reviewer>` on one line; if the wrong person was asked, thank them in one line and request the right one. If the picked reviewer says they are not a reviewer for the project or have no capacity, name a code owner or roulette pick with the command (observed, 9).
- **Who:** contributor.
- **Evidence:** gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ; https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/merge_requests/7175 ; https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6271

### The ready requested your reviewer, but the MR is back in `workflow::in dev`

- **Cause:** the ready came before gitlab-bot's welcome note, whose `workflow::in dev` replaced `workflow::ready for review` a moment later; in gitlab-org/gitlab that note usually comes four minutes or more after the MR opens (enforced; observed, 207; references/review.md, section 1). The reviewer is still requested, but the reviewers' 7-day reminder looks only at MRs labelled `workflow::ready for review`.
- **Fix:** add the label back with `@gitlab-bot label ~"workflow::ready for review"` in a new note, not with a second ready, then check Reviewers; on an MR that touches docs the label also brings the documentation automation's writer request (references/review.md, sections 1 and 4). Next time wait for the welcome note itself, not for the `Community contribution` label, which can come earlier (observed, 1 restore and 2 early labels; references/review.md, section 1).
- **Who:** contributor.
- **Evidence:** gitlab-org/quality/triage-ops:triage/processor/community/thank_contribution.rb@c906e23708bdde2d653a931d235d77e65ef935ca ; gitlab-org/gitlab:doc/user/project/labels.md@cba47cde93b86827b9f5fa1d8de324d91c3451c2 ; gitlab-org/quality/triage-ops:policies/community/hygiene/ping-inactive-reviewers.yml@e0f9071dc93f7668929e346b32801ba1f5d31f1a ; gitlab-org/quality/triage-ops:triage/processor/community/command_mr_label.rb@46a4823632f3401513d233b99137d836d520e2ad ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263037 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260638 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263025

### "We noticed this MR is marked as workflow::ready for review but no reviewer is assigned", label back to `workflow::in dev`

- **Cause:** the label is set but nobody is a reviewer (a reviewer unassigned themselves, or the earlier ready ran before the diff existed) (enforced; observed, 26).
- **Fix:** `@gitlab-bot ready @<reviewer>`, at once when your earlier ready was answered "contains no changes" (the hourly limit counts a ready posted before the diff apart from one posted with it; references/review.md, section 2), otherwise once an hour has passed since your last ready; on a docs-only MR where the project file says so (gitlab-org/gitlab, gitlab-org/gitlab-runner, gitlab-org/ci-cd/runner-tools/grit), a bare `@gitlab-bot ready`. Do not set the label yourself while no reviewer is listed.
- **Who:** contributor.
- **Evidence:** gitlab-org/quality/triage-ops:policies/community/hygiene/ping-incorrect-review-label.yml@544fa8e37d2617bd417500e18a55f1e6eeb1ec17 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260458

### "Could not add the following labels"

- **Cause:** the label is not on the bot's allow-list (for example `Hackathon`, `Community contribution`, `docs::`, `pipeline::` labels, project-specific labels) (enforced; observed, 6).
- **Fix:** do not retry. Ask a reviewer once in the MR, or leave it; stage and section labels follow the group label automatically. Template quick actions such as `/label` and `/milestone` likewise do nothing for non-members (observed, 11).
- **Who:** member.
- **Evidence:** gitlab-org/quality/triage-ops:triage/processor/community/command_mr_label.rb@46a4823632f3401513d233b99137d836d520e2ad ; https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1822

## Threads and merge blockers

### Approved and green, but `discussions_not_resolved`

Or gitlab-bot asks a maintainer to "make sure this merge request gets merged"
because it is "not currently mergeable (discussions_not_resolved)".

- **Cause:** gitlab-bot answers inside your `ready` note, which makes it an unresolved thread, and the platform's review request is an unresolved thread from the start, answered or not; other bot threads (type label nudge, Danger checklists) may be open too (enforced; observed, 35). Any reply under a standalone note, yours under a reviewer's comment or a member's under yours, also turns that note into an unresolved thread (enforced; observed, 3; references/review.md, section 8).
- **Fix:** resolve your ready and platform threads once nothing in them is pending (references/review.md, section 5); resolve bot threads you dealt with after replying what you did; answer reviewers' threads, and resolve one yourself only once it needs nothing more from the reviewer, such as the thread of an approving reviewer's optional suggestion you declined or of an approver whose approval your push kept (references/review.md, sections 8 and 9; the project file says where reviewers resolve their own). A thread your own reply under a reviewer's standalone comment created is yours to resolve once it needs nothing more from them; next time answer such a comment in a new top-level note that mentions them.
- **Who:** contributor.
- **Evidence:** gitlab-org/quality/triage-ops:triage/triage/reaction.rb@839eee7fc991f240c66053781c01d6754db849c7 ; gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ; gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/services/gitlab/rest/notes.rb@86a13b160a682e964a6307a8c7d18074303deb57 ; gitlab-org/gitlab:doc/user/discussions/_index.md@7887d944ac2c0765b3a11bfbc483d80e424f36cd ; gitlab-org/gitlab:app/services/notes/build_service.rb@e85c10513144873f8ab3b9a274cf03b54e107b88 ; https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3143#note_4065621189 ; https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/1367#note_4059714076

### Approvals vanished; "aborted automatic add to merge train because the source branch was updated"

- **Cause:** you pushed or rebased after approval. Any push aborts auto-merge or the merge train; a push that changed the diff (a conflict resolved, new commits, context picked up by a rebase) also removed approvals: all of them where the project removes every approval on push, or only those of the code owners whose files it changed where it removes code owners' approvals, so other approvals, GitLab Duo's included, can remain (documented; enforced; observed, 31; references/review.md, section 9).
- **Fix:** wait for the "reset approvals from @<user> by pushing to the branch" note, which names whose approvals went and came 11 to 38 seconds after the push (references/review.md, section 9), then comment exactly what changed and why, and ask each person the note names to approve again, except GitLab Duo, which needs nothing after a push: each of them now reads `unapproved`, so re-request them too (references/review.md, sections 8 and 9). Ask the maintainer to set auto-merge again. Next time ask before rebasing an approved MR; maintainers often rebase it themselves.
- **Who:** member.
- **Evidence:** gitlab-org/gitlab:doc/user/project/merge_requests/approvals/settings.md@2ac227a86477a009d63100482dc997bbc832cbb2 ; gitlab-org/gitlab:ee/app/services/merge_requests/reset_approvals_service.rb@bbef49e2d513a826b8087998131cb9e1ef125a77 ; gitlab-org/gitlab:ee/app/services/merge_requests/refresh/approval_service.rb@31e0b32d95a2cd92df84935261c15eff94836303 ; https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/merge_requests/3297 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/258021 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/256936 ; https://gitlab.com/gitlab-org/cli/-/merge_requests/4061

### Merge refused: "Something went wrong during merge pre-receive hook. For signed Web commits, the commit must be equal to the author"

The MR's `merge_error` holds that text, or a merge train note reads "removed
this merge request from the merge train because the merge could not be
completed." followed by it, while the pipeline is green, the approvals stand
and `detailed_merge_status` still reads `mergeable`.

- **Cause:** "Something went wrong during merge pre-receive hook." comes before every refusal by a server-side check at merge time, and the text after it names the check; other texts there can be about your diff, this one is not (enforced). It is a check built into GitLab, not a project push rule: for a change made through GitLab, every new commit that GitLab itself signed must be authored by the person making the change, and commits that are unsigned or signed with your own key are skipped (enforced). Most GitLab-owned projects have GitLab sign the commits it writes (observed, 35 of the 36 projects with a file in references/projects, checked 2026-10-21), and a squash commit names the MR's author, not the maintainer who merges (documented). Outside the window below, a normal squash merge passes all the same, because GitLab writes and stores the squash commit in a step before the merge, so the check does not count it as new (enforced; observed, 32 community MRs merged that way). Nothing in your branch causes this refusal, and nothing you push, re-sign or reword fixes it.
- **When:** every refusal seen came in one window, on 2026-10-20 between 05:35 and 21:59 UTC. A scan of every gitlab-org MR updated on or after 2026-10-19 (6728 MRs, each MR's `merge_error` and every page of its notes, read on 2026-10-22) found 160 refused MRs (94 in gitlab-org/gitlab): 159 by a refusal note, the first at 05:35 UTC (gitlab-org/editor-extensions/gitlab-lsp!4441), the last at 21:59 UTC, and none earlier or later, and one by its `merge_error` alone, with no note, last updated at 15:24 UTC that day (gitlab-org/analytics-section/siphon!619). Some merges still went through inside the window, and squash merges on the merge trains went through again after it: gitlab-org/editor-extensions/gitlab-lsp!4409 at 22:42 UTC and gitlab-org/gitlab!262072 at 22:43 UTC, after six refusals (observed, 160). Met outside that window, it is not the usual behaviour: the fix below still applies, and give the time of the refusal when you ask.
- **Fix:** do not push, rebase, reword or re-sign anything, and do not change the squash setting: a push stops auto-merge or the merge train, and one that changes the diff removes approvals (references/review.md, section 9). Read the MR first: with auto-merge set and no merge train, a failed merge writes no note, leaves auto-merge set, and is tried again when the target branch moves, so it may already have merged; in a fast-forward or semi-linear project that does not rebase automatically, a target branch move instead aborts auto-merge with a note (enforced). Otherwise comment once and ask the maintainer to merge it again, or to add it to the merge train again. Of the 137 refused MRs in the scan that have merged since, 111 merged with no commit added after the first refusal, one of them after six refusals (observed, 137). If it keeps failing, say so with the times and leave it to the maintainer whether to merge without squash where the project allows it (not where squash is required), which leaves the merge commit, authored by whoever merges, as the only commit GitLab signs (enforced). One comment is enough, for example:

  ```text
  @<maintainer> the merge stopped on a pre-receive check: "For signed Web
  commits, the commit must be equal to the author". The pipeline is green,
  the approvals stand and the branch is unchanged. Could you merge it again
  (or add it to the merge train again) when you have a moment?
  ```

- **Who:** member.
- **Evidence:** gitlab-org/gitlab:lib/gitlab/checks/commits_check.rb@2271d5086ba5c354781fa1cf1e05ea45c4aeadce ; gitlab-org/gitlab:lib/gitlab/checks/base_single_checker.rb@79c01aa5bbdaa50b18a9e43aa157e40305194981 ; gitlab-org/gitlab:app/services/merge_requests/merge_service.rb@acc196ed585122f83d47bb981ec56ea77f7335e6 ; gitlab-org/gitlab:ee/app/services/merge_trains/refresh_merge_request_service.rb@fad36962fd6f667d054bf92c83672fe4e89a4566 ; gitlab-org/gitlab:app/services/merge_requests/refresh_service.rb@9d5a0d246a6114b1ae080556fbc1540c9842d1df ; gitlab-org/gitlab:app/services/merge_requests/merge_strategies/from_source_branch.rb@b6943a23cdda748ee603e5a786bb6b228ffd837c ; gitlab-org/gitlab:ee/app/services/merge_requests/merge_strategies/from_train_ref.rb@3500dc0d3886e53609d53c3d1725281a52ecc286 ; gitlab-org/gitaly:internal/gitaly/service/operations/squash.go@bd3bba454181f52331cca441b3417bbd2de4b1cb ; gitlab-org/gitlab:lib/gitlab/gitaly_client/commit_service.rb@0209e17f12b6124b6d763ff7e68d87b993af2722 ; gitlab-org/gitlab:ee/lib/ee/gitlab/checks/push_rules/commit_check.rb@2b6fdcbf124696e75252e941350df9a5803eb02f ; gitlab-org/gitlab:doc/user/project/repository/push_rules.md@09ba600438db35dc76c8050b4788ece126ea8ee9 ; gitlab-org/gitlab:doc/user/project/merge_requests/squash_and_merge.md@0457b888ebac21085d1e8a48d1bfc283c38561c7 ; gitlab-org/gitlab:doc/api/merge_requests.md@d1cd3e49cc14259dcb7cccc3f78d081a27fa34ea ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/262072 (refused six times on the merge train, then merged with the same commits) ; https://gitlab.com/gitlab-org/gitlab-shell/-/merge_requests/1618 (refused once at 09:06 UTC, then merged with the same commits at 20:19 UTC, inside the window) ; https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/4441 (the first refusal seen, at 05:35 UTC on 2026-10-20 on the merge train, then merged with the same commits on 2026-10-21) ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263335 (the last refusal seen, at 21:59 UTC on 2026-10-20) ; https://gitlab.com/gitlab-org/analytics-section/siphon/-/merge_requests/619 (the text in `merge_error` only, with no note, the MR last updated at 15:24 UTC on 2026-10-20) ; https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/4409 (a community squash merge on the train after the window) ; https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5465 (no merge train: auto-merge set at 10:12 UTC on 2026-10-20, its pipeline green at 10:38 UTC, no note while the target branch moved that day, merged with the same commits at 04:00 UTC on 2026-10-21, seconds after the target branch next moved) ; https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5449 (not refused: merged by auto-merge at 15:32 UTC on 2026-10-19, before the window, the squash commit authored by the MR's author and the merge commit by the maintainer who merged) ; https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7674 (not refused: a squash merge on the train after the window, its commits authored the same way)

### "Requested changes" stays after you pushed fixes

- **Cause:** a "requested changes" review blocks the merge until that same reviewer approves or removes their request, or a member who can merge bypasses it; your push does not lift it, a re-request does not lift it, and neither does a comment-only review from them (enforced; documented). Replies left as pending review comments are visible only to you, so the reviewer may not know you answered (observed, 3 and 2).
- **Fix:** submit your pending review, reply in each thread with the commit, then re-request that reviewer (not an approver, whose approval it removes) and say in one comment what changed. An agent re-requests with the `mergeRequestReviewerRereview` GraphQL mutation and a person with the Re-request review button in the right sidebar, expanded first on a narrow screen; see references/review.md, section 8. After the re-request the reviewer's state reads `unreviewed` again (observed, 1), which takes the MR out of your court for the inactivity bot and puts it back on their list; the block itself goes when they approve. If they are away, ask a maintainer in a comment to bypass the request.
- **Who:** contributor, then the reviewer or a member who can merge.
- **Evidence:** gitlab-org/gitlab:doc/user/project/merge_requests/reviews/_index.md@691170325429eed40cb4b61c188a5d37295e95c9 ; gitlab-org/gitlab:app/services/merge_requests/request_review_service.rb@8c5023ca3803ed42b32430c337113e405f48f98e ; gitlab-org/gitlab:app/graphql/mutations/merge_requests/reviewer_rereview.rb@00fb3e11e6b001cba41b2346821be6dffbdc3fa1 ; gitlab-org/gitlab:app/services/merge_requests/update_reviewer_state_service.rb@fb5c7cb67de8733c2b0c9c68786b30aa0668f782 ; gitlab-org/gitlab:ee/app/models/ee/merge_request.rb@dd2f08701e6273a23be652b281dfd8693ad7e681 ; gitlab-org/gitlab:ee/app/services/merge_requests/mergeability/check_requested_changes_service.rb@86fa5a3bca0d5f8b044f303e6f47161f9744bdb5 ; gitlab-org/gitlab:ee/app/services/merge_requests/destroy_requested_changes_service.rb@cdf6b00e744cfa42c10e60f741ba6803fad02221 ; gitlab-org/gitlab:ee/app/services/ee/merge_requests/refresh_service.rb@43d553b2e74bc5ee1e3e2b076f73a358e0b90805 ; gitlab-org/quality/triage-ops:lib/mr_court_helper.rb@837f6867275b316720365d4c94c2bc3307bc7972 ; https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7432 ; https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1554 ; https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7630

### "Conflicts need to be resolved"

- **Cause:** the default branch moved while the MR waited (observed, 3).
- **How to tell from a script:** the REST API's `has_conflicts` is true only while `merge_status` reads `cannot_be_merged`. When the target branch moves, a conflicting MR goes to `cannot_be_merged_recheck` and reads `has_conflicts: false` until GitLab checks it again, so treat `cannot_be_merged` and `cannot_be_merged_recheck` alike, and do not expect `detailed_merge_status` to say `conflict` while another check fails, since it names only the first failing check and the pipeline last (references/review.md, section 9) (enforced; observed, 1: gitlab-org/gitlab!260459 read `has_conflicts: false`, `cannot_be_merged_recheck` and `discussions_not_resolved` while it conflicted). A mergeable MR goes to `unchecked` instead, so in either state `has_conflicts: false` describes the target branch as it was at GitLab's last check (enforced; observed, 1: gitlab-org/gitlab!261732 read `unchecked` on 2026-10-24, while two MRs merged after it was opened, !258839 and !263603, had changed `lib/api/projects.rb`, which it changes too). To find what the default branch changed in your files since you last looked, do not filter the commits API by date: `since` compares commit dates, and a squash commit can carry a date from weeks before it reached the default branch, as 55b00cc0, dated 2026-10-01 and merged with !258839 on 2026-10-15, which `GET /projects/278964/repository/commits?ref_name=master&path=lib/api/projects.rb&since=2026-10-13T00:00:00Z` leaves out (observed, checked 2026-10-24). Compare from the commit you last checked against instead, with `git log <that commit>..<default branch> -- <file>` in a full clone. To name the conflicting files without touching your worktree, run `git merge-tree --write-tree --name-only --messages <default branch> <your head>`, which lists them and the `CONFLICT` messages (documented). In a shallow clone, do not trust `git log <base>..<default branch> -- <file>` to find the change that conflicts: git treats the oldest commit it has as having no parents, so that commit seems to add every file (documented).
- **Fix:** fetch the canonical default branch, rebase, keep both sides' intent, rerun the tests, force-push with lease, and reply naming what conflicted. Drop a commit that is already on the default branch rather than reverting it. For generated files (OpenAPI, GraphQL reference), regenerate instead of resolving by hand; where the generated file itself moved, the project file says how (in gitlab-org/gitlab, the GraphQL reference split into one page per kind).
- **Who:** contributor.
- **Evidence:** https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/7268 ; https://gitlab.com/gitlab-org/labkit/-/merge_requests/758 ; gitlab-org/gitlab:lib/api/entities/merge_request_basic.rb@177eeb763992d7237f59c959ed2a61edb309fc79 ; gitlab-org/gitlab:app/models/merge_request.rb@b30ae611be431291816fb70e6678d011dae4e6fc ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/260459 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261732 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/258839 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263603 ; https://gitlab.com/gitlab-org/gitlab/-/commit/55b00cc0bc7cacc850bf28753e430fb01d1df652 ; https://git-scm.com/docs/git-merge-tree ; https://git-scm.com/docs/gitglossary#def_shallow_repository

## Danger

### Commit message errors in `danger-review`

- **Cause:** the commit linter (subject case, length, period, body wrap, short references, emoji, fixup or suggestion commits) (enforced; observed, 40).
- **Fix:** rewrite the commits (references/commits-and-descriptions.md) and force-push, before approval if you can: the force-push aborts auto-merge or the merge train, and removes approvals wherever it also changes the diff (references/review.md, section 9).
- **Who:** contributor.
- **Evidence:** gitlab-org/ruby/gems/gitlab-dangerfiles:lib/gitlab/dangerfiles/commit_linter.rb@c64980c95b97f830f7801675d5ccc71a210a9bfa

### "Labels missing: please ask a reviewer or maintainer to add ..."

- **Cause:** Danger's token cannot label MRs from your fork (enforced; observed, 66).
- **Fix:** add the allow-listed labels in one `@gitlab-bot label` comment; leave the rest to the reviewer. It is a warning, not a failure.
- **Who:** contributor, then member.
- **Evidence:** gitlab-org/ruby/gems/gitlab-dangerfiles:lib/danger/rules/z_add_labels/Dangerfile@366450b0266e5e984eaa2f7e0d78402dca5c07e6

### Danger asks for a database review, or posts an inline bulk database action reminder

A "Database review" section with suggested database reviewers, a "Database
team" message, or an inline note on an `insert`, `update`, `upsert`, `delete`
or `destroy` line (gitlab-org/gitlab).

- **Cause:** the MR changes database files or queries, or carries the `database` label (enforced).
- **Fix:** put the full SQL the application runs and its query plans in the description, as the database review guide asks. Database Lab is for team members only: give plans from a local database seeded with realistic data and say so, or give the raw SQL and ask the database reviewer to produce the plans. Add `~database` yourself with `@gitlab-bot label ~database` if it is missing; `database::review pending` is not on the bot's allow-list, so leave it to Danger or the reviewer. Request the database review after the backend reviewer approves, from the database section Danger posts. Reply in the inline thread with what you did, then resolve it. If the change touches no queries or migrations, say so, remove the label with `@gitlab-bot unlabel ~database` and ask for the `danger-review` job to be rerun, as Danger's own note says. Details are in references/projects/gitlab-org__gitlab.md (Database review).
- **Who:** contributor, then member for the review and the job rerun.
- **Evidence:** gitlab-org/gitlab:danger/database/Dangerfile@46d16a140c38dc174e76b67c6eded0dc859c80a8 ; gitlab-org/gitlab:doc/development/database_review.md@46d16a140c38dc174e76b67c6eded0dc859c80a8 ; gitlab-org/quality/triage-ops:triage/processor/community/command_mr_label.rb@46a4823632f3401513d233b99137d836d520e2ad ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/258526

### "Danger cannot run without API access", `secrets_provider_not_found`, `runner_configuration_error`, or "Danger has errored ... 403 Forbidden"

- **Cause:** the fork pipeline has no Danger token (observed, 8).
- **Fix:** check whether the job is allowed to fail; if it blocks, say so in the MR and ask for a canonical pipeline. The community fork usually runs Danger without your own token; where no `danger-review` job appears at all, the project runs Danger only in canonical pipelines by a CI rule (references/bots.md, section 2).
- **Who:** member.
- **Evidence:** https://gitlab.com/gitlab-org/ruby/gems/labkit-ruby/-/merge_requests/381 ; gitlab-community/meta:README.md@6f1c3fd623d90bdafdec81d8fd0977bf2dd03947

## GitLab Duo

### DCR4003 "you don't have permission to create a pipeline for Code Review Flow"

- **Cause:** you requested Duo yourself without a role in the project. The review runs as the Code Review Flow's service account, but GitLab first checks the requester's permission to create its pipeline, which takes the Developer role (enforced and documented; observed, 202; references/bots.md, section 3).
- **Fix:** use the platform's Request review, which has gitlab-bot request Duo, so GitLab checks gitlab-bot's permission to create the review pipeline, not yours; prefer it to asking a member, including for a new Duo review after Duo requested changes (the Duo "requested changes" entry below). Do not retry in a loop; it does not block the merge. A Duo review is not what the MR waits for: it still needs a human reviewer in Reviewers, because an MR only Duo reviewed stays in your court and is closed as "not sent for review" (enforced; references/why-mrs-get-closed.md, section 2). Request one with `@gitlab-bot ready @<reviewer>` or the platform (references/review.md, sections 2 to 4).
- **Who:** contributor (platform) or member.
- **Evidence:** gitlab-org/gitlab:doc/user/duo_agent_platform/flows/foundational_flows/code_review/troubleshooting.md@bd609ec96c351ca7bd412d72adf566bb6554c407 ; gitlab-org/gitlab:doc/user/duo_agent_platform/flows/foundational_flows/code_review/_index.md@80a8241c9b6b47980a23f939975a166fdd9aef81 ; gitlab-org/gitlab:ee/app/services/ee/merge_requests/base_service.rb@00fb3e11e6b001cba41b2346821be6dffbdc3fa1 ; gitlab-org/gitlab:ee/app/services/ai/duo_workflows/create_workflow_service.rb@5fbbff89ebd17c1fef1cd558575069cf88718f83 ; gitlab-org/gitlab:ee/app/services/ai/duo_workflows/code_review/failure_message_resolver.rb@7b2e25fcdd07b8f02818043cd2d2fb7bab1a59b2 ; gitlab-org/gitlab:ee/app/services/ai/duo_workflows/start_workflow_service.rb@a7c66e0edf372fa8e5767fbbe709ec6ef0c94642 ; gitlab-org/quality/triage-ops:lib/mr_court_helper.rb@837f6867275b316720365d4c94c2bc3307bc7972 ; gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_merge_request_controller.rb@a8b2e17709713e9b4c5cf18dc12c7dac7dc56d4e ; gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ; https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3148

### DCR4004, DCR4002 or DCR4010, other DCR codes, "Failed to start the Duo workflow"

- **Cause and fix:** see the error table in references/bots.md, section 3. "Failed to start" on every reply means your reply mentioned Duo and started a session; reply without mentioning it (observed, 3).
- **Who:** depends on the code.
- **Evidence:** gitlab-org/gitlab:doc/user/duo_agent_platform/flows/foundational_flows/code_review/troubleshooting.md@bd609ec96c351ca7bd412d72adf566bb6554c407

### Human approvals, but Duo's "requested changes" still blocks

- **Cause:** where "Duo can approve and request changes" is on, Duo's request blocks like a person's until Duo approves a later review or someone who can merge bypasses it (documented; observed, 13). Re-requesting Duo yourself, with the mutation or the sidebar button, goes through and then answers `DCR4003`, so no later review comes from it (references/review.md, section 8).
- **Fix:** fix or reply in each Duo thread first, in plain text: the follow-up review reads only Duo's threads and the replies in them. Push the fix before you ask, since a review asked for before the push reads the old head and keeps the block (observed, 1, gitlab-org/gitlab!266340). Then request the new Duo review yourself on the platform's manage-merge-request page (`https://contributors.gitlab.com/manage-merge-request?action=review&projectId=<id>&mergeRequestIid=<iid>`, linked from gitlab-bot's welcome note; references/review.md, section 3): make sure "Request review from GitLab Duo AI" is ticked, untick each person you do not mean to re-request (never an approver), and submit once, not within an hour of an earlier request with Duo. Its hidden `@gitlab-bot ready @GitLabDuo` line has gitlab-bot re-request Duo, a reviewer already listed, so GitLab checks gitlab-bot's permission to create the review pipeline, not yours (enforced). When that review finds nothing, Duo approves, and the approval lifts its request; it does not count toward the required approvals, so the human reviewers still approve (documented). Use this rather than asking a maintainer to request Duo again or to bypass it, and ask for a bypass only if Duo keeps requesting changes that the human reviewers agree to leave (observed, 1, and a maintainer's recommendation: on gitlab-org/api/client-go!3147 on 2026-10-21, the platform's request, note 4061201228 at 18:47 UTC, was followed seven seconds later by gitlab-bot's "requested review from @GitLabDuo", note 4061202004, and within six minutes by Duo's review, note 4061242147, and its approval, note 4061242865, after which the MR read `not_approved`, waiting on the human approval, instead of `requested_changes`. On client-go!3148 the same day a maintainer re-requested Duo when the author asked, and wrote in note 4060585061 that permission problems like this one can usually be handled through the platform, which can request reviews, Duo included).
- **Who:** contributor; a member only for a bypass.
- **Evidence:** gitlab-org/gitlab:doc/user/duo_agent_platform/flows/foundational_flows/code_review/_index.md@80a8241c9b6b47980a23f939975a166fdd9aef81 ; gitlab-org/gitlab:doc/user/duo_agent_platform/flows/foundational_flows/code_review/troubleshooting.md@bd609ec96c351ca7bd412d72adf566bb6554c407 ; gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_merge_request_controller.rb@a8b2e17709713e9b4c5cf18dc12c7dac7dc56d4e ; gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/pages/manage-merge-request-page/RequestReviewAction.vue@840936a0d635a76536946883caa39b6567439d05 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/266340#note_4120148413 ; gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ; https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3147 ; https://gitlab.com/gitlab-org/api/client-go/-/merge_requests/3148

### Duo repeats a finding you resolved, or misses code in a large MR

- **Cause:** follow-up reviews read only Duo threads and their replies, so a resolved thread without a reply is still outstanding; large MRs exceed Duo's context limits (documented).
- **Fix:** reply with what you checked before resolving; split large MRs.
- **Who:** contributor.
- **Evidence:** gitlab-org/gitlab:doc/user/duo_agent_platform/flows/foundational_flows/code_review/troubleshooting.md@bd609ec96c351ca7bd412d72adf566bb6554c407

### Duo features in the community fork stop partway through the month

- **Cause:** the 500-credit monthly cap per member (documented).
- **Fix:** wait for the 1st, or ask on your onboarding issue for a raise linked to the work.
- **Who:** contributor.
- **Evidence:** gitlab-community/meta:docs/duo-usage-guidelines.md@6f1c3fd623d90bdafdec81d8fd0977bf2dd03947

## Security bot

### GitLab-Security-Bot reports policy violations

- **Cause:** a scan result policy found something, or (from a personal fork) the required security reports were missing (observed, 71).
- **Fix:** fix findings your change introduced. Missing-report or warn-mode notes on personal-fork MRs go away with a community fork or canonical pipeline; do not change code for them.
- **Who:** contributor, or nobody.
- **Evidence:** https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/71

## Contributor platform

### The manage-issue page shows no Assign button, refuses the issue, or answers that you are not authorized

- **Cause, one of:** your onboarding request is not approved yet, so you are neither an approved community member nor a team member (the page's API answers 403); you already hold as many issues as your level allows (4 at level 0 up to 16 at level 3, 100 from level 4); the issue is marked blocked; or the issue is in a project outside `gitlab-org`, `gitlab-com`, `gitlab-community` and `components`, which the page's issue lookup does not accept (enforced).
- **Fix:** check your onboarding issue's `access-request::` label and wait for approval; unassign yourself on the same page from issues you no longer work on; for a blocked issue, ask in the issue whether work can start; outside those namespaces, ask in the issue to be assigned. Do not try `/assign` or the API instead: without a role they do nothing.
- **Who:** contributor; a team member for approval or assignment outside the four namespaces.
- **Evidence:** gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/concerns/manageable_concern.rb@f39cc821eff099faecf62980cc9ab44d9cd272a4 ; gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/pages/manage-issue-page/WorkAction.vue@fd4fd9323a309be5acae7cf5b29167164f46753f ; gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/common/Constants.js@d2b6b66020a4e1521027d251d864d810108f1497 ; gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/common/IssueUrlRegexUtils.js@e149e13f1d1ce4a83029d2dd9f1d1d738b8b8825

### No gitlab-bot reply after the platform's Request review

- **Cause:** usually none. The platform's thread requests the people you ticked or typed with its own `/request_review`, and gitlab-bot replies in it only to the hidden Duo line. No reply means Duo was not included, the project has its own review process, or a request with Duo came within an hour of an earlier one on the same MR (enforced; observed, 0 replies on 21 requests without Duo, and 3 of 29 with Duo unanswered, each a repeat within the hour; omnibus-gitlab!9929, outside that sample, for a project with its own review process).
- **Fix:** check the "requested review from @<name>" system note by the `contributors.gitlab.com` account and the Reviewers list (references/review.md, section 5). If the person you chose is listed, the request worked: resolve the thread once nothing in it is pending. If Reviewers lists only GitLabDuo, no person was asked, so request one. Do not repeat the platform request just to get a reply.
- **Who:** contributor.
- **Evidence:** gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_merge_request_controller.rb@a8b2e17709713e9b4c5cf18dc12c7dac7dc56d4e ; gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/services/gitlab/rest/notes.rb@86a13b160a682e964a6307a8c7d18074303deb57 ; gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867275b316720365d4c94c2bc3307bc7972 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263036 ; https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9929

## Silence, nudges and closes

### Weeks with no review

- **Cause:** nobody was ever asked (only Duo, or the request failed), the reviewer is overloaded or away, or the MR sits in a group that does not own the project (observed, 155).
- **Fix:** confirm a human reviewer is listed. After about a week of silence mention them once; after two, ask for another reviewer with `@gitlab-bot ready @<other>` or `@gitlab-bot help`. See references/review.md, section 10.
- **Who:** contributor.
- **Evidence:** gitlab-org/quality/triage-ops:policies/community/hygiene/ping-inactive-reviewers.yml@e0f9071dc93f7668929e346b32801ba1f5d31f1a ; gitlab-org/quality/triage-ops:lib/mr_reviewer_response_helper.rb@f678c194f285e077f635dfd7b09fcc37407c2b62

### Inactivity nudges, then "we're closing this for now since it's been quiet"

- **Cause:** 7 days without human activity makes the MR idle and 30 days stale; while it is in your court (draft, conflict, failed pipeline, requested changes, no human reviewer) the bot nudges at most weekly and closes it once stale (enforced; the counts, with the sample they come from, are in references/why-mrs-get-closed.md, sections 1 and 2).
- **Fix:** do what the first sentence of the nudge says. Reopen a closed MR when you resume, remove the reason in the same sitting, and request review. See references/why-mrs-get-closed.md.
- **Who:** contributor.
- **Evidence:** gitlab-org/quality/triage-ops:policies/community/hygiene/ping-inactive-author.yml@adcb2783c84e20eaf3fef193df65c4a40551785a ; gitlab-org/quality/triage-ops:policies/stages/hygiene/close-stale-community-contributions.yml@6acf2943033faf15ea02b61ec5bdd311a420d86e ; gitlab-org/quality/triage-ops:lib/mr_court_helper.rb@837f6867275b316720365d4c94c2bc3307bc7972

### Closed again a few days after you reopened it

- **Cause:** reopening by you or a team member removes `idle` and `stale` (enforced), so a quick re-close usually means the MR became idle again while still in your court, for example with a reviewer's "requested changes" standing, or the labels stayed because someone else reopened it (observed, 1).
- **Fix:** after reopening, remove the reason in the same sitting: re-request review from the reviewer who requested changes (references/review.md, section 8), which resets their state so the bot no longer counts the MR as in your court for it, or request a new one. If you wait on something outside your control, ask a maintainer to add `automation:prevent-auto-close`.
- **Who:** contributor, then member.
- **Evidence:** gitlab-org/quality/triage-ops:triage/processor/community/remove_idle_labels_on_activity.rb@b4d49ec8be9223319bdaecfdaf3574698bb168a3 ; gitlab-org/quality/triage-ops:lib/mr_court_helper.rb@837f6867275b316720365d4c94c2bc3307bc7972 ; gitlab-org/gitlab:app/services/merge_requests/request_review_service.rb@8c5023ca3803ed42b32430c337113e405f48f98e ; https://gitlab.com/gitlab-org/cli/-/merge_requests/1765

### Nudged while you wait on something outside your control

A freeze, a dependency MR, a product decision, or the base of a stacked MR.

- **Cause:** the bot cannot see the reason (observed, 7).
- **Fix:** say in the MR what you are waiting for and link it, and ask a maintainer for `automation:prevent-auto-close`; otherwise agree to close and reopen later.
- **Who:** member.
- **Evidence:** https://gitlab.com/gitlab-org/container-registry/-/merge_requests/2932 ; https://gitlab.com/gitlab-org/gitaly/-/merge_requests/8803

## MR mechanics

### You opened an MR by accident, or it exposed a secret

- **Cause:** the new MR form targets the upstream project from a fork; web edits and Duo's "Fix failing pipeline" button also create MRs (observed, 44).
- **Fix:** close it yourself with a one-line note. If it contained a secret, revoke the secret: closing does not remove it.
- **Who:** contributor.
- **Evidence:** gitlab-com/content-sites/handbook:content/job-description-library/expert/merge-request-coach.md@877b9494a705060060f63c5ee5b11d4ee9a5a1b1 ; https://gitlab.com/gitlab-org/gitlab-pages/-/merge_requests/1330

### The MR suddenly shows no changes

- **Cause:** the branch was reset to or merged from the default branch, or the MR was opened before anything was pushed (observed, 17).
- **Fix:** restore your commits from `git reflog`, force-push, and check the Changes tab before asking for review. Never open placeholder MRs.
- **Who:** contributor.
- **Evidence:** https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/5464

### Wrong source or target

An MR from the wrong fork, against the fork's default branch, or against a
non-default branch.

- **Cause:** the source project of an MR cannot be changed; the community forks close MRs targeting their default branch (enforced).
- **Fix:** open a replacement from the right fork against the canonical default branch with the same title and description, link it from the old one, and close the old one.
- **Who:** contributor.
- **Evidence:** gitlab-community/meta:.triage-policies-fork-mrs.yml@a14a629fd45c0142bb65c96fa2dfa37c0eea546d ; https://gitlab.com/gitlab-org/glql/-/merge_requests/85

### A stacked MR cannot target your other MR's branch

- **Cause:** an MR in the canonical project can only target canonical branches (observed, 1).
- **Fix:** branch from the first MR's branch, target the default branch, say in the description that it contains the first MR's commits and merges after it, make it depend on the first MR through merge request dependencies, and once the first one merges, rebase with `git rebase --onto upstream/<default> <the first MR's commit yours start from>` before you ask for its review: where the squash template is `%{first_commit}`, a stacked MR merged without that rebase would take the first MR's first commit message as its own squash message (references/commits-and-descriptions.md, Linking the issue).
- **Who:** contributor.
- **Evidence:** https://gitlab.com/gitlab-org/fleeting/fleeting/-/merge_requests/98 ; https://git-scm.com/docs/git-rebase ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/265240

### The platform's review request un-drafted your MR

- **Cause:** Request review marks the MR ready as part of the request (enforced; observed, 1).
- **Fix:** mark it draft again and tell the reviewer what you are waiting for; request review when it is ready.
- **Who:** contributor.
- **Evidence:** gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_merge_request_controller.rb@a8b2e17709713e9b4c5cf18dc12c7dac7dc56d4e ; https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/merge_requests/3236

### The API says the MR closes no issues although the description says `Closes ...`

- **Cause:** the `closes_issues` list can stay empty for work item references (observed, 3).
- **Fix:** judge by the description and the `linked-issue` label, not by that list.
- **Who:** nobody.
- **Evidence:** gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/queries/hackathon_leaderboard_query.rb@0aab5e7e93f587748ab6cd91f42b6fcfb1fc0422 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261343 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/261288

### The MR merged but the issue it said it closes is still open

- **Cause:** the project has "Auto-close referenced issues on default branch" off; gitlab-org/gitlab, release-tools, design.gitlab.com and step-runner do (enforced, project setting; observed, 8).
- **Fix:** close the issue yourself if you opened it, with a one-line note naming the MR and the release; otherwise say in the issue that the MR merged. See references/workflow.md, section 14.
- **Who:** contributor (the issue's author), otherwise its author or a team member.
- **Evidence:** gitlab-org/gitlab:doc/user/project/issues/managing_issues.md@e3e279695f8b03b7572dd17f8ee1758ded425e77 ; https://gitlab.com/gitlab-org/gitlab/-/merge_requests/263025

### A linked issue or work item answers 404 for you

Someone links an issue, for example in "Duplicate of <link>", and the link,
the REST API and GraphQL show you nothing.

- **Cause:** the API answers `404 Not Found` both for an item that does not exist and for one you are not allowed to see, such as a confidential issue, so from outside the two look the same (documented).
- **Fix:** do not guess why. Ask in the thread whether it covers the same problem, and do not point your MR's `Closes` line at an item you cannot read. Do not restate the defect's details in that reply either: an item you cannot see may be an unpublished security report (references/workflow.md, section 1).
- **Who:** contributor; a member who can see the item says what it covers.
- **Evidence:** gitlab-org/gitlab:doc/api/rest/troubleshooting.md@e24f1a5d4e325ecbc65f361bb19cd7e6de722429

### `git fetch` answers "GitLab is currently unable to handle this request due to load"

- **Cause:** gitlab.com refused an anonymous git request to a very busy repository, gitlab-org/gitlab first among them. The refusal comes inside the git protocol (`fatal: remote error: GitLab is currently unable to handle this request due to load (ID ...)`), not as an HTTP error or a `429`, while the REST and GraphQL APIs answer normally, and it is no block on your account. The same fetch sent with credentials went through where anonymous ones kept failing; that fits a concurrency limit that counts anonymous requests by client address, which every agent on one host shares, and authenticated ones by user, but GitLab's configuration was not read (observed, 1 evening: 3 of 3 authenticated fetches went through between anonymous refusals). A credential helper alone does not help: git sends credentials only after a `401`, and an anonymous fetch of a public repository never gets one.
- **Fix:** send credentials to gitlab.com up front: an `Authorization: Basic` header built from your username and a token with `read_repository`, set as `http.https://gitlab.com/.extraHeader` through environment variables, so that the token reaches no command line and no file: `GIT_CONFIG_COUNT=1`, `GIT_CONFIG_KEY_0=http.https://gitlab.com/.extraHeader` and `GIT_CONFIG_VALUE_0="Authorization: Basic $(printf '%s:%s' <username> "$TOKEN" | base64 | tr -d '\n')"` (documented). Or fetch the same branch from your community fork's remote, whose default branch mirrors the canonical one (references/workflow.md, section 6). Retry with a growing pause, never in a tight loop.
- **Who:** contributor.
- **Evidence:** https://git-scm.com/docs/git-config#Documentation/git-config.txt-httpextraHeader ; https://git-scm.com/docs/git-config#Documentation/git-config.txt-GITCONFIGCOUNT

### The REST API answers 429 Too Many Requests

When you, or an agent working for you, read gitlab.com through the API in a
loop or in parallel.

- **Cause:** gitlab.com rate limits are per user and per top-level group, and depend on the plan; a throttled answer is `429` with a `Retry-After` header giving the seconds to wait (documented).
- **Fix:** wait the seconds `Retry-After` names before the next request, page with `per_page=100` instead of fetching item by item, and keep parallel readers few. A 429 is not a refusal of your change.
- **Who:** contributor.
- **Evidence:** gitlab-org/gitlab:doc/user/gitlab_com/rate_limits.md@47dedfb0a40c303092dc16d44f728c67b5c6512e

### A search through the API answers `500` or "Request timed out", or a page of notes is short

- **Cause:** broad list searches are too slow for gitlab.com: a gitlab-org/gitlab merge request search without `state` timed out, and a group-wide `GET /groups/gitlab-org/issues?search=...` answered `500` (observed, checked 2026-10-22). A short page of notes is a different thing: the notes endpoint drops the notes you may not see after it cuts the page, so a page can be short while more follow (enforced).
- **Fix:** search per project with `state` set, narrowed with `created_after` if needed, or use the search API (`GET /groups/:id/search?scope=issues` or `scope=merge_requests`); never read an error as "no duplicates". For notes, follow the `Link` header or `x-next-page` to the end (references/workflow.md, section 3; references/review.md, section 5).
- **Who:** contributor.
- **Evidence:** gitlab-org/gitlab:doc/api/search.md@1802481cbb21dde958cefe4239254e2bcca0017a ; gitlab-org/gitlab:lib/api/notes.rb@f7682fd3f423bb94cb5f4d60bf05a15f180b31c0

### An API answer carries a `message` or `error` key, or the repository tree answers `404`

When you, or an agent working for you, read the API before writing (a search,
a project's rule files, a reviewer's status) and act on what came back.

- **Cause:** the API reports an error by its HTTP status. An error body carries `message`, a string or an object of field errors (documented), or, for a parameter that failed validation, `error`: `GET /projects/278964/issues?state=bogus` answers `400` with `{"error":"state does not have a valid value"}` (observed, read 2026-10-26). Commits, annotated tags and user statuses have a `message` field of their own, so a `message` key proves nothing (documented). Since GitLab 17.7 a path that does not exist answers `GET /projects/:id/repository/tree` with `404` (`invalid revision or path`), not with an empty list (documented). A ref that does not exist answers `404 Tree Not Found` there, and the files API (`GET /projects/:id/repository/files/:file_path`) answers `404 File Not Found` for a file the ref does not have, such as an `AGENTS.md` the project never added, and `404 Commit Not Found` for a ref that does not exist (observed, read 2026-10-26).
- **Fix:** tell an error by the HTTP status, never by a `message` key. A `404` for a path on a ref that exists means the path is not there (the tree's `invalid revision or path`, the files API's `File Not Found`), not a failed read; a `404` for the ref itself (`Tree Not Found`, `Commit Not Found`) means the ref is wrong; and do not read a timeout or a `5xx` as an empty result (references/workflow.md, sections 3 and 7).
- **Who:** contributor.
- **Evidence:** gitlab-org/gitlab:doc/api/rest/troubleshooting.md@e24f1a5d4e325ecbc65f361bb19cd7e6de722429 ; gitlab-org/gitlab:doc/api/commits.md@a2ea8aaf67d442b6c89e85a0a417cac11ba6e5f1 ; gitlab-org/gitlab:doc/api/tags.md@23938ffc921f8d28aade515e07b9891dfde8623c ; gitlab-org/gitlab:doc/api/users.md@037fd3dec6a6786bf5f9b651cf4f1db70b7a094e ; gitlab-org/gitlab:doc/api/repositories.md@a18d3595045bb9973826fd645ce662689bc8e5d1

## To-Do List

### The To-Do badge keeps growing although everything is answered

- **Cause:** GitLab clears few To-Dos by itself. Merging or closing an MR resolves, for everybody, only `assigned`, `approval_required`, `review_requested`, `added_approver` and `build_failed`, and `merge_train_removed` on a merge; any other To-Do only for the person who merges or closes, and closing an issue only the closer's. No job clears them later: they go only when you lose access or the item is deleted. So a note that mentions you after the merge, such as gitlab-bot's feedback request seconds after it (references/workflow.md, section 14), leaves a To-Do nothing will clear. A reply inside a thread clears only the To-Dos born in that thread (references/review.md, section 7). Every pending To-Do of yours on the item, unread mentions included, is cleared by: a standalone top-level note (`individual_note: true`); a reaction on the MR or issue or on a standalone top-level note (on a note in a thread, only that note's; on a diff note, all of them, read from the code and not observed); a push to the source branch; approving or submitting a review; editing the title, description, labels, assignees, reviewers, milestone or target branch; and anyone retrying a job of the MR. Re-requesting review, resolving a thread (outside designs), system notes and a pipeline that passes clear nothing (enforced; observed on one contributor's list over two weeks: most pending To-Dos came from automation and sat on merged or closed items).
- **Fix:** mark done what is settled, and only that. Marking done is silent, with no notification, email, system note or webhook, and can be undone (enforced).
  - **Settled:** on a merged item, a To-Do after which no person asks you anything unanswered, no thread waits on you and no promise of yours lives only there; read a closed MR, or an issue somebody else closed, before you decide. Automation's notes on sight: gitlab-bot's post-merge feedback request and its nudges, the platform's claim greeting and hand-off, its ready echo and review request acknowledgement, a Duo review that found nothing, release notes. On an open item: a `mentioned` or `directly_addressed` once you answered in the thread of the note its `target_url` names (`#note_<id>`), or when that note asks nothing; a `review_submitted` once every thread of that review has your answer (one can come after the merge, from a late draft); the platform's `assigned` on an issue once your MR that closes it is open, green and has a reviewer; a `build_failed` once the latest pipeline is green or a note the reviewer will see explains the failure.
  - **Never:** a review point or question you have not answered, a failed Duo review not asked for again, a red pipeline nobody explained, a suggestion you neither took nor declined, or a To-Do that is the only reminder of a promise of yours ("I'll open a follow-up MR") until you keep it or write it down where you will see it. A thanks needs no answer; a reaction on it, if you want one, also clears its To-Do. Before a bulk clear, classify, then read each item again: on one list a second reading moved several first-pass verdicts back to owed, most of them promises (observed).
  - **Do not post, react or push only to clear a To-Do.** It reaches other people, and notes count against the `notes_create` rate limit. The exception is a reaction that is the answer a note asks for, as on gitlab-bot's feedback request; since it clears every To-Do of yours on that MR, give it after you have read everything since the merge.
  - **Commands.** Writing needs a token with the `api` scope, since GraphQL refuses any mutation to a `read_api` token. List with `GET /api/v4/todos?state=pending&per_page=100&page=<n>`, which filters by `action`, `author_id`, `project_id`, `group_id` and `type` but not by item, so match `target.references.full`; one item's, with `read_api` enough, with `glab api graphql -f query='query { project(fullPath: "<group/project>") { mergeRequest(iid: "<iid>") { currentUserTodos(state: pending) { nodes { id action body targetUrl } } } } }'` (`issue(iid:)` for an issue). Mark one with `POST /api/v4/todos/<id>/mark_as_done`, which is idempotent, and up to 100 of your own at once with `glab api graphql -f query='mutation { todoResolveMany(input: {ids: ["gid://gitlab/Todo/<id>"]}) { todos { id state } errors } }'`, an experiment since GitLab 17.9. `todosMarkAllDone(input: {targetId: "gid://gitlab/MergeRequest/<id>"})` marks all of one item, by its `id`, not its `iid`; with no filter it marks everything. Undo with `todoRestoreMany(input: {ids: [...]})`, which has no REST route, so keep the ids you marked. In the browser: select the items in the To-Do List, then Mark as done (enforced; documented).
  - **Never** `POST /api/v4/todos/mark_as_done` without an id, which marks every pending To-Do, and do not snooze instead: a snoozed To-Do leaves the count and comes back when the snooze ends (enforced).
- **Who:** contributor.
- **Evidence:** gitlab-org/gitlab:app/services/todo_service.rb@67dccbf8b0e0af92d7375620c8c46dd42769f25a ; gitlab-org/gitlab:ee/app/services/ee/todo_service.rb@4906f08d3a3c457c348f475c7ec9d3d118454626 ; gitlab-org/gitlab:app/models/todo.rb@6c5596c4a6933fa73302f8a9f5aa18a593847e18 ; gitlab-org/gitlab:app/finders/pending_todos_finder.rb@e6e1a52c017f7fbc22c60b13b9b99b2e13153d2c ; gitlab-org/gitlab:app/services/notes/create_service.rb@7c5649a7397c4179f89e811b7c684cc45a120204 ; gitlab-org/gitlab:lib/api/discussions.rb@cf586e11e8d923d42651d675a41a20835f96c634 ; gitlab-org/gitlab:app/services/award_emojis/add_service.rb@c3b33faee255ed040a47da72ba1328e6c39e5a54 ; gitlab-org/gitlab:app/models/diff_note.rb@3a0f809df8391314cfab5ab6a8e9cf33851d338b ; gitlab-org/gitlab:app/services/merge_requests/refresh_service.rb@9d5a0d246a6114b1ae080556fbc1540c9842d1df ; gitlab-org/gitlab:app/services/issuable_base_service.rb@dd0ef3eb41bb445de995efca1aa37c67068c297f ; gitlab-org/gitlab:app/services/ci/retry_job_service.rb@726730527f449df774f2eca7a7e1059420bd381e ; gitlab-org/gitlab:app/services/merge_requests/request_review_service.rb@8c5023ca3803ed42b32430c337113e405f48f98e ; gitlab-org/gitlab:app/services/discussions/resolve_service.rb@d17a928a274a87435fb2a681b67ad46cc2480573 ; gitlab-org/gitlab:app/models/note.rb@7eae2ef8e87fac3930242771ef57dfbb2644d408 ; gitlab-org/gitlab:app/graphql/graphql_triggers.rb@8b1dc9283a0446ecca2e8b9eaab6d16a1768e6e4 ; gitlab-org/gitlab:lib/api/entities/todo.rb@6d1007f6e1e14b76262d9b503b2a2b116d80e15b ; gitlab-org/gitlab:app/graphql/mutations/base_mutation.rb@85902a96027ab4f9a6d5799d31b87fcb80b4ec2a ; gitlab-org/gitlab:doc/api/todos.md@6495e33ce686019dc39f767e8d24f478752563eb ; gitlab-org/gitlab:lib/api/todos.rb@6495e33ce686019dc39f767e8d24f478752563eb ; gitlab-org/gitlab:app/graphql/types/current_user_todos.rb@d55c9d9b7666fba0312a01808ee8ee2269718b73 ; gitlab-org/gitlab:app/graphql/mutations/todos/base_many.rb@e727df8450910e6d53a7806a1df469f9f2ffc4c3 ; gitlab-org/gitlab:app/graphql/types/mutation_type.rb@3a22c0ffca37e1d0ec9c61544f31f32636b1d55d ; gitlab-org/gitlab:app/graphql/mutations/todos/mark_all_done.rb@7676f4fa3bee1ce22e43b901158f79de393ed090 ; gitlab-org/gitlab:app/graphql/mutations/todos/restore_many.rb@7676f4fa3bee1ce22e43b901158f79de393ed090 ; gitlab-org/gitlab:app/finders/todos_finder.rb@7bf22f0501198b19a581b2e1b04afa1f3b516f3a ; gitlab-org/gitlab:lib/api/helpers/notes_helpers.rb@f0961fa015a6a19df9f9056ffe9259dc8cd71686 ; gitlab-org/gitlab:app/assets/javascripts/todos/components/mutations/bulk_resolve_todos.mutation.graphql@1caabb48564f9ebbd9874934ccb412ee09052c7f ; gitlab-org/gitlab:doc/user/todos.md@12f5f9eb32aad92420cf86e7724a0de6369c4cab ; gitlab-org/quality/triage-ops:triage/processor/community/code_review_experience_feedback.rb@8765efcd87e41a34061c6c2e36596d19109e4f06 ; https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/57662
