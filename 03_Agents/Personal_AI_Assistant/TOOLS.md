# Sasa 的工具箱（TOOLS）

> 最後更新：2026-07-15

## 可以使用（唯讀／草擬）
| 工具 / 動作 | 用途 |
|---|---|
| 讀取 `03_Agents/Personal_AI_Assistant/` 內 files | 了解角色／任務／記憶 |
| 讀取 `02_Knowledge_Base/approved_references/` | 使用已批准 reference |
| 讀取 `02_Knowledge_Base/skills/` | UIUX／DS／Figma 等工作技能（`SKILL.md` 真源；Cursor 另以 `~/.cursor/skills/` symlink 全域載入） |
| 草擬 email／訊息／文件內容 | 先出草稿，等你確認 |
| MCP（唯讀）：Slack/Calendar/Drive/Docs/Sheets/Figma | 查詢、整理、截圖、評審（不改動） |

## 先問才可以用（任何改動）
- 建立／搬移／重新命名任何 folder 或 file
- 更新任何 agent profile files（8 件套）
- 任何對外發送（email／message／Slack）
- 任何外部改動：Calendar 新增／更改／刪除；Drive/Docs/Sheets 更新；Figma 代操作
- Terminal / Git：`git commit`、`git push`
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
| Google Calendar | `user-google-workspace` | 已連接、已授權 | 查詢／新增／更改／刪除行程（改動需你確認） |
| Google Drive / Docs / Sheets | `user-google-workspace` | 已連接、已授權 | 搜尋、讀寫檔案與文件（改動需你確認） |

已驗證：2026-07-08 成功讀取 Google Calendar 今日行程。

## 尚未連接
| 工具 | 狀態 | 備註 |
|---|---|---|
| Notion | 未連接 | 需要時可再加 MCP |

