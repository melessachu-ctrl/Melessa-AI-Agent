# Cursor Automation 草稿｜月更 marketingskills 同步檢查

本檔係 **Cursor Automation** 設定稿。請在 Cursor **Agents Window** 用 Automations editor 建立，並用下面欄位預填。

這條與「Monthly ui-ux-pro-max dependency audit」、「Monthly apple-design sync check」分開。其中一條失敗不應吃掉另外兩條的通知。

## 設定摘要

| 欄位 | 值 |
| --- | --- |
| **Name** | Monthly marketingskills sync check |
| **Description** | 每月檢查 12 個 marketing skills 是否剛 sync；對一下 studio／review；Slack `#melessa-cursor`；4 個設計師 skill 正文有變才另發 `#uiux-designer` |
| **Build** | **Cloud**（唔用 Local） |
| **Trigger** | Schedule — 每月 1 號 **10:45 HKT**（GHA sync 係 09:30 HKT，留緩衝；並避開 10:00 pro-max、10:30 apple-design） |
| **Repo** | `melessachu-ctrl/Melessa-AI-Agent`，branch `main` |
| **Tools** | GitHub（讀 Actions、必要時開 draft PR）、Slack（`#melessa-cursor` + 有正文更新才 `#uiux-designer`） |

## Instructions（貼入 Automation prompt）

```text
你係 Melessa-AI-Agent 的月更同步檢查 agent。全程雲端執行；唔好要求本機操作。用繁體中文回覆／通知。

## 背景
- 真源 repo：melessachu-ctrl/Melessa-AI-Agent（checkout main）
- 12 個 marketing skills 的機械 sync 由 GitHub Actions「Sync marketingskills upstream」負責（每月 1 號 ~09:30 HKT），會直接 commit+push main
- 有更新時，該 workflow 會主動觸發「Sync UIUX-Skills」。設計師只會收到 cro、offers、copywriting、copy-editing。其餘 8 個留在 Melessa
- 你嘅工作：讀 sync 結果、對一下設計流程是否仍對得上、通知 Melessa。唔好改嗰 12 個 skill 本體

## 步驟
1. 讀 `02_Knowledge_Base/skills/cro/.upstream-sync.json`（其餘 11 個 stamp 應係同一個 commit）。記低 commit_short / synced_at。若檔案不存在，當作尚未 sync。
2. 查 GitHub Actions：最近一次「Sync marketingskills upstream」run 結果（成功且已 sync／成功且已是最新／失敗／搵唔到呢條 workflow）。
3. **若 Action 失敗或搵唔到**：發 Slack `#melessa-cursor`（C0BJ7TUHWSC）報錯 + run URL，然後停止。唔好發 `#uiux-designer`。
4. **若成功**：
   - 對照今次 diff：`cro`、`offers`、`copywriting`、`copy-editing` 嘅正文（唔計 `.upstream-sync.json`）有冇變。
   - 審計依賴 skills：
     - `02_Knowledge_Base/skills/uiux-design-studio/SKILL.md`
     - `02_Knowledge_Base/skills/uiux-review/SKILL.md`
     只睇轉換型畫面：七個檢查、優惠、標題／按鈕寫法、Conversion Pass。上游改咗檢查名、刪咗步驟、或 studio／review 引用咗已經唔存在嘅檔，先算要改。
   - **無需改依賴**：
     - Slack 發到 `#melessa-cursor`（C0BJ7TUHWSC）（唔好改用 DM）：
       - 若今次／今個月 GHA 有 sync：講已 sync 到邊個 upstream SHA、Melessa commit、Actions 連結
       - 若已是最新：講已是最新，以及而家釘住嘅 upstream SHA
       - 有 sync 時提醒本機 Melessa：`git pull origin main`
       - 若只係其餘 8 個或 stamp 變、4 個正文冇變：講設計師唔使跑 update-skills.sh
     - 只有 `cro`、`offers`、`copywriting`、`copy-editing` 正文有變，先另發 `#uiux-designer`（C02TNPKRE81），格式：
       ```
       <!channel> — UIUX Skill Repo 已更新 ✨

       **更新內容**
       轉換檢查 skills 已同步 upstream {short}（月更 automation）。設計師會收到 cro、offers、copywriting、copy-editing。

       **如何更新**
       在本機 UIUX-Skills repo 跑：
       `./scripts/update-skills.sh`

       步驟可參考 Canvas：https://hktvitlo.slack.com/docs/T1PH69YNN/F0BTSHFDX50
       ```
   - **依賴 skills 需要改**：
     - 唔好直接 push main
     - 開 feature branch（`cursor/marketingskills-dep-fix-…`）放建議改動，開 Melessa **draft PR** 指向 main
     - Slack `#melessa-cursor`：附 PR 連結，請確認後再 merge
     - 4 個正文有變先另發上面嘅 `#uiux-designer` 公告
5. 唔 force push；唔提交 secrets；唔改 UIUX-Skills 的 skills/（避免同 Actions 雙寫）；唔改 pro-max 或 apple-design 的 automation 或 skill

## 完成準則
- `#melessa-cursor` 一定收到通知（最新／已 sync／有 PR 等確認／GHA 失敗）
- 4 個設計師 skill 正文有變 ⇒ `#uiux-designer` 收到更新通知；已是最新、只改其餘 8 個、或失敗 ⇒ 唔好發 `#uiux-designer`
- 有依賴改動 ⇒ 有 draft PR；無 ⇒ 無 PR
```

## 建立步驟（給 Melessa）

1. Cursor → **Agents Window** → Automations → New
2. Build：**Cloud**
3. Trigger：Schedule → monthly，1 號 10:45 Asia/Hong_Kong（或等價 cron `45 10 1 * *`，與現有 pro-max／apple-design automation 同一套時區寫法）
4. Repo：`Melessa-AI-Agent` / `main`
5. 貼上上面 Instructions；啟用 GitHub + Slack
6. Slack：Send to Slack 選 `#melessa-cursor`（C0BJ7TUHWSC）；`#uiux-designer` 僅在 cro／offers／copywriting／copy-editing 正文有變時用（private，需先 `/invite @Cursor`）
7. Save 並可先 **Run once** 試跑（應報 up-to-date，或話條 workflow 尚未上 main）

## 與 GHA 分工

| 組件 | 職責 |
| --- | --- |
| `.github/workflows/sync-marketingskills-upstream.yml` | 對比 SHA、覆蓋 12 個 skill、commit+push Melessa、觸發下游 |
| 本 Automation | 讀結果、對 studio／review、draft PR（如需）、Slack 通知 |
| `Sync UIUX-Skills` | manifest 內的 `cro`、`offers`、`copywriting`、`copy-editing` 推給設計師 |
