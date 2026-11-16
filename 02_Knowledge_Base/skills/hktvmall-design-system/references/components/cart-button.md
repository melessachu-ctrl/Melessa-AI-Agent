# Cart Button

SKU 上的小圓角或橢圓按鈕，用來加購物車、大手折扣、Cashback、到貨通知或收藏。規格對齊 Figma component set。寫 iOS／Android UI 時必 reference 本規格同 `components/{ios|android}/HKTVCartButton.*`。Web 用 `<hktv-cart-button>`。唔整包 scaffold 入 native app。

| 欄位 | 值 |
| --- | --- |
| Figma | [Cart Button](https://www.figma.com/design/F0tjdruLjJTfWgmTeZKBnw/Design-System?node-id=7088-1450) |
| `fileKey` | `F0tjdruLjJTfWgmTeZKBnw` |
| 節點 | `7088:1450` |
| 讀取日期 | 2026-11-13 |

## 不放入 plugin

`Type=Outlined Cart (Primary)` 同 `Type=Outlined Cart (Secondary)` 不收進規格，也不做程式。不要用 `Cart (Default)` 的綠色去補一顆橢圓購物車；那會變成被排除的 Primary。

## 變體

| 屬性 | 值 |
| --- | --- |
| Type | `Cart`（Default）、`Discount`（大手折扣）、`Cashback`、`NotifyMe`、`Favourite` |
| Size | `L` 36×36、`S` 32×32。這兩個邊長沒有 token |
| Style | `Oval`（`radius-full`）、`Rounded`（`radius-card-xs`，8） |

`Cart` 在 Figma 只有 `Rounded`。傳 `Oval` 時仍畫 `Rounded`。

沒有 Pressed、Hover、Focus、Disabled。不要自己加。

## 顏色同內容

| Type | 底 | 內容 | Icon／字色 |
| --- | --- | --- | --- |
| `Cart` | `brand-primary` | `icon-old-cart-regular-filled` | `text-white` |
| `Discount` | `text-highlight` | 兩行「大手」「折扣」 | `text-white` |
| `Cashback` | `orange-75` | `icon-openexternallink-regular-outlined` | `yellow-800` |
| `NotifyMe` | `background-disable` | `icon-notification-regular-outlined` | `text-primary` |
| `Favourite` | `background-white`，框 `stroke-secondary`、`stroke-width-regular` | `icon-favourite-regular-outlined` | `text-secondary` |

Notify Me 的底色數值同時等於 `stroke-secondary`。這不是停用狀態，實作用 `background-disable` 因為它是背景 token。

Icon 跟 [icon.md](icon.md)，outlined 優先的規則不改收藏同購物車：Figma 指定的就是 filled cart 同 outlined favourite／notification／open external link。

### 尺寸

| Size | 按鈕 | Cart icon | 其他 icon |
| --- | --- | --- | --- |
| L | 36 | 24.75 | 16 |
| S | 32 | 22 | 14 |

這些 icon 尺寸沒有 token。Cart 的 L／S 來自分別的 symbol。其他 icon 的 L 是 36 裡左右各留 10；S 按比例。

大手折扣的 Figma 字是自訂向量，字高約 9。沒有 9px text token。參考實作用 `caption-2-semibold`（8）同 `text-white`，標為 DS gap。

Cashback 沒有語義 token 等於這兩個色，所以用原始色階：底 `orange-75`，icon `yellow-800`。不要改用 `background-orange-75`（那是 yellow-75）或 `membership-price-text-dvip`。

## 原始碼

| 平台 | 檔 |
| --- | --- |
| iOS | `components/ios/HKTVCartButton.swift` |
| Android | `components/android/HKTVCartButton.kt` |
| Web | `components/web/hktv-cart-button.css`、`hktv-cart-button.js` |

Icon 由呼叫端傳入（Web 用 `data-slot="icon"`）。Discount 沒有傳圖時顯示「大手」「折扣」兩行。
