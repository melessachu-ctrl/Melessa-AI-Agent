# Session｜2026-09-01｜UIUX Design Agent 規劃 ＋ 實施手冊

## 做了甚麼

### 諮詢與架構（Ask mode → Agent mode）

- 分析 PM team **Hermes Agent** 痛點：PM 查 Figma design 需人手找 UIUX designer
- 建議 **UIUX Design Agent** 作 Hermes 同級 peer agent（WhatsApp → PM Hermes → Slack → UIUX Design Agent）
- 技術分工：**Hermes** = production｜**Cursor** = skills PoC lab｜**Repo** = agent 8 件套 + design-index
- 三層做法：Design Index → Figma MCP read agent → 語意搜尋（中長期）

### 實施手冊交付

- 建立 8 步實施指南（Step 0–8 + 附錄）
- 初版 PDF/HTML → 改為 **只保留 `.md`**（Cursor 可直接閱讀）
- 刪除 `.tmp-pdp-assets/` scratch 圖片
- 統一命名：**Design Agent → UIUX Design Agent**
  - 檔案：`UIUX_Design_Agent_Implementation_8_Steps.md`
  - Slack：`#agent-uiux-design`、`@uiux-design-agent`
  - Folder：`03_Agents/UIUX_Design_Agent/`
  - Repo（正式）：`HKTV-UIUX-Design-Agent`
  - Skill：`uiux-design-lookup/SKILL.md`

### Git

- PR #5 merge：首版手冊（後刪 PDF/HTML）
- PR #6 merge：cleanup tmp assets
- PR #7 merge：rename UIUX Design Agent

## 未完成甚麼

- [ ] Step 0：同 Hermes PM team 對齊 inter-agent Slack schema
- [ ] Step 1：盤點 PM top 10 設計查詢
- [ ] Step 2：`design-index/` 首批 5–10 個 YAML
- [ ] Step 3：Cursor PoC（Figma MCP + `uiux-design-lookup` skill）
- [ ] `03_Agents/UIUX_Design_Agent/` 8 件套尚未建立

## 下次由哪裡開始

1. **Melessa repo PoC**：建 `03_Agents/UIUX_Design_Agent/` 8 件套骨架 + `design-index/` 第一個 feature（例如 Checkout 或 PDP）
2. 用 Cursor 試 3 条 PM 真實問題（参照手冊 Step 3）
3. 同 PM team 確認 Hermes 是否支援 MCP、Slack channel 命名

## 參考文件

- `01_Action_Center/outputs/docs/UIUX_Design_Agent_Implementation_8_Steps.md`

## 今日學到

- Cursor **無法預覽 PDF**（Binary file not supported）→ 手冊用 `.md` 較實際
- Cloud agent 建檔在本機 Mac 需 **`git pull origin main`** 先 sync
- UIUX Design Agent 定位係 **read-only lookup + escalate**，唔取代設計師決策

## 反思

- 做得好：由 Ask（架構諮詢）順到 deliverable（8 步手冊）同命名統一，PM/UIUX/Hermes 可共用
- 可改進：PoC 仍未動手；下次 session 應直接做 Step 2–3 最小可行（1 個 design-index + 1 次 Figma MCP 試跑）
