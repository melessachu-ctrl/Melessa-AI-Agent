# Shopline Admin — Reference

## Cookie 解析（Python）

```python
import os

def parse_shopline_admin_cookie() -> tuple[str, str]:
    raw = os.environ.get("SHOPLINE_COOKIES", "").strip()
    if not raw:
        raise RuntimeError("SHOPLINE_COOKIES not set")
    if "admin=" in raw:
        raw = raw.split("admin=", 1)[1].split(";shoplytics=", 1)[0].strip()
    if raw.startswith("_shopline_sso_session_id="):
        return "_shopline_sso_session_id", raw.split("=", 1)[1]
    if "=" in raw and not raw.startswith("s%3A"):
        k, v = raw.split("=", 1)
        return k.strip(), v.strip()
    return "_shopline_sso_session_id", raw
```

## Playwright：匯出訂單報表（日期區間）

```python
import asyncio, os, re
from playwright.async_api import async_playwright

URL = "https://admin.shoplineapp.com/admin/hkgymmn/orders?createdBy=admin"
START, END = "2025/04/01", "2026/03/31"

async def export_orders_report(fields_to_check: list[str]):
    name, value = parse_shopline_admin_cookie()
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        ctx = await browser.new_context(viewport={"width": 1920, "height": 1080}, locale="zh-TW")
        await ctx.add_cookies([{
            "name": name, "value": value,
            "domain": ".shoplineapp.com", "path": "/",
            "secure": True, "httpOnly": True,
        }])
        page = await ctx.new_page()
        await page.goto(URL, wait_until="networkidle", timeout=90000)
        await page.get_by_text("更多動作", exact=True).first.click()
        await page.get_by_text("匯出訂單報表", exact=True).first.click()
        # New UI: 「選擇範圍」「欄位設定」區塊可能收合（height:0）；先點 section 的 fa-angle 展開
        for title in await page.locator(".modal .modal-section-title").all():
            block = title.locator("xpath=following-sibling::div[contains(@class,'content-block')][1]")
            if await block.evaluate("el => el.getBoundingClientRect().height") < 5:
                await title.locator("i.fa").click()
        await page.locator('input[value="duringDates"]').click(force=True)
        start = page.locator('.modal input[name="start_at"]').first
        end = page.locator('.modal input[name="end_at"]').first
        await start.fill(START)
        await end.fill(END)
        for field in fields_to_check:
            lbl = page.locator("label").filter(has_text=re.compile(f"^{re.escape(field)}$")).first
            cb = lbl.locator('input[type="checkbox"]')
            if await cb.count() > 0 and not await cb.is_checked():
                await lbl.click()
        await page.locator('.modal button.btn-primary').filter(has_text="匯出").last.click()
        await page.wait_for_timeout(8000)
        await browser.close()
```

## Export API（觀察到的 payload 結構）

```
POST /api/admin/v2/{merchant_id}/orders/export_sales?locale=zh-hant
```

成功回應：`{"result": true, "enqueued": false}`

日期區間匯出 filters 範例：

```json
{
  "createdBy": "admin",
  "start_date": "2025-04-01T00:00:00.000Z",
  "end_date": "2026-04-01T00:00:00.000Z",
  "selected_filter_option": "created_at"
}
```

`end_date` 為**次日 00:00 UTC**（即包含至 3/31 當日）。

## 報稅用欄位 ↔ API field name

| 顯示名稱 | API `name` | `type` |
| --- | --- | --- |
| 訂單號碼 | `order_number` | order |
| 訂單日期 | `created_at` | order |
| 訂單狀態 | `status` | order |
| 付款方式 | `payment.option` | order |
| 付款日期 | `payment.paid_at` | order |
| 付款狀態 | `payment.status` | order |
| 貨幣 | `payment.currency` | order |
| 付款訂單號碼 | `payment.from` | order |
| 付款總金額 | `payment.amount` | order |
| 已退款金額 | `payment.refund_amount` | order |
| 訂單小計 | `subtotal` | order |
| 運費 | `delivery.fee` | order |
| 附加費 | `payment.fee` | order |
| 優惠折扣 | `discount` | order |
| 自訂折扣合計 | `custom_discount` | order |
| 折抵購物金 | `user_credit` | order |
| 點數折現 | `point_discount` | order |
| 折現用點數 | `applied_points` | order |
| 訂單合計 | `total` | order |
| 商品貨號 | `sku` | product |
| 商品名稱 | `title` | product |
| 選項 | `variation` | product |
| 商品成本 | `product_cost` | product |
| 商品原價 | `product_price` | product |
| 商品結帳價 | `checkout_price` | product |
| 商品折扣金額 | `product_level_discount` | product |
| 全單折扣金額 | `order_level_discount` | product |
| 數量 | `quantity` | product |
| 顧客 | `customer_name` | customer |
| 顧客取消原因 | `cancelled_reason` | order |
| 交易編號 | `payment.txn_id` | order |
| 訂單備註 | `order_remarks` | order |
| 管理員備註 | `comments` | delivery |

## 全部可選欄位（UI 分類）

### 訂單
訂單號碼、來源訂單號碼、合併訂單號碼、合併來源訂單號碼、直播 Facebook 粉絲專頁、直播名稱、訂單來源、銷售人員、訂單日期、訂單狀態、預購訂單、付款方式、付款日期、付款狀態、貨幣、付款訂單號碼、付款總金額、已退款金額、訂單小計、運費、附加費、優惠折扣、自訂折扣合計、折抵購物金、點數折現、折現用點數、訂單合計、訂單標籤、訂單備註、顧客取消原因、交易編號、退貨單編號、退貨配送編號、稅費、合作夥伴、訂單成立於、訂單來源類型、自訂訂單欄位 1–5、定期購相關

### 出貨
送貨方式、送貨狀態、收件人、電話、地址、完整地址、門市名稱、貨件追蹤號碼、到貨時間/日期、發貨時間等

### 發票（台灣）
統一編號、發票地址、發票類型、發票聯式、發票載具、發票抬頭、發票號碼等

### 商品
商品貨號、商品名稱、選項、商品成本、商品原價、商品結帳價、結帳價類型、數量、商品類型、商品折扣優惠/金額、全單折扣優惠/金額、折抵購物金分攤

### 顧客 / 會員
顧客 ID、顧客、電郵、電話、性別、生日、會員註冊日期/來源、推薦人資料

### 行銷
UTM 來源、UTM 媒介、UTM 活動名稱/字詞/內容、UTM 點擊時間

## Shoplytics（非 Admin）

| 項目 | 值 |
| --- | --- |
| Dashboard URL | `https://dashboard.shoplytics.com/admin/hkgymmn` |
| Cookie 名稱 | `shoplytics-dashboard.sid` |
| 用途 | 汇总報表、營業額趨勢；**不含**完整客戶名/商品明細 |

Secret 擴展格式：`admin=...;shoplytics=shoplytics-dashboard.sid=...`

## 官方文件

- 匯出訂單報表：https://support.shoplineapp.com/hc/zh-tw/articles/115001459203
