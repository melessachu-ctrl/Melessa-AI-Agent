# Button

通用操作按鈕，用來觸發頁面或流程中的動作。規格對齊 Figma component set。寫 iOS／Android UI 時 **必 reference** 本規格同 `components/{ios|android}/HKTVButton.*`。順序：skill 規格／參考 → app 已有 DS API → **app source 同類 button 直接複製／reuse** → skill tokens hard code＋DS gap。**唔**整包 scaffold 入 app DS 目錄。**Conflict**（UIKit legacy `HKTVButton`）先問。**Web**：Gate D ensure 本 repo `ds/`（skill 覆蓋）；頁面用 `<hktv-button>`。

| 欄位 | 值 |
| --- | --- |
| Figma | [Button](https://www.figma.com/design/F0tjdruLjJTfWgmTeZKBnw/Design-System?node-id=3135-812) |
| `fileKey` | `F0tjdruLjJTfWgmTeZKBnw` |
| 節點 | `3135:812` |
| 預設變體 | Appearance `Filled`、Shape `Rounded`、Size `L`、State `Enable` |
| 讀取日期 | 2026-11-07 |

## 變體

| 屬性 | 值 |
| --- | --- |
| Appearance | `Filled`、`Secondary`、`Outline`、`Text` |
| Shape | `Rounded`、`Capsule` |
| Size | `L`、`M`、`S`、`XS` |
| State | `Enable`、`Disabled`、`Loading` |
| 內容 | 標籤（預設文案 `Button`）、可選 `startIcon`、可選 `endIcon` |

Figma 這組沒有 Pressed、Hover、Focus。不要自行加 `brand-secondary` 當按下色，或自訂 focus 環顏色。平台如果必須有按下或焦點樣式，先列出缺口再問。

## 尺寸

高度固定（`XS` 除外，見下）。標籤過長時保持單行，按鈕隨內容加寬，不要低過最小寬度。標籤在按鈕內水平垂直居中。

### Rounded

| Size | 高度 | 最小寬度 | 水平內距 | 圓角 |
| --- | --- | --- | --- | --- |
| L | 52 | 88 | `spacing-16` | `radius-card-s`（12） |
| M | 44 | 76 | `spacing-12` | `radius-card-s`（12） |
| S | 36 | 64 | `spacing-8` | `radius-button-s`（10） |
| XS | 內容高，約 32 | 48 | `spacing-8`，垂直 `spacing-6` | `radius-card-xs`（8） |

S 的 Figma auto-layout 同時寫了垂直內距 12。框高度已固定為 36，實作以高度為準，標籤居中。

### Capsule

Capsule 的圓角都大於高度的一半，看起來是膠囊。實作用 `radius-full`，不要抄 Figma 上的 40 或 24。

| Size | 高度 | 最小寬度 | 水平內距 | Figma 圓角（只作對照） |
| --- | --- | --- | --- | --- |
| L | 52 | 84 | `spacing-20` | 40 |
| M | 44 | 72 | `spacing-16` | 24 |
| S | 36 | 64 | `spacing-12`（四邊） | 24 |
| XS | 內容高，約 32 | 48 | `spacing-8`，垂直 `spacing-6` | 24 |

`Text` 不畫底、不畫框。它仍跟同一個 Size、Shape 的高度同內距，讓點擊範圍一致。

## 顏色

只用語義 token。Disabled 的 Filled 同 Secondary 都變成灰底，不是把綠色減淡。

| Appearance | Enable 底 | Enable 字／icon／框 | Disabled 底 | Disabled 字／框 |
| --- | --- | --- | --- | --- |
| Filled | `brand-primary` | 字同 icon：`text-white` | `background-grey-75` | 字同 icon：`text-disable` |
| Secondary | `background-green-75` | 字同 icon：`brand-primary` | `background-grey-75` | 字同 icon：`text-disable` |
| Outline | 透明 | 字、icon、框：`brand-primary`；框寬 `stroke-width-regular` | 透明 | 字、icon、框：`text-disable` 只用於字同 icon；框用 `stroke-secondary` |
| Text | 透明 | 字同 icon：`brand-primary` | 透明 | 字同 icon：`text-disable` |

`background-grey-75` 是 `#f2f2f2`（Figma `Neutral/75`）。不要改用 `background-disable`（`#e5e8eb`）。

Filled 的白字在 `brand-primary` 上對比約 3.2:1。L／M 用 16px SemiBold，符合按鈕大字。不要把 Filled 的標籤改細過 16px SemiBold。

Loading 沿用該 Appearance 的 Enable 底色同框色。指示器顏色跟 Enable 的字色：Filled 用 `text-white`，其餘用 `brand-primary`。

## 字體

| Size | Filled／Secondary／Outline | Text |
| --- | --- | --- |
| L、M | `title-semibold`（Figma `Title · 16/03 SemiBold`） | `body-1-regular`（Figma `Body 1 · 16/01 Regular`） |
| S、XS | `body-2-semibold`（Figma `Body 2 · 14/03 SemiBold`） | `body-2-regular`（Figma `Body 2 · 14/01 Regular`） |

## Icon

Icon 是插槽，不是固定的心形或箭咀。顏色跟該狀態的字色。Icon 同標籤之間是 `spacing-4`。

| Size | 起始 icon | 結尾 icon |
| --- | --- | --- |
| L、M | 22 | 20 |
| S、XS | 18 | 18 |

Figma 有幾格 Outline 的 L／M icon 兩邊都是 20。其餘 L／M 是 22／20。實作跟上面這張表，直到 Figma 改齊。

## Loading

Loading 以指示器取代標籤，按鈕尺寸不變。這個狀態不可點擊。不要把 Figma 裡的 loading 點陣圖放進 app。

## 原始碼

| 平台 | Skill 參考檔（必 Read） | Runtime／落地 |
| --- | --- | --- |
| iOS | `components/ios/HKTVButton.swift` | app DS API 或跟規格寫入 feature；mall 常見 `DesignSystemComponent/` |
| Android | `components/android/HKTVButton.kt` | 同上；mall 常見 `core/ui/.../theme/` |
| Web／GCP | `components/web/hktv-button.css` + `hktv-button.js` | web repo `ds/`；頁面用 `<hktv-button>`。見 `components/web/README.md` |

Token 名稱見 `references/tokens.md`。Partial 色值經 `native-repo-map.md` mapping（`HKTVColor.brandPrimary` ↔ `Appearance.Brand.primary`／`AppColor.green1` 等）。

### Conflict：legacy UIKit `HKTVButton`

iOS mall 根目錄常有 `HKTVMall/HKTVButton.swift`：`@IBDesignable class HKTVButton: UIButton`——**唔係**本規格嘅 SwiftUI DS Button。搜尋時必須核對 `import SwiftUI` 同 API 形狀。唔好因為檔名相同就當已有 DS。跟本規格／skill 參考寫新畫面，或 reuse app 內其他 SwiftUI 同類 button；**禁止**整包 scaffold plugin 檔入 DS 目錄覆蓋 legacy。

## 平台寫法

| 角色 | Web | iOS | Android |
| --- | --- | --- | --- |
| 主底 | `var(--hktv-brand-primary)` | `HKTVColor.brandPrimary` | `HKTVColor.BrandPrimary` |
| 次底 | `var(--hktv-background-green-75)` | `HKTVColor.backgroundGreen75` | `HKTVColor.BackgroundGreen75` |
| 停用底 | `var(--hktv-background-grey-75)` | `HKTVColor.backgroundGrey75` | `HKTVColor.BackgroundGrey75` |
| 白字 | `var(--hktv-text-white)` | `HKTVColor.textWhite` | `HKTVColor.TextWhite` |
| 品牌字／框 | `var(--hktv-brand-primary)` | `HKTVColor.brandPrimary` | `HKTVColor.BrandPrimary` |
| 停用字 | `var(--hktv-text-disable)` | `HKTVColor.textDisable` | `HKTVColor.TextDisable` |
| 停用框 | `var(--hktv-stroke-secondary)` | `HKTVColor.strokeSecondary` | `HKTVColor.StrokeSecondary` |
| L／M 標籤 | `hktv-title-semibold` | `.hktvText(HKTVText.titleSemibold)` | `HKTVText.TitleSemibold` |
| Text L／M | `hktv-body-1-regular` | `.hktvText(HKTVText.body1Regular)` | `HKTVText.Body1Regular` |
| S／XS 標籤 | `hktv-body-2-semibold` | `.hktvText(HKTVText.body2Semibold)` | `HKTVText.Body2Semibold` |
| Text S／XS | `hktv-body-2-regular` | `.hktvText(HKTVText.body2Regular)` | `HKTVText.Body2Regular` |
| Rounded S 圓角 | `var(--hktv-radius-button-s)` | `HKTVRadius.buttonS` | `HKTVRadius.ButtonS` |
| Capsule L 水平內距 | `var(--hktv-spacing-20)` | `HKTVSpacing.s20` | `HKTVSpacing.S20` |

## 實作時不要做

- 不要覆蓋 native runtime 已有的 **DS** `HKTVButton`（SwiftUI／Compose）。Web repo `ds/` 內 skill 副本下次 sync **以 skill 覆蓋**。
- 不要把 UIKit legacy `HKTVButton` 當成 DS 已存在而略過；Conflict 先問。
- 不要手改 plugin 入面 starter 檔的顏色或字級；要改先改規格同 token。
- 不要寫死 hex、px 字級或 Poppins 字重（高度／icon 尺寸除外，見 spec）。
- 不要在沒有 Pressed 變體的情況下改底色。
- 不要由 Swift／Kotlin 自動轉成 Web，或由 Web 轉 native。
- 主要動作用 Filled。同一個畫面不要並列多個 Filled。
