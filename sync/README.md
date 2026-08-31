# UIUX-Skills 下游同步

Melessa 為 skill 內容真源；[`uiux-skills-manifest.json`](uiux-skills-manifest.json) 定義要同步到 [UIUX-Skills](https://github.com/melessachu-ctrl/UIUX-Skills) 的清單。

## 自動同步

Push 到 `main` 且變更 `02_Knowledge_Base/skills/**`、manifest 或 workflow 時，GitHub Actions 會執行 [`.github/workflows/sync-uiux-skills.yml`](../.github/workflows/sync-uiux-skills.yml)。

## 設定 Secret（一次性）

在 Melessa repo → Settings → Secrets and variables → Actions：

| Secret | 說明 |
| --- | --- |
| `UIUX_SKILLS_SYNC_TOKEN` | GitHub PAT，對 `melessachu-ctrl/UIUX-Skills` 有 Contents Read and write |

建議使用 fine-grained token，僅授權 UIUX-Skills repo。

## 手動補跑

GitHub → Actions → **Sync UIUX-Skills** → Run workflow。

## Cursor Rules

`sync/cursor-rules/` 內的 `.mdc` 會一併同步到 UIUX-Skills `rules/`，供 teammate 手動安裝。
