# gitlab-org/technical-writing/docs-gitlab-com

The Hugo site that builds docs.gitlab.com, with Go tooling, Vue and JavaScript, and YAML navigation data. Page content lives in the source projects (`gitlab-org/gitlab` `doc/`, the runner, charts, omnibus and others) and is mounted at build time, so this repository takes only site, navigation and tooling changes. Danger routes review to the Technical Writing team, and fork MRs get no review app.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | JavaScript, Go and Hugo templates |
| Fork to use | Community fork `gitlab-community/gitlab-org/technical-writing/docs-gitlab-com` (personal forks can run out of CI minutes) |
| Merge settings | Squash default on with the first commit's message as the squash message, merge trains on, pipeline must succeed, all threads must be resolved |
| Commit convention | No commit linter beyond the common Danger commit rules |
| MR template | `Default.md` (why rather than what, related issues, screenshots or review app link, local validation steps, checklist, labels) and `Navbar_item.md` for navigation changes |
| Changelog | None |
| Contributor docs | `CONTRIBUTING.md`, `AGENTS.md` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Fix page content in the project that owns the page, not here: this repository only builds the site, its navigation and tooling. (documented; `gitlab-org/technical-writing/docs-gitlab-com:AGENTS.md@09561f75`)
- Run `make setup` and `make clone-docs-projects` once, then `make view` to preview, `make test`, and `make check-pages-not-in-nav` for navigation changes. The lefthook pre-push hook runs the Dockerfile, frontend, Go, Markdown, shell and YAML linters plus the Go and JavaScript tests. (documented; `gitlab-org/technical-writing/docs-gitlab-com:AGENTS.md@09561f75`)
- `mise.toml` pins Go 1.25.10, Hugo extended 0.154.5, Node 22.23.2, glab and the linters, and says these are development versions, with the production versions in `.gitlab-ci.yml`; `package.json` pins Yarn 4.13.0. Run `mise trust` once in the checkout, then `make setup`, which installs the mise tools and runs `yarn install`. The build reads the source projects from sibling directories named `gitlab`, `gitlab-runner`, `omnibus-gitlab`, `charts-gitlab`, `gitlab-operator`, `cli` and so on, so put your clone of the project whose docs you change next to `docs-gitlab-com` under that name and let `make clone-docs-projects` clone the rest (`CI=true` makes shallow clones, as CI does; full clones "may take several minutes for large repositories"). `make view` serves the site at `http://localhost:1313`; in a container, set `HUGO_BIND_IP=0.0.0.0`. If `make setup` fails installing glab with a 401 or 404, run `mise uninstall --all glab` and `mise install glab`. (documented; `gitlab-org/technical-writing/docs-gitlab-com:mise.toml@3f0ad7b9`, `gitlab-org/technical-writing/docs-gitlab-com:package.json@ea2b9a5a`, `gitlab-org/technical-writing/docs-gitlab-com:doc/setup.md@9c9f260d`, `gitlab-org/technical-writing/docs-gitlab-com:Makefile@85b04f02`)
- Add a navigation entry (English only, in `data/en-us/navigation.yaml`) only after its page has merged in the source project: `test:check_global_nav_entries` fails until then. Keep such an MR in draft and link the companion MR. (enforced; [!2710](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/2710), [!2699](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/2699), [!2713](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/2713))
- Attach screenshots of visual changes yourself: fork MRs get no review app, and the template strongly recommends showing the change. (documented; `gitlab-org/technical-writing/docs-gitlab-com:.gitlab/merge_request_templates/Default.md@f1ba4da4`, [!2558](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/2558))
- Route review the way `CONTRIBUTING.md` and the Danger message say: navigation changes to the technical writer assigned to the page's stage group (find the group in the page's front matter and the writer on the handbook's technical writing assignments page), code changes to a code owner or a member of the technical writing engineering group, other changes to the docs roulette pick. Six MRs requested through a generic pick were handed to the right writer or owner. (documented; `gitlab-org/technical-writing/docs-gitlab-com:CONTRIBUTING.md@8a49e769`, `gitlab-org/technical-writing/docs-gitlab-com:Dangerfile@295d839d`, [!2719](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/2719), [!2727](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/2727))
- Propose site features in an issue first, and ask about scope and reviewer capacity before a large change. The site avoids customization layers and extra JavaScript, supports only a few local setups, and pointed a Mermaid enhancer series to an upstream package instead. (observed, 6 MRs; [!750](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/750), [!771](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/771), [!745](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/745))
- Check the target project and branch before creating an MR from the web editor; eight closes here were accidental page, config or LICENSE deletions with an unfilled template. (observed, 8 MRs; [!1151](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/1151), [!1633](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/1633), [!2484](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/2484))

## Troubleshooting

**`test:check_global_nav_entries` fails with "No sitemap entry found for global navigation entry URL ... has the page been merged yet?"**
- Cause: the entry points to a page not yet merged in its source project, or your branch is older than `main`.
- Fix: wait for the companion MR to merge, then rebase and run the pipeline again.
- Who can fix it: you.
- Sources: [!2710](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/2710)

**No review app link appears on your MR**
- Cause: review apps are not deployed for fork MRs.
- Fix: build locally with `make view` and attach screenshots; ask a member if a deployed preview is needed.
- Who can fix it: you.
- Sources: [!2558](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/2558)

## Why MRs here were closed

- Accidental MRs from the web editor that deleted pages, config or the LICENSE ([!973](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/973), [!1151](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/1151), [!1152](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/1152), [!1153](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/1153), [!1633](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/1633), [!1634](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/1634), [!2484](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/2484)).
- A declined Mermaid enhancer and its stacked drafts, auto-closed by gitlab-bot ([!750](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/750), [!771](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/771), [!772](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/772), [!773](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/773), [!774](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/774)); dev container support not wanted ([!745](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/745)).
- A personal branch with unrelated commits targeting a feature branch, with a failing pipeline and no review requested, auto-closed ([!2485](https://gitlab.com/gitlab-org/technical-writing/docs-gitlab-com/-/merge_requests/2485)).
