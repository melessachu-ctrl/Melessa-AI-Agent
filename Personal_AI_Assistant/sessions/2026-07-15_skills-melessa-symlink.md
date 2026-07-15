# Session: 2026-07-15 — Skills 真源遷入 Melessa + GitHub

## 目標

- 釐清 GitHub／跨 AI 呼叫 Sasa 的能力邊界
- 把 Sasa 會用的 Cursor skills 真源遷入 Melessa repo，並 symlink 回 `~/.cursor/skills/`
- Commit 並 push 進 GitHub

## 輸入

- 計畫：Skills Melessa symlink（真源 `02_Knowledge_Base/skills/` + Cursor shortcut）
- 遷移 11 個 UIUX／Figma／HKTVmall 相關 skills

## 輸出

- 11 個 skill 已移至 `02_Knowledge_Base/skills/`；`~/.cursor/skills/<name>` 改為 symlink
- 新增 `02_Knowledge_Base/skills/README.md`（含換機重建指令）
- 更新 `03_Agents/Personal_AI_Assistant/TOOLS.md`、`BRAIN.md` skills 入口
- 一併收錄 Step 5 相關：`AGENTS.md`、`HEARTBEAT.md`、`MEMORY.md`、觀察日誌
- Commit `f0d383b` 已 push：`https://github.com/melessachu-ctrl/Melessa-AI-Agent.git`（`main`）

## 今日學到

- 放上 GitHub ≠ 各平台自動變成完整 Sasa；需連 repo（＋ MCP）並讀 profile／skills
- Cursor 全域 skills（`~/.cursor/skills/`）不會自動跟 repo；真源應在 Melessa，再用 symlink
- 內建 `~/.cursor/skills-cursor/` 不要搬入 repo

## 待辦

- [ ] （可選）換機時依 `02_Knowledge_Base/skills/README.md` 重建 symlink
- [x] 把「skills 真源路徑」寫入 `MEMORY.md` 重要決策（2026-07-15）
- [x] 偏好：結束／finish session → 自動 commit + push（已寫入 MEMORY／HEARTBEAT／AGENTS／TOOLS）

## 反思

- 做得好：真源單一、快捷入口保留、已進 GitHub
- 待改進：觀察期工作日誌是否每次結束都補一行，下次可固定問 Melessa
