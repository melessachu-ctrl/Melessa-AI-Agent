---
name: onlux-appointment
description: >-
  排期、更新 Google Calendar 上的 OnLux 療程，並依庫存與高能量間隔規則建議組合。
  Use when the user says book／預約／排 OnLux、改 OnLux 行程、下個月 OnLux、
  或提到 Peel／Jet／Pico／HF／BFGF／Exo 等 OnLux 療程排期。
---

# OnLux 療程排期（onlux-appointment）

## 載入時機（必遵守）

命中下列**任一**情況時，必須載入並依本 skill 執行：

- Melessa 要 **book／預約／排／改** OnLux（含「book 下個月 OnLux」）
- 討論 OnLux **療程組合、rotation、高能量間隔、面部清潔頻率**
- 要在 Google Calendar **新增／改 title／改日期** 的 OnLux 行程

**授權**：Melessa **明確**要求排期或改 OnLux 日曆時，可直接用 Google Calendar MCP 建立／更新事件（依本 skill 格式）；**不必**逐欄再問。  
**分店實際 confirm**：仍須 Melessa 自己 WhatsApp／致電分店（Agent 無法代收 WhatsApp 驗證碼）。

私隱：個人 skill，**不**加入 UIUX-Skills manifest。

## 工具

- MCP namespace：`Google-calendar`（先 `GetDynamicTools`；需 auth 則 `mcp_auth`）
- 日曆：`melessa.chu@gmail.com`（primary）
- 查 OnLux：`list_events` + `fullText: "OnLux"` 或 `search_events` query `OnLux`
- 新增／改：`create_event`／`update_event`

## 分店與日曆格式（預設）

| 欄位 | 值 |
| --- | --- |
| `location` | `OnLux 銅鑼灣旗艦店`（除非 Melessa 指定其他分店） |
| `summary` | `OnLux {療程}` — 療程用 **+** 連接，大小寫跟 Melessa 慣例（例：`BFGF+Pico`、`Peel+Exo`、`HF+bfgf`） |
| `timeZone` | `Asia/Hong_Kong` |
| `useDefaultReminders` | `false`（無 overrides） |
| 時段 | 預設 **周六 13:00–14:00**（1 小時 block）；若當次只有 ~30 分鐘面部清潔仍可用 1 小時 block，除非 Melessa 要求改短 |
| `description` | 含 `地點：OnLux 銅鑼灣旗艦店`；若尚未分店 confirm，加 `（待分店確認預約）` |

排期前先 `list_events` 查該月已有 OnLux 及 **其他行程衝突**（同時段），有衝突要標出並建議改日／改鐘。

## 療程庫存與分類（2026-10 更新）

### 庫存狀態

- **EU1**：**已用晒** — 排期時**不要**再排 EU1，除非 Melessa 明確話買咗新療程。
- **額外購買（未用）**：
  - **Magic Peel**（日曆簡稱 **Peel**）
  - **Power Jet**（日曆簡稱 **Jet**）

### 療程類型

| 類型 | 代表療程 | 規則 |
| --- | --- | --- |
| **面部清潔**（非高能量） | **Peel**、**Jet** | 約 **30 分鐘**；可同場配合 **保濕**（如 BFGF）或 **高能量** 一起做；**每月至少排 1 次** 面部清潔（Peel 或 Jet 二選一或輪替，按庫存） |
| **高能量** | **Pico**、**HF**（含 Hifu／Liftera 等 Melessa 標 HF 者） | **Pico 與 HF 彼此**（以及同類高能量）須 **相隔 ≥ 14 日** |
| **保濕／其他** | **BFGF**、**Exo** 等 | 依 Melessa 當次指定；常與清潔或高能量 **同場 +** 組合 |

日曆 title **不要**寫 EU1（除非庫存更新後 Melessa 另行說明）。

## 排期邏輯（Agent 建議時）

1. **高能量**：畫出該月所有含 **Pico** 或 **HF** 的 OnLux 事件，任意兩個高能量日期相差 **< 14 日** → 必須改其中一個。
2. **面部清潔**：該月至少 **1 個** title 含 **Peel** 或 **Jet**（或兩者各一，視庫存與 Melessa 意願）。
3. **組合**：清潔 + 高能量／保濕 用 `Peel+Exo`、`BFGF+Pico` 等 **單一事件** 表達（與 Melessa 慣例一致）。
4. **頻率參考**：Melessa 常 **每月約 3 次** OnLux（周六下午）；具體日期以日曆空檔與其他預約（例：Cpplus）為準。

## 分店預約（Agent 不能代完成的部分）

- 預約熱線：**2177 8188**；銅鑼灣：**6226 8011**（WhatsApp）
- 網上登記需 **WhatsApp 驗證碼** → Agent 只產 **草稿訊息** 供 Melessa 貼上，不代發。
- 更改／取消須 **24 小時前** 通知分店。

## 回覆格式（繁體中文）

- 列出：**日期、星期、title、地點**；附 `htmlLink`
- 簡述：**高能量間隔**是否 OK、**當月是否已有面部清潔**
- 若只改 skill／規則、未改日曆，也要確認 Melessa 是否要同步改 Calendar

## 參考：2026 年 11 月（Melessa 確認）

| 日期 | Title | 備註 |
| --- | --- | --- |
| 11/7（六）13:00 | OnLux **BFGF+Pico** | 高能量 Pico |
| 11/21（六）13:00 | OnLux **Peel+Exo** | 面部清潔 + Exo；避開 11/14 Cpplus |
| 11/28（六）13:00 | OnLux **HF+bfgf** | 高能量 HF；與 11/7 Pico 相隔 21 日 ✓ |
