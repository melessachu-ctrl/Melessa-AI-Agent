# Session｜2026-11-03｜marketingskills 月更同步

## 做了甚麼

- 12 個 marketing skills 釘在 [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) `88c79f65`（2026-10-30）。上游之後會再更新，本機副本之前不會自動跟上。
- 加上跟 `apple-design`、`ui-ux-pro-max` 同一套的月更：
  - `sync/sync-marketingskills-upstream.sh`：12 個 stamp 與上游 SHA 相同就結束；任一落後或彼此不一致就覆蓋並寫 stamp。上游缺了某個 `SKILL.md` 就停，不改本機檔。
  - `.github/workflows/sync-marketingskills-upstream.yml`：每月 1 號 09:30 HKT。有差才 commit Melessa `main`，並觸發 Sync UIUX-Skills。
- 設計師只會收到 `cro`、`offers`、`copywriting`、`copy-editing`。其餘 8 個留在 Melessa。`uiux-design-studio` 與 `uiux-review` 不會被這次覆蓋。
- Cursor Automation 草稿：`sync/cursor-automation-marketingskills-monthly.md`。編輯器已打開 **Monthly marketingskills sync check**（每月 1 號 10:45、Cloud、`Melessa-AI-Agent` `main`）。儲存由 Melessa 在 Automations UI 按 Save。

## 未完成甚麼

- Automations UI 若尚未按 Save，月更通知不會跑。GHA 本身不依賴這條 Automation。
- 奶粉品牌的 `.agents/product-marketing.md` 尚未寫。

## 分發

- 這次沒有改 12 個 skill 正文或 manifest。`02_Knowledge_Base/skills/README.md` 在 skills 路徑下，push 後 Sync UIUX-Skills 會跑，但下游只複製 manifest 內的 skill 目錄，預期沒有新的下游 commit，也不發 `#uiux-designer`。

## 下次由哪裡開始

- 確認 Automations 裡 **Monthly marketingskills sync check** 已 Save，並選 Cloud、Slack 目的地 `#melessa-cursor`。
- 下次月更看 Actions「Sync marketingskills upstream」。

## 今日學到

- 只寫 `.upstream-sync.json` 不會讓副本跟上游。要有排程對 SHA，有差才覆蓋。
- 三條月更要錯開：pro-max 09:00、apple-design 09:15、marketingskills 09:30。通知再晚一截：10:00、10:30、10:45。
