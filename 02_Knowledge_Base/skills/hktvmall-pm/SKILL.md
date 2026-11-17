---
name: hktvmall-pm
description: "Write an HKTV feature spec on Confluence SPECDOCS for MMA, MMS, CSIS, Hybris, VSS, App, Web, or another portal, from a Figma file, prototype, deck, or the current system. Include page-level requirements, old vs new flow, a ZH/EN/zh_CN copytable and Kafka when the feature has customer UI or tracking, and worked examples for time or calculation rules. Do not create Jira tickets unless the published spec is complete and the user asks, or the user points at an existing Confluence spec and asks for tickets."
---

# HKTV feature spec

Use this when anyone asks for a spec for a new feature or enhancement in an HKTV system (MMA, MMS, CSIS, Hybris, VSS, App, Web, or another portal), or asks to turn a Figma file, prototype, deck, or existing pages into that spec. Also use it when they point at an existing SPECDOCS page and ask for Jira tickets.

Mockups come with the spec when a screen has no Figma or prototype. Jira tickets are a separate step and are not created automatically. See section 8.

## 0. Roles and rules

Confirm two roles before writing, if they were not already given. They can be the same person.

- **Document owner**: the person who owns this spec. Use this name in the header and, if tickets are created, as the default Jira assignee.
- **Requester**: the person who asked for the feature. Use this name in the header Requester row.

Ask once for any missing name, then reuse those names.

- **Ask before writing.** Ask the questions in section 2 in one batch. Start the spec once each one is answered or explicitly marked TBC with an owner.
- **Declare the design source first.** `Figma` | `Prototype` | `Figma + Prototype` | `None` (deck, Slack, existing admin pages, or a written flow). Do not assume Figma.
- **IT must read it comfortably.** Short bullets and tables, by page and by system. No marketing prose.
- **Chat with the user in the language they use** (often Cantonese). The spec itself is in English, with ZH UI copy quoted in 「」.
- **Quote real system facts.** Variable names, job names, run times, and table names come from the current spec, runbook, ImpEx, or config. Do not invent them.
- **Use the existing system's own terms and statuses.** For MMS / MMA these are Scheduled / On-going / Completed / On hold. Do not invent Draft / Ended.
- **On business records in admin systems, do not offer Delete.** Use On hold and keep the record for audit.
- **Time rules follow the job that applies them**, not the wall clock. Name that job and its run time, or raise an open question if it is unknown.
- **Never guess copy for existing UI.** Mark existing strings as `Existing` and leave EN / zh_CN to be copied from the app, or drop the row.
- **Never put a redeemable value** (voucher code, token) in Kafka or in URLs you log.
- **Mark every unknown as TBC + owner** (IT / designer / MKT / PM). Collect them in Open questions.
- **A prototype is not a complete product.** Happy-flow spikes often omit empty, error, and edge states. List those gaps as TBC. Do not write missing states as signed-off behaviour.
- **When Figma and a prototype conflict,** record both in Open questions and ask which one wins before finalising.

## 1. Gather sources first

- Read everything the request links to: the requester's deck (Google Slides via Drive; a PDF export works when the Slides API cannot read it), Slack threads, emails, and screenshots.
- Search Confluence for the current logic: the original spec, NOC / IT runbooks, ImpEx, system variables, and cronjobs.
- Read the team's previous specs for this kind of feature and follow their table style. Examples for customer App / Web: Display Preference, Variant Pop Up, PDP Revamp, Search Result Revamp, Wet Market, KWS CMS QC Revamp.
- Check the existing copytable Google Sheet for wording already in the product.
- When the feature has App / Web tracking, read the Prod Kafka Specification (tabs `application_form`, `page_screen`, `ecommerce`, `generic_event`) and reuse existing screen names and patterns.
- Write down the current manual flow: who asks whom, what is run, and when. The spec must say what the new flow replaces.

### Design source

Build one **screen inventory** before writing when any visual source exists: `# | Screen / pop up | States seen | Source ref | Screenshot path | Notes`. Every later page section maps to a row. A pure job or API change with no UI has no inventory.

