# Skills（真源）

Sasa 與任何連到本 Melessa repo 的 AI 可讀的工作技能放這裡。

## Cursor 快捷入口

本機 Cursor 透過 symlink 全域載入（所有專案可用）：

`~/.cursor/skills/<skill-name>` → 本目錄下對應資料夾

改 skill 內容：直接改本 repo 內檔案即可，不必改 `~/.cursor/skills/`。

## 換電腦／重建 symlink

先 clone 或 pull 本 repo，再執行（路徑與 skill 清單會自動偵測，不用手改）：

```bash
bash 02_Knowledge_Base/skills/setup-symlinks.sh
```

或從 skills 目錄內：

```bash
bash setup-symlinks.sh
```

## 新增 skill

1. 在本目錄建立 `<skill-name>/SKILL.md`
2. 在本機執行：`bash 02_Knowledge_Base/skills/setup-symlinks.sh`（或手動 `ln -sfn "<本目錄絕對路徑>/<skill-name>" "$HOME/.cursor/skills/<skill-name>"`）
3. 更新 Sasa 的 `TOOLS.md`／`BRAIN.md`／`AGENTS.md`（若需要）

## 下游分發（UIUX-Skills）

設計師 teammate 使用的下游 repo：[melessachu-ctrl/UIUX-Skills](https://github.com/melessachu-ctrl/UIUX-Skills)

- **真源**：本目錄（Melessa）；**下游**：UIUX-Skills 的 `skills/`
- Push 到 Melessa `main` 且變更本目錄時，GitHub Actions 會自動 sync（見 [`sync/README.md`](../../sync/README.md)）
- Sync 清單定義於 [`sync/uiux-skills-manifest.json`](../../sync/uiux-skills-manifest.json)（11 個 UI/UX skills + 2 個 cursor rules）
- Teammate 在 UIUX-Skills 的 skill 改動須 **PR 回 Melessa**，不可只改下游

## 不放在這裡

Cursor 內建 skills 在 `~/.cursor/skills-cursor/`，由系統管理，不要搬入本 repo。
