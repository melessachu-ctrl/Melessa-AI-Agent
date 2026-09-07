---
name: travel-packing-list
description: 當使用者講「旅行清單／行李清單／我要執行李／執行李／收拾行李／packing list」等，或語意明確係出發前執行李、check 要帶咩，本 Skill 會輸出 Melessa 的個人旅行行李清單（8 個分類、51 項）；清單真源在同目錄 checklist.md。
---

# Travel Packing List（旅行／行李清單）

## 載入時機（必遵守）
命中下列**任一**情況時，必須載入並依本 skill 執行（不可略過、不可改用其他格式或憑記憶即興改清單）：
- 使用者直接說：**旅行清單**、**行李清單**、**我要執行李**、**執行李**、**收拾行李**、**packing list**
- 語意明確係「出發前執行李／check 要帶咩／旅行前要帶啲咩」
- 使用者先叫 **Sasa／Personal AI Assistant**，再請佢出旅行／行李清單

執行前：**必讀**同目錄 `checklist.md`，再按下方輸出格式出齊。

## 清單真源
- 檔案：`02_Knowledge_Base/skills/travel-packing-list/checklist.md`
- 內容由 Melessa 於 2026-09-07 確認；**修改清單時只改 `checklist.md`**，唔好只改對話或 MEMORY。

## 輸出格式（每次都照呢個順序）
1. 標題：`# 旅行行李清單`
2. 按 `checklist.md` 的 **8 個分類** 逐段輸出（用 `##` 標題）
3. 每項保留 `- [ ]` checkbox 格式，方便 copy 或對照 Reminders
4. **唔好**加額外建議、天數估算、或改動項目——除非 Melessa 明確要求更新清單內容

## 唔做嘅嘢
- 唔好混入已刪除項目（例如：冷帽、直髮夾、照相機、記憶咭、手提電腦、獨立充電線、個人應急藥物）
- 唔好把 Hoodies 同 T 恤拆開——已合併為一項
- 唔好自動同步 Reminders／Notes（除非 Melessa 另外要求）

## 更新清單
若 Melessa 要求加／減／改項目：
1. 先確認改動
2. 更新 `checklist.md` 同檔案頂部「最後更新」日期
3. 再輸出新版清單給 Melessa 確認

## 相關腳本（可選）
- Reminders／Notes 同步：`03_Agents/Personal_AI_Assistant/scripts/add-travel-checklist-to-notes.applescript`（僅 Melessa 本機執行）
