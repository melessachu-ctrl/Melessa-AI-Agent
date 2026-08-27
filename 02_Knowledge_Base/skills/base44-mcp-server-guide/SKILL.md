---
name: base44-mcp-server-guide
description: Guides Base44 MCP server usage in Cursor—setup, OAuth/workspace scope, tool selection, and the difference vs App MCP. Use when creating or editing Base44 apps, listing projects, managing entities/sandbox, or when the user mentions Base44 MCP, create_base44_app, or app.base44.com/mcp.
---

# Base44 MCP Server Guide（Cursor）

官方文件：[Base44 MCP server](https://docs.base44.com/developers/backend/overview/mcp-server)

## Cursor setup

全域 `~/.cursor/mcp.json`：

```json
{
  "mcpServers": {
    "base44": {
      "url": "https://app.base44.com/mcp"
    }
  }
}
```

1. 儲存後重啟 Cursor（或重載 MCP）
2. 第一次連線走 **OAuth**，選要授權的 **workspace**（連線生命週期內固定）
3. 需要 **Builder plan** 或以上

確認工具可用：在 chat 請 Agent 呼叫 `list_user_apps`。

## Base44 MCP vs App MCP

| 類型 | URL | 用途 |
|---|---|---|
| **Base44 MCP**（本 skill） | `https://app.base44.com/mcp` | 在 Cursor 建／改／查 **Base44 專案** 與 sandbox |
| **App MCP** | 各已發布 app 自己的 Connection URL | 讓 AI 操作 **已上線 app** 的資料／agents／custom tools |

不要混淆兩者。App MCP 見 [App MCP docs](https://docs.base44.com/Integrations/app-mcp)。

## 權限

- Assistant 以 Melessa 身分操作，權限與她在該 workspace 的角色相同
- Viewer／Guest 不能 create／edit
- SSO workspace 會持續驗證 membership；被移出或 SSO 輪換後需重新連線

## Tool selection（quick）

| Goal | Primary tools |
|------|----------------|
| 新建專案 | `create_base44_app` |
| 改既有專案（給 editor 做） | `edit_base44_app` |
| 列專案 | `list_user_apps` |
| Build／preview | `get_app_status`、`get_app_preview_url` |
| Schema | `list_entity_schemas`、`create_entity_schema`、`update_entity_schema` |
| 資料 CRUD | `query_entities`、`create_entities`、`update_entities` |
| Sandbox 讀寫／搜尋 | `list_directory`、`read_file`、`write_file`、`edit_file`、`grep` |
| Sandbox 跑指令 | `run_command` |
| 還原點 | `create_checkpoint` |
| Connectors | `list_connectors`、`initiate_connector_connection` |

寫入前先讀該工具的 MCP schema。建立／編輯專案會背景 build；完成後可用 preview URL。

## 操作規範（Sasa）

- **讀取**（list apps、schemas、query）：可直接做
- **寫入**（create／edit app、改 schema、寫 sandbox、跑 command、建 checkpoint）：先確認 Melessa 同意（與 Calendar／Figma 改動同級）
- 勿把 OAuth token／credential 寫入 repo 或回覆內容

## Example prompts

- 「List all my Base44 projects.」
- 「Create a Base44 project for tracking job applications…」
- 「Edit my CRM project to add a follow-up date on Contacts.」
- 「Query the first 10 pending orders from my e-commerce project.」

## See also

- [Bring your own agent](https://docs.base44.com/developers/app-code/local-development/bring-your-own-agent)（sandbox scopes）
- [Docs MCP](https://docs.base44.com/developers/backend/overview/base44-docs-mcp)（搜 Base44 文件，另設）
