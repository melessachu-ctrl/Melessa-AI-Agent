---
name: gitlab-backport
description: "Backport a merged GitLab bug fix from master to the maintained stable branches (MAJOR-MINOR-stable-ee) by cherry-pick and open one Stable Branch MR per release. Use when asked to backport, cherry-pick a fix to a stable branch, or prepare patch release MRs for gitlab-org/gitlab."
version: 1.0.0
license: MIT
category: Development Workflow
metadata:
  audience: developers
  workflow: gitlab-release
---

# GitLab Backport

## When to Use

Cherry-pick a merged `master` fix onto each maintained stable branch of `gitlab-org/gitlab` for a patch release. Load the `glab` skill before creating MRs. Official process: [patch release runbook for engineers](https://gitlab.com/gitlab-org/release/docs/-/blob/master/general/patch/engineers.md).

## Prerequisites

- The fix is merged and deployed to GitLab.com.
- It is a bug fix. Features are not backported ([maintenance policy](https://docs.gitlab.com/policy/maintenance/)). For versions outside the policy, open a [backport request issue](https://gitlab.com/gitlab-org/release/tasks/-/issues/new?issuable_template=Backporting-request).
- Not a security fix. Security backports must not be opened on the canonical project; follow the [security release process for engineers](https://gitlab.com/gitlab-org/release/docs/-/blob/master/general/security/engineer.md) instead.
- Targets are the three most recently released minors, taken from version.gitlab.com (as Danger does). Never infer them from local or remote branch names; see [maintained-versions.md](references/maintained-versions.md).

## Process

Repeat steps 2-5 for each target (`18.11` / `18-11-stable-ee` shown).

1. **Find the commit.** Take the merge commit SHA from the merged MR page, or `git log --oneline origin/master | grep <keywords>`.
2. **Cherry-pick.**
   ```bash
   COMMIT_SHA=<sha>
   git fetch origin
   git checkout -b 18-11-stable-ee-backport-<mr-iid> origin/18-11-stable-ee
   git cherry-pick -m1 "$COMMIT_SHA"   # drop -m1 for a non-merge commit
   ```
   On conflicts, resolve, `git cherry-pick --continue`, and record the resolution in the MR description.
3. **Push with `--no-verify`.** Local pre-push hooks (mermaidlint, gettext, vale) match `master` tooling and fail on stable branches; CI runs the real checks.
   ```bash
   git push origin 18-11-stable-ee-backport-<mr-iid> --no-verify
   ```
4. **Write the description** from the repo's `.gitlab/merge_request_templates/Stable Branch.md`, copied verbatim, HTML comments included. Danger's stable-branch check rejects MRs without them. Fill labels, milestone, and assignee as in [mr-description.md](references/mr-description.md).
5. **Create the draft MR.** Title `Backport of '<original MR title>'` with no version prefix: the template says the title is copied into the patch blog post, and recent merged stable MRs use this form (the target branch carries the version). Omit `--push` (already pushed) and `--assignee` (fine-grained PATs get `403 insufficient_granular_scope`; the description's `/assign me` covers it).
   ```bash
   glab mr create -H gitlab-org/gitlab -R gitlab-org/gitlab \
     --title "Backport of '<original MR title>'" \
     --description "$(cat /tmp/backport-18-11-description.md)" \
     --target-branch 18-11-stable-ee --draft --yes
   ```
6. **Verify** milestone, labels, and assignee landed. If a quick action did not apply, fix it with `glab mr update <iid> --milestone "18.11" --label "backport,type::bug,pipeline::tier-3,..." -R gitlab-org/gitlab`.

## Pitfalls

- Cherry-picking a merge commit without `-m1` fails with "is a merge but no -m option was given".
- Danger error "does not use the stable branch template" means the template's HTML comments were stripped.
- This flow intentionally skips the `glab` skill's `--push` rule: the branch is pushed in step 3 with `--no-verify`. Keep `-H gitlab-org/gitlab`.

## Done when

- [ ] One MR per maintained version, target branch `MAJOR-MINOR-stable-ee`
- [ ] Conflicts, if any, documented in the description
- [ ] Milestone, labels, assignee verified
- [ ] Pipeline green, especially `e2e:test-on-omnibus-ee`, which runs only with `~"pipeline::tier-3"` (if it fails, confirm the failure relates to the change before asking for review)
- [ ] One maintainer approval (stable branches need one, not two), then merge

After merge, the change deploys to `https://gitlab.{major-minor}-stable-security-get.env.release.gitlab.net`.

## Contributing Improvements

This skill is maintained in [`gitlab-org/ai/skills`](https://gitlab.com/gitlab-org/ai/skills). If you discover that any
guidance here is **inaccurate or outdated** (e.g. a command that no longer
works, a wrong flag, an incorrect API behavior), confirm with the user and open
an MR against that repository with the fix. Keep changes focused — one fix per
MR.
