---
name: hktvmall-vibe-prototype
description: HKTVmall 在 app repo 內 vibe code／改現有 UI（in-repo spike、testing app、新功能 UI、WebView GCP remote、native 殼）。由 uiux-design-studio 在 deliveryMode=code|mixed 時呼叫；強制 DS tokens、Code Token Bind Gate、Ricky／客群。Use when vibe coding、in-repo spike、改 HKTVmall app UI、WebView GCP、requirement prototype、用 code 確認需求。
---

# HKTVmall Vibe Prototype（設計師 · in-repo spike / Code UI）

設計師在 **HKTVmall consumer app repo**（iOS／Android）或 **GCP 上嘅 WebView／web frontend repo** 用 Cursor／Claude **vibe code**：新功能 UI、改現有畫面、WebView 內容、native 外殼。交付物是可點擊的 **requirement 確認**（happy flow），sign-off 後再補 special／error case 才 MR。Web DS 真源在 `hktvmall-design-system`；web runtime 係 **該 web repo 根目錄 `ds/`**（Gate D ensure／sync）。

## 與 uiux-design-studio 的關係（必讀）

- **編排層**：凡 HKTVmall **touch UI** 或 **user-facing flow** 的工作，預設由 [`../uiux-design-studio/SKILL.md`](../uiux-design-studio/SKILL.md) 擔任 Design Director（Intake → Routing → Final Pack）。
- **執行層（本 skill）**：`deliveryMode` 為 `code` 或 `mixed` 時，studio 必須 **Read 本 skill** 並執行 in-repo spike、Code Token Bind Gate、Testing App Pack。
- **互斥閘門**：本次 **無 Figma 寫入** 時，**不要**跑 Screen Token Bind Gate；只跑 **Code Token Bind Gate**。有 Figma 寫入時見 studio「HKTVmall app repo · Code delivery mode」。

**硬性立場：** 唔係 generic 前端美術。禁止 `frontend-design` 作主視覺；跟 **hktvmall-design-system** + **ricky-design-guideline** + **hktvmall-target-customers**。

## Plugin 與自動化期望

裝 **hktvmall-uiux** 後：

| 行為 | 會自動嗎 |
| --- | --- |
| 開 `spike/` branch | **唔會**；見 [`references/in-repo-spike-sop.md`](references/in-repo-spike-sop.md) 或用戶開工 prompt 叫 Agent 執行 `git checkout -b` |
| 載入 uiux／Ricky／客群 | **唔保證**；靠 **app repo `CLAUDE.md`** + 開工句，見 [`references/designer-session-kickoff.md`](references/designer-session-kickoff.md) |
| Apple HIG | 僅含 Apple 原生控制項時讀 `apple-design` |
| Marketing skills | 轉換型先 `cro`／`offers`；Marketing Buddy 後台唔讀整套 cro（見 studio） |

## 何時用本 skill

| 適用 | 不適用 |
| --- | --- |
| in-repo spike、改 HKTVmall app／WebView（GCP）UI、WebView 新頁 | 純 Figma 出稿（studio + Screen Gate） |
| requirement happy flow 確認 | 純 API／無 UI 改動 |
| 獨立 sandbox（可選） | 只評審、不改碼 → `uiux-review` |

## 必載技能（經 studio 路由後）

| Skill | 用途 |
| --- | --- |
| `../uiux-design-studio/SKILL.md` | 編排、`deliveryMode`／`studioDepth` |
| `hktvmall-design-system` | Token；見 skill 內 `references/ds-artifact-map.md` |
| Cursor／UIUX-Skills rules：`hktvmall-figma-design-system`、`hktvmall-ui-price`（Lite App／MKGB 另見對應 rule） | 跨專案規則、價錢（等同 Claude plugin 的 `hktvmall-design-rules`） |
| `../hktvmall-target-customers/SKILL.md` | 客群、KPI |
| `../ricky-design-guideline/SKILL.md` | R1–R9 |
| `../ui-ux-pro-max/SKILL.md` | a11y、觸控 |
| `../figma-mcp-server-guide/SKILL.md` | 對照 DS 元件（optional） |

**轉換型**（PDP、搜尋、購物車、結帳、促銷、落地頁）：加 `cro`、有優惠加 `offers`、有文案加 `copywriting`／`copy-editing`。詳見 studio「轉換型畫面」。

## In-repo spike 生命周期

**預設**：在 **HKTVmall app repo** 開分支，唔強制同事用 `/feature` 前綴。

