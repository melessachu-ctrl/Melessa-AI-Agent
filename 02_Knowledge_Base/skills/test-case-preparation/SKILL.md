---
name: test-case-preparation
description: "Generate a comprehensive, human- and AI-executable test plan from a PRD (Confluence page, Slack thread or pasted draft). Each journey states exactly what to prepare (prior journey, users, SKUs, orders, system settings, and where and how to set them up), which screen to act on with which exact action, and binary pass criteria to observe on screen and in the backend. Produces a master page plus section child pages, in the format of the Ambient Plastic Bag (Oct 5) test plan or better. Also covers sanity plans, PAT plans, execution-page fills and restructuring an existing plan. Replaces test-case and hktvmall-test-plan-generator."
version: 1.1.0
category: productivity
triggers:
  - generate a test plan / test cases / QA plan for a PRD or feature
  - user provides a PRD link and asks for testing
  - sanity plan / PAT plan / smoke test plan
  - reorganize, reformat or convert an existing test plan ("put each journey in its own table")
  - fill test cases into a test-execution page
metadata:
  hermes:
    tags: [qa, test-plan, test-cases, prd, confluence, hktvmall]
    related_skills: [pr-requirement-prep, standardized-technical-prd, prd-backend-impact-consult, user-story-journey-mapper, qa-test-plan-review]
---

# Test Case Preparation

## Position in the pipeline

```
[1] standardized-technical-prd  →  [2] test-case-preparation (THIS)  →  [3] user-story-journey-mapper
        PRD + Test-Readiness Inventory    master page + journey child pages        US ↔ journey coverage
```

## The three guarantees (what every journey MUST give the tester)

A tester (human or AI) who has never seen the feature must be able to run any journey from its table alone.

1. **Preparation: what must be true before step 1, and where to make it true.**
   - the **prior journey** and the exact **state it leaves** (e.g. "order group from TC-10: main + 1 add-on, both ambient fee paid, not delivered");
   - every **data item**, by register ID and concrete identifiers: user account (tier, address, balance), SKU (code + the attributes that matter), order, courier, voucher;
   - every **system setting**, with its value (flag, threshold, PAT group, config key);
   - for anything not inherited from a prior journey, **which system to go to, the navigation path, what to set, and how to verify it took effect** (including cache refresh).
2. **Action: which screen, which element, what exactly to do**, in `System/API | Screen | Action` form. Use the exact UI labels, exact values, and the behaviour the tester should expect between steps. This comes from understanding how the feature behaves *and* how the app behaves (navigation, where entry points are, what refreshes when).
3. **Pass conditions: binary, observable, located.** Exact values on named screens or labels, plus backend persistence (field = value), plus negative assertions where the rule excludes something. Each criterion points at the step where it is observed.

If you cannot meet a guarantee from the sources, mark the gap `[TBC — <what is missing> — owner]` in the journey and
in Open Items. Do not paper over it with vague wording.

## Minimum bar — the reference plan

The reference is **"Ambient Plastic Bag (Oct 5) - Test Plan"** (Confluence `5970526373`, SPECDOCS) and its four section
child pages (TC-01 … TC-30). Everything it does is the minimum; this skill adds what it lacks. See
`references/reference-plan-ambient-plastic-bag.md` for its structure, what it does well, where it falls short, and
a TC-01 rewritten to this skill's standard.

## Runtime

Written for Claude with the Atlassian connector turned on; it also runs in Codex and Hermes. Tool names per runtime,
and how to load another skill: `references/runtime-tools.md`.

## ⚠️ Shared Rules — MUST Follow

Load **`pr-requirement-prep`**: newer document wins (flag what became obsolete); **draft in-chat for PM review before
writing to any page**; re-read immediately before writing; re-fetch after writing.

## PRD status decides how to proceed

Read the PRD header's **Document status** (set by `standardized-technical-prd`):

