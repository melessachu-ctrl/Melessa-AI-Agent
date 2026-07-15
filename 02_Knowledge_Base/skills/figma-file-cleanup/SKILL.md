---
name: figma-file-cleanup
description: "在不改變視覺結果前提下治理歷史 Figma 檔：統一命名、版面結構、auto-layout、元件化與 Design System（token／component／style）對齊；產出變更清單、遷移映射、驗證清單與阻塞清單。Use when the user mentions Figma file cleanup、整理 Figma、Figma 重構、refactor Figma、命名規範、Design System 對齊、library-first、hybrid、local-fallback、token policy、strict-no-visual-change、layoutMode=NONE、或需依 SOP 批次治理舊檔。"
---

# Figma File Cleanup

## 平台現實（必讀）

- 本 Skill 是**單一對話內的流程編排**，不是常駐多 Agent；禁止跳過 Phase 直接大範圍改檔。
- 預設 `visual_regression_policy = strict-no-visual-change`：任何可見差異須先停下、說明並取得覆核後再繼續。
- 冗長模板與表單見 [reference.md](reference.md)（僅一層連結）。

## Skills 聯動（依階段強制載入）

| 時機 | 必須讀取的檔案 |
|------|----------------|
| Phase A／D：連線、授權、`get_design_context`、`get_metadata`、截圖比對 | `~/.cursor/skills/figma-mcp-server-guide/SKILL.md` |
| Phase C／任何 `use_figma` 寫入前 | `~/.cursor/plugins/cache/cursor-public/figma/3590366424deba5651026319b71b291d10004f1b/skills/figma-use/SKILL.md` |
| Phase C 批次 4：元件化、variants、從 DS 搜尋並組裝 | `~/.cursor/plugins/cache/cursor-public/figma/3590366424deba5651026319b71b291d10004f1b/skills/figma-generate-design/SKILL.md` |
| 可選：介面品質／a11y 檢核基準 | `~/.cursor/skills/ui-ux-pro-max/SKILL.md` |

**規則**：進入對應 Phase 的第一步即 `Read` 上表檔案；未完成讀取不得呼叫該 Phase 所需之 MCP／`use_figma`。

## Intake — 參數表單

與原始 SOP PDF 之差異：**`design_system_file_url` 為必填**（除非使用者明確聲明無 DS，見下）。

| 參數 | 必填 | 允許值／說明 |
|------|------|--------------|
| `target_file_url` | 是 | 目標檔 Figma URL；須含可定位之脈絡（必要時含 `node-id`） |
| `target_node_id` | 否 | 如 `3003:4978`（URL 中 `3003-4978` 轉為冒號） |
| `design_system_mode` | 是 | `library-first` \| `hybrid` \| `local-fallback` |
| `design_system_file_url` | **是** | DS 檔／庫之 Figma URL；無 DS 時僅當使用者**明文**聲明可填 `none` |
| `token_policy` | 是 | `no-local-token` \| `allow-local-alias` |
| `component_policy` | 是 | `reuse-first` \| `allow-new-component` |
| `visual_regression_policy` | 是 | 預設 `strict-no-visual-change` |
| `rename_scope` | 是 | `top-level-only` \| `core-sections` \| `full-depth` |
| `deliverable_lang` | 否 | 預設 `zh-HK` |

### 詢問規則（必須遵守）

1. **任一必填缺失** → 停止，逐項向使用者詢問；**不得**自行假設或填預設值後開工。
2. **`design_system_file_url`**：未提供連結時，必須詢問；僅當使用者**明確**表示「沒有 DS／不使用 Design System／no design system」時，可記為 `none`，並在 Phase B 策略與交付物 `changes.md`、`blockers.md` 標註「無 DS 來源，已徵得使用者同意」。
3. 若 `design_system_file_url = none`：**強制** `design_system_mode = local-fallback`、`component_policy = allow-new-component`；若使用者先前選了衝突值，必須回問並取得確認。
4. 參數齊備後，**整表回讀**給使用者確認一次，再進 Phase A。

## 執行流程（Phase A→D）

提交資料夾命名：`[SOP] Figma-Refactor-[FileKey]-[NodeId]-[yyyyMMdd]`（`NodeId` 無則用 `root`）。

### Phase A — 審計（不改動）

先讀 `figma-mcp-server-guide`，再執行審計。

