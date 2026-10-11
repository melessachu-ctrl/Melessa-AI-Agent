---
name: address-book
description: Address book — 查詢與更新親友郵寄地址（寫明信片、寄件）。觸發：問地址、address book、寄 postcard、搬屋改地址、同步 Drive 地址簿。
version: "1.3.0"
---

# Address book（親友地址簿）

用戶旅行時會寫明信片給親友。**邏輯真源**是與 `SKILL.md` 同結構的 YAML；**實體存放**採「本機 cache 優先，Google Drive 真源兜底」。

| 檔案 | 用途 |
|------|------|
| `address-book.yaml` | 本機／Cloud skill 目錄內的 **cache**（預設讀這份） |
| `master.config.yaml` | Drive 上 master 的 `file_id`（**無地址內容**，可跟 skill 一齊複製） |
| Google Drive **`Address Book Skill/`** 內 `address-book.yaml` | **Master**（無 cache 時從此讀；`master.config.yaml` 有 folder／file id） |

## 前置：Google Drive MCP

Cursor 與 Grok Bot 若已接 **Google Drive MCP**，才可在無本機 YAML 時拉 master。若 MCP 未授權，fallback 失敗時告知用戶登入 MCP 或補本機 `address-book.yaml`。

## 觸發時機

- 用戶詢問親友**郵寄地址**或 **address book**
- 用戶要**列清單**（例如「寄給 Tsun、Kyol、父母」）
- 用戶說**搬屋、改地址**，或**新增／刪除**親友
- 用戶說 **「同 Drive 同步」**、**「從 Google Drive 更新地址簿」**

## 載入資料（每次查詢或更新前必做）

解析 skill 目錄路徑（本機常為 `~/.cursor/skills/address-book/`；Cloud 常為 `/cursor/stores/user/skills/address-book/`；Grok Bot 為 workspace 內同名資料夾）。

**舊名稱**：`family-friends-addresses`、`addresses.yaml` — 若只找到舊路徑，仍可讀取，但應 Write 至新路徑並刪除舊檔。

### 步驟 A — 本機 cache（預設）

1. 讀 `master.config.yaml` 取得 `google_drive.master_file_id` 與 `local.cache_filename`（預設 `address-book.yaml`）。
2. 嘗試 **Read** 同目錄的 cache 檔。
3. **若讀取成功且內容為有效 YAML**（含 `contacts`）→ 用此資料繼續，**不要**為日常查詢多餘打 Drive。

### 步驟 B — Google Drive 真源（fallback）

在以下任一情況執行：

- cache 檔 **不存在**
- **無法讀取**（權限、路徑錯）
- 內容 **損壞或非 YAML**
- 用戶 **明確要求** 以 Drive 為準

**Fallback 操作：**

1. 確認 **Google Drive MCP** 可用；必要時先 `mcp_auth`。
2. 用 `master.config.yaml` 的 `google_drive.master_file_id`。
3. 呼叫 **`download_file_content`** 取得 **完整 UTF-8 YAML 原文**。
4. 解析 YAML；若失敗且 `legacy_pdf_file_id` 存在，可最後手段讀舊 PDF，並提醒應以 YAML master 為準。
5. **若可寫入 skill 目錄**：將下載內容 **Write** 到 `address-book.yaml`（簡短告知「已從 Drive 還原 cache」）。
6. 若 **無法寫本機**：只在當次對話使用 Drive 內容；更新時見「寫回 Drive」。

## 查詢流程

1. 依 **載入資料** 取得最新 `contacts`。
2. 用 `display_name`、`aliases` 模糊匹配（忽略大小寫）。
3. 一人多地址時全部列出並標 `label`。
4. 回覆（繁體中文）：標題 **{display_name}**（含 `phone`）；地址行用英文 `lines`。

## 更新流程

1. 依 **載入資料** 讀取現有 YAML。
2. 修改 `contacts`（**`addresses[].lines` 一律英文**）；更新 `meta.last_updated`（`YYYY-MM-DD`）。
3. **寫入本機 cache**：**Write** `address-book.yaml`（若目錄可寫）。
4. **寫回 Google Drive master**：
   - MCP **`update_file` 不支援改檔案內容**；可 Drive 桌面同步覆蓋 `address-book.yaml`、或 **`create_file`** 上傳新檔並更新 `master.config.yaml` 的 `master_file_id`、或用戶手動改 Drive 後說「從 Drive 同步」。
5. 回覆用戶改動摘要；若未寫回 Drive，**明確提醒**。

## 私隱

- **不要**將 `address-book.yaml` 提交公開 Git repo 或在 PR 貼完整地址。
- `master.config.yaml` 只有 file id，可跟 skill 一齊部署。

## 資料結構

`contacts[].id | display_name | aliases | phone? | notes? | addresses[].label | addresses[].lines[]`
