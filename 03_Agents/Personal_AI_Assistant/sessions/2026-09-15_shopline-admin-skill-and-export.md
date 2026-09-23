# Session｜2026-09-15｜Shopline Admin 登入、訂單報表匯出、`shopline-admin` skill

## 做了甚麼

### Shopline Admin（Cloud Agent）

- 用 `_shopline_sso_session_id` 成功登入 **Gym Master Nutrition**（`hkgymmn`）Admin 後台
- 探索「**更多動作 → 匯出訂單報表**」：列出全部可自訂欄位；整理香港合夥 **BIR52**（年結 3/31）建議欄位
- 觸發 **2025/04/01 – 2026/03/31** 訂單日期區間匯出（API `result: true`）；需選 **`duringDates`** radio，否則會誤匯「目前頁面」24 筆
- 釐清：報表寄至**觸發匯出之 Admin 帳號 email**（session 為 `melessa07`）；Agent **無** Yahoo Mail 授權，無法代查收件匣

### Cloud Agent Secret

- Melessa 在 Cursor **My Secrets** 新增 **`SHOPLINE_COOKIES`**（Runtime Secret）
- 建議值格式：`_shopline_sso_session_id=<session值>`
- 更新 secret 後須**新開 Cloud Agent** 才會注入

### Skill：`shopline-admin`

- 建立 `02_Knowledge_Base/skills/shopline-admin/SKILL.md` + `reference.md`（Playwright 登入、日期區間匯出、報稅欄位、安全規則）
- 更新 `02_Knowledge_Base/skills/README.md` symlink 清單
- PR #10 merge 至 **`main`**（commit `dcb189b`）
- Cloud VM 已建 `~/.cursor/skills/shopline-admin` symlink

### Sasa 路由（本 finish session）

- 更新 `AGENTS.md`／`BRAIN.md`／`TOOLS.md`／`MEMORY.md`／`TASKS.md`

## 未完成甚麼

- Melessa **本機 Mac** 尚未重建 `~/.cursor/skills/shopline-admin` symlink（需 `git pull` 後執行 README 指令）
- 未確認 Yahoo 是否已收到 2025/04–2026/03 訂單 CSV（需 Melessa 自行查 `melessa07@yahoo.com.hk`，含垃圾郵件）
- 首次誤觸「目前頁面」匯出（24 筆）可忽略；以日期區間那次為準

## 下次由哪裡開始

- **Shopline 後台 task**：新開 Cloud Agent → 確認 `SHOPLINE_COOKIES` 已注入 → Agent 讀 **`shopline-admin`** skill
- **報稅**：下載 CSV 後交 CPA 整理 BIR52；另備 Stripe／PayMe 月結、進貨成本
- **Session 過期**：更新 My Secrets 的 `SHOPLINE_COOKIES`，再新開 agent

## 今日學到

- Shopline Admin 與 Shoplytics 係**不同 session**（`_shopline_sso_session_id` vs `shoplytics-dashboard.sid`）
- 匯出訂單報表 modal：必須先選 **`duringDates`**，日期欄位才會 enable
- Cloud Agent Runtime Secret 只注入**新啟動**的 agent；`CLOUD_AGENT_INJECTED_SECRET_NAMES` 可驗證
- 個人／合夥 skill（非 UIUX）不進 UIUX-Skills manifest → finish session **毋須** Slack 公告

## 備註

- **不記錄、不提交** session cookie 值
- Skill 真源：`02_Knowledge_Base/skills/shopline-admin/`
