# gitlab-org/glql

GLQL, the GitLab Query Language: a Rust compiler built to WASM plus a Ruby gem (`glql_rb`). Commits are Conventional Commits checked by commitlint, the MR template's quick actions request GitLabDuo as a reviewer only when a project member opens the MR, and Duo skills in the repository describe what reviewers expect, such as an Example Usage section for user-facing query changes. Generated GraphQL is validated against GitLab's current schema, so work that needs a new backend field waits for the `gitlab-org/gitlab` MR.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | Rust, with a Ruby gem |
| Fork to use | Community fork `gitlab-community/gitlab-org/glql` |
| Merge settings | Squash default on (checked 2026-10-22; most MRs merged up to 2026-10-20 landed without squash), merge trains on, pipeline must succeed, all threads must be resolved |
| Commit convention | Conventional Commits (`.commitlintrc.yml` extends `@commitlint/config-conventional`), checked by lefthook on push and by the `commitlint` job on every commit of the MR; with squash on and no squash template, the MR title is the commit that lands on `main`, and no job lints it |
| MR template | `Default.md`: what and why, how to validate locally, then `/assign me`, `/label` and `/assign_reviewer @GitLabDuo` lines that work only for members |
| Changelog | None to edit; `CHANGELOG.md` is generated at release by conventional-changelog from the commit headers on `main` (the MR title when squashed) |
| Contributor docs | `AGENTS.md`; Duo skills under `.gitlab/duo/skills` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Write every commit as a Conventional Commit and install the lefthook hooks. The `commitlint` job checks every commit from the MR's diff base, whether or not the MR will be squashed, so an early commit that fails commitlint keeps failing until you reword it with an interactive rebase and force-push; adding commits on top does not help. One MR was closed after its author could not get past this. (enforced; `gitlab-org/glql:.gitlab-ci.yml@7f03d603`, `gitlab-org/glql:.commitlintrc.yml@b50338c4`, `gitlab-org/glql:lefthook.yml@148b402b`, [!124](https://gitlab.com/gitlab-org/glql/-/merge_requests/124))
- Give the MR a Conventional Commits title: squash is on by default with no template, so the title alone lands on `main` and becomes the changelog line, and neither commitlint, which skips merge trains and reads only the commits, nor Danger, which imports only `simple_roulette`, checks it. (enforced; `gitlab-org/glql:scripts/create_release.sh@71cd0c88`, `gitlab-org/glql:conventional-changelog.config.js@b50338c4`, `gitlab-org/glql:.gitlab-ci.yml@7f03d603`, `gitlab-org/glql:Dangerfile@e8b4441b`, https://gitlab.com/gitlab-org/glql/-/commit/71cd0c883aa91d75dc97bf62f6ba76c28267596c)
- Run `cargo fmt`, `cargo clippy` with `-D warnings` and `cargo test`, `wasm-pack build` for the WASM target and `rake compile` in `glql_rb`. After a schema change, regenerate `schema.json` with `cargo run --bin generate-schema` followed by `npm run lint:prettier:fix`. (enforced; `gitlab-org/glql:AGENTS.md@7f03d603`, `gitlab-org/glql:lefthook.yml@148b402b`)
- CI's `test` job runs `DUMP_GRAPHQL=1 cargo nextest run` (the job installs cargo-nextest), while `AGENTS.md` and the lefthook pre-push hook use `cargo test`; install cargo-nextest to run what CI runs. Rust 1.89.0 comes from `rust-toolchain.toml`, which rustup applies inside the repository, and the Rust jobs use `rust:1.89-slim`; `build-wasm` runs `wasm-pack build --target web` with wasm-pack 0.13.1. After the WASM build, `test-wasm` runs `npm install`, `npm run build` and `npm run test:ci`, `type-check` runs `npm run type-check`, and `eslint` runs `npm run lint` and `npm run lint:prettier`, all on `node:lts-alpine`, while `.tool-versions` gives Node 22.18.0 and Ruby 3.4.2 for development. (enforced; documented; `gitlab-org/glql:.gitlab-ci.yml@7f03d603`, `gitlab-org/glql:rust-toolchain.toml@96198616`, `gitlab-org/glql:.tool-versions@b64771f7`, `gitlab-org/glql:AGENTS.md@7f03d603`, `gitlab-org/glql:lefthook.yml@148b402b`)
- For user-facing query changes, add an `## Example Usage` section with a GLQL `yaml` block and a collapsible `glql_rb` snippet that compiles the query, runs it against GitLab.com GraphQL and transforms the result. (documented; `gitlab-org/glql:.gitlab/duo/skills/mr-example-usage/SKILL.md@2ab81034`, `gitlab-org/glql:.gitlab/merge_request_templates/Default.md@f3dc9ee9`)
- Keep doc comments to the contract or invariant rather than history or callers, reuse existing crates rather than adding abstraction, and leave "review feedback addressed" sections out of the description. Two MRs were closed for over-abstraction or for reimplementing what a crate provides. (observed, 5 MRs; [!532](https://gitlab.com/gitlab-org/glql/-/merge_requests/532), [!537](https://gitlab.com/gitlab-org/glql/-/merge_requests/537), [!530](https://gitlab.com/gitlab-org/glql/-/merge_requests/530), [!105](https://gitlab.com/gitlab-org/glql/-/merge_requests/105), [!127](https://gitlab.com/gitlab-org/glql/-/merge_requests/127))
- Discuss the design in the issue first; spikes and approaches that diverged from the project's direction were closed. (observed, 3 MRs; [!105](https://gitlab.com/gitlab-org/glql/-/merge_requests/105), [!127](https://gitlab.com/gitlab-org/glql/-/merge_requests/127), [!133](https://gitlab.com/gitlab-org/glql/-/merge_requests/133))
- The template's `/assign me`, `/label` and `/assign_reviewer @GitLabDuo` lines need `admin_merge_request` in `gitlab-org/glql`, which the Developer role grants, so they do nothing when a contributor without a role opens the MR. Get the Duo review through the contributor platform's Request review, set labels with `@gitlab-bot label`, and request a human reviewer as well: Duo is not one (references/review.md, sections 2 and 3). (enforced; `gitlab-org/glql:.gitlab/merge_request_templates/Default.md@f3dc9ee9`, `gitlab-org/gitlab:lib/gitlab/quick_actions/merge_request_actions.rb@49d9373b`, `gitlab-org/gitlab:lib/gitlab/quick_actions/issue_and_merge_request_actions.rb@b748b633`, `gitlab-org/gitlab:lib/gitlab/quick_actions/issuable_actions.rb@428a138f`, `gitlab-org/gitlab:app/policies/merge_request_policy.rb@b42110b5`, `gitlab-org/gitlab:config/authz/roles/developer.yml@19df6706`)
- Work on a dedicated branch, not your fork's `main`; an MR from the fork's `main` was closed and reopened from a branch. (observed, 1 MR; [!85](https://gitlab.com/gitlab-org/glql/-/merge_requests/85))
- Expect Danger's roulette to suggest reviewers; reviewers use conventional comment labels and move out-of-scope work to follow-up issues. (observed, 3 MRs; [!530](https://gitlab.com/gitlab-org/glql/-/merge_requests/530), [!532](https://gitlab.com/gitlab-org/glql/-/merge_requests/532), [!537](https://gitlab.com/gitlab-org/glql/-/merge_requests/537))

## Troubleshooting

**The test job fails in the community fork with `tar: .cargo/bin: No such file or directory`**
- Cause: a cold CI cache in the fork.
- Fix: ask a member to retry the job; it passed on retry.
- Who can fix it: a maintainer or member.
- Sources: [!566](https://gitlab.com/gitlab-org/glql/-/merge_requests/566), [!517](https://gitlab.com/gitlab-org/glql/-/merge_requests/517)

**`graphql-validate` fails on a field GitLab's schema does not have**
- Cause: the job validates generated GraphQL against GitLab's current schema, and the backend MR adding the field has not merged.
- Fix: keep the MR in draft until the `gitlab-org/gitlab` MR merges, and link it. Reproduce the job before pushing: `DUMP_GRAPHQL=1 cargo nextest run` writes every query the tests compile to `tmp/graphql/`, `./scripts/fetch_gitlab_graphql_schema.sh` downloads gitlab-org/gitlab's current schema to `tmp/gitlab_schema.graphql` without a token, and `npx -p @graphql-inspector/cli -p graphql graphql-inspector validate './tmp/graphql/*.graphql' './tmp/gitlab_schema.graphql' --onlyErrors --relativePaths` lists the fields the schema lacks.
- Who can fix it: you.
- Sources: [!568](https://gitlab.com/gitlab-org/glql/-/merge_requests/568), `gitlab-org/glql:.gitlab-ci.yml@7f03d603`, `gitlab-org/glql:src/lib.rs@616cc36d`, `gitlab-org/glql:scripts/fetch_gitlab_graphql_schema.sh@e09c07ce`

**commitlint keeps failing after you fixed the MR title**
- Cause: an earlier commit message in the branch is not a Conventional Commit.
- Fix: reword it with an interactive rebase (or squash locally) and force-push.
- Who can fix it: you.
- Sources: [!124](https://gitlab.com/gitlab-org/glql/-/merge_requests/124)

## Why MRs here were closed

- Design decisions: over-abstraction, custom logic an existing crate covers, a spike that grew too complex ([!105](https://gitlab.com/gitlab-org/glql/-/merge_requests/105), [!127](https://gitlab.com/gitlab-org/glql/-/merge_requests/127), [!133](https://gitlab.com/gitlab-org/glql/-/merge_requests/133)); ignore entries nobody needed ([!544](https://gitlab.com/gitlab-org/glql/-/merge_requests/544)).
- Companions of `gitlab-org/gitlab` work that was dropped or not ready ([!543](https://gitlab.com/gitlab-org/glql/-/merge_requests/543), [!568](https://gitlab.com/gitlab-org/glql/-/merge_requests/568)).
- A first commit that failed commitlint ([!124](https://gitlab.com/gitlab-org/glql/-/merge_requests/124)); an MR from the fork's `main` ([!85](https://gitlab.com/gitlab-org/glql/-/merge_requests/85)).
