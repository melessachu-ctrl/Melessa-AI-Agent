---
name: shopline-admin
description: >-
  用 Cloud Agent Secret `SHOPLINE_COOKIES` 登入 Shopline Admin 後台（hkgymmn），執行訂單查詢、
  匯出訂單報表、欄位設定等操作。Use when the user asks to log into Shopline admin, export order reports,
  check orders, or perform Shopline backend tasks for Gym Master Nutrition.
---

# Shopline Admin（Gym Master Nutrition）

## 載入時機（必遵守）

命中下列**任一**情況時，必須載入並依本 skill 執行：

- 使用者要求在 **Shopline Admin** 後台操作（訂單、匯出、篩選、報表）
- 使用者提到 **hkgymmn**、**Gym Master Nutrition**、**匯出訂單報表**
- 使用者提到 **`SHOPLINE_COOKIES`**、**`_shopline_sso_session_id`**
- 使用者要整理 **報稅用訂單 CSV**（香港合夥 BIR52、年結 3/31）

## 工具與限制

- **首選**：Playwright（headless Chromium）設 cookie 後操作 UI；比 curl 穩定。
- **憑證來源**：環境變數 **`SHOPLINE_COOKIES`**（Cursor Cloud Agent Runtime Secret）。
- **禁止** 把 session cookie 寫入 repo、commit、session 檔、LOG、PR、或 chat 回覆。
- **無法** 讀取 Yahoo / Gmail 收件匣確認報表是否寄到（除非使用者另外授權對應 MCP）。
- Admin 與 **Shoplytics Dashboard** 係**不同 session**；本 skill 預設只處理 Admin。

---

## 0. 憑證：`SHOPLINE_COOKIES`（必做）

優先順序：**環境變數 `SHOPLINE_COOKIES`** → 使用者本則訊息貼上的 cookie（僅在 secret 缺失時）。

檢查時只確認「有／沒有」，**不要** `echo` 或寫出 cookie 內容：

```bash
[ -n "$SHOPLINE_COOKIES" ] && echo COOKIE_SET=yes || echo COOKIE_SET=
```

### Secret 格式

**預設（只登 Admin）：**

```
_shopline_sso_session_id=<session值>
```

**擴展（Admin + Shoplytics，可選）：**

```
admin=_shopline_sso_session_id=<admin值>;shoplytics=shoplytics-dashboard.sid=<shoplytics值>
```

解析規則：

- 若含 `admin=` 前綴，取 `admin=` 後至 `;shoplytics=` 前（或字串結尾）作 Admin cookie
- 否則整段視為 Admin cookie（可含或不含 `_shopline_sso_session_id=` 前綴；Playwright 需拆成 name/value）

### 若 `COOKIE_SET` 為空

**停止執行**，用繁體中文一次說明：

> 需要你在 Cursor **Cloud Agents → My Secrets** 設定 **`SHOPLINE_COOKIES`**（Runtime Secret），值為 `_shopline_sso_session_id=...`。  
> 更新 secret 後請**開新 Cloud Agent**（舊 agent 不會自動注入新 secret）。

**取得 Admin cookie（Chrome）：**

1. 登入 `https://admin.shoplineapp.com/admin/hkgymmn`
2. F12 → **Application** → **Cookies** → `https://admin.shoplineapp.com`
3. 複製 **`_shopline_sso_session_id`** 的 Value
4. 更新 My Secrets 的 `SHOPLINE_COOKIES`（**不要**貼到 chat）

若 API 回 **401 / redirect 到 SSO**：session 過期 → 請使用者更新 secret，**不要**重試猜測。

---

## 1. 商店固定資訊

| 項目 | 值 |
| --- | --- |
| 商店名稱 | Gym Master Nutrition |
| Handle | `hkgymmn` |
| Admin 根路徑 | `https://admin.shoplineapp.com/admin/hkgymmn` |
| 訂單頁 | `https://admin.shoplineapp.com/admin/hkgymmn/orders?createdBy=admin` |
| Merchant ID | `63246366c6ae0d0008f3ba79` |
| 年結日 | 3 月 31 日（報稅年度：4/1 – 翌年 3/31） |
| 語言 | 繁體中文（`locale=zh-hant`） |

---

## 2. 登入流程（Playwright）

```python
# 從 SHOPLINE_COOKIES 解析（勿 log 值）
import os, re

raw = os.environ["SHOPLINE_COOKIES"]
if "admin=" in raw:
    raw = raw.split("admin=", 1)[1].split(";shoplytics=", 1)[0]
if "=" in raw:
    name, value = raw.split("=", 1)
else:
    name, value = "_shopline_sso_session_id", raw

await context.add_cookies([{
    "name": name.strip(),
    "value": value.strip(),
    "domain": ".shoplineapp.com",
    "path": "/",
    "secure": True,
    "httpOnly": True,
}])
```

驗證：開啟訂單頁，HTTP 200 且 title 含 `Orders`／頁面有「更多動作」。

---

## 3. 匯出訂單報表（標準流程）

