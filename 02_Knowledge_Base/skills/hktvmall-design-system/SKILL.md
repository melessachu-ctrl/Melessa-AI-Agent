---
name: hktvmall-design-system
description: HKTVmall Design System — design tokens、寫 UI 規則、平台參考檔（iOS／Android／Web tokens／icons／components）。Use when writing or vibe coding HKTVmall / hktv / 香港電視購物 iOS／Android／Web UI — new pages, screens, components, styles, themes — or when asked which color, font, spacing, radius, shadow, border, or icon to use. iOS／Android frontend UI MUST load this skill and reference platform files first (tokens／icons／components). Do not scaffold whole native DS libraries into app repos; reference skill files for decisions and values.
---

# HKTVmall Design System（寫程式用）

這個 skill 把 HKTVmall Design System（Figma fileKey `F0tjdruLjJTfWgmTeZKBnw`，2026-11-05 同步）變成可以直接寫進程式碼的 token 同平台參考。設計原則見 `references/design-principles.md`；設計和評審時請一併遵守 Cursor／UIUX-Skills rules（`hktvmall-figma-design-system`、`hktvmall-ui-price`；Lite App／MKGB 另見對應 rule）以及 `ricky-design-guideline`。**設計師 vibe code testing app** 時另跟 `hktvmall-vibe-prototype` 的 Code Token Bind Gate。

## 硬性規則

1. **iOS／Android 寫 frontend UI 必須用本 skill。** 開工先 Read 本 `SKILL.md`，再 **reference 對應平台檔**（見下「Reference-first」）。唔好跳過 skill 直接憑記憶或自創數值。
2. **所有 color／font／spacing／radius／shadow／border 必須用本 skill 的 token。** **不可自創** hex、px、pt、dp、字體名或「接近值」。完全沒有 token → 停低列缺口問用戶。
3. **UI 先用語義 token。** 例如 `text-primary`、`brand-primary`、`background-grey-50`。沒有數值完全一樣的語義 token 時，改用同一個原始色階 token（例如 `orange-75`、`yellow-800`）。不要用名字相近但數值不同的語義 token。
4. **Icons 優先用本 skill icon library。** 先查 `icons/icons.json`＋平台 icon 檔。同一物件 outlined／filled 都有時用 **outlined**；filled 只用於畫面狀態本身係實心且 library 有對應 filled。無適合 → 先列名再問；確認後先可以新 icon，**新 icon 一律 outline style 優先**。唔好用 SF Symbol、Material Icon 或臨時 SVG 頂替而未問。詳見 `references/components/icon.md`。
5. **Components 先在本 skill 搵。** 先讀 `references/components/` 規格同 `components/{ios|android|web}/` 參考實作。無適合 → 先搜 **app source 同類 component**；有就 **直接複製／reuse** 以統一整 app style；無同類先用 skill tokens hard code，並標 **DS gap**。
6. **不改動現有 components 的樣式。** 除非任務明確要求，否則不要修改現有 component 的樣式，也不要順手把舊程式碼改成用 token。
7. **價錢一律顯示一位小數。** 例如 `$289.0`、`$1,530.0`。售價用 `text-sale-price`；原價用 `*-rp`（刪除線）配 `text-tertiary`。
8. **禁止把整套 native DS scaffold／複製入 iOS／Android app repo。** Proper Design System 由 **IT 在 app repo 維護**。Agent **Read／reference** skill 檔做決策同數值；**唔**把 `HKTVTokens.*`、整套 `Icons.xcassets`、`HKTVButton`／`HKTVPrice` 等整包落地當平行 DS。**WebView／web repo** 則必須 ensure 本 repo `ds/`（見下；與 native 分開）。

## Plugin 是 source，consumer 是 runtime

