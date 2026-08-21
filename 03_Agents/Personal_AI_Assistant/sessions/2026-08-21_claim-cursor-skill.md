# Session｜2026-08-21｜Claim Cursor skill（receipt + enJoy e-statement）

## 做了甚麼

### Cursor Billing／Expense

- 用 Browser Tab 下載 **July 2026** Cursor receipt（`#VFPVOHGN-0004`，US$20，29 Jul 2026）
- 存入 iCloud Expense：`…/HKTVmall/Document/Expense/7:26/Receipt-2309-4840.pdf`
- 釐清 Expense folder 命名：磁碟為 **`M:YY`（冒號）**，Finder 顯示成 `M/YY`；不可建成巢狀 `7/26`

### 恒生 enJoy Card e-statement

- 登入 e-Banking → e-Statement／信用卡 → enJoy Visa白金卡
- 確認結單列含 `13-07-2026`、`13-08-2026` 等
- Browser Tab **難以自動存** 恒生 blob／popup PDF；改為 skill 內「檢查 folder + 引導手動下載」
- 恒生信用卡結單 **不會** 以 PDF 附件寄 Gmail（只有提示電郵）
- `7:26` 現有有效 `Jul eStatement.pdf`（6 頁 PDF）

### Skill：`claim-cursor`

- 建立 skill（原試作名 `cursor-receipt-expense` → 更名 **`claim-cursor`）
- 流程：下載 Cursor receipt → 存 `Expense/{M:YY}` → 檢查同 folder 是否已有 e-statement；沒有則引導下載**含 Cursor 扣款**那期（例：claim 2026-07 → **13-08-2026**）
- 真源遷入 `02_Knowledge_Base/skills/claim-cursor/`；`~/.cursor/skills/claim-cursor` → symlink
- 更新 Sasa 路由：`AGENTS.md`／`BRAIN.md`／`TOOLS.md`；skills `README.md` 重建清單

## 未完成甚麼

- （可選）將 `claim-cursor` 的恒生下載再強化為更穩的自動存檔（目前以引導為主）
- 若 `7:26` 的 `Jul eStatement.pdf` 實際是 **13-07** 而非含 29 Jul 扣款的 **13-08**，claim 時可能要改下 **13-08-2026** 那期

## 下次由哪裡開始

- 說「下載 cursor receipt」／「claim Cursor」→ Agent 讀 `claim-cursor` skill
- 每月：Cursor receipt 自動下載；e-statement 若 folder 已有則跳過，否則照 skill 指引下載正確期數

## 今日學到

- Expense 年月 folder 用冒號 `7:26`，不是路徑斜線
- Cursor 下旬扣款通常落在恒生「下一個月約 13 日」結單
- 恒生 e-Statement 在 Cursor Browser 常走 hidden iframe／blob，CDP 難以抽出 PDF

## 備註

- Skill 真源：`02_Knowledge_Base/skills/claim-cursor/SKILL.md`
- 不記錄銀行登入憑證
