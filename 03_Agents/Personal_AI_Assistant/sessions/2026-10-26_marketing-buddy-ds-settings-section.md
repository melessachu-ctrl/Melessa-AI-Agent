# Session｜2026-10-26～10-27｜Marketing Buddy DS 整理＋Settings section＋DS 規則

## 做了甚麼

### Figma（Marketing Buddy - Design System，`dR3ATshJMDaGHOG0Y3R6Ew`）

- Soft-fork／頁面 IA 整理（Cover、MB Patterns、Components 分頁等；延續前段對話）
- Form Settings：TextField／Select 遷到 `Form/Input`（Hints off）；Inclusion UI 元件化
- 命名：`Form/Settings section`、`Form/Settings section/Row`、`Form/Settings section/Options`、`Form/File chip`；頁內 components 改 `Form/…` 並排成 3 欄
- 全 file page background：`#F5F5F5` → `#E5E5E5`（Layouts 深灰底未改）
- 釐清：DS 現有 **Styles**（paint／text／effect）；Variables collection 為空屬正常，publish library 即可跨 file 用 styles，唔一定要 migrate variables

### Cursor／分發

- 新增規則真源：`sync/cursor-rules/marketing-buddy-ds.mdc`（Melessa `.cursor/rules/` 同步一份）
  - Marketing Buddy／MKGB → 必須用 Marketing Buddy DS
  - Text／Color 必須用 DS tokens
  - Icon：先 DS；冇 → Material Symbols（Rounded + Outline）；色用 DS color tokens
- `sync/uiux-skills-manifest.json` 加入 `marketing-buddy-ds.mdc`
- `uiux-design-studio`：加 Marketing Buddy／MKGB 觸發詞與 DS 預設；description／Intake／聯動表同步

## 未完成甚麼

- Figma library **Publish**（styles／components）仍須 Melessa 在 Figma UI 手動 publish，其他 file 先啟用 library
- （可選）日後再把 color styles migrate 成 Variables（modes／semantic）；非 publish 前提

## 分發

- Melessa push：`842b7b5`
- Actions：[Sync UIUX-Skills](https://github.com/melessachu-ctrl/Melessa-AI-Agent/actions/runs/40480485519) success
- UIUX-Skills：`445221a` `chore(sync): from Melessa @ 842b7b5`（含 `rules/marketing-buddy-ds.mdc`／`.md`）
- Slack：https://hktvitlo.slack.com/archives/C02TNPKRE81/p1793093126428529

## 下次由哪裡開始

- 設計師：`./scripts/update-skills.sh` 後會有 `rules/marketing-buddy-ds.mdc`＋`.md`
- Marketing Buddy／MKGB 出稿 → 跟 `marketing-buddy-ds`＋studio 新節
- 需要跨 file 用 styles／components → 在 Figma publish Marketing Buddy DS

## 今日學到

- Figma **Styles ≠ Variables**；Variables 空唔代表冇 tokens，只係未做 variable migration
- Settings 類「標題＋可增刪列」pattern 宜叫 **Settings section**，唔好用內容標題（Inclusion）做 component 名
- `counterAxisSizingMode` 唔接受 `FILL`；橫向撐滿用 child `layoutSizingHorizontal = 'FILL'`