- **Canonical（規格）**：本 skill 內 `tokens/tokens.json`；`scripts/build_tokens.py` 產生三平台檔。Icon：`icons/icons.json`＋`icons/source`；`scripts/build_icons.py`。Web components：`components/web/`。`components/ios`／`components/android` 同 `tokens/ios|android`、`icons/ios|android` 係 **寫 UI 時必讀的參考檔**，唔係整包複製入 **native app** 的目標。
- **運行時**：iOS／Android **app repo**（IT DS／既有 `Appearance`／`AppColor` 等）+ **GCP 上嘅 WebView／web frontend repo**（根目錄 `ds/`）。App 開 Remote URL；web DS 真源在本 skill，runtime 副本在 web repo 的 `ds/`。
- **對照表**：`references/ds-artifact-map.md`；runtime mapping：`references/native-repo-map.md`。

設計師 in-repo spike 見 `hktvmall-vibe-prototype`；編排見 `uiux-design-studio`。

## 寫 UI 前：Reference-first（iOS／Android 強制）

寫 **iOS 或 Android** frontend UI 時，**必須**跟本流程。路徑／runtime API 可讀 app 根 `CLAUDE.md` 同 `native-repo-map.md`，但 **決策同數值以 skill 平台檔為先**。

### 0. 必讀平台檔

| 平台 | 必 reference |
| --- | --- |
| **iOS** | `tokens/ios/HKTVTokens.swift`、`icons/ios/`（＋`icons/icons.json`）、`components/ios/`、`references/tokens.md`、`references/components/*` |
| **Android** | `tokens/android/HKTVTokens.kt`、`icons/android/`（＋`icons/icons.json`）、`components/android/`、`references/tokens.md`、`references/components/*` |
| **Web／GCP** | Skill：`tokens/web`、`icons/web`、`components/web`。Consumer web repo：ensure `ds/`（見「Web／GCP：`ds/` ensure」） |

### 1. Tokens（必用 skill；不可自創）

1. Read 上表平台 token 檔＋`references/tokens.md`，用語意名決策（color／font／spacing／radius／shadow／border）。
2. 落地到 app runtime：
   - 有 `HKTVTokens.*` → import 使用。
   - 有 `Appearance`／`AppColor`（Partial）→ 用 `native-repo-map.md` mapping 打去同一語意；**數值來源仍係 skill token**。
   - 無對應 API → **仍然唔自創數值**；用 skill token 的語意同數值寫入新碼（feature 內），或停低問；**唔**整包複製 `HKTVTokens` 入 repo。
3. 缺語意 token → 列缺口問；禁止「找相近頂替」。

### 2. Icons（優先 skill）

1. 在 `icons/icons.json` 按名稱揀；再對照平台檔（iOS catalog／Android drawable 參考）。
2. **有適合** → 用 skill 指定嘅物件名；runtime 用 app 已有同名／對等資源（`icon_*`／`ic_*`）；outlined 優先。
3. **無適合** → 列缺名問用戶；確認後先可以新 icon，**outline style 優先**；標明唔喺 DS icon library。
4. **禁止**把整套 skill `icons/ios`／`icons/android` scaffold 入 app。Web：只按頁把需要的 SVG sync 入 `ds/icons/`（唔一次過成庫）。

### 3. Components（先 skill，再 app 同類）

搜尋用 **平台＋API 形狀**，唔好只 match 檔名。詳見 `button.md`、`price.md`、`cart-button.md`、`text-field.md`、`native-repo-map.md`。

1. **Skill 有規格／參考實作**（`references/components/`、`components/ios|android`）→ 跟規格寫；數值用 skill tokens。若 app 已有對應 **DS API** → reuse，**唔覆蓋**。
2. **Skill 無適合** → 搜 **app source 同類 component**（同職能／同視覺族，例如同類 button、price row、chip）。**有就直接複製／reuse**，確保整 app style 統一。
3. **Skill 無、app 亦無同類** → 用 skill tokens **hard code** 組合，MR／回覆標 **DS gap**。
4. **Conflict**（例：iOS UIKit `@IBDesignable class HKTVButton: UIButton`）→ 停低問；唔當 DS SwiftUI Button；唔好覆蓋 legacy。
5. **Web／GCP** → Gate D ensure `ds/` 後，頁面用 `<hktv-button>`／`<hktv-price>`；`ds/` 內 skill 副本 **一律以 skill 覆蓋**。

