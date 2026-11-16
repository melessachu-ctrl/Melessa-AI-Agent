# Native app repo map（iOS／Android runtime 落地）

HKTVmall consumer app（`ioshktvmall`／`androidhktvmall`）**已經有**部分 native Design System 產物，但檔名同 API **唔等於** plugin 產生嘅 `HKTVTokens.*`。

**寫 UI 決策以 skill 平台檔為先**（見 `hktvmall-design-system/SKILL.md` Reference-first）。本檔只負責：**點樣把 skill 語意 token 落地到 app 現有 API**，同 Conflict 點處理。

**硬性規則：**

1. Agent **必須** Read／reference skill 的 `tokens/{ios|android}`、`icons/{ios|android}`、`components/{ios|android}`（＋規格）。
2. **禁止**把整套 plugin tokens／icons／components **scaffold／複製入 app repo 當平行 DS**。
3. color／font／spacing／radius／shadow／border **不可自創**；數值來源係 skill tokens。

## 三態（輔助 runtime；唔阻擋寫 UI）

| 狀態 | 意思 | Agent 行為 |
| --- | --- | --- |
| **有完整副本** | 已有 `HKTVTokens.swift`／`.kt` | 用語意 token 決策；import runtime API |
| **Partial** | 有 Appearance／AppColor 等，唔完整 | 用語意 token 決策；下表 mapping 落地；缺維度 API 時仍跟 skill 數值，列 gap；**禁止**整包複製平行 `HKTVTokens` |
| **Conflict** | 檔名撞但 **唔係** DS API（例如舊 UIKit `HKTVButton`） | **停低問**；唔覆蓋；唔另開平行副本 |
| **無對應 API** | 完全搵唔到 mapping | 仍然用 skill token 寫 feature；列 gap；**唔** Absent 就停、**唔**整包 scaffold |

## Mall app 預設路徑

| 平台 | Tokens／Theme | Icons | DS components |
| --- | --- | --- | --- |
| iOS | `HKTVMall/DesignSystemComponent/Appearance/`（`Color/Appearance.swift`、`Color/Primitive.swift`、`Font/AppFont.swift`） | `HKTVMall/DesignSystemComponent/Icons.xcassets` | 同 `HKTVMall/DesignSystemComponent/`；**避開**根目錄舊 `HKTVMall/HKTVButton.swift` |
| Android | `core/ui/src/main/java/com/hktv/android/core/ui/theme/`（`AppColor.kt`、`AppTheme.kt`、`AppType.kt`）＋ `androidHKTVmall/src/main/res/values/colors.xml`（`<!-- Figma Style -->`） | 各 module `res/drawable/`（現多用 `ic_*`；DS 標準名係 `icon_*`） | 同 `core/ui/.../theme/` package |
| Web／GCP | 見 **web／WebView repo** 的 `ds/hktv-tokens.css`（`ds/PIN.json`） | `ds/icons/`（按需） | `ds/hktv-*.css|js` |

## 偵測訊號

### Token

| 優先 | 搜尋 |
| --- | --- |
| 完整副本 | `HKTVTokens.swift`、`HKTVTokens.kt`；Web 另查本 web repo `ds/hktv-tokens.css`＋`ds/PIN.json` |
| iOS Partial | `Appearance.swift`、`Primitive.swift`（通常喺 `DesignSystemComponent/Appearance/`） |
| Android Partial | `AppColor.kt`；或 `colors.xml` 內 `brand_primary`／`text_primary` |

有 `HKTVTokens.*` → 用 `HKTVColor`／`HKTVSpacing` 等落地。  
無 `HKTVTokens` 但有 Appearance／AppColor → **Partial**（下表 mapping）。  
兩者都無 → 仍 **reference skill token 檔** 寫 UI；列 runtime gap。

### Icon

| 平台 | 搜尋 |
| --- | --- |
| iOS | `Icons.xcassets`（mall：`DesignSystemComponent/Icons.xcassets`） |
| Android | `icon_*_regular_outlined` **或** `ic_*_regular_outlined` |
| Web | `icon-*-regular-outlined.svg` |

先用 skill `icons/icons.json` 揀名；runtime 用 repo 現有對等資源。缺名／無適合 → 問；新 icon **outline 優先**。**唔**從 plugin 整包／additive scaffold。

### Component

