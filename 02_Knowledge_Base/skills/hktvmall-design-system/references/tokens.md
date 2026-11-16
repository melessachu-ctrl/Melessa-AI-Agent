# HKTVmall tokens（速查）

Generated from tokens.json (HKTVmall Design System, Figma F0tjdruLjJTfWgmTeZKBnw, synced 2026-11-05). Do not edit by hand: change tokens.json and regenerate.

每個 token 的名稱在三個平台的寫法：

| tokens.json | Web | iOS (SwiftUI) | Android (Compose) |
| --- | --- | --- | --- |
| `text-sale-price` | `var(--hktv-text-sale-price)` | `HKTVColor.textSalePrice` | `HKTVColor.TextSalePrice` |
| `green-800`（primitive） | `var(--hktv-green-800)` | `HKTVPrimitive.green800` | `HKTVPrimitive.Green800` |
| `spacing-16` | `var(--hktv-spacing-16)` | `HKTVSpacing.s16` | `HKTVSpacing.S16` |
| `radius-card-s` | `var(--hktv-radius-card-s)` | `HKTVRadius.cardS` | `HKTVRadius.CardS` |
| `stroke-width-regular` | `var(--hktv-stroke-width-regular)` | `HKTVBorderWidth.regular` | `HKTVBorderWidth.Regular` |
| `shadow-card` | `var(--hktv-shadow-card)` | `.hktvShadow(HKTVShadow.card)` | `HKTVShadow.Card` |
| `body-2-regular`（字體） | `class="hktv-body-2-regular"` | `.hktvText(HKTVText.body2Regular)` | `HKTVText.Body2Regular` |

## 語義顏色（UI 一律用這些）

