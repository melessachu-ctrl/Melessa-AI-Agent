# Web starters（WebView／web repo · `ds/`）

HKTVmall WebView 內容通常喺 **GCP 上嘅 web／WebView repo**（app 開 Remote URL）。Web DS **真源**在本 skill；**runtime** 係該 repo 根目錄的 **`ds/`**（由 agent Gate D／本 skill `scripts/sync_web_ds.py` sync）。

## 部署／sync（Gate D）

1. 偵測 Web vibe code（Surface `WebViewH5`）。
2. 查 consumer repo 有冇 `ds/`。
3. **無** → 由 skill 複製入 `ds/`，寫 `ds/PIN.json`：
   - `tokens/web/hktv-tokens.css` → `ds/hktv-tokens.css`
   - `components/web/hktv-button.css` + `hktv-button.js` → `ds/`
   - `components/web/hktv-price.css` + `hktv-price.js` → `ds/`
   - `components/web/hktv-cart-button.css` + `hktv-cart-button.js` → `ds/`
   - `components/web/hktv-text-field.css` + `hktv-text-field.js`、`hktv-dropdown.*`、`hktv-phone-field.*` → `ds/`
4. **有** → 比 `ds/PIN.json` 的 `meta.synced`／file hashes 同 skill `tokens.json` 的 `meta.synced` 與來源檔；**舊或不匹配 → re-sync（一律以 skill 覆蓋）**，再更新 PIN。
5. **Icons**：唔一次過 sync 成個 `icons/web`；只按本頁需要複製到 `ds/icons/`。
6. 寫 UI：**必須**用 `ds/`（`--hktv-*`、`<hktv-button>`／`<hktv-price>`／`<hktv-cart-button>`）；無適合 component → hard code＋標 **DS gap**。

Helper（裝咗 plugin 後 agent 可跑；script 喺 **本 skill** 內，唔喺 marketplace 根）：

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/sync_web_ds.py --target /path/to/webview-repo
python3 ${CLAUDE_SKILL_DIR}/scripts/sync_web_ds.py --target /path/to/webview-repo --icons icon-cart-regular-outlined,icon-search-regular-outlined
```

若環境未展開 `${CLAUDE_SKILL_DIR}`，用 plugin 路徑：  
`python3 ${CLAUDE_PLUGIN_ROOT}/skills/hktvmall-design-system/scripts/sync_web_ds.py --target …`  
無 Python／唔跑 script 時：agent **直接從本 skill** 複製 `tokens/web`、`components/web` 入 `ds/` 並寫 `PIN.json`（Gate D 仍有效）。

`PIN.json` 對齊 skill `tokens.json` 的 `meta.synced`，並記錄 tokens／components 檔 hash。

**唔好**手改 generated `hktv-tokens.css` 數值；要改回 skill `tokens.json` 再 `build_tokens.py`，然後 re-sync。人手改過 `ds/` 內副本 → 下次 sync **仍以 skill 覆蓋**。

## 頁面引用

```html
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
<link href="/ds/hktv-tokens.css" rel="stylesheet">
<link href="/ds/hktv-button.css" rel="stylesheet">
<link href="/ds/hktv-price.css" rel="stylesheet">
<script src="/ds/hktv-button.js" defer></script>
<script src="/ds/hktv-price.js" defer></script>
<link href="/ds/hktv-cart-button.css" rel="stylesheet">
<script src="/ds/hktv-cart-button.js" defer></script>
<link href="/ds/hktv-text-field.css" rel="stylesheet">
<script src="/ds/hktv-text-field.js" defer></script>
<link href="/ds/hktv-dropdown.css" rel="stylesheet">
<script src="/ds/hktv-dropdown.js" defer></script>
<link href="/ds/hktv-phone-field.css" rel="stylesheet">
<script src="/ds/hktv-phone-field.js" defer></script>

<hktv-button appearance="filled" size="l">加入購物車</hktv-button>
<hktv-price kind="sp" size="l" amount="289" original="399"></hktv-price>
```

Icon（按需已 sync 到 `ds/icons/`）建議 inline SVG 或由頁面載入，以便 `currentColor` 跟 token 色。

## 規則摘要

| 情況 | 行為 |
| --- | --- |
| 無 `ds/` | 建立並 sync tokens + components；寫 PIN |
| 有 `ds/` 但 PIN／hash 舊 | re-sync 覆蓋；更新 PIN |
| 有 `ds/` 且 PIN 對齊 | 唔改 tokens／components；icons 仍可按需補 |
| 人手改過 `ds/` | 下次 Gate D **以 skill 為準覆蓋** |
| 無適合 component | hard code + **DS gap** |

詳見 `references/ds-artifact-map.md`、`hktvmall-vibe-prototype` Gate D。
