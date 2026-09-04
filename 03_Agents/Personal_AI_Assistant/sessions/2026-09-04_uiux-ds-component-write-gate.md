# Session｜2026-09-04｜uiux-design-studio DS Component Write Gate

## 做了甚麼

### 問題

- Designer 回報：用 `uiux-design-studio` **update／create Design System component** 時，未自動做 auto-layout、未用 font token。

### Skill／規則更新（真源）

- `02_Knowledge_Base/skills/uiux-design-studio/SKILL.md`：新增強制 **DS Component Write Gate**
  - Gate A：auto-layout（容器不得無故 `layoutMode=NONE`）
  - Gate B：font／Text Style token（Lite App → Design Tokens；其餘 → 目標 DS）
  - Gate C：leaf-only layer naming（對齊 `figma-file-cleanup`）
  - 寫入前必讀 `figma-use` + `figma-generate-library` + cleanup 命名／layout；未過 Gate 不得交件
  - DS Owner／Review／Final Pack 模板同步
- `02_Knowledge_Base/skills/figma-file-cleanup/SKILL.md`：命名對 DS 元件寫入改為強制；補 auto-layout 對齊說明
- `02_Knowledge_Base/skills/apply-design-system/SKILL.md`：新建／更新 DS 元件時指向 Write Gate
- `~/.cursor/rules/uiux-design-studio.mdc`：Guardrails 補 auto-layout／font token／leaf-only
- `~/.cursor/rules/hktvmall-figma-design-system.mdc`、`lite-app-figma-design-tokens.mdc`：必做流程補 Write Gate
- `sync/cursor-rules/`：上述兩條跨專案規則已同步（供 UIUX-Skills Actions 分發）

## 未完成甚麼

- （無阻塞）Designer 需於 Actions sync 後跑 `./scripts/update-skills.sh` 才拿到新版
- （可選）`#uiux-designer` 公告 skills 已更新

## 下次由哪裡開始

- 請一位 designer 用 `uiux-design-studio` 建／改一個 DS 元件，驗收 Write Gate（auto-layout + text style + leaf naming）
- 若仍漏做：再補寫入後自動掃 `layoutMode=NONE`／空 `textStyleId` 的驗證腳本範例

## 今日學到

- 僅在 Lite App／cleanup 路徑寫 soft 規範不足；DS 元件 create／update 需要獨立硬閘門，並串 Review／Final Pack
