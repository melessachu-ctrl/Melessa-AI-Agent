# Session: 2026-07-17 — Lite App Design System

## 目標

- 完善 Lite App Design System 元件，並把相關 App 畫面接回 Design System。

## 輸入

- Lite App Design System、Design Tokens 及 Lite App 目標頁的 Figma 節點。
- Button、Nav Bar、Checkbox、Footer 與 Bottom Sheet 的功能及變體要求。

## 輸出

- 更新 Button 的 icon、顏色、尺寸、字體、Text style 與新增尺寸。
- 建立 Checkbox component set，涵蓋 type、checked state 與 enabled state。
- 建立可配置的 Footer component，並把目標頁的舊 Footer 遷移至新元件。
- 把目標頁的舊 Nav Bar 遷移至 Lite App Design System 元件。
- 建立單一 Bottom Sheet component：
  - 可顯示或隱藏 Footer。
  - 可編輯 Header title、左右 action 與 Content。
  - 左右 action 使用 exposed `Header Action` instances。
- 建立 `Header Action` component set，提供 `Action Button` 與 `Icon Button` 兩種 Type。
- 完成 component properties、semantic token bindings、文件、範例及視覺 QA。

## 今日學到

- 把 action 類型放在 nested helper component，比在 Bottom Sheet 建立組合 variants 更容易使用和維護。
- Figma Plugin API 的寫入是 atomic；variant 移出 component set 後，要重新建立由 component set 管理的 custom properties。
- 空的 component set 可能被 Figma 自動移除，清理腳本需先確認節點是否仍存在。
- 綁定 token 時應以目前發布 library 的 variable key 為準，避免沿用過期 ID。

## 待辦

- [x] 本次要求已全部完成。

## 反思

- 做得好：每次結構變更後都有檢查 properties、token、尺寸與截圖，及時發現 variant 架構與文字 token 問題。
- 需要改進：Melessa 說「結束 session」時，應立即執行 session Markdown、`TASKS.md`、commit 與 push 的完整收尾流程；本次首次回覆漏做，已補正。
