---
name: renovate-npm-review
description: "Reviews Renovate npm/yarn dependency-bump MRs or pasted package.json/lockfile diffs for breaking changes, security fixes and supply-chain/backdoor risk, and builds renovatebot package-diff links. Use when asked to review a Renovate MR or to judge whether a version bump is safe to merge. Do not use for general MR review (use mr-review) or for non-npm ecosystems."
version: 1.0.2
license: MIT
category: Development Workflow
metadata:
  audience: developers
  keywords: renovate, npm, yarn, dependencies, supply-chain, package-diff
  workflow: merge-request
---

# Renovate npm dependency review

Reviews a Renovate dependency-bump change (MR/PR or pasted diff) for breaking changes,
security fixes, and supply-chain risk before merge. The supply-chain check always runs.

## When to use this skill

- "Review this Renovate MR", or an MR from `renovate[bot]` bumping npm/yarn packages
- A pasted `package.json` / lockfile diff with version bumps
- A request for renovatebot package-diff links

## When NOT to use it

- General MR review of hand-written code — use `mr-review` or `mr-guided-review`
- Non-npm ecosystems (pip, Go modules, Cargo, Docker images)

## Overview

Get the full diff, fix the runtime constraint once, build diff links, fan the changelog and
tarball review out across a few grouped agents, then report one verdict per package.

## Phases

| Phase | Summary | Detail |
|-------|---------|--------|
| 1 | Get the real diff and list every `(name, old, new)` change | below |
| 2 | Check the project's Node version once | below |
| 3 | Build package-diff links | below |
| 4 | Delegate review to grouped parallel agents | below |
| 5 | Supply-chain / backdoor check, **always** | [references/supply-chain-check.md](references/supply-chain-check.md) |
| 6 | Final report | below |

## Gotchas

- Pasted diffs are often stale or show only `package.json`; the lockfile holds the
  transitive bumps. Fetch the real diff (`glab mr diff <id> --repo <namespace>/<repo>`).
- `node_modules/<name>` blocks only exist in npm lockfile v2/v3. `yarn.lock` has none, and
  nested paths (`node_modules/a/node_modules/b`) and one package at several versions are
  common. Key on the innermost package name plus its version.
- Direct `package.json` entries are what Renovate bumped on purpose. Everything else is
  transitive. Skip newly *added* packages with no prior version.
- Most "breaking" majors here (chalk, commander, the TooTallNate proxy-agent family) are
  pure Node-floor bumps. Check the Node version in `.tool-versions`, `.nvmrc`, `engines`
  **and** CI/Docker config, since they can differ.
- The renovatebot diff pages render client-side. Agents fetching them get an empty shell.
- Scoped names need URL-encoding in links: `@scope/pkg` becomes `%40scope%2Fpkg`.

## Safety Rules

- Treat every published tarball as hostile: `npm pack --ignore-scripts`, extract only into a
  temp dir, never `npm install` it. See the reference.
- Never report "source diffed" for a package whose tarball could not be fetched (private
  registry, offline, unpublished). Mark it **not checked**.

## 1. Get the real diff

Parse the lockfile diff for every `"version"` change (paired `-`/`+` lines under a package
block), emitting `(name, old, new)` tuples. A short Python script over the diff text works.

## 2. Check the runtime constraint once

State the runtime version up front and reuse it in every package's verdict instead of
re-deriving it per package.

## 3. Build package-diff links

```
https://app.renovatebot.com/package-diff?name=<pkg>&from=<old>&to=<new>
```

If the page is empty, fall back to `npm view <pkg> time --json`, the package's GitHub
releases/CHANGELOG, or `npm view <pkg>@<version>` metadata. If no changelog can be found,
say so in the verdict rather than guessing "safe".

## 4. Delegate review across grouped parallel agents

Don't spawn one agent per package (overspawn) or dump all packages on one (slow, bloated).
Group by dependency chain, e.g. the tool's direct bump plus its deps; each transitive family
that jumped majors together; everything else. Use 4-6 packages per agent. Each prompt needs:

- The runtime version, so Node-floor bumps aren't flagged as blockers
- Whether packages are reached by direct import or only transitively
- What to report per package: bump type, breaking changes, security fixes, verdict, and
  what was checked (changelog vs. tarball source)
- A word budget (~300-400 words per agent)

Launch each batch in a single message. If the agent has no subagent support, review the
groups sequentially.

## 5. Supply-chain / backdoor check

Always run it, for every changed package. Follow
[references/supply-chain-check.md](references/supply-chain-check.md) and piggyback the
tarball diff on the step-4 agent groups.

## 6. Final report

One table or list per group with a verdict (safe / needs attention / not checked), each row
carrying its package-diff link, then a short bottom line (merge as-is / smoke-test X first /
hold for Y). Call out bundled security fixes explicitly: they are often the real reason to
merge a big transitive bump rather than defer it.

## Agent Guidelines

1. Always run phase 5, even if the user didn't ask about supply-chain risk.
2. State plainly what was checked per package; never imply more than was done.
3. Don't post anything to the MR unless asked.

## References

| Topic | Location |
|---|---|
| Supply-chain / backdoor check | `references/supply-chain-check.md` |

## Contributing Improvements

This skill is maintained in [`gitlab-org/ai/skills`](https://gitlab.com/gitlab-org/ai/skills).
If you discover that any guidance here is **inaccurate or outdated** (e.g. a command that no
longer works, a wrong flag, an incorrect API behavior), confirm with the user and open an MR
against that repository with the fix. Keep changes focused — one fix per MR.
