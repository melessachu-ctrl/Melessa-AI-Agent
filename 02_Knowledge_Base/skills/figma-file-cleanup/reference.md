# Figma File Cleanup — 參考與模板

本檔由 [SKILL.md](SKILL.md) 單層連結；請勿再嵌套多層 reference。

---

## 1. 輸入參數表單（可複製填寫）

```
Target File URL：        [必填，Figma 連結；建議含 node-id 或另填 Node ID]
Target Node ID：         [選填，例 3003:4978；URL 內 3003-4978 請轉為冒號]
Design System Mode：     [必填：library-first | hybrid | local-fallback]
Design System File URL： [必填：DS 檔／庫連結；無 DS 時須使用者明文同意後填 none]
Token Policy：           [必填：no-local-token | allow-local-alias]
Component Policy：       [必填：reuse-first | allow-new-component]
Visual Regression：      [必填：strict-no-visual-change]
Rename Scope：           [必填：top-level-only | core-sections | full-depth]
Deliverable Lang：       [選填，預設 zh-HK]
```

**`design_system_file_url = none` 時**：於本表末加一行聲明：`使用者已明文確認無 Design System 檔可對齊。` 並將 `Design System Mode` 改為 `local-fallback`、`Component Policy` 改為 `allow-new-component`（或註明已與使用者確認之合意值）。

---

## 2. 提交資料夾結構（範例）

```
[SOP] Figma-Refactor-[FileKey]-[NodeId]-[yyyyMMdd]/
├── 01-baseline-screenshots/     # Phase A
├── 02-batch-updates/             # Phase C 各批次前後對比（建議子資料夾 batch-01 …）
├── 03-docs/
│   ├── changes.md
│   ├── mapping.csv
│   └── verification.md
└── 04-blockers.md
```

---

## 3. `mapping.csv` 欄位

第一列標頭（UTF-8）：

```csv
old_name,old_id,new_name,new_id,note
```

- `note`：例如 `alias`、`library-instance`、`blocked-by-permission`。

---

## 4. 模板：`03-docs/changes.md`

```markdown
# 變更清單（What changed）

## 元資料
- Target File URL：
- Target Node ID：
- Design System File URL：（或 none + 使用者同意聲明）
- 執行日期：
- 語言：zh-HK（或自填）

## 變更摘要
（條列；每項盡量附節點 ID 或頁名）

1. …
2. …

## 與 Design System 對齊
- 已套用之庫元件／token：
- 未對齊項目（連結至 blockers）：

## 假設與限制
- …
```

---

## 5. 模板：`03-docs/verification.md`

```markdown
# 驗證清單

## 視覺回歸（strict-no-visual-change）
- [ ] 全頁改前截圖路徑：
- [ ] 全頁改後截圖路徑：
- [ ] 差異說明（允許 0–1px 文本重排否？）：
- [ ] 判定：通過 / 未通過

## 結構與命名
- layoutMode=NONE 治理前比例：___% → 後：___%（目標：___）
- 命名合規抽查（範圍與樣本）：
- 元件實例化覆蓋（說明）：

## 附件索引
- 01-baseline-screenshots/ …
- 02-batch-updates/ …
```

---

## 6. 模板：`04-blockers.md`

```markdown
# 阻塞清單

| ID | 描述 | 原因 | 所需資源／決策 | 狀態 |
|----|------|------|------------------|------|
| B1 | … | … | … | open |
```

若無阻塞，仍保留檔案並寫：`無阻塞項目。`

---

## 7. 命名規範速查

| 層級 | 前綴範例 |
|------|----------|
| 頁面 | `PDP/Page/…` |
| 版面 | `PDP/Layout/…` |
| 區塊 | `PDP/Section/…` |
| 元件 | `PDP/Component/…` |

禁用於最終名稱：`Frame 123`、`Group 11`、`Copy`。

---

## 8. 風險與度量（細則）

- **strict-no-visual-change**：任何非預期像素差異、陰影／圓角／填色變化皆須列為驗證未通過或阻塞，除非使用者書面覆核。
- **批次**：每批變更應可在 02-batch-updates 中以「批前／批後」成對還原敘事。
- **權限**：無法啟用某 published component 時，寫入 blockers 並暫停依賴該元件之替換。
- **建議指標**（於 verification.md 填數值即可）：
  - `layoutMode=NONE` 節點數／總節點數或目標區內比例；
  - 以實例替換之重複區塊數；
  - 命名抽查合規率；
  - 回歸輪次中發現之可見缺陷筆數。

---

## 9. 輸出物清單範本（核銷用）

- [ ] `changes.md`
- [ ] `mapping.csv`（含表頭）
- [ ] `verification.md`（含截圖路徑與通過判定）
- [ ] `04-blockers.md`
