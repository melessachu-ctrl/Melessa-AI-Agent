# Session｜2026-09-07｜uiux-design-studio 跨專案規則路徑改為多 agent 可讀

## 做了甚麼

### 問題

- `uiux-design-studio` 把跨專案規則寫死成 `~/.cursor/rules/*.mdc`；非 Cursor agent／Spaces 通常沒這條路，也不載 `.mdc`。
- 下游已有雙軌 `rules/*.md`（與 `.mdc` 同內容），skill 指標未對齊。

### Skill 更新（真源）

- `02_Knowledge_Base/skills/uiux-design-studio/SKILL.md`
  - HKTVmall／Lite App 兩段：改為搜尋順序（`rules/<name>.md` → 同名 `.mdc`（`rules/` 或 `sync/cursor-rules/`）→ Cursor 使用者規則）；皆無則以本節為準、勿阻塞
  - 專案特例：Cursor 用 `.cursor/rules/*.mdc`；其他 agent 用 `AGENTS.md`（或同等 instructions）

## 未完成甚麼

- Slack `#uiux-designer` 公告：finish session 於 Actions 成功後發送（link 補在下方）
- （可選）skill 內大量 `~/.cursor/skills/...` 路徑仍偏 Cursor，可之後再改相對路徑

## 下次由哪裡開始

- UIUX Design Agent PoC 仍在進行中（見 `TASKS.md`）
- 可選：把 `uiux-design-studio` 的 `~/.cursor/skills/` 指標改成 repo 相對路徑

## 今日學到

- 雙軌 `.md`  alone 不夠；skill 裡的「詳見」必須指向其他 agent 實際找得到的檔，否則仍當 Cursor 專用
