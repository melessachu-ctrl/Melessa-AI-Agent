# Session｜2026-10-27｜apple-design 有條件載入＋獨立月更同步

## 做了甚麼

### 決策

- 留著 [dickwu/apple-design-skill](https://github.com/dickwu/apple-design-skill)，但**平時不載入**
- App 設計或評審只有畫面包含 Apple 原生功能（Apple Pay、Sign in with Apple、系統權限／通知／Widget／Live Activity／Dynamic Island、系統 alert／sheet／picker、系統控制項上的 SF Symbols、iPhone Duo 系統列、系統 chrome 上的 Liquid Glass、App Review 因設計被拒）才讀
- 只核對該控制項是否符合 HIG。品牌、密度、文案、token 仍以 Ricky 與 HKTVmall／Lite App Design System 為準
- 月更**不要**併入「Monthly ui-ux-pro-max dependency audit」。pro-max 那條在上游失敗時會整段停止
- skill 要進 UIUX-Skills，因為 `uiux-design-studio` 會叫 agent 去讀它

### 真源與閘門

- 同步上游 `914b6a3`（2026-10-15）到 `02_Knowledge_Base/skills/apple-design/`（136 檔）＋ `.upstream-sync.json`
- `sync/apple-design-description.txt` 在覆蓋後收窄 `SKILL.md` description，避免「任何 review my design 都要用」
- 本機 symlink：`~/.cursor/skills/apple-design`
- 閘門寫入 `uiux-design-studio`（「Apple native function」）與 `uiux-review`
- 加入 `sync/uiux-skills-manifest.json`

### 月更

- GitHub Action「Sync apple-design upstream」：每月 1 號 09:15 HKT；有更新才 commit `main` 並觸發 Sync UIUX-Skills
- Cursor Automation 草稿：`sync/cursor-automation-apple-design-monthly.md`。編輯器已打開 **Monthly apple-design sync check**（每月 1 號 10:30、Cloud、`Melessa-AI-Agent` `main`）。儲存由 Melessa 在 Automations UI 按 Save

## 未完成甚麼

- Automations UI 若尚未按 Save，月更通知不會跑。GHA 本身不依賴這條 Automation

## 分發

- Melessa push：`750b414`（skill commit `e350ea0`，其後 merge `origin/main` 的 timesheet skill）
- Actions：[Sync UIUX-Skills](https://github.com/melessachu-ctrl/Melessa-AI-Agent/actions/runs/40455148543) success
- UIUX-Skills：`d222652` `chore(sync): from Melessa @ 750b414`（`skills/apple-design/SKILL.md` 已在下游）
- Slack：https://hktvitlo.slack.com/archives/C02TNPKRE81/p1793078738351759

## 下次由哪裡開始

- 設計師跑 `./scripts/update-skills.sh`
- 確認 Automations 裡 **Monthly apple-design sync check** 已 Save
- 下次月更看 Actions「Sync apple-design upstream」與 `#melessa-cursor`

## 今日學到

- 上游 skill 的 description 若寫「任何 review 都要用」，symlink 後平時也會被自動載入。收窄 description 要放在 skill 目錄以外，否則下次覆蓋會被蓋回
- Bash 的 `$(...)` 會被 Ruby 程式裡的括號提前截斷；同步腳本改把結果寫進暫存檔再讀
