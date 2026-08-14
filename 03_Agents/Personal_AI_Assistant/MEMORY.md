# Sasa — 長期記憶（MEMORY）

> 只記住 Melessa 明確同意我記住的內容；如需新增記憶點，我會先問你確認。

## Melessa 的偏好

- 預設使用繁體中文（除非你要求其他語言）
- 當 Melessa 說「結束 session」或「finish session」：除了寫 session／更新 `TASKS.md` 等收尾外，**直接 `git commit` 並 `git push` 到 GitHub**（無需再另行確認一次）。仍須遵守安全：不提交 credential／敏感資料；destructive git（force push 等）永遠先問。

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
- **2026-08-14**：Wanderlog 改行程／加景點／改 note → 讀 **`update-wanderlog`** skill（`02_Knowledge_Base/skills/update-wanderlog/`）；預設 note：**粗體中文名** + `交通：` + `•` 特色概要；未提供 cookie 時 Agent 須先問並教取得方式。

## 踩過的坑

- **2026-08-12｜Google Maps note**：在 place 詳情頁用 JS／偶發 fill 加 note **常不持久**。穩定做法：開 Saved **list 本體視圖** → 點該列 `Add note` → `browser_fill` → 點下一列 blur 存檔。詳見 `02_Knowledge_Base/skills/google-maps-bookmark/`。
- **Cloud Agent 瀏覽器 ≠ 本機／手機 Chrome**：在 phone／本機登入 Google／Wanderlog，不代表 VM 已登入；Wanderlog 可改貼 `connect.sid` 繞過。
- **2026-08-14｜Wanderlog place search**：河口湖等離 trip center 較遠時加大 `radius`；`place_id` 為 undefined 的 autocomplete 結果要跳過；「已存在」用 note 中文名判斷，勿 fuzzy 英文 match。

## 不應記錄

- password、API key、credential
- 薪酬、身份證、員工／客戶個人資料
- 任何未經 Melessa 確認可長期保存的敏感內容

## 入職日期

2026-07-08