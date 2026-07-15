# Skills（真源）

Sasa 與任何連到本 Melessa repo 的 AI 可讀的工作技能放這裡。

## Cursor 快捷入口

本機 Cursor 透過 symlink 全域載入（所有專案可用）：

`~/.cursor/skills/<skill-name>` → 本目錄下對應資料夾

改 skill 內容：直接改本 repo 內檔案即可，不必改 `~/.cursor/skills/`。

## 換電腦／重建 symlink

先 clone 本 repo，再執行：

```bash
SKILLS_DST="/Users/mchu/Melessa AI Agent/02_Knowledge_Base/skills"
SKILLS_SRC="$HOME/.cursor/skills"
mkdir -p "$SKILLS_SRC"

for name in \
  apply-design-system \
  audit-design-system \
  figma-file-cleanup \
  figma-mcp-server-guide \
  fix-design-system-finding \
  frontend-design \
  hktvmall-target-customers \
  ricky-design-guideline \
  ui-ux-pro-max \
  uiux-design-studio \
  uiux-review
do
  ln -sfn "$SKILLS_DST/$name" "$SKILLS_SRC/$name"
done
```

（若 Melessa 路徑不同，先改 `SKILLS_DST`。）

## 新增 skill

1. 在本目錄建立 `<skill-name>/SKILL.md`
2. 在本機執行：`ln -sfn "<本目錄絕對路徑>/<skill-name>" "$HOME/.cursor/skills/<skill-name>"`
3. 更新上方重建清單與 Sasa 的 `TOOLS.md`／`BRAIN.md`（若需要）

## 不放在這裡

Cursor 內建 skills 在 `~/.cursor/skills-cursor/`，由系統管理，不要搬入本 repo。
