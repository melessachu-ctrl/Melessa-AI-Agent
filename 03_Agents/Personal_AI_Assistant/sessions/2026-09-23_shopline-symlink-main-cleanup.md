# Session｜2026-09-23｜`shopline-admin` 本機 symlink、main 同步、刪舊分支

## 做了甚麼

### 本機環境

- 建立 `~/.cursor/skills/shopline-admin` → `02_Knowledge_Base/skills/shopline-admin` symlink
- 確認 Cursor 可全域載入 `shopline-admin` skill

### Git／main

- 釐清 **`cursor/shopline-admin-skill-8cde` 已於 PR #10 合入 `origin/main`**，無需再開 PR
- 本機 `main` 曾分叉（本機獨有 `baoyu-infographic` commit vs 遠端 shopline 相關 commit）
- **`git pull origin main --no-rebase`** 合併後 **`git push`** → 遠端 `main` 為 **`05f5135`**
- 刪除本機與 GitHub 遠端分支 **`cursor/shopline-admin-skill-8cde`**

## 未完成甚麼

- 未在本 session 重新驗證 `SHOPLINE_COOKIES` 或 Yahoo 訂單報表收件（延續 9/15 待辦）

## 下次由哪裡開始

- Shopline 後台 task：本機或新 Cloud Agent + `shopline-admin` skill + Secret
- 若要做報稅：查 `melessa07@yahoo.com.hk` 是否已有 2025/04–2026/03 訂單 CSV

## 今日學到

- 本機長期停在已 merge 的 feature branch 時，應切回 `main` 並 `pull`，避免以為「未 merge」
- 本機 `main` 若有未 push 的 commit，與遠端合併時用 `--no-rebase` merge 可保留兩邊歷史（例：`baoyu-infographic` + shopline）

## 備註

- 無 skill 內容變更；無 UIUX-Skills sync／Slack 公告
