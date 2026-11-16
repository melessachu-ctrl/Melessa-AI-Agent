# In-repo spike SOP（HKTVmall · 設計師 vibe code）

> 搭配 [`../SKILL.md`](../SKILL.md) 與 `uiux-design-studio`。Plugin **唔會**自動開 branch；本 SOP 供設計師與 Agent 逐步執行。

## 0. 開工前

- [ ] 已裝 `hktvmall-uiux`（repo 內 `.claude/settings.json` 已 commit，或本機已 install）
- [ ] 已讀 [`designer-session-kickoff.md`](designer-session-kickoff.md) 並貼開工 prompt
- [ ] 已確認 **DS Surface**：NativeChrome / WebViewH5（= GCP web／WebView repo · `ds/`）/ Mixed
- [ ] 已讀 `ds-artifact-map.md`：native = reference skill；WebView = Gate D ensure 本 repo `ds/`

## 1. 開 spike 分支

```bash
git fetch origin
git checkout -b spike/<TICKET>-<short-name> origin/<base>   # base 跟團隊慣例，常為 main/develop
```

- [ ] 分支名含 `spike/`（sign-off 前）
- [ ] 新 UI 盡量新 module／WebView route／**feature flag off** 或 debug 入口
- [ ] **唔**順手改舊 component 樣式（除非任務明確要求）

## 2. Happy flow 實作

- [ ] `uiux-design-studio`：`deliveryMode=code`，`studioDepth=light`
- [ ] 執行 `hktvmall-vibe-prototype`：只用 DS **語意 token**
- [ ] WebViewH5：Gate D（`ds/`＋`PIN.json`；icons 按需）後先寫 UI
- [ ] 主 flow ≤3 步；價錢一位小數；mock 資料
- [ ] README 或 app 內標 **PROTOTYPE / SPIKE**（若 internal build）

## 3. Code Token Bind Gate

- [ ] 跑完 vibe-prototype 內 checklist（含 Gate D／T／C）
- [ ] Testing App Pack 草稿（點開、測邊條、DS 聲明：`ds/PIN.json` 或 native 路徑）

## 4. UIUX Review → Requirement AC

- [ ] 讀 `uiux-review`；對 running app／模擬器
- [ ] 產出 **Requirement AC**（用 [`requirement-ac-template.md`](requirement-ac-template.md)）
- [ ] **唔**把 error／special case 塞入 Requirement AC（留 Engineering AC）

## 5. Sign-off

- [ ] PO／PM 簽 AC + 可點 build（記錄日期／build 號）
- [ ] 無 AC **唔**去掉 spike 語意、唔宣稱 production-ready

## 6. 去 `/spike` 繼續（sign-off 後）

**預設 A — 改名：**

```bash
git branch -m spike/<TICKET>-<short-name> <TICKET>-<short-name>
```

**選 B — tag 開新分支：**

```bash
git tag req-signed-off-<TICKET>
git checkout -b <TICKET>-<short-name> req-signed-off-<TICKET>
```

- [ ] 分支名跟同事慣例（**唔**強制 `/feature`）

## 7. 工程化 + MR

- [ ] 與工程師 pairing：API、error、empty、loading、analytics、bridge
- [ ] 補 **Engineering AC**
- [ ] MR 描述：已簽 Requirement AC、本次新增邊啲 case
- [ ] MR 標籤／關鍵字：`req-signed-off`、`ready-for-review`（若團隊用）

## 與同事並行

- 唔改他人 branch；唔 merge spike 入 main 而無 flag／review 共識
- 階段用 MR metadata 表達，唔要求全隊改 branch 命名
