# Run gitlab-docs-change and gitlab-docs-review headless

Contents:

- [What runs where](#what-runs-where)
- [GitLab CI example](#gitlab-ci-example)
- [Roll out in steps](#roll-out-in-steps)

## What runs where

| Job | Skill | Writes | Token needs |
|---|---|---|---|
| `gitlab-docs-review` | `gitlab-docs-review`, auto mode | Each cycle: commits the fixes that need no input to a fix branch (`gitlab-docs-review/mr-<iid>`) and opens or updates a draft fix MR into the MR source branch. It posts the questions on the fix MR and one handoff note on the MR, and resolves its own threads that are fixed. With `push` [delivery](../../gitlab-docs-review/references/writer.md#delivery), it commits to the MR source branch and posts on the MR instead. 2 cycles by default ([auto mode](../../gitlab-docs-review/references/writer.md#auto-mode)). | `api`, `write_repository` |
| `gitlab-docs-change` (manual) | `gitlab-docs-change`, auto mode | New commits on the MR branch, or a new branch and MR | `api`, `write_repository` |

Auto mode reviews and writes in one job: a review cycle ends with a writer
step, so there is no separate apply job. For a read-only trial, add
`--dry-run`: the job writes the review and the planned comments to its
artifacts and posts nothing. Run the jobs only for MRs from the project
itself, as the rules below do: the job reads untrusted text and holds a
write token. Only the MR author, a person a review note asked, or a project
member with the Developer role or higher can answer a review question.

## GitLab CI example

The agent CLI is an example (Claude Code headless with `claude -p`). Any
agent that can load skills works, such as `opencode run`. Check your CLI's
`--help` for its tool and permission flags.

```yaml
stages: [gitlab-docs-review]

.docs-agent:
  image: node:22-bookworm      # needs git, python3, glab, and the agent CLI
  variables:
    GITLAB_DOCS_REVIEW_MODE: auto
    GIT_DEPTH: 0               # the review diffs base..head
  rules:
    # Do not review the job's own fix MR, or the pipeline its fix commit started.
    - if: $CI_MERGE_REQUEST_SOURCE_BRANCH_NAME =~ /^gitlab-docs-review\//
      when: never
    - if: $CI_COMMIT_MESSAGE =~ /^docs: apply gitlab-docs-review fixes/
      when: never
    - if: $CI_PIPELINE_SOURCE == "merge_request_event" && $CI_MERGE_REQUEST_SOURCE_PROJECT_ID == $CI_PROJECT_ID
      changes:
        paths: ["doc/**/*"]     # your docs_root
        compare_to: refs/heads/$CI_DEFAULT_BRANCH
  before_script:
    - apt-get update -qq && apt-get install -y -qq python3 git >/dev/null
    - ./scripts/ci/install-docs-tools.sh   # glab, vale, markdownlint-cli2 at the project's pinned versions
    - npm install -g @anthropic-ai/claude-code
    - mkdir -p ~/.claude/skills
    - git clone --depth 1 https://gitlab.com/gitlab-org/ai/skills.git /tmp/ai-skills   # the published skills; pin a commit
    - cp -R /tmp/ai-skills/skills/gitlab-docs-review /tmp/ai-skills/skills/gitlab-docs-change /tmp/ai-skills/skills/gitlab-docs-preview ~/.claude/skills/
    - echo "$GITLAB_TOKEN" | glab auth login --hostname "$CI_SERVER_HOST" --stdin
  interruptible: true
  resource_group: docs-agent-$CI_MERGE_REQUEST_IID   # one agent run per MR at a time
  allow_failure: true                                # advisory until the team trusts it
  artifacts:
    when: always
    access: developer                                # findings can quote non-public text
    expire_in: 2 weeks
    paths: [gitlab-docs-review-out/]

gitlab-docs-review:
  extends: .docs-agent
  stage: gitlab-docs-review
  script:
    - git fetch origin "$CI_MERGE_REQUEST_SOURCE_BRANCH_NAME"
    - git checkout -B "$CI_MERGE_REQUEST_SOURCE_BRANCH_NAME" FETCH_HEAD
    - test "$(git rev-parse HEAD)" = "$CI_COMMIT_SHA" || { echo "Branch moved; skipping."; exit 0; }
    - claude -p "Use the gitlab-docs-review skill in auto mode on MR !$CI_MERGE_REQUEST_IID of $CI_PROJECT_PATH. Run the auto mode cycle as writer.md says, 2 cycles, with --delivery fix-mr. Push only to the fix branch that fix_mr.py --plan names, never to $CI_MERGE_REQUEST_SOURCE_BRANCH_NAME. Write every output to gitlab-docs-review-out/."

gitlab-docs-change:
  extends: .docs-agent
  stage: gitlab-docs-review
  when: manual                 # a person starts it on a code MR
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event" && $CI_MERGE_REQUEST_SOURCE_PROJECT_ID == $CI_PROJECT_ID
      when: manual
  script:
    - claude -p "Use the gitlab-docs-change skill in auto mode. Document the user-facing changes in MR !$CI_MERGE_REQUEST_IID of $CI_PROJECT_PATH on its source branch. Write the plan and the gitlab-docs-review report to gitlab-docs-review-out/."
```

## Roll out in steps

1. Dry run: add `--dry-run` to the prompts. Read the artifacts on a few MRs:
   the planned comments, and the fixes the writer step would commit.
1. Auto mode: remove `--dry-run` once the team agrees with most fixes. The
   fixes arrive as draft fix MRs (`fix-mr` delivery, the default), and the
   MR author merges one when they agree with it.
1. Optional: set `delivery: push` in `.gitlab-docs-review.yml` once authors
   want the fixes committed to their branch directly.
1. Keep `allow_failure: true` until false positives are rare.
