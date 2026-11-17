# Copytable, Kafka tracking and mockups (optional deliverables)

Produce these only when they apply. Leave the section out entirely (no heading, no "N/A") when they do not.

## 1. Copytable — when the feature adds or changes UI copy

Read the existing copytable Google Sheet first, for wording already in the product.

Columns: `Page | Screenshot | Key | Description | New / Existing | ZH | EN | zh_CN | Remark | Update time`

- One group per screen-inventory row; merge the screenshot cell across the group's rows.
- Key = `<feature>_<page>_<module>_<element>` in lower_snake_case, so IT can use it as the i18n key.
- ZH comes from Figma text layers; otherwise from the prototype, i18n keys, or copy the user provided.
- EN stays short. Use one term per concept (領取 = Claim, 換領 = Redeem).
- zh_CN is written Mandarin, not Cantonese colloquial (「寫低你想同收禮人講嘅說話」→「写下你想对收礼人说的话」).
- **Existing strings:** mark the row `Existing` (grey) and never invent its EN / zh_CN; copy them from the app or drop the row.
- Add extra tabs when needed (e.g. `csv template` with ZH / EN / zh_CN headers and sample rows).
- Re-scan ZH for commonly confused characters (撐 / 撳, 喘 / 喺, 嘢 / 嘅).

**Building it:** create an `.xlsx` with openpyxl, with images anchored per group. Claude with a Drive connector: upload with
`create_file` so it becomes a Google Sheet. If a sheet for this feature already exists, edit that one (editing needs the
Sheets connector); ask before creating a second file. Without Drive access, deliver the `.xlsx` and ask the user to
upload it. Link the sheet in the header's Copytable row.

The ZH / EN labels also go into the Test-Readiness Inventory screen table, so test steps can quote them.

## 2. Kafka tracking — when App / Web screens need tracking

Leave this out for admin-only or job-only changes. Read the Prod Kafka Specification first (tabs `application_form`,
`page_screen`, `ecommerce`, `generic_event`) and reuse existing screen names and patterns.

Columns: `Action / trigger point | event | event_category | event_action | event_label | event_value | screenName | Remark`

- `screen_view` for every page, pop-up and bottom sheet in the screen inventory.
- `generic_event` for every CTA: category = the screen, action = the button, label = a useful ID (`{sku_code}`, `{share_method}`, a result enum).
- One result event after each API call that matters.
- **Never log a redeemable value** (voucher code, token) in Kafka or in any URL that is logged.

Put the Kafka rows in the copytable workbook on a tab named `kafka ping`, and link it in the header's Kafka row. If tracking is
out of scope, record that as an Open Question with an owner. `test-case-preparation` turns each row into a tracking check.

## 3. Mockups — only for screens with no Figma frame and no prototype

Usually an admin-portal change.

- One self-contained HTML file with a tab per screen (admin list, admin create / edit, App, Web).
- Match the existing system: layout, colours, sidebar, breadcrumb, filter pills, table header, buttons, status pills, upload tiles, modals, fonts. Copy an existing list, edit or audit-modal page when that pattern exists.
- For a customer-facing change with no single source of truth, show the existing and new versions side by side.
- Mock data matches the spec. When the spec changes, update the mockup in the same turn.
- Take screenshots (Playwright or the browser tool), fix overlaps, and use them as the section images.
- Never draw a second visual over a Figma frame that already shows the screen.
