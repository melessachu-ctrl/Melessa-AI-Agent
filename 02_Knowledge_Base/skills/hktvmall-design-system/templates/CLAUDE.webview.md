# CLAUDE.md 範本：HKTVmall WebView／web frontend repo（GCP）

<!--
用於設計師或 Business User 在 GCP 上嘅 web／WebView 內容 repo vibe code。
工程師正式開發唔需要裝 hktvmall-design plugin。
平台建議將本內容 commit 入本 repo 一次。
填好 base URL 後可刪除此註解。

Web DS 真源：hktvmall-design-system skill。
Runtime：本 repo 根目錄 ds/（Gate D ensure／sync；ds/PIN.json）。
-->

## HKTVmall UI 編排（Web vibe code）

凡 **touch 使用者可見 UI**，在寫碼前：

1. Read **`hktvmall-uiux`** plugin 的 **`uiux-design-studio`**（`deliveryMode=code`）
2. Read **`hktvmall-vibe-prototype`**、**`hktvmall-design-system`**、`hktvmall-target-customers`、`ricky-design-guideline`
3. **Gate D**：ensure 本 repo `ds/`（見下）後先寫 UI
4. **唔**用 `frontend-design` 作 HKTVmall 主視覺

Spike sign-off 用 **Requirement AC**；見 vibe-prototype `references/requirement-ac-template.md`。

## Design System（本 repo `ds/`）

| 欄位 | 值 |
| --- | --- |
| Surface | **WebViewH5** |
| DS 目錄 | `ds/` |
| PIN | `ds/PIN.json`（對齊 skill `tokens.json` → `meta.synced`） |
| WebView base URL | `[例如 https://webview.example.com/]` |

### Gate D（開工必跑）

1. 無 `ds/` → 由 skill sync `tokens/web`＋`components/web`，寫 PIN：  
   `python3 ${CLAUDE_SKILL_DIR}/scripts/sync_web_ds.py --target .`  
   （或 `${CLAUDE_PLUGIN_ROOT}/skills/hktvmall-design-system/scripts/sync_web_ds.py`；無 Python 則 agent 直接從 skill 複製）
2. 有 `ds/` → 比 PIN／hash；舊或不匹配 → **re-sync，一律以 skill 覆蓋**
3. Icons：按本頁需要 `--icons name1,name2` 複製入 `ds/icons/`（唔一次過成庫）
4. 頁面 **必須**用 `ds/`：`--hktv-*`、`<hktv-button>`、`<hktv-price>`；無 component → hard code＋**DS gap**

詳見 skill `components/web/README.md`、`references/ds-artifact-map.md`。

### 頁面引用示例

```html
<link href="/ds/hktv-tokens.css" rel="stylesheet">
<link href="/ds/hktv-button.css" rel="stylesheet">
<script src="/ds/hktv-button.js" defer></script>
```

### 規則

1. **只用 `ds/` tokens／components。** 禁止裸 hex、自創 spacing／radius。
2. **唔好手改 `ds/hktv-tokens.css` 數值**；改 skill `tokens.json` 再 build＋re-sync。
3. **人手改過 `ds/` 內 skill 副本 → 下次 Gate D 仍以 skill 覆蓋。**
4. **價錢一位小數**（`$289.0`）；售價 `text-sale-price`。
5. **不改舊頁樣式**，除非任務明確要求。
