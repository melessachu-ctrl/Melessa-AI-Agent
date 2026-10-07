# Session｜2026-10-07｜ui-ux-pro-max 同步 upstream＋Quick Reference 路徑

## 做了甚麼

### 查 upstream

- Repo：[nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)
- 最新 commit：`477bcb2`（2026-10-03）`fix: stop Cursor skill pointing at empty Quick Reference (#509)`
- 最新 GitHub release 仍是 **v2.15.0**（2026-08-13）；`main` 已超前 release
- 本機舊版約 7 月遷入 Knowledge Base；Quick Reference 仍寫死在 `SKILL.md`，stacks 16 個

### 同步 skill 真源

從 upstream `.claude/skills/ui-ux-pro-max` 覆蓋：

- `02_Knowledge_Base/skills/ui-ux-pro-max/`（Melessa 真源）
- 本機 `UIUX-Skills/skills/ui-ux-pro-max/`（同內容；正式下游仍由 Actions 從 Melessa sync）

新版重點：79 styles／192 palettes／22 stacks；Quick Reference 改在 `references/quick-reference.md`；Three.js 改 `Timer`／`PCFShadowMap`。寫入 `.upstream-sync.json`（commit／日期）。舊版 backup 在 `*.bak-20261007-155137`（不 commit）。

### 依賴路徑

Heuristic Pass 不再當全文在 `SKILL.md`。已改：

- `uiux-review`：必讀 `SKILL.md`＋`references/quick-reference.md`
- `uiux-design-studio`：評審／a11y／一致性對齊 `quick-reference.md`
- `figma-file-cleanup`：可選 a11y 基準同上

## 未完成甚麼

- 本機 `UIUX-Skills` 的 `*.bak-*` 可刪（確認新版無誤後）
- finish session 後靠 Melessa push → Actions **Sync UIUX-Skills**；勿手動 push 下游 `skills/`

## 下次由哪裡開始

- 確認 Actions sync 成功、`#uiux-designer` 已公告
- Designer 本機跑 `./scripts/update-skills.sh`
- UIUX Design Agent PoC 仍見 `TASKS.md`

## 今日學到

- Cursor 版 skill 的 Quick Reference **刻意**拆到 `references/quick-reference.md`，`SKILL.md` 只留優先級表
- `skill.json` 的 version 欄可能落後 `main`；以 commit／`SKILL.md` hash 對齊較準
