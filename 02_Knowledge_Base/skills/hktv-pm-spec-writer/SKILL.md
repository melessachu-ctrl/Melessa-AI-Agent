---
name: hktv-pm-spec-writer
description: Write an HKTVmall PM / IT-ready Confluence spec from a Figma file and/or a clickable prototype (in-repo spike, testing app, preview URL, uploaded screenshots/recording), page by page and component by component, plus a ZH/EN/zh_CN copytable and Kafka ping list, from the Hybris/VSS + App/Web team's view. Use when the PM asks to write a PM spec, SPECDOC, SEWO spec, Confluence spec, copytable, Kafka ping list, or to turn a Figma design or prototype into an IT-ready spec for HKTVmall.
---

# HKTVmall PM Spec Writer

Turns a **Figma design** and/or a **prototype** into an IT-ready spec (Hybris / VSS / App / Web), a copytable and a Kafka ping list. Written for HKTVmall PMs; output style follows the team's existing SPECDOCS / SEWO specs.

## 0. Golden rules

- **Ask before writing.** Never start the spec until the open questions below are answered or explicitly marked TBC.
- **Declare the design source first.** `Figma` | `Prototype` | `Figma + Prototype`. Do not assume Figma.
- **IT must read it comfortably.** Short bullet points and tables, by page and by system. No marketing prose, no padding.
- **Never guess copy for existing UI.** Mark existing strings as `Existing` and leave EN / zh_CN to be copied from the app, or drop the row.
- **Never put a redeemable value (voucher code, token) in Kafka or URLs you log.**
- **Chat with the PM in the language they use** (often Cantonese). The spec itself is in English with ZH UI copy quoted in 「」.
- **Mark every unknown as TBC + owner** (TBC with IT / designer / MKT / PM). Collect them in an Open Items table.
- **Prototype ≠ complete product.** Happy-flow spikes often omit empty / error / edge states — list gaps as TBC; do not invent missing states as signed-off behaviour.

## 1. Gather context (do this first, quietly)

1. **Reference specs**: read the PM's previous specs in the project (e.g. Display Preference, Variant Pop Up, PDP Revamp, Search Result Revamp, Wet Market, KWS CMS QC Revamp). Copy their structure, wording and table style.
2. **Kafka reference**: read the Prod Kafka Specification (tabs `application_form`, `page_screen`, `ecommerce`, `generic_event`). Reuse existing screen names and patterns (e.g. `share_to` + `{share_method}`, `my_page_gift_voucher`).
3. **Design source** — pick path A and/or B below. Build one **Screen inventory** first (`# | Screen / pop up | States seen | Source ref | Screenshot path | Notes`). Every later section must map to this inventory.

### Path A — Figma (Figma connector)

- `get_metadata` on the page (no nodeId first to list pages) to get frames, sections, flow arrows and layer names.
- `get_screenshot` per section with `enableBase64Response: true` (the sandbox usually cannot download figma.com asset URLs). Crop frames locally with PIL using the frame x/y/w/h from metadata.
- If you get "no edit access", ask the PM to duplicate the file into their own drafts and share the copy link.
- Starter plan has a low MCP call limit: fetch whole sections, not single frames, and cache screenshots locally.
- Diff a new Figma version against the old metadata (frames + text layer names) and report: new frames, removed frames, new states.
- Screen inventory rows come from frames / sections / named states.

### Path B — Prototype

Accept any of: preview / testing-app URL, in-repo spike branch or local path, exported build, PM-uploaded screenshots / screen recording, or a written walkthrough.

1. Ask for: URL or repo path, how to open the flow (entry, login, feature flag, deep link), platforms covered, and which states exist beyond happy flow.
2. Walk the flow end-to-end. Capture **every reachable screen, pop up, bottom sheet, toast** as a screenshot (browser / computer-use / recording stills). Name files `NN-<screen>-<state>.png`.
3. If source is code (in-repo spike): skim routes / screen names / copy keys / mock fixtures to enrich the inventory; do not treat unfinished code as signed-off product behaviour.
4. If only a recording or partial screenshots: inventory what is visible; mark unseen states `TBC with PM / designer`.
5. Prefer linking `hktvmall-vibe-prototype` Requirement AC / Testing App Pack when the prototype came from that workflow.
6. Diff a new prototype drop vs the previous inventory (added / removed screens, new states) and report it.

### Both sources

- Prefer Figma for layout / component naming when both exist; use the prototype to confirm tap landings, real copy, and runtime states.
- If they conflict, record both in Open Items and ask the PM which wins before finalising.

## 2. Clarifying questions (ask in one batch, numbered, grouped)

- **Design source**: Figma link? Prototype URL / repo / screenshots? Both? Which is source of truth if they differ?
- **Background / data**: where does the data come from (SKU, VSS, Hybris, Recomm, ecom engine)? What exists today (old flow)?
- **Ownership & state**: who owns the record, how does status change, expiry rules, refunds, revoke?
- **Per page**: grouping, sort order, empty / expired / sold-out states, >N items behaviour, what each button does and where it lands.
- **Prototype coverage** (if Path B): which states are built vs not (empty, error, loading, logout, old app)? Any Requirement AC already signed?
- **Sharing / links** (if any): payload per channel, deep link / deferred deep link, app not installed, not logged in, old app version.
- **Errors**: every error state, priority, copy, buttons; timeout / no network.
- **Notifications**: push / app notification trigger and copy.
- **Delivery**: platforms (iOS / Android / Web / mobile web), app min version, timeline, PAT, owners table, output formats.