| 元件 | 平台 | Skill 參考檔 |
| --- | --- | --- |
| Button | iOS | `components/ios/HKTVButton.swift`＋`references/components/button.md` |
| Button | Android | `components/android/HKTVButton.kt`＋`button.md` |
| Button | Web／GCP | `components/web/hktv-button.css`＋`.js` |
| Price（列表） | iOS | `components/ios/HKTVPrice.swift`＋`price.md` |
| Price（列表） | Android | `components/android/HKTVPrice.kt`＋`price.md` |
| Price（列表） | Web／GCP | `components/web/hktv-price.css`＋`.js` |
| Cart button | iOS | `components/ios/HKTVCartButton.swift`＋`cart-button.md` |
| Cart button | Android | `components/android/HKTVCartButton.kt`＋`cart-button.md` |
| Cart button | Web／GCP | `components/web/hktv-cart-button.css`＋`.js` |
| Text field | iOS | `components/ios/HKTVTextField.swift`＋`text-field.md` |
| Text field | Android | `components/android/HKTVTextField.kt`＋`text-field.md` |
| Text field | Web／GCP | `components/web/hktv-text-field.css`＋`.js` |
| Dropdown | iOS | `components/ios/HKTVDropdown.swift`＋`text-field.md` |
| Dropdown | Android | `components/android/HKTVDropdown.kt`＋`text-field.md` |
| Dropdown | Web／GCP | `components/web/hktv-dropdown.css`＋`.js`（要一併載入 text field css） |
| Phone | iOS | `components/ios/HKTVPhoneField.swift`＋`text-field.md` |
| Phone | Android | `components/android/HKTVPhoneField.kt`＋`text-field.md` |
| Phone | Web／GCP | `components/web/hktv-phone-field.css`＋`.js`（要一併載入 text field css） |

UIKit／Android XML 未有 Button／Price 原生 View 檔時，唔好由 Swift／Kotlin／Web 互轉；跟上面「skill → app 同類 → hard code」順序。

### Runtime 三態（輔助落地；唔阻擋 reference-first）

寫 UI **唔**以「Absent 就停」為預設。三態只幫你揀 runtime API：

| 狀態 | 意思 | 行為 |
| --- | --- | --- |
| **有完整／Partial API** | `HKTVTokens` 或 Appearance／AppColor | 用語意 token 決策；mapping 落地 |
| **Conflict** | 檔名撞但唔係 DS API | 停低問 |
| **無 mapping** | 缺某維度 API | 仍用 skill token 數值／語意；列 gap；**唔**整包 scaffold DS |

### Web／GCP：`ds/` ensure（WebView／web frontend repo）

寫 **Web** UI（Surface `WebViewH5`；正在編輯嘅係 GCP 上嘅 web／WebView repo）時：

1. 查 repo 根有冇 `ds/`。
2. **無** → 由 skill 複製 `tokens/web`＋`components/web` 入 `ds/`，寫 `ds/PIN.json`（可用 `python3 ${CLAUDE_SKILL_DIR}/scripts/sync_web_ds.py --target <repo>`）。
3. **有** → 比 `PIN.json`／hashes 同 skill `meta.synced` 與來源檔；舊或不匹配 → **re-sync，一律以 skill 覆蓋**。
4. **Icons**：按本頁需要從 `icons/web` 複製入 `ds/icons/`（`--icons a,b`）；唔一次過 sync 成庫。
5. 頁面 **必須**用 `ds/`（`--hktv-*`、`<hktv-button>`／`<hktv-price>`／`<hktv-cart-button>`）；無適合 component → hard code＋**DS gap**。

詳見 `ds-artifact-map.md`、`components/web/README.md`。此流程 **唔**適用於 iOS／Android app（仍禁止 scaffold native DS）。

如果 vibe code 用的 repo 未有設定，建議 **commit 一次**：

- Native app：`templates/CLAUDE.md` → `CLAUDE.md`
- WebView／web repo：`templates/CLAUDE.webview.md` → `CLAUDE.md`
- `templates/claude-settings.json` → `.claude/settings.json`（啟用 **hktvmall-uiux**）

正式開發嘅 **工程師唔需要裝本 marketplace**。

## 命名對照

`tokens/tokens.json` 是唯一來源，三個平台的檔案都由它產生，名稱一一對應：

