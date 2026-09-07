# Session｜2026-09-07｜UIUX-Skills rules 雙軌：Melessa sync 自動產生 `.md`

## 做了甚麼

### 背景（UIUX-Skills，2026-09-04）

- UIUX-Skills 改為規則雙軌：Cursor 繼續用 `.mdc`；另提供同內容 `.md`（ChatGPT／Codex／Claude／Spaces）。
- 下游新增 `scripts/export-rules-md.sh`；`update-skills.sh` 本機會 regen `.md`。
- 當時評估：Sasa／Cursor 日常**不用改**；缺口在 Melessa → 下游 sync 只複製 `.mdc`，git 裡的 `.md` 會漂移。

### Melessa 真源／sync（本 session 實作）

- `sync/sync-uiux-skills.sh`：複製每個 `*.mdc` 時，一併寫出同內容的 `rules/*.md`
- `sync/README.md`：說明雙軌；Melessa 只維護 `.mdc`，portable `.md` 由 sync 產生

本機空目錄試跑：兩個 rule 均產出 `.mdc` + `.md`，內容一致。

## 下游與公告

- Melessa push：`5fc4b6d` → `main`
- Actions **Sync UIUX-Skills**：成功（[run 34075394128](https://github.com/melessachu-ctrl/Melessa-AI-Agent/actions/runs/34075394128)）
- Slack `#uiux-designer`：https://hktvitlo.slack.com/archives/C02TNPKRE81/p1788747161287699
- UIUX-Skills `CONTRIBUTING.md`：改為「Melessa sync 會一併寫 `.md`」，本機改 `.mdc` 才需 `export-rules-md.sh`

## 未完成甚麼

- （無阻塞）下次改 `sync/cursor-rules/*.mdc` 時，確認 Actions 下游 commit 含對應 `.md`

## 下次由哪裡開始

- UIUX Design Agent PoC 仍在進行中（見 `TASKS.md`）
- 下次改 `sync/cursor-rules/*.mdc` 後，確認 Actions commit 含對應 `.md`

## 今日學到

- 下游為 Spaces／非 Cursor agent 加 `.md` 副本時，真源 repo 的 sync 必須同時寫出 twin，否則 git 與本機 `update-skills.sh` 會分叉
