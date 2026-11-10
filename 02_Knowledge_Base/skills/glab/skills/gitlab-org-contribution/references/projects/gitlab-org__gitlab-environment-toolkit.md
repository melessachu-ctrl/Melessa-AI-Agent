# gitlab-org/gitlab-environment-toolkit

The GitLab Environment Toolkit (GET): Terraform and Ansible that deploy GitLab reference architectures. It is issue-first: `CONTRIBUTING.md` and the MR template require an issue reviewed by the maintainers before any MR, and say MRs filed (including with AI tools) without understanding the design will be closed. Most closed community MRs were product decisions of exactly that kind. Optional settings go through the documented Custom Config feature, not new variables.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | HCL (Terraform) and Ansible |
| Fork to use | Community fork `gitlab-community/gitlab-org/gitlab-environment-toolkit` |
| Merge settings | Squash default on, merge commits, no merge train |
| Commit convention | No commit linter (the Dangerfile disables the commit message and commit count rules); merged titles are plain capitalized sentences |
| MR template | `default.md`: description, related issue, author checklist (green pipeline, docs updated, Secret Detection and IaC SAST clean), `/milestone %GET` and type label quick actions, and a mention of the maintainers group |
| Changelog | None; the Danger changelog rule is disabled |
| Contributor docs | `CONTRIBUTING.md` (including the Technical Design pointer), `AGENTS.md`, `docs/` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Raise an issue and get it reviewed by the maintainers before opening an MR, read the Technical Design first, and propose extensions of existing features rather than new areas; dependency versions and design rules are reserved for maintainers. Five MRs were closed as product decisions and two for missing agreement. (documented; `gitlab-org/gitlab-environment-toolkit:CONTRIBUTING.md@f2a01184`, `gitlab-org/gitlab-environment-toolkit:.gitlab/merge_request_templates/default.md@f2a01184`, [!1593](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1593), [!1792](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1792), [!1659](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1659))
- Use the Custom Config hooks for niche settings instead of new variables; when a variable is warranted, put it in the common defaults with an `_enable` suffix for switches, append custom tasks at the end of roles, and keep examples lean, since they are starting points rather than complete configurations. (observed, 5 MRs; [!1820](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1820), [!1822](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1822), [!1588](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1588), [!1893](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1893))
- Run `terraform fmt`, `tflint`, `ansible-lint`, markdownlint and the lychee link check as `AGENTS.md` lists, and confirm Secret Detection and IaC SAST pass, as the author checklist asks. Keep docs in `docs/` in step with the module code. (documented; `gitlab-org/gitlab-environment-toolkit:AGENTS.md@cf349b91`, `gitlab-org/gitlab-environment-toolkit:.gitlab/merge_request_templates/default.md@f2a01184`)
- Consider who else depends on a file before changing it: pinning an exact Python version would have broken asdf users, and replacing deprecated settings had to wait for the planned removal. (observed, 2 MRs; [!1454](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1454), [!1444](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1444))
- You cannot apply the template's `/milestone %GET` and type labels; leave a comment mentioning the maintainers group the template names and ask them to. Ignore Danger's "does not refer to an existing milestone" warning on a fork MR. (observed, 10 MRs; [!1803](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1803), [!1848](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1848), [!1760](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1760), [!1876](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1876))
- Point out fork pipeline failures unrelated to your change (molecule jobs with no runner, jobs not enabled in forks) in a comment instead of trying to fix them; maintainers sort out the pipeline when the MR is ready. (observed, 6 MRs; [!1770](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1770), [!1822](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1822), [!1872](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1872))
- `@gitlab-bot ready` requests nobody here: GET is one of the projects with their own review process, so the command only marks the MR ready and adds `workflow::ready for review`, with no reviewer and no reply, even if you name someone. Request review through the contributor platform's Request review action, or ask the maintainers group the MR template names (`@gitlab-org/maintainers/gitlab-environment-toolkit`; the project has no CODEOWNERS file). The template says reviews aim to happen within two weeks and to ping that group if nobody responds. (enforced; `gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867`, `gitlab-org/gitlab-environment-toolkit:.gitlab/merge_request_templates/default.md@f2a01184`)
- Expect a reviewer and then a GET maintainer. A reviewer suggested by the platform without GET knowledge usually hands the MR to the maintainers group. (observed, 4 MRs; [!1803](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1803), [!1848](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1848))
- Check the diff before creating the MR: personal Terraform config, state and lock files were committed by mistake once. (observed, 1 MR; [!1626](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1626))

## Troubleshooting

**Danger warns that the MR "does not refer to an existing milestone"**
- Cause: the template's `/milestone %GET` quick action cannot be applied by non-members.
- Fix: ignore it and ask the maintainers group to set the milestone.
- Who can fix it: a maintainer or member.
- Sources: [!1760](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1760), [!1837](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1837), [!1893](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1893)

## Why MRs here were closed

- Product decisions: a setting Custom Config already covers ([!1588](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1588), [!1893](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1893)), a tool-specific workaround for a problem every deployment method has ([!1792](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1792)), a heavier example architecture ([!1659](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1659)), a breaking Python pin ([!1454](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1454)).
- Missing agreement: a feature request that needed evaluation ([!1593](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1593)), a premature replacement of deprecated settings ([!1444](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1444)).
- Superseded by a maintainer's approach (a provider bump, a cleaner change, a narrower custom-config MR) ([!1838](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1838), [!1902](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1902), [!1770](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1770)).
- Duplicates and mistakes: a copy of an open MR ([!1436](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1436)), already fixed in a release ([!1515](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1515)), meant for another repository ([!1432](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1432)), personal files committed ([!1626](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1626)), withdrawn ([!1592](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/merge_requests/1592)).
