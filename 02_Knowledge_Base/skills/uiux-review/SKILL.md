---
name: uiux-review
description: "Standardized UI/UX review SOP for finished designs (screenshots, Figma, prototypes, code, live URLs). Use when the user asks for a UIUX review, design critique, heuristic evaluation, a11y review, accessibility check, usability check, design audit, design QA, review screen / page / component / Figma / prototype / live URL, or says 評審 / 設計評審 / 走查 / 檢查 UI / 檢查 UX / 易用性檢查 / 無障礙檢查 / critique my design / review this UI. Runs a 7-step SOP (Intake → Reviewer Lens → Heuristic Pass → Walkthrough → Strengths → Findings → Anti-nitpick + AC) anchored on `ui-ux-pro-max` Quick Reference, with a default Reviewer Lens of a 50+ household shopper. Outputs in 繁體中文."
---

# UIUX Review SOP

這份 skill 把「為已完成的 UI/UX 設計做評審」標準化。`uiux-design-studio` 的 **UIUX Review（Critic / QA）** 角色每次評審都依本 SOP 產出。

## 使用時機

- 已有一份完成或接近完成的設計（screenshot / Figma frame / prototype / live URL / front-end code），需要被檢視
- 需要明確指出「Must / Should / Nice / Keep」與**可落地的改善方案**
- 需要從特定族群視角（不只一般使用者）評估易用性

## 不適用時機

- 還在 0→1 探索／需求未明（請改走 `uiux-design-studio` 的 Research / Designer）
- 純 UI 視覺改版方向討論（請走 Designer）
- Design System 補洞／Figma 檔案治理（請走 `figma-file-cleanup` 或 DS Owner）

## 必載技能（執行前先讀）

1. **必讀**：`~/.cursor/skills/ui-ux-pro-max/SKILL.md` —— Heuristic Pass 直接對齊它的 Quick Reference §1–§10，本 skill 不複製條目
2. 評審對象是 **Figma URL／Figma 檔**：加讀 `~/.cursor/skills/figma-mcp-server-guide/SKILL.md`
3. 評審對象是 **前端 code**：加讀 `~/.cursor/skills/frontend-design/SKILL.md`

> 若沒讀上述技能就開始評審，視為違規 SOP。

## 預設 Reviewer Lens（評審視角）

每次評審以「代表使用者」角度做 cognitive walkthrough。預設 lens：

```
代表使用者：香港、50 歲以上、負責幫屋企買日用品的家庭採購者
科技熟練度：低～中（會用 WhatsApp、會 tap、不熟新手勢、不熟英文術語）
視覺/動作：可能有老花、tap 精度下降、閱讀速度慢
情境：在家或途中、單一明確任務（買一件特定產品 / 重訂之前買過的 / 找送貨資訊）
判斷準則：能否在 ≤3 步、不靠猜測、不需閱讀小字完成任務
不適合假設：熟英文術語、會用 long-press / swipe / 多指手勢、會主動探索 hidden menu
```

> 每次 intake 時可由使用者一句話覆寫（例如「這次改用大學生在校園 Wi-Fi 上的視角」）。覆寫後仍維持「明確一段話」格式，**不做 research-grade persona**。

## 7-step SOP

照此順序執行，不可跳步。每步都有對應輸出。

### Step 1 — Intake（最短 4 題）

若使用者已提供，跳過對應題；缺哪題只問哪題。

1. **評審對象**：screenshot / Figma URL / live URL / code / prototype（哪一個或哪幾個）
2. **目標使用者**：是否沿用預設 Reviewer Lens？要覆寫的話一句話覆寫
3. **平台與情境**：Web / iOS / Android / 桌面；最常見的 1–2 個任務情境
4. **評審重點**：usability / a11y / 視覺一致性 / 內容語氣 / 全部（預設「全部」）

### Step 2 — Reviewer Lens 確認

把當次採用的 lens 用一段話寫出來（含族群、科技熟練度、視覺/動作、情境、判斷準則）。**這段話會直接決定 Step 4 Walkthrough 的視角**。

### Step 3 — Heuristic Pass

對齊 `ui-ux-pro-max` Quick Reference 的 10 大類，逐類掃描：

| # | 類別 | 對應 pro-max 章節 |
| --- | --- | --- |
| 1 | Accessibility | §1 |
| 2 | Touch & Interaction | §2 |
| 3 | Performance / 第一印象 | §3 |
| 4 | Style Selection / 視覺一致性 | §4 |
| 5 | Layout & Responsive | §5 |
| 6 | Typography & Color | §6 |
| 7 | Animation | §7 |
| 8 | Forms & Feedback | §8 |
| 9 | Navigation | §9 |
| 10 | Charts & Data（如有） | §10 |

規則：

- **沒發現問題的類別直接略過**，不要為了湊數寫「OK」（AC 區再做總結）
- 每條發現必須對應 pro-max 的某條 rule key（例如 `color-contrast`、`touch-target-size`）
- 無對應 rule key、又無法清楚說明 user impact 的，**不要寫進來**

### Step 4 — Walkthrough Pass

用 Step 2 的 Reviewer Lens 第一人稱走 1–2 條關鍵任務，每步用「我看到 X，以為 Y，嘗試做 Z，結果 W」格式標出 friction。