| Status | What to do |
|---|---|
| `FINAL` (in development) | Proceed. This is the normal case. |
| `DRAFT` | Ask once: build the plan on this draft now (e.g. to prepare QA early), or wait for FINAL? If the user says proceed, record the PRD version in the plan's Feature Overview and mark the plan "based on DRAFT v<n>". When the PRD later changes, diff the versions and update only the affected journeys. |
| `LAUNCHED` | Proceed; the plan is a regression or PAT reference. Use the launched release version and launch date in the Feature Overview. |
| No status (older specs) | Treat as DRAFT unless the user says it is final. |

Record the PRD version you built from in the plan. If the PRD changed since, say which FRs or ACs changed before reusing the plan.

---

## Modes

| Mode | Trigger | Output |
|---|---|---|
| **Full plan** (default) | "test plan / test cases for this PRD" | Master page + child pages by PRD section (all phases below) |
| **Sanity plan** | "sanity plan", "quick check" | 3–7 happy-path journeys only, same journey format; edge cases are deferred to the full plan explicitly. See Mode notes. |
| **PAT plan** | "PAT", "production acceptance", "post-release smoke" | Same structure, scoped to PAT-group members, with per-platform result columns. See Mode notes. |
| **Execution-page fill** | target page already has its own table schema | Match that page's schema; do not impose this one. See Mode notes. |
| **Restructure** | "reorganize / reformat / put each journey in its own table" | Convert existing cases into this journey format without changing data, thresholds, IDs or pass criteria. See Mode notes. |

---

## Procedure (Full plan)

### Phase 0 — Gather sources (read live, read everything)

Source-of-truth order:
1. **PRD** (live version; sections are referred to by name because numbers vary): User Stories + ACs; Technical Considerations: each `FR-nn` with its `RULE-nn.m` rules, **worked examples** (ready-made expected values), **screen blocks** (component table with display conditions and tap landings, state × component matrix), admin validation `V-nn.m` and editable-by-status rules, Simulation Steps; Systems to Enhance + Features at Risk + Backend / Jobs / API; Error States; Notifications; Copytable and Kafka tab; Acceptance Criteria Summary; Open Questions; **Test-Readiness Inventory** (screens and labels, configuration, data archetypes, observable outputs, jobs and timing).
2. **Figma** for exact screens, labels and states. If unreachable, flag every label `[assumed — confirm in Figma]` and never invent one.
3. **Jira**: epic and story acceptance criteria; **bugs** in the area (each becomes an edge case); linked tickets' test-case bullets (each one must map to a journey).
4. **Code or code-owner answers** (if the agent has repository access, or via `prd-backend-impact-consult`): real UI strings and i18n keys, config keys and defaults, persisted field names, API/event names, log lines, cache layers, async jobs or crons. These turn "verify the flag" into "`Hybris order.ambient_plastic_bag_paid = 1`".
5. **Existing test plans or QA pages** for the same area (CQL `title ~ "test" AND title ~ "<area>"`) for reusable setup and accounts.

If the PRD has no Test-Readiness Inventory (e.g. older specs), build its content yourself in Phase 1–2 from the sources above and list what you had to infer.

### Phase 1 — Build the behaviour model (checkpoint with PM)

Before writing any test, write down how the feature and the app behave. Every expected value is derived from this model.

1. **Rules table**: each FR rule as input conditions → output, with concrete values (thresholds, caps, priorities, eligibility, exclusions).
2. **State model**: entities and their states and transitions (cart → order → paid → waybill → delivered → refunded…), what triggers each transition (user action, courier action, cron, event), and timing (real-time vs scheduled).
3. **System responsibility map**: which system computes, stores, syncs and displays each value.
4. **App behaviour notes**: how a tester reaches each screen (entry path), where entry points sit, what refreshes automatically vs needs pull-to-refresh or reopen, per-platform differences (App-only surfaces), localisation of labels.
5. **Observability map**: for every outcome, where it is visible: screen + label, API field, DB table.column, log line, report.

Present a short summary of the model plus systems, roles, configurable parameters and actors, and **confirm with the PM before
Phase 3**. Errors here repeat in every journey.

### Phase 2 — Build the Environment & Data Register

This becomes master-page sections 2–3. Every journey refers to it by ID, so preparation is written once and done
correctly.

