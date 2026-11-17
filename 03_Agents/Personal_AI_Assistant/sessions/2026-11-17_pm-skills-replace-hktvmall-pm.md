# Session｜2026-11-17｜pm-skills 取代 hktvmall-pm

## 做了甚麼

用下載的 `pm-skills` 取代 `hktvmall-pm`，並分發到 plugin 和 UIUX-Skills。

1. 比對後決定用進階包。`standardized-technical-prd` 吸收原 spec 流程，再加上測試計劃和 user story 追溯
2. 移除 `hktvmall-pm`（Melessa、本機 symlink、`hktvmall-uiux` plugin）
3. 加入三份 skill：`standardized-technical-prd`、`test-case-preparation`、`user-story-journey-mapper`
4. 真源在 Melessa `02_Knowledge_Base/skills/`。同步清單由 18 個變 **21** 個
5. Plugin **0.7.10**（repo 已 flatten 到根目錄的 `skills/`）
6. `pm-skills/README.md` 只是安裝說明，沒有放進 repo。Agent 讀各資料夾的 `SKILL.md`
7. 三個 repo 已 push。`subscription-ticket/` 留在 Melessa 未追蹤，沒有 commit

## 分發

- Melessa：`1b11761`
- hktvmall-design：`8854bab`
- UIUX-Skills：先是手動 `be2e9a3`，Actions 再同步 [chore(sync): from Melessa @ 1b11761](https://github.com/melessachu-ctrl/UIUX-Skills/commit/1c9e3ac)
- Slack：https://hktvitlo.slack.com/archives/C02TNPKRE81/p1794898800583109
- 本機 UIUX-Skills 已 fast-forward 到 `1c9e3ac`

## 未完成甚麼

- 這包還會叫 `pr-requirement-prep` 和 `prd-backend-impact-consult`，下載資料夾和 repo 都沒有
- README 提到要改 `qa-test-plan-review` 的舊引用，那份 skill 也不在這兩個 repo
- 已裝 plugin 的人要更新到 0.7.10
- 設計師要跑 `./scripts/update-skills.sh`
- Claude `user-power@team-agent-skills` 仍有舊的 `hktv-pm-spec-writer`

## 下次由哪裡開始

- 若要補齊依賴，找 `pr-requirement-prep` 和 `prd-backend-impact-consult` 再裝
- `subscription-ticket/` 是另一份 spec 草稿，要另開 session 才處理

## 今日學到

- `pm-skills/README.md` 不是 runtime。三份 skill 各自帶 `references/`，可以單獨載入
- Plugin repo 已 flatten，skill 在根目錄 `skills/`，不再是 `plugins/hktvmall-uiux/skills/`
