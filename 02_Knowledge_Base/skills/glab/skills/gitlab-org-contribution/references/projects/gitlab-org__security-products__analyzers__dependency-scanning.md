# gitlab-org/security-products/analyzers/dependency-scanning

The Go analyzer behind GitLab dependency scanning, which builds SBOMs from lock files. It requires a changie entry for user-facing changes, documents strict commit hygiene, tests parsers with golden files, and expects two reviews. `CONTRIBUTING.md` requires the community fork.

| Fact | Value |
| --- | --- |
| Default branch | `main` |
| Language | Go (the repository statistics are dominated by JavaScript test fixtures) |
| Fork to use | Community fork `gitlab-community/gitlab-org/security-products/analyzers/dependency-scanning`. `CONTRIBUTING.md` links the older path `gitlab-community/security-products/analyzers/dependency-scanning`, which redirects there (checked 2026-10-22) |
| Merge settings | Squash always, merge trains on, pipeline must succeed, all threads must be resolved |
| Commit convention | Documented hygiene: atomic commits, subject of at most 50 characters with an optional `package:` scope, body wrapped at 72 |
| MR template | `default.md` (what and why, related issues, how to validate locally, label quick actions) |
| Changelog | changie entries under `.changes/unreleased/` |
| Contributor docs | `CONTRIBUTING.md`, `AGENTS.md`, `.gitlab/duo/mr-review-instructions.yaml` |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Rules

- Open the MR from the community fork, as `CONTRIBUTING.md` requires. Personal-fork pipelines failed the License Approval Policy (no SBOM reports) and feature checks, and two MRs had to be reopened. (documented; `gitlab-org/security-products/analyzers/dependency-scanning:CONTRIBUTING.md@55185c7e`, [!71](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/71), [!595](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/595))
- Add a changie entry for features, fixes, deprecations and removals: run `changie new` and commit the file in `.changes/unreleased/`. Use Added, Fixed, Deprecated or Security; Changed and Removed are only for breaking changes, need `~"breaking change"`, and a check rejects them otherwise. Leave `MR: "0"` for release automation to fill, and write the body as the user-visible outcome. (enforced; `gitlab-org/security-products/analyzers/dependency-scanning:CONTRIBUTING.md@55185c7e`, `gitlab-org/security-products/analyzers/dependency-scanning:.gitlab/duo/mr-review-instructions.yaml@fb90ddfc`, [!257](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/257))
- Keep commits small and atomic, separate refactors from behavior changes, rebase instead of merging the target branch, and make every commit build and pass tests; write subjects of at most 50 characters, optionally scoped `package: summary`. (documented; `gitlab-org/security-products/analyzers/dependency-scanning:CONTRIBUTING.md@55185c7e`)
- Do not prefix MR titles with the project or component name (`Dependency Scanning:`, `yarn:`); state the change. (observed, 1 MR; [!596](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/596))
- Install the toolchain with `mise install`. When you change the Go version, change it in every place that names it: `go.mod` with a `0` patch version (`go 1.26.0`) and no `toolchain` directive; the `Dockerfile`'s `ubi-go` image at the latest patch, with `EXPECTED_GO_FIPS_VERSION` set to the version it ships; `mise.toml` and `.gitlab-ci.yml` with major.minor only; and a golangci-lint version built with at least the Go version in `go.mod`. After editing reachability rules, run `scripts/gen_reachability_rules.sh`. Run `go test ./...` for the packages you touched and `golangci-lint run`. (documented; `gitlab-org/security-products/analyzers/dependency-scanning:CONTRIBUTING.md@55185c7e`)
- For parser changes, put inputs under `fixtures/` and golden outputs under the parser's `expect/` directory, wired into its table test, rather than inline strings; add an entry to `test/e2e_test.go` when behavior depends on an analyzer variable. (observed, 3 MRs; [!596](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/596), [!599](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/599))
- When you add support for a file type, update the supported files section of `README.md` the way its comments describe; a job checks it. (enforced; [!71](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/71))
- Do not open MRs that only bump dependency versions; the dependency update bot does those. (observed, 1 MR; [!207](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/207))
- Plan for two reviews: pick a first reviewer from Danger's roulette or `CODEOWNERS`; they approve and hand over to a maintainer, who merges through the merge train. A reviewer who applied a suggestion cannot be the one who merges. (observed, 6 MRs; [!256](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/256), [!379](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/379))
- Search open MRs and issues, team work included, before you start; a team member merged the same fix first once. (observed, 1 MR; [!585](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/585))

## Troubleshooting

**`cbs-feature-trigger-analysis` or `release temp image` fails in a fork pipeline**
- Cause: the downstream benchmark trigger did not work for forks, and a fresh fork had no version tags.
- Fix: rebase onto current `main`, which carries the fix.
- Who can fix it: you.
- Sources: [!602](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/602)

**The security bot reports that SBOM reports required by the License Approval Policy could not be found**
- Cause: the pipeline ran in a personal fork without the scanners.
- Fix: open the MR from the community fork.
- Who can fix it: you.
- Sources: [!71](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/71), [!72](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/72)

**A job rejects a changie entry of kind Changed or Removed**
- Cause: those kinds are reserved for breaking changes.
- Fix: use Added or Fixed, or add `~"breaking change"` and run a new pipeline if the change is breaking.
- Who can fix it: you.
- Sources: `gitlab-org/security-products/analyzers/dependency-scanning:CONTRIBUTING.md@55185c7e`, [!257](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/257)

## Why MRs here were closed

- Reopened from the community fork ([!71](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/71), [!595](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/595)); reworked as a new MR after review ([!72](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/72)).
- A manual version bump left to the bot ([!207](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/207)); a fix a team member merged first ([!585](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/585)).
- Test MRs used to check fork pipeline behavior, and MRs closed by their authors right after opening ([!600](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/600), [!601](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/601), [!603](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/603), [!76](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/76), [!552](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning/-/merge_requests/552)).
