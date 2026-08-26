# Session｜2026-08-26｜Google Maps「東京美食」續存＋note

## 做了甚麼

### Google Maps「東京美食」（`google-maps-bookmark`）

- 接續 2026-08-23 未完成項：Trip.com 13 間（排除 #5／#11／#13／#15）
- 開始時 list 已有 **6** places → 結束時 **15** places
- **新 Save 9 間**：龍吟、色川、人形町今半、鳥貴族、鴨 to 蔥、梅丘壽司美登利、炸牛排本村、燒肉內臟武田、沾麵ENJI
- **既有 3 間補 note**：肉亭ふたごiki、壽司三味、敘敘苑
- **舊格式升級**：月島文字燒、築地市場 → `地區｜景點名`
- Note 一律在 **list 視圖** `browser_fill` + blur 存檔

### 略過

- **鮪魚一代（エキュート上野）**：店已閉店，Maps 找不到可存 place → 略過  
  → Trip.com 13 間 Maps 涵蓋 **12/13**

### Skills（本回合有遵循）

- `google-maps-bookmark`（含 reference CDP `saveToList`／list note 流程）

## 未完成甚麼

- （本任務無阻塞；鮪魚一代永久略過）
- list 內既有「餺飥不動（東戀路店）」等非 Trip.com 項，未改動

## 下次由哪裡開始

- （可選）Maps「東京」list note 升級為 `地區｜景點名`
- （可選）河口湖 10 景點 Wanderlog note 升級
- （可選）刪 Lite App 備份 `Backup - img (pre PDP IMG)`

## 今日學到

- CDP `Runtime.evaluate` + `awaitPromise` 在此環境常回空 → 改用 `window.__saveResult` 非同步腳本再 poll，或 navigate → Save click → 選 list
- Save 選單開著時 side panel 易被 menu overlay 擋；先關 hamburger／Escape 再開 list
- 搜尋關鍵字要夠準（避免點錯 Maguro Bito／ecute Ueno）
