# gitlab-org/professional-services-automation/tools/migration/congregate

Congregate, the Professional Services migration tool (Python with Poetry, Celery, MongoDB and a Vue frontend). `CONTRIBUTING.md` documents a community fork flow: fork pipelines run lint, unit, code quality and security jobs, and a maintainer copies your branch into a mirror MR in the project that runs the end-to-end suite and fast-forwards `master` with your commits. You cannot see the parent project's pipelines.

| Fact | Value |
| --- | --- |
| Default branch | `master` |
| Language | Python |
| Fork to use | Community fork `gitlab-community/gitlab-org/professional-services-automation/tools/migration/congregate` |
| Merge settings | Fast-forward merges only, merge trains on, pipeline must succeed, all threads must be resolved |
| Commit convention | DCO sign-off; no commit lint. Your commits land as written |
| MR template | Default description in project settings: Overview, Tasks and Acceptance Criteria; merged descriptions close the issue with `Closes #<issue>` (checked 2026-10-22; references/workflow.md, section 7) |
| Changelog | None to edit |
| Contributor docs | `CONTRIBUTING.md`, `AGENTS.md`, `docs/` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Work from the community fork and leave the `test:end-to-end (run by a maintainer)` job alone: it needs Professional Services credentials and blocks merge until a maintainer labels the MR `community::mirror`, copies your branch to `community/mr-<iid>` and runs it in a mirror MR in the project. That MR's merge fast-forwards `master` with your commits and marks your MR merged. Keep your branch rebased; each push re-syncs the mirror. (documented; `gitlab-org/professional-services-automation/tools/migration/congregate:CONTRIBUTING.md@92f761be`, [!1578](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1578), [!1585](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1585), [!1600](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1600))
- Squash your own branch if you want a single commit: merges are fast-forward only, and squashing on the mirror would leave your MR unmerged. (observed, 1 MR; [!1578](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1578))
- Run checks locally, because you cannot see the parent project's pipelines: `poetry install`, `poetry run pylint congregate -j 4` (or `ci/pylint-errors.sh`), `pytest -m unit_test` (needs a MongoDB), `generate_command_reference.py --check` after CLI changes, and autopep8 at line length 79. Rebase when a maintainer says CI was fixed on `master`; maintainers asked for that eight times. (observed, 12 MRs; `gitlab-org/professional-services-automation/tools/migration/congregate:AGENTS.md@62302f5a`, [!1516](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1516), [!1562](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1562), [!1610](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1610))
- Never call the GitLab API with raw `httpx` or `requests`; use the project's API wrappers, or add the call to `gitlab-ps-utils` first. `AGENTS.md` calls raw API calls a review blocker, and reviewers asked contributors to reuse existing code paths. (documented; `gitlab-org/professional-services-automation/tools/migration/congregate:AGENTS.md@62302f5a`, [!1581](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1581))
- Expect a reviewer and then a maintainer; reviewers mark comments Blocking or Non-blocking. (observed, 5 MRs; [!1578](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1578), [!1590](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1590), [!1613](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1613))
- Describe what the MR changes and why, and keep the diff to that purpose; MRs with no description, a title that did not match the diff, or a corrupted rebase were closed. (observed, 4 MRs; [!808](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/808), [!1088](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1088), [!839](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/839), [!1274](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1274))

## Troubleshooting

**`test:end-to-end (run by a maintainer)` sits unplayed and the MR cannot merge**
- Cause: end-to-end tests need Professional Services credentials, and the ID token carries the fork's project ID.
- Fix: leave it. A maintainer labels the MR `community::mirror` and runs the tests in the mirror MR.
- Who can fix it: a maintainer or member.
- Sources: `gitlab-org/professional-services-automation/tools/migration/congregate:CONTRIBUTING.md@92f761be`, [!1585](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1585)

**A project bot says "The end-to-end suite cannot run on a merge request from a fork, so it runs on !NNNN instead" with a failed status**
- Cause: the mirror MR's pipeline failed.
- Fix: open the linked pipeline if you can, or ask the maintainer to paste the failing output; fix failures caused by your change and push, which re-syncs the mirror.
- Who can fix it: you.
- Sources: [!1578](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1578)

**You cannot see which pipeline job failed on your MR**
- Cause: contributors cannot see pipelines that run in the parent project.
- Fix: ask the maintainer to paste the failing output, reproduce lint and unit tests locally, and rebase when CI fixes land on `master`.
- Who can fix it: you, with a maintainer's help.
- Sources: [!1516](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1516), [!1562](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1562)

## Why MRs here were closed

- Moved by a maintainer into a project branch or sibling MR to get it merged; in one case the contributor stayed the commit author ([!964](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/964), [!949](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/949), [!1589](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1589), [!1274](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1274)).
- No description or an unrelated diff ([!808](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/808), [!839](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/839), [!1088](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1088)); withdrawn the same day without a note ([!672](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/672), [!860](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/860), [!940](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/940)).
- Reopened from the community fork once it existed ([!1342](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1342)); already landed by a direct commit ([!1396](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1396)); obsolete after other cleanup and auto-closed ([!1485](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1485)).

## Open questions

- [!1589](https://gitlab.com/gitlab-org/professional-services-automation/tools/migration/congregate/-/merge_requests/1589) was closed unmerged because the mirror MR merged rebased commits, after which maintainers changed the mirror process. Whether the fork MR is now always marked merged was not confirmed.
