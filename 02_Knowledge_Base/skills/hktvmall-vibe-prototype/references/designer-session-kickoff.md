# Session 開工指引（設計師／Business User）

## Plugin 裝咗之後會唔會自動幫我？

| 期望 | 現實 |
| --- | --- |
| 自動開 `spike/` branch | **唔會** — 要喺對話明確要求，或跟 in-repo-spike-sop 叫 Agent 跑 git |
| 自動走 uiux-design-studio | **唔保證** — app repo 要有 `CLAUDE.md` + 下方開工句 |
| 自動套 Apple／cro | **有條件** — 見 `uiux-design-studio` 分流 |

**工程師唔需要裝 plugin**；sign-off 後佢哋用自己工具接 MR 即可。

## App repo 必備（通常由平台 commit 一次）

1. **`.claude/settings.json`** ← 從 `hktvmall-design-system/templates/claude-settings.json` 複製（啟用 **hktvmall-uiux**）
2. **`CLAUDE.md`** ← Native app 用 `templates/CLAUDE.md`（填 native token 路徑 + WebView base URL）；**WebView／web repo** 用 `templates/CLAUDE.webview.md`（`ds/`＋PIN）

個人只需在本機首次：`/plugin marketplace add` + `install hktvmall-uiux@hktvmall-design`；之後 `marketplace update` 即可。

## 建議開工 prompt（複製貼上）

```text
HKTVmall 新功能／改 UI，in-repo spike。請：

1. Read uiux-design-studio，deliveryMode=code，studioDepth=light
2. Read hktvmall-vibe-prototype、hktvmall-design-system、hktvmall-target-customers、ricky-design-guideline
3. 若未在 spike 分支：git checkout -b spike/<ticket>-<short-name>
4. 只做 happy flow；遵守 Code Token Bind Gate
5. 若 Surface 含 WebViewH5：先 Gate D ensure 本 repo ds/（PIN 對齊 skill）
6. 完成後 uiux-review，產出 Requirement AC（requirement-ac-template）

Surface：[NativeChrome | WebViewH5 | Mixed]
（WebViewH5 = GCP 上 web／WebView repo；用本 repo ds/）
Ticket：<TICKET>
```

## 改現有畫面（唔係新 spike）

```text
HKTVmall 改現有 app UI。請 uiux-design-studio 編排（deliveryMode=code），
hktvmall-vibe-prototype 規則；只改本次觸及的檔案，唔 refactor 舊 UI。
```

## Marketing 相關

- **HKTVmall 轉換頁**（PDP、購物車…）：studio 會加 cro／offers 等。
- **Marketing Buddy 後台**：用 Marketing Buddy DS，**唔**當轉換型讀全套 cro。
- 一般新功能：**唔**自動讀 cro，除非你寫明促銷／轉換目標。
