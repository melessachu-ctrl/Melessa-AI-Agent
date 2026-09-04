---
description: "HKTVmall Figma 設計預設套用 HKTVmall Design System（跨專案）。當任務涉及 HKTVmall UI/UX 設計、Figma 出稿、Prototype、或 uiux-design-studio 時自動啟用。"
alwaysApply: true
---

# HKTVmall Figma Design System（預設）

## 觸發條件

下列**任一**成立時，視為 HKTVmall Figma 設計任務，**必須**套用本 Design System：

- 使用者要在 Figma 做 **HKTVmall** / **hktv** / **香港電視購物** 相關設計
- 呼叫 **`uiux-design-studio`** 且任務屬 HKTVmall UI/UX（設計、改版、評審、Prototype、DS 補洞）
- 任務已命中 `hktvmall-target-customers` 或 `ricky-design-guideline` 載入條件

## 預設 Design System（未指定時）

若使用者**未**指定其他 design system / library，一律使用：

| 欄位 | 值 |
| --- | --- |
| 名稱 | HKTVmall Design System |
| Figma URL | https://www.figma.com/design/F0tjdruLjJTfWgmTeZKBnw/Design-System?node-id=11445-16121 |
| `fileKey` | `F0tjdruLjJTfWgmTeZKBnw` |
| 預設入口 `nodeId` | `11445:16121` |

使用者若明確指定其他 DS，以使用者指定為準。

## 必做流程（Figma 相關工作）

1. **先搜尋、再新建**：呼叫 `search_design_system` 或 `use_figma` 盤點既有 token／元件／變體；**禁止**在未查庫前從零畫按鈕、表單、導覽等基礎元件。
2. **library-first**：版面與互動以 DS 元件組合為主；缺口才提案新增，並標註為 DS 變更。
3. **寫入前載入技能**：`use_figma` 前讀 `figma-use`；多區塊對齊 DS 時讀 `apply-design-system`；從設計稿實作時讀 `figma-implement-design`。
4. **建立／更新 DS 元件**：遵守 `uiux-design-studio`「DS Component Write Gate」— auto-layout、HKTVmall DS Text Style／typography token、leaf-only naming（對齊 `figma-file-cleanup`）；未過 Gate 不得交件。
5. **產出標註**：Director Final Pack／UI Spec 須列出採用的 DS 名稱、fileKey、以及主要引用元件／token（未知則標「待盤點」並說明阻塞）；有 DS 元件寫入時附 Write Gate 結果。

## 與其他技能聯動

HKTVmall Figma 設計任務須**同時**遵守：

- `hktvmall-target-customers`（客群／KPI）
- `ricky-design-guideline`（R1–R9）
- `uiux-design-studio`（若為編排流程；DS 元件寫入見「DS Component Write Gate」）
- `figma-file-cleanup`（DS 元件命名／auto-layout 規範）
