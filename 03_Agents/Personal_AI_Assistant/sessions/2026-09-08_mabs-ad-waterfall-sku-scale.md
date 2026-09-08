# Session｜2026-09-08｜MABS Ad 模組：瀑布流縮尺＋SKU 內容對齊

## 做了甚麼

### Figma｜MABS — Ad Platform — V2（`gvyP4YrHEXraz9b3071uLY`）

頁：`Customer tracking - Ad preview`

1. **瀑布流欄寬縮尺**（節點 `30295:5246`，「178」模組）
   - 問題：1x 模組 178×292 直接放進已縮尺的 2-col search result（欄寬 **124.95**），撐破 gutter
   - 做法：對該 frame `rescale(124.95/178 ≈ 0.702)`，字級／圓角／內距一併等比
   - 結果：124.95×204.97；overflow = 0；與同欄 SKU／Video Ad 實例同寬
   - **未改**畫布 1x 原稿 `30295:4961`（仍 178×292）

2. **SKU 圖／價錢／節省金額**對齊橫向模組 A（`26989:9768`）前四格
   - 左上：$174.00／-26%
   - 右上：$74.90／-15%
   - 左下：$199.00／-46%
   - 右下：$41.00／-12%（補 Saved badge；價錢改回紅色折扣樣式）
   - 來源第五格被裁切，未寫入 2×2
   - Header（為你推薦／Sakuratin House／贊助）未改

### Skills／約束（本回合有遵循）

- `uiux-design-studio`（既有頁面改版：Director + Designer + Review）
- `figma-use`／`figma-mcp-server-guide`
- `ricky-design-guideline`、`uiux-review`、`ui-ux-pro-max`
- `hktvmall-target-customers`（search waterfall 推薦模組／Promotion CTR）

## 未完成甚麼

- （可選）瀑布流內圖層名仍叫 `178`（寬已是 124.95）
- （可選）其他 preview 畫板若也貼了未縮的 178 模組，未掃
- 未改 skill 真源／`sync/**` → 無需 UIUX-Skills 下游／Slack 公告

## 下次由哪裡開始

- UIUX Design Agent PoC（Step 0–3）— 見 `TASKS.md`／`Now.md`
- 若要同步其他 Ad preview：指出畫板即可
- 工程規格跟 **178px 1x 原稿**，不要把 preview 的 124.95／縮後字級當 production token

## 今日學到

- 此檔 search result 瀑布流是 **~0.70× preview**（2-col 275.1；欄 124.95；SKU master 178）
- 放入欄內要用 **uniform `rescale`**，不可只改 width（否則字級／圓角比例會壞）
- 橫向 `For You - Search` 與 2×2 `Redbox SKU` 元件不同：圖用 **imageHash override**；價錢用 Redbox `Price#15309:2`；Saved 是父層 overlay，不是 Redbox 內建 prop
- 無折扣的 Redbox 價錢是灰底＋深字；補 Saved 時要一併改回粉紅底＋紅字

## 連結

- [縮尺後瀑布流 Ad 模組](https://www.figma.com/design/gvyP4YrHEXraz9b3071uLY/MABS---Ad-Platform---V2?node-id=30295-5246)
- [來源橫向模組 A](https://www.figma.com/design/gvyP4YrHEXraz9b3071uLY/MABS---Ad-Platform---V2?node-id=26989-9768)
