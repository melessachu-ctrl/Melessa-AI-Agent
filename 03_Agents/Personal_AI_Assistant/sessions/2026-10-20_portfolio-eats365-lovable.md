# Session｜2026-10-20｜Eats365 portfolio 文案 + Lovable 寫入 + skill 固化 project link

## 做了甚麼

### Portfolio 文案（Eats365 POS）

- 依 `portfolio-designer` 產出「Eats365 — POS that restaurants actually love」中英對照文案（6 年／14 產品／sole designer；不含 Biz）
- Melessa 改中文 PDF 後，以中文為準重對英文；Title／Short description 維持定稿；產品總覽保留連結

### Lovable 寫入

- 確認 Lovable MCP 已連線（帳號 Melessa07）
- 目標專案：`[with Credit] Melessa's Portfolio Design`  
  `project_id` = `b5eb4110-69a3-40ff-a113-47d1c71402bb`  
  Editor：https://lovable.dev/projects/b5eb4110-69a3-40ff-a113-47d1c71402bb
- 經 MCP `send_message` 更新 `/projects/eats365`：short desc、Duration 6 years、Category、四段 approach（中英）、產品總覽 URL
- Commit：`1b64109f19d6133c788d49275c66fade64fc1669`（preview 已更新）
- Publish 未做（自動 deploy 被拒／未核准）

### Skill 更新

- `portfolio-designer` 新增 **Lovable 專案（寫入網站時必用）** 表：project_id、Editor、Preview、Live、workspace、關鍵檔案路徑
- 真源：`02_Knowledge_Base/skills/portfolio-designer/SKILL.md`（與 `~/.cursor/skills/portfolio-designer` 對齊）

## 未完成甚麼

- Live 站 `melessa-chu-design.lovable.app` 尚未 Publish（preview 已有新文案）
- 首頁 card short description 與詳情頁已同步；若要再調 mockup／gallery 圖另開

## 下次由哪裡開始

- 說「幫我 publish portfolio」→ Lovable MCP `deploy_project`（同一 project_id）
- 改其他 project 文案 → 讀 `portfolio-designer`（不必再搜 Lovable project）

## 今日學到

- Portfolio 寫入應把 **固定 project_id** 寫進 skill，避免每次 `list_projects` 猜兩個 portfolio 副本
- 詳情頁 approach 跟 `eats365-scan-to-order` 同一模式：`translations.ts` keys + `projects.ts` `approach` 接線
