# gitlab-org/quality/triage-ops

The automation behind gitlab-bot: reactive processors (a service that receives GitLab webhooks and runs every processor under `triage/processor/`, including the `@gitlab-bot` commands) and scheduled policies (gitlab-triage YAML under `policies/`, run by pipeline schedules). Reading its source is the reliable way to know what a bot command does.

| Fact | Value |
| --- | --- |
| Default branch | `master` |
| Language | Ruby 4.0.7 (the CI image and `.tool-versions`; `AGENTS.md` still says 3.3.7) |
| Fork to use | Community fork `gitlab-community/gitlab-org/quality/triage-ops` |
| Merge settings | Squash default on, squash message template `%{first_multiline_commit}`, merge trains on, pipeline must succeed, all threads must be resolved |
| Commit convention | gitlab-dangerfiles `commit_messages` rule |
| MR template | `.gitlab/merge_request_templates/Default.md` with an "Expected impact & dry-runs" section |
| Changelog | None: the Dangerfile excludes the changelog rule and there is no changelog file |
| Contributor docs | `AGENTS.md`, `CONTRIBUTING.md`, `REACTIVE.md`, `SCHEDULED.md`, `doc/processor_implementation.md` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Read `AGENTS.md` before you start: it gives the commands, the generated files, the custom cops and how to dry-run policies, and those match what CI enforces. Its Ruby version is out of date: it says 3.3.7 (and "Ruby 3.3" in its code style section), `.ruby-version` says 4.0.2, and CI's default image `ruby:4.0.7` and `.tool-versions` say 4.0.7, which is what the pipeline uses; work on 4.0.7. (documented; enforced; `gitlab-org/quality/triage-ops:AGENTS.md@cd686912`, `gitlab-org/quality/triage-ops:.gitlab-ci.yml@efdc7b5f`, `gitlab-org/quality/triage-ops:.tool-versions@17dd1ddd`, `gitlab-org/quality/triage-ops:.ruby-version@b35215d1`)
- Never write GitLab quick actions (lines starting with `/`) into comments the bot posts, and call the API through `Triage.api_client` rather than building a client. The custom cops `TriageOps/NoQuickActions` and `TriageOps/UseTriageApiClient` enforce both. (enforced; `gitlab-org/quality/triage-ops:AGENTS.md@cd686912`)
- After changing policies or job definitions, run `bin/generate_all_policies_and_jobs` and commit the generated files; the `regeneration-check` job fails otherwise. Also run `bin/check_frequency_job_limits`. If `regeneration-check` fails on files your MR did not touch, the default branch is out of date: say so in a note instead of committing someone else's regeneration. (enforced; `gitlab-org/quality/triage-ops:AGENTS.md@cd686912`, `gitlab-org/quality/triage-ops:lefthook.yml@918e935e`, [!4405](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4405))
- Run `bundle exec rspec` (lefthook also runs undercover on changed lines) and `bundle exec rubocop` before pushing. (documented; `gitlab-org/quality/triage-ops:AGENTS.md@cd686912`)
- Specs must not read protected CI variables; stub them. A spec that reads one passes on canonical pipelines and fails in every fork pipeline (KeyError on `GITLAB_BOT_API_TOKEN_ON_COM`). (observed, 3 MRs; [!4210](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4210), [!4259](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4259), [!4405](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4405))
- The `dry-run:custom` and `dry-run:schedule` jobs are manual and need protected tokens, so a maintainer runs them. Run your own dry run with `bundle exec gitlab-triage --debug --dry-run --token <your token>` against a project you own, and paste the output in the template's "Expected impact & dry-runs" section along with the projects and resources the policy touches. (documented; `gitlab-org/quality/triage-ops:AGENTS.md@cd686912`, `gitlab-org/quality/triage-ops:.gitlab/merge_request_templates/Default.md@5c5f833c`, [!4116](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4116), [!3648](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/3648))
- Explain why in the description, especially for a revert or removal: what broke, which issue or incident it relates to, and why reverting is right. A revert with no explanation was closed. (observed, 1 MR; [!3713](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/3713))
- No `Changelog:` trailer is needed. (enforced; `gitlab-org/quality/triage-ops:Dangerfile@11fbe595`)
- Choose the reviewer from the owners `.gitlab/CODEOWNERS` names for the whole project (the `@gl-dx/development-health` group and the project's maintainers); a reviewer suggested starting with the author of the issue the MR addresses. (observed, 1 MR; `gitlab-org/quality/triage-ops:.gitlab/CODEOWNERS@e02380dd`, [!4427](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4427))
- Open the MR from the community fork: from a personal fork every pipeline needed a team member to start it, and one ran out of compute minutes. (observed, 1 MR; [!4377](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4377))
- Target `master` from a branch made from it; an MR targeting a non-default branch showed 216 unrelated files and was closed. (observed, 2 MRs; [!4364](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4364), [!4059](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4059))

## Where bot behavior is defined

The README, `REACTIVE.md` and `AGENTS.md` summaries are shorter than the code and in one place wrong: they spell the review alias `request-review`, while the command accepts `ready`, `review` and `request_review`. When you need to know what a command or policy does, read these files:

| Behavior | File |
| --- | --- |
| `@gitlab-bot ready` (aliases, rate limit, no-changes wait, docs-only coach skip, projects that get no reviewer) | `triage/processor/community/command_mr_request_review.rb` |
| Command syntax (a command starts a line; arguments on the same line) | `triage/triage/reactive_command.rb` |
| Label allow list | `triage/processor/community/command_mr_label.rb` |
| `help`, `handoff`, `feedback`, `unassign_review` | `triage/processor/community/command_mr_*.rb` |
| Rate limit (default 60 per hour) | `triage/triage/rate_limit.rb` |
| Technical writer auto-request | `triage/processor/community/automated_review_request_doc.rb` |
| Projects with an external review process; the Distribution list URL | `lib/www_gitlab_com.rb` |
| Idle and stale labels, nudges, auto-close | `policies/stages/hygiene/*.yml`, `policies/community/hygiene/*.yml`, `lib/mr_court_helper.rb`, `lib/idle_mr_helper.rb` |
| Pipeline tier labels in `gitlab-org/gitlab` | `triage/processor/pipeline_tier_transitions.rb` |

(documented; `gitlab-org/quality/triage-ops:REACTIVE.md@f98daef9`, `gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867`)

## Troubleshooting

**Specs pass locally but fail in the fork pipeline with KeyError for `GITLAB_BOT_API_TOKEN_ON_COM`**
- Cause: the spec reads a protected variable fork pipelines do not receive.
- Fix: stub the variable. If the spec is not yours, point to the fix that added the stub, or ask a maintainer to run the pipeline.
- Who can fix it: you.
- Sources: [!4405](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4405)

**Your personal-fork pipeline does not start: `ci_quota_exceeded`**
- Cause: personal-fork pipelines use your own compute minutes.
- Fix: push to the community fork, open a new MR there, close the old one with a link.
- Who can fix it: you.
- Sources: [!4450](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4450)

**`dry-run:custom` or `dry-run:schedule` cannot be started from your MR**
- Cause: manual jobs that need protected tokens.
- Fix: run a local dry run and paste the output; ask a maintainer to run the protected job if needed.
- Who can fix it: a maintainer.
- Sources: `gitlab-org/quality/triage-ops:AGENTS.md@cd686912`

**`regeneration-check` fails on generated files your MR did not change**
- Cause: the default branch has policy changes whose generated files were not regenerated.
- Fix: do not commit the unrelated regeneration; say in a note that the failure comes from the default branch.
- Who can fix it: a maintainer.
- Sources: [!4405](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4405)

## Why MRs here were closed

- Research MRs carrying instructions aimed at the AI reviewer (and removing CI security jobs), which Duo flagged as prompt injection ([!4399](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4399) to [!4404](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4404)). Content aimed at steering automated reviewers is treated as abuse.
- Wrong target branch or base ([!4059](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4059), [!4364](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4364)); a revert with no reason ([!3713](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/3713)).
- Duplicates during a hackathon ([!4425](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4425), [!4426](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4426), [!4444](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4444)).
- Stale after needing a maintainer dry run ([!3648](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/3648)); moved to the community fork ([!4377](https://gitlab.com/gitlab-org/quality/triage-ops/-/merge_requests/4377)).
