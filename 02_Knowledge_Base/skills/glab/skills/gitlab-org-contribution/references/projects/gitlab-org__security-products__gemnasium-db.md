# gitlab-org/security-products/gemnasium-db

The GitLab Advisory Database: one YAML advisory per package and identifier, read by GitLab dependency scanning. Advisories are never deleted, the advisory team often folds a correction into a broader MR of its own, and `@gitlab-bot ready` requests no reviewer here because the project has an external review process.

| Fact | Value |
| --- | --- |
| Default branch | `master` |
| Language | YAML data with Ruby tooling |
| Fork to use | Community fork `gitlab-community/gitlab-org/security-products/gemnasium-db` (advisory CI runs there) |
| Merge settings | Squash default off, no merge train, pipeline must succeed, all threads must be resolved |
| Commit convention | No commit linter; titles name the advisory and package; a batch title starts with `Batch import` |
| MR template | `New Advisory` |
| Changelog | None |
| Contributor docs | `CONTRIBUTING.md` (fields, ranges, review) |

Each rule ends with its kind and its sources (see the legend in `INDEX.md`).

## Advisory content

- Follow the field rules in `CONTRIBUTING.md`: every value double-quoted, files starting with `---`, two-space indentation and text at most 150 characters wide (enforced in CI); `identifiers` with the public ID (or a `GMS-<year>-<nr>` ID when there is no CVE); `package_slug` naming the package where the flaw actually is, not a meta-package that depends on it; `affected_range` in the package type's syntax (square brackets inclusive, parentheses exclusive); and `fixed_versions` that were published. Check versions against NVD or the vendor advisory and against the fix commits and tags, and look for backports. (documented; `gitlab-org/security-products/gemnasium-db:CONTRIBUTING.md@2ecf618d`, [!31977](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/31977), [!34252](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/34252))
- Validate each file with `ci/schema/validate.rb <file>.yml` before pushing, and run `yamllint` with the repository's `.yamllint`. (documented; `gitlab-org/security-products/gemnasium-db:CONTRIBUTING.md@2ecf618d`)
- Keep the NVD CVSS vector when NVD has one; use the CVSS calculator only when no score is published. A correction that replaced NVD's score with a vendor's was redone by the team. (documented; `gitlab-org/security-products/gemnasium-db:CONTRIBUTING.md@2ecf618d`, [!34253](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/34253))
- Contribute advisories in batches of at most 50, all of one package type where possible, with a title starting `Batch import`. (documented; `gitlab-org/security-products/gemnasium-db:CONTRIBUTING.md@2ecf618d`)
- Never delete an advisory file, even for a withdrawn CVE or a false positive: the team keeps the file, sets the title to `False Positive`, the description to "This advisory has been marked as a false positive." and an affected range that matches no version. For Maven the team used `(0)` (earlier `(,0)`). Propose that change instead of a deletion. (observed, 6 MRs; [!44680](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/44680), [!44692](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/44692), [!35185](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/35185), [!35384](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/35384), [!44921](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/44921), [!45008](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/45008))
- Before opening, check `master` and open MRs for the same advisory; several MRs were already fixed or merged elsewhere. (observed, 3 MRs; [!31947](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/31947), [!46809](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/46809), [!32209](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/32209))

## Review

- `@gitlab-bot ready` only changes the label here: triage-ops skips reviewer assignment for projects with an external review process. Request review through the contributor platform's request-review link, or mention a member of the advisory team you found in the history of merged advisory MRs. (enforced; `gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867`)
- Link your evidence (upstream issue, registry page, NVD entry) and allow commits from members: the team may fold your correction into a broader MR that covers more packages, or open its own when it cannot edit your branch. Answer questions about the package slug with evidence; an MR whose author did not answer was closed. (observed, 4 MRs; [!32908](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/32908), [!34253](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/34253), [!32872](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/32872))

## Troubleshooting

**After `@gitlab-bot ready` the MR is labeled but no reviewer is requested**
- Cause: triage-ops skips reviewer assignment for projects with an external review process.
- Fix: request review through the contributor platform, or mention a reviewer from the advisory team.
- Who can fix it: you.
- Sources: `gitlab-org/quality/triage-ops:triage/processor/community/command_mr_request_review.rb@837f6867`

## Why MRs here were closed

- Deleted advisories instead of marking them false positives; the team made the false-positive change in its own MR ([!44680](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/44680), [!44681](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/44681), [!44682](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/44682), [!35185](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/35185), [!44921](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/44921)).
- Folded into a broader team MR ([!32908](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/32908), [!34253](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/34253)) or merged through another MR ([!46809](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/46809)).
- Not needed: the range already behaved as wanted, or the version was never published ([!31977](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/31977), [!34252](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/34252)); already on `master` ([!31947](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/31947)); duplicate MRs by one author ([!31946](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/31946), [!32209](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/32209), [!32210](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/32210)); unanswered review ([!32872](https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/merge_requests/32872)).

## Open questions

- Which empty range the CI treats as "matches nothing" for package types other than Maven; check a recent false-positive MR of the same package type before choosing one.
