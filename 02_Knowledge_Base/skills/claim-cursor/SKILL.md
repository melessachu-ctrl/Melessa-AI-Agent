---
name: claim-cursor
description: >-
  Runs the full Cursor company-claim pipeline (receipt download → Expense folder
  → enJoy e-statement check → gray-mask claim PDF). Also supports e-statement-only
  redact. Use when the user says 我要 claim cursor、幫我 claim cursor、claim Cursor、
  下載 cursor receipt、download Cursor receipt、Cursor 發票／收據、Enjoy Card
  e-statement／estatement、恒生結單、遮罩／處理／mask eStatement、redact statement，
  or similar.
---

# Claim Cursor

每月下載 Cursor subscription receipt，並核對恒生 enJoy Card e-statement，遮罩後存入 iCloud Expense，方便向公司 claim。

## 載入時機（必遵守）

命中下列**任一**情況時，必須載入並依本 skill 執行：
- **完整 claim（預設跑 §1–7）**：「我要 claim cursor」「幫我 claim cursor」「claim Cursor」「幫我 claim 上個月 Cursor」等（大小寫／空格不拘）
- 下載／download Cursor receipt／收據／發票；把 Cursor receipt 存到 Expense
- Enjoy Card／恒生 e-statement／estatement／信用卡結單（配合 Cursor claim）
- 遮罩／處理／mask／redact eStatement／結單；使用者提供 eStatement 路徑並要求處理
- 類似「幫我攞上個月 Cursor 單據」的說法

## 執行模式（必遵守）

### A. 完整 claim（§1 → §7）

觸發：「我要 claim cursor」「幫我 claim cursor」「claim Cursor」等**未**限定只做其中一步時。

1. **必須依序執行 §1 → §7**（含 receipt 下載、eStatement 遮罩、以及 §7 回報），不要只做一半就當完成。
2. 中途**卡關**時：立刻停下，用繁體中文清楚說明：
   - **已完成**到哪一步
   - **欠缺／卡住什麼**（一項一項列）
   - **請使用者做什麼**才能繼續（例如登入、下載哪一期結單、提供路徑）
3. 使用者補齊後，從卡住那步繼續，直到 §6d 產出遮罩 PDF 並完成 **§7 回報**，或再次卡關回報。

### B. 只處理 eStatement

觸發：使用者只提供結單路徑／只說 mask／遮罩／處理 eStatement。可跳過 §2–5；仍跑 §1（推月）+ §6b/6d + **§7 回報**。卡關時同樣回報欠缺什麼。

## 常數

| 項目 | 值 |
| --- | --- |
| Billing URL | `https://cursor.com/dashboard/billing` |
| Hang Seng e-Statement | `https://www.hangseng.com/zh-hk/online/e-services/e-statement-e-advice/#/cards`（需已登入 e-Banking） |
| Expense base | `/Users/mchu/Library/Mobile Documents/com~apple~CloudDocs/HKTVmall/Document/Expense` |
| Downloads | `~/Downloads`（通常 `/Users/mchu/Downloads`） |
| 信用卡 | 恒生 **enJoy Visa白金卡**（結單列常見 `ENJOY VISA PLATINUM`） |
| 遮罩灰 | RGB ≈ `(0.86, 0.87, 0.87)`（對齊 Jun 範本 Square fill） |
| 遮罩產出檔名 | `{英文月縮寫} eStatement Cursor.pdf`（例：`Jul eStatement Cursor.pdf`） |
| 遮罩實作 | 本機 `python3` + **PyMuPDF（`import fitz`）** |

## 目標月份

1. **預設**：上個月（相對「今天」）
   - 今日 8 月 2026 → 目標 **2026-07**
   - 今日 1 月 2027 → 目標 **2026-12**
2. **例外**：使用者指明月份／年月則用指定值（可解析「7 月」「July 2026」「2026-07」「上個月」等）
3. **只處理 eStatement 模式**：可從使用者路徑中的 folder `M:YY`、檔名月縮寫、或明確指定推得目標月；不強制重跑 Cursor billing
4. 算出目標後，同時準備：
   - **UI 標籤**：英文全月名 + 四位年，例如 `July 2026`（Invoices 下拉／按鈕用）
   - **Folder 名**、**英文月縮寫**（`Jan`…`Dec`，用於產出檔名）

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

- Receipt／恒生下載引導：**必須**用 `cursor-ide-browser`（navigate / tabs / snapshot / click / scroll / lock / unlock）
- 無 Browser MCP 且本次需要開 billing／恒生頁：停止，請使用者開 **Settings → Tools & MCP → Connect to Browser → Browser Tab**，開新對話後重試
- **只處理已提供／folder 內 eStatement 遮罩**：可不開 browser，直接用本機 Python
- 長操作：`navigate` → `lock` → 操作 → 全部完成後 `unlock`
- **不要**自動化登入／輸入密碼
- 不要用 Cloud Agent 當主流程（需本機登入態 + iCloud 寫入）

