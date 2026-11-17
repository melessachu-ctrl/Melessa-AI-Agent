---
name: standardized-technical-prd
description: "Write a development-ready and test-ready PRD (HKTV feature spec on Confluence SPECDOCS) for any HKTV system (MMA, MMS, CSIS, Hybris, VSS, OIX, App, Web, other portals) from requirements that may be incomplete: a draft, brief, deck, Slack thread, meeting notes, Figma file, prototype or the current system. Fills gaps with an ID-tagged clarification list, triages impact on existing code (directly when the agent can read the repos, and/or via prd-backend-impact-consult), builds a screen inventory from the design source, writes per-screen requirements, worked examples, error states, notifications, copytable and Kafka when they apply, and a Test-Readiness Inventory for test-case-preparation. Manages document status (DRAFT → FINAL → LAUNCHED). Creates Jira tickets only when the published spec passes the completeness gate and the user asks."
version: 3.0.0
category: productivity
metadata:
  hermes:
    tags: [prd, spec, requirements, product-management, gap-filling, impact-analysis, test-readiness, jira, confluence, hktvmall]
    related_skills: [pr-requirement-prep, prd-backend-impact-consult, prd-intake, spec-gap-review, prd-flow-diagram, prd-sequence-diagram, test-case-preparation, user-story-journey-mapper]
  supersedes: [hktvmall-pm]
---

# Standardized Technical PRD

## Position in the pipeline

```
Business requirements (incomplete) + design source (Figma / prototype / none)
   │
   ▼
[1] standardized-technical-prd   ← THIS SKILL
      gap-fill → impact triage → screen inventory → PRD (DRAFT) → PM review → publish
      → [completeness gate + user asks] Jira tickets → status FINAL → (release) status LAUNCHED
   ▼
[2] test-case-preparation        ← master test plan + journey child pages
   ▼
[3] user-story-journey-mapper    ← journeys ↔ user stories, coverage gaps, fills the User Stories table
```

This skill owns everything the two downstream skills need: **stable IDs**, **concrete rules with values and worked
examples**, **screens with exact labels, components and landings**, **configuration and data archetypes**, and
**where each outcome can be observed**.

## Runtime

Written for Claude with the Atlassian connector turned on; it also runs in Codex and Hermes. Tool names per runtime,
and how to load another skill: `references/runtime-tools.md`.

## ⚠️ Shared Rules — MUST Follow

