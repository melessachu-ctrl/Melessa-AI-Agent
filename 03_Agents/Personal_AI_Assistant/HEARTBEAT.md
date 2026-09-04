# Sasa 的對話啟動清單（HEARTBEAT）

## 每次開始
1. 讀 `MEMORY.md`（偏好和紅線）
2. 讀 `TASKS.md`（手上有甚麼）
3. 讀 `sessions/` 最新一份紀錄（如果有）
4. 向 Melessa 報告：上次做了甚麼、今次建議由哪裏開始
5. 如果你只呼叫「Sasa」但未有說需求：我會先問你「有什麼需要我幫忙嗎？」

## 任務執行中
1. 先用一句話重述我理解到嘅目標
2. 先給 1 個建議方案；如你表述模糊，我會提供 2–3 個例子俾你選或修改
3. 每一步都會先問你確認，再繼續下一步
4. 涉及刪除、覆蓋、對外發送、敏感資料、授權或高風險操作 → 先停下提醒，等你明確同意先繼續

## 每次結束
1. 交付：重點摘要、next steps、待你確認事項
2. 在 `sessions/` 寫下今次紀錄：做了甚麼、未完成甚麼、下次由哪裏開始
3. 更新 `TASKS.md`
4. 有新偏好或踩坑 → 提議加入 `MEMORY.md`，等你確認
5. （可選）建議更新哪些相關 folder 的內容（例如：`01_Action_Center/`）
6. 若 Melessa **未**說 finish session，但今次完成了可記錄的工作任務，可主動問要不要加一行到觀察日誌；**等你確認後才寫入**
7. **當 Melessa 說「結束 session」／「finish session」**（見 `MEMORY.md`）：
   1. 完成 `sessions/` 紀錄、`TASKS.md` 更新、交付摘要
   2. **自動**在 `01_Action_Center/outputs/test_logs/Workflow_Observation_Log.md` **追加一行**（不覆蓋既有內容），欄位：
      - **日期時間**（本 session 起訖，估計即可）
      - **做了甚麼**（一句話摘要）
      - **用了多久**
      - **感受**（耗能／充電／中性）
      - **價值**（高／中／低 + 簡短理由）
      - **Skills**：本回合有**讀取並遵循**的 skill 名稱（如 `google-maps-bookmark`）；多個用逗號分隔；**無則留空**
   3. 將收尾相關變更（session、觀察日誌、`TASKS.md`、已確認的 `MEMORY` 等）一併 `git commit` 並 `git push` 到 **Melessa-AI-Agent** GitHub；不提交 credential／敏感檔；不做 force push / hard reset
   4. **UIUX-Skills 下游（條件式，見 `MEMORY.md`）**：若本 session 有修改 `02_Knowledge_Base/skills/**` 或 `sync/**`，**或**本 session 直接更新了 [UIUX-Skills](https://github.com/melessachu-ctrl/UIUX-Skills) repo，在 Melessa push 成功後：
      - **不要**每次 finish session 都手動 sync／push UIUX-Skills 的 `skills/`（真源在 Melessa；下游由 GitHub Actions **Sync UIUX-Skills** 自動更新）
      - **不要**在 Melessa 本機跑 `update-skills.sh`（該腳本給 clone UIUX-Skills 的 designer 用；Melessa 用 symlink 指向真源即可）
      - **要**確認 Actions workflow 跑成功；若失敗或未觸發，手動 **Run workflow**（`workflow_dispatch`）或查 [`sync/README.md`](../../sync/README.md)
      - 若本 session **只**改 UIUX-Skills 的非 sync 檔（如 README、`scripts/update-skills.sh`），才另 commit／push **UIUX-Skills** repo
      - 若本 session **未**改上述路徑、且未更新 UIUX-Skills → 跳過，不做任何 UIUX-Skills 操作
   5. **UIUX-Skills Slack 公告（條件式；整個 finish session 流程完成後）**：當下列**任一**成立，且下游已就緒（Actions sync 成功，或 UIUX-Skills 本身已 push 成功）時，**必須**用 Slack MCP `slack_send_message` 發到 `#uiux-designer`（channel_id `C02TNPKRE81`），**無需再問 Melessa**：
      - 本 session 的 skill／`sync/**` 變更已 sync 到 UIUX-Skills
      - 本 session 有直接更新 UIUX-Skills repo
      - 訊息結構（對齊既有公告；`更新內容` 依今次改動改寫，其餘固定）：

        ```
        <!channel> — UIUX Skill Repo 已更新 ✨

        **更新內容**
        {今次變更的簡短說明：改了哪些 skill／規則、designer 要注意什麼}

        **如何更新**
        在本機 UIUX-Skills repo 跑：
        `./scripts/update-skills.sh`

        步驟可參考 Canvas：https://hktvitlo.slack.com/docs/T1PH69YNN/F0BTSHFDX50
        ```

      - 發完後把 message link 寫進當次 session 紀錄與對 Melessa 的交付摘要
      - 未命中上述條件 → **不要**發此公告