After answers, list your own assumptions explicitly and ask the PM to confirm them before finalising.

## 3. Spec structure (living doc / Confluence)

1. **Overview** – doc info table (Owner, Designer, Tech lead App, Tech lead Hybris/VSS, QA, Epic/tickets, **Design source** = Figma and/or Prototype links, Copytable + Kafka, Target release), Objective (3 bullets), Scope (platforms, in/out), Terms. If prototype-only, note coverage (e.g. happy flow only).
2. **User Journey – Old vs New** – numbered steps for each actor (old flow, new flow), plus a "What changes per system" table (Area | Old | New).
3. **Flow diagram** – must show **every** state: entry checks first (e.g. App installed? → store), login (incl. ✕), pre-check results, cancel paths, failure + retry, every success button and its landing. States not present in the source stay on the diagram as TBC nodes.
4. **One section per page / pop up** (one inventory row), each with:
   - Lead sentence (what the page does) + **source screenshot** (composite of all known states, captioned left to right; label caption `Figma` / `Prototype`).
   - Component table: `# | Component | Display / hide condition | Tap action / landing`.
   - **State × component matrix** (Y/N + remark) when the page has several states (e.g. Valid / Sold out / Expired none claimed / Expired partly claimed; 1 / 2–10 / >10 items).
   - Rules bullets (sort, grouping, limits, snapshot rules, TBCs).
5. **Error states** – table `Priority | Pop up | Condition (BE) | Desc + buttons / action`, plus the toast spec (fade in/out, 3s, unclickable unless stated).
6. **Notifications** – trigger, who gets it, copy (fixed text + {variables}), tap landing.
7. **By system** – VSS / Hybris / App / Web FE / CDN responsibilities; proposed APIs (marked as proposals for IT); **New data fields table** (`Field | Type | Owner | Description`).
8. **Business rules** – numbered `RULE-n` in a code block; add **pseudo code** for status / result logic.
9. **Copytable & Kafka** – link to the sheet + screenName summary table.
10. **Open items (TBC)** – `# | Item | Check with`.
11. **Acceptance criteria** – table `ID | Scenario | Expected | Rule ref`, split by actor. Reuse signed Requirement AC from a vibe prototype when available; expand to Engineering-level cases the IT spec needs.

## 4. Copytable (Google Sheet tab `copytable`)

Columns: `Page | Screenshot | Key | Description | New / Existing | ZH | EN | zh_CN | Remark | Update time`

- One group per **screen inventory** row (Figma frame **or** prototype screen), screenshot merged across the group's rows.
- Key = `<feature>_<page>_<module>_<element>` (lower_snake_case) so IT can use it as the i18n key.
- Pull ZH from Figma text layers when available; otherwise from prototype UI / i18n keys / PM-provided copy. Still mark app-existing strings `Existing` — do not invent EN / zh_CN for them.
- EN: short (buttons often have little room). Keep one term per concept (e.g. 領取 = Claim, 換領 = Redeem).
- zh_CN: convert Cantonese colloquial to written Mandarin (e.g. 寫低你想同收禮人講嘅說話 → 写下你想对收礼人说的话).
- Grey rows = Existing; do not invent their EN / zh_CN.
- Add extra tabs when needed (e.g. `csv template` with headers in ZH / EN / zh_CN + sample rows).

## 5. Kafka (Google Sheet tab `kafka ping`)

Columns: `Action / trigger point | event | event_category | event_action | event_label | event_value | screenName | Remark`

- `screen_view` for every page / pop up / bottom sheet in the screen inventory.
- `generic_event` for every CTA; category = the screen, action = the button, label = useful id (`{sku_code}`, `{share_method}`, result enum).
- One result event after each API call that matters (e.g. `redeem_result` = success / not_found / redeemed_by_me / redeemed_by_other / expired / timeout / error).
- Reuse existing screen names from the Prod Kafka Specification; never log redeemable codes.

## 6. Delivery

- **Spec**: Claude living doc (Docs). Create the outline first, fill one section per call, add the flow diagram and page screenshots (upload as artifact assets → blobs).
- **Sheet**: build an .xlsx with openpyxl (images anchored per group), upload via Google Drive `create_file` (converts to Google Sheet). Editing an existing sheet needs the **Google Sheets** connector; Drive alone can only create new files – ask, don't silently create a second file.
- **Confluence** (Atlassian connector): read the page first (`draft: true`, `detail: full`, HTML). If the PM already pasted / edited the spec, keep their edits and apply only deltas with `edits` (`replaceNode` / `insertNodeAfter` by `data-local-id`), dry-run first, save as draft. Attachment upload may be blocked by the sandbox proxy – then hand the PM the PNGs and leave a placeholder where each goes.
- Save key links + decisions (including design-source choice) to the project notes doc.

## 7. Quality checks before handing over

- Every screen-inventory row and known state appears in a page section, the matrix, the flow diagram and the copytable.
- Source labelled correctly on screenshots (`Figma` / `Prototype`); conflicts between sources are in Open Items or resolved.
- Prototype-only gaps (empty / error / loading / old app) are either specified or listed as TBC — never silently treated as out of scope.
- Every button has a landing; every error has copy + buttons.
- Re-scan the spec for wrong Chinese characters (escape typos like 撐/撳, 喘/喺, 嘢/嘅) by listing all Han characters used.
- Look at the rendered diagram (screenshot) and fix overlaps.
- Reply to the PM briefly: design source used, what changed, what you could not do and why, and the remaining questions.
