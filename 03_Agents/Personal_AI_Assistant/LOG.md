# LOG｜Sasa

## 2026-09

| 日期 | 任務 | 成果 | 備註 |
|---|---|---|---|
| 2026-09-04 | KA Price＋Search Result Figma 批次 | 真實 SKU；一位小數；Show KA Off＋Cart；VIP 巢狀補齊 | fileKeys `sVR8HBaQAfiJp5SqPfA1lo`／`SPD3XrBhgiW57uBo28UxjZ` |
| 2026-09-03 | 3rd Party Login Permissions List 更新為 7 項 | Consent ZH 主元件＋實例；`3911:222` 保留「您已授權：」 | fileKey `3gnFYaXhhARa39OqRf0MdX`；注意實例 text override |
| 2026-09-01 | UIUX Design Agent 規劃＋8 步實施手冊 | `UIUX_Design_Agent_Implementation_8_Steps.md`；命名統一；刪 PDF/HTML + `.tmp-pdp-assets`；PR #5–#7 | PoC 待 Step 0–3；Hermes + Slack 待 PM team |

## 2026-08

| 日期 | 任務 | 成果 | 備註 |
|---|---|---|---|
| 2026-08-27 | Cursor 接入 Lovable MCP＋操作 skill | `mcp.json` 加 lovable；官方 plugin；`lovable-mcp-server-guide`＋symlink；Sasa 路由同步 | 寫入／deploy 先問；≠ portfolio-designer |
| 2026-08-27 | Cursor 接入 Base44 MCP＋操作 skill | `mcp.json` 加 base44；`base44-mcp-server-guide`＋symlink；TOOLS／MEMORY／AGENTS 同步 | 寫入先問；≠ App MCP |
| 2026-08-26 | Maps「東京美食」續存＋list note | 新存 9＋補 note 3；list 15 places；`地區｜景點名`；12/13（一代閉店略過） | Local Agent + `google-maps-bookmark`；CDP await 不穩改 poll |
| 2026-08-26 | Lite App PDP IMG 對齊＋OOS demo 頁 | 主元件換 `PDP IMG`；新頁 `PDP v3.0 (OOS)`（IMG＋ATC OOS） | fileKey `rCF6Dj4hH8rb2lPd85i3C3`；備份可刪 |
| 2026-08-25 | Portfolio Designer 遷入 Melessa（Skill） | `portfolio-designer` 真源＋symlink＋Sasa 路由；範例 JSON／PNG；PDF exporter | 不做獨立 Agent；非 alwaysApply rule |
| 2026-08-25 | Google Calendar 東京航班＋全日旅行；預設關提醒 | UO854／UO871＋「✈️東京旅行」入曆；MEMORY + `google-calendar-no-reminders` rule | MCP 建事件後須 API PATCH 關提醒 |
| 2026-08-24 | Finish session 流程 + observation log Skills 欄 | HEARTBEAT／MEMORY／BRAIN 更新；finish session 自動寫 log | 本回合無 skill 使用 |
| 2026-08-23 | Trip.com 東京美食 13 間；Wanderlog「東京 Food」+ 景点 note；`地區｜景點名` skill 更新 | Wanderlog 13 美食 + 16 景点 note；兩 skill 格式統一；Maps 當時 ~3/13 | Maps 於 2026-08-26 補完 12/13 |
| 2026-08-13 | Google Maps「東京」→ Wanderlog「東京景点」同步 | Cloud Agent 以 `connect.sid` + API 完成 13 景點＋中文 note；session 紀錄 Cloud／Local 分工 | 不存 cookie；VM 瀏覽器登入 Google 未成功 |
| 2026-08-12 | 建立 `google-maps-bookmark` skill；東京景點存 Maps + note | Skill 真源 + symlink；Sasa 路由／README／MEMORY 踩坑；13 景點繁中 note | 只用 cursor-ide-browser；note 必須在 list 視圖 |
| 2026-08-06 | MedDx AiLergy 報告分析與摘要 | Session 紀錄；TASKS 更新（預約／檢測完成）；無明確 IgE 陽性 | 非醫療診斷；不保存報告個資 |

## 2026-07

| 日期 | 任務 | 成果 | 備註 |
|---|---|---|---|
| 2026-07-28 | 建立 `email-writer` skill 與 Sasa routing | Skill 真源放入 `02_Knowledge_Base/skills/`、建立 `~/.cursor/skills/email-writer` symlink、更新 Sasa 路由與 skills README | 電郵內容不足時改用 placeholder 補位，不追問 |
| 2026-07-27 | 建立 `tonight-dinner` skill 與 Sasa routing | Skill 真源放入 `02_Knowledge_Base/skills/`、建立 `~/.cursor/skills` symlink、更新 Sasa 路由與 README、已 push | 後續新增 skill 預設沿用 repo-source + symlink 結構 |
| 2026-07-23 | MedDx／AiLergy 評估 | Session 紀錄＋預約前 5 問；TASKS 待辦 | 不含收據個資；非醫療診斷 |
| 2026-07-07 | 建立 8 件套第一版 | 建立 `AGENTS.md`～`LOG.md` 共 8 份檔案 | 內容待 Step 4 audit 後修訂 |
