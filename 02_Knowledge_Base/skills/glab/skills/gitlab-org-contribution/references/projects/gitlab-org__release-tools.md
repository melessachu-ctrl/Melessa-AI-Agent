# gitlab-org/release-tools

The Ruby tooling that drives GitLab's release process. Its issues live in `gitlab-com/gl-infra/delivery` (issues are disabled here), release pipelines run on a mirror on ops.gitlab.net, and there is no community fork. Every MR from an outside fork in the corpus was closed; changes are designed with the Delivery team first, and merges are held during releases.

| Fact | Value |
| --- | --- |
| Default branch | `master` |
| Language | Ruby |
| Fork to use | Personal fork (no community fork exists, checked 2026-10-22). An outside fork cannot exercise the release paths |
| Merge settings | Squash default off, merge trains on, pipeline must succeed, all threads must be resolved |
| Commit convention | DCO; no commit linter (the Dangerfile disables the commit message and metadata rules) |
| MR template | `Default.md` (what and why, `%{all_commits}`, author checklist, labels) |
| Changelog | None to edit |
| Contributor docs | `AGENTS.md`; runbooks live in `gitlab-org/release/docs` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Start with an issue in `gitlab-com/gl-infra/delivery` rather than a drive-by MR: release pipelines run only on the ops mirror and changes are designed with the Delivery team. Every MR from an outside fork in the corpus was closed, and larger changes were redesigned in the issue or moved to the ChatOps project. (documented; `gitlab-org/release-tools:AGENTS.md@959ad5c2`, [!4608](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4608), [!4848](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4848), [!1553](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/1553))
- Confirm in the issue which repository owns the behavior; functionality that belongs to ChatOps was closed here. (observed, 2 MRs; [!4608](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4608), [!4713](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4713))
- Run `bundle exec rspec` (release code runs in dry-run mode in specs) and RuboCop, which includes a custom cop. An agent in a sandboxed session runs RuboCop through its Ruby API (`bundle exec ruby -e 'require "rubocop"; exit RuboCop::CLI.new.run(ARGV)' -- <files>`), because the executable's server check calls `Process.kill`, which fails with `Errno::EPERM` there even with `--no-server`. The lefthook hooks also run gitleaks, golangci-lint for the metrics module and a Danger dry run. Never hand-edit the generated CI file. (documented; `gitlab-org/release-tools:AGENTS.md@959ad5c2`)
- Cover every new branch with a spec (the most common review blocker, per `AGENTS.md`), keep rake tasks thin over a service with `execute`, use `ENV.fetch('NAME', nil)`, keep requires alphabetical, and post testing evidence (a dry-run log, an ops pipeline link or screenshots) in the MR. Runbook changes go in a companion MR in `gitlab-org/release/docs`. (documented; `gitlab-org/release-tools:AGENTS.md@959ad5c2`)
- Answer and resolve every Duo thread; Duo reviews every MR, and reviewers use conventional comment labels such as `issue (blocking)`. (documented; `gitlab-org/release-tools:AGENTS.md@959ad5c2`)
- Do not expect a merge during a monthly or patch release or a production change lock; maintainers merge when someone can watch the next run. (documented; `gitlab-org/release-tools:AGENTS.md@959ad5c2`, [!5081](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/5081), [!5131](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/5131), [!4944](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4944))
- Fill in the template with what changes and why; unexplained edits, deletions and a mistaken revert were closed. (observed, 5 MRs; [!772](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/772), [!1506](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/1506), [!2095](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/2095), [!3513](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/3513))

## Why MRs here were closed

- Unexplained or accidental changes: no description, deletions, an empty template, a mistaken revert ([!772](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/772), [!1506](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/1506), [!1553](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/1553), [!2095](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/2095), [!3513](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/3513)).
- Wrong project or not needed: belonged in ChatOps ([!4608](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4608), [!4713](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4713)); gems already in the CI image ([!4652](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4652)).
- Redesigned in the issue and replaced by smaller MRs ([!4848](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4848), [!4939](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4939)); stacked MRs targeting a feature branch auto-closed by gitlab-bot after months without progress ([!4953](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4953), [!4954](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4954), [!4955](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4955)); a draft withdrawn after Duo flagged defects ([!4926](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4926)).

## Troubleshooting

**Your fork's pipeline passes, or cannot run the release paths at all**
- Cause: release pipelines run only on the mirror on ops.gitlab.net; an outside fork exercises specs and linters, never a real release run.
- Fix: run `bundle exec rspec` and `bundle exec rubocop` locally, post a dry-run log in the MR, and ask in the Delivery issue for someone to run the change on ops.
- Who can fix it: a member of the Delivery team.
- Sources: `gitlab-org/release-tools:AGENTS.md@959ad5c2`, [!4848](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/4848)

**Approved but not merged for days**
- Cause: merges are held during a monthly or patch release or a production change lock, until someone can watch the next run.
- Fix: nothing to change; do not push or rebase while you wait, and ask once after the release if nothing happened.
- Who can fix it: a maintainer.
- Sources: `gitlab-org/release-tools:AGENTS.md@959ad5c2`, [!5081](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/5081), [!5131](https://gitlab.com/gitlab-org/release-tools/-/merge_requests/5131)

**No community fork**
- Cause: none exists for this project (checked 2026-10-22), so your personal fork runs on your own CI minutes and runners; see references/troubleshooting.md for those failures.