Load **`pr-requirement-prep`** first:
1. Conflicting requirements → the **newer document wins**, but **flag** the requirement it made obsolete.
2. Documents marked DRAFT are not assumed to be agreed requirements; ask whether to continue modifying or to ignore them. (This skill's own status lifecycle is below.)
3. **Draft in-chat for PM review** before writing to any page; re-read before writing; re-fetch after.
4. PM corrections with an unresolved dependency → post as a comment that separates decided changes from blocked ones.

## House rules

- **Roles.** Confirm the **Document owner** (header, default Jira assignee) and **Requester** (header) before writing; ask once for any missing name.
- **Language.** Chat in the user's language (often Cantonese). Write the spec in English; quote ZH UI copy in 「」.
- **IT must read it comfortably.** Short bullets and tables, organised by screen and by system. No marketing prose.
- **Quote real system facts.** Variable names, job names, run times, table and field names, and config keys come from the current spec, runbook, ImpEx, config or code. Never invent them; unknown → `[TBC]` + owner.
- **Use the system's own terms and statuses.** For MMS / MMA these are Scheduled / On-going / Completed / On hold. Do not invent Draft / Ended.
- **No Delete on business records in admin systems.** Use On hold and keep the record for audit.
- **Time rules follow the job that applies them,** not the wall clock. Name the job and its run time, or raise an Open Question.
- **Never guess copy for existing UI.** Mark existing strings `Existing`, and copy EN / zh_CN from the app or leave them out.
- **Never put a redeemable value** (voucher code, token) in Kafka or in URLs that are logged.
- **A prototype is not a complete product.** Missing empty, error, loading and old-app states are `[TBC]`, not signed-off behaviour.
- **Figma vs prototype conflicts** go to Open Questions; ask which wins before finalising.
- **Every unknown is `[TBC]` + owner** (IT / designer / MKT / PM / named team) and appears in Open Questions.

## IDs (stable; independent of section numbers)

| Item | Format | Example |
|---|---|---|
| User story | `US-nn` | US-03 |
| Acceptance criterion | `AC-nn.m` (under its story) | AC-03.2 |
| Functional requirement | `FR-nn` | FR-04 |
| Rule within an FR | `RULE-nn.m` | RULE-04.2 |
| Admin validation | `V-nn.m` | V-04.1 |
| Clarification / open question | `A1…` (blocking), `B1…` (decision needed), `C1…` (hygiene) | A2 |

IDs never change once the PM has seen them: new items take the next free number, and removed IDs are retired (never
reused). Sections may be omitted or renumbered freely, because nothing downstream refers to section numbers. Downstream
skills refer to sections **by name**.

---

## Procedure

### Step 1 — Gather sources (read live, read everything)

1. Read everything the request links to: deck (Google Slides; a PDF export works when Slides cannot be read), Slack threads, emails, screenshots, the Jira epic and stories.
2. Fetch each Confluence source live (html, full): main page, child pages, linked sub-specs, inline and footer comments, linked sheets. Record each version. Unresolved comments often hold decisions the body never absorbed.
3. Search Confluence for the current logic: the original spec, NOC / IT runbooks, ImpEx, system variables, cronjobs. Read the team's previous specs of the same kind and follow their table style (customer App / Web examples: Display Preference, Variant Pop Up, PDP Revamp, Search Result Revamp, Wet Market, KWS CMS QC Revamp).
4. Check the existing copytable sheet for wording already in the product, and the Prod Kafka Specification when there is App / Web tracking.
5. Write down the **current flow**: who asks whom, what is run, and when. The spec must say what the new flow replaces.
6. Apply shared rules 1–2. Never rebuild from a session cache or an earlier draft.

### Step 2 — Declare the design source and build the screen inventory

Declare `Figma` | `Prototype` | `Figma + Prototype` | `None` (do not assume Figma), then build the screen inventory
(`# | System / Channel | Screen / pop-up | States seen | Source ref | Screenshot path | Notes`). Paths for Figma and for
prototypes, diffing new versions, and image rules: `references/design-source-and-screen-inventory.md`.

### Step 3 — Classify the input and sweep for gaps

| Input type | Handling |
|---|---|
| Full draft PRD | Restructure into the document structure, preserving every fact; gaps → `[TBC]`. |
| Short brief / deck | Expand each point into the relevant sections; ask only for facts that block a section. |
| Meeting notes / Slack | Group decisions into Scope, Technical Considerations, Systems to Enhance; unresolved → `[TBC]`. |
| Raw idea | Draft with reasonable assumptions marked `[ASSUMED]` and open points marked `[TBC]`. |
| Figma / prototype only | Step 2 inventory first; every screen becomes a screen subsection; missing states → `[TBC]`. |

Sweep every dimension and record each gap:

| Dimension | Questions that expose gaps |
|---|---|
| **Business / data** | Why now, which KPI moves, values (fees, thresholds), where data comes from, what the old flow is. |
| **Ownership and state** | Who owns the record, how status changes, expiry, refund, revoke; which statuses can still be edited. |
| **Per screen** | Grouping, sort, empty / expired / sold-out states, what each button does and where it lands. Admin: list filters, create / edit, validation. |
| **Prototype coverage** | Which states are built (empty, error, loading, logged out, old app); any signed Requirement AC. |
| **Sharing / links** | Payload per channel, deep link, app not installed, not logged in, old app version. |
| **Errors** | Each error state, priority, copy and buttons; timeout and no network. |
| **Notifications** | Push / in-app / email / SMS trigger and copy. |
| **Jobs and time rules** | Which job applies the rule, when it runs, cut-offs. |
| **Operations** | Internal users (CS, finance, ops, couriers, merchants), their tools (CSIS, back office, courier app), manual fallbacks, reports. |
| **Conflicts** | Existing rules this changes (old → new); interaction with promotions, vouchers, caps, add-ons, refunds, other fees. |
| **User types** | Member tiers, guest vs logged in, merchant types, geography, PAT / feature groups. |
| **Pre-conditions** | Feature flags, config keys and owners, data that must exist, behaviour when a pre-condition is not met. |
| **Every branch** | Every branch of each routing condition is specified, not only the one the requester cares about. |
| **Failure and kill-switch** | Retries, idempotency, duplicates, who flips the flag, what happens to in-flight records. |
| **Observability** | Where a tester can see each outcome: UI label, API field, DB column, log line, report. |
| **Delivery** | Platforms, app minimum version, target launch, owners. |

Ask the user the gap questions **in one batch**, numbered and grouped (skip groups that do not apply), as an **ID-tagged
clarification list**, blocking-first:

```
A1 [Blocking — implementation] FR-02 Cap priority when only frozen + ambient → proposed: ambient + frozen = $2 → owner: Product (proposal)
B1 [Decision needed] Scope: is Macau excluded, or only overseas? → proposed: both → owner: Product (proposal)
```

Owners are **proposals**. Keep IDs stable across rounds. After the answers, list assumptions and ask the user to confirm
them. Start writing once each question is answered or explicitly `[TBC]` with an owner.

### Step 4 — Triage the impact on existing code

Run this for every new feature or behaviour change. Choose the path or paths available:

**Path A — the agent can read the repositories** (cloned locally, a code-search tool, or similar):
1. Answer the three impact questions yourself, verbatim:
   1. Which back-end systems do I need to enhance?
   2. A summary of what I need to change in the related systems in terms of logics and data.
   3. What other features will be impacted for this change in terms of logics and data, so enhancement should be considered to avoid making those features broken?
2. Also answer the app-side version: which screens, components, view models and API calls change, and which app features share them.
3. Every claim carries `repo — path:line` and **PROVEN** (code path read end to end) or **UNPROVEN** (inferred). Record the commit or branch read.
4. Trace both layers. A backend getter that ignores a field does not prove the UI ignores it; the render gate may be in client JS, a microservice or a native app. If code contradicts what the PM saw in production, the reading is incomplete.
5. Harvest for the Test-Readiness Inventory: real UI strings / i18n keys, config keys and defaults, persisted field names, API / event names, job names and schedules, log lines.

**Path B — code-owner bots:** load **`prd-backend-impact-consult`** (two Slack threads: TeamEcom for the backend without OIX, App
Team Agent for the app side; the same three questions verbatim; one shared polling window; reconcile both legs). From Claude
or Codex, see the bot-consult note in `references/runtime-tools.md`. Posting to Slack needs the user's yes.

**Both:** Path A first; then ask the bots targeted PROVEN / UNKNOWN questions only where Path A was UNPROVEN or out of reach.
A contradiction between legs is a finding: record both with `file:line` and raise it as a clarification item.

Fold the results into the clarification list, Technical Considerations, Systems to Enhance (Backend / App impact, features
at risk), Open Questions and the Test-Readiness Inventory. Repeat Steps 3–4 for each clarification round.

### Step 5 — Write the PRD (Markdown first)

Use the document structure below. Keep the `.md` (and screenshots and mockups) in the working directory under `<feature>/`;
ask once where, if the user has not said. Header status = `DRAFT`. Optional deliverables (copytable, Kafka, mockups) per
`references/copytable-kafka-mockups.md`.

### Step 6 — Quality gate, then PM review

Run the quality gate below. Hand the PM: the draft, the clarification list (blocking first), the decisions needed, and
what you could not do and why. Do not publish until the PM explicitly approves.

### Step 7 — Publish and keep in sync

Publish per `references/confluence-publishing.md` (SPECDOCS, title convention, targeted edits, images embedded next to
their rules, re-fetch after writing). **Every time the spec changes, update the `.md`, the mockup, the copytable workbook
and Confluence together**, and add a Changes Log line and a version message.

### Step 8 — Jira tickets and status (only on request)

Follow `references/jira-tickets-and-status.md`:
- **Completeness gate** first. If it fails, list what is missing and stop: no question, no tickets.
- If this run published a complete spec and the user has not asked, ask once: "Spec is on Confluence. Create the Jira tickets?"
- One epic (TEAMECOM) + one child ticket per Systems to Enhance row, each citing its FR / RULE / AC IDs.
- After tickets exist: epic key → header Ticket row, status `DRAFT` → `FINAL`.
- When the release version is released: status → `LAUNCHED` with launch date and release version(s).
- Slack follow-up only when the user asks.

After publishing (or reaching FINAL), suggest running `test-case-preparation` on the page.

### Step 9 — Remember

If the user names a notes file or project memory, save the feature's sources, decisions, design-source choice,
Confluence page ID and open questions there as they happen; add ticket keys only after tickets exist.

---

## Document structure

### Header table (always, at the top)

| Field | Value |
|---|---|
| Document status | `DRAFT` / `FINAL` / `LAUNCHED` |
| Launch date | `YYYY-MM-DD` (from the released Jira version; TBC until LAUNCHED) |
| Release version(s) | e.g. `HYBRIS@2026-10-05` (TBC until tickets exist) |
| Document owner | name |
| Requester | name |
| Systems | every system touched |
| Designer | name / TBC |
| Tech lead · QA | when known |
| Ticket | epic key / TBC |
| Target launch | date / TBC |
| Design source | Figma / Prototype / Figma + Prototype / None, plus links |
| Copytable · Kafka | links, when those deliverables exist |

### Changes Log (always, right after the header)
`Version | Date | Author | Change` (including status changes).

### Numbered sections

Sections marked *(optional)* are **left out entirely** (no heading, no "N/A") when they do not apply, and the rest are
renumbered. The PM may also drop or override sections (see Input handling). Related Documents is always last.

**1. Summary.** What, why, for whom (2–4 paragraphs).
- **1.1 Development Objectives:** `Goal | Don'ts / Non-goals`.
- **1.2 User Journey — Old vs New** *(optional: when a person-facing flow changes)*: numbered steps per actor, old and new, plus `Area | Old | New`. Say what the new flow replaces.
- **1.3 Users and Permissions** *(optional)*: `Role | System | Can view | Can create / edit | Can approve`.
- **1.4 Glossary** *(optional)*.

**2. User Stories.**
> `US-01` — As a `[actor]`, I want `[goal]`, so that `[benefit]`.
> `AC-01.1` Given … When … Then … (concrete values, statuses, labels; binary; names where it is observed)

Every story has at least one AC. Reuse signed Requirement AC from a vibe prototype when it exists, and expand it for IT
and QA. Consolidated table; the last two columns are filled by `user-story-journey-mapper` (until then `[pending test plan]`):

| User Story ID | User Story Description | Related Test Journeys | Screen Sequence |
|---|---|---|---|

Screen Sequence format: `[System A — Screen 1] → [System A — Screen 2] → [System B — Screen 1]`.

**3. Goals & Success Metrics.** `Goal | Metric | Target | Measurement Method`; inferred values marked `[TBC]`.

**4. Scope.** In Scope (bullets); Out of Scope (bullets, each with a one-sentence reason).

**5. Technical Considerations.** One subsection per functional requirement, headed `FR-nn — <name>`:
- **Requirement:** `RULE-nn.m` rules in IF / THEN or table form with concrete values; pseudo-code when status or result logic branches. Enumerated scenarios (thresholds, caps, priorities, eligibility, state transitions) go in a table with an introductory sentence.
- **Worked examples** *(required for calculation, priority between rules, time windows, cut-offs, rounding, proration or combined conditions)*: `Example # | Input / situation | Expected result | Why`, with real-looking dates, times, SKUs, amounts and statuses. Cover the normal case, the boundaries (exactly at the cut-off, one minute after, zero, maximum) and at least one case where the rule does not apply. For time rules, show the timeline against the job ("Merchant edits at 23:58 → job runs 00:05 → status On-going → edit locked"). Unconfirmed outcomes are still written and added to Open Questions.
- **Screens** *(for FRs with UI: one block per screen-inventory row)*: a lead sentence on what the screen does; the screenshot (states composited left to right, labelled `Figma` or `Prototype`); a component table `# | Component | Display / hide condition | Tap action / landing`; a state × component matrix (`Y/N` + remark) when the screen has several states.
- **Admin screens** *(for admin portals / back office)*: navigation; list page (columns, filters, sort, default); create / edit page (fields, defaults); validation table `V-nn.m | Field | Rule | Error copy`; which fields can be edited in each status.
- **Simulation Steps:** (1) preconditions and data setup naming the system that controls each; (2) exact inputs; (3) expected output or state change with values; (4) where to observe it (system, screen + label, API field, DB column, log).
- **Covers:** US / AC IDs.
- **Edge cases:** boundaries, empty / maximum, ineligible, cancel / amend, retries / duplicates, concurrency.

**6. Systems to Enhance.** Table with these columns **exactly**:

| System | Type | Enhancement Breakdown | Related Development | Impacted Journeys |
|---|---|---|---|---|
| … | `Back-end` or `Front-end` | Back-end: `a.) Functions within the system` `b.) Interfacing required (API / Queue / Event)` · Front-end: `a.) Changes required on front-end` `b.) Information exchange logic` | FR IDs | US IDs |

Bullet lists inside cells. Each row becomes one Jira child ticket. Then:
- **6.1 Backend Impact:** Path A / TeamEcom findings with `file:line` and PROVEN / UNPROVEN, attributed to their source.
- **6.2 App Impact:** the same for app screens, flows and app-side logic.
- **6.3 Features at Risk:** existing features sharing the changed logic or data, and why (each becomes a regression journey).
- **6.4 Backend / Jobs / API** *(optional: when there is server behaviour)*: endpoints, events, queues, jobs (name, schedule, what they change), data model changes.
Name any consult leg that never answered.

**7. Feature Flow Diagrams** *(optional: include when there are several decision points, branching by status or user type, jobs or systems handing off, retries, or a customer journey with entry checks, login, cancel or failure)*. One Mermaid `flowchart TD` per **non-sequential** workflow (`7.1`, `7.2`…). Show every known state and landing including cancel, failure and retry; states missing from the source stay on the diagram as `TBC` nodes; label decisions with the real condition (`status == On-going?`, `stock > 0?`) and jobs with name + run time. Inline for simple features; delegate to `prd-flow-diagram` for 3+ systems or iteration.

**8. Primary Journey Sequence Diagram** *(optional: include when the flow is mainly calls between systems)*. Mermaid `sequenceDiagram` with `autonumber`, `actor` for humans, `participant` for systems, a payload on every arrow, `alt / else` for edge cases. Inline or delegate to `prd-sequence-diagram`.

**9. Error States** *(optional: when the UI has errors)*. `Error | Trigger | Priority (when several apply) | Copy (ZH / EN) | Buttons → landing`. Include timeout and no network.

**10. Notifications** *(optional)*. `Notification | Channel (push / in-app / email / SMS) | Trigger | Recipient | Copy (ZH / EN) | Landing`.

**11. Copytable and Tracking** *(optional: when there is UI copy or App / Web tracking)*. Links to the copytable sheet and its `kafka ping` tab, with a summary of new keys and events.

**12. Acceptance Criteria Summary.** Generated from the user-story ACs, grouped by actor: `AC ID | Actor | Scenario | Expected | Rule ref (RULE / V IDs)`. If the PM dropped user stories, this table is the AC source and uses `AC-FRnn.m` IDs.

**13. Timeline, Effort & Rollout.**
- **13.1 Engineering & Cross-Functional Effort:** working days per system, QA, PM, Design.
- **13.2 Business Action Items:** checklist, each item one sentence starting with a verb.
- **13.3 Rollout** *(optional)*: phasing, PAT group, feature flag plan, app minimum version, rollback / kill-switch.

**14. Open Questions.** `# | ID | Item | Check with | Answer | Blocking?`. Every `[TBC]`, every unresolved clarification item, and every Figma vs prototype conflict. Mark `[TBC]` if it blocks implementation, `[STATUS: PENDING]` if waiting on a bot, PM or management.

**15. User Story ↔ Functional Requirement ↔ System Change Mapping.** `User Story ID | Functional Requirement ID(s) | Systems to Enhance | Screen / API / Flow affected`.

**16. Test-Readiness Inventory.** What lets `test-case-preparation` write exact preconditions, actions and pass criteria. Unknown → `[TBC]` + owner.
- **16.1 Screen & UI Elements:** `System / Channel | Screen | Entry path (how a tester reaches it) | UI element (exact label ZH + EN / i18n key) | Change type (new / modified / unchanged but affected) | States`.
- **16.2 Configuration & Settings:** `Config / flag | Meaning | Default / test value | Controlling system → navigation path | Who can change it | How to verify the active value | Cache / propagation delay`.
- **16.3 Test Data Archetypes:** `Archetype | Required attributes (exact values) | Owning system | Why needed (FR / RULE / AC)`.
- **16.4 Observable Outputs:** `Outcome | Surface | Exact location (label / API field / table.column / log / Kafka event) | Value format`.
- **16.5 Jobs & Timing:** `Job | Schedule | What it changes | How to trigger or wait for it in UAT`.

**17. Related Documents** (always last). Specs, runbooks, Figma, prototype, copytable, Kafka spec, Jira epic, test plan.

---

## Core formatting rules

1. Section names as above; IDs as in the ID table; hierarchical numbering for subsections.
2. Formal, technical, data-driven. Every table has an introductory sentence.
3. Mermaid in fenced `mermaid` blocks; check renders for overlaps.
4. **No ambiguity:** replace "appropriate", "relevant" or "as needed" with concrete conditions, statuses, field names and values; otherwise `[TBC]` plus what must be confirmed.
5. Every button has a landing. Every error has copy and buttons.

## Input handling — the PM can override the framework

The PM's explicit structure wins. Some PMs drop User Stories, Goals & Success Metrics or Out of Scope, or add a UI
Developments section (screen → change → mirror existing vs net-new). Do not force dropped sections back. Keep the
technical substance (FRs with rules, worked examples and simulation steps; Systems to Enhance; Open Questions; mapping;
Test-Readiness Inventory). If User Stories are dropped, the Acceptance Criteria Summary becomes the AC source and
`user-story-journey-mapper` maps journeys to FR IDs. Confirm section cuts before publishing.

## Pitfalls

- **Restructuring an already-updated source:** fetch the live page and check its version. FR IDs referenced but never defined → `[TBC]` in Open Questions.
- **"Do not edit the existing document":** render in chat, list gaps, wait. Create a page only when told to.
- **Never create a page the PM did not ask for.** "Revise based on my request" means edit in place, keeping the structure. If a pipeline keeps reverting your writes, report it and ask.
- **Edit requests may cite an older draft's section numbers.** Map each request to the current page and report which are already done, with evidence.
- **A "timed out" write may have landed.** Re-fetch before reporting failure.
- **Business wording is not a system list.** "Show the fee at checkout" touches the cart calculation, checkout UI on each channel, the order record, downstream sync and the receipt. Step 4 exists to find these.
- **Prose and tables drift.** Put every number in a table or worked example; the table wins.
- **"Existing report already covers it"** is not a deletion. Write "no change required, confirmed by <owner>" and fix every dependent metric, system row and action item.
- **Status is not decoration.** Downstream skills read it. Do not mark FINAL before tickets exist (or the user confirms development started), or LAUNCHED before the release version is released.

## Quality gate — before handing over the draft

**Sources and gaps**
- [ ] Shared rules applied (recency conflicts flagged, DRAFT sources clarified).
- [ ] Current flow recorded; the spec says what the new flow replaces.
- [ ] Gap sweep ran across every dimension; clarification list is ID-tagged, banded, blocking-first, with proposed owners; assumptions confirmed.
- [ ] Impact triage ran (Path A and/or B); every claim has `file:line` + PROVEN / UNPROVEN or a bot attribution; silent legs named.

**Design and screens**
- [ ] Design source declared; every screen-inventory row and known state appears in a screen block, the state matrix, the flow diagram (when present) and the copytable (when copy changes).
- [ ] Screenshots labelled `Figma` or `Prototype`; source conflicts are in Open Questions or resolved.
- [ ] Prototype gaps (empty, error, loading, old app) are specified or `[TBC]`.
- [ ] Every button has a landing; every error has copy and buttons; admin statuses and the no-Delete rule are respected.

**Requirements**
- [ ] Every user story has an ID and at least one binary AC with a place to observe it.
- [ ] Every FR has RULE IDs with concrete values, simulation steps, Covers and edge cases; worked examples under every calculation or time rule, naming the job.
- [ ] Systems to Enhance has the five exact columns; every row maps to at least one FR and US; 6.1–6.3 present.
- [ ] Acceptance Criteria Summary, Open Questions and the mapping table are complete.
- [ ] Test-Readiness Inventory lists every screen with exact labels, every config with its controlling system and verification, data archetypes for every rule branch, an observable output for every AC, and every job with its schedule.

**Publishing**
- [ ] Header complete (status, owner, requester, systems, design source); Changes Log updated.
- [ ] ZH copy re-scanned for confused characters; diagrams checked for overlaps.
- [ ] Nothing published without explicit approval; `.md`, mockup, copytable and Confluence in sync; page re-fetched after writing; every image renders.
- [ ] Hand-over message: design source used, what changed, what could not be done and why, remaining questions.
