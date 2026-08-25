# Session｜2026-08-25｜Google Calendar 東京航班＋無提醒預設

## 做了甚麼

### Google Calendar（2026-09 東京）

- 去程 **UO854 HKG→NRT**：16 Sep 01:15（HKG T2）→ 06:45（NRT T2）；Fare U Essential
- 回程 **UO871 NRT→HKG**：22 Sep 17:05（NRT T2）→ 21:00（HKG T1）；Fare U Essential
- 全日行程 **✈️東京旅行**：16–22 Sep 2026（all day）
- 以上行程皆**已關閉提醒**

### 偏好／規則

- Melessa 要求：之後每次加 Google Calendar **預設關提醒**，除非明確說要開
- 已建立 Cursor 全域規則：`~/.cursor/rules/google-calendar-no-reminders.mdc`（`alwaysApply`）
- 實作備註：`calendar_createEvent` MCP **不支援** reminders → 建完後須用 Calendar API `PATCH`（token：`~/.google-workspace-mcp/tokens.json`，勿入 repo）

## 未完成甚麼

- （本 session 無未完成 calendar 項）
- 進行中（與本 session 無關）：Maps「東京美食」剩餘約 10 間

## 下次由哪裡開始

- 加 Calendar 行程 → 依新規則預設關提醒
- 優先：Maps「東京美食」剩餘 Save + note（Local Agent + `google-maps-bookmark`）

## 今日學到

- Google Workspace MCP 建事件後預設 `reminders.useDefault: true`；關提醒需額外 API PATCH
- 全日事件 end date 為**排他**（16–22 Sep → end `2026-09-23`）
