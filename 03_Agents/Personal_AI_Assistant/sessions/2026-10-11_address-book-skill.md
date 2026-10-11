# Session｜2026-10-11｜Address book skill + Google Drive master

## 做了甚麼

### Skill `address-book`

- 由 Google Drive PDF「地址.pdf」匯入親友地址；`addresses[].lines` 一律英文
- 聯絡人：Kyol、浚（aliases 含 Tsun）、綽、King、伯父、老爺奶奶（Carol）、炮台山屋企（Henry/Mary）、香港仔屋企（Melessa）、Alvin父母、Alvin
- 已移除：Mary 獨立條目、黑妹、Carol 鴨脷洲地址；曦屋企已合併入老爺奶奶
- **本機 cache 優先**；讀不到 `address-book.yaml` 時 **Google Drive MCP** fallback
- 舊名 `family-friends-addresses`／`addresses.yaml` 已棄用

### Google Drive

- Master：`address-book.yaml` — https://drive.google.com/file/d/1LYI9YefG1jq-9e_acNUIjYfrytZk2M3P/view
- Folder：**Address Book Skill** — https://drive.google.com/drive/folders/1P0Vht0sVKpDqESgmFDeYeBbUcRuc6ryg
- Legacy PDF id 仍記於 `master.config.yaml`（僅 fallback）

### Repo（無地址明文）

- `02_Knowledge_Base/skills/address-book/`：`SKILL.md`、`master.config.yaml`、`README.md`、`.gitignore`
- Sasa 路由：`AGENTS.md` #17；`TOOLS.md`、`LOG.md`、`MEMORY.md`、skills `README.md`

### 私隱

- `address-book.yaml` **不進 Git**；Cloud user store 與 Drive 為資料副本

## 未完成 / 待 Melessa

- 本機：`git pull` 後 `bash 02_Knowledge_Base/skills/setup-symlinks.sh`；從 Drive 拷 `address-book.yaml` 到 skill 目錄（若 cache 未有）
- 開 **Sync Skills for Cloud Agents**（若要用 Cloud／Slack `@cursor` 讀 user skill）
- Grok Bot：複製 skill 檔 + 確認 Google Drive MCP
- King 兩個加拿大地址：寄件前確認用邊一個

## 下次由哪裡開始

- 旅行前：「給我 address book 裡某某地址」或 `/address-book`
- 搬屋：口述新址 → agent 改 cache + 提醒同步 Drive master

## 今日學到

- Cursor user skill 與 Grok Bot skill **不同系統**；Drive master + `master.config.yaml` 可共用
- Drive MCP **`update_file` 不改內容**；改 master 需覆蓋上傳或桌面同步

## 反思

- 做得好：Drive folder 整理 + repo 真源（skill 邏輯）與私人 YAML 分離
- 可改進：若 Melessa 常手改 Drive，可加「session 結束 sync Drive」固定步驟
