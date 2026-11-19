# Session｜2026-11-19｜安裝 html-ppt skill

## 做了甚麼

### Skill `html-ppt`

- 自 [lewislulu/html-ppt-skill](https://github.com/lewislulu/html-ppt-skill) vendor 入 Melessa 真源：`02_Knowledge_Base/skills/html-ppt/`
- 上游 commit `fd16290`（`chore: remove tracked .DS_Store from templates (#10)`）；寫入 `.upstream-sync.json`
- 略過 `docs/`（README 配圖）；保留 `SKILL.md`、`assets/`、`templates/`、`references/`、`scripts/`、`examples/`、`LICENSE`（MIT）
- 本機 symlink：`~/.cursor/skills/html-ppt` → Melessa 真源（`setup-symlinks.sh`）
- Melessa push：`3b020a4`；Actions **Sync UIUX-Skills** 成功（https://github.com/melessachu-ctrl/Melessa-AI-Agent/actions/runs/44500885833）；`html-ppt` **不在** manifest → 下游無此 skill；**未發** `#uiux-designer`

### Sasa 路由

- `AGENTS.md` #18、`BRAIN.md`、`TOOLS.md`、`MEMORY.md`、`LOG.md`、`TASKS.md`
- `02_Knowledge_Base/skills/README.md`：標明 Melessa 自用、不進 UIUX-Skills

## 未完成 / 待 Melessa

- （可選）若要設計師也用，再把 `html-ppt` 加入 `sync/uiux-skills-manifest.json`
- （可選）之後若要跟上游月更，可仿 `apple-design` 加 GHA／Automation

## 下次由哪裡開始

- 講「做一份 PPT／slides／pitch deck／技術分享」→ Agent 讀 `html-ppt`，先確認內容／主題／模板再 scaffold

## 今日學到

- 上游官方路徑也可 `npx skills add`；Melessa 慣例仍是 vendor 到 `02_Knowledge_Base/skills/` + symlink
- 改 `skills/**` 會觸發 Sync UIUX-Skills Actions，但 skill **不在 manifest** → 下游不會拿到 `html-ppt`；**毋須** `#uiux-designer` 公告

## 反思

- 做得好：對齊既有 vendored skill（`.upstream-sync.json`）與 Sasa 路由收尾
- 可改進：若常用且要跟上游，再補月更腳本，唔好人手重 clone