| Token | 值 | 用途 |
| --- | --- | --- |
| `text-primary` | #1c1c1c ← neutral-950 | 主要文字：標題、商品名、內文。白底 17:1。 |
| `text-secondary` | #575757 ← neutral-700 | 次要文字：輔助說明、規格、metadata。白底 7.2:1。 |
| `text-tertiary` | #8b8b8b ← neutral-500 | 第三層文字：時間戳、弱提示。白底只有 3.4:1，未達 4.5:1，只宜用於 18px 以上或非必要資訊。 |
| `text-placeholder` | #b2b2b2 ← neutral-300 | 輸入框 placeholder。白底 2.1:1，不可用來寫任何必要資訊。 |
| `text-disable` | #a3a3a3 ← neutral-400 | 停用狀態文字。白底 2.5:1（停用狀態可豁免對比要求）。 |
| `text-white` | #ffffff ← neutral-0 | 深色或品牌色底上的文字。 |
| `text-sale-price` | #cf062a ← red-800 | 售價／優惠價。白底 5.7:1。價錢一律顯示一位小數（$289.0）。 |
| `text-danger` | #e4483f ← red-600 | 錯誤訊息、警示文字。白底 4.0:1，略低於 4.5:1，建議 14px Medium 以上使用。 |
| `text-highlight` | #fd7c0a ← orange-500 | 重點強調（橙）。白底 2.6:1，不宜作細字內文，只用於大字或配合底色。 |
| `brand-primary` | #00a759 ← green-800 | HKTVmall 主品牌綠：主要 CTA 底色、選中狀態、品牌元素。白字在其上 3.2:1，只符合 3:1（大字／粗體 Button 字）。 |
| `brand-secondary` | #007b55 ← green-900 | 深品牌綠：按下狀態、綠色連結文字。白底 5.3:1，可作文字色。 |
| `brand-tertiary` | #00ce6e ← green-600 | 淺品牌綠：裝飾、icon、插圖點綴。白底 2.1:1，不可作文字。 |
| `brand-flagship-store` | #c0812b ← yellow-700 | 旗艦店標記（金棕）。白底 3.3:1，只用於 badge／icon，不作細字。 |
| `background-white` | #ffffff ← neutral-0 | 頁面與卡片的主要底色。 |
| `background-grey-50` | #f7f7f7 ← neutral-50 | 頁面底色（卡片之間的灰底）。 |
| `background-grey-75` | #f2f2f2 ← neutral-75 | 次層灰底：分隔區塊、輸入框底。 |
| `background-black` | #000000 ← neutral-1000 | 全黑底：影片、沉浸式區塊。 |
| `background-disable` | #e5e8eb ← neutral-100 | 停用元件底色。 |
| `background-error` | #ffebee ← red-25 | 錯誤提示區塊底色，配 text-danger。 |
| `background-green-50` | #f2fbf7 ← green-50 | 品牌淺綠底：資訊提示、選中卡片。 |
| `background-green-75` | #e5f6ee ← green-75 | 品牌淺綠底（較深一級）。 |
| `background-warning` | #fff7cd ← yellow-50 | 警告提示底色（淺黃）。 |
| `background-inform` | #d0f2ff ← blue-75 | 資訊提示底色（淺藍）。 |
| `stroke-primary` | #f2f2f2 ← neutral-75 | 分隔線、卡片邊框（最淡）。 |
| `stroke-secondary` | #e5e8eb ← neutral-100 | 輸入框、按鈕外框、較明顯的分隔線。屬裝飾性邊框；作為可互動控制的唯一邊界時對比不足 3:1。 |
| `overlay-70` | #000000b2 ← overlay-neu-1000-70 | Modal／bottom sheet 背後的遮罩。 |
| `overlay-30` | #0000004d ← overlay-neu-1000-30 | 較輕的遮罩：圖片上的文字墊底、輕 overlay。 |
| `membership-price-text-plus` | #00b539 ← green-700 | Plus 會員價文字。白底 2.7:1，未達文字對比要求，建議搭配粗體大字或底色。 |
| `membership-plus` | #67fb98 ← green-400 | Plus 會員標記色（badge／icon）。 |
| `membership-price-text-vip` | #5e30a7 ← purple-800 | VIP 會員價文字。白底 8.6:1。 |
| `membership-price-text-gvip` | #e4b40b ← yellow-600 | GVIP 會員價文字。白底 1.9:1，對比嚴重不足，建議放在深色或 membership-gvip-background 以外的處理，或改用更深色階。 |
| `membership-gvip` | #e4b40b ← yellow-600 | GVIP 會員標記色（badge／icon）。 |
| `membership-gvip-background` | #fff4cd ← yellow-75 | GVIP 區塊底色。 |
| `membership-vip` | #5e30a7 ← purple-800 | VIP 會員標記色。 |
| `membership-price-text-dvip` | #a76708 ← yellow-800 | DVIP 會員價文字。白底 4.6:1。 |
| `membership-vip-background` | #f5efff ← purple-50 | VIP 區塊底色。 |
| `membership-price-text-ppp` | #ff6c40 ← orange-600 | PPP 價文字。白底 2.8:1，未達文字對比要求。 |
| `bu-landmark` | #666666 | Landmark 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 5.7:1。 |
| `bu-supermarket` | #7cc73d | Supermarket 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 2.1:1，不可作細字文字色。 |
| `bu-personal-care` | #f5a623 | Personal Care 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 2.0:1，不可作細字文字色。 |
| `bu-beauty` | #fc5585 ← red-400 | Beauty 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 3.1:1，不可作細字文字色。 |
| `bu-fashion` | #2d2d2d | Fashion 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 13.8:1。 |
| `bu-macau` | #ae8223 | Macau 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 3.5:1，不可作細字文字色。 |
| `bu-pets` | #f97c46 | Pets 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 2.6:1，不可作細字文字色。 |
| `bu-mother-baby` | #77d1da | Mother&Baby 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 1.8:1，不可作細字文字色。 |
| `bu-gadgets` | #2a74e0 | Gadgets 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 4.5:1，不可作細字文字色。 |
| `bu-home-applicances` | #57c2bd | Home Applicances 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 2.1:1，不可作細字文字色。 |
| `bu-housewares` | #e3c100 | Housewares 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 1.8:1，不可作細字文字色。 |
| `bu-sports` | #77ae39 | Sports 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 2.7:1，不可作細字文字色。 |
| `bu-toys` | #0196ff | Toys 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 3.1:1，不可作細字文字色。 |
| `bu-insurance` | #98353b | Insurance 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 7.2:1。 |
| `bu-service-deal` | #8366ff | Service Deal 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 4.0:1，不可作細字文字色。 |
| `bu-cashback` | #ff6c40 ← orange-600 | Cashback 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 2.8:1，不可作細字文字色。 |
| `bu-3-hrs` | #711cd4 ← purple-600 | 3 HRS 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 7.4:1。 |
| `bu-live` | #00bfe0 | Live 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 2.2:1，不可作細字文字色。 |
| `bu-taobao` | #ff401e | Taobao 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 3.5:1，不可作細字文字色。 |
| `bu-public-housing` | #23814f | Public Housing 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 4.9:1。 |
| `bu-greenlab` | #3dd4ae | Greenlab 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 1.9:1，不可作細字文字色。 |
| `bu-the-place` | #33cccc | The Place 業務單位（BU）識別色，用於 BU 標籤、分類 icon、專區頭部。白底 2.0:1，不可作細字文字色。 |
| `background-red-50` | #ffe1e1 ← red-50 | 淺紅底：促銷、限時優惠區塊。 |
| `background-orange-75` | #fff4cd ← yellow-75 | 淺橙底（Figma 中指向 Yellow/75）。 |
| `background-blue-50` | #e6f7ff ← blue-50 | 淺藍底：資訊區塊。 |
| `background-ka-price` | #474747 ← neutral-800 | KA 價底色（深灰），配 text-white。 |

