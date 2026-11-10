# gitlab-org/ruby/gems/gitlab-triage

The gem that runs GitLab triage policies (the engine behind `gitlab-org/quality/triage-ops`). It imports the gitlab-dangerfiles defaults, so commit messages and the `Changelog:` trailer are checked by Danger, and squash is off by default, so your commits usually land as written; some MRs are squashed, which keeps only one commit's message. Most closed community MRs were long-idle ones whose authors stopped answering review or fixing specs.

| Fact | Value |
| --- | --- |
| Default branch | `master` |
| Language | Ruby |
| Fork to use | Community fork `gitlab-community/gitlab-org/ruby/gems/gitlab-triage` |
| Merge settings | Squash default off, squash commit template `%{first_multiline_commit}` (read 2026-10-26), merge trains on, pipeline must succeed, all threads must be resolved |
| Commit convention | The common gitlab-dangerfiles commit message rules |
| MR template | `.gitlab/merge_request_templates/Default.md`; maintainers release with `Release.md` |
| Changelog | `Changelog:` trailers; the release template builds notes from them, and Danger posts "CHANGELOG missing" when no commit has one |
| Contributor docs | `README.md`, `CONTRIBUTING.md` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Run `bundle exec rubocop` and `bundle exec rake spec` before pushing; installing lefthook runs RuboCop on changed files and the specs on pre-push. (documented; `gitlab-org/ruby/gems/gitlab-triage:CONTRIBUTING.md@664448e8`, `gitlab-org/ruby/gems/gitlab-triage:lefthook.yml@c26314b3`)
- `.ruby-version` and `.tool-versions` pin Ruby 3.2.4, but CI runs `bundle exec rake spec` on `ruby:3.0`, `3.1`, `3.2` and `3.3` and RuboCop on `ruby:3.2`, with `BUNDLE_FROZEN=true` and `BUNDLE_PATH=vendor`; the gemspec requires Ruby 3.0 or later. Run the specs on 3.0 too when your change uses newer syntax or standard library. The gemspec builds its file list with `git ls-files`, so build the gem (`bundle exec rake build`, as the `dry-run:gitlab-triage` job does) from a git checkout; outside one the list comes out empty. (enforced; `gitlab-org/ruby/gems/gitlab-triage:.gitlab-ci.yml@d50a3785`, `gitlab-org/ruby/gems/gitlab-triage:.ruby-version@f72d0714`, `gitlab-org/ruby/gems/gitlab-triage:.tool-versions@f72d0714`, `gitlab-org/ruby/gems/gitlab-triage:gitlab-triage.gemspec@2619d006`)
- `CONTRIBUTING.md` says "Add a trailer to every commit with a user-visible change" (`Changelog:`; the next bullet says how to keep it through a squash). Use a category from `.gitlab/changelog_config.yml`, and `changed` when a change makes policies that loaded before fail; dependency updates, documentation-only changes and internal refactors need none. `Default.md` has a Checklist item, "User-visible commits have a `Changelog:` trailer": keep it and tick it. (documented; `gitlab-org/ruby/gems/gitlab-triage:CONTRIBUTING.md@664448e8`, `gitlab-org/ruby/gems/gitlab-triage:.gitlab/merge_request_templates/Default.md@664448e8`)
- Where the trailer goes: squash is off by default, so each commit lands as written, but MRs do get squashed (7 of the last 40 merged MRs, 2 of them community MRs, read 2026-10-26), and the squash template is `%{first_multiline_commit}`, so a squash lands only the message of the oldest commit with a body: on [!419](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/419) the second commit's `Changelog: changed` never reached `master` (https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/commit/25bbe2503b1483efa73a604a431f20953a5808ec carries only the first commit's message). So follow the rule, and because a squash lands only the oldest commit with a body, keep an MR with one user-visible change to one user-visible commit, the oldest with a body, whose trailer then lands whether or not the MR is squashed (references/commits-and-descriptions.md, Changelog entries). An MR with several user-visible changes carries one trailer per change, each in the commit that makes it, and says in the description that it must not be squashed, and why. (enforced, the squash template; observed, 7 MRs, and !419, whose second commit, https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/commit/2ca7710a9ee4b94cc1fafe33b6b140dfc74c83fd, with `Changelog: changed`, is on no branch or tag; keeping one user-visible change to one commit is observed, not documented)
- The `with integration context` helper's `perform(yaml)` wraps the engine in `expect { ... }.to output.to_stdout`, which captures stdout, so a spec cannot also check through it what the run printed. To assert a warning, call `Gitlab::Triage::Engine.new(policies: policies, options: options).perform` inside your own `expect { ... }.to output(/.../).to_stdout`, after setting `options.dry_run = false` as the helper does. (enforced; `gitlab-org/ruby/gems/gitlab-triage:spec/support/shared_context/integration.rb@c6677092`)
- Fix Danger's commit message and changelog findings as soon as they appear; one author gave up after leaving them for later. (observed, 1 MR; [!349](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/349))
- When your change fixes offenses listed in `.rubocop_todo.yml`, regenerate it with `bundle exec rubocop --regenerate-todo` instead of editing it by hand, and do not bump unrelated gems in the same MR. (observed, 1 MR; [!363](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/363))
- Use verifying doubles (`instance_double`) in specs rather than excluding the cop that asks for them. (observed, 1 MR; [!362](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/362))
- Before adding a client-side filter or workaround, check whether the GitLab API already offers it or a GitLab release fixed the problem. Reviewers prefer API-side filtering, because a client-side check fetches extra data for every resource. (observed, 2 MRs; [!370](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/370), [!227](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/227))
- `.gitlab/CODEOWNERS` assigns every path to the Developer Experience group; pick a reviewer from that group's members or from Danger's reviewer roulette. (documented; `gitlab-org/ruby/gems/gitlab-triage:.gitlab/CODEOWNERS@cee631a2`)
- Keep the pipeline green and answer review, or say plainly that someone else may take the MR over; eight community MRs here were closed as stale, some after years. (observed, 8 MRs; [!296](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/296), [!320](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/320), [!350](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/350), [!372](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/372))

