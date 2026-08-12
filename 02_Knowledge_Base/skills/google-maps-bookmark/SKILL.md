---
name: google-maps-bookmark
description: >-
  用 Cursor 內建瀏覽器（cursor-ide-browser）在 Google Maps 把地點存入指定 Saved list，並可在 list
  視圖為各地點加上 note（預設繁體中文名稱）。Use when the user asks to bookmark / save /
  收藏 / 加入 Google Maps list、為 Maps 景點加 note、或把文章／清單裡的地點存進 Maps。
---

# Google Maps Bookmark（存地點 + Note）

## 載入時機（必遵守）
命中下列**任一**情況時，必須載入並依本 skill 執行：
- 使用者要求把地點／景點 **save／bookmark／收藏／加入** Google Maps（或指定 list）
- 使用者要求為 Maps 已存地點 **加 note／備註／中文名稱**
- 使用者提供文章／連結／清單，並要求把其中地點存進 Maps

## 工具與限制
- **只用** `cursor-ide-browser`（navigate / snapshot / click / fill / press_key / cdp / lock）。
- **沒有** Google Maps API／Workspace MCP 可寫入 Saved lists；不要去找或假裝有 API。
- 長操作前：`browser_lock` → 做完再 `unlock`。
- UI 語言可能是英文（Save / Add note / Saved）；以 snapshot 的 `name`／`aria-label` 為準。

## 執行前檢查清單
複製並追蹤：

```
Progress:
- [ ] 確認已登入正確 Google 帳號
- [ ] 確認目標 list 名稱（使用者指定；未指定則先問）
- [ ] 整理待存清單（搜尋關鍵字 ↔ note）
- [ ] 逐一 Save 到 list
- [ ]（若需要）在 list 視圖加 note
- [ ] 抽查並回報
```

### 登入
1. 開 `https://www.google.com/maps`，檢查帳戶按鈕是否為使用者帳號。
2. 未登入／錯帳號：立刻 `unlock`，請使用者在瀏覽器登入後回覆「已登入」，再繼續。
3. **不要**嘗試自動化登入／輸入密碼。

### 目標 list
- 必須有明確 list 名稱（例如「東京」）。
- 未指定時先問一次；不要猜。
- 只改任務相關地點；**不要**改動 list 內其他既有 note／地點。

---

## A. Save 地點到 list（穩定流程）

對每個地點重複：

### A1. 開 place 頁
1. `browser_navigate` 到：
   `https://www.google.com/maps/search/{encodeURIComponent(query)}`
2. 等 place 就緒：有 `h1` 標題 + `Save` 按鈕。
3. 若仍在 `/maps/search/`：點最吻合的 `a[href*="/maps/place/"]`（優先精確名稱匹配），再等 Save。
4. 用 `h1` 確認是正確地點；錯了就換更準的 query（加城市／官方英文名），不要存錯。

### A2. Save → 選 list
**優先用 CDP 批次腳本**（見 [reference.md](reference.md) 的 `saveToList`），比逐一下 accessibility click 更穩。

手動等同步驟：
1. 點 `Save`（`aria-label`／`data-value`／按鈕文字為 Save）。
2. 等 `[role="menuitemradio"]` 選單出現。
3. 點文字包含**目標 list 名稱**的項目。
4. 成功訊號：按鈕變 Saved／出現 `Saved in {list}`／list 地點數 +1。

### A3. 失敗處理
| 情況 | 做法 |
| --- | --- |
| 找不到 Save | 再等／從搜尋結果點入 place；仍失敗則記「失敗」並跳下一個 |
| 找不到 list | snapshot 確認 list 名；確認已登入；不要新建 list（除非使用者要求） |
| 已在 list | 視為成功，繼續 |
| 誤存無關地點 | 從 list 移除該地點後再重存正確的 |

批次時：每存完一個就更新 todo／內部清單，避免重複或漏存。

---

## B. 加 Note（唯一穩定做法）

### 關鍵規則（必遵守）
1. **必須在 Saved list 本體視圖**加 note（頁面標題類似 `{list名} - Google Maps`，側欄列出該 list 所有 places）。
2. **禁止**依賴 place 詳情頁的 Add note／用 JS 設 `textarea.value` 當已儲存——那個路徑**經常不持久化**。
3. 填 note 用 `browser_fill`（不是純 CDP 賦值）。
4. 每個 note 填完後要 **blur 觸發存檔**：點下一個「Add note」、點另一個已有 Note 欄，或點無害空白處（**不要**點 list 標題，否則會進入重新命名）。

### B1. 進入 list 視圖
任選其一：
- Saved → Lists → 點目標 list
- 從已存 place 點 `Saved in {list}`／list 連結進入 list
- 若已知 list URL（含 `!11m2!2s…!3e3`），可直接 navigate

確認：側欄標題是目標 list，且能看到多個 place 列與「Add note」或已有 Note 欄。

### B2. 逐列加 note
對每個目標 place：
1. 找到該列的 `Add note`（或已有 `Note` textbox）。
2. 點 `Add note` 展開。
3. `browser_fill` 寫入 note 文字。
4. 立刻點下一個目標的 `Add note`（或下一個 note 欄）以 blur／存檔。
5. snapshot 確認該列 `Note` 的 `value` 已是目標文字。

### B3. Note 內容預設
- 使用者要「中文名稱／看得懂是哪裡」→ 用**繁體中文**常用地名（例如 Tokyo Tower → 東京鐵塔）。
- 使用者有指定 note 原文 → 用指定內容。
- 不要覆寫既有、與本次無關的 note。

### B4. 完成前抽查
- 所有本次目標列都有正確 note value。
- list 標題仍是原名（未被改成編輯中的字數顯示等）。
- 最後一個 note 已 blur 存檔。

---

## C. 建議整體順序

1. 從來源抽出地點 → 做成表格：`搜尋關鍵字 | 預期英文名 | note（繁中）`
2. 先全部 Save（流程 A）
3. 再開 list 一次做完所有 note（流程 B）——比「每存一個就在 place 頁加 note」快且穩
4. 用繁中回報結果表（成功／略過／失敗）

## 回報格式（簡潔）

```markdown
已存入「{list}」：N 個

| Maps 名稱 | Note | 狀態 |
| --- | --- | --- |
| Tokyo Tower | 東京鐵塔 | 成功 |
```

失敗項寫明原因（找不到地點／未登入／list 不存在等）。

## 詳細腳本
CDP `saveToList` 與常見 selector：見 [reference.md](reference.md)。