**2a. Systems & access**

| System / Tool | Used for (journeys) | Access / role needed | How to obtain access |
|---|---|---|---|

**2b. Configuration & settings** (`CFG-xx`)

| ID | Setting | Value for this plan | Controlling system → navigation path | How to verify active value | Cache / propagation step | Revert after |
|---|---|---|---|---|---|---|
| CFG-01 | Ambient threshold N | 6 | Backend config console → Plastic Bag → Threshold | Re-open page shows 6; checkout with 5 units shows no fee | Clear config cache / wait X min `[TBC]` | Yes, if a journey changes it |

**2c. Test data** (`D-xx`): one row per data item, with **concrete identifiers** (SKU code, account login reference, address label). Placeholders such as "SSI SKU A" are allowed only as aliases that map to a real code; if the code is unknown, write `[TBC — assign SKU code]`.

| ID | Data item (alias) | Concrete identifier | Required attributes (exact) | System to set up → path | Verification | Notes / conflicts |
|---|---|---|---|---|---|---|
| D-04 | SSI SKU A | `H0888001_S_xxxx` [TBC] | SSI, ambient, location group = PBL1, stock ≥ 10 | MMS → Product → Inventory | MMS shows location group PBL1, stock ≥ 10 | Shared by TC-01…TC-14; re-check stock between runs |

Include: customer accounts (and their state: verified, tier, wallet balance, saved addresses), SKUs per rule branch
(qualifying, non-qualifying, boundary, bundle, other temperature zones), merchant or store setup, couriers, CS agents,
vouchers or promotions, and orders that are created by prior journeys (note them as "created by TC-xx").

Credentials are never written into the plan; refer to the account by a label and where testers get the credentials.

### Phase 3 — Design coverage (checkpoint with PM)

Derive journeys systematically. For each FR and AC, walk the dimensions in `references/coverage-dimensions.md` and keep
only those that apply:

- **Every `RULE` row and branch** (including branches the PRD left blank, which become `[TBC]` journeys and open items), and **every worked example** (each one is at least a pass criterion, usually a journey).
- **Every screen block:** each component's display / hide condition (shown and hidden) and each tap landing; each state in the state × component matrix.
- **Every admin validation rule `V-nn.m`** (valid and invalid input) and the editable-by-status rules (an edit allowed in one status, blocked in another).
- **Every error state** (trigger → copy → buttons → landing) and **every notification** (trigger → channel → copy → landing).
- **Every Kafka event** in the tracking tab, as a tracking check on the journey that triggers it (screen_view on entry, generic_event on the CTA, result event after the API call).
- **Boundaries**: N−1, N, N+1; cap reached and exceeded; empty and maximum.
- **Pre-condition matrix**: user state, platform, account, cart composition, promotion, inventory, payment, feature flag, timing, data volume.
- **Order and lifecycle variants**: main / add-on / marketing add-on, split delivery rounds, cancel, amend, out-of-stock after checkout, partial delivery.
- **Geography and delivery method.**
- **Cross-surface consistency**: the same value on every screen, the API, the stored record and the downstream sync must agree.
- **Async and idempotency**: crons and events, retries, duplicates, concurrent actors (two couriers, CS and customer at once).
- **Configurability**: change the setting, observe the new behaviour, revert.
- **Regression**: one journey per Features at Risk row and per existing behaviour the change touches.
- **Jobs and timing**: each job in Jobs & Timing, run either side of its schedule and cut-off (how to trigger or wait for it in UAT).
- **Known bugs** from Jira in the area.
- **Every ticket test-case bullet** must map to a journey.

Then apply the **falsifiability check** to each scenario (from `qa-test-plan-review`):
- Would this journey **pass on a build without the change**? If so, re-position the data so the changed rule is the binding constraint.
- Every widened condition (`A` → `A OR B`) has **one negative journey** with an object that must still be excluded.
- Data chosen for a flag-gated fix must **not** also satisfy the old condition.

Output the **Scenario Matrix** for PM approval:

