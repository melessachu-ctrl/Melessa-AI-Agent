# gitlab-org/gitlab-development-kit

The GitLab Development Kit (GDK), which sets up a local GitLab for development. `AGENTS.md` puts it in maintenance mode: only critical bug fixes, with new features going to its successor, Caproni. The GDK's install page tells first-time setups to consider starting with Caproni, and `AGENTS.md` says Caproni will replace the GDK for all GitLab contributors, while the gitlab-org/gitlab first-contribution guide still recommends the GDK or GDK-in-a-box; for what a gitlab-org/gitlab change needs without either, see references/projects/gitlab-org__gitlab.md, Test environment. (documented; `gitlab-org/gitlab-development-kit:AGENTS.md@3942e100`, `gitlab-org/gitlab-development-kit:doc/_index.md@cf704d5c`, `gitlab-org/gitlab:doc/development/contributing/first_contribution/_index.md@88381481`)

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | Ruby |
| Fork to use | Community fork `gitlab-community/gitlab-org/gitlab-development-kit` |
| Merge settings | Squash default on, merge trains on, all threads must be resolved |
| Commit convention | gitlab-dangerfiles `commit_messages` rule (all default rules except performance) |
| MR template | `.gitlab/merge_request_templates/Default.md` |
| Changelog | None to edit |
| Contributor docs | `AGENTS.md`, `doc/contributing/_index.md` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Do not propose new GDK features; send bug fixes, reliability fixes and docs corrections. A feature MR was closed and redirected to Caproni while bug-fix MRs from the same period merged. (documented; `gitlab-org/gitlab-development-kit:AGENTS.md@3942e100`, [!6174](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6174), [!6224](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6224))
- Combine documentation fixes into one MR. A maintainer closed eight single-link docs MRs from one author with "Please combine docs MRs in this project", and 13 were consolidated in all, one of them already approved. (observed, 14 MRs; [!6240](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6240), [!6245](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6245), [!6247](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6247))
- Open the MR from the community fork: a reviewer asked a personal-fork author to reopen there "so all the pipeline jobs can run". (observed, 1 MR; `gitlab-org/gitlab-development-kit:doc/contributing/_index.md@f591eebe`)
- Before pushing: `make test` or `bundle exec rspec` for Ruby changes, `bundle exec rubocop --config .rubocop-gdk.yml` (note the config file), and markdownlint-cli2 and Vale for docs. If you change `gdk.example.yml` or the Makefile configuration, run the lefthook verify jobs (`verify-gdk-example-yml`, `verify-makefile-config`); lefthook also runs check-links and shellcheck. (documented; `gitlab-org/gitlab-development-kit:doc/contributing/_index.md@f591eebe`, `gitlab-org/gitlab-development-kit:lefthook.yml@e30da825`)
- For work that belongs to one service, add a Rake task rather than a new `gdk` command. (documented; `gitlab-org/gitlab-development-kit:doc/contributing/_index.md@f591eebe`)
- Fill the Default template: tick the impacted categories (gdk-reliability, gdk-usability, gdk-performance) and answer the checklist (linked issue, backward compatibility, tests, observability, documentation, announcement, whether `gdk doctor` needs a check). (documented; `gitlab-org/gitlab-development-kit:.gitlab/merge_request_templates/Default.md@be83c6ee`)
- When you edit a docs link, check its anchor against the current page too; docs.gitlab.com headings get renamed and reviewers asked link-fix MRs to update anchors. (observed, 2 MRs; [!6240](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6240), [!6253](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6253))
- Read `.gitlab/duo/mr-review-instructions.yaml` before requesting review; it is what GitLab Duo checks GDK MRs against. Reviewers come from Danger's roulette and the GDK maintainers group in `.gitlab/CODEOWNERS`. (documented; `gitlab-org/gitlab-development-kit:.gitlab/duo/mr-review-instructions.yaml@48ce1579`)
- Lowercase commit subjects fail Danger here too: an interim combined MR was replaced after a lowercase-start subject failed. (enforced; [!6280](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6280))

## Troubleshooting

**build-integration-image or build-verify-image fails in `gdk update` or `gdk install` with "fetch-pack: unexpected disconnect", "early EOF" or "resource exhausted" while fetching gitlab-org/gitlab; or a manual macOS job fails because the runner lacks a tool**
- Cause: network or runner problems unrelated to the MR; the cells and macOS jobs are also flaky.
- Fix: retry once at most, then post a note with the job link and the error line. Maintainers apply `pipeline::expedited` and restart the merge train when the job was green before.
- Who can fix it: a maintainer.
- Sources: [!6222](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6222), [!6223](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6223), [!6271](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6271)

## Why MRs here were closed

- A new feature in a project in maintenance mode ([!6174](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6174)).
- Single-link docs MRs folded into one combined MR at a maintainer's request ([!6240](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6240) to [!6267](https://gitlab.com/gitlab-org/gitlab-development-kit/-/merge_requests/6267)).
