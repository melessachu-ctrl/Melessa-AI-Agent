# Design Index／Figma 命名 brief（PoC）

## Figma 檔案（建議）

`[Platform] / [Feature] / [Version] / [Status]`

- **Platform**：`App`｜`Web`｜`Lite App`
- **Status**：`Approved`｜`WIP`｜`Archive`

## design-index YAML 檔名

- 小寫 kebab-case，與 `id` 一致：`search-result-category-tree.yaml`
- 一 feature 一檔；多 frame 用 `figma.frames[]`（可選）或另開 entry

## 治理（Phase 1 起）

- 每個 Jira epic 應 link 對應 Figma frame
- `last_verified`：設計師或 UIUX agent 確認 link 仍有效時更新
- `status: deprecated` 保留檔案，勿刪 YAML（避免舊 Jira link 404）