## 執行檢查清單

完整 claim 時複製並追蹤（卡關＝該項未勾且須回報「欠缺」）：

```
Progress:
- [ ] §1 解析目標月 → UI 標籤 + folder `M:YY` + 應下載之 enJoy 結單日期 + 月縮寫
- [ ] §2 Browser 可用；開 billing；lock
- [ ] §2 已登入且看得到 Invoices
- [ ] §3 Invoices 選目標月；確認有 Paid 列
- [ ] §4 View → Stripe → Download receipt
- [ ] §5 PDF 存入 Expense/{M:YY}/
- [ ] §6b 找到原始 eStatement（folder 或使用者提供）
- [ ] §6d 搜尋 CURSOR；產出遮罩 PDF；驗證通過
- [ ] unlock（若有 lock）；§7 回報
```

卡關回報範本（繁體中文，可精簡但欄位要齊）：

```
已完成：…
卡住步驟：§…
欠缺：…
請你：…（例如：把 13-08-2026 結單存成 Jul eStatement.pdf 放到 Expense/7:26/，或貼上路徑）
```

## 流程

### 1. 解析月份與路徑

```
folder_name = f"{month}:{year % 100}"   # e.g. 7:26
dest_dir    = f"{Expense base}/{folder_name}"
ui_label    = f"{EnglishMonth} {YYYY}"  # e.g. July 2026
mon_abbr    = f"{EnglishMonth[:3]}"     # e.g. Jul
# enJoy 結單期 = claim 月的「下一個月」約 13 日 → 見 §6a
hangseng_stmt_label = f"13-{stmt_m:02d}-{stmt_y}"  # e.g. July claim → 13-08-2026
masked_out  = f"{dest_dir}/{mon_abbr} eStatement Cursor.pdf"
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

恒生**不會**把信用卡結單 PDF 寄到 Gmail（只有「有新結單」提示）；須從 e-Banking 下載。Browser Tab 對恒生 popup／blob PDF **常無法自動存檔**，因此下載步以「檢查 + 引導」為主；**取得原始結單後必須跑 §6d 產出遮罩 PDF**。

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

#### 6b. 檢查 Expense folder／選定來源檔

在 `dest_dir`（`Expense/{M:YY}/`）列出檔案，或使用使用者**明確指定**的路徑。

**來源優先序：**

1. 使用者明確指定的 eStatement 路徑／檔案
2. 否則在 `dest_dir` 找「原始」e-statement（見下）

視為原始 e-statement（大小寫不拘），須同時符合：

- 副檔名：`.pdf`（遮罩流程需要可抽文字的 PDF；`.jpg`／`.png` 僅算「已下載」證據，仍須請使用者提供 PDF 才能跑 6d）
- 檔名含：`estatement`、`e-statement`、`e_statement`、`statement`（例如 `Jun eStatement.pdf`、`Jul eStatement.pdf`）

**排除（勿當來源）：**

- `Receipt*`、`Invoice*`、`S-20*`（claim form）
- 本 skill 遮罩產物：檔名符合 `* eStatement Cursor*.pdf`（含 `Cursor-2` 等）
- 檔名含 `Cursor` 且明顯是 Stripe receipt（例如 `Cursor Receipt-*.pdf`）

**多份**未排除的原始結單：選**修改時間最新**者，並在回報中註明選了哪份。

若**已有**原始 e-statement：

- **不要**再提示／引導下載
- **繼續 §6d** 產出遮罩 PDF

若**沒有**：走 §6c；**不要**假裝已遮罩。

#### 6c. 若沒有 → 卡關並引導下載（繁體中文）

完整 claim 到此若 folder 無原始 eStatement、使用者亦未提供路徑：

1. **視為卡關**：用上方「卡關回報範本」說明欠缺 **enJoy eStatement PDF**；**不要**假裝已完成 claim／已遮罩。
2. 明確告訴要下載的結單：**`13-MM-YYYY`（ENJOY VISA PLATINUM）**，並一句解釋：因 Cursor 在 claim 月下旬扣款，該筆在此期結單。
3. 建議存檔名：`{英文月縮寫} eStatement.pdf`（對齊現有 `Jun eStatement.pdf`），放入同一 `Expense/{M:YY}/`；或直接把檔案路徑貼給 Agent。
4. 步驟指引：
   - 登入恒生個人 e-Banking（Browser Tab 可先開到 e-Statement URL；未登入則請使用者登入後回覆）
   - **e-Statement / e-Advice** → **信用卡** 分頁
   - 戶口選 **enJoy Visa白金卡**
   - 在列表找到日期 **`13-MM-YYYY`** → 按 **下載**
   - 若彈窗／PDF 被擋：允許 `hangseng.com` 彈出視窗後再按一次；手動儲存到 `dest_dir`
5. 自動化：可嘗試開頁、選卡、點對應 **下載**；若無法把 PDF 寫入本機，**停止自動重試**，改為上述引導。
6. 使用者表示已放入／提供路徑後：再跑 **6b → 6d**；仍無則再報一次欠缺，不要無限循環。

#### 6d. eStatement → claim 遮罩 PDF（必遵守）

**觸發（任一）：**

- 6b 已找到原始 eStatement；或
- 使用者親口提供路徑／檔案並要求處理／遮罩／mask（可跳過 §2–5）

**步驟：**

1. 確認本機可 `python3 -c "import fitz"`（PyMuPDF）。不可用 → 停止並請安裝／改環境，勿用純 annotation 凑合。
2. 用 `fitz` 開啟來源 PDF；逐頁 `get_text()` 搜尋 **`CURSOR`**（實際商戶常為 `CURSOR, AI POWERED IDE`／`CURSOR.COM`）。
3. **找不到**：停止；回報總頁數，並建議可能下錯期 → 應下載 `hangseng_stmt_label`（§6a）。
4. **多頁／同頁多筆**命中：預設取**第一個**命中頁／第一筆，並在回報註明。
5. 只把該頁 `insert_pdf` 成**新單頁**文件（**不覆蓋**原完整結單）。
6. 以 **redaction**（`add_redact_annot` + `apply_redactions`）畫淺灰框，**真正移除**底層文字（公司 claim 隱私；勿只加可選取文字的 Square annotation）。
7. 遮罩範圍（對齊 `Expense/6:26/Jun eStatement.pdf` 視覺與 `7:26/Jul eStatement Cursor.pdf` 實作）：

| 區塊 | 建議 Rect（A4 恒生結單；單位 pt） | 保留 |
| --- | --- | --- |
| 卡號列 | `(63.83, 82.5, 165.0, 95.0)` | `ENJOY VISA PLATINUM`、姓名 |
| 地址（姓名下方） | `(64.76, 126.80, 184.64, 187.09)` | `MISS CHU MELESSA`（或結單上姓名） |
| NEW BALANCE 金額 | `(376.30, 129.33, 478.92, 147.88)` | Minimum Payment |
| Cursor **之上**交易 | `(16.28, 266.66, 584.04, cursor_window_top)` | — |
| Cursor **之下**交易 | `(16.29, cursor_window_bottom, 584.05, 809.03)` | — |

**Cursor 可視窗：**

- `cursor_y` = 該頁 `search_for("CURSOR")` 第一個 hit 的 `y0`
- `cursor_window_top` ≈ `cursor_y - 2`
- 向下涵蓋主列 + `(FOREIGN CURRENCY…)` + `(EXCHANGE RATE*…)` + `(PURCHASE ID:…)`；通常至下一筆交易列之前
- 實務：找 purchase-id 列底或下一個明顯交易日期列的 `y0`，設 `cursor_window_bottom`；七月範例約 `cursor_y≈485.5` → window `483.0`–`534.5`

8. `GRAY = (0.8616, 0.8701, 0.8701)`；對每個 mask rect `add_redact_annot(r, fill=GRAY)`，再 `apply_redactions(images=fitz.PDF_REDACT_IMAGE_NONE)`。
9. 存到 `dest_dir`：`{mon_abbr} eStatement Cursor.pdf`。若已存在 → `{mon_abbr} eStatement Cursor-2.pdf`（再撞 `-3`…），**不要覆蓋**。
10. **驗證**（文字抽樣）：須有姓名與 `CURSOR`／HKD 金額；不得仍有完整卡號（如 `4557 0710…`）或明顯其他商戶列（例如緊鄰的 `HKTVMALL`）。失敗則調整 window／rect 後重跑，勿交付未過驗證的檔。
11. 回報：來源檔、來源頁碼（例如原結單第 3 頁）、產出路徑、Trans/Post 日期、描述、HKD 金額（及 USD 若可見）。

**可複製的 Python 骨架（Agent 應依實際路徑／座標執行，勿盲貼不改）：**

```python
import fitz
from pathlib import Path