**Path A — Figma.** `get_metadata` on the page first (no node id) to list frames, sections, and flow arrows. `get_screenshot` per section. Crop to the part that section discusses. If there is no edit access, ask the user to duplicate the file into their drafts and share the copy link. On a large file, fetch sections rather than every frame, and keep the screenshots locally. Diff a new Figma version against the old metadata and report new frames, removed frames, and new states.

**Path B — Prototype.** Accept a preview or testing-app URL, an in-repo spike, an exported build, screenshots, a screen recording, or a written walkthrough.

1. Ask for the URL or repo path, how to open the flow, which platforms are covered, and which states exist beyond the happy path.
2. Walk the flow. Capture every reachable screen, pop up, bottom sheet, and toast. Name files `NN-<screen>-<state>.png`.
3. If the source is code, skim routes, screen names, copy keys, and fixtures to enrich the inventory. Unfinished code is not signed-off behaviour.
4. If the source is a recording or partial screenshots, inventory what is visible and mark unseen states `TBC with PM / designer`.
5. When the prototype came from `hktvmall-vibe-prototype`, link its Requirement AC / Testing App Pack.
6. Diff a new prototype drop against the previous inventory and report added screens, removed screens, and new states.

When both sources exist, prefer Figma for layout and component names. Use the prototype to confirm tap landings, real copy, and runtime states.

## 2. Clarifying questions

Ask in one batch, numbered, grouped. Skip a group that does not apply to this feature.

- **Design source**: Figma link, prototype URL / repo / screenshots, both, or none? Which wins if they differ?
- **Background / data**: where the data comes from, and what the old flow is.
- **Ownership and state**: who owns the record, how status changes, expiry, refunds, revoke.
- **Per page or admin screen**: grouping, sort, empty / expired / sold-out, what each button does and where it lands. For admin: list filters, create / edit, validation, which statuses can still be edited.
- **Prototype coverage**: which states are built (empty, error, loading, logged out, old app). Any Requirement AC already signed?
- **Sharing / links**: payload per channel, deep link, app not installed, not logged in, old app version.
- **Errors**: each error state, priority, copy, and buttons. Timeout and no network.
- **Notifications**: push / in-app trigger and copy.
- **Jobs and time rules**: which job applies the rule, and when it runs.
- **Delivery**: platforms, app min version, target launch, owners.

After the answers, list assumptions and ask the user to confirm them before finalising. Anything still open goes into Open questions with an owner.

## 3. Write the spec

Write the spec as a .md, then publish it to Confluence. If the user has not said where the files should live, ask once. Otherwise put the markdown, screenshots, and mockup in the current working directory under `<feature>/`.

Confluence conventions:

- Space: SPEC Documents (key `SPECDOCS`, spaceId `19202049`).
- Title: `<System> - <Feature>` when the feature lives in one system, for example "MMA - Long Holiday Store Closed Setting". When it spans several systems and no single one owns it, use the feature name alone, for example "WetMarket and 3Hr Integration to Mall". The Systems row lists every system either way.
- Header table: Document status (DRAFT), Document owner, Requester, Systems, Designer (TBC), Ticket (TBC), Target launch, Design source (Figma / Prototype / Figma + Prototype / None, plus links). Add Tech lead and QA rows when those people are known. Add Copytable and Kafka links when those deliverables exist.

Then these sections, in this order. **Leave a section out completely** — no heading and no "N/A" — when it does not apply, and renumber the rest. Related documents is always last.

1. Changes log
2. Background (current flow and new needs) and **User journey – old vs new** when a person-facing flow changes. Number the steps per actor. Add a table: Area | Old | New.
3. Objectives + Non-goals
4. Users and permissions
5. Glossary
6. Flow diagram, only when the logic needs it (see below)
7. Requirements
8. Error states, when the UI has errors
9. Notifications, when any exist
10. Backend / jobs / API, when there is server behaviour
11. Copytable and Kafka, when there is UI copy or App / Web tracking (see sections 4 and 5)
12. Acceptance criteria
13. Open questions (`# | Item | Check with | Answer`)
14. Rollout
15. Related documents

