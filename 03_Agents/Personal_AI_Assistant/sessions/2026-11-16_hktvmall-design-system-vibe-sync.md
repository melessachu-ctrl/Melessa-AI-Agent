# Session｜2026-11-16｜Sync hktvmall-design-system／vibe-prototype 到 Melessa＋UIUX-Skills

## 做了甚麼

Melessa 要比對本機 `HKTV/hktvmall-design` 與 Melessa skills，並把只在 plugin 的兩個 skill 收進 Melessa 真源與 UIUX-Skills：

1. 盤點：hktvmall-design 20 skills；Melessa 40；overlap 17；只在 hktvmall-design 有 `hktvmall-design-rules`、`hktvmall-design-system`、`hktvmall-vibe-prototype`
2. 決定：**sync** `hktvmall-design-system`、`hktvmall-vibe-prototype`；**不 sync** `hktvmall-design-rules`（內容＝既有 cursor-rules）
3. 真源：`02_Knowledge_Base/skills/hktvmall-design-system/`、`…/hktvmall-vibe-prototype/`（自 plugin 拷貝；交叉引用改指 rules）
4. `.gitignore`：為 DS token 路徑加白名單（否則 `*token*` 擋死 `tokens/`）
5. `sync/uiux-skills-manifest.json`：17 → **19** skills；`skills/README.md` 說明更新
6. 本機 `~/.cursor/skills` symlink 已建

## 分發

- Melessa：`93581dd` 已在 `main`
- Actions：[Sync UIUX-Skills](https://github.com/melessachu-ctrl/Melessa-AI-Agent/actions/runs/43827064184) 成功
- UIUX-Skills：[chore(sync): from Melessa @ 93581dd](https://github.com/melessachu-ctrl/UIUX-Skills/commit/8004977)
- Slack：https://hktvitlo.slack.com/archives/C02TNPKRE81/p1794816317384559

## 關於 hktvmall-design-rules

- Melessa／UIUX-Skills 已有同等內容：`hktvmall-figma-design-system`、`hktvmall-ui-price`、`marketing-buddy-ds`、`lite-app-figma-design-tokens`（rules 雙軌）
- 不 sync 唔會令 Figma／評審 skill 壞掉；該 skill 只係 Claude plugin 把 alwaysApply rules 包成可 Read 的索引
- 留在 `hktvmall-design` Claude plugin 即可，避免三處維護

## 未完成甚麼

- 設計師要在 UIUX-Skills 跑 `./scripts/update-skills.sh`，新開 Agent chat 才載入
- 本機 `/Users/mchu/UIUX-Skills` clone 可能仍 dirty／落後；以 remote `8004977` 為準，本機自行 `git pull --ff-only` 或 `update-skills.sh`
- Melessa `uiux-design-studio` 尚未寫死 `deliveryMode=code|mixed` → 必讀 vibe-prototype（plugin 文案有提；兩邊 studio 正文暫未有）；若要自動路由可另開 session

## 下次由哪裡開始

- 設計師跑 `./scripts/update-skills.sh`
- 若要 vibe code 由 studio 強制路由，在 `uiux-design-studio` 加 `deliveryMode`／Code Token Bind Gate 段落

## 今日學到

- Melessa `.gitignore` 的 `*token*` 會誤傷 Design System skill 的 `tokens/`；新增 skill 含 token 檔時要先開白名單
- `hktvmall-design-rules` ≠ 新規則；是 Cursor rules 的 Claude 包裝
