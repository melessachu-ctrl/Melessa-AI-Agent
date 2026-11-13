# Session｜2026-11-13｜安裝 hktv-pm-spec-writer 並列入 UIUX-Skills

## 做了甚麼

Melessa 要安裝 `Downloads/hktv-pm-spec-writer`，並讓 UIUX-Skills repo 用到。

- 真源：`02_Knowledge_Base/skills/hktv-pm-spec-writer/SKILL.md`
- 內容對齊 `hktvmall-uiux` plugin 已發布版本（commit `21110ff`）：Figma 及／或 prototype → Confluence spec、copytable、Kafka。Downloads 資料夾是較早、只寫 Figma 的草稿，沒有拿來當真源。
- `sync/uiux-skills-manifest.json` 加入此 skill（清單由 16 個變 17 個）
- `02_Knowledge_Base/skills/README.md` 同步說明
- 本機 `~/.cursor/skills/hktv-pm-spec-writer` symlink 已建

## 分發

- Melessa push 與 Actions **Sync UIUX-Skills**、Slack 連結：收尾 push 後補入本檔

## 未完成甚麼

- 設計師要在 UIUX-Skills 跑 `./scripts/update-skills.sh`，新開 Agent chat 先會載入

## 下次由哪裡開始

- 確認 Actions sync 成功後，設計師跑 `./scripts/update-skills.sh`
- 若要 PM spec 由 `uiux-design-studio` 主動路由，再在 studio 加觸發；今次只做安裝與分發

## 今日學到

- 同名 skill 若 plugin 已有較新版本，UIUX-Skills 應跟 plugin，避免設計師拿到只寫 Figma 的舊稿
