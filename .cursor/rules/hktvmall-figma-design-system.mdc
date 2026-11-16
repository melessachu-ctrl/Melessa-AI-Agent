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
2. **library-first**：版面與互動以 DS 元件組合為主；能直接用 DS component／variant 就用 instance。
3. **元件化決策（DS 沒有可直接用的 component 時）**：
   - **重覆元素 → local component**：同一元素會在本檔／本 flow **重覆使用**，且 DS 沒有可直接套用的**整塊** component → 在**本工作檔**做成 **local component**，畫面只放 instance。Local component 是**組合殼**：內部**優先嵌套 DS component instance**（例如 Button、Badge、Icon、Input、List row 等），其餘自建層才綁 HKTVmall DS text／color token／primitive；**禁止**為了包一層 local 而把已有 DS Button／Badge 等拆成裸圖層重畫。這**不是**已發佈 DS 元件，**不**觸發「DS Component Write Gate」，除非使用者明確要求把該元件補進 Design System。
   - **整頁骨架重覆 → 整頁 component + section slot**：整頁 UI 會重覆使用，只是某些 section 的 state／內容不同 → **整頁做成 component**，相異 section 做成 **section slot**（可換內容／state 的區塊）。整頁／slot 內同樣優先用 DS component instance。勿與 Screen Token Bind Gate 的「Content SLOT」（demo 文案文字綁定）混淆。
   - **應進 DS 的缺口**：跨專案／應發佈的基礎元件缺口 → 才提案新增並標註為 DS 變更（另過 Write Gate）。
4. **寫入前載入技能**：`use_figma` 前讀 `figma-use`；多區塊對齊 DS 時讀 `apply-design-system`；從設計稿實作時讀 `figma-design-to-code`。
5. **建立／更新 DS 元件**：遵守 `uiux-design-studio`「DS Component Write Gate」— auto-layout、HKTVmall DS Text Style／typography token、leaf-only naming（對齊 `figma-file-cleanup`）；未過 Gate 不得交件。本檔 local component／整頁＋section slot **不**走本條，但仍須過 Screen Token Bind Gate（文字／色）。
6. **產出標註**：Director Final Pack／UI Spec 須列出採用的 DS 名稱、fileKey、以及主要引用元件／token（未知則標「待盤點」並說明阻塞）；有 DS 元件寫入時附 Write Gate 結果；本檔新建的 local component／整頁 component＋section slot（若有）須另列。

## 與其他技能聯動

HKTVmall Figma 設計任務須**同時**遵守：

- `hktvmall-target-customers`（客群／KPI）
- `ricky-design-guideline`（R1–R9）
- `uiux-design-studio`（若為編排流程；DS 元件寫入見「DS Component Write Gate」；畫面／local／整頁 slot 見「Screen Token Bind Gate」與元件化決策）
- `figma-file-cleanup`（DS 元件命名／auto-layout 規範）
