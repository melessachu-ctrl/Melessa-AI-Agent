# Session｜2026-09-10｜東京 Food 加燗アガリ、Wanderlog Cloud Agent Secret

## 做了甚麼

### Wanderlog｜前往Tokyo的旅行（`afnmohflkhpeqqpp`）→「東京 Food」

- 新增 **Kan Agari／燗アガリ**（西新宿本店，新 YS ビル 3 階；非はなれ）
- Note：**新宿｜燗アガリ**＋西武新宿／新宿西口交通＋爐端燒／ぬる燗／土鍋米
- Section 由 16 → **17** 個 place

### 街上改 Wanderlog（不必每次貼 `connect.sid`）

- 否決：把個人帳密給 Agent；Wanderlog 工具只認 cookie，密碼風險更高
- 可選：專用協作帳號＋edit 權限（仍要存該帳的 cookie；權限較小）
- **採用**：Cursor Cloud Agent Secret **`WANDERLOG_COOKIE`**（**Runtime Secret**）
- 已設好並用 Cloud Agent 驗證：secret 有注入、session 有效（不把 cookie 寫入 repo／MEMORY／session）
- 街上：手機開**新的** Cloud Agent 即可加景點；本機 Local chat **不會**自動有此 secret

### Skill

- `update-wanderlog`：先檢查環境變數 `WANDERLOG_COOKIE`（只查有／沒有，不 echo 值）；有則直接用；沒有才教貼 cookie
- 真源：`02_Knowledge_Base/skills/update-wanderlog/SKILL.md`（`~/.cursor/skills/update-wanderlog` 為 symlink）

## 未完成甚麼

- Local Agent 仍無 `WANDERLOG_COOKIE`（除非另設 MCP env；本回合未做）
- （可選）河口湖 10 景點 note 升級為 `地區｜` + 特色
- （可選）Maps「東京」list note 升級為 `地區｜景點名`
- `update-wanderlog` **不在** UIUX-Skills manifest → 無需下游 sync 公告

## 下次由哪裡開始

- 街上加餐廳：開 **新的 Cloud Agent**，說行程／list／店名即可
- Cookie 過期或登出 Wanderlog 後：回家更新 Cloud Agent Secret（勿貼 chat、勿 commit）
- UIUX Design Agent PoC（Step 0–3）— 見 `TASKS.md`

## 今日學到

- Wanderlog 無官方 API；`wanderlog-mcp` 只認 `connect.sid`，不認帳號密碼
- Cloud Agent Secret 用 **Runtime Secret**，避免出現在對話／tool 輸出
- 已在跑的 Cloud Agent **讀不到**新加的 secret，必須新開
- 不要把個人 Wanderlog 密碼交給 Agent；也不要把 cookie 寫進 repo

## 備註

- **不記錄、不提交** `connect.sid`／`WANDERLOG_COOKIE` 值
- 驗證 run：[Verify Wanderlog cookie](https://cursor.com/agents?id=bc-e1e0e82e-a16a-47ef-a997-2ea99e809199)