### Requirements

**Customer App / Web / pages from a design.** One subsection per screen-inventory row:

- A lead sentence for what the page does, plus the source screenshot. Composite the known states, captioned left to right, and label the caption `Figma` or `Prototype`.
- Component table: `# | Component | Display / hide condition | Tap action / landing`.
- A state × component matrix (Y/N + remark) when the page has several states.
- Rules as numbered `RULE-n` for sort, grouping, limits, and snapshot behaviour. Add pseudo code when status or result logic is branching.

**Admin portal / back office.** Per system: navigation, list page, create / edit page, validation table (V1…), and which fields can be edited in each status.

Put the image that explains a UI rule in that same subsection, next to the rule. Crop to the part the rule talks about. Annotate with numbered callouts when the rule points at specific elements, and use the same numbers in the text. Name files `<section>-<what>.png`. Link the Figma frame next to the image when one exists. Sections with no UI (backend, rollout) do not need an image.

### Flow diagram

Add a Mermaid flowchart or sequence diagram when there are several decision points, branching by status or user type, jobs or systems handing off, retries, or a customer journey with entry checks, login, cancel, or failure. Leave it out when the UI only displays data and makes no real decisions.

When you include it, show every known state and landing, including cancel, failure, and retry. States missing from the source stay on the diagram as TBC nodes. Label a decision with the real condition (`status == On-going?`, `stock > 0?`). Label a job with its name and run time. Put a sequence diagram next to Backend / API when the flow is mainly calls between systems.

Keep the Mermaid source in the .md. On Confluence, use the Mermaid macro if the space has one. Otherwise render a PNG and embed it like the other images.

### Worked examples

When a rule involves calculation, priority between rules, time windows, cut-offs, rounding, proration, or a combination of conditions, follow `RULE-n` with a table: Example # | Input / situation | Expected result | Why. Use real-looking dates, times, SKUs, amounts, and statuses.

Cover the normal case, the boundaries (exactly at the cut-off, one minute after, zero, max), and at least one case where the rule does not apply. For a time rule, show the timeline against the job, for example "Merchant edits at 23:58 → job runs 00:05 → status becomes On-going → edit locked". If an outcome is unconfirmed, still write the example and add it to Open questions.

### Acceptance criteria

Table: `ID | Scenario | Expected | Rule ref`, split by actor. Reuse signed Requirement AC from a vibe prototype when it exists, and expand it to the cases IT and QA need.

## 4. Copytable

Include this when the feature adds or changes UI copy. Read the existing copytable sheet first.

Columns: `Page | Screenshot | Key | Description | New / Existing | ZH | EN | zh_CN | Remark | Update time`

- One group per screen-inventory row. Merge the screenshot across the group's rows.
- Key = `<feature>_<page>_<module>_<element>` in lower_snake_case, so IT can use it as the i18n key.
- Pull ZH from Figma text layers, otherwise from the prototype, i18n keys, or copy the user provided.
- EN stays short. One term per concept (領取 = Claim, 換領 = Redeem).
- zh_CN is written Mandarin, not Cantonese colloquial. For example 「寫低你想同收禮人講嘅說話」becomes 「写下你想对收礼人说的话」.
- Grey rows = Existing. Do not invent their EN / zh_CN.
- Add an extra tab when the feature needs one, for example `csv template` with headers in ZH / EN / zh_CN and sample rows.

Build an .xlsx with openpyxl, images anchored per group, and upload it with Google Drive `create_file` so it becomes a Google Sheet. If a sheet for this feature already exists, edit that sheet. Drive alone can only create a new file; editing needs the Google Sheets connector. Ask before creating a second file.

## 5. Kafka

Include this when the feature has App / Web screens that need tracking. Leave it out for an admin-only or job-only change.

Columns: `Action / trigger point | event | event_category | event_action | event_label | event_value | screenName | Remark`