| Journey ID | Section | Scenario | Type (Happy / Edge / Negative / Regression / Config) | Covers (US / AC / FR) | Priority (P0–P2) | Depends on | Platforms |
|---|---|---|---|---|---|---|---|

Group journeys by PRD section (1.1, 1.2…) because these become the child pages. IDs are `TC-01…`, stable once shown to the PM.

### Phase 4 — Chain the journeys

- For each journey, record **Depends on** (journeys whose output state it consumes) and **Followed by**.
- A **producer** journey states, in its cleanup/state row, exactly what it leaves behind for its followers.
- Where a dependency is "TC-17 **or** TC-18", say so; where a journey needs a variant of the producer (e.g. two delivery rounds), say how to create that variant.
- Build **execution chains** for efficient manual runs (e.g. `TC-10 → TC-17 → TC-25 → TC-26`).
- Check for cycles, and that destructive journeys (refund, delivery, config change) come after every journey that needs the earlier state.

### Phase 5 — Write each journey

Use the per-journey table in `references/journey-template.md`. Rows a–g match the reference plan exactly; rows h–j
are additions this skill requires.

| Field | Value |
|---|---|
| a.) ID of the journey | TC-xx |
| b.) Brief description of the journey | one line stating the rule under test and the expected outcome |
| c.) ID of journey it depends on | `—` or TC IDs + the state consumed |
| d.) Preconditions / Data Setup | **Prior state** · **Data** (D-IDs with values) · **Settings** (CFG-IDs with values) · **Setup steps** (only for what is not inherited: system → path → action → verify) |
| e.) Tester steps | numbered `System/API: … \| Screen: … \| Action: …` lines (rules below) |
| f.) Expected Observations / Pass Criteria | `•` bullets, each tagged with the step it is observed at (rules below) |
| g.) Journey IDs that follow the current journey | TC IDs or `—` |
| h.) Requirement coverage | US / AC / FR IDs |
| i.) Platforms & evidence | iOS / Android / Web (mark App-only surfaces); screenshots to capture at steps x, y |
| j.) State left behind / Cleanup | what followers can use; what to revert (config, stock, wallet) |

**Writing rules for d.) Preconditions:**
- Never "admin access", "order available" or "customer complains" on its own. Say which account, which order (created by which journey, with which properties), and which setting value.
- When a precondition needs a state that is hard to reach through the UI (two delivery rounds, a courier that did not confirm, out-of-stock after checkout), give the setup method (UI path, back-office action, API or impex) and who can do it. Flag steps that need technical access.
- State date assumptions for any date-dependent data, and re-base them on the execution day.

**Writing rules for e.) Tester steps:**
- One action per step: `N. **System/API:** <system> **| Screen:** <screen> **| Action:** <verb> <exact UI element in quotes> <exact value>`.
- Use the exact labels from the Test-Readiness Inventory's screen table, the copytable or Figma (`Tap "加入購物車" (Add to cart)`), the exact quantities and the exact selection (`Select address "Macau – Test"`).
- Backend steps use `Screen: —` and name what to query: `Query order <id>: field ambient_plastic_bag_paid` (system, table or API, field).
- Async steps say what to wait for and the limit: `Wait for refund cron (every 15 min) [TBC]; max 20 min`.
- Insert a **checkpoint** after any step whose outcome the next step depends on: `→ Expect: Cart badge shows 6`.
- Login and navigation boilerplate may be shortened to one step once the plan's conventions section defines it (e.g. "Open SKU PDP via search", defined once), but **never skip a screen the feature changes**.

**Writing rules for f.) Pass criteria:**
- Binary and exact: `• (step 6) Checkout summary shows line "常溫商品膠袋費" = $1.00`.
- Cover each surface the rule touches: UI at the point of action, the persisted record, downstream sync, and other surfaces that must agree.
- Include the **negative assertion** when the rule excludes something (`• "急凍商品膠袋費" line NOT shown`).
- Derived values show the arithmetic and are labelled derived (`qualifying units = 2 + 2×3 + 2×1 = 10 ≥ 6 [derived]`).
- For idempotency or duplicate checks, assert the count (`exactly 1 refund transaction for the order group`).
- List the evidence to capture (screenshot or record) in row i.

