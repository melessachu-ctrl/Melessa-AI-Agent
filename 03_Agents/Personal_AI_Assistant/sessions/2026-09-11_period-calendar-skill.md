# Session｜2026-09-11｜黎 m 記日曆、`period-calendar` skill

## 做了甚麼

### Google Calendar
- 依既有格式（全日 **🩸**、粉紅色 `colorId: 4`、不佔時間、無關提醒）記今日開始日
- 對照上個月那筆（實際是 8 月 8 日，不是 8 月 10 日）

### Skill
- 建立 `period-calendar`：講「黎 m／來月經／大姨媽」即記日曆；問幾時／上個月／週期則查 🩸
- 真源：`02_Knowledge_Base/skills/period-calendar/SKILL.md`
- 本機：`~/.cursor/skills/period-calendar` → symlink
- Sasa 路由：`AGENTS.md`／`BRAIN.md`／`TOOLS.md`／`MEMORY.md`
- **不**加入 UIUX-Skills manifest（個人健康 skill，不發 `#uiux-designer`）

## 未完成甚麼

- 無阻塞

## 下次由哪裡開始

- 之後講「黎 m」即記；問「上個月幾時黎 m」即查日曆
- UIUX Design Agent PoC（Step 0–3）— 見 `TASKS.md`

## 今日學到

- 全日活動若用 `YYYY-MM-DDT00:00:00+08:00` 會被寫成前一日；要用 UTC `T00:00:00Z`，並核對回傳的 `start.date`
- `search_events` 對 emoji／「period」不可靠；查 🩸 用 `list_events` + `fullText`

## 備註

- session／MEMORY **不列**歷次日期；日期以 Google Calendar 為準
