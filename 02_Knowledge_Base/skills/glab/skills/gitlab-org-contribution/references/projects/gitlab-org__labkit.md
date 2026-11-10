# gitlab-org/labkit

LabKit, the shared Go library for GitLab services (logging, tracing, metrics, correlation, database and Redis clients, feature flags). v1 lives in the root module; active development is in the `v2` module. Conventional commits drive automated releases. Every Go service at GitLab depends on it, which is why size limits are strict and structural changes need agreement first.

| Fact | Value |
| --- | --- |
| Default branch | `master` |
| Language | Go |
| Fork to use | Community fork `gitlab-community/gitlab-org/labkit`, created on 2026-10-19. Before that, contributions came from personal forks whose pipelines could not pass |
| Merge settings | Squash default off, merge trains on, pipeline must succeed, all threads must be resolved |
| Commit convention | Conventional Commits with module-path scopes, header at most 100 characters (`commitlint.config.js`) |
| MR template | None |
| Changelog | None; releases come from commit types (semantic-release posts the released version on the MR) |
| Contributor docs | `CONTRIBUTING.md`, `AGENTS.md`, `.gitlab/duo/mr-review-instructions.yaml` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Write every commit as `<type>(<scope>): <description>` with type feat, fix, docs, refactor, test, chore, ci, perf, revert or style, a scope naming the module path (`v2/log`, `v2/postgres`, `v2/redis`), a lower-case description without a trailing period, and a header of at most 100 characters. Use feat or fix only for user-facing changes: feat cuts a minor release and fix a patch. Squash is off, so your commits reach `master` as written. (documented; `gitlab-org/labkit:CONTRIBUTING.md@8792cb4a`, `gitlab-org/labkit:AGENTS.md@a5b5b538`, `gitlab-org/labkit:commitlint.config.js@d6d8f55d`)
- Keep MRs under 500 changed lines where possible (2,000 is the hard limit; generated mocks and `*.pb.go` do not count) and each commit under 500 lines. Plan larger work as stacked MRs, each targeting its predecessor; from the community fork, whose branches an MR in labkit cannot target, branch each one from its predecessor and target `master` instead (references/commits-and-descriptions.md, Linking the issue); keep renames and moves in their own commits and MRs; squash fix-ups into the commits they correct before review. Do not apply `large-mr::approved` yourself. (documented; `gitlab-org/labkit:CONTRIBUTING.md@8792cb4a`, `gitlab-org/labkit:AGENTS.md@a5b5b538`)
- Run `./scripts/prepare-dev-env.sh` once, then before pushing `mise run test` (both modules), `mise run lint` and `mise run tidy`. Regenerate mocks with `mockery` in `v2` after changing an interface (CI runs `./scripts/check-mock-files.sh`). Run integration tests with `-tags integration` against the docker compose services under `v2/postgres/testdata` and `v2/redis/testdata` when you touch them. (enforced; `gitlab-org/labkit:CONTRIBUTING.md@8792cb4a`, `gitlab-org/labkit:.gitlab-ci.yml@8024160e`)
- Never raise the `go` directive in either `go.mod`; CI's `check-go-version` pins both. If a dependency demands a newer Go, say so in the MR. (enforced; `gitlab-org/labkit:AGENTS.md@a5b5b538`, `gitlab-org/labkit:.gitlab-ci.yml@8024160e`)
- For v2 code follow the design rules: `New()` and `NewWithConfig(cfg)` constructors with a nil-safe `New()`, `Start(ctx)` and `Shutdown(ctx)` components, functional options instead of new required parameters, `context.Context` first on every blocking method, injectable I/O dependencies, configurable timeouts and pool sizes, `sync.Once` for lazy init, minimal exported API. Add no new public API to the v1 root module (bug fixes and dependency updates only). (documented; `gitlab-org/labkit:AGENTS.md@a5b5b538`, `gitlab-org/labkit:.gitlab/duo/mr-review-instructions.yaml@8792cb4a`)
- In tests use testify (`require` for preconditions, `assert` otherwise), table-driven tests with a `name` field and `t.Run`, cover failure paths, and avoid fixed sleeps in timing tests (`require.Eventually` or `require.Never`). (documented; `gitlab-org/labkit:.gitlab/duo/mr-review-instructions.yaml@8792cb4a`, [!456](https://gitlab.com/gitlab-org/labkit/-/merge_requests/456))
- Danger here does not lint commit messages or ask for changelog entries; the Dangerfile excludes both. (enforced; `gitlab-org/labkit:Dangerfile@fa712140`)
- Assign one of the maintainers listed in `CODEOWNERS` as reviewer through `@gitlab-bot ready @<maintainer>`; for `v2/ratelimit` the entry adds the team that owns rate limiting. (documented; `gitlab-org/labkit:CONTRIBUTING.md@8792cb4a`, `gitlab-org/labkit:CODEOWNERS@adcc2508`)
- Before a structural or cross-cutting change (splitting modules, new metric label schemes, CI rules that skip jobs), open an issue and get maintainer agreement; several such MRs were declined after discussion. (observed, 3 MRs; [!136](https://gitlab.com/gitlab-org/labkit/-/merge_requests/136), [!128](https://gitlab.com/gitlab-org/labkit/-/merge_requests/128), [!165](https://gitlab.com/gitlab-org/labkit/-/merge_requests/165))
- In a dependency MR, state the impact on LabKit's consumers; an unanswered question about a dependency's breaking release left an MR open for years. (observed, 1 MR; [!32](https://gitlab.com/gitlab-org/labkit/-/merge_requests/32))

## CI on forks

Every job runs on `gitlab-org` tagged runners, danger-review reads its token from Vault, and `conformance-spec` triggers a downstream project. None of that worked from a personal fork, so maintainers ported approved community MRs into the canonical project with the contributor's commits and authorship. Use the community fork (from 2026-10-19). danger-review still fails for an MR from it, because the fork cannot read that token, but since 2026-10-20 the job is allowed to fail when the MR's source is the community fork, in a pipeline a maintainer runs too, so it no longer blocks; from a personal fork it still does. If your pipeline still cannot run, say so once, enable "Allow commits from members who can merge", keep commits clean and rebased so a port is mechanical, and follow the new MR if a maintainer opens one. (enforced; observed, 4 MRs; `gitlab-org/labkit:.gitlab-ci.yml@8024160e`, [!780](https://gitlab.com/gitlab-org/labkit/-/merge_requests/780), [!768](https://gitlab.com/gitlab-org/labkit/-/merge_requests/768), [!767](https://gitlab.com/gitlab-org/labkit/-/merge_requests/767), [!758](https://gitlab.com/gitlab-org/labkit/-/merge_requests/758), [!456](https://gitlab.com/gitlab-org/labkit/-/merge_requests/456))

## Troubleshooting

**The pipeline never goes green: jobs stay pending, danger-review fails for a missing `DANGER_GITLAB_API_TOKEN`, `conformance-spec` cannot trigger its downstream project**
- Cause: the CI needs the canonical project's runners, secrets and trigger rights.
- Fix: do not try to fix CI from your fork. Write once that the pipeline cannot pass from the fork and ask a maintainer to run it or port the commits; move to the community fork for later MRs, where a failed danger-review is allowed to fail.
- Who can fix it: a maintainer or member.
- Sources: [!768](https://gitlab.com/gitlab-org/labkit/-/merge_requests/768), [!456](https://gitlab.com/gitlab-org/labkit/-/merge_requests/456), [!780](https://gitlab.com/gitlab-org/labkit/-/merge_requests/780)

**A personal fork has no instance runners at all**
- Cause: identity verification is pending on the account.
- Fix: use the community fork, and request a review anyway.
- Who can fix it: you.
- Sources: [!457](https://gitlab.com/gitlab-org/labkit/-/merge_requests/457)

## Why MRs here were closed

- Ported by a maintainer into the canonical project because the fork pipeline could not pass; these merged with the contributor as author ([!758](https://gitlab.com/gitlab-org/labkit/-/merge_requests/758), [!767](https://gitlab.com/gitlab-org/labkit/-/merge_requests/767), [!768](https://gitlab.com/gitlab-org/labkit/-/merge_requests/768)).
- Stale after the fork pipeline could not run or no review was requested ([!453](https://gitlab.com/gitlab-org/labkit/-/merge_requests/453), [!456](https://gitlab.com/gitlab-org/labkit/-/merge_requests/456), [!457](https://gitlab.com/gitlab-org/labkit/-/merge_requests/457)).
- Design decisions: multi-module split, dynamic metric labels, skipping a CI check ([!136](https://gitlab.com/gitlab-org/labkit/-/merge_requests/136), [!128](https://gitlab.com/gitlab-org/labkit/-/merge_requests/128), [!165](https://gitlab.com/gitlab-org/labkit/-/merge_requests/165)); a feature replaced by the owning team's groundwork ([!450](https://gitlab.com/gitlab-org/labkit/-/merge_requests/450)).

## Open questions

- `commitlint.config.js` lists only v1 scopes in its scope list while the docs ask for `v2/...` scopes; whether v2 scopes fail commitlint is not confirmed.
