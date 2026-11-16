# Text field、Dropdown、Phone

三個輸入欄共用外框：標題、輸入框、可選訊息。規格對齊 Figma 頁 [Text Field](https://www.figma.com/design/F0tjdruLjJTfWgmTeZKBnw/Design-System?node-id=3005-218)（`3005:218`）。寫 UI 時 reference 本規格同 `components/{ios|android|web}`。唔整包 scaffold 入 native app。

| 欄位 | 值 |
| --- | --- |
| `fileKey` | `F0tjdruLjJTfWgmTeZKBnw` |
| 文字欄 | `5686:130` 一組 |
| Dropdown | `5690:356` 一組 |
| Phone | `5686:231` 一組 |
| 讀取日期 | 2026-11-13 |

## 共用外框

| Size | 輸入框高 | 欄位總高（單行標題） |
| --- | --- | --- |
| M | 56 | 86 |
| S | 48 | 78 |

標題同輸入框之間是 `spacing-8`。輸入框同訊息之間是 `spacing-4`。左右內距 `spacing-16`。圓角 `radius-card-s`（12）。框寬 `stroke-width-regular`。

標題同已填文字用 `body-1-regular`、`text-primary`。Placeholder 用同一個字級、`text-placeholder`。錯誤訊息用 `body-2-regular`、`text-danger`。

| 狀態 | 框 | 底 | 文字 |
| --- | --- | --- | --- |
| Placeholder、Filled | `stroke-secondary` | `background-white` | 已填 `text-primary`；未填 `text-placeholder` |
| Focus、Typing | `text-primary` | `background-white` | 同上。游標 `brand-primary` |
| Error、Error-Typing | `text-danger` | `background-white` | 輸入文字 `text-primary`。訊息 `text-danger` |
| Disabled | `stroke-secondary` | `background-grey-75` | `text-disable` |

Disabled 由 `18745:65786` 對色。`#f2f2f2` 是 `background-grey-75`，`#a3a3a3` 是 `text-disable`。

清除 icon 是 `icon-on-textfieldclear-regular-filled`，色 `#d3d3d3`。沒有語義 token 等於這個色，用原始色階 `neutral-200`。

## Text field

`HKTVTextField`。

| State | 說明 |
| --- | --- |
| Placeholder | 顯示 hint |
| Focus | 框變深，仍是 hint |
| Typing | 顯示輸入文字同游標 |
| Filled | 顯示輸入文字，無游標 |
| Error | 顯示輸入文字、清除 icon、錯誤訊息 |
| Error-Typing | 同 Error，再加游標 |
| Disabled | 不可輸入 |

可選插槽，預設隱藏：

- `$` 前綴
- 密碼圓點同 `icon-hide-regular-outlined`

## Dropdown

`HKTVDropdown`。只畫收合的欄位。Figma 這個節點沒有展開選單，選中值由呼叫端傳入。

| State | 說明 |
| --- | --- |
| Placeholder | hint |
| Focus | 框變深 |
| Filled | 顯示選中值 |
| Disabled | 同共用 Disabled |

右側 20px `icon-chevrondown-small-outlined`。20 沒有 token。沒有 Error、Typing。

## Phone

`HKTVPhoneField`。左邊區碼（預設 `+852`）加 20px chevron，右邊號碼欄。兩格間距 `spacing-8`。區碼寬 109。

| State | 說明 |
| --- | --- |
| Placeholder | 號碼欄是 hint |
| Focus | 號碼欄框變深 |
| Typing | 號碼同游標 |
| Filled | 號碼 |
| Error | 號碼、清除 icon、錯誤訊息 |

這組沒有 Disabled。區碼欄的框跟號碼欄同一狀態色。

## 原始碼

| 平台 | 檔 |
| --- | --- |
| iOS | `HKTVTextField.swift`、`HKTVDropdown.swift`、`HKTVPhoneField.swift` |
| Android | 同名 `.kt` |
| Web | `hktv-text-field`、`hktv-dropdown`、`hktv-phone-field` 的 css 同 js |

Icon 由呼叫端傳入。沒有傳圖時，參考實作畫一個同色的簡單 chevron 或清除記號，正式畫面仍應用 icon library 的圖。
