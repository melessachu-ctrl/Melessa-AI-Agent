---
name: user-story-journey-mapper
description: "Map the journeys (test cases) of a test plan back to the PRD's user stories, acceptance criteria and functional requirements. For each user story, list the related journey IDs, names and the cross-system screen sequence in [System — Screen] → [System — Screen] format; report coverage gaps (stories or ACs with no journey, journeys tracing to no story, mismatched claims); and draft the fill for the PRD User Stories table's 'Related Test Journeys' and 'Screen Sequence' columns. Use after test-case-preparation, or on any existing test plan."
version: 2.1.0
category: productivity
metadata:
  hermes:
    tags: [prd, qa, traceability, coverage, user-stories]
    related_skills: [pr-requirement-prep, standardized-technical-prd, test-case-preparation]
---

# User Story ↔ Journey Mapper

## Position in the pipeline

```
[1] standardized-technical-prd  →  [2] test-case-preparation  →  [3] user-story-journey-mapper (THIS)
     US-nn / AC-nn.m / FR-nn IDs       TC-xx journeys (row h = coverage)     traceability + coverage gaps + User Stories table fill
```

The mapper does two jobs:
1. **Traceability:** for each user story, which journeys exercise it and through which screens.
2. **Coverage audit:** which stories, ACs or FRs are not tested, which journeys test nothing in the PRD, and where a journey's claimed coverage does not match what its steps actually do.

## ⚠️ Shared Rules — MUST Follow

Load **`pr-requirement-prep`**: newer document wins (flag obsolete requirements); **draft in-chat for PM review before
writing to any page**; re-read before writing; re-fetch after writing.

## Runtime

Written for Claude with the Atlassian connector turned on; it also runs in Codex and Hermes. Tool names per runtime:
`references/runtime-tools.md`.

## PRD status

Read the PRD header's **Document status**. `FINAL` or `LAUNCHED` → proceed. `DRAFT` or no status → ask once whether to map
against this draft; if yes, label the output "mapped against DRAFT v<n>". Always record the PRD and test-plan versions you
mapped, and if the test plan says it was built from an older PRD version, list the FRs and ACs that changed between the two
versions as possible stale coverage.

**IDs:** PRDs written by `standardized-technical-prd` v3 use `US-nn`, `AC-nn.m`, `FR-nn`, `RULE-nn.m`, `V-nn.m`, and sections are
referred to by name (numbers vary because optional sections are omitted). Older PRDs may use `2.1`-style story numbers and
section-number FR IDs (`5.3`); map whatever scheme the PRD uses and keep it in the output.

## Inputs

1. **PRD** (URL or page): the User Stories section (`US-01`, `2.1`, or any numbering) with ACs; FR IDs in Technical Considerations; the Systems to Enhance "Impacted Journeys" column; the User Story ↔ FR ↔ System Change Mapping; the Acceptance Criteria Summary. If the PM dropped User Stories, map to **FR IDs** (and the `AC-FRnn.m` criteria in the Acceptance Criteria Summary) instead and say so.
2. **Test plan** (URL or page): the master page and **every child page** it links (journeys are usually on child pages). Each journey has an ID, a name, tester steps, and ideally row h.) Requirement coverage.

If child pages cannot be read, list the known links and ask for their contents. If the PRD has no user-story section,
stop and ask which section or ID scheme to map to.

## Procedure

### 1. Read the PRD (live)
- Fetch in HTML; record the version.
- Extract every user story: ID, exact text, and its ACs (IDs and text). Extract FR IDs with a one-line summary and the stories each FR covers (the FR's Covers line and the mapping table).
- Capture any "Related Test Journeys" or "Screen Sequence" values already present in the User Stories table (to compare later).

### 2. Read the test plan (live, all child pages)
Build a **journey dictionary** keyed by journey ID:

| Field | Source |
|---|---|
| Journey name | `### Journey TC-xx — <name>` heading or row b.) |
| Declared coverage | row h.) (US / AC / FR IDs), if present |
| Steps | row e.): parse each `System/API: X \| Screen: Y \| Action: Z` |
| Pass criteria | row f.) |
| Depends on / followed by | rows c.) / g.) or the master dependency map |
| Section | child-page section heading (1.1, 1.2…) |

### 3. Derive each journey's screen sequence
From row e.), in step order:
1. Make one node per step: `[<System> — <Screen>]`. Normalise system names to the names in the PRD's Test-Readiness Inventory / Systems to Enhance (e.g. "Customer App (iOS)" → "Customer App").
2. **Collapse consecutive duplicates** (several actions on the same screen = one node).
3. Backend or API steps (`Screen: —`) become `[<System> — backend check]` (or `[<System> — <API/record>]` when the step names it), so the sequence shows where persisted state is verified.
4. Wait or async steps become `[<System> — async: <trigger>]`.
5. Join with ` → `.
If a journey has no steps, derive the sequence from the PRD's flow or sequence diagrams and mark it `[derived]`; if that is not possible, write `[screen sequence missing]`.

