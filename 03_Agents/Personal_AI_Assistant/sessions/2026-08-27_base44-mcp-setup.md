# Session｜2026-08-27｜Base44 MCP 接入 Cursor

## 做了甚麼

- 確認 Cursor 支援 Base44 官方 MCP（`https://app.base44.com/mcp`）
- 在 `~/.cursor/mcp.json` 加入 `base44`（保留 figma、google-workspace）
- Melessa 完成 OAuth；本機 MCP 已出現 `user-base44`（已授權、可用）
- 說明能力：建／改 app、list／schema／entities、sandbox 讀寫與 `run_command`；並區分 **Base44 MCP** vs **App MCP**
- 建立 skill：`02_Knowledge_Base/skills/base44-mcp-server-guide/` + `~/.cursor/skills` symlink
- 更新 Sasa：`TOOLS.md`、`MEMORY.md`、`LOG.md`、`TASKS.md`、`AGENTS.md`、skills README、觀察日誌

## 未完成甚麼

- （本 session 無未完成項；尚未實際用 MCP 建／改任何 Base44 app）

## 下次由哪裏開始

- 要用 Base44：先讀 `base44-mcp-server-guide`；寫入操作先問 Melessa
- 範例：「List all my Base44 projects.」驗證連線與 workspace

## 今日學到

- Base44 MCP 需 **Builder plan+**；OAuth 選定的 workspace 固定至重新授權
- `create_base44_app`／`edit_base44_app` 走背景 build；sandbox 工具可讓 Agent 直接改 code
- App MCP 是「已發布 app 對外暴露」，與帳號級 Base44 MCP 不同
