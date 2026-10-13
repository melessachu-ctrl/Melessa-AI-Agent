# TOOLS｜UIUX Design Agent

## Repo（read）

| 路徑 | 用途 |
|------|------|
| `design-index/*.yaml` | Feature → Figma metadata |
| `design-index/scripts/search_design_index.py` | 關鍵字搜尋 |
| `docs/slack-message-schema.md` | Slack 回覆格式 |

## Figma MCP（read-only）

| 工具 | 用途 |
|------|------|
| `get_metadata` | Frame 結構 |
| `get_screenshot` | 出圖 |
| `get_design_context` | UI spec 摘要 |
| `search_design_system` | DS component |
| `get_variable_defs` | Tokens |

指南：`02_Knowledge_Base/skills/figma-mcp-server-guide/SKILL.md`

## Slack（production 階段）

- 監聽／回覆 `#agent-uiux-design`（Step 5）
- PoC 階段：Cursor 手動試跑，唔做 always-on bot

## 禁止

- `use_figma` 寫入、刪除 node
- 未授權對外發送
