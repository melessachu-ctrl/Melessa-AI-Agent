# Cursor Automation 草稿｜月更 ui-ux-pro-max 依賴檢查

本檔係 **Cursor Automation** 設定稿。Cloud Agent 環境無法直接打開 Automations editor；請在 Cursor **Agents Window** 用 Automate skill／Automations UI 建立，並用下面欄位預填。

## 設定摘要

| 欄位 | 值 |
| --- | --- |
| **Name** | Monthly ui-ux-pro-max dependency audit |
| **Description** | 每月檢查 Melessa 的 ui-ux-pro-max 是否剛 sync；審計依賴 skills；Slack DM 通知 Melessa；有改動則開 PR 等確認 |
| **Build** | **Cloud**（唔用 Local） |
| **Trigger** | Schedule — 每月 1 號 **10:00 HKT**（GHA sync 係 09:00 HKT，留 1 小時緩衝） |
| **Repo** | `melessachu-ctrl/Melessa-AI-Agent`，branch `main` |
| **Tools** | GitHub（讀／開 PR）、Slack（DM + 可選 `#uiux-designer`） |

## Instructions（貼入 Automation prompt）

```text
你係 Melessa-AI-Agent 的月更依賴檢查 agent。全程雲端執行；唔好要求本機操作。用繁體中文回覆／通知。

## 背景
- 真源 repo：melessachu-ctrl/Melessa-AI-Agent（checkout main）
- ui-ux-pro-max 機械 sync 由 GitHub Actions「Sync ui-ux-pro-max upstream」負責（每月 1 號 ~09:00 HKT），會直接 commit+push main
- 下游 UIUX-Skills 由既有「Sync UIUX-Skills」workflow 自動更新
- 你嘅工作：讀最新 skill、檢查依賴 skills 要唔要改、通知 Melessa

## 步驟
1. 讀 `02_Knowledge_Base/skills/ui-ux-pro-max/.upstream-sync.json` 同 `SKILL.md`、`references/quick-reference.md`。記低 commit_short / synced_at。
2. 查 GitHub Actions：最近一次「Sync ui-ux-pro-max upstream」run 結果（成功／已是最新／失敗）。若失敗，Slack DM Melessa 報錯 + run URL，然後停止。
3. 審計依賴 skills（至少）：
   - `02_Knowledge_Base/skills/uiux-review/SKILL.md`
   - `02_Knowledge_Base/skills/uiux-design-studio/SKILL.md`
   - `02_Knowledge_Base/skills/figma-file-cleanup/SKILL.md`
   - `02_Knowledge_Base/skills/ricky-design-guideline/SKILL.md`
   對照 ui-ux-pro-max 新結構：Quick Reference 應指向 `references/quick-reference.md`（唔應假設全文喺 SKILL.md）；破路徑、過時 § 假設、遺失檔案引用都記低。
4. **若無需改依賴 skills**：
   - Slack **DM Melessa**（唔好只發 channel）：
     - 若今次／今個月 GHA 有 sync：講已 sync 到邊個 upstream SHA、Melessa commit、Actions 連結
     - 若已是最新：講已是最新
     - 一定提醒：
       - 本機 Melessa：`git pull origin main`
       - 若有推到 UIUX-Skills：設計師跑 `./scripts/update-skills.sh`（Canvas：https://hktvitlo.slack.com/docs/T1PH69YNN/F0BTSHFDX50）
   - 若今次真有更新 UIUX-Skills，另發 `#uiux-designer`（C02TNPKRE81），格式：
     ```
     <!channel> — UIUX Skill Repo 已更新 ✨

     **更新內容**
     ui-ux-pro-max 已同步 upstream {short}（月更 automation）

     **如何更新**
     在本機 UIUX-Skills repo 跑：
     `./scripts/update-skills.sh`

     步驟可參考 Canvas：https://hktvitlo.slack.com/docs/T1PH69YNN/F0BTSHFDX50
     ```
5. **若依賴 skills 需要改**：
   - **唔好**直接 push main
   - 開 feature branch（`cursor/ui-ux-pro-max-dep-fix-…`）放建議改動，開 Melessa **draft PR** 指向 main
   - Slack DM Melessa：附 PR 連結，請確認後再 merge；說明 ui-ux-pro-max 本體若已上 main 就只審依賴改動
6. 唔 force push；唔提交 secrets；唔改 UIUX-Skills 的 skills/（避免同 Actions 雙寫）

## 完成準則
- Melessa 一定收到 Slack DM（最新／已 sync／有 PR 等確認／GHA 失敗）
- 有依賴改動 ⇒ 有 PR；無 ⇒ 無 PR
```

## 建立步驟（給 Melessa）

1. Cursor → **Agents Window** → Automations → New
2. Build：**Cloud**
3. Trigger：Schedule → monthly，1 號 10:00 Asia/Hong_Kong（或等價 cron）
4. Repo：`Melessa-AI-Agent` / `main`
5. 貼上上面 Instructions；啟用 GitHub + Slack
6. Slack：DM 目標選 Melessa 自己；`#uiux-designer` 僅在有下游更新時用
7. Save 並可先 **Run once** 試跑（應報 up-to-date 或開空審計）

## 與 GHA 分工

| 組件 | 職責 |
| --- | --- |
| `.github/workflows/sync-ui-ux-pro-max-upstream.yml` | 對比 SHA、覆蓋 skill、commit+push Melessa |
| 本 Automation | 依賴審計、PR（如需）、Slack 通知 |
| `Sync UIUX-Skills` | Melessa skills 變更後自動推下游 |

可選：repo Secrets `SLACK_BOT_TOKEN` + `SLACK_DM_USER_ID` 令 GHA 亦發簡易 DM；無則只靠本 Automation。
