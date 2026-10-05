# Session｜2026-09-10～09-14｜Apple 發佈會摘要、iPhone Duo × HKTVmall homepage

## 做了甚麼

### Apple 2026 秋季發佈會

- 摘要「Surprise and Shine」（John Ternus 首場）：iPhone Duo、iPhone 18 Pro／Pro Max、Watch Series 12／Ultra 4、AirPods 5、iOS 27
- 圖解卡片（香港建議零售價）：`apple-sept-2026-event-card.png`（當時放 Cursor assets／本機工作區；**不在**本 repo）

### iPhone Duo 設計指引（HKTVmall）

- 對照 Apple Tech Talk [111466](https://developer.apple.com/videos/play/tech-talks/111466/)（原則）＋ [111462](https://developer.apple.com/videos/play/tech-talks/111462/)（vertical bar）
- 文字方案（方便上手優先）：搜尋／分類／相機留橫；右側直欄放 house、客服、六個 tab（次序不變）；內屏 sidebar + list／PDP 分欄；不刪 tab、不另造第三套導航
- Figma：team folder ≠ library；要 **Publish** + team admin 設 default；官方 **UI kits** 在 team libraries 的 **UI kits** tab enable（唔使 Publish 自己 duplicate 嗰份）

### Homepage mockup（本 repo）

- `01_Action_Center/outputs/hktvmall-duo-homepage/`
  - `duo-mockups.html`（`?view=outer`／`inner`／board）
  - `duo-homepage-outer.png`（外屏 Compact 截圖，最準）
  - `hktvmall-duo-outer-render.png`／`hktvmall-duo-inner-render.png`（效果圖；內屏 render 有少量亂碼）
- Branch／PR：`cursor/hktvmall-duo-homepage-mockups-2c88` → https://github.com/melessachu-ctrl/Melessa-AI-Agent/pull/9

### 預覽說明（本機）

- Cloud Agent **Files** 右鍵無 Open in Browser → **Download** 或本機打開
- Cloud checkout **≠** 本機 `Melessa AI Agent` folder；本機要：

```bash
cd "/Users/mchu/Melessa AI Agent"
git fetch origin cursor/hktvmall-duo-homepage-mockups-2c88
git checkout cursor/hktvmall-duo-homepage-mockups-2c88
open 01_Action_Center/outputs/hktvmall-duo-homepage/duo-mockups.html
```

## 未完成甚麼

- 內屏 HTML 截圖未收成同外屏同等精度（board／inner Chrome 截圖曾空白）
- 本機尚未 fetch／checkout 該 branch（Finder `outputs` 仍無 `hktvmall-duo-homepage`）
- HKTVmall Figma team：iOS 27 library／UI kit default 要 **team admin** 開；本回合只寫步驟、未代操作
- 未改 `02_Knowledge_Base/skills/**`／`sync/**` → **無需** UIUX-Skills sync／`#uiux-designer` 公告

## 下次由哪裡開始

- 本機 fetch 上述 branch 後用瀏覽器開 `duo-mockups.html`
- （可選）補內屏高精度截圖；或把 mockup 搬入 HKTVmall Figma
- UIUX Design Agent PoC（Step 0–3）— 見 `TASKS.md`

## 今日學到

- Duo：兩 size class（Compact 外屏／Regular 內屏），唔為每個 pose 畫一套 chrome；自訂 tab／nav **唔會**自動變直欄
- Vertical bar：icon 去直、過闊文字／搜尋留橫；badge 代替金額文字；tab 先留、toolbar 先 overflow（navigation-focused）
- Figma UI kits 同自己 duplicate 嘅 Apple kit 唔好兩套一齊開
- Cloud Agent 檔案樹／checkout 唔等於本機 repo

## 備註

- 發佈會價錢為香港建議零售價整理，非最終報價單
- Skills 本回合有讀：`hktvmall-target-customers`、`ricky-design-guideline`、`frontend-design`
