# UIUX-Skills 下游同步 ＋ ui-ux-pro-max 月更

Melessa 為 skill 內容真源；[`uiux-skills-manifest.json`](uiux-skills-manifest.json) 定義要同步到 [UIUX-Skills](https://github.com/melessachu-ctrl/UIUX-Skills) 的清單。

## 自動同步（下游 UIUX-Skills）

Push 到 `main` 且變更 `02_Knowledge_Base/skills/**`、manifest 或 workflow 時，GitHub Actions 會執行 [`.github/workflows/sync-uiux-skills.yml`](../.github/workflows/sync-uiux-skills.yml)。

## 月更：ui-ux-pro-max upstream（雲端）

每月對比 [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) 的 `main`，與 Melessa 真源 stamp：

[`02_Knowledge_Base/skills/ui-ux-pro-max/.upstream-sync.json`](../02_Knowledge_Base/skills/ui-ux-pro-max/.upstream-sync.json)

| 組件 | 職責 |
| --- | --- |
| [`sync-ui-ux-pro-max-upstream.sh`](sync-ui-ux-pro-max-upstream.sh) | 對比 SHA；落後則覆蓋 skill + 寫 stamp |
| [`.github/workflows/sync-ui-ux-pro-max-upstream.yml`](../.github/workflows/sync-ui-ux-pro-max-upstream.yml) | 每月 1 號 ~09:00 HKT cron + 手動 `workflow_dispatch`；落後則 **commit + push Melessa `main`** |
| [`cursor-automation-ui-ux-pro-max-monthly.md`](cursor-automation-ui-ux-pro-max-monthly.md) | Cursor Automation（**Cloud**）草稿：依賴 skill 審計、開 PR（如需）、Slack DM |
| [`notify-ui-ux-pro-max-slack.py`](notify-ui-ux-pro-max-slack.py) | 可選：GHA 用 Slack bot 發簡易 DM |

流程：

1. GHA 跑 `sync-ui-ux-pro-max-upstream.sh`
2. 已是最新 → 結束（可選 Slack「已是最新」）
3. 有更新 → commit/push Melessa → workflow **顯式** `gh workflow run sync-uiux-skills.yml`（`GITHUB_TOKEN` push 唔會自動連鎖其他 workflow）
4. Cursor Automation（同日稍晚）審計 `uiux-review`／`uiux-design-studio`／`figma-file-cleanup`／`ricky-design-guideline`；要改則開 **draft PR** 等 Melessa 確認，唔直接 push 依賴改動

### 本機提醒（通知文案固定）

Sync 成功後：

```bash
# Melessa（本機）
git pull origin main

# UIUX-Skills（設計師）
./scripts/update-skills.sh
```

唔好在 Melessa 本機手動改 `UIUX-Skills/skills/`（避免同 Actions 雙寫）。

### 手動試跑

```bash
# 只對比／sync 工作樹（exit 0=已最新；10=已覆蓋待 commit）
bash sync/sync-ui-ux-pro-max-upstream.sh .

# 或 GitHub → Actions → Sync ui-ux-pro-max upstream → Run workflow
```

### Secrets（可選）

在 Melessa repo → Settings → Secrets and variables → Actions：

| Secret | 說明 |
| --- | --- |
| `UIUX_SKILLS_SYNC_TOKEN` | GitHub PAT，對 `melessachu-ctrl/UIUX-Skills` 有 Contents Read and write（下游 sync 必備） |
| `SLACK_BOT_TOKEN` | （可選）GHA 簡易 DM |
| `SLACK_DM_USER_ID` | （可選）Melessa 的 Slack user id（`U…`） |

無 Slack secrets 時，依賴檢查與通知靠 Cursor Automation（見草稿檔）。

## 設定 Secret（下游 sync，一次性）

在 Melessa repo → Settings → Secrets and variables → Actions：

| Secret | 說明 |
| --- | --- |
| `UIUX_SKILLS_SYNC_TOKEN` | GitHub PAT，對 `melessachu-ctrl/UIUX-Skills` 有 Contents Read and write |

建議使用 fine-grained token，僅授權 UIUX-Skills repo。

## 手動補跑下游

GitHub → Actions → **Sync UIUX-Skills** → Run workflow。

## Cursor Rules（雙軌）

真源在 `sync/cursor-rules/`，**只維護 `.mdc`**（Cursor Project Rules）。Sync 時會寫到 UIUX-Skills `rules/`：

| 下游檔 | 用途 |
| --- | --- |
| `*.mdc` | Cursor 安裝用（`cp rules/*.mdc ~/.cursor/rules/`） |
| `*.md` | 由對應 `.mdc` **同內容產生**，供 ChatGPT／Codex／Claude／Spaces 等只接受 `.md` 的環境 |

不必在 Melessa 另存一份 `.md`；腳本會在同步時自動寫出。之後改 `.mdc` 再 push，下游雙軌會一起更新，無需在 UIUX-Skills 再手工 `export-rules-md.sh`。
