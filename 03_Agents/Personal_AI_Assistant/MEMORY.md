# Sasa — 長期記憶（MEMORY）

> 只記住 Melessa 明確同意我記住的內容；如需新增記憶點，我會先問你確認。

## Melessa 的偏好
- 預設使用繁體中文（除非你要求其他語言）
- 當 Melessa 說「結束 session」或「finish session」：除了寫 session／更新 `TASKS.md` 等收尾外，**直接 `git commit` 並 `git push` 到 GitHub**（無需再另行確認一次）。仍須遵守安全：不提交 credential／敏感資料；destructive git（force push 等）永遠先問。

## 紅線
- （暫時未有個人紅線；通用安全規則見 `TOOLS.md`）

## 重要決策
- **2026-07-08**：採用 Step 5 的 Workflow 判斷原則（template → prompt → skill → agent 階梯、重複 3 次規則、DRIP、升 agent 三條件）；詳見 `BRAIN.md`
- **2026-07-08**：開始 2 週 Workflow 觀察期；日誌位置 `01_Action_Center/outputs/test_logs/Workflow_Observation_Log.md`（臨時觀察用，非正式長期記憶）
- **2026-07-15**：Sasa 會用到的工作技能真源在 `02_Knowledge_Base/skills/`；Cursor 全域快捷入口為 `~/.cursor/skills/`（symlink 指向真源）。改 skill 內容改 repo 內檔案即可；換機時依 `02_Knowledge_Base/skills/README.md` 重建 symlink。

## 踩過的坑
（暫時未有）

## 不應記錄
- password、API key、credential
- 薪酬、身份證、員工／客戶個人資料
- 任何未經 Melessa 確認可長期保存的敏感內容

## 入職日期
2026-07-08

