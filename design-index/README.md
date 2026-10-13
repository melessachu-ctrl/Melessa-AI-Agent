# Design Index（PoC）

HKTVmall UIUX Design Agent 的 **feature → Figma** 目錄真源。每個高頻 feature 一個 YAML；agent **先查 index，再開 Figma**。

## 欄位

見 `01_Action_Center/outputs/docs/UIUX_Design_Agent_Implementation_8_Steps.md` Step 2 與附錄 B。

## 維護

- 新增 entry：複製任一 `.yaml`，改 `id`／`figma`／`keywords`，更新 `last_verified`
- 命名規範：`docs/design-index-naming.md`
- 本機搜尋：`python3 design-index/scripts/search_design_index.py "關鍵字"`

## Phase 0 範圍

首批 8 個 entry（多數來自 2026 Q3–Q4 已驗證 session 的 fileKey）。`checkout-v3`、`cart-v2` 為 **wip** placeholder，待 PM／設計師補 link。

## 相關

- Lookup skill：`02_Knowledge_Base/skills/uiux-design-lookup/SKILL.md`
- Agent 設定：`03_Agents/UIUX_Design_Agent/`
- Slack schema（草稿）：`docs/slack-message-schema.md`
