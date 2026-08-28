# Sasa — 長期記憶（MEMORY）

> 只記住 Melessa 明確同意我記住的內容；如需新增記憶點，我會先問你確認。

## Melessa 的偏好

- 預設使用繁體中文（除非你要求其他語言）
- 當 Melessa 說「結束 session」或「finish session」：除了寫 session／更新 `TASKS.md` 等收尾外，**自動追加一行**到 `01_Action_Center/outputs/test_logs/Workflow_Observation_Log.md`（含 **Skills** 欄：本回合用過的 skill 才填，無則留空），然後**直接 `git commit` 並 `git push` 到 GitHub**（無需再另行確認一次）。仍須遵守安全：不提交 credential／敏感資料；destructive git（force push 等）永遠先問。
- **2026-08-25｜Google Calendar**：建立／新增行程時**預設關閉提醒**（`useDefault: false`、無 overrides）；**只有** Melessa 明確要求提醒時才開啟。Cursor 規則：`~/.cursor/rules/google-calendar-no-reminders.mdc`。MCP `calendar_createEvent` 不支援 reminders → 建完後用 Calendar API `PATCH`（token 在 `~/.google-workspace-mcp/`，勿 commit）。
- **2026-08-25｜Portfolio**：寫 portfolio／作品集文案／device mockup／Lovable project details → 讀 **`portfolio-designer`** skill（真源在 `02_Knowledge_Base/skills/portfolio-designer/`）。以 Skill 承載，不做獨立 Agent；勿用 `alwaysApply` rule。
- **2026-08-27｜Base44 MCP**：Cursor 全域已接 `base44`（`https://app.base44.com/mcp`）；建／改 Base44 app、entities、sandbox → 讀 **`base44-mcp-server-guide`**。寫入操作先問。勿與「已發布 app 的 App MCP」混淆。
- **2026-08-27｜Lovable MCP**：Cursor 全域已接 `lovable`（`https://mcp.lovable.dev`）＋可裝 Lovable plugin（`/lovable-new` 等）；建／改／部署 Lovable 專案 → 讀 **`lovable-mcp-server-guide`**。寫入／deploy 先問。文案／mockup 仍用 **`portfolio-designer`**（不自動改站）。

## 個人／居住

- **現居（2026-08 起）**：香港仔中心，**港富閣**（與丈夫同住）。
- **平時去港鐵**：搭 **4M 小巴** 去 **黃竹坑**，再轉 **南港島綫**（黃竹坑站）。**港鐵香港仔站現未使用**（2026-08 仍無此站）。
- **以前（與父母同住）**：炮台山，**Le Sommet 豪廷峯**。最近港鐵：**炮台山站**（港島綫）。
- **用途**：行程規劃、通勤時間估算、路線建議時，預設起點為**現居**，並用 **4M → 黃竹坑 → 港鐵** 作為預設出發模式；若 Melessa 提及「返父母家／炮台山」則改用前址。
- **不記錄**：單位樓層、門牌、業主／租約細節。

## 健康／個人背景

- **濕疹**：不時復發、原因未明；主要在手掌／手背、膝頭後方、耳背、頸，範圍通常很小。
- **相關過敏表現**：有鼻敏感，但較少流鼻水／打噴嚏，主要是眼痕、眼紅。
- **2026-08 MedDx AiLergy**：295 項 IgE 篩查；總 IgE < 20 kU/L（正常）；**無任何項目達 ≥ 0.3 kUA/L 明確陽性**。邊界值（仍屬陰性／不確定）包括乳膠 Hev b 1（0.18）、蟹（0.15）等。結論：未見明確 IgE 致敏；症狀若持續仍可能屬非 IgE 機制，必要時帶報告見專科。

## 紅線

- （暫時未有個人紅線；通用安全規則見 `TOOLS.md`）

## 重要決策

