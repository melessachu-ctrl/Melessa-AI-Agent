# gitlab-org/ops/artifact-registry

A Go service (OpenAPI, deployed with Runway) with extensive contributor docs written for humans and agents. Conventional Commits are enforced on commits by gitlint and on the MR title by `lint:mr-title`, squash is on so the MR title becomes the commit message, and custom Danger rules fail feature and fix MRs that change code without tests. There is no community fork, and label or milestone edits by non-members silently do nothing.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | Go |
| Fork to use | Personal fork (no community fork exists, checked 2026-10-22) |
| Merge settings | Squash default on (the MR title is the commit message; commit bodies are dropped), merge trains on, pipeline must succeed, all threads must be resolved |
| Commit convention | Conventional Commits: gitlint in a pre-commit hook (subject at most 72 characters) and `lint:mr-title` on the MR title (a `Draft:` prefix is stripped) |
| MR template | `Default.md`: Summary (Problem, Impact, Change, Downsides), Checklist (Ran it, Interfaces and data, Failure, Rollout, Hot path, Database evidence, Security, ADRs, E2E, Simplicity), Related to. Also ADR, Plan, Spec and Close-out templates |
| Changelog | None found |
| Contributor docs | `AGENTS.md`, `docs/dev/conventions.md`, `docs/plans`, ADRs |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Make the MR title a Conventional Commit: `lint:mr-title` checks it, and with squash on it becomes the commit message on `main`. Keep commit subjects within 72 characters for gitlint; retrying the job cannot fix a gitlint failure, so amend and force-push. (enforced; `gitlab-org/ops/artifact-registry:docs/dev/conventions.md@4faedbd3`, [!1603](https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1603))
- Do not bypass the hooks with `--no-verify`; `AGENTS.md` allows it only for a deliberate failing-test-first commit. (documented; `gitlab-org/ops/artifact-registry:AGENTS.md@3d0034a4`)
- A `feat` or `fix` MR that changes Go code needs a `_test.go` change in the same directory, or Danger fails. After you fix a Danger finding (title, label, tests), it clears on the next pipeline run, not when you edit the MR. (enforced; `gitlab-org/ops/artifact-registry:danger/tests_with_code/Dangerfile@a3122bd9`, `gitlab-org/ops/artifact-registry:danger/stream_label/Dangerfile@0f21f076`)
- Fill in the template for the MR's phase yourself (`Plan.md` for the plan MR, `Default.md` for code; `glab` and the API apply none), start large changes with a plan MR, which merges before any step MR opens, and check the ADRs for the area and the open issues and MRs on the same symbol or symptom before you start. The MR size gate refuses more than 1,000 added lines of Go (code and tests, generated and vendored files excluded) with no per-MR override, so larger work ships as a stack. (documented; `gitlab-org/ops/artifact-registry:.gitlab/merge_request_templates/Default.md@a91c031a`, `gitlab-org/ops/artifact-registry:AGENTS.md@3d0034a4`, `gitlab-org/ops/artifact-registry:docs/dev/agentic-development.md@f249d05c`, [!1598](https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1598))
- Every MR needs labels (type labels are a SOX control) and a milestone, but a non-member's label and milestone edits silently do nothing; leave a note asking a maintainer to apply them (find one in CODEOWNERS, on the project members page filtered to Maintainer, or in the `roulette.json` entry described in the next rule) and let the autolabels job do what it can. (observed, 4 MRs; `gitlab-org/ops/artifact-registry:AGENTS.md@3d0034a4`, [!1509](https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1509), [!1512](https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1512), [!1552](https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1552))
- Pick reviewers from the MR's own Danger roulette note once the pipeline is green and bot threads are addressed. If the note never appears (danger-review cannot run on forks), take candidates from the project's entry in gitlab-roulette's `roulette.json` and say in the MR that you did. (documented; `gitlab-org/ops/artifact-registry:docs/dev/conventions.md@4faedbd3`, [!1554](https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1554))
- In a personal fork, danger-review, autolabels and dependency scanning fail without protected variables (they may fail without blocking), arm64 jobs get `no_matching_runner`, and an exhausted quota fails every job with `ci_quota_exceeded`. Run the commands of the jobs your fork cannot run locally, post the results, and ask a maintainer to run the pipeline in the parent project. (observed, 3 MRs; [!1552](https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1552), [!1554](https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1554))

## Troubleshooting

**A Danger message about the title, label or tests stays after you fixed it**
- Cause: Danger results update only when the pipeline runs again.
- Fix: push a real change or ask a member to rerun the pipeline; do not push an empty commit.
- Who can fix it: a maintainer or member.
- Sources: `gitlab-org/ops/artifact-registry:danger/stream_label/Dangerfile@0f21f076`

**gitlint fails on a commit subject**
- Cause: the subject is longer than 72 characters or not a Conventional Commit.
- Fix: reword the commit and force-push.
- Who can fix it: you.
- Sources: [!1603](https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1603)

## Why MRs here were closed

- A richer change to the same row reached `main` first, and the MR was never sent for review; gitlab-bot closed it after three nudges ([!1598](https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1598)). The other closed MRs labeled as community were automated sync MRs, not contributions.

## Open questions

- `docs/dev/conventions.md` says danger-review is not allowed to fail, but in fork pipelines it ran with `allow_failure` and failed without blocking ([!1552](https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1552), [!1554](https://gitlab.com/gitlab-org/ops/artifact-registry/-/merge_requests/1554)). Which is current was not confirmed.
