# CLAUDE.md 範本：HKTVmall iOS／Android app repo（設計師／Business User vibe code）

<!--
用於設計師或 Business User 用 Claude Code 做 in-repo spike／改 UI。
工程師正式開發唔需要此檔或 hktvmall-design plugin。
平台建議將本內容 commit 入 repo 一次，唔使每人手動複製。
填好實際路徑、Native DS 狀態、WebView base URL 後可刪除此註解。

若本 repo 係 GCP 上嘅 WebView／web frontend 內容，改用 templates/CLAUDE.webview.md。
本 app 只開 Remote URL；web DS runtime 喺 web repo 的 ds/（ds/PIN.json）。
-->

## HKTVmall UI 編排（設計師 vibe code／改 UI）

凡 **touch 使用者可見 UI** 或 **user-facing flow**（新功能、改版、WebView 頁、native 殼），在寫碼前：

1. Read **`hktvmall-uiux`** plugin 的 **`uiux-design-studio`**（預設 Design Director）
2. 若 `deliveryMode` 為 `code` 或 `mixed`：Read **`hktvmall-vibe-prototype`**，跟 in-repo spike SOP
3. Read **`hktvmall-design-system`**（本 plugin）、`hktvmall-target-customers`、`ricky-design-guideline`
4. **唔**用 `frontend-design` 作 HKTVmall 主視覺

**唔觸發上列流程**：純 API、無 UI 差異的重構、CI、單元測試。

Spike sign-off 用 **Requirement AC**；見 vibe-prototype `references/requirement-ac-template.md`。

## Design System（Reference-first）

本 repo 的 UI 遵守 HKTVmall Design System。寫 **iOS／Android frontend UI** 前，**必須**讀 `hktvmall-uiux` plugin 的 `hktvmall-design-system` skill，並 **reference 平台檔**（iOS：`tokens/ios`、`icons/ios`、`components/ios`；Android：對應 `android`）。落地對照：`references/ds-artifact-map.md`、`references/native-repo-map.md`。

### Reference-first 規則（native）

1. **Tokens：** 所有 color／font／spacing／radius／shadow／border 必須用 skill 語意 tokens；**不可自創**。有 `Appearance`／`AppColor` 就用 `native-repo-map.md` mapping 落地同一語意。
2. **Icons：** 優先 skill `icons/icons.json`＋平台 icon 檔；無適合先問；新 icon **outline 優先**。
3. **Components：** 先搵 skill 規格／參考 → app 已有 DS API → **app source 同類直接複製／reuse** → skill tokens hard code＋DS gap。
4. **禁止**把整套 `HKTVTokens.*`／icons／DS components **scaffold 入本 repo** 當平行 DS（IT 維護 proper DS）。

### Runtime 路徑（consumer repo）

| 平台 | Runtime 路徑（填實際） | Skill 必 reference |
| --- | --- | --- |
| iOS | `[HKTVMall/DesignSystemComponent/Appearance/]` | `tokens/ios/HKTVTokens.swift`、`icons/ios/`、`components/ios/` |
| Android | `[core/ui/.../theme/AppColor.kt]` | `tokens/android/HKTVTokens.kt`、`icons/android/`、`components/android/` |

- **Conflict**（檔名撞但唔係 DS API，例如 UIKit `HKTVButton`）→ 先問；唔覆蓋。
- Partial 時唔好默默開第二套色系統。
- **本 app repo 通常唔存放 `hktv-tokens.css`。** Web DS 喺 WebView／web repo 的 `ds/`。

### WebView（GCP · Remote URL）

Surface 名 **`WebViewH5`** = remote GCP web（兼容舊用語）。**改 web 內容時應在 web／WebView repo 開工**（用 `CLAUDE.webview.md`），唔喺本 app repo 抄 CSS。

| 欄位 | 填寫 |
| --- | --- |
| WebView base URL | `[例如 https://webview.example.com/]` |
| Web DS 位置 | 該 web repo 根目錄 **`ds/`**（`ds/PIN.json` 為版本標記） |

- 本 app 只開 Remote URL + native 殼；**唔**把 web tokens／components 放入本 repo。
- Code Token Bind Gate（若只改 native）：跟 NativeChrome。若要改 web 頁 → 切去 web repo，跑 **Gate D** ensure `ds/`。

### Design system component（native）

- iOS：`[HKTVMall/DesignSystemComponent/]`（避開根目錄 legacy UIKit `HKTVMall/HKTVButton.swift`）
- Android：`[core/ui/.../theme/]`

已有 **DS API** → reuse。Skill 無適合 → 搜本 repo **同類 component 直接複製／reuse**。再無 → skill tokens hard code＋DS gap。**唔**整包從 plugin scaffold 入 DS 目錄。Conflict 先問。

Web components 真源在 skill；runtime 在 web repo `ds/`（見 `CLAUDE.webview.md`）。唔好由 Swift／Kotlin 轉換。

### Icon library

- iOS：`[HKTVMall/DesignSystemComponent/Icons.xcassets]`
- Android：`[各 module res/drawable/：ic_* 或 icon_*]`
- Web：web repo `ds/icons/`（按需 sync）

先按 skill `icons/icons.json` 揀名；優先 outlined。無適合先問；新 icon **outline 優先**。**唔**整包從 plugin 複製入本 **native** repo。Android `ic_*` vs `icon_*` 唔清時先問。

### 規則

1. **新程式碼一律用 skill tokens。** color／font／spacing／radius／shadow／border 不可自創。
2. **不改舊 component 的樣式。** 除非任務明確要求。
3. **只用語義 token。** 例如 `text-primary`、`brand-primary`、`background-grey-50`。
4. **找不到 token 就先問。** 不要自己發明。
5. **價錢一律顯示一位小數。** 例如 `$289.0`、`$1,530.0`。售價用 `text-sale-price`，原價用刪除線配 `text-tertiary`。
6. **新功能要有簡短文字說明。** 新控件的文字說明不超過半句；Button 文字要說明按下後得到甚麼（R4）。
7. **模組要有清楚邊界。** 頁面底用 `background-grey-50`，模組用 `background-white`（R6）。
8. **改動舊 UI 要先列出。** 會改到現有 UI 位置、圖示或流程的修改，必須在回覆中列明，等我確認（R2、R8）。
