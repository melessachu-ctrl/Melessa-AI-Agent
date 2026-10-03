---
name: onlux-appointment
description: >-
  排期、更新 Google Calendar 上的 OnLux 療程，draft WhatsApp 預約訊息（全名），並依庫存與高能量間隔規則建議組合。
  Use when the user says book／預約／排 OnLux、改 OnLux 行程、下個月 OnLux、
  或提到 Peel／Jet／Pico／HF／BFGF／Exo 等 OnLux 療程排期。
---

# OnLux 療程排期（onlux-appointment）

## 載入時機（必遵守）

命中下列**任一**情況時，必須載入並依本 skill 執行：

- Melessa 要 **book／預約／排／改** OnLux（含「**book／預約 下個月 OnLux**」）
- 討論 OnLux **療程組合、rotation、高能量間隔、面部清潔頻率**
- 要在 Google Calendar **新增／改 title／改日期** 的 OnLux 行程

**授權**：Melessa **明確**要求排期或改 OnLux 日曆時，可直接用 Google Calendar MCP 建立／更新事件（依本 skill 格式）；**不必**逐欄再問。  
**分店實際 confirm**：仍須 Melessa 自己 **WhatsApp／致電** 分店（Agent **不代發**；只出草稿）。

私隱：個人 skill，**不**加入 UIUX-Skills manifest。

## 「預約下個月 OnLux」標準交付（必做兩件）

當 Melessa 話 **預約／book 下個月（或指定月份）OnLux** 時，同一輪回覆須包含：

1. **Google Calendar** — 建立／更新該月 OnLux 事件（**簡稱**，見下節）
2. **WhatsApp 草稿** — 供 Melessa 複製貼上銅鑼灣分店（**療程全名**，見「日曆簡稱 ↔ WhatsApp 全名」）

若只改其中一項（例如「只改 WhatsApp 文案」），仍用全名／簡稱對應規則，並問是否要同步改 Calendar。

## 工具

- MCP namespace：`Google-calendar`（先 `GetDynamicTools`；需 auth 則 `mcp_auth`）
- 日曆：`melessa.chu@gmail.com`（primary）
- 查 OnLux：`list_events` + `fullText: "OnLux"` 或 `search_events` query `OnLux`
- 新增／改：`create_event`／`update_event`

## 分店與日曆格式（預設）

| 欄位 | 值 |
| --- | --- |
| `location` | `OnLux 銅鑼灣旗艦店`（除非 Melessa 指定其他分店） |
| `summary` | `OnLux {療程}` — 療程用 **+** 連接、**簡稱**（例：`BFGF+Pico`、`Peel+Exo`、`HF+bfgf`） |
| `timeZone` | `Asia/Hong_Kong` |
| `useDefaultReminders` | `false`（無 overrides） |
| 時段 | 預設 **周六 13:00–14:00**（1 小時 block）；若當次只有 ~30 分鐘面部清潔仍可用 1 小時 block，除非 Melessa 要求改短 |
| `description` | 含 `地點：OnLux 銅鑼灣旗艦店`；若尚未分店 confirm，加 `（待分店確認預約）` |

排期前先 `list_events` 查該月已有 OnLux 及 **其他行程衝突**（同時段），有衝突要標出並建議改日／改鐘。

## 日曆簡稱 ↔ WhatsApp 全名（必遵守）

Google Calendar title **只用簡稱**；WhatsApp 草稿 **必須用分店認的全名**。  
由 Calendar 的 `+` 分段逐段轉換（大小寫不敏感），再用 ` + `（前後有空格）連接。

| 日曆簡稱 | WhatsApp 全名 |
| --- | --- |
| Peel | **Magic Peel** |
| Jet | **Power Jet** |
| Exo | **Exosome** |
| HF | **Hifu Lifteria** |
| Pico | **Pico** |
| BFGF / bfgf | **BFGF** |

- 例：日曆 `Peel+Exo` → WhatsApp `Magic Peel + Exosome`
- 例：日曆 `HF+bfgf` → WhatsApp `Hifu Lifteria + BFGF`
- 例：日曆 `BFGF+Pico` → WhatsApp `BFGF + Pico`
- 若 Melessa 當次指定其他寫法，以她為準並可回寫本表（在 skill 內更新）。

**不要**在 WhatsApp 用 Peel／Exo／HF 等日曆簡稱（除非全名表未涵蓋且 Melessa 確認）。

## WhatsApp 草稿格式（Melessa 慣例）

```
你好，我想預約 {M}月療程：

{M}/{D}（{weekday}）{HH:MM} — {全名1} + {全名2}
…
```

- `{M}月療程`：目標月份，例如 `11月療程`
- 每行一個 appointment；日期 **M/D**、**中文星期**（一至日）、**24h 鐘**（如 `13:00`）
- 組合用 **` + `**（空格 + 加號 + 空格）
- 單一療程則只寫全名，不加 `+`
- 可選在末尾加一行：會員姓名／編號 placeholder（Melessa 常自行填，**不必**追問）
- **不要**代發；回覆用 code block 方便複製

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
| **高能量** | **Pico**、**HF**（日曆 HF = WhatsApp **Hifu Lifteria**） | **Pico 與 HF 彼此**須 **相隔 ≥ 14 日** |
| **保濕／其他** | **BFGF**、**Exo**（WhatsApp **Exosome**） | 依 Melessa 當次指定；常與清潔或高能量 **同場 +** 組合 |

日曆 title **不要**寫 EU1（除非庫存更新後 Melessa 另行說明）。

## 排期邏輯（Agent 建議時）

1. **高能量**：畫出該月所有含 **Pico** 或 **HF** 的 OnLux 事件，任意兩個高能量日期相差 **< 14 日** → 必須改其中一個。
2. **面部清潔**：該月至少 **1 個** title 含 **Peel** 或 **Jet**（或兩者各一，視庫存與 Melessa 意願）。
3. **組合**：清潔 + 高能量／保濕 用 `Peel+Exo`、`BFGF+Pico` 等 **單一事件** 表達（與 Melessa 慣例一致）。
4. **頻率參考**：Melessa 常 **每月約 3 次** OnLux（周六下午）；具體日期以日曆空檔與其他預約（例：Cpplus）為準。

## 分店聯絡

- 預約熱線：**2177 8188**；銅鑼灣 WhatsApp：**6226 8011**
- 更改／取消須 **24 小時前** 通知分店

## 回覆格式（繁體中文）

1. **Calendar**：日期、星期、**簡稱 title**、地點；附 `htmlLink`；高能量間隔、當月是否已有面部清潔
2. **WhatsApp 草稿**：獨立 code block，全名、符合上方模板
3. 提醒：草稿貼上 WhatsApp 後等分店 confirm；confirm 後可改 Calendar 備註

## 參考：2026 年 11 月（Melessa 確認）

| 日期 | Calendar（簡稱） | WhatsApp 行 |
| --- | --- | --- |
| 11/7（六）13:00 | OnLux **BFGF+Pico** | `11/7（六）13:00 — BFGF + Pico` |
| 11/21（六）13:00 | OnLux **Peel+Exo** | `11/21（六）13:00 — Magic Peel + Exosome` |
| 11/28（六）13:00 | OnLux **HF+bfgf** | `11/28（六）13:00 — Hifu Lifteria + BFGF` |

WhatsApp 開頭：`你好，我想預約 11月療程：` + 空行 + 以上三行。
