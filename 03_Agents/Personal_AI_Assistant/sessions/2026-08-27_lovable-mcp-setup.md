# Session｜2026-08-27｜Lovable MCP 接入 Cursor

## 做了甚麼

- 確認 Cursor 支援 Lovable 官方 MCP（`https://mcp.lovable.dev`）
- 在 `~/.cursor/mcp.json` 加入 `lovable`（保留 figma、google-workspace、base44）
- Melessa 完成 OAuth；本機出現 `user-lovable`，後亦安裝 **Lovable Cursor plugin**（`plugin-lovable-lovable`，slash：`/lovable-new` 等）
- 釐清三種 skills：MCP client skill／Cursor plugin skills／Lovable workspace skills
- 建立 Melessa skill：`02_Knowledge_Base/skills/lovable-mcp-server-guide/` + `~/.cursor/skills` symlink
- 說明與 `portfolio-designer` 分工：文案 skill 不自動改站；MCP 可直接改／部署 Lovable 專案
- 更新 Sasa：`TOOLS.md`、`MEMORY.md`、`LOG.md`、`TASKS.md`、`AGENTS.md`、`BRAIN.md`、skills README、Latest_State、觀察日誌

## 未完成甚麼

- （本 session 無阻塞項；尚未用 MCP 實際改 portfolio 或建新 Lovable app）
- Plugin slash commands 需 Melessa 在 Marketplace 完成 Install／`/add-plugin lovable`（若尚未按；cache 已見官方 plugin 目錄）

## 下次由哪裏開始

- 要用 Lovable：先讀 `lovable-mcp-server-guide`；寫入／deploy 先問 Melessa
- 範例：「List my Lovable workspaces.」或「Update melessa-chu-design with this copy…」
- Portfolio 文案仍用 `portfolio-designer`；要自動貼站再接 MCP

## 今日學到

- Lovable MCP 與 Base44 MCP 同屬「帳號級建站 MCP」；寫入耗 credits
- 只加 `mcp.json` ≠ 自動有 slash commands；需 Cursor **Lovable plugin**
- Workspace skills 存在 Lovable 端，給建站 agent 用；可用 MCP 的 `list_workspace_skills` 等管理
