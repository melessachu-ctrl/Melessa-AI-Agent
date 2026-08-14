# Session｜2026-08-13｜Google Maps → Wanderlog 東京景點同步（Cloud Agent）

## 做了甚麼

- 從 Google AI Mode 分享文章整理 **13 個東京推薦景點**（地標、歷史文化、動漫體驗、購物商圈）
- 嘗試在 **Cloud Agent VM** 用瀏覽器登入 Google Maps／Wanderlog → **失敗**（Google 新裝置驗證、Facebook 需密碼；VM 與本機／手機 session 分離）
- 改用 Melessa 提供的 **Wanderlog `connect.sid`**（不含在 repo）+ Wanderlog 非官方 API，在雲端完成同步
- 目標行程：**前往Tokyo的旅行**（`afnmohflkhpeqqpp`）→ 清單 **「東京景点」**
- **結果**：13 個景點齊全，每個 place 的 note 為繁體中文名（例如 Shibuya Sky → 澀谷天空）
  - 原本已有 4 個（浅草寺、东京铁塔、新宿御苑、银座）→ 跳過新增，**補上中文 note**
  - 新加入 9 個（澀谷天空、東京晴空塔、明治神宮、吉卜力、寶可夢樂園、澀谷十字路口、麻布台之丘、哈利波特影城、阿美橫町）
- 說明 **Cloud vs Local Agent**、**Move to Local**（僅電腦 Agents 視窗）、手機 Remote 看不到 VM 瀏覽器

## 未完成甚麼

- 未在 Cloud Agent 內成功登入 **Google Maps**（無法自動讀「東京」saved list；景點來源為文章＋先前整理）
- 未設定 Wanderlog MCP 為 Cursor 固定工具（每次需貼 cookie 或日後配置 `WANDERLOG_COOKIE`）
- 若 Google Maps「東京」清單有 **第 14 個以後** 的景點，尚未比對

## 下次由哪裡開始

- **只改 Wanderlog**：貼新的 `connect.sid` + 說明要加／改的 list 即可（Cloud Agent 可用）
- **要用本機已登入 Chrome 操作 Google Maps**：在 **電腦 Cursor 新開 Local Agent chat**（或 Agents 視窗 Move to Local，條件多）
- **手機 Cursor Remote**：貼 cookie／景點清單文字，不必指望看到 VM 瀏覽器

## 今日學到

- `connect.sid` = Wanderlog 登入憑證；在**任一已登入 Wanderlog 的瀏覽器**複製即可讓 Cloud Agent 代操作（勿公開分享）
- Gmail MCP ≠ Google Maps 瀏覽器登入；兩者分開
- Cloud Agent 的 Chrome 與本機／手機 Chrome **不是同一個 profile**

## 備註

- **不記錄、不提交** `connect.sid` 或任何 credential
- Wanderlog 帳號顯示為 melessa07@yahoo.com.hk（Facebook 登入）
