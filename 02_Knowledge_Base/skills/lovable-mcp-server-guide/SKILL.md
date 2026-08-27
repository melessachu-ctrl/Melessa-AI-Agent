---
name: lovable-mcp-server-guide
description: Guides Lovable MCP server usage in Cursor—setup, OAuth, tool selection, plugin slash commands, and how it differs from portfolio-designer (copy-only). Use when creating or editing Lovable apps, listing projects, deploying, querying Lovable Cloud DB, or when the user mentions Lovable MCP, mcp.lovable.dev, /lovable-new, or melessa-chu-design.lovable.app automation.
---

# Lovable MCP Server Guide（Cursor）

官方文件：[Lovable MCP server](https://docs.lovable.dev/integrations/lovable-mcp-server)  
Client skill（工具參考）：[mcp.lovable.dev/skill.md](https://mcp.lovable.dev/skill.md)

## Cursor setup

### 方式 A｜Lovable Cursor plugin（建議）

Marketplace：[cursor.com/marketplace/lovable](https://cursor.com/marketplace/lovable)  
或 Chat：`/add-plugin lovable`

會帶上 MCP、skills、rules，以及 slash commands：

| Command | 用途 |
|---|---|
| `/lovable-new` | 從一句 brief 建新專案 |
| `/lovable-iterate` | 改既有專案 |
| `/lovable-db` | Lovable Cloud Postgres |
| `/lovable-deploy` | 部署並回傳 live URL |

### 方式 B｜手動 MCP

全域 `~/.cursor/mcp.json`：

```json
{
  "mcpServers": {
    "lovable": {
      "type": "http",
      "url": "https://mcp.lovable.dev",
      "auth": {
        "CLIENT_ID": "6d465f583e1e4ce5801b1616f735670c"
      }
    }
  }
}
```

1. 儲存後 Reload Window
2. 第一次工具呼叫走 **OAuth**（瀏覽器登入 Lovable）
3. 用量計入 Lovable credits；寫入／deploy 前先確認 Melessa

確認：Agent 可呼叫 `list_workspaces` 或 `get_me`。

## Lovable MCP vs portfolio-designer

| | Lovable MCP（本 skill） | `portfolio-designer` |
|---|---|---|
| 作用 | 在 Cursor **直接建／改／部署** Lovable 專案 | 產出可貼上的 **中英文案＋mockup** |
| 改網站 | 會（經 `send_message`／agent） | **不會**自動改站 |
| 適用 | 「幫我改 melessa-chu-design…」「用 Lovable 建…」 | 「寫 portfolio／project details 文案」 |

兩者可併用：先用 `portfolio-designer` 產文案，再經 MCP `send_message` 貼上／套用。

## MCP vs workspace skills

| 類型 | 是什麼 | 誰用 |
|---|---|---|
| **MCP tools** | `create_project`、`send_message`、`deploy_project` 等 | Cursor Agent 呼叫 Lovable |
| **Cursor plugin skills** | `scaffold-lovable-project`、`iterate-with-lovable-agent` 等 | Cursor Agent 工作流 |
| **Lovable workspace skills** | workspace repo 內 `skills/*/SKILL.md` | **Lovable 建站 agent**（可用 `list_workspace_skills` 等管理） |

## Tool selection（quick）

| Goal | Primary tools |
|------|----------------|
| 發現 workspace | `list_workspaces`、`get_workspace`、`get_me` |
| 新建專案 | `create_project`（可選 `render_project_widget`） |
| 改既有專案 | `send_message`（複雜功能可 `plan_mode=true`） |
| 查變更 | `get_diff`、`list_edits`、`list_messages` |
| 讀 code | `list_files`、`read_file` |
| 部署 | `deploy_project` |
| Knowledge | `get_`／`set_project_knowledge`、`get_`／`set_workspace_knowledge` |
| Workspace skills | `list_workspace_skills`、`create_workspace_skill` 等（admin／owner） |
| Database | `get_database_status` → `enable_database` → `query_database` |
| Analytics | `get_project_analytics`、`get_project_analytics_trend` |

寫入前先讀該工具的 MCP schema。`create_project`／`send_message` 會消耗 credits。

## 操作規範（Sasa）

- **讀取**（list projects、get_diff、read_file、analytics）：可直接做
- **寫入**（create／send_message、set knowledge、query_database 寫入、deploy）：先確認 Melessa 同意（與 Calendar／Figma／Base44 同級）
- `query_database` 權限等同 production — 破壞性 SQL 必須先問
- 勿把 OAuth token／credential 寫入 repo 或回覆內容
- 程式在 Lovable cloud sandbox，不在本機 repo

## Example prompts

- 「List my Lovable workspaces and recent projects.」
- 「Create a Lovable landing page for …」
- 「Update melessa-chu-design project details with this copy…」
- 「Deploy project [ID] and give me the live URL.」

## See also

- Plugin skills：`scaffold-lovable-project`、`iterate-with-lovable-agent`、`enable-lovable-cloud-database`、`deploy-lovable-project`（來自 Lovable Cursor plugin）
- 文案／mockup：`portfolio-designer`
- MCP 原始碼：[lovablelabs/mcp](https://github.com/lovablelabs/mcp)
