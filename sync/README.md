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

## Cursor Rules（雙軌）

真源在 `sync/cursor-rules/`，**只維護 `.mdc`**（Cursor Project Rules）。Sync 時會寫到 UIUX-Skills `rules/`：

| 下游檔 | 用途 |
| --- | --- |
| `*.mdc` | Cursor 安裝用（`cp rules/*.mdc ~/.cursor/rules/`） |
| `*.md` | 由對應 `.mdc` **同內容產生**，供 ChatGPT／Codex／Claude／Spaces 等只接受 `.md` 的環境 |

不必在 Melessa 另存一份 `.md`；腳本會在同步時自動寫出。之後改 `.mdc` 再 push，下游雙軌會一起更新，無需在 UIUX-Skills 再手工 `export-rules-md.sh`。
