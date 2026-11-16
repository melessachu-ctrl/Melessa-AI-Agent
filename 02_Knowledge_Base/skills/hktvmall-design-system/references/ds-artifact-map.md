# DS Artifact Map（來源 vs 各 runtime 落地）

## 一圖看懂

```
Figma HKTVmall DS (fileKey F0tjdruLjJTfWgmTeZKBnw)
        │
        ▼
tokens.json  ←── hktvmall-design-system skill（唯一規格來源）
    │
    ├── build_tokens.py ──► web/hktv-tokens.css
    │                       ios/HKTVTokens.swift   （寫 UI 必 reference）
    │                       android/HKTVTokens.kt （寫 UI 必 reference）
    ├── build_icons.py  ──► icons/web、icons/ios、icons/android
    ├── components/web  ──► hktv-button / hktv-price
    │
    ▼
iOS／Android 寫 UI（Reference-first）     │  WebView／web frontend repo（GCP）
1. Read skill 平台 tokens／icons／comps   │  repo 根 `ds/`（agent ensure／sync）
2. Tokens 必用 skill；不可自創             │  tokens + components 必 sync；icons 按需
3. Icons 優先 skill；新 icon outline 優先 │  `ds/PIN.json` = 版本標記
4. Components：skill → app 同類複製 → hard code
禁止整包 scaffold native DS 入 app repo
```

**Skill 平台檔 = 寫 UI 時必 reference 的規格＋參考實作。** Native runtime 由 app 既有 API／IT DS 承接；**WebView 內容 repo** 用本 repo 內 `ds/`（由 skill sync；**一律以 skill 為準**覆寫）。**Agent 禁止**把整套 `HKTVTokens.*`／native components／icons scaffold 入 **iOS／Android app** 當平行 DS。

WebView 頁以 **Remote URL**（GCP 上嘅 web／WebView repo）為準；**唔係**獨立「H5 git 產品線」假設，但 **寫 web 嘅 repo 本身可以喺 GCP**，並在根目錄維護 `ds/`。

## 三端分工

| 層級 | Canonical（plugin） | iOS／Android 寫 UI | WebView／web repo（GCP） |
| --- | --- | --- | --- |
| **語意 tokens** | `tokens/tokens.json`＋平台檔 | **必 reference** `tokens/ios` 或 `tokens/android`；落地用 `HKTVTokens` 或 Appearance／AppColor mapping | `ds/hktv-tokens.css`（自 skill sync） |
| **Icon library** | `icons/icons.json`＋平台檔 | **優先** skill icons；無適合先問；新 icon outline 優先；唔整包複製 | `ds/icons/*.svg`（**按頁按需** sync） |
| **Component 規格** | `references/components/` | 必讀規格 | — |
| **Component 程式碼** | `components/ios|android`（參考）；`components/web`（sync 來源） | skill 有 → 跟規格寫；無 → **app source 同類複製**；再無 → tokens hard code＋DS gap | `ds/hktv-*.css|js`；**skill 為準覆寫**；頁面用 `<hktv-button>`／`<hktv-price>` |

## WebView 決策樹

```
新功能 UI 主要放邊？
│
├─► 內容喺 WebView／web frontend repo（GCP）
│     → Surface = WebViewH5
│     → Gate D：ensure 本 repo `ds/`
│         • 無 `ds/` → sync tokens/web + components/web，寫 ds/PIN.json
│         • 有 `ds/` → 比 PIN／hash 同 skill meta.synced；舊就 re-sync（skill 覆蓋）
│         • icons：只按本頁需要從 icons/web 複製入 ds/icons/
│     → 頁面必須用 ds/（--hktv-*、<hktv-button>、<hktv-price>）；無 component → hard code＋DS gap
│     → iOS／Android app **唔放** web CSS；只開 Remote URL
│
└─► 純 Native 畫面（iOS／Android）
      → 必讀 hktvmall-design-system；reference 平台檔
      → Tokens：只用 skill 語意；mapping 落地；不可自創
      → Icons：優先 skill；新 icon outline 優先
      → Components：skill → app 同類複製／reuse → hard code＋DS gap
      → Conflict（legacy 同名）先問
      → 禁止整包 scaffold HKTVTokens／Icons／DS components 入 app
```

