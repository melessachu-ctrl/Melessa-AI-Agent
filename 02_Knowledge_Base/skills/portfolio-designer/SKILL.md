---
name: portfolio-designer
description: 當使用者要寫 Melessa portfolio 專案文案、device mockup、更新作品集／Lovable project details 時，依固定欄位產出中英對照文案與專業 mockup（可選 JSON／PDF export）。觸發詞含 portfolio、project 文案、device mockup、作品集、Lovable project details。
---

# Portfolio Designer — Melessa Chu

## 載入時機（必遵守）

命中下列**任一**情況時，必須載入並依本 skill 執行（不可略過、不可改用其他格式）：

- 使用者說：portfolio／作品集／更新 portfolio／portfolio 文案／project 文案／project details
- 使用者說：device mockup／mockup 效果圖／portfolio mockup
- 使用者提到目標站 **melessa-chu-design.lovable.app** 或要產出可貼上 Lovable 的專案內容
- 使用者先叫 **Sasa／Personal AI Assistant**，再要求寫 portfolio 專案內容或 mockup

執行前可讀：

- `references/project-details-schema.md`（欄位定義）
- `examples/eats365-scan-to-order.json`（完整範例語氣與結構）
- `examples/mockup-previews/`（mockup 視覺參考，可選）

## 目標

為 **Melessa's portfolio website**（https://melessa-chu-design.lovable.app）快速產出：

1. Project details **中英對照文案**（可直接貼上 Lovable）
2. **Device mockup** 效果圖或合成指引（乾淨、專業、突出產品畫面）

**不做**：自動改 Lovable 網站、commit 大份設計 PDF、代表使用者對外發布。

## 網站風格參考

設計與文案須與現有網站一致：

- 語氣：專業、清晰、有熱情；善用具體成果與數字，但不誇張
- 視覺：簡潔、現代、留白充足；mockup 乾淨俐落，突出產品畫面
- 品牌定位：UI/UX Designer Manager · Hong Kong；F&B / eCommerce / Fintech；Technology, Data & Empathy

結構參考頁：https://melessa-chu-design.lovable.app/projects/product-search-tool

---

## Project 文案任務

### 產出欄位（依序，中英對照）

| 欄位 | 說明 |
|------|------|
| **Title** | 專案標題；可含一句成果或價值主張 |
| **Short description** | 1–2 句摘要，放在標題下方 |
| **Category** | 如 UX/UI Design、Web Design、AI Product Design |
| **Client** | 客戶名稱或 Personal Project |
| **Duration** | 專案時長 |
| **Vision and Innovation** | 動機、洞察、創新點；可用小標題開場 |
| **Identifying Unique Challenges** | 核心痛點與獨特挑戰；可用 bullet |
| **Resolving Complex Problems** | 解法與做法；步驟或策略要具體 |
| **User-Centric Design** | 以使用者為中心的設計決策；可列關鍵 UI/UX 選擇 |

詳見 `references/project-details-schema.md`。

### 文案格式

- 每個欄位先英文、後中文（或並列小標 EN / 中文）
- 段落之間留空行，小標題用 `###` 層級
- 英文：簡潔、主動語態、可讀性高
- 中文：繁體中文，語氣與英文一致，避免直譯腔
- 用詞專業但容易理解，不冗長，語氣熱情、有趣生動

### 範例語氣（Product Search Tool）

- Title 型態：*Cross Platform Product Search Tool — compare prices in one click*
- Short description：一句話說清產品價值與使用情境
- 內文弧線：真實經驗 → 問題本質 → 輕量解法 → 使用者體驗決策

完整專案範例見 `examples/eats365-scan-to-order.json`。

### 預設 Markdown 輸出

每次文案任務預設輸出可 copy-paste 的 markdown（欄位順序固定）。若使用者要求 JSON，另輸出與範例同 schema 的 JSON。

```markdown
## Title
**EN:** ...
**中文:** ...

## Short description
**EN:** ...
**中文:** ...

## Category
**EN:** ...
**中文:** ...

## Client
**EN:** ...
**中文:** ...

## Duration
**EN:** ...
**中文:** ...

### Vision and Innovation
#### EN — {subtitle}
...
#### 中文 — {subtitle}
...

### Identifying Unique Challenges
...

### Resolving Complex Problems
...

### User-Centric Design
...
```

資料不足時：用 `[Placeholder]` 標示缺漏，不拒絕產出草稿。

---

## Device Mockup 任務

每次接到 device mockup 任務：

- 配合 portfolio website 的 style
- 產出感覺專業的 device mockup 效果圖
- 效果圖保持整潔，避免不必要的文字

### Mockup 原則

- 優先使用與網站一致的裝置呈現（手機、平板、瀏覽器 frame），畫面以 UI 截圖為主
- 背景與陰影克制，不搶產品內容
- 若需標註，僅保留必要、極少量輔助文字
- 視覺參考：`examples/mockup-previews/`（Eats365 預覽風格）

### 產圖方式

1. 使用者提供 UI 截圖時：依上述原則給出合成／排版指引，或用可用的圖像工具合成
2. 需從零產示意 mockup 時：使用 Cursor `GenerateImage`，prompt 強調乾淨裝置 frame、留白、產品畫面為主、少標註
3. 大型設計源檔（PDF）留在 `~/Desktop/Melessa Design/`，**不要**塞進 git

---

## 可選：JSON／PDF export

- JSON：與 `examples/eats365-scan-to-order.json` 同 schema
- PDF：可執行同目錄 `scripts/export_portfolio_copy.py`（讀 JSON → PDF）

```bash
python3 scripts/export_portfolio_copy.py \
  --input examples/eats365-scan-to-order.json \
  --output /path/to/out.pdf
```

依賴見 `scripts/requirements.txt`（`fpdf2`）。字型預設嘗試系統 Arial Unicode；可用 `--font` 覆寫。

---

## 完成後回報

- 做了甚麼：（文案／mockup／JSON／PDF）
- 結果如何：欄位是否齊全、是否已對齊參考頁結構
- 待你確認：需貼上 Lovable 的區塊、mockup 是否要再調
- 下一步建議：例如補截圖、調語氣、export PDF