1. **開工**：`git checkout -b spike/<ticket>-<short-name>`（團隊慣用命名可調，spike 期建議含 `spike/` 前綴）。
2. **Happy flow only**：mock 資料、feature flag off 或 debug 入口；唔大改共用層（`hktvmall-design-system` 規則 2）。
3. **Review**：`uiux-review`（`studioDepth=light` 可精簡）；產出 **Requirement AC**，模板 [`references/requirement-ac-template.md`](references/requirement-ac-template.md)。
4. **Sign-off**：PO／PM 簽 **Requirement AC + 可點 build**（唔等於 MR merged）。
5. **去 spike 語意繼續開發**（二選一，預設 A）：
   - **A**：`git branch -m spike/<ticket>-<name> <ticket>-<name>`（跟團隊平常 branch 名，**唔**加 `/feature`）。
   - **B**：`git tag req-signed-off-<ticket>` → 從 tag 開新分支 `<ticket>-<name>`。
6. **補 special／error case** → 工程 pairing → MR（用 MR 標籤：`req-signed-off`、`ready-for-review`）。

逐步 checklist：[`references/in-repo-spike-sop.md`](references/in-repo-spike-sop.md)。

## Requirement AC vs Engineering AC

| 類型 | 時機 | 內容 |
| --- | --- | --- |
| **Requirement AC** | Spike sign-off | Happy flow + 當輪 Must；來自 `uiux-review` Acceptance Criteria |
| **Engineering AC** | MR 前 | Error／empty／loading、API、deep link、a11y 邊界 |

**AC** = Acceptance Criteria（驗收標準），可勾選清單。定義與格式見 `uiux-review` Step 7。

## DS Surface Declaration（開工時寫一句）

| Surface | Token 來源 | Component 策略 |
| --- | --- | --- |
| **NativeChrome** | **必 reference** skill `tokens/{ios\|android}`；落地用已有 `HKTVTokens` **或** Appearance／AppColor（`native-repo-map.md` mapping）。color／font／spacing／radius／shadow／border **不可自創** | skill 規格／參考 → repo **DS API** → **app source 同類直接複製／reuse** → tokens hard code＋DS gap；Conflict 先問；**禁止**整包 scaffold native DS 入 app |
| **WebViewH5** | 本 **web／WebView repo** 的 `ds/hktv-tokens.css`（Gate D 自 skill sync；`ds/PIN.json`）。名保留兼容＝GCP remote web 內容 | **必須**用 `ds/` 的 `<hktv-button>`／`<hktv-price>`；無 component → hard code＋DS gap；`ds/` 內 skill 副本 **一律以 skill 覆蓋** |
| **Mixed** | 兩邊分別遵守上表 | 在 Testing App Pack 分開列 |

WebView 決策樹：見 `ds-artifact-map.md`。iOS／Android：**Reference-first**（見 `hktvmall-design-system`）；runtime mapping 見 `native-repo-map.md`。Icons：native 優先 skill；Web 按需 sync 入 `ds/icons/`。Native app repo **通常唔放** web CSS。

## Component 成熟度（唔阻塞 spike）

| Phase | 內容 | Spike |
| --- | --- | --- |
| 1 | 語意 **tokens** | **必須** |
| 2 | 高頻 **repo 元件** reuse | 盡量 |
| 3 | 對齊 Figma 全庫 | 長期；缺口標 **DS gap — composed from tokens** |

## Code Token Bind Gate（強制）

每一次新建或改動 UI **交付前**必過；未過不得宣告可給 user 測或 Final Pack「已交付」。

### Gate D — DS ensure（WebViewH5 強制；開工先跑）

僅當 Surface 含 **WebViewH5**（正在編輯 web／WebView repo）：

1. 查 repo 根有冇 `ds/`。
2. **無** → 由 skill 複製 `tokens/web`＋`components/web` 入 `ds/`，寫 `ds/PIN.json`。建議：  
   `python3 ${CLAUDE_SKILL_DIR}/scripts/sync_web_ds.py --target .`  
   （script 喺 **plugin skill** `hktvmall-design-system/scripts/`；無 Python 則 agent 直接複製檔案）
3. **有** → 比 `PIN.json` 的 `meta.synced`／file hashes 同 skill；舊或不匹配 → **re-sync，一律以 skill 覆蓋**，更新 PIN。
4. **Icons**：只按本頁需要從 skill `icons/web` 複製入 `ds/icons/`（可 `--icons …`）；唔一次過成庫。
5. 未完成 Gate D **唔好**開始寫／改 web UI。

### Gate T — Token only