src = Path("…/Jul eStatement.pdf")  # 6b 選定或使用者指定
dst = Path("…/Jul eStatement Cursor.pdf")
GRAY = (0.8616, 0.8701, 0.8701)

src_doc = fitz.open(src)
page_index = next(
    i for i, p in enumerate(src_doc)
    if "CURSOR" in p.get_text().upper()
)
out = fitz.open()
out.insert_pdf(src_doc, from_page=page_index, to_page=page_index)
src_doc.close()
page = out[0]

hits = page.search_for("CURSOR")
cursor_y = hits[0].y0
cursor_window_top = cursor_y - 2
# 向下：涵蓋 FOREIGN / EXCHANGE / PURCHASE ID；必要時用 words 找下一筆交易 y0
cursor_window_bottom = cursor_y + 49  # 約略；優先用文字座標精算

masks = [
    fitz.Rect(63.83, 82.5, 165.0, 95.0),
    fitz.Rect(64.76, 126.80, 184.64, 187.09),
    fitz.Rect(376.30, 129.33, 478.92, 147.88),
    fitz.Rect(16.28, 266.66, 584.04, cursor_window_top),
    fitz.Rect(16.29, cursor_window_bottom, 584.05, 809.03),
]
for r in masks:
    page.add_redact_annot(r, fill=GRAY)
