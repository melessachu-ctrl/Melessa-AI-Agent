# Google Maps Bookmark — Reference

配套 [SKILL.md](SKILL.md)。僅在執行批次 Save／除錯時讀本檔。

## CDP：`saveToList(query, listName)`

在已開的 Maps tab 用 `browser_cdp` → `Runtime.evaluate`，設 `awaitPromise: true`、`returnByValue: true`。

先 `browser_navigate` 到 `https://www.google.com/maps/search/{query}`，再跑：

```javascript
(() => new Promise(async (resolve) => {
  const sleep = (ms) => new Promise(r => setTimeout(r, ms));
  const listName = "LIST_NAME"; // 換成目標 list，例如 東京
  const expect = /PLACE_REGEX/i; // 可選：用來驗證 h1，例如 /Tokyo Tower|東京タワー/

  const findSave = () => [...document.querySelectorAll('button')].find(b =>
    b.getAttribute('data-value') === 'Save' ||
    b.getAttribute('aria-label') === 'Save' ||
    /^\s*Save\s*$/.test(b.innerText)
  );

  for (let i = 0; i < 30; i++) {
    if (findSave()) break;
    if (location.href.includes('/maps/search/')) {
      const links = [...document.querySelectorAll('a')].filter(a => a.href.includes('/maps/place/'));
      const match = expect
        ? links.find(a => expect.test(a.innerText))
        : links[0];
      if (match) { match.click(); await sleep(1500); continue; }
    }
    await sleep(400);
  }

  const h1 = document.querySelector('h1')?.innerText || '';
  if (expect && !expect.test(h1)) {
    resolve({ ok: false, step: 'wrong-place', h1, title: document.title });
    return;
  }

  const saveBtn = findSave();
  if (!saveBtn) {
    resolve({ ok: false, step: 'save-timeout', h1, title: document.title });
    return;
  }

  // 已 Saved 時可能仍叫 Save 或已變成 Saved；若選單可開就開
  saveBtn.click();
  await sleep(1200);

  const item = [...document.querySelectorAll('[role="menuitemradio"]')]
    .find(el => (el.textContent || '').includes(listName));
  if (!item) {
    resolve({
      ok: false,
      step: 'list-not-found',
      h1,
      menus: [...document.querySelectorAll('[role="menuitemradio"]')]
        .slice(0, 8)
        .map(el => el.textContent.trim().slice(0, 40))
    });
    return;
  }

  item.click();
  await sleep(800);
  resolve({ ok: true, h1, list: listName, title: document.title });
})())
```

### 呼叫注意
- 每次換地點：先 navigate，再 evaluate（不要假設上一頁狀態還在）。
- `listName` 用精確子字串（「東京」可匹配「東京 Private · N places」類文字）。
- 回傳 `ok:false` 時依 `step` 處理，不要假裝成功。

## 常用 selector／訊號

| 用途 | 訊號 |
| --- | --- |
| Save | `button`：`aria-label=Save` / `data-value=Save` / 文字 `Save` |
| List 選項 | `[role="menuitemradio"]` 文字含 list 名 |
| 已存 | `Saved in {list}`、Save 變 Saved、list 地點數增加 |
| List 視圖 | 頁面 title `{list} - Google Maps`；多列 place + `Add note` / `Note` |
| Note 欄 | accessibility：`textbox` name=`Note`；或按鈕 `Add note` |
| 進入 list | Saved → 目標 list；或 place 上的 `Saved in {list}` |

## Note 路徑：為什麼 list 視圖才穩

| 路徑 | 結果 |
| --- | --- |
| Place 詳情 → Add note → JS 設 value / 偶發 fill | **常不持久**；離開後 note 消失 |
| List 視圖 → Add note → `browser_fill` → blur | **會持久** |

Blur 建議：點下一個 `Add note`。避免點 list 標題（會進入重新命名，heading 可能變成 `2/40` 字數）。

## 從 list 移除誤存地點

1. 開 list 視圖
2. 找到誤存列 → More / 選單 → Remove from list（或同等移除）
3. 確認地點數減少後再存正確地點

## 批次節奏建議
- Save：navigate → CDP save → 記結果 → 下一個（約 2–4 秒／點）
- Note：全部 Save 完後 **只開一次 list**，由上到下 fill
- 每 5 個可 snapshot 一次抽查，避免 silent fail
