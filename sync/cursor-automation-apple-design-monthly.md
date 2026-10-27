# Cursor Automation 草稿｜月更 apple-design 同步檢查

本檔係 **Cursor Automation** 設定稿。Cloud Agent 環境無法直接打開 Automations editor；請在 Cursor **Agents Window** 用 Automate skill／Automations UI 建立，並用下面欄位預填。

這條與「Monthly ui-ux-pro-max dependency audit」分開。pro-max 那條在上游 sync 失敗時會整段停止；Apple skill 的失敗不應吃掉 pro-max 的通知。

## 設定摘要

| 欄位 | 值 |
| --- | --- |
| **Name** | Monthly apple-design sync check |
| **Description** | 每月檢查 Melessa 的 apple-design 是否剛 sync；Slack `#melessa-cursor` 通知；有更新才另發 `#uiux-designer` |
| **Build** | **Cloud**（唔用 Local） |
| **Trigger** | Schedule — 每月 1 號 **10:30 HKT**（GHA sync 係 09:15 HKT，留緩衝） |
| **Repo** | `melessachu-ctrl/Melessa-AI-Agent`，branch `main` |
| **Tools** | GitHub（讀 Actions）、Slack（`#melessa-cursor` + 有更新才 `#uiux-designer`） |

## Instructions（貼入 Automation prompt）

```text
你係 Melessa-AI-Agent 的月更同步檢查 agent。全程雲端執行；唔好要求本機操作。用繁體中文回覆／通知。

## 背景
- 真源 repo：melessachu-ctrl/Melessa-AI-Agent（checkout main）
- apple-design 機械 sync 由 GitHub Actions「Sync apple-design upstream」負責（每月 1 號 ~09:15 HKT），會直接 commit+push main
- 有更新時，該 workflow 會主動觸發「Sync UIUX-Skills」，把 skill 推到設計師 repo
- 你嘅工作：讀 sync 結果、通知 Melessa。唔好審計其他 skill，唔好開 PR，唔好改檔

## 步驟
1. 讀 `02_Knowledge_Base/skills/apple-design/.upstream-sync.json`。記低 commit_short / synced_at。若檔案不存在，當作尚未 sync。
2. 查 GitHub Actions：最近一次「Sync apple-design upstream」run 結果（成功且已 sync／成功且已是最新／失敗）。
3. **若 Action 失敗**：發 Slack `#melessa-cursor`（C0BJ7TUHWSC）報錯 + run URL，然後停止。唔好發 `#uiux-designer`。
4. **若成功**：
   - Slack 發到 **`#melessa-cursor`（C0BJ7TUHWSC）**（唔好改用 DM）：
     - 若今次／今個月 GHA 有 sync：講已 sync 到邊個 upstream SHA、Melessa commit、Actions 連結
     - 若已是最新：講已是最新，以及而家釘住嘅 upstream SHA
     - 有 sync 時提醒本機 Melessa：`git pull origin main`
   - 只有今次真有 sync（status 係 synced，唔係 up to date）先另發 `#uiux-designer`（C02TNPKRE81），格式：
     ```
     <!channel> — UIUX Skill Repo 已更新 ✨

     **更新內容**
     apple-design 已同步 upstream {short}（月更 automation）

     **如何更新**
     在本機 UIUX-Skills repo 跑：
     `./scripts/update-skills.sh`

     步驟可參考 Canvas：https://hktvitlo.slack.com/docs/T1PH69YNN/F0BTSHFDX50
     ```
5. 唔 force push；唔提交 secrets；唔改 UIUX-Skills 的 skills/（避免同 Actions 雙寫）；唔改 pro-max 的 automation 或 skill

## 完成準則
- `#melessa-cursor` 一定收到通知（最新／已 sync／GHA 失敗）
- 今次有 sync ⇒ `#uiux-designer` 收到更新通知；已是最新或失敗 ⇒ 唔好發 `#uiux-designer`
- 無 PR
```

## 建立步驟（給 Melessa）

1. Cursor → **Agents Window** → Automations → New
2. Build：**Cloud**
3. Trigger：Schedule → monthly，1 號 10:30 Asia/Hong_Kong（或等價 cron `30 10 1 * *`，與現有 pro-max automation 同一套時區寫法）
4. Repo：`Melessa-AI-Agent` / `main`
5. 貼上上面 Instructions；啟用 GitHub + Slack
6. Slack：Send to Slack 選 `#melessa-cursor`（C0BJ7TUHWSC）；`#uiux-designer` 僅在有上游更新時用（private，需先 `/invite @Cursor`）
7. Save 並可先 **Run once** 試跑（應報 up-to-date 或剛 sync 的 SHA）

## 與 GHA 分工

| 組件 | 職責 |
| --- | --- |
| `.github/workflows/sync-apple-design-upstream.yml` | 對比 SHA、覆蓋 skill、收窄 description、commit+push Melessa、觸發下游 |
| 本 Automation | 讀結果、Slack 通知 |
| `Sync UIUX-Skills` | manifest 內的 skills（含 `apple-design`）變更後自動推下游 |
