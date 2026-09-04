# Session｜2026-09-04｜Finish session：UIUX Slack 公告寫入收尾流程

## 做了甚麼

### Finish session 流程更新

- `HEARTBEAT.md` 新增 **7.5**：若 update 已 sync 到 UIUX-Skills、或本 session 更新了 UIUX-Skills，整段收尾完成後**必須**自動發 `#uiux-designer` 公告
- 訊息結構固定（參考 https://hktvitlo.slack.com/archives/C02TNPKRE81/p1788494400986859）：
  - `<!channel> — UIUX Skill Repo 已更新 ✨`
  - **更新內容**（今次摘要）
  - **如何更新**（`./scripts/update-skills.sh` + Canvas）
- `MEMORY.md`：偏好改「條件式必做」；補 2026-09-04 決策
- `AGENTS.md`／`TOOLS.md`：對外發送例外（命中時可不問直接發 Slack）

### 本回合相關脈絡（稍早）

- DS Component Write Gate 已 push／Actions sync／已發過一次 `#uiux-designer` 公告
- `gh` CLI 方案 A 已裝好並登入（利於之後自動 push）

## 未完成甚麼

- （無）下次命中 UIUX-Skills 更新時，驗證 7.5 自動發公告

## 下次由哪裡開始

- 改 skill／sync 並 finish session → 確認 Actions → 自動發 `#uiux-designer`
- UIUX Design Agent PoC 仍在進行中（見 `TASKS.md`）
