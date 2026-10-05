# Session｜2026-10-02～10-05｜Search Result category tree：護膚化妝卡、品牌列

## 做了甚麼

檔案：[Search Result — 3-4 Columns](https://www.figma.com/design/SPD3XrBhgiW57uBo28UxjZ/Search-Result---3-4-Columns)（`SPD3XrBhgiW57uBo28UxjZ`），頁「🏞 Thumbnail」。

### 護膚化妝（PC - Subcate）

- Instance [24219:52223](https://www.figma.com/design/SPD3XrBhgiW57uBo28UxjZ/Search-Result---3-4-Columns?node-id=24219-52223)（主元件 `24219:52222`）
- 18 張護膚化妝部門卡改為 **SubCate Card** `Layout=Default, Selected=Off`（set `22165:44342`，variant `22165:44343`）；名稱與商品圖保留
- 標題下加 **Brand Logo Section**。熱門品牌（網站護膚化妝街）：Fresh、L’Oréal Paris、The Body Shop、Shiseido、Laneige、Avène、innisfree、Melvita
- 手機框拉高，18 張卡可以一次看完。側欄仍選中「護理保健」

### 零食甜品品牌列（SubCate - 圖上字下（1））

- Frame [23987:694](https://www.figma.com/design/SPD3XrBhgiW57uBo28UxjZ/Search-Result---3-4-Columns?node-id=23987-694)
- 「超級市場」列表頂部的 Brand Logo Section 和 divider 已從流程拿走
- Child Category 內、「全部零食甜品 >」下面加了 Brand Logo Section
- Logo 換成 HKTVmall「零食 甜品」（`AA11150000000`）熱門品牌，網站次序：city'super、Garden、Ferrero、Frito-Lay、Big C、禮品佳、Mars Wrigley、微熱山丘
- 這支 phone 已從元件 `with Brand`（`9227:25187`）detach 成 frame `24239:749`，避免改到其他 option。時尚服飾的品牌列沒動

## 未完成甚麼

- 每行最右一個品牌 logo 仍被內容區裁切（跟護理保健的 Brand Logo Section 一樣）
- 圖上字下（1）已 detach，之後改 `with Brand` 主元件不會再同步到這支
- 零食甜品第三格：分類頁 alt 是 EDO，實際店舖圖是 Ferrero，畫面上用的是網站顯示的圖

## 下次由哪裡開始

- 若 marketing 要改其他 snack option（有圖／白卡）的品牌列位置，不要改主元件 `9227:25187`（多個 option 共用）
- Instance 裡的 auto-layout 子層**不要**設 `visible=false`（會刪掉，不是隱藏）。要從單一 demo 拿走圖層，先 detach 再刪

## 踩坑

- `visible=false`、`layoutPositioning=ABSOLUTE` 都不能安全地藏起 instance 內的 auto-layout 子層
- 分類熱門品牌要抓該 category submenu、且 `data-maincat` 對得上分類碼；alt 文字可以和圖片不一致
- 巢狀 id（`I…`）不能當 `upload_assets` 的 nodeId；先上傳到頁面，再把 `imageHash` 寫進 logo