範例：

```
任務：重訂上次買過的廁紙
1. 我打開 app，看到首頁有「最新優惠」大 banner — 我以為要買日用品要先入優惠頁，猜了一下
2. 我找「我嘅訂單」，但底部 4 個 icon 全是英文，我看不懂哪個是「我」
3. 我 tap 個人頭像 icon，跳去登入頁，但我已經登入了 — 我以為自己 logout 咗，按返回
→ Friction：底部 nav 缺中文 label（對應 nav-label-icon）；個人 icon 行為不一致
```

### Step 5 — Strengths Pass（必做）

列出 **設計得好、應該保留** 的地方，每條附「為何有效」的具體理由（不是稱讚）。最少寫 2 條（除非設計真的整體不及格）。

格式：

- **[類別] 現況**：…
- **為何有效**：對 Reviewer Lens 的具體幫助
- **保留建議**：在後續迭代中不要動到的部分

### Step 6 — Findings 分類輸出

每條 finding 用以下固定格式：

```
### [Must / Should / Nice / Keep] — 一句話標題

- 現況：（看到什麼，引用具體位置 / 元件名 / 截圖座標）
- 對 Reviewer Lens 的影響：（會發生什麼後果，不是抽象問題）
- 改善方案：（可落地、具體；不是「建議改善」「考慮優化」這類空話）
- 對應原則：`pro-max:<rule-key>` 或 WCAG / HIG / MD 條目
```

四級分類定義：

| 級別 | 觸發條件 |
| --- | --- |
| **Must fix** | 對 Reviewer Lens 造成阻塞、a11y 違規（WCAG AA 不過）、資料/金錢損失風險、誤操作率明顯上升 |
| **Should fix** | 不阻塞但會明顯增加任務時間、混淆、信任降低；或一致性破口會擴散 |
| **Nice to have** | 體驗加分但不影響任務完成；或為未來擴充舖路 |
| **Keep** | 設計得好、應該保留（從 Step 5 帶入，附理由） |

### Step 7 — Anti-nitpick 守門 + Acceptance Criteria

**Anti-nitpick 守門**（對自己的 findings 做最後一遍篩選）：

- 每條 Must/Should 必須能回答：「這對 Reviewer Lens 的具體後果是什麼？」
- 不能只用「不夠好」「可以更…」這類詞彙
- 若某類別已符合一般 UIUX 標準，**明確寫「OK，無需改動」**，但只在 AC 區寫一行，不要當作 finding
- 同一個問題有多個面向時，合併成一條，不要拆成多條湊數

**Acceptance Criteria（可量化驗收清單）**：

從 Must + Should 反推可勾選的驗收條件，例如：

```
- [ ] 所有底部 nav icon 加中文 label，字級 ≥ 12pt（對應 Must #1）
- [ ] 主要 CTA 在 375px 寬下對比度 ≥ 4.5:1（對應 Must #2）
- [ ] 「重訂」入口從首頁可在 ≤ 2 tap 到達（對應 Should #1）
- [ ] 已符合一般標準（無需改動）：色彩語意、loading 狀態、錯誤訊息位置
```

## 輸出模板（最終交付，照抄填空）

```markdown
## UIUX Review — [評審對象一句話描述]

### Reviewer Lens
[一段話，5–7 行]

### Heuristic Pass（只列有發現的類別）
- §1 Accessibility：…
- §2 Touch & Interaction：…
- （沒發現的類別略過）

### Walkthrough（任務：[任務名]）
1. …
2. …
→ Friction：…

### Strengths（保留）
- **[類別] 現況**：…
  - 為何有效：…
  - 保留建議：…

### Findings

#### Must fix
##### M1 — [標題]
- 現況：…
- 對 Reviewer Lens 的影響：…
- 改善方案：…
- 對應原則：`pro-max:<rule-key>`

#### Should fix
##### S1 — [標題]
（同格式）

#### Nice to have
##### N1 — [標題]
（同格式）

#### Keep
（從 Strengths 帶入，每條一行摘要 + 引用 Strengths 編號）

### Acceptance Criteria
- [ ] …（對應 M1）
- [ ] …（對應 M2）
- [ ] 已符合一般標準（無需改動）：…
```

## 守則摘要

1. **不吹毛求疵**：符合一般 UIUX 標準的部分明確寫「OK，無需改動」，不湊數
2. **必須有原則對應**：每條 Must / Should 都要 cite `pro-max:<rule-key>` 或 WCAG / HIG / MD
3. **必須有具體方案**：禁止「建議優化」「考慮改善」這類空話
4. **必須講人話**：影響描述用 Reviewer Lens 第一人稱，不要寫成抽象體驗論述
5. **必須有 Strengths**：除非整體不及格，否則最少 2 條保留項
6. **語言**：繁體中文（除技術專有名詞）

## 與 `uiux-design-studio` 的關係

本 skill 是 `uiux-design-studio` Routing 表「只要評審」一列的**強制依賴**：

- 進入 UIUX Review 角色前，先讀本 SKILL.md
- 本 skill 的「Step 1–7 輸出」放進 Director Final Pack 的「Review Report」附錄
- 本 skill 的 Reviewer Lens 是該次評審的真實 source of truth，覆寫 Director 的一般假設