## Troubleshooting

**`danger-review` fails with an SSL or authentication error unrelated to your commits**
- Cause: Danger's token or connection from a personal-fork pipeline; once, the project's Danger token had expired.
- Fix: post the job link and ask a maintainer to retry; use the community fork, where Danger runs without extra setup.
- Who can fix it: a maintainer.
- Sources: [!312](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/312)

**The only failed job is `code_quality`, with "pull access denied for codeclimate/codeclimate-structure"**
- Cause: the Code Climate engine images were deleted from Docker Hub, and [!429](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/429) removed the job on 2026-10-19, so only branches based on an older `master` still run it.
- Fix: rebase onto `master` and push.
- Who can fix it: you.
- Sources: [!429](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/429), https://gitlab.com/gitlab-community/gitlab-org/ruby/gems/gitlab-triage/-/jobs/17250130116 (on [!419](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/419)), `gitlab-org/ruby/gems/gitlab-triage:.gitlab-ci.yml@d50a3785`

## Why MRs here were closed

- Stale after review questions, conflicts or failing specs went unanswered, closed by maintainers or gitlab-bot ([!147](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/147), [!273](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/273), [!296](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/296), [!320](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/320), [!362](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/362), [!372](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/372)); authors who stopped ([!349](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/349), [!350](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/350)).
- Finished or replaced by a maintainer ([!163](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/163), [!324](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/324)); already fixed in GitLab ([!370](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/370)); a client-side filter abandoned over cost ([!227](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/227)).
- Accidental web-editor MRs ([!319](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/319), [!338](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/338), [!340](https://gitlab.com/gitlab-org/ruby/gems/gitlab-triage/-/merge_requests/340)).
