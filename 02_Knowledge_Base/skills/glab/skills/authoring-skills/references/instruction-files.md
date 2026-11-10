# Authoring AGENTS.md / CLAUDE.md

Project instruction files (`AGENTS.md`, `CLAUDE.md`) follow most of the skill
principles, but they are **always loaded**, so the cost model differs. Loading
details below come from vendor docs and can change; re-check
[Claude Code memory](https://code.claude.com/docs/en/memory),
[OpenCode rules](https://opencode.ai/docs/rules/) and
[agents.md](https://agents.md/) before relying on them.

## Contents

- What carries over
- What differs from a skill
- Section vs reference file vs skill
- Checklist

## What carries over

- **Only what pushes the model off its defaults.** Build/test commands, repo
  quirks, and conventions it gets wrong. Skip what it can read from the code.
- **Lead with the gotchas;** be concrete and checkable ("use 2-space
  indentation", not "format code nicely"); one default plus an escape hatch.
- **Don't railroad;** no environment specifics that go stale (versions, IDs).
- **Progressive disclosure:** keep the entry file lean, link detail files.
- **Fix observed failures,** not imagined ones: add a line when the agent got
  something wrong, then re-test with a real task.
- **Prefer mechanical enforcement** (linters, CI checks, hooks) over prose, and
  say which rules are enforced. The vendor docs say instruction files are
  context, not enforced configuration.

## What differs from a skill

| | Skill | AGENTS.md / CLAUDE.md |
|---|---|---|
| Loading | Name and description always listed; body on trigger | Root and ancestor files every session; nested files on demand |
| Discovery | `description` is the trigger | No description; every line must matter to most tasks |
| Size budget | Body under 500 lines (Anthropic); 100/150 in gitlab-org/ai/skills | Claude Code docs target under 200 lines per file |
| Scope | Task-shaped, portable across repos | Repo- or directory-shaped |
| Nesting | One flat folder | Directory hierarchy (see below) |

Loading and precedence (per the docs above; not tested here):

- **Claude Code** loads `CLAUDE.md` from the working directory and its ancestors
  at launch, and subdirectory files on demand when it reads files there. It reads
  `AGENTS.md` only when no `CLAUDE.md` applies, by default. To share one file,
  make `CLAUDE.md` contain `@AGENTS.md` (imports load at launch, so they
  organize but don't save context) or symlink it.
- **OpenCode** reads `AGENTS.md`, falling back to `CLAUDE.md`; the first match
  wins, so having both means only `AGENTS.md` is used.
- **agents.md** says the nearest file in the tree takes precedence. Claude Code
  says conflicting instructions may be resolved arbitrarily, so don't rely on
  overriding: remove contradictions between root and nested files.
- Subdirectory files cost context only when relevant; use them for
  package-specific rules instead of growing the root file. Claude Code also has
  `.claude/rules/` files whose `paths:` frontmatter scopes them to matching
  files, which suits rules for one area of the tree.

## Section vs reference file vs skill

- **Inline in the file:** needed in most sessions (commands, hard rules,
  pitfalls).
- **Linked reference file or nested file:** needed for one area or sub-case.
  Link it with a plain path and say when to read it; avoid `@import` for
  rarely needed docs because it loads at launch.
- **Skill:** a repeatable multi-step workflow needed in some sessions.
  Reference it by name rather than copying it in.

## Checklist

1. Every line passes "would the agent get this wrong without it?".
2. Trim before adding; Claude Code's guidance is under about 200 lines per file.
3. Concrete, non-contradictory, and consistent across nested files.
4. Rules a tool can enforce point at the tool.
5. If the repo keeps both files, they are identical or one imports the other;
   follow the repo's own rule (gitlab-org/ai/skills keeps `CLAUDE.md` a byte
   copy of `AGENTS.md`).
