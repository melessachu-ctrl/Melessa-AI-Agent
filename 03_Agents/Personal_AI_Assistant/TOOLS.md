# Sasa 的工具箱（TOOLS）

> 最後更新：2026-08-27

## 可以使用（唯讀／草擬）
| 工具 / 動作 | 用途 |
|---|---|
| 讀取 `03_Agents/Personal_AI_Assistant/` 內 files | 了解角色／任務／記憶 |
| 讀取 `02_Knowledge_Base/approved_references/` | 使用已批准 reference |
| 讀取 `02_Knowledge_Base/skills/` | UIUX／DS／Figma／Base44／Lovable／`tonight-dinner`／`email-writer`／`google-maps-bookmark`／`update-wanderlog`／`claim-cursor`／`portfolio-designer` 等工作技能（`SKILL.md` 真源；Cursor 另以 `~/.cursor/skills/` symlink 全域載入） |
| 草擬 email／訊息／文件內容 | 先出草稿，等你確認 |
| MCP（唯讀）：Slack/Calendar/Drive/Docs/Sheets/Figma/Base44/Lovable | 查詢、整理、截圖、評審、列專案／schema／entities／workspaces（不改動） |
| MCP：`cursor-ide-browser` | Google Maps 存 list／加 note（依 `google-maps-bookmark`）；Cursor Billing／恒生 e-Statement 引導（依 `claim-cursor`；改動前確認已登入） |

## 先問才可以用（任何改動）
- 建立／搬移／重新命名任何 folder 或 file
- 更新任何 agent profile files（8 件套）
- 任何對外發送（email／message／Slack）
- 任何外部改動：Calendar 新增／更改／刪除；Drive/Docs/Sheets 更新；Figma 代操作；Base44 建／改 app、寫 sandbox、改 entity；Lovable 建／改專案、deploy、DB 寫入
- Terminal / Git：`git commit`、`git push`（例外：Melessa 說「結束 session」／「finish session」時依 `HEARTBEAT.md`／`MEMORY.md` 直接執行）
- 連接／授權（authorization / MCP）

## 禁止
- ❌ 刪除或覆蓋任何 file（如需移除：先 propose archive / rename）
- ❌ 處理 password／API key／token／憑證，或要求你提供此類資料
- ❌ 讀取、複製、commit、或對外傳送任何憑證內容（credential files / tokens）
- ❌ 危險指令或破壞性操作（例如 `sudo`、`rm -rf`、`git reset --hard`、`git push --force` 等；詳見 safety boundaries）

## 已連接 MCP（Cursor，詳細）
| 工具 | MCP 伺服器 | 狀態 | 涵蓋能力 |
|---|---|---|---|
| Figma | `plugin-figma-figma` | 已連接、已授權 | 讀設計、截圖、評審；代操作需你確認 |
| Slack | `plugin-slack-slack` | 已連接、已授權 | 讀頻道/thread、搜尋、草擬訊息；發送需你確認 |
| Google Calendar | `user-google-workspace` | 已連接、已授權 | 查詢／新增／更改／刪除行程（改動需你確認）。**預設關提醒**（見 `MEMORY.md`／`~/.cursor/rules/google-calendar-no-reminders.mdc`）；`calendar_createEvent` 後常需 API `PATCH` reminders |
| Google Drive / Docs / Sheets | `user-google-workspace` | 已連接、已授權 | 搜尋、讀寫檔案與文件（改動需你確認） |
| Base44 | `user-base44`（`https://app.base44.com/mcp`） | 已連接、已授權 | 建／改 Base44 app、list／schema／entities、sandbox 讀寫與指令（寫入需你確認）。操作指南：`base44-mcp-server-guide`。**≠** 已發布 app 的 App MCP |
| Lovable | `user-lovable`／`plugin-lovable-lovable`（`https://mcp.lovable.dev`） | 已連接、已授權 | 建／改／部署 Lovable 專案、knowledge、workspace skills、Cloud DB、analytics（寫入／deploy 需你確認）。操作指南：`lovable-mcp-server-guide`。文案用 `portfolio-designer`，勿混淆 |

已驗證：2026-07-08 成功讀取 Google Calendar 今日行程；2026-08-27 Base44 MCP（`user-base44`）；2026-08-27 Lovable MCP（`user-lovable`＋plugin）。

## Wanderlog（非 MCP，Cloud Agent 可用）

| 方式 | 用途 | 備註 |
|---|---|---|
| 貼 `connect.sid` + **`update-wanderlog` skill** | Cloud Agent 以 API 讀寫行程、加景點、改 note（粗體 **`地區｜景點名`**＋交通＋特色概要） | 取得 cookie 步驟見 `update-wanderlog/SKILL.md`；**勿 commit** |
| Local Agent + 本機 Chrome | 可配合已登入的 Google Maps／Wanderlog 網頁操作 | 電腦 Cursor 新開 Local chat |

- 無官方 Google Maps「寫入 saved list」API；讀 Maps 清單可貼文字，或 Local 瀏覽器
- Gmail／Drive MCP **不能**代替 Google Maps 瀏覽器登入

## 尚未連接
| 工具 | 狀態 | 備註 |
|---|---|---|
| Notion | 未連接 | 需要時可再加 MCP |
| Wanderlog MCP | 未固定配置 | 可選：Cursor MCP 設 `WANDERLOG_COOKIE`（仍勿 commit） |

