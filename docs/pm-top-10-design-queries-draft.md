# PM top 10 設計查詢（草稿）

> **Status:** draft — Step 1 待 PM 訪談／Slack 記錄驗證  
> Phase 1 只 solve 類別 1–3（lookup + 理解）

| # | 類別 | 例句（待換成真實 PM 原話） | 預期 confidence | PoC index entry |
|---|------|---------------------------|-----------------|-----------------|
| 1 | 定位 | Checkout v3 最新 approved design 喺邊？ | medium（checkout 仍 wip） | `checkout-v3` |
| 2 | 定位 | Search result category tree 邊個 frame？ | high | `search-result-category-tree` |
| 3 | 理解 | PDP OOS 點顯示？ | high | `lite-app-pdp-oos` |
| 4 | 理解 | KA Price 喺 search result 點樣出？ | high | `ka-price-search-result` |
| 5 | 定位 | 3rd party login consent 權限 list 邊頁？ | high | `third-party-login-consent` |
| 6 | 理解 | MABS 瀑布流 ad 模組比例？ | medium | `mabs-ad-waterfall` |
| 7 | DS | 呢個 flow 用咩 component？ | medium | Figma MCP `search_design_system` |
| 8 | 定位 | Cart 最新稿？ | low（placeholder） | `cart-v2` |
| 9 | 版本 | 有冇舊版 search result？ | medium | 多 entry + status |
| 10 | 判斷 | PRD 同 design 有冇 gap？ | low（Step 8） | — |

## PoC 試跑用 5 題（Cursor）

1. Search result 護膚化妝 SubCate 邊個 frame？→ `search-result-category-tree`
2. Lite App PDP OOS demo？→ `lite-app-pdp-oos`
3. KA Price search result section link？→ `ka-price-search-result`
4. 3rd party login 七項權限？→ `third-party-login-consent`
5. MABS 瀑布流縮尺後模組？→ `mabs-ad-waterfall`