### Phase 6 — Assemble the master page and child pages

**Master page** (reference structure, plus the additions marked ★):

0. ★ **Feature Overview & Scope**: feature, PM owner, epic, PRD link + version + Document status (DRAFT / FINAL / LAUNCHED; for LAUNCHED the release version and launch date), in/out of scope with reasons, environment (UAT/SIT, app build, flag state).
1. **Acceptance Objectives**: numbered, one per area.
2. **System / Tool | Access / Role Needed** (Phase 2a).
3. **Common Data Setup**: ★ the full register (2b settings + 2c data) with system, path and verification.
4. **All User Journeys**: links to child pages by section, with TC ranges, plus ★ a one-line-per-journey index (ID, description, type, priority).
5. **Journey Dependency Map**: `Journey ID | Section | Depends on | Followed by`.
6. **Suggested Execution Order for End-to-End Scenario Chains.**
7. **Acceptance Criteria Summary**: `Area | Acceptance Criteria`.
8. ★ **Requirement Coverage Matrix**: `US / AC / FR | Journey IDs | Status` (covered / partial / uncovered). Uncovered items are listed explicitly.
9. ★ **Conventions**: step format, shortened navigation steps, result legend (PASS / FAIL / BLOCKED / NOT TESTED).
10. **Open Items / Notes / Assumptions**: every `[TBC]` and `[assumed]` with an owner.
11. ★ **Test Execution Summary**: `TC ID | Scenario | Result (per platform) | Tester | Date | Evidence | Notes`, with results left empty.

**Child pages**: one per PRD section group (about 5–10 journeys each, keeping each page well under the Confluence body
limit), titled `<Feature> — <x.y–x.z> <Section names>`, each journey as `### Journey TC-xx — <description>` followed by its
table.

### Phase 7 — Self-review (before showing the PM)

Run the quality gate below. Additionally re-read every journey as a tester who has never seen the feature: could you
prepare the data, find the screen, do the action and decide pass or fail without asking anyone? If not, fix that journey.

### Phase 8 — Review, then publish

1. Present in chat: behaviour model summary (if not already confirmed), register, scenario matrix, all journeys, and open items. Large plans can go section by section.
2. Publish only after explicit approval. Follow `references/confluence-publishing.md`: storage-format HTML generated from structured data (never Markdown converted to HTML for nested content), child pages created first and then linked from the master, re-read before every write, re-fetch after every write. On the **test-plan master** (and any long child with several h2s), include a Table of Contents per §3.1 (`maxLevel: 2`, after header / before Changes Log).
3. Then suggest running `user-story-journey-mapper` to fill the PRD's User Stories table and verify coverage.

---

## Mode notes

**Sanity plan.** Purpose line; logic under test (the 2–3 key rules); environment precondition (named test orders and baseline values captured before testing); 3–7 happy-path journeys in the same journey format; exit criteria. Explicitly list the edge cases deferred to the full plan. Align scope to what was actually confirmed in ticket comments or partial runs, and say what you aligned to.

**PAT plan.** Same master structure. Scope = PAT-group members only (name the group, e.g. `XXX_PAT_GROUP`, in the overview and the register); remove non-PAT contrast cases once the PM confirms. Cover Web, iOS and Android in one table per journey by adding `Web | iOS | Android` result columns (not three copies). Mark App-only surfaces as `—` on Web. Add a `Platform` column to the journey index. Use full-width tables.

