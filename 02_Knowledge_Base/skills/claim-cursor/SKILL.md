---
name: claim-cursor
description: >-
  Downloads Cursor subscription billing receipts via the built-in browser, saves
  them into the HKTVmall iCloud Expense folder, and checks/guides Hang Seng
  enJoy Card e-statement for company claim. Use when the user says 下載 cursor
  receipt、download Cursor receipt、Cursor 發票／收據、claim Cursor、Enjoy Card
  e-statement／estatement、恒生結單，or similar.
---

# Claim Cursor

每月下載 Cursor subscription receipt，並核對恒生 enJoy Card e-statement，存入 iCloud Expense，方便向公司 claim。

## 載入時機（必遵守）

命中下列**任一**情況時，必須載入並依本 skill 執行：
- 下載／download Cursor receipt／收據／發票
- claim Cursor、把 Cursor receipt 存到 Expense
- Enjoy Card／恒生 e-statement／estatement／信用卡結單（配合 Cursor claim）
- 類似「幫我攞上個月 Cursor 單據」的說法

## 常數

| 項目 | 值 |
| --- | --- |
| Billing URL | `https://cursor.com/dashboard/billing` |
| Hang Seng e-Statement | `https://www.hangseng.com/zh-hk/online/e-services/e-statement-e-advice/#/cards`（需已登入 e-Banking） |
| Expense base | `/Users/mchu/Library/Mobile Documents/com~apple~CloudDocs/HKTVmall/Document/Expense` |
| Downloads | `~/Downloads`（通常 `/Users/mchu/Downloads`） |
| 信用卡 | 恒生 **enJoy Visa白金卡**（結單列常見 `ENJOY VISA PLATINUM`） |
## 目標月份

1. **預設**：上個月（相對「今天」）
   - 今日 8 月 2026 → 目標 **2026-07**
   - 今日 1 月 2027 → 目標 **2026-12**
2. **例外**：使用者指明月份／年月則用指定值（可解析「7 月」「July 2026」「2026-07」「上個月」等）
3. 算出目標後，同時準備：
   - **UI 標籤**：英文全月名 + 四位年，例如 `July 2026`（Invoices 下拉／按鈕用）
   - **Folder 名**：見下一節

## Expense 資料夾命名（必遵守）

- 實際路徑字元是 **冒號 `:`**，不是斜線 `/`
- Finder 會把 `7:26` **顯示成** `7/26`；使用者口中的「7/26」= 磁碟上的 `7:26`
- 格式：`{M}:{YY}` — 月**不補零**；年為兩位
  - 2026-07 → `7:26`
  - 2027-01 → `1:27`
  - 2023-10 → `10:23`
- **禁止**建成巢狀路徑 `Expense/7/26/`（`7` 內再 `26`）
- 對齊現有慣例：`5:26`、`6:26`、`7:26`、`10:23`、`12:21` 等
- 資料夾已存在 → 直接放入；不存在 → 用單一資料夾名 `mkdir`（例如 `…/Expense/7:26`）

## 工具與限制

- **必須**用 `cursor-ide-browser`（navigate / tabs / snapshot / click / scroll / lock / unlock）
- 無 Browser MCP：停止，請使用者開 **Settings → Tools & MCP → Connect to Browser → Browser Tab**，開新對話後重試
- 長操作：`navigate` → `lock` → 操作 → 全部完成後 `unlock`
- **不要**自動化登入／輸入密碼
- 不要用 Cloud Agent 當主流程（需本機登入態 + iCloud 寫入）

## 執行檢查清單

複製並追蹤：

```
Progress:
- [ ] 解析目標月 → UI 標籤 + folder `M:YY` + 應下載之 enJoy 結單日期
- [ ] Browser 可用；開 billing；lock
- [ ] 已登入且看得到 Invoices
- [ ] Invoices 選目標月；確認有 Paid 列
- [ ] View → Stripe → Download receipt
- [ ] PDF 落入 Downloads
- [ ] 存入 Expense/{M:YY}/（同名則加 -2 後綴）
- [ ] 檢查同 folder 是否已有 e-statement（pdf/jpg 等）
- [ ] 若無：引導下載正確期數（勿重複催促若已有）
- [ ] unlock；回報路徑與金額／結單狀態
```
## 流程