| tokens.json | Web | iOS (SwiftUI) | Android (Compose) |
| --- | --- | --- | --- |
| `text-sale-price` | `var(--hktv-text-sale-price)` | `HKTVColor.textSalePrice` | `HKTVColor.TextSalePrice` |
| `spacing-16` | `var(--hktv-spacing-16)` | `HKTVSpacing.s16` | `HKTVSpacing.S16` |
| `radius-card-s` | `var(--hktv-radius-card-s)` | `HKTVRadius.cardS` | `HKTVRadius.CardS` |
| `stroke-width-regular` | `var(--hktv-stroke-width-regular)` | `HKTVBorderWidth.regular` | `HKTVBorderWidth.Regular` |
| `shadow-card` | `var(--hktv-shadow-card)` | `.hktvShadow(HKTVShadow.card)` | `HKTVShadow.Card` |
| `body-2-regular` | `class="hktv-body-2-regular"` | `.hktvText(HKTVText.body2Regular)` | `style = HKTVText.Body2Regular` |

Web 的所有 CSS variable 和 class 都加了 `hktv-` 前綴，所以不會和現有樣式撞名。

## 選 token 的方法

每個 token 的數值和用途見 `references/tokens.md`。最常用的如下：

- **文字：**
  - 一般文字：`text-primary`
  - 次要文字：`text-secondary`
  - 弱提示：`text-tertiary`（白底 3.4:1，只用於非必要資訊）
  - 深色底上的文字：`text-white`
- **品牌和 CTA：**
  - 主要按鈕：`brand-primary` 底配 `text-white`，按鈕字用 16px SemiBold 或以上，因為對比只有 3.2:1
  - 綠色文字連結：`brand-secondary`
- **底色和模組邊界（R6）：** 頁面底用 `background-grey-50`，模組或卡片用 `background-white`，圓角用 `radius-card-s`。需要線框時用 `stroke-secondary` 配 `stroke-width-regular`。
- **字體：**
  - 商品名、內文：`body-2-regular`
  - 輔助說明：`body-3-regular`
  - 區塊標題：`headline-3-semibold`
  - 價錢：`price-listing-main`、`price-listing-multi-col`、`price-detail-page-main`
- **間距：** 頁面左右邊距和卡片內距用 `spacing-16`；元素之間主要用 `spacing-8` 和 `spacing-12`（R5 資訊密度）；區塊之間用 `spacing-24`。
- **陰影：** 卡片用 `shadow-card`，modal 用 `shadow-modal`，固定底部欄用 `shadow-footer`。
- **會員價和 BU 識別色：** `membership-*` 和 `bu-*` 只用於對應的會員價、會員標記和 BU 標籤，不借作其他用途。

## 平台注意事項

- **iOS 陰影：** SwiftUI 的 `shadow(radius:)` 大約等於 CSS blur 的一半，而且沒有 spread。`z12`、`z16`、`z20`、`zcard` 的負 spread 只能近似。
- **Android 陰影：** `Modifier.shadow(elevation)` 無法重現這些數值。要用 `Modifier.dropShadow`（Compose UI 1.9 起），或者用 `drawBehind` 自己畫，數值取自 `HKTVShadow`。
- **iOS 刪除線：** `hktvText()` 用的 `View.strikethrough` 需要 iOS 16 或以上。
- **只有 Light mode：** Figma 暫時沒有 Dark mode token，所以不要自行推算深色值。
- **中文字體：** Poppins 只包含拉丁字母和數字，中文會自動用系統字體顯示（iOS 是 PingFang HK）。

## Components

- **規格（逐步補）**：`references/components/`。已有 [Button](references/components/button.md)、[Price](references/components/price.md)、[Cart Button](references/components/cart-button.md) 同 [Text field／Dropdown／Phone](references/components/text-field.md)（Figma `3005:218`）。
- **寫 UI 順序**：reference skill 規格／平台參考檔 → app 已有 DS API → app source 同類複製 → skill tokens hard code＋**DS gap**。**唔**整包把 skill components 複製入 app DS 目錄。
- **Web／GCP**：Gate D ensure web repo `ds/`（tokens＋components 必 sync；icons 按需）。PDP 價錢未有程式碼。

