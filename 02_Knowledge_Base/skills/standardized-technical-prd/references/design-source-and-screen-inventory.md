# Design source and screen inventory

## 1. Declare the design source first

Record it in the header row "Design source" before writing any requirement:
`Figma` | `Prototype` | `Figma + Prototype` | `None` (deck, Slack, existing admin pages, or a written flow), plus links.
Do not assume Figma.

When Figma and a prototype disagree, record both in Open Questions and ask which one wins before finalising.
Prefer Figma for layout and component names; use the prototype to confirm where taps land, real copy, and runtime states.

## 2. Build the screen inventory

Build it before writing whenever any visual source exists. A pure job or API change with no UI has no inventory.

| # | System / Channel | Screen / pop-up / bottom sheet | States seen | Source ref (Figma frame / prototype route) | Screenshot path | Notes |
|---|---|---|---|---|---|---|

Every inventory row becomes a screen subsection under a Functional Requirement, a row of the Test-Readiness
Inventory's screen table, and (when copy changes) a copytable group.

## 3. Path A — Figma

1. Call `get_metadata` on the page without a node ID to list frames, sections and flow arrows.
2. Call `get_screenshot` per section, cropped to the part the section discusses. On a large file, fetch sections rather than every frame, and keep the screenshots locally.
3. Use `get_design_context` for exact text layers (labels) when you need copy.
4. No edit or view access → ask the user to duplicate the file into their drafts and share that link.
5. A new Figma version → diff its metadata against the previous inventory; report new frames, removed frames and new states.
6. Figma unreachable (expired token, bridge down) → say so, draft from the other sources, mark every label `[assumed — confirm in Figma]`, and never invent labels or visual states.

## 4. Path B — Prototype

Accept a preview or testing-app URL, an in-repo spike, an exported build, screenshots, a screen recording, or a written walkthrough.

1. Ask for the URL or repo path, how to open the flow, which platforms are covered, and which states exist beyond the happy path.
2. Walk the flow. Capture every reachable screen, pop-up, bottom sheet and toast as `NN-<screen>-<state>.png`.
3. If the source is code, skim routes, screen names, copy keys and fixtures to enrich the inventory. Unfinished code is not signed-off behaviour.
4. If the source is a recording or partial screenshots, inventory what is visible and mark unseen states `TBC with PM / designer`.
5. If the prototype came from `hktvmall-vibe-prototype`, link its Requirement AC / Testing App Pack and reuse signed ACs.
6. A new prototype drop → diff against the previous inventory; report added screens, removed screens and new states.

**A prototype is not a complete product.** Happy-path spikes often omit empty, error, loading, logged-out and old-app states.
List those as `[TBC]` with an owner. Do not write missing states as signed-off behaviour.

## 5. Images in the spec

- Put the image that explains a UI rule in the same subsection, next to the rule. Crop to the part the rule talks about.
- Composite the known states of a screen left to right, and caption it with the states and the source label `Figma` or `Prototype`.
- Annotate with numbered callouts when a rule points at specific elements, and use the same numbers in the text.
- Name files `<section>-<what>.png` (e.g. `FR-03-cart-banner-states.png`). Link the Figma frame next to the image when one exists.
- Sections with no UI (backend, rollout) need no image.
- Upload and embed per `references/confluence-publishing.md` §5.
