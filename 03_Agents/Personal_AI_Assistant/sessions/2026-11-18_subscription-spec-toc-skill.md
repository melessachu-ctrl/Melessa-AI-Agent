# Session｜2026-11-18～19｜Subscription 子 spec + Confluence TOC skill

## 做了甚麼

### Subscription（套票）SPECDOCS

1. 讀 Sarah 對 MMS／CSIS 的 requirements，分別寫入子 spec version **0.2**
   - [Subscription - MMS](https://hongkongtv.atlassian.net/wiki/spaces/SPECDOCS/pages/6213533697/Subscription+-+MMS)：per-SKU program；qty／freq／rounds 組合填確實金額（唔再填 %）；status＋reserved bookings；PSP 低於最高套票價 warning；Admin／Merchant list filters
   - [Subscription - CSIS](https://hongkongtv.atlassian.net/wiki/spaces/SPECDOCS/pages/6213402626/Subscription+-+CSIS)：渠道確認 CSIS；customer profile subscriptions；CS 永久取消；order page subscription SKU type、$0.0 charged；C7 關閉
2. Parent 與兩頁子 spec 都加咗 Confluence **Table of Contents**（`maxLevel: 2`，header 後／Changes Log 前）
3. 釐清頁底 **Related content** 係 Confluence 自動推薦，唔係放子 spec link 嘅地方；子／sibling links 仍放 Related Documents

### Skill：每次 publish 必加目錄

1. `standardized-technical-prd` → **v3.1.0**：`references/confluence-publishing.md` §3.1；Step 7＋publishing checklist；`runtime-tools.md` 補 `insertNodeBefore`
2. `test-case-preparation`：同步 TOC 規則（test-plan master 必加）
3. Sync 到 [hktvmall-design](https://github.com/melessachu-ctrl/hktvmall-design) plugin **0.7.11**（commit `4aa5651`）

本地稿：`subscription-ticket/`（含 MMS／CSIS md）仍 **未追蹤**，同之前一樣唔入 Melessa commit。

## 分發

- Melessa：本 finish session push（真源 skill TOC）
- hktvmall-design：`4aa5651`（0.7.11）已在 `main`
- UIUX-Skills：靠 Melessa push → Actions **Sync UIUX-Skills**；成功後發 `#uiux-designer` 公告

## 未完成甚麼

- Open question **C10**：MMS 組合價係 per-unit 定 qty 總額（draft：per-unit × qty）
- Parent App 收費／% 顯示尚未因 exact amount 全面對齊
- `subscription-ticket/` 本地稿未 commit
- `pr-requirement-prep`／`prd-backend-impact-consult` 仍不在 Melessa／plugin（舊問題）

## 下次由哪裏開始

- Sarah／Cecilia 答 C10 後對齊 parent charge math
- 若要版控 subscription 本地稿，另開 session 決定是否 commit `subscription-ticket/`
- 已裝 plugin 的人：`/plugin marketplace update hktvmall-design` → **0.7.11**

## 今日學到

- Confluence granular `insertNodeBefore` 應用 **full UUID** `data-local-id`，只傳末 12 hex 會 `granular_edit_unresolved`
- Related content ≠ Related Documents；唔好當 child-spec 目錄用