- `screen_view` for every page, pop up, and bottom sheet in the screen inventory.
- `generic_event` for every CTA. Category = the screen, action = the button, label = a useful id (`{sku_code}`, `{share_method}`, a result enum).
- One result event after each API call that matters.
- Reuse screen names from the Prod Kafka Specification. Never log a redeemable code.

Put the Kafka rows in the same workbook as the copytable, on a tab named `kafka ping`.

## 6. Mockups

Build a mockup only for a screen the spec must show that has no Figma frame and no prototype. This is the usual case for an admin portal change.

- One self-contained HTML file, with a tab per screen (admin list, admin create / edit, App, Web).
- Match the existing system: layout, colours, sidebar, breadcrumb, filter pills, table header, buttons, status pills, upload tiles, modals, and fonts. Copy an existing list page, edit page, or audit modal when that pattern already exists.
- For a customer-facing change with no single source of truth, show the existing version and the new version side by side.
- Mock data matches the spec. When the spec changes, update the mockup in the same turn.
- Take Playwright screenshots, fix overlaps, and use those screenshots as the section images.

Do not draw a second visual on top of a Figma frame that already shows the screen.

## 7. Publish and keep in sync

- Create the page with `createConfluenceContent`. For later changes use `updateConfluenceContent` with `edits`:
  - `replaceNode`, `insertNodeAfter`, or `deleteNode` by `data-local-id`, plus the latest `snapshotToken`.
  - Read the page with `getConfluenceContent` (html, detail full). Large results are saved to a file; parse it with python to find the local IDs.
  - Run `insertNodeAfter` on a node before running `replaceNode` on that same node.
  - On `snapshot_stale`, refetch and reapply the edits.
  - Edit the published page (not the draft) if the draft is behind.
  - If the user has already edited the page, keep those edits and apply only the delta.