## 原始色階

先用語義 token。沒有數值完全一樣的語義 token 時，UI 可以用下面同一個原始色階。不要用名字相近但數值不同的語義 token。

- **green**：25 #eefff6、50 #f2fbf7、75 #e5f6ee、100 #ccffe2、200 #9efccb、300 #76ffbe、400 #67fb98、500 #09de7a、600 #00ce6e、700 #00b539、800 #00a759、900 #007b55、950 #04503a
- **neutral**：0 #ffffff、50 #f7f7f7、75 #f2f2f2、100 #e5e8eb、200 #d3d3d3、300 #b2b2b2、400 #a3a3a3、500 #8b8b8b、600 #535353、700 #575757、800 #474747、900 #272727、950 #1c1c1c、1000 #000000
- **red**：25 #ffebee、50 #ffe1e1、75 #ffc8c8、100 #f1b3bb、200 #ffa0a0、300 #ff6464、400 #fc5585、500 #ff4c4c、600 #e4483f、700 #d0021b、800 #cf062a、900 #ae061a、950 #8f0d1d
- **orange**：25 #fff8ed、50 #fff4e2、75 #fef3e8、100 #fdebd7、200 #ffdca8、300 #ffc272、400 #fe9e39、500 #fd7c0a、600 #ff6c40、700 #ff5500、800 #cc3b02、900 #82290c、950 #7e3310
- **yellow**：25 #fffceb、50 #fff7cd、75 #fff4cd、100 #fdf2ad、200 #fcf18c、300 #ffec74、400 #fae24a、500 #f7cf18、600 #e4b40b、700 #c0812b、800 #a76708、900 #844e0f、950 #7a4f01
- **blue**：25 #effaff、50 #e6f7ff、75 #d0f2ff、100 #b9e8ff、200 #ace1ff、300 #7acaff、400 #28a6ff、500 #1890ff、600 #1d78ff、700 #0057ff、800 #005aff、900 #004edc、950 #04297a
- **purple**：25 #f8f7ff、50 #f5efff、75 #f1e9ff、100 #efebff、200 #e5d3ff、300 #b680ff、400 #a35cfd、500 #852cf1、600 #711cd4、700 #7039c7、800 #5e30a7、900 #4e2989、950 #30195c
- **overlay**：overlay-neu-1000-70 #000000b2、overlay-neu-1000-30 #0000004d

## 字體

Poppins，行高 140%，字距 0。

