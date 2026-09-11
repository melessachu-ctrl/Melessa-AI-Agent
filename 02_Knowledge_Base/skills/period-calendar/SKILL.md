---
name: period-calendar
description: >-
  用 Google Calendar 以固定格式紀錄 Melessa 月經開始日，並可查上次／上個月日期。
  Use when the user says 黎m／來m／黎M／來M／來月經／黎月經／月經／大姨媽／period start，
  或問 幾時黎m／上次幾時／上個月幾時黎m／週期／period date。
---

# Period Calendar（黎 m 日曆紀錄）

## 載入時機（必遵守）
命中下列**任一**情況時，必須載入並依本 skill 執行（不可略過、不可改格式）：
- 使用者說自己 **黎 m／來 m／來月經／黎月經／大姨媽**（含「今日黎 m 了」等）
- 使用者要求 **記／mark／幫我紀錄** 月經開始日
- 使用者問 **幾時黎 m、上次幾時、上個月幾時、週期幾耐**

**站立授權**：講「黎 m」＝已授權把該日記入 Google Calendar，**不必再問**。

私隱：
- 日曆標題只用 🩸，不要寫「月經」等字
- 只在相關對話處理；回覆簡短
- 真源在本 skill；**不**加入 UIUX-Skills manifest
- session／MEMORY 只記流程偏好，不列歷次日期

## 工具
- MCP namespace：`plugin-google-calendar-google-calendar`
- 先 `GetDynamicTools`；若 `needsAuth`，先 `mcp_auth` 再繼續
- 日曆：`melessa.chu@gmail.com`（primary）
- 查詢用 `list_events` + `fullText: "🩸"`（`search_events` 對 emoji 不可靠）
- 新增用 `create_event`；日期錯了用 `update_event`

## A. 紀錄（使用者話黎 m）

日期規則：
- 講「今日／而家」或沒指定日期 → 用對話當日（user_info / Today’s date）
- 有講具體日期 → 用該日
- 時區：`Asia/Hong_Kong`

先查該日是否已有 🩸：有就告訴她已記過，**不要重複建立**。

建立參數（必須完全一致）：

| 欄位 | 值 |
| --- | --- |
| `summary` | `🩸` |
| `allDay` | `true` |
| `calendarId` | `melessa.chu@gmail.com` |
| `colorId` | `"4"`（粉紅色 Flamingo） |
| `availability` | `AVAILABILITY_FREE` |
| `overrideReminders` | `[]` |
| `timeZone` | `Asia/Hong_Kong` |
| 描述／地點／出席者／Meet | 不要加 |

**全日日期時差（必遵守）**  
不要用 `YYYY-MM-DDT00:00:00+08:00`，會被寫成前一日。

用 UTC date-only：
- `startTime`: `{目標日}T00:00:00Z`
- `endTime`: `{翌日}T00:00:00Z`

建立後立刻核對回傳的 `start.date` 是否等於目標日。若差一天，`update_event` 用同一對 UTC 日期修正。

回覆（繁體中文、簡短）：已記、日期（含星期）、全日 🩸、粉紅色；附 `htmlLink`。  
若她記錯上個月日期，可一句更正，不要長篇解釋。

## B. 查詢（幾時黎 m）

1. `list_events`：`fullText: "🩸"`，`calendarId: melessa.chu@gmail.com`，範圍至少涵蓋近 12 個月，`timeZone: Asia/Hong_Kong`
2. 全日活動的日曆日 = `start.date` 的 `YYYY-MM-DD`（不要再自行加減時區）
3. 只根據日曆資料回答，不要靠記憶猜

對應問題：
- **上次／最近一次** → 最新一筆 🩸
- **上個月** → 上一個日曆月裡的 🩸；該月沒有就如實講，並報最近一筆
- **某月幾時** → 該月的 🩸
- **週期／隔幾耐** → 相鄰兩筆相差日數（結束日 − 開始日）

回覆簡短：日期 + 星期；若自然，可補「距離上一／這次約 N 日」。

## 格式對照
既有紀錄都是全日 🩸、多數 `colorId: 4`、`AVAILABILITY_FREE`。查日曆核對，不要把歷次日期寫進其他檔。