### 1. 解析月份與路徑

```
folder_name = f"{month}:{year % 100}"   # e.g. 7:26
dest_dir    = f"{Expense base}/{folder_name}"
ui_label    = f"{EnglishMonth} {YYYY}"  # e.g. July 2026
# enJoy 結單期 = claim 月的「下一個月」約 13 日 → 見 §6a
hangseng_stmt_label = f"13-{stmt_m:02d}-{stmt_y}"  # e.g. July claim → 13-08-2026
```

### 2. 開 Billing

1. `browser_navigate` → Billing URL（使用者要求看得到瀏覽器時可 `position: "active"`）
2. `browser_lock`
3. snapshot：需有 **Billing & Invoices**／**Invoices** 區塊
4. 未登入或沒有 Invoices：`unlock`，請使用者在 Browser Tab 登入後回覆「已登入」，再繼續

### 3. 選月份並 View

1. 捲到 **Invoices**
2. 點月份下拉／按鈕，選與 `ui_label` 相符的項目（例如 `July 2026`）
3. 確認表格有列（Date UTC、Status Paid、Amount、**View**）
4. **該月無發票**：停止並回報；**不建**空 folder（除非使用者明確要求只建 folder）
5. **同月多筆**：對每一列的 **View** 重複步驟 4–5，receipt 都放入同一 `M:YY`
6. 點 **View**（常以 `_blank` 開 Stripe 新分頁）

### 4. Download receipt

1. `browser_tabs` list → select 標題含 `Invoice`／`invoice.stripe.com` 的 tab
2. 點 **Download receipt**（不要只下載 invoice，除非使用者只要 invoice）
3. 等下載完成（頁面可能顯示 Preparing to download receipt）
4. 在 `~/Downloads` 找最新相關 PDF（常見 `Receipt-*.pdf`）；以修改時間剛產生者為準

### 5. 存到 Expense

1. `mkdir -p` **只針對** `…/Expense/{M:YY}`（單一資料夾名含冒號）
2. 將 PDF **複製或移動**到 `dest_dir`
3. 若目標已有同名檔：改存為 `原名-2.pdf`（再撞則 `-3`…），**不要覆蓋**既有 claim 檔
4. 可用 Python/`/bin/mv`/`/bin/cp`；刪除錯誤巢狀資料夾時避免依賴會改寫 `rm` 的 alias

### 6. enJoy Card e-statement（claim 必核）

恒生**不會**把信用卡結單 PDF 寄到 Gmail（只有「有新結單」提示）；須從 e-Banking 下載。Browser Tab 對恒生 popup／blob PDF **常無法自動存檔**，因此本步以「檢查 + 引導」為主，不強制自動化下載成功。

#### 6a. 應下載哪一期（含 Cursor 扣款的那期）

Cursor 多在該月下旬扣款（例如 **29 Jul**）。恒生 enJoy 結單日期多為每月約 **13 日**；**下旬扣款會出現在「下一個月 13 日」那期**。

```
# 目標 claim 月 = Cursor 發票月 = (Y, M)   e.g. 2026-07
# 結單月 = 下一個月
stmt_y, stmt_m = (Y, M+1) if M < 12 else (Y+1, 1)
hangseng_stmt_label ≈ f"13-{stmt_m:02d}-{stmt_y}"   # e.g. 13-08-2026
```

例子：

| Cursor／claim 月 | Folder | 應下載的結單列日期 |
| --- | --- | --- |
| 2026-07 | `7:26` | **13-08-2026** |
| 2026-06 | `6:26` | **13-07-2026** |
| 2026-12 | `12:26` | **13-01-2027** |

