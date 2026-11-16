# Icon

Figma 的 icon 係兩組 symbol，唔係一個可以切換 outlined／filled 的 component。Plugin 收成一套 icon library，再生成 iOS、Android、Web 三份。

**寫 iOS／Android UI：** 必 reference `icons/icons.json`＋`icons/{ios|android}/`。**優先用 skill icons**；無適合先問，確認後先可以新 icon，**outline style 優先**。**禁止**把整套 skill icons scaffold 入 app repo。**Web／GCP：** 按頁把需要的 SVG sync 入 web repo `ds/icons/`（唔一次過成庫）。Mall 路徑見 `references/native-repo-map.md`。

| 欄位 | 值 |
| --- | --- |
| Outlined | [icon frame](https://www.figma.com/design/F0tjdruLjJTfWgmTeZKBnw/Design-System?node-id=3023-185)，節點 `3023:185` |
| Filled | [Icon/Fill](https://www.figma.com/design/F0tjdruLjJTfWgmTeZKBnw/Design-System?node-id=3023-186)，節點 `3023:186` |
| 命名 | `icon-{物件}-{regular\|small}-{outlined\|filled}` |
| 畫板 | 多數 `24×24`。`icon-hktvmall-regular-filled` 係 `38×28`。`small` 仍放喺 `24×24` 畫板，係另一張圖 |
| 數量 | 199（2026-11-07） |
| 清單 | `icons/icons.json` |

灰色底同紫色虛線唔喺 symbol 入面，係匯出說明 frame 的殘件。`scripts/build_icons.py` 清走佢哋，並保留畫板留白。唔好把 path 裁到緊貼邊界，亦唔好為遷就 library 而改 Figma 畫板尺寸。

## Vibe code 點揀

1. 先在 `icons/icons.json` 按名稱揀，再對照平台參考檔。唔好用 SF Symbol、Material Icon 或臨時 SVG 頂替而未問。
2. 同一物件 outlined 同 filled 都有時，優先 **outlined**。Filled 只用於該畫面狀態本身係實心，例如已讚、已收藏，而且 library 有對應的 filled。
3. Library 沒有合適的 icon，先列出缺的物件名再問。用戶確認之後先可以用新 icon，**新 icon 一律 outline style 優先**，並在回覆標明呢隻唔喺 DS icon library。
4. Runtime：優先用 app 已有同名／對等資源（`icon_*`／`ic_*`）。**唔**整包／additive 從 plugin 複製入 app。

## 改色

`icons.json` 的 `tintable: true` 係單色圖。來源 fill／stroke 已收成黑色，用時先改色。

| 平台 | 改色 |
| --- | --- |
| iOS | imageset 係 `template`。`Image("icon-cart-regular-outlined").renderingMode(.template)`，再跟字色 |
| Android | `ColorFilter.tint`。DS 標準檔名用底線，例如 `icon_cart_regular_outlined`；mall app 現存可能係 `ic_cart_regular_outlined`——用時跟 repo 實際資源名 |
| Web | `fill="currentColor"`。要 inline SVG 先改到色；`<img>` 載入 SVG 改不到 |

`tintable: false` 而家只有：

- `icon-verify-regular-filled`（黑同白）
- `icon-verifycolor-regular-filled`（金色漸變同白勾）

呢兩隻保持原色。iOS imageset 係 `original`。

## 路徑

| 平台 | Skill 參考（必 Read） | Runtime |
| --- | --- | --- |
| iOS | `icons/ios/Icons.xcassets` | mall：`HKTVMall/DesignSystemComponent/Icons.xcassets`。唔另開第二個 catalog；唔整包複製 |
| Android | `icons/android/*.xml` | 各 module `res/drawable/`（`icon_*`／`ic_*`） |
| Web／GCP | `icons/web/*.svg` | web repo `ds/icons/`（按需 sync） |

重新生成 plugin 參考檔：`python3 scripts/build_icons.py`。`--check` 對齊已提交的成品。唔好手改 `icons/web`、`icons/ios`、`icons/android`。
