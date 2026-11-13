# Session｜2026-11-13｜安裝 hktv-pm-spec-writer 並列入 UIUX-Skills

## 做了甚麼

Melessa 要安裝 `Downloads/hktv-pm-spec-writer`，並讓 UIUX-Skills repo 用到。

- 真源：`02_Knowledge_Base/skills/hktv-pm-spec-writer/SKILL.md`
- 內容對齊 `hktvmall-uiux` plugin 已發布版本（commit `21110ff`）：Figma 及／或 prototype → Confluence spec、copytable、Kafka。Downloads 資料夾是較早、只寫 Figma 的草稿，沒有拿來當真源。
- `sync/uiux-skills-manifest.json` 加入此 skill（清單由 16 個變 17 個）
- `02_Knowledge_Base/skills/README.md` 同步說明
- 本機 `~/.cursor/skills/hktv-pm-spec-writer` symlink 已建

## 分發

- Melessa：`f9651b0`（skill）與 `4e1ec35`（sync 修正）已在 `main`
- 第一次 Actions [Sync UIUX-Skills](https://github.com/melessachu-ctrl/Melessa-AI-Agent/actions/runs/43386846593) 顯示成功，但沒有寫入下游。新 skill 是未追蹤檔；`git diff --quiet` 睇唔到，而且 `grep -q` 在 `pipefail` 下會漏報變更，changelog 也沒有更新。
- 已改 `sync/sync-uiux-skills.sh` 同 `.github/workflows/sync-uiux-skills.yml`，用 `git status --porcelain` 先決定要不要 commit。
- 第二次 Actions：[Sync UIUX-Skills](https://github.com/melessachu-ctrl/Melessa-AI-Agent/actions/runs/43387192963) 成功
- UIUX-Skills：[chore(sync): from Melessa @ 4e1ec35](https://github.com/melessachu-ctrl/UIUX-Skills/commit/7ab7c0007a779ccf9f6984ba244167a9da63f722)
- Slack：https://hktvitlo.slack.com/archives/C02TNPKRE81/p1794555569152709

## 未完成甚麼

- 設計師要在 UIUX-Skills 跑 `./scripts/update-skills.sh`，新開 Agent chat 先會載入

## 下次由哪裡開始

- 確認 Actions sync 成功後，設計師跑 `./scripts/update-skills.sh`
- 若要 PM spec 由 `uiux-design-studio` 主動路由，再在 studio 加觸發；今次只做安裝與分發

## 今日學到

- 同名 skill 若 plugin 已有較新版本，UIUX-Skills 應跟 plugin，避免設計師拿到只寫 Figma 的舊稿