- Upload the images and embed them yourself. The user should not have to place them by hand.
  1. Create the page first, because the attachment needs its page id.
  2. For each PNG, run `executeWrite` with `name: createConfluenceAttachment` and `inputs: {contentId: <page id>, localFilePath: <absolute path>, fileSize: <bytes>}`. It returns an `uploadCommand` (curl). Run that in Bash. The response gives the file's media id. The collection is usually `contentId-<page id>`.
  3. Put the image in the section it explains, next to the rule, with `updateConfluenceContent` `edits` (`insertNodeAfter` the rule's node, or `replaceNode` on an old `[Image: …]` placeholder):
     `<figure data-type="media-single" data-layout="center" data-width="60" data-width-type="percentage"><div data-type="media" data-media-type="file" data-id="MEDIA_ID" data-collection="COLLECTION" data-alt="7-cart-banner-states.png"></div><figcaption>What it shows, which state</figcaption></figure>`
     Use width 60 for screenshots and 80 for diagrams. Never make up `data-id` or `data-collection`. Copy them from the upload response. Never point `<img>` at a local path.
  4. Read the page back and check that every image renders. To replace a changed image, upload it again with the same filename so it becomes a new version of the attachment, then check that the embed shows the new one.
- Attach the mockup HTML and the .md as a file card (`media-group`) when the user wants them on the page.
- Slack uploads work too: `slack_get_file_upload_url` → POST the bytes with curl (keep the URL in a shell variable, untouched) → `slack_complete_file_upload` with the thread's `channel_id` and `thread_ts`. Only share to Slack when the user asks, and confirm the destination first.
- If an upload fails (proxy 403, size limit), retry once. If it still fails, send the PNGs in the reply, put a placeholder where each image goes (`[Image: 7-cart-banner-states.png]` plus a caption), and list the filename → section mapping so the user can attach them by hand.
- Every time the spec changes, update the .md, the mockup, the copytable workbook, and Confluence together, and add a version message.

## 8. Jira tickets

Do not create tickets while writing or publishing the spec.

Create tickets only when both are true:

1. The Confluence spec is complete. Read the published page, or the page the user named, before deciding.
2. The user has asked for tickets. Either they already pointed at a Confluence page and said to create tickets, or this run published a complete spec and they say yes when asked.

The spec is not complete when any of these is missing, empty, or still a placeholder:

- Document owner, Requester, Systems
- Background, including what the new flow replaces
- Objectives + Non-goals
- A requirement section for each system in the Systems row
- Acceptance criteria

Also required when they apply:

- A design source was used: every screen-inventory row has a page section
- UI copy changes: the copytable exists, with ZH filled in and EN / zh_CN filled in for new strings
- App / Web tracking applies: the Kafka tab exists, or an open question with an owner says tracking is out of scope

Designer may stay TBC. The Ticket cell stays TBC until tickets exist. Open questions are allowed when each one has an owner and does not change scope, behaviour, or which systems need a ticket. An open question that would change those means the spec is not complete.

If the spec is not complete, do not ask and do not create tickets. List what is missing and stop.

If this run published a complete spec and the user has not already asked for tickets, ask once: "Spec is on Confluence. Create the Jira tickets?" Stop if they say no or do not answer.

If they already pointed at a Confluence page and asked for tickets, skip that question. If that page is not complete, still do not create tickets.

After tickets exist, write the epic key back into the header Ticket row.

- Epic in `TEAMECOM`. Set Epic Name, Priority B, Development PIC `customfield_11563`, Testing PIC `customfield_11562`, Build Date `customfield_11200`, and Time Sheet Project Label `customfield_11580`.
- Epic description: background, spec link, scope per system, build, and open questions.
- Child tickets go in each system's project (`HYBRIS`, `EER`, `CSIS`, `HSS`, `HKTVAD`, and so on) with `parent` = the epic. If the system is not in that list, ask which Jira project to use. Do not invent a project key.
  - Issue type New Feature or Improvement
  - Summary prefixed `[System]` or `[service-name]`
  - Same PICs as the epic
  - Assignee: the document owner. If the user names a different assignee, use that name instead.
  - fixVersion `<Project>@YYYY-MM-DD` for the build (look it up with getJiraProjectVersions)
  - Description: background, the requirement, the `RULE-n` and acceptance-criteria ids it covers, and "to confirm with dev"
- EER requires `System` (`customfield_10300`, single option) and Time Sheet Project Label.
- Look up account IDs with `lookupJiraAccountId`. Check that the assignee stuck, because some projects auto-assign on create.
- Ask for the build version, dev PIC, and test PIC only after the user has asked for tickets and the spec is complete. If any of those is missing, ask before creating the epic. Reuse the timesheet label from the Slack thread or an earlier epic when one exists.

## 9. Slack follow-up

Skip this section when no tickets were created.

- Reply in the feature's existing Slack thread (read it first for context and who is involved). List the epic and child tickets as links, plus PICs and the timesheet label.
- Tag the dev PIC to check which tickets are still missing. Tag the owning PM of any other team (for example MMS) to create their tickets and link them to the epic.
- Only post when the user asks. Give the user the message link afterwards.

## 10. Check before handing over

- Every screen-inventory row and known state appears in a page section, the matrix, the flow diagram (when the feature has one), and the copytable (when copy changes).
- Screenshots are labelled `Figma` or `Prototype`. Conflicts between sources are in Open questions or already resolved.
- Prototype gaps (empty, error, loading, old app) are specified or listed as TBC.
- Every button has a landing. Every error has copy and buttons.
- Worked examples sit under each calculation or time rule, and the example names the job.
- Admin statuses and the no-Delete rule match section 0.
- Re-scan ZH copy for the wrong character (撐 / 撳, 喘 / 喺, 嘢 / 嘅).
- Look at the rendered diagram and fix overlaps.
- Reply briefly: design source used, what changed, what you could not do and why, and the remaining questions.

## 11. Remember

If the user names a notes file or project memory to keep, save the feature's sources, decisions, design-source choice, Confluence page id, and open questions there as they happen. Add ticket keys only after tickets are created. If they do not name a place, hand back the Confluence page and, when they exist, the copytable link. Include ticket keys only when tickets were created.
