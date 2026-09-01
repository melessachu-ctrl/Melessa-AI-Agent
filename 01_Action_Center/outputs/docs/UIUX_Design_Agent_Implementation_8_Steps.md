# UIUX Design Agent 實施步驟（8 步）

> 供 PM / UIUX / Hermes team 隨時參考之實施手冊  
> **文件版本：** 2026-09-01

**背景：** PM team 使用 Hermes Agent（本地 macOS + 雲端 LLM），經 WhatsApp 回應 stakeholder；跨 agent 協作在 Slack channel 進行。UIUX team 目前無對外 AI agent，PM 查 Figma design 需人手找設計師。

**目標：** 建立 UIUX Design Agent（Hermes 同級），令 PM 可自助查設計稿、screenshot、UI spec，並在 low confidence 時 escalate 設計師。

**技術分工：** Hermes = production agent｜Cursor = skills 開發／PoC lab｜Repo = agent 設定 + design-index 真源

---

## 目錄

1. [整體架構](#整體架構)
2. [Step 0：對齊 PM agent 嘅 inter-agent 協議](#step-0對齊-pm-agent-嘅-inter-agent-協議)
3. [Step 1：盤點 PM top 10 查詢](#step-1盤點-pm-top-10-查詢)
4. [Step 2：建 Design Index](#step-2建-design-index)
5. [Step 3：喺 Cursor 試 Figma MCP + 寫 lookup skill](#step-3喺-cursor-試-figma-mcp--寫-lookup-skill)
6. [Step 4：建 Hermes UIUX Design Agent](#step-4建-hermes-uiux-design-agent)
7. [Step 5：接 Slack channel](#step-5接-slack-channel)
8. [Step 6：PoC 試跑](#step-6poc-試跑)
9. [Step 7：加 governance + 設計師把關](#step-7加-governance--設計師把關)
10. [Step 8：擴展](#step-8擴展)
11. [附錄 A：Repo 策略與 PoC 路線](#附錄-arepo-策略與-poc-路線)
12. [附錄 B：Design Index YAML 範例](#附錄-bdesign-index-yaml-範例)
13. [附錄 C：常見陷阱](#附錄-c常見陷阱)

---

## 整體架構

```
Stakeholder (WhatsApp)
        ↓
   Hermes PM Agent（macOS 常駐）
        ↓ 設計相關問題
   Slack #agent-uiux-design
        ↓
   UIUX Design Agent（Hermes 同級）
        ↓
   Slack 回覆 → Hermes 整合 → WhatsApp 答 stakeholder
```

| 元件 | 角色 |
|------|------|
| **Hermes PM Agent** | 理解 stakeholder 問題、routing、整合回覆 |
| **UIUX Design Agent** | read-only 查 design-index + Figma，回覆 link / screenshot / 摘要 |
| **Design Index（repo）** | feature → Figma link、Jira、status、keywords 目錄 |
| **Figma MCP** | get_metadata、get_screenshot、get_design_context、search_design_system |
| **Cursor** | 開發 skills、PoC 試 lookup；唔係 production Slack bot |

**PM 查詢分類：**
- 「定位」（最新稿喺邊）同「理解」（某 state 點設計）→ AI 高成功率
- 「判斷」（PRD 同 design 有冇衝突）→ AI 初稿 + 設計師 confirm

---

## Step 0：對齊 PM agent 嘅 inter-agent 協議

**⏱ 約 1 天｜與 Hermes PM team 協作**

同 Hermes PM team 確認 Slack channel 規則同 message schema，確保 PM agent 知道點 parse UIUX Design Agent 回覆並整合至 WhatsApp。

### 建議 Slack channel

`#agent-uiux-design`（或沿用現有 agent channel 命名規則）

### PM Hermes 發送格式（示例）

```
@uiux-design-agent lookup
query: "Checkout v3 最新 approved design 喺邊？"
context: { jira: "HKTV-1234", platform: "app" }
```

### UIUX Design Agent 回覆格式（示例）

```
status: found | partial | not_found | escalate
confidence: high | medium | low
answer: "..."
figma_url: "..."
screenshot: [Slack upload 或 link]
design_status: approved | wip | deprecated
escalate_to: @designer（若 confidence=low）
```

### 本步交付物

- Slack channel 名稱確認
- Message schema 文件（可放 repo `docs/slack-message-schema.md`）
- Escalation 觸發條件共識（confidence=low、not_found、design_status=wip 等）
- 確認 macOS 可否跑第二個 Hermes instance（或同機不同 profile）
- 確認 Hermes 是否原生支援 MCP，或需 Figma REST wrapper

---

## Step 1：盤點 PM top 10 查詢

**⏱ 3–5 天｜訪談 PM / 翻 Slack 記錄**

喺 Slack 或短訪問問 PM：「過去一個月，你最常問設計師咩？」分類後通常包括：

1. 搵最新 design link
2. 某個 UI state 點設計（empty / error / OOS 等）
3. 用咩 component / DS token
4. 呢個 flow 有冇舊版 / 新版
5. PRD 同 design 有冇 gap

> **範圍控制：** Phase 1 只 solve 第 1–3 類（lookup + 理解），已可減 60%+ 人手查詢。第 5 類留 Step 8 擴展。

### 本步交付物

- Top 10 查詢清單（含真實例句）
- 每類查詢對應 confidence 預期（high / medium / low）
- PoC 測試用 3–5 條真實問題

---

## Step 2：建 Design Index

**⏱ 1–2 週｜設計師主導**

在 repo 建立 `design-index/`，每個 feature 一個 YAML 檔，記錄結構化 metadata。UIUX Design Agent 先查 index，再開 Figma，唔使每次問設計師「檔案喺邊」。

### Phase 0 範圍

只 index **5–10 個高頻 feature**（例如 Checkout、PDP、Cart、Search、Login），唔好一次 index 晒所有 Figma 檔。

### 每個 entry 最少欄位

| 欄位 | 說明 |
|------|------|
| `id` / `name` | Feature 識別 |
| `platform` | app / web |
| `status` | approved｜wip｜deprecated |
| `figma` | file_key、node_id、url |
| `jira` / `confluence` | 雙向 link |
| `keywords` | PM 可能用嘅搜尋詞 |
| `owner` | 負責設計師 |
| `last_verified` | 最後確認日期 |

### 設計 metadata 治理（同步進行）

- Figma 檔案命名：`[Platform] / [Feature] / [Version] / [Status]`
- 每個 Jira epic 必須 link 對應 Figma frame
- 標記 Approved vs WIP vs Archive

### 本步交付物

- `design-index/` 內 5–10 個 YAML 檔
- 命名規範 brief（Confluence 或 repo docs）

---

## Step 3：喺 Cursor 試 Figma MCP + 寫 lookup skill

**⏱ 約 1 週｜UIUX team + Cursor lab**

用 Cursor 做 **lab**（唔係 production bot）。試到 80% 查詢 pattern 有穩定 output，先 port 去 Hermes。

### 操作清單

1. 加 Figma MCP（`https://mcp.figma.com/mcp`）
2. 重用現有 skills：`figma-mcp-server-guide`、`uiux-design-studio` 等
3. 新建 `uiux-design-lookup/SKILL.md`，定死流程：
   - 收到 query → 先查 design-index → 再 call Figma tools
   - 固定回覆格式（answer + evidence + confidence + design_status）
   - 邊界：read-only、唔做設計決策
4. 用 Step 1 嘅 3–5 條真實 PM 問題試跑

### Figma 工具對照

| PM 問題 | 工具 |
|---------|------|
| 搵 checkout 最新 design | design-index → `search_design_system` |
| show me PDP OOS state | `get_metadata` → `get_design_context` + `get_screenshot` |
| 用咩 component？ | `get_code_connect_map` |
| design tokens 係咩？ | `get_variable_defs` |

### PoC 成功標準（Cursor 階段）

- 80% 測試問題有 Figma link + 2–3 句摘要
- 知道邊啲 case 要 escalate 設計師
- Figma read rate limit 可接受

---

## Step 4：建 Hermes UIUX Design Agent

**⏱ 1–2 週｜Hermes + UIUX 協作**

跟 PM Hermes 同一框架，在 macOS 起第二個 Hermes instance（或同機不同 profile）。

### Agent 8 件套（放 repo）

```
03_Agents/UIUX_Design_Agent/
  AGENTS.md    ← 角色：UIUX Design Agent，read-only
  SOUL.md      ← 語氣、邊界、escalation 原則
  TOOLS.md     ← Figma MCP、design-index、Slack
  BRAIN.md     ← 引用 skills + design-index 路徑
  MEMORY.md    ← 常見 query cache、escalation 記錄
  HEARTBEAT.md / LOG.md / TASKS.md（按需）
```

### TOOLS 層

| Tool | 用途 | 實作 |
|------|------|------|
| `search_design_index` | 關鍵字 / Jira / feature 搵 entry | 讀 repo YAML |
| `figma_get_metadata` | 睇 frame 結構 | Figma MCP 或 REST |
| `figma_get_screenshot` | 出圖俾 PM | Figma MCP |
| `figma_get_design_context` | UI spec 摘要 | Figma MCP |
| `search_design_system` | 搵 DS component | Figma MCP |

若 Hermes **原生支援 MCP**：直接接 Figma MCP server。  
若**唔支援**：寫 thin HTTP wrapper（例如 Python FastAPI）包 Figma REST API，Hermes 當 custom tool call。

### 固定回覆格式

1. **Answer**：2–3 句設計摘要
2. **Evidence**：Figma link + screenshot
3. **Status**：Approved / WIP / Deprecated
4. **Confidence**：High / Medium / Low
5. **Escalate?**：Low confidence 時 @designer

---

## Step 5：接 Slack channel

**⏱ 3–5 天**

1. 開 `#agent-uiux-design`（或沿用現有 agent channel pattern）
2. UIUX Design Agent Hermes instance 監聽該 channel
3. PM Hermes 收到 WhatsApp 設計問題 → 轉發 Slack → 等 thread 回覆 → 整合 → WhatsApp

### PM Hermes routing 邏輯（示意）

```
if query matches design_patterns:
    slack_post("#agent-uiux-design", query)
    response = wait_for_thread_reply(timeout=60s)
    if response.confidence == "low":
        append "⚠️ 設計師確認中"
    whatsapp_reply(format_for_stakeholder(response))
else:
    handle_normally()
```

---

## Step 6：PoC 試跑

**⏱ 2 週**

- 揀 2–3 個 PM 試用
- 只 cover design-index 入面嘅 5–10 個 feature
- 記錄：response time、accuracy（PM 評分）、escalation rate、設計師被 interrupt 次數

### PoC 成功標準

| 指標 | 目標 |
|------|------|
| Lookup 回覆時間 | 80% < 30 秒 |
| PM 滿意度 | ≥ 4/5 |
| Escalation rate | < 30% |
| 設計師 interrupt | 降 60–80%（對比 baseline） |

---

## Step 7：加 governance + 設計師把關

**⏱ ongoing**

| 機制 | 做法 |
|------|------|
| Read-only | Agent 只有 Figma read scope |
| Status 標記 | 每個 index entry 有 approved / wip / deprecated |
| Low confidence escalate | 自動 @designer in Slack |
| 設計師 confirm loop | Designer 確認後更新 index + MEMORY |
| Rate limit | Figma MCP 有 read limit；batch 查詢、cache screenshot |

### UIUX Design Agent 應該做

- ✅ 搵設計稿、show screenshot、summarize UI spec
- ✅ 回答「用咩 component / token」
- ✅ 指出 design 同 PRD 可能不一致（初稿）

### UIUX Design Agent 唔應該做

- ❌ 改 Figma（write 留畀設計師）
- ❌ 做設計決策（例如「應該改 layout」）
- ❌ 代表 design team approve

---

## Step 8：擴展

**⏱ PoC 成功後**

1. **自動 sync index**：Figma webhook / 定期 script 更新 metadata
2. **Jira 雙向 link**：Jira ticket 自動帶 `figma_url` field
3. **Vector search**：index + Confluence design spec 語意搜尋
4. **PRD cross-check**：PM 寫 PRD 時 Hermes 自動 call UIUX Design Agent 做 gap analysis
5. **開正式 repo**：若 PoC 在 Melessa repo，搬 agent 專用檔案至 `HKTV-UIUX-Design-Agent`；skills 真源留 Melessa / UIUX-Skills

---

## 附錄 A：Repo 策略與 PoC 路線

### PoC 路線（建議）

```
Phase 1（Melessa repo + Cursor）
  → 建 UIUX Design Agent 8 件套 + design-index + uiux-design-lookup skill
  → Cursor 試 Figma MCP + lookup 流程

Phase 2（PoC OK）
  → 開新 repo HKTV-UIUX-Design-Agent
  → 只搬 agent 專用檔案；skills 共用部分留 Melessa

Phase 3
  → Hermes 接 Slack + 新 repo → PM 試用
```

### Repo 儲存咩

| 放喺 repo | 唔放喺 repo |
|-----------|-------------|
| Agent 8 件套、design-index YAML、uiux-design-lookup skill、Slack schema、PoC log | Figma 設計稿本體、API keys、WhatsApp 對話、完整 Confluence/Jira 內容 |

---

## 附錄 B：Design Index YAML 範例

```yaml
id: checkout-v3
name: Checkout v3
platform:
  - app
  - web
status: approved          # approved | wip | deprecated
figma:
  file_key: F0tjdruLjJTfWgmTeZKBnw
  node_id: "12345:67890"
  url: https://www.figma.com/design/...
jira: HKTV-1234
confluence: https://...
owner: "@designer"
keywords:
  - checkout
  - 結帳
  - payment
last_verified: 2026-08-15
```

YAML 係純文字設定檔，可用 Cursor / VS Code 編輯；push 上 GitHub 後可在 repo 網頁直接查看。

---

## 附錄 C：常見陷阱

| 陷阱 | 後果 |
|------|------|
| 用 Cursor 做 production bot | Cursor 唔係 always-on Slack listener |
| 一次 index 晒所有 Figma | 維護成本高、metadata 快速過期 |
| 冇 confidence / escalate | PM 將 WIP 當 final，或 trust 錯答案 |
| 跳過 Slack 協議 | PM agent 唔知點整合回 WhatsApp |
| 冇 repo 真源 | Index 散喺 Sheet / Confluence / Slack，越用越亂 |
| Skills 同 agent config 放散 | 換機、onboarding 困難 |

### 預期效果（正式上線後）

| 指標 | 現狀 | 目標 |
|------|------|------|
| PM 等設計師回覆 | 數小時～1 天 | 秒級（lookup） |
| 設計師被 interrupt | 高 | 降 60–80% |
| 「搵唔到 design」 | 常見 | 罕見（有 index） |
| 設計決策準確性 | 100%（人手） | AI 初稿 + 設計師 confirm |

---

*本文件由 UIUX Design Agent 規劃對話整理而成，供 HKTVmall PM / UIUX / Hermes team 內部參考。*
