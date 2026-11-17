# Session｜2026-11-17｜hktvmall-pm 取代 hktv-pm-spec-writer

## 做了甚麼

把 Winnie 專用的 feature spec skill 收成任何人可用的 `hktvmall-pm`，並取代 `hktv-pm-spec-writer`。

1. 真源：`02_Knowledge_Base/skills/hktvmall-pm/SKILL.md`（由 `feature-spec-to-tickets` 改名）
2. 角色不再寫死 Winnie。Document owner 與 Requester 可不同；缺名先問
3. 寫 spec 併入原 `hktv-pm-spec-writer`：先問、screen inventory、逐頁需求、copytable（ZH／EN／zh_CN）、Kafka、worked examples、交稿檢查
4. Jira **不自動開**。Spec 未齊就停並列出缺項；齊了先問。對方已指明 Confluence 並要求開票才開
5. 移除 Melessa 的 `hktv-pm-spec-writer`，並從 UIUX-Skills manifest 拿掉（19 → 18）。同步腳本會刪除已不在清單的 skill
6. `hktvmall-design` plugin 0.7.7：刪除 `hktv-pm-spec-writer`，放入同一份 `hktvmall-pm`
7. 本機 `UIUX-Skills` fast-forward 到 `3c6d8e7`。更新前的舊工作區暫存為 stash `local drift before update 2026-11-17`

## 分發

- Melessa：`17e59f3` 已在 `main`
- UIUX-Skills：[chore(sync): from Melessa @ 17e59f3](https://github.com/melessachu-ctrl/UIUX-Skills/commit/3c6d8e7)
- hktvmall-design：`64bff61`（plugin 0.7.7）已在 `main`
- `hktvmall-pm` **不**進 UIUX-Skills。設計師要 spec skill 要更新 `hktvmall-uiux` plugin，不是只跑 `update-skills.sh`
- 本機 `~/.cursor/skills/hktvmall-pm` 指向 Melessa 真源

## 未完成甚麼

- 已裝 plugin 的人要自行更新到 0.7.7
- Claude `user-power@team-agent-skills` 仍有一份 `hktv-pm-spec-writer`，今次沒有動
- Melessa 與 plugin 兩份 `hktvmall-pm` 不會自動互相同步；之後改真源要再拷一次去 plugin
- UIUX-Skills stash `local drift before update 2026-11-17` 仍在，內容是更新前的舊檔，可丟

## 下次由哪裡開始

- 若要 plugin 跟上 Melessa 真源，再把 `SKILL.md` 拷到 `plugins/hktvmall-uiux/skills/hktvmall-pm/`
- 若要清掉 team-agent-skills 裡的舊 spec skill，另開一次

## 今日學到

- UIUX-Skills 的 sync 只複製 manifest 內的 skill；要刪下游目錄，腳本必須主動移除不在清單的資料夾
- 本機 UIUX-Skills 若有舊的未提交改動，`git pull --ff-only` 會被擋住；先 stash 再 pull
