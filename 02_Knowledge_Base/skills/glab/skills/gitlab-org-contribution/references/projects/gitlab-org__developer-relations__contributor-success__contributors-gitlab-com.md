# gitlab-org/developer-relations/contributor-success/contributors-gitlab-com

The source of contributors.gitlab.com, the contributor platform: a Rails and Vue application that onboards people into the community forks, posts review, help, label and assignment requests on their behalf (its bot account is `contributors.gitlab.com`), and scores points, levels and hackathon leaderboards. The hackathon rules and the platform user guide live here too.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Languages | JavaScript, Ruby, Vue |
| Fork to use | Community fork `gitlab-community/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com` (required in practice) |
| Merge settings | Squash always, squash message template `%{first_commit}`, merge trains on, all threads must be resolved |
| Commit convention | A `Changelog:` trailer (`Feature`, `Bug` or `Maintenance`) on commits; contributions under the Developer Certificate of Origin |
| MR template | `.gitlab/merge_request_templates/default.md` |
| Changelog | Generated from the `Changelog:` trailers; no file to edit |
| User docs | `contributors/public/docs/` (served at https://contributors.gitlab.com/docs) |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Clone and branch from the community fork. Maintainers requested changes on MRs from personal forks only to ask for the move, and five MRs were closed and recreated in the community fork. (documented; `gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:CONTRIBUTING.md@d706ed11`, [!2904](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2904), [!2926](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2926))
- Add a `Changelog: Feature`, `Changelog: Bug` or `Changelog: Maintenance` trailer to the commit; the release note section is generated from it. Squash always uses the first commit's message, so put the trailer there. (documented; `gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:CONTRIBUTING.md@d706ed11`)
- Fill the `default.md` template: What does this MR do and why?, Screenshots or screen recordings, Validation steps. (documented; `.gitlab/merge_request_templates/default.md` in this project, as summarized in `CONTRIBUTING.md@d706ed11`)
- Expect two approvals, one from a code owner, for anything but non-code or single-file changes. Pick the code owner from `.gitlab/CODEOWNERS` for the paths you touch. (documented; `gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:CONTRIBUTING.md@d706ed11`)
- GitLab Duo can approve or request changes on MRs here; a Duo change request blocks the merge like a person's until Duo approves a later review or a member bypasses it. Answer its findings and ask for a follow-up Duo review. (observed, 1 MR here; [!2965](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2965))
- In specs, write the expected value as an independent literal (`eq(20)`, not `eq(described_class::REPORTER_ACCESS_LEVEL)`) when the value under test comes from a production constant, so a wrong constant cannot change both sides of the assertion. The Duo review instructions here flag the reverse. (documented; `gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:.gitlab/duo/mr-review-instructions.yaml@22431cb4`)
- For the development environment, tests and lint, follow `DEVELOPMENT.md` (which `AGENTS.md` points to) and the hooks in `lefthook.yml`. (documented; `CONTRIBUTING.md@d706ed11`)
- `DEVELOPMENT.md` sets up a Dev Container built from `docker/dev.Dockerfile`: copy `docker/.env.docker.example` to `docker/.env.docker`, open the repository in an IDE that supports Dev Containers and reopen it in the container; the app runs on `http://localhost:3030` and `rake data:seed` seeds it. Inside it run `bundle exec rspec` (the test environment loads `docker/.env.docker.example`), `npm run test`, `rubocop`, `npm run lint`, `npm run typecheck` and `markdownlint-cli2`. After changing what an endpoint returns, run `generate_api_types`, since the `api-contracts` job fails on a stale `doc/openapi.yaml` or generated TypeScript; after changing a GraphQL query, run `npm run graphql:codegen`, since `typecheck:graphql` fails on a stale file. Outside the container, `mise install` gives Node 24.22.0, Ruby 4.0.7 and lefthook, the versions of the CI images. (documented; enforced; `gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:DEVELOPMENT.md@af2e5629`, `gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:mise.toml@ca96dde4`, `gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:.gitlab-ci.yml@ca96dde4`)
- Assign the issue to yourself through the platform's manage-issue page before you start, so others see it is taken; two contributors took the same unassigned issue and one MR was closed. (observed, 3 MRs; `gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/controllers/api/v1/manage_issue_controller.rb@f39cc821`, [!2930](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2930))

## Hackathon rules hosted here

The hackathon rules for every project are in `contributors/public/docs/hackathon-rules.md`: at most 20 MRs a day, assignment to the issue before opening an MR for it, and one typo-fix MR per project; an MR counts when it merges within 31 days. One author withdrew six hackathon MRs at once to follow these rules. (documented; `gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/public/docs/hackathon-rules.md@eddd645f`, `gitlab-org/developer-relations/contributor-success/contributors-gitlab-com:contributors/app/javascript/pages/hackathon-page/DetailsSection.md@6f095948`, [!2892](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2892))

## Where the platform's behavior is defined

When a platform action surprises you, these files say what it does:

- `contributors/app/controllers/api/v1/manage_merge_request_controller.rb`: the notes and quick actions behind Request review (including the hidden gitlab-bot line that asks GitLabDuo) and Ask for help.
- `contributors/app/javascript/pages/manage-merge-request-page/RequestReviewAction.vue`: default reviewer selection and the four-reviewer cap.
- `contributors/lib/review_capacity_picker.rb`: how the suggested reviewer is picked.
- `contributors/app/controllers/api/v1/manage_issue_controller.rb` and `contributors/app/controllers/concerns/manageable_concern.rb`: issue assign, unassign and close, and who may use the manage pages.
- `contributors/public/docs/user-guide.md`: points, levels, rewards and the manage page URLs.

## Troubleshooting

**A maintainer requests changes only to say the MR should come from the community fork**
- Cause: the MR was opened from a personal fork.
- Fix: push the branch to the community fork, open a new MR from it, close the old one with a link.
- Who can fix it: you.
- Sources: [!2911](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2911), [!2913](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2913)

## Why MRs here were closed

- Opened from personal forks and recreated in the community fork ([!2904](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2904), [!2911](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2911), [!2912](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2912), [!2913](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2913), [!2926](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2926)).
- A batch of hackathon MRs withdrawn by the author to follow the hackathon rules ([!2892](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2892) to [!2897](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2897)).
- Duplicates: two contributors took the same unassigned issue ([!2930](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2930)), or an author's own earlier MR covered it ([!2908](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2908), [!2910](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2910)).
- A test MR ([!2966](https://gitlab.com/gitlab-org/developer-relations/contributor-success/contributors-gitlab-com/-/merge_requests/2966)).
