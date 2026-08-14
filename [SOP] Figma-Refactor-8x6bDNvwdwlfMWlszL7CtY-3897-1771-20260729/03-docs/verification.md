# 驗證清單

**Frame**：`MGM/Page/NewCustomerPromotion-goldvip-landing-0ppl`（`3897:1771`）  
**視覺政策**：`strict-no-visual-change`

## 截圖對比

| 階段 | 尺寸 | 結果 |
| --- | --- | --- |
| Baseline（改前） | 375 × 1150 | 已記錄 |
| 改後（含回歸修正） | 375 × 1150 | ✅ 通過 |

中間曾出現 CouponLimitNote 錯位（root 高度 2041px）與 CodeField 寬度 378px，均已修正並通過最終截圖驗證。

## 結構度量（改後）

| 指標 | 改前 | 改後 |
| --- | --- | --- |
| 總節點數 | 164 | 123 |
| FRAME 總數 | 4 | 16 |
| auto-layout FRAME | 1 | 14 |
| layoutMode=NONE FRAME | 3 | 2 |
| GROUP 數 | 23 | 14 |
| 核心命名合規（top-level + sections） | 低 | ✅ 達標 |
| 裝飾 primitive 舊命名殘留 | 高 | 64（集中於 Hero 插畫） |

## layoutMode=NONE 預期殘留

1. `MGM/Section/Hero/Graphics` — 插畫絕對定位，刻意保留
2. Status Bar instance 內部 — library 元件，不可改

## 驗收勾選

- [x] 全頁 UI 與改前一致（375×1150 截圖通過）
- [x] Root 已設 VERTICAL auto-layout
- [x] 核心互動區（Referral code、Stats、CTA、Footer）已 auto-layout 化
- [x] 頂層與 section 命名達 `MGM/…` 規範
- [x] 無新建本地 token（符合 `no-local-token`）
- [ ] Hero 插畫內部 primitive 全深度命名（超出 `core-sections` 範圍，列阻塞）

## 已符合一般標準（無需改動）

- Status Bar / Title sharing 維持 DS library instance
- 插畫視覺層未 detach 或重繪