| Token | 大小 | 字重 | 用途 |
| --- | --- | --- | --- |
| `headline-1-regular` | 28px | 400 | 頁面大標題，Regular。 |
| `headline-1-medium` | 28px | 500 | 頁面大標題，Medium。 |
| `headline-1-semibold` | 28px | 600 | 頁面大標題，SemiBold。 |
| `headline-2-regular` | 24px | 400 | 頁面標題、大數字，Regular。 |
| `headline-2-medium` | 24px | 500 | 頁面標題、大數字，Medium。 |
| `headline-2-semibold` | 24px | 600 | 頁面標題、大數字，SemiBold。 |
| `headline-2-bold` | 24px | 700 | 頁面標題、大數字，Bold。 |
| `headline-3-regular` | 20px | 400 | 區塊標題，Regular。 |
| `headline-3-medium` | 20px | 500 | 區塊標題，Medium。 |
| `headline-3-semibold` | 20px | 600 | 區塊標題，SemiBold。 |
| `subtitle-regular` | 18px | 400 | 副標題、modal 標題，Regular。 |
| `subtitle-medium` | 18px | 500 | 副標題、modal 標題，Medium。 |
| `subtitle-semibold` | 18px | 600 | 副標題、modal 標題，SemiBold。 |
| `title-regular` | 16px | 400 | 卡片標題、列表標題（數值同 Body 1），Regular。 |
| `title-medium` | 16px | 500 | 卡片標題、列表標題（數值同 Body 1），Medium。 |
| `title-semibold` | 16px | 600 | 卡片標題、列表標題（數值同 Body 1），SemiBold。 |
| `body-1-regular` | 16px | 400 | 主要內文，Regular。 |
| `body-1-medium` | 16px | 500 | 主要內文，Medium。 |
| `body-1-semibold` | 16px | 600 | 主要內文，SemiBold。 |
| `body-2-regular` | 14px | 400 | 商品名、一般內文（最常用），Regular。 |
| `body-2-medium` | 14px | 500 | 商品名、一般內文（最常用），Medium。 |
| `body-2-semibold` | 14px | 600 | 商品名、一般內文（最常用），SemiBold。 |
| `body-3-regular` | 12px | 400 | 輔助說明、metadata，Regular。 |
| `body-3-medium` | 12px | 500 | 輔助說明、metadata，Medium。 |
| `body-3-semibold` | 12px | 600 | 輔助說明、metadata，SemiBold。 |
| `caption-1-regular` | 10px | 400 | badge、標籤、細註，Regular。 |
| `caption-1-medium` | 10px | 500 | badge、標籤、細註，Medium。 |
| `caption-1-semibold` | 10px | 600 | badge、標籤、細註，SemiBold。 |
| `caption-1-bold` | 10px | 700 | badge、標籤、細註，Bold。 |
| `caption-2-regular` | 8px | 400 | 最小標記（8px）；只用於 badge 內的極短字，不作閱讀文字，Regular。 |
| `caption-2-medium` | 8px | 500 | 最小標記（8px）；只用於 badge 內的極短字，不作閱讀文字，Medium。 |
| `caption-2-semibold` | 8px | 600 | 最小標記（8px）；只用於 badge 內的極短字，不作閱讀文字，SemiBold。 |
| `price-detail-page-main` | 24px | 600 | PDP 主售價，配 text-sale-price。 價錢一律一位小數：$289.0。 |
| `price-detail-page-rp` | 12px | 400 | PDP 原價（刪除線），CSS 加 text-decoration: line-through。 價錢一律一位小數：$289.0。 |
| `price-listing-main` | 16px | 600 | 商品列表售價（單／雙欄），配 text-sale-price。 價錢一律一位小數：$289.0。 |
| `price-listing-multi-col` | 14px | 600 | 多欄列表售價，配 text-sale-price。 價錢一律一位小數：$289.0。 |
| `price-listing-rp` | 12px | 400 | 列表原價（刪除線），CSS 加 text-decoration: line-through。 價錢一律一位小數：$289.0。 |

## 間距

