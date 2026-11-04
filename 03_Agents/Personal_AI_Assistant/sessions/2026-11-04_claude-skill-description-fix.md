# Session｜2026-11-04｜Claude 安裝失敗：收窄三份 skill description

## 做了甚麼

Claude 安裝 UIUX-Skills 時有三份 `SKILL.md` 失敗。對過 `Downloads/uiux-skills-claude-fix.patch` 後，改 Melessa 真源，沒有整段貼回舊 description。

- `audit-design-system`、`fix-design-system-finding`：description 加引號。原文不變（292、299 字）。未加引號時 `drift: missing`、`cluster): swap` 的冒號加空格會讓 YAML 解析失敗。
- `uiux-design-studio`：description 由 1227 字縮到 593 字（上限 1024）。保留虛擬角色、改版／視覺升級、a11y／WCAG、Screen Token Bind Gate、三個 Design System 的 fileKey，以及要連帶讀的 skill。
- 沒有把舊 description 貼進正文。那些閘門、fileKey、`120:1278`、轉換型畫面與 SaaS 版式限制，正文裡已經有。description 是決定要不要載入 skill 時唯一會看的欄位，貼進正文補不回觸發。

同步清單其餘 13 個 skill 的 YAML 與字數都過關。最接近上限的是 `uiux-review`（992）、`copywriting`（989）、`offers`（969）。

## 分發

- Melessa：`6feacaa` 已在 `main`
- Actions：[Sync UIUX-Skills #30](https://github.com/melessachu-ctrl/Melessa-AI-Agent/actions/runs/41802430867) 成功
- UIUX-Skills：[chore(sync): from Melessa @ 6feacaa](https://github.com/melessachu-ctrl/UIUX-Skills/commit/4a9dc21e55c9246247ae139ab1ce1189b5856967)
- Slack：https://hktvitlo.slack.com/archives/C02TNPKRE81/p1793782217890839

## 未完成甚麼

- 設計師要在 UIUX-Skills 跑 `./scripts/update-skills.sh`，再在 Claude 重裝這三份 skill

## 下次由哪裡開始

- 設計師在 UIUX-Skills 跑 `./scripts/update-skills.sh`，再在 Claude 重裝這三份 skill
- 若再改 description，先數字數（≤1024），含 `: ` 的句子要加引號

## 今日學到

- Claude skill 的 `description` 最長 1024 字，而且 frontmatter 必須是合法 YAML
- 冒號後面有空格、又沒加引號，會被當成新欄位
