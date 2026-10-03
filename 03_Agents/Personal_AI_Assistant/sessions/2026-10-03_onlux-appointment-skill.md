# Session｜2026-10-03｜OnLux 11 月排期 + `onlux-appointment` skill

## 做了甚麼

### Google Calendar（2026-11 OnLux｜銅鑼灣旗艦店｜無提醒）

- **11/7（六）13:00** — OnLux **BFGF+Pico**
- **11/21（六）13:00** — OnLux **Peel+Exo**（避開 11/14 Cpplus 針）
- **11/28（六）13:00** — OnLux **HF+bfgf**（與 11/7 Pico 相隔 ≥14 日）

### Skill（真源 + Sasa 路由）

- 新建 `02_Knowledge_Base/skills/onlux-appointment/SKILL.md`（個人 skill，不進 UIUX-Skills）
- 規則摘要：**EU1 已用晒**；額外 **Peel／Jet** 面部清潔（~30 分、每月至少 1 次）；**Pico 與 HF** 高能量相隔 **≥14 日**；明確要求 book 時可直接改 Calendar
- 更新 `AGENTS.md`（#16）、`BRAIN.md`、`TOOLS.md`、`MEMORY.md`、`02_Knowledge_Base/skills/README.md` symlink 清單
- Draft PR：**[#11](https://github.com/melessachu-ctrl/Melessa-AI-Agent/pull/11)**（branch `cursor/onlux-appointment-skill-f4d6`）

### 其他

- 提供 OnLux 銅鑼灣分店 **WhatsApp 預約草稿**（11 月三個時段；會員欄位留空由 Melessa 填）
- 釐清：repo `sessions/` 內 **僅 2026-08-28** 提及 OnLux（路線）；**無** 9 月排 10 月日曆的 session 紀錄（Calendar 顯示 10 月事件為 2026-09-01 建立）

## 未完成甚麼

- PR #11 **未 merge** `main`；本機 Mac 需跑 symlink 加 `onlux-appointment`
- 分店 **WhatsApp／電話 confirm** 仍須 Melessa 自行發送
- **Jet** 庫存未在 11 月 title 使用（11 月面部清潔用 Peel+Exo）

## 下次由哪裡開始

- 發 WhatsApp 確認 11 月三個 appointment；分店回覆後可改 Calendar 備註（移除「待分店確認」）
- Merge PR #11 後本機 `git pull` + symlink
- 之後「book 下個月 OnLux」→ 讀 `onlux-appointment` skill

## 今日學到

- 10 月 OnLux 排期可能發生於 **未 finish session 入 repo** 的對話；真源應靠 skill + Calendar，唔只靠 session 記憶
- Melessa 偏好：**update skill** 時要寫清庫存（EU1 用晒、Peel/Jet 加購）同高能量間隔

## 反思

- 做得好：依 Melessa 修正即時改 11/7、11/21 title 並寫入 skill
- 可改進：若懷疑已有 skill，應先問本機 `~/.cursor/skills/` 檔名再新建（今次 repo 真源確實無舊檔）
