# Price

商品價錢。列表同商品頁（PDP）是兩個 component，價錢種類、原價、promotion text 同 unit price 共用規則。這份是規格。Swift、Kotlin、Web 已有**列表** starter；PDP 未有程式碼。SKU card 另做，裡面放列表價錢，不要把價錢排版寫進 card。

Component 不呼叫 API，也不假設 JSON 欄位名。畫面先把 API 對到下面的參數，再傳入。

| 欄位 | 值 |
| --- | --- |
| Figma 頁 | [Price](https://www.figma.com/design/F0tjdruLjJTfWgmTeZKBnw/Design-System?node-id=7081-1311) |
| `fileKey` | `F0tjdruLjJTfWgmTeZKBnw` |
| 頁節點 | `7081:1311` |
| 列表 | Search Result Card - Price，`7083:2002` |
| 列表附加列 | Search Result Card - KA/85 Price，`18852:22007` |
| PDP | PDP Price，`19688:9757` |
| 瀑布流 | Waterfall SKU - Price，`7081:1312`。對照列表 `Size=S`，不是第三個 component |
| Unit price | `14542:1023` |
| 讀取日期 | 2026-11-09 |

## 價錢種類

列表同 PDP 用同一組種類。顏色跟種類，字級跟畫面。

| 種類 | 主價錢色 |
| --- | --- |
| `RP` | `text-primary`。這是唯一顯示的正價，不是刪除線 |
| `SP` | `text-sale-price` |
| `VIP` | `membership-price-text-vip` |
| `GVIP` | `membership-price-text-gvip` |
| `DVIP` | `membership-price-text-dvip` |
| `PPP` | `membership-price-text-ppp` |
| `Cashback` | `bu-cashback` |
| `GreenLab` | `bu-greenlab`。這個 token 註明不可作細字；若 Figma 主價錢不是這個色，先問，不要換一個相近色 |
| `PublicHousing` | `bu-public-housing` |
| `NotForSale` | `text-primary`。沒有價錢數字，顯示傳入的文案，字級跟該畫面的主價錢 |

KA 同 85 折不是價錢種類。它們是附加列。KA 列的底用 `background-ka-price`，字用 `text-white`。85 badge 是可選插槽，沿用 Figma 的 badge，不要另外著色。

## 數字

主價錢、原價、unit price 傳入的是數字。顯示時先格式成一位小數，並加千分位。例如 `289` 顯示 `$289.0`，`9999.2` 顯示 `$9,999.2`。不要顯示 `$289` 或 `$9,999.20`。

## Promotion text 同刪除線原價

Promotion text 是後台讓 marketing 任意輸入的一句字，例如「日本北海道空運到港」。它不是產地欄。

它同刪除線原價共用一個位置。

- 有 promotion text：只顯示這句，不顯示刪除線原價。
- 沒有 promotion text，而且有原價：顯示刪除線原價。
- 兩個都傳入：以 promotion text 為準，仍然不顯示刪除線原價。

Component 可以同時接收這兩個可選參數，但不會兩行都畫。Figma `19688:9771` 的樣板把這句和 RP instance 都擺了出來；實作以上面的互斥為準。

刪除線原價用 12 Regular、`text-tertiary`。列表是 `price-listing-rp`，PDP 是 `price-detail-page-rp`。Promotion text 用同一個字級同 `text-sale-price`，不要刪除線。

## 列表 `HKTVPrice`

來源 `7083:2002`。

| 項目 | 值 |
| --- | --- |
| `Size=L` | 主價錢 `price-listing-main`（16 SemiBold）。單欄或雙欄 |
| `Size=S` | 主價錢 `price-listing-multi-col`（14 SemiBold）。多欄同瀑布流 |

由上至下：

1. Promotion text，或刪除線原價。兩個都沒有就略過這行。
2. 主價錢。`NotForSale` 時這一行是文案。
3. 可選 85 badge。
4. 可選 unit price。

有 KA 或 85 折附加列時，用 `18852:22007` 的結構，加在主價錢區之上。沒有附加列就不要留空行。

## PDP `HKTVPdpPrice`

來源 `19688:9757`。主價錢用 `price-detail-page-main`（24 SemiBold）。

由上至下：

1. 可選 KA／85 附加列。`Type=KA`、`85`、`KA+85` 才有。`Default` 沒有。
2. Promotion text，或刪除線原價。規則同上。
3. 主價錢。旁邊可選展開箭咀，只在呼叫端傳入動作時顯示。箭咀用 icon library 的 `icon-chevrondown-small-outlined`。
4. 可選 unit price。
5. 可選價格走勢。
6. 可選 Mall Dollar 回贈。Icon 用 `icon-malldollar-regular-filled`，這隻是固定色，不要 tint。

`NotForSale` 只顯示文案，不顯示數字、原價或 promotion text。

## Unit price

列表同 PDP 都可選。它不是第三個價錢 component。

| 參數 | 值 |
| --- | --- |
| 語言 | 中文單位例如「件」，英文單位例如 `unit` |
| 平均 | 沒有，或前面加「平均」／`Avg.` |
| 數字 | 一位小數 |

例子：`$9,999.2/件`、`平均 $9,999.2/件`、`$9,999.2/unit`、`Avg. $9,999.2/unit`。

## API 對應

| 參數 | 傳入 | 沒有資料時 |
| --- | --- | --- |
| 主價錢 | 數字 | `NotForSale` 時改傳文案 |
| 原價 | 數字，可空 | 不顯示刪除線 |
| Promotion text | 字串，可空 | 改顯示原價（如果有） |
| 價錢種類 | 上面的種類 | 先問，不要猜一種 |
| KA／85 | 有先顯示附加列 | 不留空位 |
| Unit price | 數字、單位、是否平均 | 不顯示 |
| Mall Dollar、價格走勢 | PDP 可選 | 不顯示 |

Component 收到的是這些參數，不是整個 API response。

## 原始碼

| 平台 | Skill 參考檔（必 Read） | Runtime／落地 |
| --- | --- | --- |
| iOS | `components/ios/HKTVPrice.swift` | app DS API 或跟規格寫入 feature；mall 常見 `DesignSystemComponent/` |
| Android | `components/android/HKTVPrice.kt` | 同上；mall 常見 `core/ui/.../theme/` |
| Web／GCP | `components/web/hktv-price.css` + `hktv-price.js` | web repo `ds/`；頁面用 `<hktv-price>`。見 `components/web/README.md` |

以上是列表價錢。PDP 的 `HKTVPdpPrice`／web PDP 未有程式碼。寫 UI 順序：skill 規格／參考 → app DS API → **app source 同類 price view 直接複製／reuse** → skill tokens hard code＋DS gap。**Web**：Gate D ensure `ds/`（skill 覆蓋）。Native 已有 DS `HKTVPrice` 唔覆蓋。Feature 內 ad-hoc price view 可當「app 同類」reuse，但唔當 DS 檔已 pin。Partial 時色／字經 `native-repo-map.md` mapping；缺 text style token 先問。

## 下一步先不做

- 不把價錢排版寫進 SKU card。
- 不新增 token。字級同顏色用現有 price、membership 同 BU token。
- 不在列表 component 裡做 PDP 的展開箭咀、價格走勢或 Mall Dollar。