```
Task Progress — Phase A
- [ ] 已讀 figma-mcp-server-guide
- [ ] 已拉取結構（get_metadata / get_design_context 等依 guide）
- [ ] 已記錄 layoutMode=NONE 節點
- [ ] 已記錄命名異常（Frame 123、Group 11、Copy 等）
- [ ] 已標註高頻重複元素（候選元件）
- [ ] 已盤點 token／style 是否 ad-hoc
- [ ] 已匯出全頁基線截圖 → 01-baseline-screenshots/
- [ ] （建議）關鍵 section 截圖
- [ ] 已產出審計報告（純文字）；確認無任何寫入／use_figma 變更
```

### Phase B — Design System 策略確認（不改動）

依 `design_system_mode`：

- `library-first`：優先使用指定 DS 之 token／元件。
- `hybrid`：優先庫，缺失時依策略局部 fallback。
- `local-fallback`：僅在庫缺失且已確認時建立本地。

依 `token_policy`：

- `no-local-token`：禁止建立本地 token。
- `allow-local-alias`：允許別名，**必須**全程記錄於遷移映射。

輸出：短策略文（會用哪些 DS 元件／token、缺口與 fallback）。若 `design_system_file_url = none`，開頭必須聲明無 DS 與使用者同意。

### Phase C — 結構治理（分批；每批前後截圖）

進入 Phase C 前**必須**讀 `figma-use`。**禁止**一次性改完整頁後才截圖。

```
Task Progress — Phase C（每批次重複：批前截圖 → 變更 → 批後截圖 → 通過再下一批）
- [ ] 批次 1：頁面骨架與主 section（低風險）→ 02-batch-updates/
- [ ] 批次 2：區塊內部容器 auto-layout
- [ ] 批次 3：命名規範化（依 rename_scope）
- [ ] 批次 4：元件化與 variants（進此批次前必讀 figma-generate-design，依其 search_design_system 等流程）
```

### Phase D — 驗證與交付

- 全頁改前／改後截圖對比；容差：允許 **0–1px** 等級之文本重排，其餘可見差異視為未通過（除非使用者書面覆核 `strict-no-visual-change`）。
- 產出：`03-docs/changes.md`、`03-docs/mapping.csv`、`03-docs/verification.md`、`04-blockers.md`（結構與欄位見 reference.md）。

```
Task Progress — Phase D
- [ ] 已讀 figma-mcp-server-guide（若需補截圖／比對）
- [ ] 驗證通過（含截圖與差異說明）
- [ ] 四份交付物已寫入約定路徑
```

## 命名規範（建議）

| 類型 | 範例 |
|------|------|
| 頁面 | `PDP/Page/Desktop` |
| 版面 | `PDP/Layout/MainContent` |
| 區塊 | `PDP/Section/FAQ` |
| 元件 | `PDP/Component/Pagination` |
| 變體 | 例：`State=Collapsed`；多狀態以 variant 屬性組合（勿用裸 `|` 分隔於節點名內） |

**禁止**作為最終名稱：`Frame 123`、`Group 11`、`Copy`。

## 驗收標準（DoD）

- [ ] 全頁 UI 與改前一致（截圖對比通過）
- [ ] 目標範圍內 `layoutMode=NONE` 達到預期治理比例（於 verification.md 註明度量）
- [ ] 命名達標（依 `rename_scope`）
- [ ] 復用處均為元件實例，非零散複製
- [ ] token 策略符合參數（`no-local-token` 時尤須嚴格）

## 風險與控管（摘要）

- 嚴守 `strict-no-visual-change`：可見差異先報告再動。
- 批次化與頻繁回歸，避免範圍失控。
- 開工前確認 DS 庫讀取權限與版本策略。
- 建議度量：`layoutMode=NONE` 比例、元件化覆蓋率、命名合規率、回歸缺陷數（於 verification.md 可列）。

## 輸出物（必須交付）

1. 變更清單（What changed）→ `changes.md`  
2. 遷移映射（Old Name/ID → New Name/ID）→ `mapping.csv`  
3. 驗證清單（含前後截圖）→ `verification.md`  
4. 阻塞清單（無法對齊 DS 之原因）→ `blockers.md`  

完整目錄結構、表單占位與 Markdown 模板見 [reference.md](reference.md)。