page.apply_redactions(images=fitz.PDF_REDACT_IMAGE_NONE)
out.save(dst, garbage=4, deflate=True)
out.close()
```

### 7. 回報（繁體中文）

**全部成功時**至少包含：
- 目標月份（例如 2026-07）
- Folder 顯示名（`7/26`）與實際資料夾名（`7:26`）
- Cursor receipt 完整路徑與檔名；金額、invoice #、付款日（若本次有跑 §2–5）
- enJoy e-statement 來源檔名
- 遮罩 PDF 產出路徑（頁碼、Cursor 日期／金額）

**卡關時**用「卡關回報範本」；勿用含糊的「請再提供更多資料」——必須點名欠缺項目。

## 失敗速查（＝卡關時要告訴使用者的欠缺）

| 情況 | 欠缺／請使用者 |
| --- | --- |
| 無 cursor-ide-browser | 欠缺 Browser Tab；請開 Settings → Tools & MCP → Connect to Browser（僅遮罩且已有本機 PDF 可跳過） |
| 未登入 Cursor | 欠缺 Cursor 登入態；請在 Browser Tab 登入後回覆「已登入」 |
| 未登入恒生 | 欠缺恒生 e-Banking 登入；請登入後回覆 |
| 該月無發票 | 欠缺該月 Paid invoice；停止；不建空 folder |
| View 開了但找不到 Download receipt | 欠缺可下載的 receipt 按鈕；snapshot 後可試 invoice 並註明 |
| PDF 未出現在 Downloads | 欠缺本機 Downloads 內的 receipt；請確認瀏覽器下載權限 |
| folder 無 e-statement 且未提供路徑 | 欠缺原始 enJoy PDF；請下載 `13-MM-YYYY` 或貼路徑 |
| 恒生 blob／popup 無法自動存 | 同上；引導手動下載；folder 已有則不催 |
| folder 已有原始 e-statement | （非失敗）跳過下載 → **跑 6d** |
| 無 PyMuPDF | 欠缺 `fitz`；請安裝後重試，勿交付未 redact 檔 |
| PDF 無 `CURSOR` | 欠缺含 Cursor 列的正確期結單；建議改下 `13-MM-YYYY` |
| 多頁／多筆 CURSOR | 取第一筆並註明 |
| 只有 jpg／png 結單 | 欠缺可抽字 PDF；請改提供 PDF |

## 靜態例子（驗證用）

| 情境 | 目標月 | Folder | enJoy 結單期 | 遮罩產出 |
| --- | --- | --- | --- | --- |
| 「我要 claim cursor」（今日 2026-08） | 2026-07 | `7:26` | 有檔則 6d；無檔卡關要 **13-08-2026** | 完整跑 §1–7 |
| 今日 2026-08，未指明 | 2026-07 | `7:26` | **13-08-2026** | （有來源後）`Jul eStatement Cursor.pdf` |
| 今日 2027-01，未指明 | 2026-12 | `12:26` | **13-01-2027** | `Dec eStatement Cursor.pdf` |
| 使用者指明 2027 年 1 月 | 2027-01 | `1:27` | **13-02-2027** | `Jan eStatement Cursor.pdf` |
| `7:26` 已有 `Jul eStatement.pdf` | — | — | **不提示下載** | 跑 6d → `Jul eStatement Cursor.pdf` |
| 使用者提供路徑並說 mask | 由路徑／指定 | 同左 | 不強制下載 | 同 6d（模式 B） |
| folder 無 e-statement | — | — | 卡關：引導 `13-MM-YYYY` | **不產出**遮罩檔 |