路徑：**訂單 → 更多動作 → 匯出訂單報表**

**UI 注意（2026-09 起）：** modal 內「選擇範圍」「欄位設定」可能**收合**（`content-block` height=0）。Playwright 操作前須點 section 標題旁的 **▼/▲** 展開，否則看不到 checkbox、日期欄位亦可能 disabled。

### 3.1 選擇範圍（重要）

| 模式 | 何時用 |
| --- | --- |
| **訂單日期 + 日期區間**（`duringDates` radio） | 匯出整個會計年度或指定區間 ✅ **預設** |
| 目前頁面（`currentPage`） | 只匯出畫面上 24 筆 ❌ 除非使用者明確要求 |
| 已選訂單 | 使用者已勾選特定訂單時 |

**必須** 點選 `input[value="duringDates"]`，再填 modal 內 `start_at` / `end_at`（`YYYY/MM/DD`）。  
未選 `duringDates` 時日期欄位會 **disabled**，匯出會變成「目前頁面」。

### 3.2 日期限制

- 單次匯出最多 **366 天**
- 報稅年度範例：`2025/04/01` – `2026/03/31`（365 天，OK）
- 日期類型選 **訂單日期**（`created_at`）

### 3.3 報表交付方式

- 按「匯出」後 API 回 `{"result": true}` 即已提交
- 報表**不會**在瀏覽器即時下載；通常**寄到觸發匯出之 Admin 帳號 email**
- 可在 **大量作業進度** 或訂單篩選 **報表狀態** 查看進度
- 完成後請使用者自行查 email（含垃圾郵件）；agent **不得** 假設已收到

### 3.4 香港合夥報稅（BIR52）建議欄位

**必選（核心）：**  
訂單號碼、訂單日期、訂單狀態、付款方式、付款日期、付款狀態、貨幣、付款總金額、已退款金額、訂單小計、運費、附加費、優惠折扣、自訂折扣合計、折抵購物金、點數折現、折現用點數、訂單合計、商品貨號、商品名稱、選項、商品成本、商品原價、商品結帳價、商品折扣金額、全單折扣金額、數量、顧客、顧客取消原因、交易編號、訂單備註、管理員備註

**可略過：** 所有「(台灣)」發票欄位、直播、定期購、智能櫃點碼（除非業務用到）

完整欄位清單與 API field name 對照：見 [reference.md](reference.md)。

---

## 4. 執行前檢查清單

```
Progress:
- [ ] SHOPLINE_COOKIES 已注入（COOKIE_SET=yes）
- [ ] 確認任務：查詢 / 匯出 / 欄位設定 / 其他
- [ ] 日期區間與日期類型（預設：訂單日期）
- [ ] 匯出模式 = duringDates（非目前頁面）
- [ ] 欄位清單（報稅任務用 §3.4）
- [ ] 執行並確認 API result:true
- [ ] 回報：日期、欄位數、交付方式（email）、後續使用者動作
```

---

## 5. 與 Shoplytics 的分工

| 需求 | 用哪個 |
| --- | --- |
| 完整訂單明細（客戶名、商品、成本、備註） | **Admin 本 skill** |
| Dashboard 汇总、營業額趨勢、月報 | Shoplytics（需 `shoplytics-dashboard.sid`，見 Secret 擴展格式） |
| 香港報稅用 CSV | **Admin 匯出訂單報表** |

---

## 6. 常見錯誤

| 錯誤 | 原因 | 處理 |
| --- | --- | --- |
| HTTP 401 / SSO redirect | session 過期 | 請更新 `SHOPLINE_COOKIES` secret + 新 agent |
| 只匯出 24 筆 | 用了「目前頁面」或未選 `duringDates` | 重跑 §3.1 |
| 日期欄無法填 | `duringDates` radio 未選 | 先點 `input[value="duringDates"]` |
| `COOKIE_SET` 空 | secret 未注入此 agent | 新開 Cloud Agent |
| 以為 agent 會收到 email | 無 Yahoo/Gmail 授權 | 請使用者自行查信箱 |

---

## 7. 回報格式

```markdown
## Shopline Admin 任務結果

- **商店**：Gym Master Nutrition（hkgymmn）
- **操作**：匯出訂單報表
- **日期**：2025/04/01 – 2026/03/31（訂單日期）
- **欄位**：33 欄（見 §3.4）
- **API**：result: true
- **交付**：報表將寄至觸發匯出之 Admin email；請自行查收（含垃圾郵件）
- **後續**：交 CPA 整理 BIR52；另備支付平台月結單、進貨成本
```

---

## 8. 安全與清理

- ❌ 不 commit cookie、暫時 Playwright 腳本中的 session 值
- ❌ 不在 chat 重複貼 `_shopline_sso_session_id` 值
- ✅ session 檔可記「完成了 Shopline 匯出」，**不可**記 cookie
- ✅ 提醒使用者：secret 等同後台通行證；定期更新、用完可登出

## 詳細 API、欄位對照、Playwright 片段

見 [reference.md](reference.md)。
