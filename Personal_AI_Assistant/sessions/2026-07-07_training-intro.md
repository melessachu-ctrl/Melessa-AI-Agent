# Session: 2026-07-07 — AI Agent 入門培訓

## 目標

- 建立第一位 Personal AI Assistant 的安全、清晰資料夾
- 了解 folder structure、起步檔案與安全邊界
- 完成 Cursor 版安全三件套與 agent 核心檔案

## 今日學到

- 三層結構：`Melessa AI Agent/` → `Personal_AI_Assistant/` → `sessions/`
- 起步檔案：README、.gitignore、sessions 說明、第一次 session 筆記
- 安全原則：工作區隔離、不在 session 寫機密、先解釋再執行 command
- 安全三件套（Cursor 版）：`rm→trash` alias、`.cursor/rules/`、Agent 模式 + terminal 確認
- 記憶層 vs 攔截層：rules 教偏好，alias 擋風險

## 輸入（範例）

- 培訓教材：`knowledge/01_Terminal_Setup_Safe_Start.md`
- 練習情境：整理一份「週會待辦」清單（使用假名）

## 輸出

- 已建立 `~/Melessa AI Agent/Personal_AI_Assistant/` 資料夾結構
- 已建立 README、.gitignore 與本 session 筆記
- 已建立 `AGENTS.md`、`.cursor/rules/safety-boundaries.mdc`
- 已建立 `templates/session-template.md`、`knowledge/` 教材副本
- 已設定 `~/.zshrc` 的 `rm→trash` alias

## 待辦

- [x] 在 Cursor 以 `~/Melessa AI Agent` 作為唯一 workspace 開啟
- [x] 新增 `AGENTS.md` 與 `.cursor/rules/`
- [x] 新增 `templates/session-template.md`
- [ ] 等待 Step 2 培訓教材，建立 AI Agent Training Home

## 反思

- 做得好：folder 結構清晰，安全邊界從一開始就寫進 README 與 rules
- 待改進：熟悉 Cursor 確認框的使用節奏，逐步建立個人白名單
