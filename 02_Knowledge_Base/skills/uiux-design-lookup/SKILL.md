---
name: uiux-design-lookup
description: Read-only PM design lookup — search design-index YAML first, then Figma MCP (metadata, screenshot, design context). Use when PM or agent asks where a design is, UI state (OOS/error), component, or Figma link for HKTVmall features.
---

# UIUX Design Lookup（read-only）

PM／agent **查設計稿定位同 UI state** 的流程。唔做設計決策、唔改 Figma。

## 觸發

- 「最新 design 喺邊」「搵 Figma」「PDP OOS 點樣」「search result 邊個 frame」
- Slack `@uiux-design-agent lookup`（見 `docs/slack-message-schema.md`）

## 必讀

- Index：`design-index/*.yaml`（repo 根目錄）
- 操作：`02_Knowledge_Base/skills/figma-mcp-server-guide/SKILL.md`
- Agent 邊界：`03_Agents/UIUX_Design_Agent/SOUL.md`

## 流程（固定順序）

1. **Parse query**：feature 名、platform、Jira、state 關鍵字（OOS、error、consent…）
2. **Search index**
   - 跑 `python3 design-index/scripts/search_design_index.py "<keywords>"`  
   - 或手動 grep `design-index/` 的 `keywords`／`id`／`jira`
   - 0 命中 → `status: not_found`，`confidence: low`，建議 escalate
   - 多命中 → 列 top 3，請求澄清或選 `status: partial`
3. **Check `status`**
   - `wip` / `deprecated` → 答案必須標明；`design_status` 跟 entry
   - `figma.file_key` 為 null → `partial`，勿捏造 link
4. **Figma MCP**（有 file_key 時）
   - 大 frame：`get_metadata` → 再對子 node `get_design_context`
   - 要視覺：`get_screenshot`（fileKey + nodeId）
   - DS component：`search_design_system`
   - Tokens：`get_variable_defs`
5. **輸出格式**（對齊 Slack schema）

```text
status: found | partial | not_found | escalate
confidence: high | medium | low
answer: <2–3 句，繁中或 PM 所用語言>
figma_url: <entry figma.url>
design_status: approved | wip | deprecated
evidence:
  - design-index: <id>
  - figma: get_metadata / get_screenshot（如有）
escalate_to: <若 confidence=low 或 not_found>
```

## Confidence 指引

| 情況 | confidence |
|------|------------|
| index hit + MCP 確認 node 存在 | high |
| index hit，未開 Figma | medium |
| 多個 entry 或 wip placeholder | medium / low |
| 無 index、無 link | low → escalate |

## 邊界

- **Read-only**：禁止 `use_figma` 寫入、generate、delete
- **HKTVmall 價格文案**：跟 repo 規則，金額顯示小數點後一位（若摘要含 price）
- **勿**把 API key／token 寫入回覆或 commit

## PoC 測試題

見 `docs/pm-top-10-design-queries-draft.md` 底部 5 題。
