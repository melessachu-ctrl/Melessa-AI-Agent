# gitlab-org/ci-cd/runner-tools/grit

GRIT, the GitLab Runner Infrastructure Toolkit: Terraform modules with Go Terratest tests for running runners on AWS and GCP. Module READMEs are generated, `CHANGELOG.md` is generated at release, and the integration tests need GitLab's cloud credentials and project runners, so a maintainer has to run the full pipeline. Reviewer roulette may find nobody for GRIT, so name a reviewer yourself.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | HCL (Terraform) with Go tests |
| Fork to use | Community fork `gitlab-community/gitlab-org/ci-cd/runner-tools/grit` |
| Merge settings | Squash default on, pipeline must succeed, no merge train |
| Commit convention | Conventional Commits (`AGENTS.md`) |
| MR template | None found |
| Changelog | `CHANGELOG.md`, generated at release; never edit it in your MR |
| Contributor docs | `CONTRIBUTING.md` (DCO, Google's Terraform best practices, generated READMEs, tests), `AGENTS.md`, `docs/` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Run `make terraform-docs` after changing `variables.tf` or `outputs.tf` and commit the regenerated READMEs (CI verifies them); never edit `CHANGELOG.md`. (enforced; `gitlab-org/ci-cd/runner-tools/grit:CONTRIBUTING.md@bad63b3e`, `gitlab-org/ci-cd/runner-tools/grit:AGENTS.md@dcdaca9f`, [!310](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/310), [!391](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/391))
- Before pushing, run `terraform fmt -check`, `terraform validate`, `tflint`, `make lint-go` (golangci-lint) and `make lint-docs` (Vale and markdownlint); `make test` needs AWS or GCP credentials for the integration tests. (documented; `gitlab-org/ci-cd/runner-tools/grit:CONTRIBUTING.md@bad63b3e`)
- Once your local checks pass, ask a maintainer to run the full pipeline and keep the MR moving (see Troubleshooting for why the integration jobs cannot pass from a fork). (observed, 6 MRs; [!355](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/355), [!310](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/310))
- Name a reviewer yourself in `@gitlab-bot ready @<reviewer>` (see Troubleshooting for how to find one when roulette shows nobody, and for an MR that touches `docs/`, where the documentation bot replaces the reviewer you name). (enforced; observed, 3 MRs; `gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867`, `gitlab-org/quality/triage-ops:triage/processor/community/automated_review_request_doc.rb@57fab1af`, `gitlab-org/quality/triage-ops:triage/triage/reaction.rb@839eee7f`, [!310](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/310), [!357](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/357))
- Link an issue that the owning team agreed to before sending a fix; a hackathon fix with no issue was closed because nobody could confirm it was wanted. (observed, 1 MR; [!320](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/320))
- Propose alternatives in the issue or in one MR description, not as parallel MRs; when a reviewer asks for a split, close the combined MRs yourself and link the new ones. (observed, 2 MRs; [!424](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/424), [!425](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/425))
- Update the branch of an existing MR (rebase or force-push) instead of reopening it as a new one; three MRs were closed and recreated the same day. (observed, 3 MRs; [!318](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/318), [!422](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/422), [!423](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/423))

## Why MRs here were closed

- Auto-closed by gitlab-bot: never sent for review, no reviewer for the area, or a failing pipeline after review questions ([!320](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/320), [!357](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/357), [!376](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/376), [!400](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/400)).
- Replaced by the author's own MRs: recreations, splits and competing alternatives ([!318](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/318), [!422](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/422), [!423](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/423), [!424](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/424), [!425](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/425)); recreated from the community fork ([!377](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/377)); carried into a maintainer's MR with attribution ([!378](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/378)).
- Empty or accidental MRs ([!314](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/314), [!358](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/358), [!367](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/367)); a draft withdrawn over open design questions ([!432](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/432)).

## Troubleshooting

**Integration or e2e jobs fail or never start in your MR**
- Cause: they need GitLab-owned AWS or GCP credentials and runners tagged for the project, which no fork has; long-lived branches also break the Google e2e environment.
- Fix: run `terraform fmt -check`, `terraform validate`, `tflint`, `make lint-go` and `make lint-docs` locally, then ask a maintainer to run the full pipeline, and keep the MR moving. Maintainers merged over unrelated cloud failures.
- Who can fix it: a maintainer.
- Sources: [!355](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/355), [!310](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/310), [!382](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/382), [!433](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/433)

**Reviewer roulette shows nobody, or the review passes from hand to hand**
- Cause: few reviewers are listed for GRIT; one MR went through five hand-offs over four months, and an MR with no available reviewer was auto-closed.
- Fix: name a reviewer from the runner maintainer groups in `.gitlab/CODEOWNERS` or from recent commits to the module you change, with `@gitlab-bot ready @<reviewer>`. On an MR that touches `docs/`, the documentation bot replaces a reviewer named in the ready that adds `workflow::ready for review` a second later with its own pick from the `[Documentation]` section: for a docs-only MR post a bare `@gitlab-bot ready`, and for an MR that also changes code repeat `@gitlab-bot ready @<reviewer>` once the bot's request is in and the hour limit allows (references/projects/gitlab-org__gitlab-runner.md, Docs).
- Who can fix it: you.
- Sources: `gitlab-org/ci-cd/runner-tools/grit:.gitlab/CODEOWNERS@d76825bd`, `gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867`, `gitlab-org/quality/triage-ops:triage/processor/community/automated_review_request_doc.rb@57fab1af`, `gitlab-org/quality/triage-ops:triage/triage/reaction.rb@839eee7f`, `gitlab-org/quality/triage-ops:triage/triage/documentation_code_owner.rb@8e3a04cb`, [!310](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/310), [!357](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/357), [!452](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/452)

**The generated README check fails**
- Cause: `variables.tf` or `outputs.tf` changed without regenerating the module READMEs.
- Fix: run `make terraform-docs` and commit the result.
- Who can fix it: you.
- Sources: `gitlab-org/ci-cd/runner-tools/grit:CONTRIBUTING.md@bad63b3e`

## Open questions

- A contributor said they could not create an issue in the project although issues are enabled ([!424](https://gitlab.com/gitlab-org/ci-cd/runner-tools/grit/-/merge_requests/424)); the cause is unknown.
