# gitlab-docs-review

Reviews a GitLab docs change the way a technical writer does, brevity first.
It comments only on what the change wrote or broke.

## What it knows

- The reviewer rules are distilled from 69 docs MRs that technical writers
  reviewed, and the suite was replayed on 62 more.
- It reads the live style guide, word list, and Vale rules on every run, so
  it reviews against the current rules.

## How it works

1. **Triage:** a script sets the review tier from the diff.
1. **Checks:** Vale with GitLab's live rules, markdownlint, built-in checks
   (metadata, history, feature flags, redirects), and an impact check for
   broken links and anchors.
1. **Reviewers:** three read-only subagents in parallel.
   - Editor: style, brevity, the live word list, structure.
   - Facts: claims checked against the source code at the MR's date, and
     impact on other pages.
   - Reader: walks each task as a new user.
1. **Combine:** a script merges the findings, drops repeats, and ranks them
   by importance. Problems in old text go to the summary, not inline.
1. **Report or post:** nothing posts until you approve. A finding that names
   a non-public source is withheld. A separate writer phase can apply fixes.

Configure it with `.gitlab-docs-review.yml` ([keys](references/config.md)).

## Development

Change the skill here. `tests/` covers the posting guardrails. The full
tests and the replay eval live in
[gabrielengel_gl/docs-skills-lab](https://gitlab.com/gabrielengel_gl/docs-skills-lab).

On the latest replay eval, the suite caught 71% of a technical writer's
comments on 5 MRs, with 4 wrong comments. The auto mode targets are not met yet, so use
interactive mode. See the
[latest results](https://gitlab.com/gabrielengel_gl/docs-skills-lab/-/blob/main/dev/evals/results/2026-10-15-distillation.md).
The auto-mode writer step and later prompt changes came after that run, so
rerun the eval before relying on its numbers.
