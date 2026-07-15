---
name: hktvmall-target-customers
description: HKTVmall（香港網上購物平台）目標客群與零售 UX 心智模型。提供核心 segments、行為/痛點、以及對 UIUX（資訊密度、促銷階層、搜尋/推薦、信任與可解釋性）的設計含意與檢核。Use when designing/reviewing HKTVmall UI/UX, discussing target customers/目標客群/segments, promotion-driven retail UX, recommendation modules, search-to-cart, conversion/basket size, or zh-HK e-commerce microcopy.
---

# HKTVmall Target Customers（目標客群）— UIUX 使用版

## 何時載入

在 **uiux-design-studio** 被呼叫，且任務屬 **HKTVmall 相關 UI/UX 工作**時，**必須 Read 本 skill**（觸發條件見 `uiux-design-studio` 之「HKTVmall 觸發詞」）。與 `ricky-design-guideline` 通常同時載入：本 skill 約束客群／KPI／零售 UX 取捨，後者約束設計原則。

## 快速使用（給 uiux-design-studio）

在做 HKTVmall 相關設計／評審時，先把產品視為「香港人的日常生活一站式購物平台」（效率型零售 UX），並用下列假設做 routing 與決策：

### 核心定位
- **不是**：精品/極簡/高端 premium 體驗導向
- **是**：高資訊密度、促銷驅動、快速決策的「香港 discount retail UX」

### 主要目標客群（Segments）
- **A 家庭主婦 / 家庭採購者（最大核心）**
  - **需求**：買餸、日用品補貨、bulk buy、母嬰、重貨（廁紙/洗衣液）
  - **痛點**：忙、唔想搬重物、唔想排隊、想一次買齊、價格敏感
  - **UX 含意**：資訊密度可以高；以「快啲搵到貨」為首要；價格/優惠層級要清楚且突出
- **B 上班族（第二核心）**
  - **情境**：午休/通勤/深夜下單；低耐性、高 mobile usage
  - **重視**：搜尋效率、送貨可靠、優惠、推薦相關性、快速 repeat order
  - **UX 含意**：Search 優先級極高；推薦模組可多，但要更「準」與「可解釋」
- **C 價格敏感型消費者**
  - **行為**：比價、等優惠、搶 coupon、看 cashback、比運費
  - **UX 含意**：促銷資訊密度高是合理的 conversion driver；但要避免把「可用優惠」藏起來
- **D 中年 / 非 tech-savvy 用戶**
  - **UX 含意**：可讀性、明確操作回饋、可預期流程、降低理解成本（尤其結帳/配送/優惠券）

### 推薦（Recommendation）使用原則
- **存在合理性**：大量泛用搜尋詞（例：洗頭水、咖啡、紙巾）＋品牌忠誠不一定高 → 推薦可導向高轉換/回購
- **最大風險**：用戶唔知「點解推薦」→ 認知為廣告/亂推
- **接受條件（滿足其一即可）**
  - **明顯相關**：與 keyword/品類高度一致
  - **有理由**：熱門/最多人買/回購率高/你可能喜歡/與關鍵字相關品牌
  - **有利益**：品牌優惠、coupon、combo deal（香港用戶對「優惠理由」敏感）

### 產品 KPI（用於取捨與驗收）
- **優先 optimize**：Conversion rate、Basket size、Repeat purchase、Search-to-cart rate、Promotion CTR、DAU
- **不以**：漂亮/簡潔/premium feeling 作為第一優先（除非不影響上述 KPI）

## 產出要求（uiux-design-studio 輸出格式約束）

當你提出 UI 方案、或評審設計時，請至少包含：
- **這個決策對應哪個 segment 的痛點/情境**（A/B/C/D）
- **你在優化哪個 KPI**（至少 1 個）
- **資訊密度/促銷層級如何不「亂」**：用層級、群組、排序、可掃描性說清楚
- **推薦模組若出現**：提供「可解釋理由」的文案/標籤（zh-HK）與 fallback（例如無足夠信心時不顯示）

## 原文參考
- 完整原文收錄於 `ANALYSIS.md`（請保持原文不隨意改寫；若要更新，新增「版本/日期」並保留變更記錄）。

