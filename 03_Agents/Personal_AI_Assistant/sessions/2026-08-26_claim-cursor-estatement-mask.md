# Session｜2026-08-26｜claim-cursor：eStatement 遮罩 + 完整 §1–7 觸發

## 做了甚麼

### July eStatement 遮罩（手動產出，後寫入 skill）

- 在 `Expense/7:26/Jul eStatement.pdf` 第 3 頁找到 Cursor 交易（29 JUL／31 JUL，`CURSOR, AI POWERED IDE`，HKD 159.92）
- 依 `6:26/Jun eStatement.pdf` 淺灰遮罩樣式 redact：卡號、地址、NEW BALANCE、其他交易；保留姓名與 Cursor 列
- 產出：`…/Expense/7:26/Jul eStatement Cursor.pdf`（單頁；不覆蓋原結單）

### Skill：`claim-cursor` 擴充

- 新增 **§6d**：folder 有原始 eStatement（或使用者提供路徑）→ 找 CURSOR 頁 → PyMuPDF redact → `{Mon} eStatement Cursor.pdf`
- 無 eStatement → 卡關並引導下載正確期數 `13-MM-YYYY`；不假裝已遮罩
- 「我要 claim cursor／幫我 claim cursor」→ **模式 A：完整跑 §1–7**（含 §7 回報）
- 只 mask／只丟路徑 → **模式 B**（跳過 §2–5，仍跑 §1 + §6 + §7）
- 卡關回報範本：已完成／卡住步驟／欠缺／請你做什麼
- Sasa 路由同步：`AGENTS.md`、`BRAIN.md`

## 未完成甚麼

- （可選）恒生 e-Statement 仍難在 Browser Tab 自動存檔；維持引導為主
- 未另建 `scripts/`（依計劃把座標／Python 骨架寫在 SKILL.md）

## 下次由哪裡開始

- 說「我要 claim cursor」→ 讀 `claim-cursor`，跑 §1–7
- 缺結單時會停並告訴要下載哪一期；放入／貼路徑後續跑 6d + 7

## 今日學到

- 遮罩應用 **redaction**（移除底層文字），不要只加可選取的 Square annotation
- 完整 claim 含 §7 回報；先前寫成 §1–6 是漏看

## 備註

- Skill 真源：`02_Knowledge_Base/skills/claim-cursor/SKILL.md`
- Expense PDF 不進 git
