---
name: update-wanderlog
description: >-
  用 Wanderlog 非官方 API（connect.sid + wanderlog-mcp）在指定行程加入景點、撰寫 place note（粗體中文名、交通、景點特色概要）、
  更新或補齊既有清單。Use when the user asks to add places to Wanderlog, sync Maps list to Wanderlog,
  edit Wanderlog itinerary notes, or modify a Wanderlog trip list/section.
---

# Update Wanderlog（景點與 Note）

## 載入時機（必遵守）

命中下列**任一**情況時，必須載入並依本 skill 執行：

- 使用者要求在 **Wanderlog** 加入／刪除／更新 **景點（place）**
- 使用者要求為 Wanderlog 景點 **加 note／備註／中文名稱／交通／特色概要**
- 使用者要把 **Google Maps 清單** 或文章／表格裡的地點 **同步到 Wanderlog 某個 list／section**
- 使用者提到 **Wanderlog 行程**、**connect.sid**、或指定 trip 名稱（例如「前往Tokyo的旅行」）

## 工具與限制

- **首選**：`wanderlog-mcp` npm 套件（`RestClient` + `ShareDBClient`），在 Cloud Agent 亦可運作。
- **不用** 瀏覽器登入 Wanderlog（Cloud VM 與本機 session 分離，Facebook 登入常失敗）。
- **沒有** Wanderlog 官方公開 API；本 skill 使用其 web client 私有 API，可能隨時變動。
- **禁止** 把 `connect.sid`／`WANDERLOG_COOKIE` 寫入 repo、commit、session 檔、LOG、或 PR。

---

## 0. 憑證：`connect.sid`（必做）

### 使用者**未提供** `connect.sid` 時

**停止執行**，用繁體中文一次問清楚並教取得方式：

> 要代你改 Wanderlog，需要你在已登入 Wanderlog 的瀏覽器複製 **`connect.sid`** cookie 貼給我（約一年有效）。  
> 這是登入憑證，**請勿公開分享**；貼完後我不會寫入 repo。

**Chrome / Edge**

