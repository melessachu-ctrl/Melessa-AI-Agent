# Publishing to Confluence (PRDs and test plans)

Tool names per runtime: `references/runtime-tools.md`.

## 1. Draft-first (hard rule)

1. Draft in chat (section by section for large documents). Do not touch any page.
2. Wait for explicit approval ("put it on this page" + URL, "publish", "go").
3. Only create a page when the user asked for one. "Revise" means edit the existing page in place.
4. Re-read the page **immediately before every write**. If the version moved since your last read, or it contains content you did not write, keep those edits and apply only your delta; if they conflict, stop and ask. A full-body write from a stale read once destroyed six versions of a PM's edits.

## 2. Where pages go (HKTV conventions)

- Space: SPEC Documents (key `SPECDOCS`, spaceId `19202049`).
- PRD title: `<System> - <Feature>` when one system owns the feature (e.g. "MMA - Long Holiday Store Closed Setting"); the feature name alone when it spans several systems. The header's Systems row always lists every system.
- Test plan title: `<Feature> - Test Plan`; child pages `<Feature> — <x.y–x.z> <Section names>`.
- Keep the Markdown source of the document in the working directory under `<feature>/` (ask once where, if the user has not said).

## 3. Creating and editing

**Claude (preferred method):** create with `createConfluenceContent`. For later changes use `updateConfluenceContent` with targeted `edits` instead of rewriting the body:
- Read with `getConfluenceContent` (html, detail full). Large results are saved to a file; parse it with a script to find each node's `data-local-id`.
- Use `replaceNode`, `insertNodeAfter`, `insertNodeBefore` or `deleteNode` by `data-local-id`, with the latest `snapshotToken`. Prefer the **full UUID** in `data-local-id` (not only the last 12 hex chars) when granular edits return `granular_edit_unresolved`.
- Run `insertNodeAfter` on a node before running `replaceNode` on that same node.
- On `snapshot_stale`: re-fetch and reapply the edits.
- Edit the published page, not a draft that is behind it.

**Hermes / Codex (full-body update):** generate the whole storage-format body from structured data in code, re-read the page immediately before writing, then write with the version incremented.

## 3.1 Table of Contents (mandatory on every spec page)

Every SPECDOCS PRD page this skill creates or publishes — **parent and child specs**, and the **test-plan master** — must have a Confluence **Table of Contents** macro near the top so readers can jump without long scrolling.

**When**
- On first create / first publish of a page.
- After a substantial rewrite of an existing page that still lacks a TOC.
- When the user asks to add 目錄 / TOC. Skip only if a `toc` macro is already present (`data-extension-key="toc"`).

**Where**
- Immediately **after** the document header table.
- Immediately **before** the `Changes Log` heading when that section exists; otherwise before the first content `<h2>`.

**Macro (HTML for Atlassian MCP / Claude)** — `maxLevel: 2` (h1–h2 only; do not list every h3):

```html
<div data-type="extension" data-extension-key="toc" data-extension-type="com.atlassian.confluence.macro.core" data-parameters='{"macroParams":{"maxLevel":{"value":"2"}},"macroMetadata":{"schemaVersion":{"value":"1"},"title":"Table of Contents"}}'></div>
```

**How**
1. New page: include the macro in the create body at the position above.
2. Existing page without TOC: `getConfluenceContent` (html, full) → find the `Changes Log` (or first content) `<h2 data-local-id="…">` → `updateConfluenceContent` with `edits: [{ name: "insertNodeBefore", localId: "<full UUID>", value: "<toc macro html>" }]` and the latest `snapshotToken`.
3. Re-fetch and confirm `data-extension-key="toc"` is present and sits above Changes Log / the first content h2.
4. Version message example: `Add Table of Contents (maxLevel 2) after document header.`

**Do not confuse with Related content.** Confluence's automatic "Related content" block at the bottom is viewer-history based. It is **not** where child-spec links go. Put child / sibling links in **Related Documents** (and the parent Section 17 when used). Do not invent or edit Related content.

## 4. HTML rules

- Generate storage-format HTML **from structured data in code** and pass it as a JSON-escaped string. Do not hand-type hundreds of attributes, and do not convert Markdown to HTML (it loses nested tables and images).
- `<table>`, `<ol>` and `<ul>` go directly inside `<td>`, never inside `<p>`.
- Tables: `data-layout="full-width"` when there are more than 4 columns; `default` otherwise.
- No `<html>`, `<head>` or `<body>` wrappers. `<code>` for field names, SKU codes and config keys. Escape `&`, `<` and `>`.
- Mermaid: use the Mermaid macro if the space has one; otherwise render a PNG and embed it as an image. Always keep the Mermaid source in the Markdown file. Check the render visually for overlapping or clipped labels (especially CJK).

## 5. Images (screenshots, diagrams, mockups)

1. Create the page first, because attachments need its page ID.
2. For each PNG: upload it as an attachment (`createConfluenceAttachment` → run the returned `uploadCommand` → read the media `id` from the response; the collection is usually `contentId-<page id>`).
3. Embed it in the section it explains, next to the rule it illustrates (`insertNodeAfter` the rule's node, or `replaceNode` an `[Image: …]` placeholder):
   ```html
   <figure data-type="media-single" data-layout="center" data-width="60" data-width-type="percentage"><div data-type="media" data-media-type="file" data-id="MEDIA_ID" data-collection="COLLECTION" data-alt="7-cart-banner-states.png"></div><figcaption>What it shows, which state</figcaption></figure>
   ```
   Width 60 for screenshots, 80 for diagrams. **Never make up `data-id` or `data-collection`**; copy them from the upload response. Never point `<img>` at a local path.
4. To replace an image, upload again with the same filename (new attachment version), then check that the embed shows it.
5. Attach the Markdown or mockup HTML as a file card (`media-group`) only when the user wants them on the page.
6. **If an upload fails** (proxy 403, size limit, tool not available): retry once; then put `[Image: <file>.png]` plus a caption where each image goes, send the PNGs in the reply, and list filename → section so the user can attach them.

## 6. Large documents

- Keep each page body well under the API limit. Split a test plan into a master page + section child pages (about 5–10 journeys each).
- Create child pages first, then the master with links to them.

## 7. Filling an existing page (execution pages, partly written plans)

- Fill, never restructure: keep the page's schema, headings, order and language.
- **Preserve media:** count `data-id=` (and `<figure>`) on the fetched body and on the composed body; the counts must match.
- Slim large bodies before a full-body write: drop `data-local-id` attributes (check the `annotation` count first, because inline-comment anchors depend on them); replace nested-table migration extensions with `<ul>/<li>`.
- Never write into tester-owned Result or Screenshot cells, or status legends. Keep the tester's notes; if one contradicts the behaviour model, add a "to clarify" note beside it.
- Do not write while the requester is editing the page; hand over paste-ready text instead.

## 8. After every write

- Re-fetch and confirm: version incremented, title correct, **your specific new content is present** (the last section or journey is there, which also catches truncation), media counts unchanged, images render.
- A write the tool reported as timed out may have landed. Re-fetch before reporting failure.
- Use a descriptive version message ("Add FR-04 worked examples"; "Add 1.5–1.6 journeys TC-15…TC-24"), and tell the user earlier versions are in page history.

## 9. Known write-back quirks (not damage)

`data-local-id` values are regenerated; `<time>` dates come back localised; a smart link with an empty anchor renders as the raw URL. Verify dates from the HTML readback.
