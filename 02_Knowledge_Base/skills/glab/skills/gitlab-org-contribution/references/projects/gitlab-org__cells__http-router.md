# gitlab-org/cells/http-router

The Cells HTTP router, a TypeScript Cloudflare Worker built with npm (not Go, despite the generic example in `CONTRIBUTING.md`). Most community MRs refresh the route snapshot for a `gitlab-org/gitlab` MR that adds routes, and the router MR must merge first. There is no community fork, a personal-fork pipeline fails before any job is created, and merge pipelines run again on a mirror you cannot open.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | TypeScript |
| Fork to use | Personal fork (no community fork exists, checked 2026-10-22) |
| Merge settings | Squash default on, merge trains on, pipeline must succeed, all threads must be resolved |
| Commit convention | `CONTRIBUTING.md` commit hygiene (small atomic commits, subject at most 72 characters, explain why, no merge commits, every commit builds); not linted |
| MR template | `.gitlab/merge_request_templates/Default.md`: what and why, references, numbered local validation steps, acceptance checklist |
| Changelog | None |
| Contributor docs | `CONTRIBUTING.md`; `docs/adding-gitlab-routes.md` for route snapshot MRs |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- When your `gitlab-org/gitlab` MR changes `config/routing/gitlab_routes.json`, open a router MR that runs `npm run download-gitlab-routes -- <your branch>` (with `GITLAB_ROUTES_PROJECT=<fork path>` when the GitLab branch is in a fork), `npm run generate-route-guards` and `npm run test -- routes.spec.ts`, and commit the snapshot files together. Merge the router MR first, then rerun `cells-routes:router-in-sync` on the GitLab MR; if that order is impossible, the GitLab MR needs the `pipeline:skip-router-sync` label with a reason. The GitLab job reads the snapshot from the router's `main`. (documented; `gitlab-org/cells/http-router:docs/adding-gitlab-routes.md@2a003ea7`, [!1438](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1438), [!1354](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1354))
- Fill in the template's "How to set up and validate locally" with the exact commands and their output, and link the paired GitLab MR under References. Reviewers merged snapshot refreshes quickly when the description showed the download output and why no routing rule changed. (documented; `gitlab-org/cells/http-router:.gitlab/merge_request_templates/Default.md@eb884a4a`, [!1438](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1438), [!1354](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1354))
- Install the lefthook hooks or run their commands before committing: prettier and eslint on TypeScript, markdown-link-check on docs, the type check, and `npm run generate` when wrangler config inputs change. Check each commit with these npm commands; the `make build format lint test` example in `CONTRIBUTING.md` is copied from another project and does not apply. (documented; `gitlab-org/cells/http-router:lefthook.yml@63b24346`, `gitlab-org/cells/http-router:CONTRIBUTING.md@f9a43adc`)
- Use the Node version in `.tool-versions` (`nodejs 25.9.0`, beside jsonnet-tool 1.19.0; `.mise.toml` only aliases jsonnet-tool to its GitLab release source). CI builds its job image with that version, and `validate-node-version` fails when the image's Node differs from `.tool-versions`. Install as the jobs do, with `npm ci` at the root and `npm ci --prefix integration`. (enforced; documented; `gitlab-org/cells/http-router:.tool-versions@d75c5628`, `gitlab-org/cells/http-router:.mise.toml@7f0d3273`, `gitlab-org/cells/http-router:.gitlab-ci.yml@c261146b`)
- From a personal fork, expect the MR pipeline to fail before any job starts (see Troubleshooting). Ask a maintainer to run the pipeline in the canonical project, and say whether your MR touches `.gitlab-ci.yml`. (enforced; `gitlab-org/cells/http-router:.gitlab-ci.yml@c261146b`, [!1438](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1438))
- Do not wait for a Danger comment: the danger-review include runs only for MRs whose source project is the canonical project or its security mirror. (enforced; `gitlab-org/cells/http-router:.gitlab-ci.yml@c261146b`)
- For a snapshot refresh, ask for review from whoever asked for it in the paired GitLab MR or whoever merged the last snapshot refreshes (the history of the snapshot files), and say why in the ready note. Both MRs that did this were approved within a day. (observed, 2 MRs; [!1354](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1354), [!1438](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1438))
- After a first approval, ask a member of the maintainers group named in `CODEOWNERS` for the Code Owner approval `main` requires, if none has approved yet; an approved MR with a green pipeline waited for it until the contributor asked. (enforced; `gitlab-org/cells/http-router:CODEOWNERS@c6b7c620`, [!1438](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1438))
- Answer the reviewer and keep companion MRs in sync, or say you cannot continue; the one closed community MR was a draft with a failing pipeline whose author never answered, and gitlab-bot closed it. (observed, 1 MR; [!1207](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1207))

## Troubleshooting

**The MR pipeline fails before any job is created; CI lint says "jobs renovate_bot config should implement the script:, run:, or trigger: keyword"**
- Cause: `renovate-bot.yml` is included only for the canonical project, while the `renovate_bot` override is always defined, so in a fork the job has no script.
- Fix: do not edit CI in your MR. Ask a maintainer to run the pipeline in the canonical project and confirm your MR does not touch `.gitlab-ci.yml`.
- Who can fix it: a maintainer or member.
- Sources: `gitlab-org/cells/http-router:.gitlab-ci.yml@c261146b`, [!1438](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1438)

**A project bot posts "A pipeline is running on a mirror related to this merge request" with an ops.gitlab.net link you cannot open**
- Cause: merge pipelines are mirrored to ops.gitlab.net for deployment checks.
- Fix: wait; the maintainer who started the merge watches that pipeline.
- Who can fix it: a maintainer or member.
- Sources: [!1354](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1354), [!1438](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1438)

**`cells-routes:router-in-sync` fails on your `gitlab-org/gitlab` MR**
- Cause: your GitLab MR adds or changes routes the router snapshot on `main` does not have yet.
- Fix: open and merge a router MR that refreshes the snapshot from your branch, then rerun the job; if that cannot happen first, ask for the `pipeline:skip-router-sync` label with a reason.
- Who can fix it: you.
- Sources: `gitlab-org/cells/http-router:docs/adding-gitlab-routes.md@2a003ea7`, [!1438](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1438)

## Why MRs here were closed

- Stale: a draft with a failing pipeline and companion MRs out of sync, closed by gitlab-bot after the author did not answer ([!1207](https://gitlab.com/gitlab-org/cells/http-router/-/merge_requests/1207)).