- 寫 native UI 前已 **reference** skill 平台 token 檔。只用 `hktvmall-design-system` 語義 token（color／font／spacing／radius／shadow／border）；落地可係 `HKTVColor.*` **或** Appearance／AppColor mapping。禁止裸 hex、裸正文字級、非 DS 字體、自創數值。
- Web：只用本 repo `ds/hktv-tokens.css` 的 `--hktv-*`／typography class。
- 找不到 token：列出缺口並問 user。**禁止**整包 scaffold `HKTVTokens`／icons 入 **native** app repo。

### Gate C — Components

1. Reference skill `components/{ios|android|web}`＋`references/components/`。
2. **Web**：必須用 `ds/` 的 `<hktv-button>`／`<hktv-price>`（等）；無適合 → hard code＋DS gap。
3. **Native**：Repo 內搜尋既有 **DS API** → import（唔好把 UIKit legacy `HKTVButton` 當 DS）。
4. Skill 無適合 → 搜 **app source 同類** → **直接複製／reuse** 保 style 統一。
5. 仍無：skill tokens hard code + 標 DS gap（**唔**整包 scaffold plugin components 入 native DS 目錄）。
6. Icons：優先 skill library；新 icon **outline 優先**；Web 按需入 `ds/icons/`。

### Gate P — Price & copy

一位小數；R4 CTA；zh-HK 對照客群 skill。

### Gate R — Ricky Pass

R1–R9；code 可對照 `hktvmall-design-system/references/design-principles.md`。

```
HKTVmall Code Token Bind Gate — Checklist
- [ ] Surface Declaration 已寫
- [ ] WebViewH5：Gate D 已 ensure `ds/`（PIN 對齊 skill；或剛 re-sync）
- [ ] 已 reference skill 平台 tokens／icons／components（或本 repo `ds/PIN.json`）
- [ ] 新建／改動 UI 無裸 hex／裸字級／自創 spacing／radius／shadow／border（抽樣）
- [ ] Icons：skill 優先；Web 按需已 sync；新 icon 已標且 outline 優先（若有）
- [ ] 元件：Web 用 `ds/`；Native skill → app 同類／DS API → hard code＋DS gap／Conflict 已列
- [ ] 價錢一位小數
- [ ] preview 可點
- [ ] uiux-review（至少 light）
- [ ] Testing App Pack 已附
```

## Testing App Pack

Director Final Pack 附錄必含：

1. 怎樣開（指令 + URL／模擬器）
2. 測邊條、mock、已知未做
3. DS 聲明（native 路徑／reuse／gap；Web：`ds/`＋**`ds/PIN.json` 的 meta.synced**）
4. Code Token Bind Gate 結果（含 Gate D）
5. Segment & KPI（A/B/C/D）
6. Review 摘要 + **Requirement AC**（全文或連結）

## HKTVmall repo 設定（設計師／Business User；工程師唔裝 plugin）

平台 **commit 一次** 入會 vibe code 嘅 repo：

- Native app：`templates/CLAUDE.md` → `CLAUDE.md`
- WebView／web repo：`templates/CLAUDE.webview.md` → `CLAUDE.md`
- `templates/claude-settings.json` → `.claude/settings.json`（**uiux + dev**）

見 `references/designer-session-kickoff.md` 固定開工句。

## 常見錯誤

| 錯誤 | 正確做法 |
| --- | --- |
| 只裝 plugin 唔讀 studio | 先 uiux-design-studio 再本 skill |
| code 任務跑 Screen Token Gate | 只跑 Code Gate |
| 未 ensure `ds/`／PIN stale 仍寫 web UI | 先 Gate D（`${CLAUDE_SKILL_DIR}/scripts/sync_web_ds.py` 或直接複製）；再寫頁面 |
| 手改 `ds/` 當長期自訂 | 下次 sync **以 skill 覆蓋**；要改回 skill 真源 |
| 一次 sync 成個 icons 庫 | 只按頁 `--icons` 按需複製 |
| 寫 native UI 唔讀 skill／唔 reference 平台檔 | 必讀 `hktvmall-design-system`；Read `tokens/{ios\|android}` 等 |
| 自創 color／spacing／radius 等 | 只用 skill 語意 tokens；缺就問 |
| 整包 scaffold `HKTVTokens`／icons／DS components 入 **native** app | Reference skill 數值；mapping 落地；禁止平行 DS |
| Skill 無 component 就亂 hard code、唔睇 app 同類 | Native：先複製／reuse app source 同類；Web：標 DS gap |
| 把 UIKit `HKTVButton` 當 DS Button | Conflict：先問；核對 SwiftUI／Compose API |
| sign-off 前宣稱 production-ready | 僅 Requirement AC + happy flow |

回覆使用者使用 **繁體中文**。
