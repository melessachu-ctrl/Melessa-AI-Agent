# 阻塞清單

## 1. Hero 插畫內部 primitive 命名（低優先）

- **節點**：`MGM/Section/Hero/Illustration` 下 ~50 個 Rectangle / Ellipse / Polygon / Group
- **原因**：純裝飾性絕對定位圖形；全量 rename 工作量大，且 `strict-no-visual-change` 下調整父層可能觸發細微位移
- **建議**：若需完整治理，另開 batch 僅針對插畫，採 `MGM/Decoration/Hero/{Element}` 前綴
- **影響**：不阻塞工程交付；不影響主要內容區維護

## 2. MCP 環境無 PingFang HK 字型

- **原因**：`figma.loadFontAsync({ family: "PingFang HK", style: "Semibold" })` 失敗
- **處置**：auto-layout 轉換時避免修改 text 對齊屬性；保留原有 text style
- **影響**：統計數字／CTA 文字未改為 FILL + center align（視覺與改前一致）

## 3. Icon GROUP 未元件化

- **節點**：`MGM/Icon/Referrals`、`MGM/Icon/Coupons`
- **原因**：自訂 vector 組合，HKTVmall DS 未盤點到可直接 swap 的等价 icon instance
- **建議**：後續以 `search_design_system` 盤點 DS icon；或建立 local component（需 `component_policy` 確認）
- **影響**：不阻塞本 frame 結構治理

## 4. Background 仍為 GROUP

- **節點**：`MGM/Layout/Background`
- **原因**：含多層 rectangle 疊加；轉 frame 需驗證 blend/mask 行為
- **建議**：下一批可轉為 FIXED auto-layout frame + absolute children