| Token | 值 | 用途 |
| --- | --- | --- |
| `spacing-2` | `2px` | 最細間距：icon 與文字之間的微調。 |
| `spacing-4` | `4px` | 緊密間距：badge 內距、標籤之間。 |
| `spacing-6` | `6px` | 小間距：價錢與原價之間、緊湊列表。 |
| `spacing-8` | `8px` | 基本間距：卡片內元素之間、grid gutter。 |
| `spacing-12` | `12px` | 中間距：卡片內距、區塊內元素組之間。 |
| `spacing-16` | `16px` | 標準頁面左右邊距、卡片內距。 |
| `spacing-20` | `20px` | Button Capsule L 水平內距（Figma 3135:812）。 |
| `spacing-24` | `24px` | 區塊之間的間距。 |
| `spacing-32` | `32px` | 大區塊之間。 |
| `spacing-36` | `36px` | 最大間距：頁面主要段落之間。 |

## 圓角

| Token | 值 | 用途 |
| --- | --- | --- |
| `radius-badge-s` | `4px` | 小 badge、標籤（4px）。 |
| `radius-badge-l` | `6px` | 大 badge、tag chip（6px）。 |
| `radius-card-xs` | `8px` | 小卡片、輸入框、按鈕（8px）。 |
| `radius-button-s` | `10px` | Button Rounded S（10px，Figma 3135:812）。 |
| `radius-card-s` | `12px` | 商品卡、一般卡片（12px）。 |
| `radius-card-l` | `16px` | 大卡片、bottom sheet 頂角（16px）。 |
| `radius-module` | `24px` | 首頁模組、大型容器（24px）。 |
| `radius-full` | `999px` | 膠囊形：pill 按鈕、圓形頭像（999px）。 |

## 邊框

| Token | 值 | 用途 |
| --- | --- | --- |
| `stroke-width-hairline` | `0.4px` | 極細線（0.4px）：高密度列表分隔。 |
| `stroke-width-regular` | `1px` | 標準邊框（1px）：卡片、輸入框。 |
| `stroke-width-bold` | `2px` | 粗邊框（2px）：選中、focus 狀態。 |

## 陰影

| Token | 值 | 用途 |
| --- | --- | --- |
| `shadow-card` | `0 4px 8px 0 rgba(145, 158, 171, 0.16)` | 一般卡片（Figma：Card）：商品卡、資訊卡浮於 background-grey-50 之上。 |
| `shadow-modal` | `0 4px 16px 0 rgba(145, 158, 171, 0.3)` | Modal、popup、對話框（Figma：Modal），比卡片明顯，配 overlay-70 遮罩。 |
| `shadow-footer` | `0 0 8px 0 rgba(145, 158, 171, 0.16)` | 固定底部欄（Figma：Footer）：加入購物車列、結帳列。無 Y 偏移，四邊均勻散開，所以向上也有陰影。 |
| `shadow-z1` | `0 1px 2px 0 rgba(145, 158, 171, 0.16)` | 高度 1：最輕的浮起，例如 tab bar、輕微分層的列表項。 |
| `shadow-z8` | `0 8px 16px 0 rgba(145, 158, 171, 0.16)` | 高度 8：下拉選單、tooltip、浮動按鈕。 |
| `shadow-z12` | `0 12px 24px -4px rgba(145, 158, 171, 0.16)` | 高度 12：popover、展開的卡片。 |
| `shadow-z16` | `0 16px 32px -4px rgba(145, 158, 171, 0.16)` | 高度 16：側邊抽屜、較大的浮層。 |
| `shadow-z20` | `0 20px 40px -4px rgba(145, 158, 171, 0.16)` | 高度 20：bottom sheet 等大型浮層。 |
| `shadow-z24` | `0 24px 48px 0 rgba(145, 158, 171, 0.16)` | 高度 24：最高層級的浮層。 |
| `shadow-zcard` | `0 12px 24px -4px rgba(145, 158, 171, 0.12), 0 0 2px 0 rgba(145, 158, 171, 0.2)` | 雙層卡片陰影（Figma：zCard）：一層大範圍柔光，加一層 2px 貼邊輪廓。適合放在白底上、需要邊緣清晰的卡片。 |