**Execution-page fill.** If the target page already has its own schema (e.g. `Test Item | Case | Breakdown | Expected Result | Result | Screenshot iOS | Screenshot And` plus a PASS/FAIL/SKIP/CANCEL legend), match it. Put the three guarantees into its columns (preparation in Breakdown's first lines, the `System | Screen | Action` steps in Breakdown, pass criteria in Expected Result). Never fill tester-owned Result or Screenshot cells. Preserve every `<figure>` and media `data-id`, and count them before and after.

**Restructure.** Extract every existing case; preserve IDs, thresholds, fees, accounts, SKUs and pass criteria verbatim; keep sections the user did not ask to change; map the cases into rows a–g (add h–j only if the PM agrees); list anything that did not fit and any case that fails the three guarantees as findings (do not silently "fix" data).

---

## Quality gate

**Guarantee 1: Preparation**
- [ ] Every journey's d.) names the prior journey + the state consumed, or `—`.
- [ ] Every data reference is a register ID with a concrete identifier or `[TBC — assign]`; no anonymous "a product".
- [ ] Every setting is a CFG ID with a value; each CFG row has controlling system, path, verification, cache step and revert.
- [ ] Hard-to-reach states have a setup method and an owner.
- [ ] No credentials are written in the plan.

**Guarantee 2: Screen and action**
- [ ] Every step uses `System/API | Screen | Action`; every changed screen in the PRD's screen inventory appears in at least one journey, and every component landing, error state and notification is exercised.
- [ ] UI labels are exact (from Figma, the PRD or code) or flagged `[assumed — confirm in Figma]`.
- [ ] Backend steps name the system + table/API + field; async steps name the trigger and wait limit.
- [ ] Checkpoints exist where a later step depends on an earlier outcome.

**Guarantee 3: Pass conditions**
- [ ] Every criterion is binary, has an exact value, names its surface and the step where it is observed.
- [ ] Persisted state and downstream sync are asserted where the feature writes data.
- [ ] Exclusion rules have negative assertions; widened conditions have a negative journey.
- [ ] Falsifiability: no journey would pass on a build without the change.
- [ ] Derived values show arithmetic and are labelled `[derived]`.

**Coverage and structure**
- [ ] Every AC, RULE row and branch, worked example, V rule, Kafka event, ticket test-case bullet, Features at Risk row and known bug maps to at least one journey (coverage matrix has no unexplained "uncovered").
- [ ] Dependency map is consistent with rows c/g; no cycles; chains are executable in order.
- [ ] Master page has all sections 0–11; child pages split by section; journey IDs are stable.
- [ ] All `[TBC]` / `[assumed]` items appear in Open Items with an owner.
- [ ] Drafted in chat and approved before publishing; re-read before writing; re-fetched after writing.

## Pitfalls

- **Vague steps:** "Add item to cart" is not acceptable. Write `Screen: PDP of SSI SKU A | Action: Set quantity stepper to 6, tap "加入購物車"`.
- **Pass criteria only on the happy surface:** a fee rule that is only checked on checkout misses the order record, OIX sync, the receipt and order history.
- **Placeholders that never become real data:** "SSI SKU A" with no SKU code blocks execution. Keep the alias, but resolve the code in the register or flag it.
- **"Expected = actual" from a different code path:** the stored order value proves nothing about another service's own calculation. Read that service's surface.
- **Cache:** a setting changed without a cache or propagation step makes FAILs ambiguous.
- **Date-bearing data expires:** re-base dates on the execution day and use one date format everywhere.
- **Dropping a case** is a coverage decision. Record it as NOT TESTED with the residual risk and who accepted it; never SKIP or PASS it.
- **Markdown→Confluence loses nested tables;** `<table>` inside `<p>` is rejected. Generate storage HTML directly.
- **Stale-read overwrite:** a full-body write from an old read destroys the PM's edits. Re-read right before writing; if the version moved, stop and reconcile.
- **Silent truncation:** long bodies get cut. Split into child pages and re-fetch after writing.

## References

- `references/journey-template.md`: journey table, master-page skeleton, Markdown and Confluence storage-HTML templates.
- `references/coverage-dimensions.md`: pre-condition categories, edge-case dimensions and the falsifiability rules in full.
- `references/reference-plan-ambient-plastic-bag.md`: the minimum-bar reference plan (page IDs, structure, gaps to exceed) and TC-01 rewritten to this standard.
- `references/confluence-publishing.md`: draft-first workflow, targeted edits, HTML rules, images, page splitting, media preservation and post-write verification (shared with standardized-technical-prd).
- `references/runtime-tools.md`: tool names for Claude (Atlassian connector), Codex and Hermes.
