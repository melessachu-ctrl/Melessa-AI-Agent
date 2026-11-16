# Session｜2026-11-16｜HKTVmall Figma：local component／整頁 section slot 規則

## 做了甚麼

Melessa 要把 HKTVmall Figma 出稿的元件化判斷寫進 skills／rules：

1. 會重覆使用、DS 又沒有可直接用的**整塊** component → 本檔做成 **local component**
2. 整頁骨架會重覆、只有部分 section 的 state／內容不同 → **整頁 component + section slot**
3. Local／整頁是**組合殼**：內部**優先嵌套 DS instance**（Button、Badge、Icon、Input 等）；禁止為了包一層 local 把已有 DS 子元件拆成裸圖層重畫
4. Local／整頁＋slot **不**走 DS Component Write Gate；文字／色仍過 Screen Token Bind Gate
5. 「Content SLOT」（demo 文案綁定）與「section slot」（可換區塊）分開寫清

### 改動檔案（Melessa 真源）

- `sync/cursor-rules/hktvmall-figma-design-system.mdc`（元件化決策第 3 步）
- `.cursor/rules/hktvmall-figma-design-system.mdc`（workspace alwaysApply 副本）
- `02_Knowledge_Base/skills/uiux-design-studio/SKILL.md`（HKTVmall 預設、閘門表、Review／Final Pack）
- `02_Knowledge_Base/skills/apply-design-system/SKILL.md`（允許 token-bound local shell；禁 unbound one-off）

### 本機對齊（未當 Melessa finish 主路徑 push）

- `~/.cursor/skills`（symlink → 真源，已即時生效）
- `UIUX-Skills/` 本機副本（下游改由 Actions sync，勿手動 push `skills/`）
- `HKTV/hktvmall-design`、`HKTV/agent-skills`、Claude marketplace 本機副本已改；另 repo／plugin 發佈未在本 session push

## 分發

- Melessa：待 finish session commit／push
- UIUX-Skills：靠 Actions **Sync UIUX-Skills**（改了 `02_Knowledge_Base/skills/**` + `sync/**`）
- Slack：`#uiux-designer` 公告（Actions 成功後）

## 未完成甚麼

- 設計師要在 UIUX-Skills 跑 `./scripts/update-skills.sh`，新開 Agent chat 才載入
- HKTV plugin／agent-skills 本機改動若要進正式 plugin 發佈，需另開 session commit／publish

## 下次由哪裡開始

- 確認 Actions sync 成功後，設計師跑 `./scripts/update-skills.sh`
- 下次 HKTVmall Figma 出稿時驗證：重覆區塊 → local shell＋內嵌 DS Button／Badge

## 今日學到

- Local component ≠ 自創 DS；是本檔組合殼，子層仍用 DS instance
- Screen Token Bind 的「Content SLOT」與整頁「section slot」用語易混，規則裡必須分開命名
