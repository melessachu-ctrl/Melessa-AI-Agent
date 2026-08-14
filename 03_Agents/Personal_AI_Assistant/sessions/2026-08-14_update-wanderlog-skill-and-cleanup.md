# Session｜2026-08-14｜Wanderlog 河口湖同步、`update-wanderlog` skill、本機收尾

## 做了甚麼

### Wanderlog（Cloud Agent，延續前次對話）

- 將 Google Maps 新加的 **10 個富士山／河口湖景點** 同步至 **前往Tokyo的旅行** → **「富士山河口湖景點」**
- 使用 `connect.sid` + `wanderlog-mcp`（RestClient + ShareDBClient）；note 為 **粗體中文名 | 交通**
- 首批 6 個成功；4 個因 Place search 失敗 → 改用替代搜尋詞／place_id 補齊（遊覽船、Ubuya、大石公園、新倉山忠靈塔）
- **結果**：清單共 10 個景點，note 含 bold 中文名與交通資訊

### Skill：`update-wanderlog`

- 將 Wanderlog 加景點＋ note 流程整理為 skill（原 `wanderlog-places` → 更名 **`update-wanderlog`**）
- 預設 note 格式改為三段落：**粗體中文名** → `交通：…` → `•` 特色概要（2–4 點）
- 未提供 `connect.sid` 時：Agent 須停下並教 DevTools 取得方式
- 已 merge 至 GitHub **`main`**（commit `6c651f3`）；Sasa 路由已更新（`AGENTS`／`BRAIN`／`TOOLS`／skills README）

### 本機

- `git merge origin/main` 取得 skill；重建 `~/.cursor/skills/update-wanderlog` symlink
- Melessa 確認刪除 **`Canada_East_Coast_Sep2026/`**（不再需要）
- Melessa 確認刪除 **`[SOP] Figma-Refactor-8x6bDNvwdwlfMWlszL7CtY-3897-1771-20260729/`**（2026-07-29 MGM landing frame 治理之本地交付紀錄；Figma 改動仍在雲端檔案）

## 未完成甚麼

- 河口湖 10 景點 note **尚未** 升級為新版三段落格式（仍為舊版「粗體中文 | 交通」）；若要一致可另開一輪用 `update-wanderlog` 更新
- GitHub PR #1 可能仍顯示 Open（內容已在 main）；可手動 close
- 本機 `main` 曾超前 remote（含 checkpoint）；finish session push 後應對齊

## 下次由哪裡開始

- **改 Wanderlog**：貼 `connect.sid` + 目標 list；Agent 讀 `update-wanderlog` skill
- **補河口湖 note 特色 bullet**：同上，指定更新「富士山河口湖景點」既有 place note
- **換機／新 Cursor**：`git pull` + 依 `02_Knowledge_Base/skills/README.md` 重建 symlink

## 今日學到

- Wanderlog place search：部分 Maps 英文名 `getPlaceDetails` 會失敗 → 用替代 search 或固定 `place_id`
- 判定「已存在」應以 **note 中文名** 為準，勿用模糊英文 match
- `figma-file-cleanup` SOP 資料夾只存本地交付文件，刪除不影響 Figma 已改內容

## 備註

- **不記錄、不提交** `connect.sid`
- Skill 真源：`02_Knowledge_Base/skills/update-wanderlog/`
