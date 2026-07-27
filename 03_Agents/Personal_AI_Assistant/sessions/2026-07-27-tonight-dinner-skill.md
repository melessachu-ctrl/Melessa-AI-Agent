# Session｜2026-07-27｜tonight-dinner skill

## 做了甚麼
- 把「今晚煮咩好」從單純個人 skill，整理成 repo 真源：`02_Knowledge_Base/skills/tonight-dinner/`
- 建立 `~/.cursor/skills/tonight-dinner` 指向 repo 真源的 symlink，對齊現有 skill 系統
- 更新 `Sasa` 路由，確保兩條路徑都會命中同一個 skill：
  - 直接講「今晚煮咩好？／今晚食咩／韓式」
  - 先叫 `Sasa`，再請佢出晚餐建議
- 更新 skills README 的 symlink 重建清單
- 清走工作樹內 4 個未追蹤的 `tmp-figma*.png`

## 未完成甚麼
- 暫未實際做一次完整「今晚煮咩好？」輸出驗證圖示品質與口吻
- 暫未把 `tonight-dinner` 納入任何觀察日誌

## 下次由哪裏開始
- 如要驗證效果：直接在一般對話輸入「今晚煮咩好？」或在 `Sasa` 對話輸入「Sasa，今晚煮咩好？」
- 若之後新增其他可觸發 skill，預設沿用「repo-source + `~/.cursor/skills` symlink」並同步檢查 `Sasa` routing

## 備註
- Melessa 已明確確認：之後在 repo 新增每個 skill，預設都要用 repo-source + personal symlink 結構；如涉及觸發詞，同步更新 `Sasa` routing
