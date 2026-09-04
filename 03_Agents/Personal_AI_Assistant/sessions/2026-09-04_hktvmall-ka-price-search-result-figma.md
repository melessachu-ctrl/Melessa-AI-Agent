# Session｜2026-09-02～09-04｜HKTVmall KA Price＋Search Result Figma 批次更新

## 做了甚麼

### Figma｜HKTVmall — KA Price（`sVR8HBaQAfiJp5SqPfA1lo`）

- Typography：超市A／B tag Medium → Regular（`Body 3 · 12/01 Regular` DS token）
- 價格文案：`$99.1` → `$20.0`；指定 group stroke weight → `0.4`
- Section SKU cards 換成真實 SKU（出前一丁；美素佳兒 4 號），含 image／name／spec／promo／rating／sold／KA／mall price／unit／store
- Promo Label：`State=Promo`；文案依任務更新

### Figma｜Search Result — 3-4 Columns（`SPD3XrBhgiW57uBo28UxjZ`）

- 多個 section／frame（2 Col／3 Col／4 Col／Section 1–2）SKU card 價格改 **一位小數**：
  - Original（RP）、Discounted（含 VIP／GVIP／DVIP／專屬價等巢狀 frame）、Unit Price、超市A（及 KA）
- `21354:131898`：`Show KA 1 = Off`；`Action Btn Type = Cart`（44 張卡）

### Skills／約束（本回合有遵循）

- `uiux-design-studio`（編排）
- `figma-use`（寫入前必讀；text：load font → mutate）
- `figma-mcp-server-guide`／`upload_assets`（真實 SKU 圖）
- HKTVmall Design System 規則（text style／library-first）
- （觸發時）`hktvmall-target-customers`、`ricky-design-guideline`

## 未完成甚麼

- （無）本回合交辦 Figma 批次已完成
- 未改 skill 真源／`sync/**` → 無需 UIUX-Skills 下游操作

## 下次由哪裡開始

- UIUX Design Agent PoC（Step 0–3）— 見 `TASKS.md`／`Now.md`
- （可選）若再有「全價格一位小數」批次：先掃 `Search Result Card - Price` **整棵子樹**（勿只改 grand=`Bottom` 直系子節點），否則 VIP／專屬價會漏

## 今日學到

- VIP／GVIP／DVIP／專屬價折扣價常在內層 `Price`／`Frame …` 下，父層不是 `Search Result Card - Price` 直系 → 應用「是否在 Price card 子樹內」判斷
- `Show KA 1` 在 **RP** 元件（`Show KA 1#7342:65`）；`Show KA` 在 **Search Result Card - Price**（`Show KA#9396:0`）— 兩者不同
- Unit Price 同卡可能有隱藏空 instance + 可見 instance；改價要掃全部 `Unit Price`，勿 `findOne` 只改第一個

## 連結

- [KA Price — Search Result v1.x](https://www.figma.com/design/sVR8HBaQAfiJp5SqPfA1lo/HKTVmall---KA-Price?node-id=9779-29174)
- [Search Result 3-4 Columns — 2 Col section](https://www.figma.com/design/SPD3XrBhgiW57uBo28UxjZ/Search-Result---3-4-Columns?node-id=21354-131898)
- [Section 1](https://www.figma.com/design/SPD3XrBhgiW57uBo28UxjZ/Search-Result---3-4-Columns?node-id=22205-31726)／[Section 2](https://www.figma.com/design/SPD3XrBhgiW57uBo28UxjZ/Search-Result---3-4-Columns?node-id=22205-31727)
