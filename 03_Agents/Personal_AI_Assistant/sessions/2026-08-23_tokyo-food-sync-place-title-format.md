# Session｜2026-08-23｜東京美食 Wanderlog 同步、`地區｜景點名` 格式、Skills 更新

## 做了甚麼

### Trip.com 東京美食整理

- 整理 [Trip.com 東京美食 2026](https://hk.trip.com/blog/tokyo-food-recommendation/) **17 間**餐廳（編號 1–17），供後續選取
- 依 Melessa 指示 **排除 #5、#11、#13、#15**，其餘 **13 間** 加入 Wanderlog／（計劃）Google Maps

### Wanderlog ✅

- 行程：**前往Tokyo的旅行**（`afnmohflkhpeqqpp`）
- Section：**東京 Food**（注意空格與 `F` 大寫）
- **13 間餐廳** 已全部新增；note 格式：**粗體 `地區｜景點名`** + `交通：` + `•` 特色
- **東京景点** 16 個景點 note 已補 **交通 + 特色**（保留原有補充文字）
- 舊「東京 Food」部分地點（如築地市場、月島文字燒、阿美橫町）已升級為 **`地區｜景點名`** 標題

### Google Maps ⏸️ 未完成

- 目標 list：**東京美食**
- 約 **3/13** 確認存入（肉亭ふたごiki、壽司三味、敘敘苑）；其餘 10 間 + list note 未完成
- 阻塞：`cursor-ide-browser` MCP 多次被拒／Aborted；子 agent 無法共用已 lock 的 browser tab；搜尋結果偶爾點錯店

### Skills 更新 ✅

- **`update-wanderlog`**：預設 note 標題改為 **`地區｜景點名`**（全形 `｜`）；新增 `formatPlaceTitle`、`noteContainsPlace`、舊格式升級指引；reference 加東京 Food 範例表
- **`google-maps-bookmark`**：Maps list note 預設 **`地區｜景點名`**（純文字）；交通／特色放 Wanderlog；新增與 Wanderlog 分工表、批次清單模板

## 未完成甚麼

- [ ] Google Maps「**東京美食**」：剩餘 ~10 間 Save + 全部 list note（`地區｜景點名`）
- [ ] （可選）抽查 Wanderlog autocomplete 是否個別存錯 place（如色川、鳥貴族）

## 下次由哪裡開始

1. **Local Agent** + 已登入 Google 帳號，開 Maps Saved →「東京美食」看現況
2. 單一 browser：`navigate` → CDP `saveToList`（加 `expect` regex）→ 最後一次 list 視圖 fill note
3. 詳見 `02_Knowledge_Base/skills/google-maps-bookmark/SKILL.md`

## 今日學到

- Maps 與 Wanderlog **標題格式應一致**（皆 `地區｜景點名`）；Maps 只寫標題一行，交通／特色放 Wanderlog
- Google Maps 批次存 **單一 browser + CDP** 已是最快路徑；開多 tab／派 subagent 無法加速（無法共用 session）
- Wanderlog section 名稱須完全匹配（`東京 Food` ≠ `東京food`）

## 備註

- **不記錄、不提交** `connect.sid`
- Skill 真源：`02_Knowledge_Base/skills/update-wanderlog/`、`google-maps-bookmark/`
