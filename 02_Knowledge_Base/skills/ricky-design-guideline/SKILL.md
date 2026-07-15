---
name: ricky-design-guideline
description: HKTVmall App 設計原則（王語錄設計篇）。在 uiux-design-studio 流程中約束 Figma 設計、Prototype 與設計評審的決策。Use when designing HKTVmall UI/UX, generating Figma screens, building prototypes, reviewing designs, or when uiux-design-studio is invoked for design/prototype/review work. Also triggers on「Ricky Design Guideline」「王語錄」「HKTVmall 設計原則」.
---

# Ricky Design Guideline

HKTVmall App 設計原則（王語錄 · 設計篇 · 第二修訂版精要）。本 skill 為 **uiux-design-studio** 的專案設計約束層；不取代 `ui-ux-pro-max` / `uiux-review`，而是在其之上追加取捨準則。

## 何時載入

在 **uiux-design-studio** 被呼叫，且任務涉及以下任一項時，**必須 Read 本 skill**：

- Figma 設計出稿（新頁面、改版、元件）
- Prototype 製作或互動規格
- 設計評審（design / Figma / prototype / live URL）

## 核心原則（9 條）

### 1. 以顧客意圖為中心
- 每頁先釐清顧客的**第一意圖**（可能不只一個）。
- 區分**主動進入** vs **被導流進入**；後者需用機制喚起並放大需求。
- 區分**必備資訊**（不可漏、不可誤解）與**雜訊**（多餘圖形、多餘編排）。
- 用行為訊號優化不同「待辦任務」（例如搜尋背後的不同目的）。

### 2. 改版保守：位置與辨識不變
- 新舊設計對照時，**UI 元素、圖示、位置**原則上不變。
- 降低重新學習成本，保護既有操作習慣。

### 3. 選擇可見：不隱藏關鍵訊息
- 若「有這麼多選擇」本身就是核心訊息，**不要收合選項**。
- 例：品類模組、品牌模組應保持可見、可掃。

### 4. 文案極短：新控件必說明
- **全新** UI 控件須有文字說明，但**不超過半句**。
- 整體說明（介面或教學）一律精簡；多數人不會細讀，過長即等於沒寫。

### 5. 一屏盡覽：資訊密度優先
- 在**不嚴重影響可讀性、不分散對重點的注意力**前提下，每屏盡量承載更多資訊與功能區塊。
- 讓顧客**一眼**掌握我們提供的內容與能力，**首頁尤其如此**。

### 6. 模組邊界清楚
- 每個區塊／模組用**線框**或**強烈色對比**明確分隔。
- 確保所有顧客都能理解：畫面中的元素屬於同一組。

### 7. 下線與大改：用數據把關
- 棄用或大幅改動前，須有**現有使用數據**評估影響。
- 經驗法則：**超過 5% 顧客使用 → 不可動**。

### 8. 尊重五年老用戶的肌肉記憶
- 大量營收來自**使用同一套 UI/UX 逾五年**的忠誠顧客。
- 變更應**最小化干擾**其操作記憶。
- 例外：數據或回饋顯示現有流程已是**長期痛點**（長期習慣 vs 長期斥責）。

### 9. 分群思考影響：忠誠／輕度／新客
- 評估影響時區分：**忠誠客、輕度客、新客**。
- 三者在需求、商品認知、使用習慣與商業價值上皆不同，設計決策須分別考量。

## 在 uiux-design-studio 中的應用

### Design Director
- 在「決策原則」中至少引用本 skill 3 條以上，並標明對應編號（R1–R9）。
- 任何可能違反 R2（位置不變）、R7（>5% 不可動）、R8（肌肉記憶）的提案，須在 Final Pack「風險與待確認」明列。

### UX Researcher
- Persona / JTBD 須覆蓋 R9 三群：忠誠客、輕度客、新客。
- 區分主動進入 vs 被導流進入（R1）。

### UIUX Designer
- 版面決策對照 R1（意圖/雜訊）、R3（選擇可見）、R5（資訊密度）、R6（模組邊界）。
- 改版須做 Before/After 對照，標注哪些元素位置/圖示維持不變（R2）。
- 新控件 microcopy ≤ 半句（R4）。

### Prototype Creator
- 關鍵流須測試：被導流進入時需求是否被放大（R1）。
- 不為「簡潔」而收合應展開的選擇模組（R3）。

### UIUX Review
- Heuristic Pass 追加 **Ricky Pass**（見下方檢查清單）。
- Findings 中違反 R2/R7/R8 的項目預設為 **Must fix**（除非有數據證明長期痛點）。
- Findings 標注對應規則編號，格式：`ricky:R{n}`。

## Ricky Pass 檢查清單

設計出稿或評審時逐項勾選：

```
Ricky Pass:
- [ ] R1 已釐清本頁第一意圖；區分主動/被導流；剔除雜訊
- [ ] R2 改版元素位置、圖示與舊版一致（或已說明必要變更理由）
- [ ] R3 選擇豐富度為核心訊息時，未收合選項
- [ ] R4 新控件有 ≤ 半句說明；無冗長教學文案
- [ ] R5 資訊密度充分且首屏可一覽；可讀性未受損
- [ ] R6 各模組有明確邊界（線框或強對比）
- [ ] R7 棄用/大改功能已查使用數據；>5% 使用者功能未動
- [ ] R8 變更對五年老用戶肌肉記憶影響最小
- [ ] R9 已分別評估忠誠客、輕度客、新客影響
```

## 與其他 skill 的關係

| Skill | 關係 |
| --- | --- |
| `uiux-design-studio` | 編排層；本 skill 為其設計約束 |
| `ui-ux-pro-max` | 通用 UX/a11y 規範；本 skill 為 HKTVmall 取捨準則 |
| `uiux-review` | 評審 SOP；Ricky Pass 追加於 Heuristic Pass 之後 |
| `frontend-design` | 前端實作；須遵守 R2/R5/R6 |

## 一句話原則

以顧客意圖與分群為準，在可讀前提下提高資訊密度與模組清晰度；改版不動位置與圖示、不藏選擇、文案極短；大改與下線以數據為準，優先保護五年老用戶的操作記憶。