### 4. Match journeys to user stories
Use the strongest evidence available, and label it:

| Label | Evidence |
|---|---|
| *(none)*, i.e. **declared** | Journey row h.) lists the US / AC (or an FR whose Covers line or the mapping table ties it to the US) |
| `[PRD-listed]` | The PRD's User Stories table "Related Test Journeys" already names the journey |
| `[inferred]` | No declaration: matched via the FR the journey exercises (from its pass criteria and data), the systems/screens in its steps vs the story, the Systems to Enhance "Impacted Journeys" column, or the dependency chain (a follower inherits its producer's story only if its own criteria test that story) |

Then **verify** every declared or PRD-listed link: does the journey's step sequence reach the screen and its pass criteria
assert the outcome the AC describes? If not, flag it `[claim mismatch: <why>]`. Do not silently drop the link or keep it.

### 5. Coverage audit
Compute and report:
- **Uncovered user stories / ACs**: no journey asserts them. Each one is a gap for `test-case-preparation`.
- **Partially covered ACs**: a journey reaches the screen but does not assert the AC's outcome, or covers only one branch or channel the AC names.
- **Orphan journeys**: trace to no story or FR. Either the PRD is missing a requirement (raise it with the PM) or the journey is regression; regression journeys map to the PRD's Features at Risk rows.
- **Claim mismatches** from step 4.
- **Obsolete references**: journeys citing IDs that no longer exist in the current PRD (shared rule 1).
- **Channel gaps**: a story names a channel (iOS / Android / Web / CSIS) that no mapped journey runs on (from row i.).

### 6. Produce the output (in chat first)

**Per user story:**

```text
### US-01 — As a customer, I want …, so that …
AC coverage: AC-01.1 ✓ (TC-01, TC-03) · AC-01.2 ✗ uncovered

| Journey ID | Journey Name | Covers | Screen Sequence |
|---|---|---|---|
| TC-01 | Ambient fee triggered when qualifying SSI quantity ≥ N | AC-01.1 | [Customer App — Home] → [Customer App — Search] → [Customer App — PDP] → [Customer App — Cart] → [Customer App — Checkout summary] → [Payment Server — Payment] → [Hybris — backend check] → [OIX — backend check] |
| TC-03 | Threshold met across multiple qualifying location groups `[inferred]` | AC-01.1 | … |
```

**Consolidated table:**

| User Story ID | User Story Summary | AC IDs | Journey ID | Journey Name | Link basis (declared / PRD-listed / inferred) | Screen Sequence |
|---|---|---|---|---|---|---|

**Coverage summary:** counts (stories covered / partial / uncovered; journeys mapped / orphan), then the lists from step 5, each item
with a suggested action (add journey X to the test plan; add a US to the PRD; fix row h of TC-yy).

**User Stories table fill (draft):** the consolidated table with `Related Test Journeys` = journey IDs (inferred ones marked) and
`Screen Sequence` = the **primary** journey's sequence for that story (the P0 happy path; list the others by ID only).
Show a diff against what the table currently holds.

**Legend:** declared / `[PRD-listed]` / `[inferred]` / `[derived]` / `[claim mismatch]` / `[screen sequence missing]`.

### 7. Write back (only when approved)
- PRD User Stories table: update only the two columns, keeping everything else (Claude: a targeted `replaceNode` on that table). Re-read before writing; re-fetch after.
- Test plan: if the PM agrees, add or correct row h.) on journeys whose coverage was inferred or mismatched, and update the master's Requirement Coverage Matrix.
- Never write either page without explicit approval.

## Self-check quality gate

- [ ] Every user story (or FR, if stories were dropped) in the current PRD appears in the output.
- [ ] Every journey ID used exists in the journey dictionary; every journey appears either under a story or in the orphan list.
- [ ] Every screen sequence uses `[System — Screen]` nodes joined by ` → `, with consecutive duplicates collapsed.
- [ ] Inferred, derived and mismatched items are explicitly labelled.
- [ ] Declared links were verified against steps and pass criteria, not just copied.
- [ ] The coverage summary lists uncovered ACs, orphans, mismatches, obsolete IDs and channel gaps, each with a suggested action.
- [ ] No feature-specific business logic is written into this skill's instructions.
- [ ] Nothing was written to Confluence without approval.

## Handling ambiguous or missing data

- **Journey ID present but name or steps missing** → output the ID with `[missing in test plan]`.
- **PRD names a journey descriptively with no ID** → match by name against the dictionary; otherwise `[unmatched — assign TC ID]`.
- **Test plan uses a different step format** (free text, execution-page Breakdown column) → extract system and screen per sentence where possible; mark sequences built this way `[derived]`.
- **Multiple PRD versions or a DRAFT PRD** → apply shared rules 1–2 before mapping.
