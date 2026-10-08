# Session｜2026-10-08｜figma-implement-design → figma-design-to-code

## 做了甚麼

### 查官方 Figma skills

- 從 Cursor Figma plugin（figquery）取出：`figma-use`、`figma-generate-library`、`figma-generate-design`、`figma-design-to-code`（副本在 `tmp/figma-skills/`，gitignore，不 commit）
- 確認官方 **已無** `figma-implement-design`：`figma/mcp-server-guide` `main` 與 docs 頁皆 404；後繼名為 **`figma-design-to-code`**
- 兩者職責相同（Figma → production code）；新版改為呼叫 `get_design_context` 前的硬性 MUST 規則（含 Code Connect／asset 落地）

### 真源更新（已在 main）

- `02_Knowledge_Base/skills/uiux-design-studio/SKILL.md`：description 清單＋「讀設計稿／從 Figma 實作」改指 `figma-design-to-code`
- `sync/cursor-rules/hktvmall-figma-design-system.mdc`：同上
- 相關 commit：`f739b6c`（studio）、`ca9cc41`（rule）

### 下游

- UIUX-Skills 已 sync（含 `@ ca9cc41`／後續）；下游 `uiux-design-studio` 與 `hktvmall-figma-design-system` 已是 `figma-design-to-code`

## 未完成甚麼

- Designer 本機需跑 `./scripts/update-skills.sh` 才拿到新版路由名稱

## 分發

- Melessa push（session／log）：`b1164d8`
- Skill／rule 變更先前已在 `f739b6c`／`ca9cc41`；下游 UIUX-Skills 已 sync（含 `@ ca9cc41`）
- Slack：https://hktvitlo.slack.com/archives/C02TNPKRE81/p1791445058724039

## 下次由哪裡開始

- 無阻塞；若仍見舊名 `figma-implement-design` 出現在其他文件再搜一次清乾淨

## 今日學到

- Cursor 實際載入的 Figma skill 清單以 plugin／MCP `skill://index.json` 為準；公開 docs／搜尋索引可能滯後
- `figma-implement-design` 與 `figma-design-to-code` 是改名＋改寫法，不是兩條並行路徑