- **2026-07-08**：採用 Step 5 的 Workflow 判斷原則（template → prompt → skill → agent 階梯、重複 3 次規則、DRIP、升 agent 三條件）；詳見 `BRAIN.md`
- **2026-07-08**：開始 2 週 Workflow 觀察期；日誌位置 `01_Action_Center/outputs/test_logs/Workflow_Observation_Log.md`（臨時觀察用，非正式長期記憶）
- **2026-07-15**：Sasa 會用到的工作技能真源在 `02_Knowledge_Base/skills/`；Cursor 全域快捷入口為 `~/.cursor/skills/`（symlink 指向真源）。改 skill 內容改 repo 內檔案即可；換機時依 `02_Knowledge_Base/skills/README.md` 重建 symlink。
- **2026-07-27**：之後在 `Melessa AI Agent` repo 新增每個 skill，預設都要同時做到「repo-source + `~/.cursor/skills` symlink」；若 skill 涉及觸發詞（例如一講某句就要出餐／做事），同步更新 Sasa routing（至少檢查 `AGENTS.md`、`BRAIN.md`、`TOOLS.md` 是否要補）。
- **2026-08-13**：**Wanderlog（Cloud Agent）**：可在對話貼 `connect.sid`（從已登入 wanderlog.com 的瀏覽器 DevTools 複製），Agent 用 API 改行程；**勿寫入 repo／MEMORY**。**Google Maps 網頁**：Cloud VM 難登入 Google；可改貼景點清單，或電腦 **Local Agent** 用本機 Chrome。**Cursor Agent 環境**：Local↔Cloud 主要在電腦 **Agents 視窗** Move to；手機 Remote 看不到 VM 瀏覽器。
- **2026-08-14**：Wanderlog 改行程／加景點／改 note → 讀 **`update-wanderlog`** skill；預設 note：**粗體 `地區｜景點名`** + `交通：` + `•` 特色概要；未提供 cookie 時 Agent 須先問並教取得方式。
- **2026-08-23**：Google Maps list note 預設 **`地區｜景點名`**（純文字，全形 `｜`）；交通／特色 bullet 放 Wanderlog。Maps ↔ Wanderlog 同步時標題格式應一致。詳見 `google-maps-bookmark`／`update-wanderlog` skill。
- **2026-08-21**：Cursor 公司 claim（receipt + enJoy e-statement）→ 讀 **`claim-cursor`** skill；Expense folder 為 `M:YY`（冒號）；預設上個月；folder 已有 e-statement 則不催下載；Cursor 下旬扣款通常對應恒生「下一個月約 13 日」結單（例：July claim → `13-08-YYYY`）。
- **2026-08-27**：Cursor 接入官方 **Base44 MCP**（Builder plan+、OAuth 選 workspace）；操作指南 skill `base44-mcp-server-guide`；寫入級操作與 Calendar／Figma 同級需先確認。
- **2026-08-27**：Cursor 接入官方 **Lovable MCP**（`mcp.lovable.dev`）＋ Cursor Lovable plugin；操作指南 skill `lovable-mcp-server-guide`；寫入／deploy／DB 與 Calendar／Figma／Base44 同級需先確認。
- **2026-08-26**：`claim-cursor` 擴充 eStatement **淺灰遮罩**（產出 `{Mon} eStatement Cursor.pdf`）；「我要 claim cursor／幫我 claim cursor」預設跑完整 **§1–7**；卡關須明確回報欠缺（結單／登入／Browser 等）。

## 踩過的坑

- **2026-08-26｜Lite App PDP DS swap**：Instance 內本地 frame（如 `img`）不能直接結構替換 → 改 **main component** 才會同步。OOS demo 用獨立 Page／instance override（`PDP IMG`＋`Button / Add to cart` 的 `State=OOS`），勿把有貨主元件永久改成 OOS。寫入前先 clone 備份；`search_design_system` 找 Lite App DS 元件。
- **2026-08-12｜Google Maps note**：在 place 詳情頁用 JS／偶發 fill 加 note **常不持久**。穩定做法：開 Saved **list 本體視圖** → 點該列 `Add note` → `browser_fill` → 點下一列 blur 存檔；note 預設 **`地區｜景點名`**。詳見 `google-maps-bookmark` skill。
- **2026-08-23｜Google Maps 批次存**：單一 browser + CDP `saveToList` 最快；subagent 無法共用已 lock tab；Cloud `cursor-ide-browser` 可能 Aborted／需 Local Agent + 已登入 Google。
- **Cloud Agent 瀏覽器 ≠ 本機／手機 Chrome**：在 phone／本機登入 Google／Wanderlog，不代表 VM 已登入；Wanderlog 可改貼 `connect.sid` 繞過。
- **2026-08-14｜Wanderlog place search**：河口湖等離 trip center 較遠時加大 `radius`；`place_id` 為 undefined 的 autocomplete 結果要跳過；「已存在」用 note 中文名判斷，勿 fuzzy 英文 match。
- **2026-08-21｜恒生 e-Statement**：信用卡結單 **不會** PDF 附件寄 Gmail（只有提示）。Cursor Browser Tab 下載常落 hidden iframe／blob，CDP 難自動存檔 → `claim-cursor` 以檢查 Expense folder + 引導手動下載為主。Expense 年月資料夾勿用路徑斜線建成 `7/26` 巢狀。

## 不應記錄

- password、API key、credential
- 薪酬、身份證、員工／客戶個人資料
- 任何未經 Melessa 確認可長期保存的敏感內容

## 入職日期

2026-07-08