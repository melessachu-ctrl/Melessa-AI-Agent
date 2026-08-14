# 變更清單 — MGM New Customer Flow Landing Frame

**目標節點**：`3897:1771`（原 `[App] 3 New Cus Promotion-goldvip-landing-0ppl`）  
**檔案**：HKTVmall - MGM - New Customer Flow（`8x6bDNvwdwlfMWlszL7CtY`）  
**政策**：`strict-no-visual-change` · `rename_scope=core-sections` · `design_system_mode=library-first`

## 摘要

在不改變視覺的前提下，完成頁面骨架命名、核心區塊 auto-layout 化，以及 root frame 結構治理。

## Batch 1 — 核心命名（24 項）

- Root → `MGM/Page/NewCustomerPromotion-goldvip-landing-0ppl`
- 背景／裝飾／文案／統計／CTA／Footer／Component 實例全面改為 `MGM/{Layout|Section|Copy|Decoration|Icon|Component}/…` 語意路徑
- 移除頂層 `Frame 202`、`Group 390`、`black frame` 等歷史命名

## Batch 2 — 內部 auto-layout 化

| 原節點 | 新結構 | 說明 |
| --- | --- | --- |
| `Group 201` | `MGM/Section/Referral/CodeField/Input` | HORIZONTAL auto-layout；子層 absolute 保留疊放 |
| `Group 390` ×2 | `MGM/Section/Stats/ReferralCount` / `CouponCount` | VERTICAL auto-layout + Background/Value 命名 |
| `Group 414` | `MGM/Section/CTA/ViewCouponsButton` | VERTICAL auto-layout |
| `Group 415` | `MGM/Section/Footer` | VERTICAL auto-layout |
| `Group 271` | 扁平化為 `MGM/Copy/CouponLimitNote` TEXT | 移除多餘 GROUP 包裝 |

## Batch 3 — 頁面骨架 section 化

新增 7 個 section wrapper（皆 VERTICAL auto-layout，子層 `layoutPositioning=ABSOLUTE` 保留原座標）：

- `MGM/Section/Chrome`
- `MGM/Section/Hero`
- `MGM/Section/Promo`
- `MGM/Section/Referral`
- `MGM/Section/StatsReferrals`
- `MGM/Section/StatsCoupons`
- `MGM/Section/CTA`

Root frame 設為 `layoutMode=VERTICAL`、固定 375×1150；`MGM/Layout/Background` 保留為全頁背景 GROUP。

## Batch 4 — Hero 補充命名

- `Group 411` → `MGM/Section/Hero/Illustration`
- Hero 文案／裝飾子層部分語意化

## 回歸修正

- 扁平化 `CouponLimitNote` 時座標 double-count → 已修正為 `(73, 1015)`
- `CodeField` 寬度被 auto-layout 撐大 → 已還原 185×50
- Root 高度被撐大 → 已還原 1150px

## 未改動（刻意保留）

- Hero 插畫內部 50+ 裝飾 primitive（Rectangle/Ellipse/Polygon）— 純視覺裝飾，改 naming 風險高、維護收益低
- `MGM/Section/Hero/Graphics` 維持 `layoutMode=NONE`（插畫絕對定位）
- DS 元件實例（Status Bar、Title sharing）維持 library instance，未 detach