## 檔案

| 檔案 | 內容 |
| --- | --- |
| `tokens/tokens.json` | 唯一來源（Design System 格式） |
| `tokens/web/hktv-tokens.css` | CSS variables 和字體 class（sync 入 web repo `ds/`） |
| `tokens/ios/HKTVTokens.swift` | iOS 寫 UI 必 reference 的 token 檔 |
| `tokens/android/HKTVTokens.kt` | Android 寫 UI 必 reference 的 token 檔 |
| `references/tokens.md` | 所有 token 的數值和用途速查 |
| `references/design-principles.md` | 設計原則 R1–R9 和 Ricky Pass 評審清單 |
| `references/native-repo-map.md` | iOS／Android runtime 路徑、mapping、Conflict 例 |
| `references/components/button.md` | Button 變體、尺寸、顏色同 token 對照 |
| `references/components/price.md` | 列表同 PDP 價錢、promotion text、unit price |
| `references/components/cart-button.md` | Cart button。不含 Outlined Cart Primary／Secondary |
| `references/components/text-field.md` | 文字欄、dropdown、電話號碼 |
| `references/components/icon.md` | Icon library 命名、改色、outline 優先 |
| `icons/icons.json` | Icon 清單（名稱、畫板、可唔可以改色） |
| `icons/source/` | 清理後的 SVG 來源 |
| `icons/web/` | Web SVG（按需 sync 入 `ds/icons/`） |
| `icons/ios/Icons.xcassets` | iOS 寫 UI 必 reference 的 icon 參考 |
| `icons/android/` | Android 寫 UI 必 reference 的 icon 參考 |
| `components/ios/HKTVButton.swift` | SwiftUI Button 參考實作 |
| `components/ios/HKTVPrice.swift` | 列表價錢參考實作 |
| `components/android/HKTVPrice.kt` | 列表價錢參考實作 |
| `components/android/HKTVButton.kt` | Compose Button 參考實作 |
| `components/web/hktv-button.css`／`.js` | Web Button（Custom Element），sync 入 `ds/` |
| `components/web/hktv-price.css`／`.js` | 列表價錢（Custom Element），sync 入 `ds/` |
| `components/ios/HKTVCartButton.swift` | Cart button 參考實作 |
| `components/android/HKTVCartButton.kt` | Cart button 參考實作 |
| `components/web/hktv-cart-button.css`／`.js` | Cart button（Custom Element），sync 入 `ds/` |
| `components/ios/HKTVTextField.swift` | 文字欄參考實作 |
| `components/android/HKTVTextField.kt` | 文字欄參考實作 |
| `components/ios/HKTVDropdown.swift` | Dropdown 收合欄參考實作 |
| `components/android/HKTVDropdown.kt` | Dropdown 收合欄參考實作 |
| `components/ios/HKTVPhoneField.swift` | 電話號碼參考實作 |
| `components/android/HKTVPhoneField.kt` | 電話號碼參考實作 |
| `components/web/hktv-text-field.css`／`.js` | 文字欄，sync 入 `ds/` |
| `components/web/hktv-dropdown.css`／`.js` | Dropdown，sync 入 `ds/` |
| `components/web/hktv-phone-field.css`／`.js` | 電話號碼，sync 入 `ds/` |
| `components/web/README.md` | Web starter：`ds/` sync、PIN、頁面引用 |
| `references/ds-artifact-map.md` | tokens／components 來源 vs app／web `ds/`、WebView 決策樹 |
| `templates/CLAUDE.md` | 給 native app repo 用的 `CLAUDE.md` 範本 |
| `templates/CLAUDE.webview.md` | 給 WebView／web repo 用的 `CLAUDE.md` 範本 |
| `templates/claude-settings.json` | vibe code repo：啟用 `hktvmall-uiux` |
| `scripts/sync_web_ds.py` | Gate D helper：skill → consumer `ds/`（裝 plugin 後可用；`${CLAUDE_SKILL_DIR}/scripts/…`） |

網上版 Design System（給人瀏覽）：https://claude.ai/code/artifact/0d300b80-d7e1-4644-93e0-e309da4c9f48