若 Stripe receipt 上可見實際扣款日，以「扣款日落在哪一期結單週期」為準（通常仍是下一個月約 13 日那列）。

#### 6b. 檢查 Expense folder（有就不要催）

在 `dest_dir`（`Expense/{M:YY}/`）列出檔案。若**已有** e-statement，則：

- **不要**再提示／引導下載
- 回報：已找到的檔名與路徑

視為已有的檔名／副檔名（大小寫不拘），符合**任一**即可：

- 副檔名：`.pdf` / `.jpg` / `.jpeg` / `.png`
- 且檔名含：`estatement`、`e-statement`、`e_statement`、`statement`（例如 `Jun eStatement.pdf`、`Jul eStatement.pdf`、`eStatement.jpg`、`eStatementFile_….pdf`）

**排除**：`Receipt*`、`Cursor*`、`Invoice*`、`S-20*` 等明顯非信用卡結單檔（勿把 Cursor receipt 當成 e-statement）。

#### 6c. 若沒有 → 引導下載（繁體中文）

1. 明確告訴使用者要下載的結單：**`13-MM-YYYY`（ENJOY VISA PLATINUM）**，並一句解釋：因 Cursor 在 claim 月下旬扣款，該筆在此期結單。
2. 建議存檔名：`{英文月縮寫} eStatement.pdf`（對齊現有 `Jun eStatement.pdf`），放入同一 `Expense/{M:YY}/`。
3. 步驟指引：
   - 登入恒生個人 e-Banking（Browser Tab 可先開到 e-Statement URL；未登入則請使用者登入後回覆）
   - **e-Statement / e-Advice** → **信用卡** 分頁
   - 戶口選 **enJoy Visa白金卡**
   - 在列表找到日期 **`13-MM-YYYY`** → 按 **下載**
   - 若彈窗／PDF 被擋：允許 `hangseng.com` 彈出視窗後再按一次；手動儲存到 `dest_dir`
4. 自動化：可嘗試開頁、選卡、點對應 **下載**；若無法把 PDF 寫入本機，**停止自動重試**，改為上述引導，等使用者放好後可再幫核對 folder。
5. 使用者表示已放入後：再跑一次 6b 確認；仍無則簡短提示檔名建議，不要無限循環。

### 7. 回報（繁體中文）

回報至少包含：
- 目標月份（例如 2026-07）
- Folder 顯示名（`7/26`）與實際資料夾名（`7:26`）
- Cursor receipt 完整路徑與檔名；金額、invoice #、付款日（若可見）
- enJoy e-statement：**已存在（檔名）** 或 **待下載（應下載 `13-MM-YYYY`）**

## 失敗速查

| 情況 | 處理 |
| --- | --- |
| 無 cursor-ide-browser | 請開 Browser Tab；停止 |
| 未登入 Cursor／恒生 | unlock → 請使用者登入 → 再續 |
| 該月無發票 | 回報；不建空 folder |
| View 開了但找不到 Download receipt | snapshot 確認；可試 Download invoice 並註明差異後再問使用者 |
| PDF 未出現在 Downloads | 等數秒再列目錄；仍無則請使用者確認瀏覽器下載權限 |
| 恒生 blob／popup 無法自動存 PDF | 引導手動下載正確期數；folder 已有結單則不催 |
| folder 已有 e-statement | 跳過下載引導 |

## 靜態例子（驗證用）

| 情境 | 目標月 | Folder | enJoy 結單期 |
| --- | --- | --- | --- |
| 今日 2026-08，未指明 | 2026-07 | `7:26` | **13-08-2026** |
| 今日 2027-01，未指明 | 2026-12 | `12:26` | **13-01-2027** |
| 使用者指明 2027 年 1 月 | 2027-01 | `1:27` | **13-02-2027** |
| `7:26` 已有 `Jul eStatement.pdf` | — | — | **不提示下載** |