| 要搵 | 算「已有 DS」 | 唔算／Conflict |
| --- | --- | --- |
| Button iOS | SwiftUI `struct`／`View` 版，對齊 `references/components/button.md` | UIKit `@IBDesignable class HKTVButton: UIButton`（legacy） |
| Button Android | Compose `@Composable fun HKTVButton`（或同等） | 舊 View／XML button、僅檔名相似 |
| Price | SwiftUI／Compose 列表 `HKTVPrice`；Web `<hktv-price>` | 各 feature 內 ad-hoc price view（可 reuse 作「app 同類」） |
| Button Web | Custom Element `hktv-button` | 僅 class 名相似 |

**寫 component 順序：** skill 規格／參考 → app DS API → **app source 同類直接複製／reuse** → skill tokens hard code＋DS gap。

## 語意 token → native API mapping

語意名仍以 `tokens.json`／`references/tokens.md`／平台 `HKTVTokens.*` 為準。Partial repo **唔寫死自創 hex**；用對應 API 落地 **同一 skill 語意**。

| 語意 token | iOS（Appearance／Primitive） | Android Compose（AppColor） | Android XML（colors.xml） |
| --- | --- | --- | --- |
| `brand-primary` | `Appearance.Brand.primary` | `AppColor.green1` | `@color/brand_primary` |
| `brand-secondary` | `Appearance.Brand.secondary` | `AppColor.green0` | （無單一對應時列缺口問） |
| `brand-tertiary` | `Appearance.Brand.tertiary` | `AppColor.green2` | `@color/brand_tertiary` |
| `text-primary` | `Appearance.Text.primary` | `AppColor.textPrimary` | `@color/text_primary` |
| `text-secondary` | `Appearance.Text.secondary` | `AppColor.textSecondary` | `@color/text_secondary` |
| `text-tertiary` | `Appearance.Text.tertiary` | `AppColor.textTertiary` | `@color/text_tertiary` |
| `text-sale-price` | `Appearance.Text.salePrice` | `AppColor.textPriceRed` | （查 `text_danger`／價色；無則問） |
| `text-disable` | `Appearance.Text.disable` | （無則問） | 接近值唔好擅自頂替；先問 |
| `text-white` | `Appearance.Text.white` | `AppColor.textDarkPrimary`／`White` | `@color/white` |
| `background-white` | `Appearance.Background.white` | `AppColor.backgroundWhite` | `@color/white` |
| `background-grey-50` | `Appearance.Background.grey` | `AppColor.backgroundGrey` | （無專名則跟 skill 語意／問） |
| `background-grey-75` | `Appearance.Background.grey75` | （無則問） | **唔好**亂代；先問 |
| `background-green-50` | `Appearance.Background.green50` | `AppColor.backgroundGreen5` | `@color/background_green_50` |
| `background-green-75` | `Appearance.Background.green75` | `AppColor.backgroundGreen10` | `@color/background_green_75` |
| `stroke-primary` | `Appearance.Stroke.primary` | `AppColor.strokeSecondary`（命名可能交叉） | `@color/stroke_primary` |
| `stroke-secondary` | `Appearance.Stroke.secondary` | `AppColor.strokePrimary`／查實際 hex | `@color/stroke_secondary` |

Spacing／radius／shadow／text style：Partial 時通常未有對等 enum。需要時跟 skill `HKTVSpacing`／`HKTVRadius`／`HKTVShadow`／`HKTVText` 語意同數值；列 runtime gap；**禁止**整包引入平行 `HKTVTokens` 檔入 repo。

## Conflict 例子

| 情況 | 正確處理 |
| --- | --- |
| iOS 根目錄 `HKTVMall/HKTVButton.swift` 係 UIKit `UIButton` 子類 | **唔係** DS SwiftUI Button。跟 skill `button.md`／參考實作寫新畫面；或問用戶／IT。**唔**自動 scaffold plugin 檔入 DS 目錄 |
| 只搜到檔名 `HKTVButton` 就當已有 | 必須核對 import（SwiftUI vs UIKit）同 API |
| Android 已有 `ic_cart_regular_outlined`，skill 係 `icon_cart_regular_outlined` | 視為同物件；新碼跟 repo 資源名 |
| skill 無 component、app 有同類 chip／row | **直接複製／reuse** app 同類，保 style 統一 |
| 同時存在 `Appearance` 同手貼 `HKTVTokens` 且色值分歧 | 停低；以 `tokens.json`／Figma sync 為準，問用戶／IT |

## 同 ds-artifact-map 的關係

- Plugin 內 `tokens.json`／平台檔仍係 **canonical 規格**。
- 本檔係 **consumer runtime mapping**。
- WebView／GCP 跟 `ds-artifact-map.md`；純 native 畫面：Reference-first＋本檔 mapping。