**Mixed**：內容用 GCP web repo（其 `ds/`）；Nav／chrome 用 native Reference-first。Testing App Pack 分開列。

## Web `ds/` 路徑約定

| Repo 路徑 | Skill 來源 |
| --- | --- |
| `ds/hktv-tokens.css` | `tokens/web/hktv-tokens.css` |
| `ds/hktv-button.css`／`.js`、`hktv-price.css`／`.js` | `components/web/`（略過 README） |
| `ds/icons/*.svg` | `icons/web/`（按需） |
| `ds/PIN.json` | sync 時寫入（`meta.synced`、hashes） |

Helper（plugin skill 內）：`python3 ${CLAUDE_SKILL_DIR}/scripts/sync_web_ds.py --target <web-repo-root>`（可選 `--icons name1,name2`）。見 `components/web/README.md`。無 script 時 agent 直接從 skill 複製檔案。

**唔好**手改 generated `hktv-tokens.css` 數值；要改回 skill `tokens.json` 再 `build_tokens.py`，然後 re-sync。人手改過 `ds/` 內 skill 副本 → 下次 Gate D **仍以 skill 覆蓋**。

## 同步步驟（plugin 更新後）

1. 設計團隊更新 Figma → 更新 plugin `tokens.json`（`meta.synced`）。
2. 跑 `python3 scripts/build_tokens.py`（icons：`build_icons.py`）。
3. Consumer：
   - **iOS／Android：** IT／平台維護 app-repo DS；agent 寫 UI 時 **reference skill**，唔整包複製。
   - **Partial：** 唔默默改 Appearance／AppColor 對齊除非任務要求；缺維度跟 skill 語意列 gap。
   - **WebView／web repo：** vibe code 開工跑 Gate D（skill 內 `scripts/sync_web_ds.py`，或 agent 直接複製）；更新 `ds/PIN.json`。
4. **唔好**手改 generated 檔數值；改回 `tokens.json` 再 build

（定時／push 自動把 skill sync 去 GCP 的 CI **唔喺本流程內**；靠 agent Gate D。）

## Consumer 填寫表

**Native app**（貼入 app repo `CLAUDE.md`）：

| 平台 | 本 runtime token／CSS 路徑 | 備註 |
| --- | --- | --- |
| iOS | 例：`HKTVMall/DesignSystemComponent/Appearance/` | 寫 UI 仍必 reference skill `tokens/ios` |
| Android | 例：`core/ui/.../theme/AppColor.kt` | 寫 UI 仍必 reference skill `tokens/android` |
| WebView base URL | 例：`https://…/`（開 Remote URL） | **pin 以 web repo `ds/PIN.json` 為準** |

**WebView／web repo**（貼入該 repo `CLAUDE.md`，可用 `templates/CLAUDE.webview.md`）：

| 欄位 | 值 |
| --- | --- |
| DS 目錄 | `ds/` |
| PIN | `ds/PIN.json` |

Mapping 見 `native-repo-map.md`。

## Component 優先序（規格／實作分期）

1. Button（`button.md`；Figma `3135:812`）
2. Price（`price.md`；列表 vs PDP）
3. Cart Button（`cart-button.md`；Figma `7088:1450`。不含 Outlined Cart Primary／Secondary）
4. Text field、Dropdown、Phone（`text-field.md`；Figma `3005:218`。Dropdown 只做收合欄）
5. Product card
6. Badge／promo bubble
7. Nav bar／bottom sheet 殼（native）

未有 skill component：Web → skill tokens hard code＋**DS gap**；Native → 先 **app 同類複製**；再無 → skill tokens hard code＋**DS gap**。

## 與 vibe-prototype 的銜接

- **Code Token Bind Gate**：Gate D = ensure `ds/`；Gate T = skill／`ds/` tokens only；Gate C = skill components →（native）app 同類 → hard code。
- WebView：查本 repo `ds/`（`--hktv-*`、`<hktv-button>`／`<hktv-price>`）同 `PIN.json`。
- Native：查是否跟 skill 語意（經 mapping 或 feature 內引用）；唔靠整包複製過閘。
