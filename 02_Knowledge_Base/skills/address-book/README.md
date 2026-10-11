# address-book（親友地址簿）

個人 skill：**勿**將 `address-book.yaml` commit 入本 repo（含親友地址與電話）。

## Repo 內有甚麼

| 檔案 | 說明 |
|------|------|
| `SKILL.md` | Agent 行為（查詢、更新、Drive fallback） |
| `master.config.yaml` | Google Drive folder／master file id（無地址） |
| `.gitignore` | 忽略本機 `address-book.yaml` cache |

## 真源與 cache

1. **Google Drive** folder [`Address Book Skill`](https://drive.google.com/drive/folders/1P0Vht0sVKpDqESgmFDeYeBbUcRuc6ryg) 內 `address-book.yaml`（master）
2. **本機 cache**：`address-book.yaml` 與 `SKILL.md` 同目錄（`~/.cursor/skills/address-book/` symlink 後）
3. **Cloud user store**：`/cursor/stores/user/skills/address-book/`（含 cache；Sync Skills 時注意）

預設讀本機 cache；讀不到時用 **Google Drive MCP** + `master.config.yaml` 的 `master_file_id` 拉 master。

## 本機安裝

```bash
bash 02_Knowledge_Base/skills/setup-symlinks.sh
```

首次：從 Drive 下載 `address-book.yaml` 放到 `02_Knowledge_Base/skills/address-book/`（或只放 `~/.cursor/skills/address-book/`），**不要** `git add` 該檔。

## Grok Bot

複製 `SKILL.md` + `master.config.yaml`；可省略 cache，靠 Drive MCP fallback。

## 觸發

問「地址」「address book」「寄 postcard 給 Tsun」等；或 `/address-book`。
