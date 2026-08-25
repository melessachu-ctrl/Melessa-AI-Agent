# Project Details Schema（Lovable）

對齊 Melessa portfolio project details 頁結構。參考頁：https://melessa-chu-design.lovable.app/projects/product-search-tool

## Scalar fields

| key | label | 說明 |
|-----|-------|------|
| `title` | Title | 專案標題；可含成果／價值主張 |
| `short_description` | Short description | 1–2 句摘要 |
| `category` | Category | 如 UX/UI Design、Web Design、AI Product Design |
| `client` | Client | 客戶名稱或 Personal Project |
| `duration` | Duration | 專案時長或「Client project」 |

每個 scalar 都有 `en` / `zh`。

## Content sections（My Approach）

依序：

| key | label |
|-----|-------|
| `vision_and_innovation` | Vision and Innovation |
| `identifying_unique_challenges` | Identifying Unique Challenges |
| `resolving_complex_problems` | Resolving Complex Problems |
| `user_centric_design` | User-Centric Design |

每個 section：

- `key`、`label`
- `subtitle.en` / `subtitle.zh`（可當 H3）
- `body.en` / `body.zh`

## Lovable mapping（建議）

| 頁面位置 | 來源 |
|----------|------|
| Hero title | `fields.title.en` |
| Hero subtitle | `fields.short_description.en` |
| Meta category | `fields.category.en` |
| Meta client | `fields.client.en` |
| Meta duration | `fields.duration.en` |
| Content blocks | `sections[]` 依上表順序 |

`page_route` 建議：`/projects/{project_slug}`

## JSON 頂層欄位

```text
project_slug
project_type          # 固定 "portfolio_project_details"
target_platform       # 通常 "lovable"
reference_url         # 產品／專案外部連結（可選）
portfolio_reference   # 結構參考頁 URL
fields                # object of scalar en/zh
sections              # array
lovable_mapping       # optional
design_assets         # optional string list（外部 PDF 路徑說明，勿 commit 大檔）
```

完整範例：`../examples/eats365-scan-to-order.json`