1. 開 [wanderlog.com](https://wanderlog.com) 並登入
2. 按 `F12`（或右鍵 → 檢查）
3. **Application**（應用程式）→ 左側 **Storage → Cookies → https://wanderlog.com**
4. 找到 **`connect.sid`**，複製 **Value**（通常以 `s%3A` 開頭）
5. 貼到 chat（可只貼 value，不必加 `connect.sid=` 前綴）

**Firefox**

1. 開 [wanderlog.com](https://wanderlog.com) 並登入
2. `F12` → **Storage** → **Cookies** → `https://wanderlog.com`
3. 複製 **`connect.sid`** 的 Value

**Safari**

1. 先啟用開發者選單：**Safari → 設定 → 進階 → 在選單列顯示「開發」選單**
2. 開 [wanderlog.com](https://wanderlog.com) 並登入
3. **開發 → 顯示 Web 檢查器** → **Storage → Cookies**
4. 複製 **`connect.sid`**

### 執行時用法

```bash
WANDERLOG_COOKIE='<connect.sid value>' node script.mjs
```

- 接受 `s%3A...` 或 `connect.sid=s%3A...` 兩種格式
- 若 API 回 **session invalid / expired**：請使用者重新登入 Wanderlog 後貼新 cookie，**不要**重試猜測

---

## 1. 執行前檢查清單

從使用者訊息整理並確認（缺就問）：

```
Progress:
- [ ] connect.sid 已取得
- [ ] 目標行程名稱或 trip key（例：前往Tokyo的旅行 / afnmohflkhpeqqpp）
- [ ] 目標 section／list 名稱（例：東京景点、富士山河口湖景點）
- [ ] 景點清單：Maps 搜尋名 | 中文名 | 交通 | 特色概要（bullet）
- [ ] note 格式確認（預設：粗體中文名 + 交通：… + • 特色）
- [ ] 已存在景點：跳過新增 or 只補 note？
- [ ] 執行 API 同步
- [ ] 驗證數量與 note，回報結果表
```

### 必要輸入

| 項目 | 說明 |
| --- | --- |
| 行程 | 名稱關鍵字即可；腳本用 `listTrips()` 找 |
| Section | `trip.itinerary.sections` 裡 `heading` 完全匹配（區分大小寫／簡繁） |
| 每個 place | **搜尋關鍵字** + **中文名** + **交通** + **特色概要**（2–4 個 bullet） |

若使用者只給 Maps 截圖／表格且缺特色概要：依景點常識簡短補 2–4 點（繁體、每點一行）；不確定時先問。

---

## 2. Note 格式（預設）

Place 的 inline note 用 **rich-text**，結構為三段落：

1. **粗體中文名**（獨立一行）
2. `交通：` + 交通資訊（獨立一行）
3. 景點特色概要（**point form**，每行以 `• ` 開頭）

### 顯示範例

```
河口湖遊覽船          ← 粗體
交通：搭紅線至遊覽船・纜車入口
• 湖上遠眺富士山
• 約 20 分環湖
• 可配纜車同遊
```

### rich-text ops

```javascript
function defaultNoteOps(zh, transport, highlights = []) {
  const ops = [
    { insert: zh, attributes: { bold: true } },
    { insert: '\n' },
  ];
  if (transport) ops.push({ insert: `交通：${transport}\n` });
  for (const point of highlights) {
    ops.push({ insert: `• ${point}\n` });
  }
  return ops;
}
```

- 中文名用 **繁體**（使用者指定則從）
- `highlights`：字串陣列，每項一個 bullet（**不要**在字串內再加 `•`）
- 無交通或無特色時可省略該段；但預設應盡量齊全
- 若使用者指定其他格式（例如不要 bullet）：依指定調整

---

## 3. 核心流程（加入景點 + note）

對每個待加 place 重複以下步驟。詳細腳本見 [reference.md](reference.md)。

### 3.1 準備

```bash
npm init -y && npm install wanderlog-mcp
```

在 workspace 建立**暫時** `.mjs` 腳本；任務結束後刪除腳本與 `node_modules`／`package.json`（**勿 commit**）。

### 3.2 定位行程與 section

1. `RestClient.getUser()` — 確認 session 有效
2. `RestClient.listTrips()` — 依名稱找 trip（例：`t.name.includes('Tokyo')`）
3. `RestClient.getTripWithResources(tripKey)` — 取得最新 itinerary
4. `sections.find(s => s.heading === '目標清單名')` — 記下 `sectionIndex`

若找不到 section：列出所有 `heading` 請使用者確認，**不要**新建 section（除非使用者明確要求）。

### 3.3 判斷是否已存在

用 place **note 內的中文名** 判斷（比英文 place 名可靠）：

```javascript
function noteContainsZh(block, zh) {
  return (block.text?.ops ?? []).some(
    (o) => typeof o.insert === 'string' && o.insert.includes(zh),
  );
}
```

- 已存在且 note 正確 → **跳過**
- 已存在但 note 缺／錯 → 走 **§4 更新 note**（不要重複 insert place）

### 3.4 解析 Google Place

```javascript
const predictions = await rest.searchPlacesAutocomplete({
  input: searchQuery,
  sessionToken: crypto.randomUUID(),
  location: { latitude, longitude }, // 目的地中心；河口湖可用 35.498, 138.768
  radius: 50000, // 離東京較遠時加大；市區可用 15000
});
```

**重要**：

- 略過 `place_id` 為 `undefined` 的 prediction，改試下一個
- `getPlaceDetails` 失敗時依序試前 5 個有效 prediction
- 仍失敗：改用**替代搜尋詞**或使用者提供的 **place_id**（見 reference 常見對照）
- **不要**用模糊英文子字串比對來判定「已存在」（易誤判）

### 3.5 寫入 ShareDB

**每個 place 用新的 `ShareDBClient`**，並在 submit 前 **重新 `getTripWithResources`** 刷新 block 索引。

```javascript
const blockPath = ['itinerary', 'sections', sectionIndex, 'blocks', insertIndex];
const block = buildPlaceBlock(placeDetail, userId);
await client.submit([
  { p: blockPath, li: block },
  {
    p: [...blockPath, 'text'],
    t: 'rich-text',
    o: defaultNoteOps(zh, transport, highlights),
  },
]);
```

- place 之間 `sleep(1200–1500)`，避免 rate limit
- submit 失敗：invalidate 後重抓 trip 再試一次

### 3.6 完成驗證

再次 `getTripWithResources`，確認：

- section 內 place **數量**符合預期
- 每個 note：第一行粗體中文名、`交通：` 行、至少一個 `•` bullet（若有提供特色）
- 回報表格給使用者

---

## 4. 只更新既有 place 的 note

不新增 block，只改 `text` rich-text：

1. 在 section.blocks 找到目標 place（依中文 note 或 `place.name`）
2. ShareDB submit：

```javascript
{
  p: [...blockPath, 'text'],
  t: 'rich-text',
  o: defaultNoteOps(zh, transport, highlights),
}
```

若需保留其他欄位，先讀現有 `block.text.ops` 再合併。**不要**覆寫與本次無關的 place note。

---

## 5. 常見錯誤

| 錯誤 | 原因 | 處理 |
| --- | --- | --- |
| `session invalid` / 401 | cookie 過期或登出 | 請使用者貼新 `connect.sid` |
| `Place not found` | autocomplete 第一筆無效 place_id，或 details API 失敗 | 換搜尋詞／指定 place_id／試下一筆 prediction |
| ShareDB conflict | 連續 submit 版本衝突 | 每 place 新 client + 刷新 trip；加 sleep |
| 搜尋偏離目的地 | trip center 在東京，河口湖太遠 | 搜尋時用該區座標 + `radius: 50000` |
| 誤判已存在 | 英文 fuzzy match 太寬 | 改以 note 中文名判斷 |

---

## 6. 與 Google Maps skill 的分工

| 任務 | 用哪個 skill |
| --- | --- |
| 存地點到 Google Maps、Maps list 加 note | `google-maps-bookmark` |
| 把地點加進 Wanderlog 行程／list、Wanderlog note | **本 skill** |
| Maps → Wanderlog 同步 | 來源在 Maps 時先確認 Maps 清單內容（貼表／截圖）；Wanderlog 端用本 skill |

---

## 7. 回報格式

```markdown
已更新 Wanderlog「{行程名}」→「{section名}」：共 N 個景點

| Place 名稱 | Note 摘要 | 狀態 |
| --- | --- | --- |
| Ensoleille Excursion Ship | **河口湖遊覽船**／交通：搭紅線…／3 點特色 | 新增 |
| 浅草寺 | **浅草寺** | 略過（已存在） |
```

失敗項寫明原因與已嘗試的搜尋詞。

---

## 8. 安全與清理

- ❌ 不 commit `connect.sid`、`package.json`（若僅為本次安裝 wanderlog-mcp）、暫時腳本
- ✅ 任務結束刪除暫時 `node_modules`／腳本（除非 repo 已正式納入 wanderlog 工具鏈）
- ✅ session 檔可記「完成了 Wanderlog 同步」，**不可**記 cookie

## 詳細腳本與 API

可複製腳本模板、河口湖搜尋對照、trip key 範例：見 [reference.md](reference.md)。
