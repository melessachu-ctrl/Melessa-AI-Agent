# Session｜2026-11-03｜轉換檢查接進設計工作室

## 做了甚麼

### 三個 repo 的結論

- [Duct](https://github.com/5hirish/duct)：獨立桌面 app，讀廣告與分析帳戶。不裝進這個 agent。
- [ai-agents-for-marketing](https://github.com/suhasbhairav/ai-agents-for-marketing)：HubSpot 示範站，畫面用寫死資料。跳過。
- [marketingskills](https://github.com/coreyhaines31/marketingskills)：Cursor skills。採用。

### 安裝（Melessa）

- 12 個 skill 放進 `02_Knowledge_Base/skills/`，上游 `88c79f65`（2026-10-30），各夾帶 `.upstream-sync.json`
- 本機 symlink：`bash 02_Knowledge_Base/skills/setup-symlinks.sh`
- 全域可用：`product-marketing`、`cro`、`copywriting`、`copy-editing`、`offers`、`emails`、`sms`、`ads`、`ad-creative`、`seo-audit`、`social`、`influencer-marketing`
- 觸發靠每個 skill 的 description。新對話才載入

### 設計工作室只讀 4 個

轉換型畫面（PDP、搜尋結果、購物車、結帳、促銷、落地頁）才讀：

- `cro`：七個檢查（5 秒價值、標題、主轉換、信任證據、反對點、摩擦力、優惠是否一眼可懂）
- `offers`：有優惠時才讀
- `copywriting`：標題與主按鈕各 2–3 個寫法
- `copy-editing`：評審時只改已有句子

`uiux-review` 在 Heuristic 之後加 Step 3b Conversion Pass。主轉換被擋、價格或優惠會看錯、聲稱沒根據、按鈕講不清按下後發生什麼，列 Must fix。

HKTVmall 高密度促銷、Ricky、價錢一位小數優先。不套 SaaS 的拆導覽、大留白、試用按鈕。整理 Figma、補 Design System、後台表單不讀這 4 個。

`emails`、`sms`、`ads`、`ad-creative`、`seo-audit`、`social`、`influencer-marketing` 留在網店對話。`product-marketing` 只寫一次品牌底稿。使用者註明「這頁是給某條廣告」時，才對一下標題是否和廣告同一句話。

### 設計師分發

- `cro`、`offers`、`copywriting`、`copy-editing` 加入 `sync/uiux-skills-manifest.json`
- `sync/README.md`、`02_Knowledge_Base/skills/README.md` 改為 16 個 skills + 4 個 cursor rules

## 未完成甚麼

- 奶粉品牌的 `.agents/product-marketing.md` 尚未寫。要在新對話說「幫我寫 product marketing context」
- 設計師要在 UIUX-Skills 跑 `./scripts/update-skills.sh` 才會連上這 4 個

## 下次由哪裡開始

- 確認 Actions「Sync UIUX-Skills」成功，以及 `#uiux-designer` 公告已發
- 新對話先為奶粉品牌寫 product marketing context

## 今日學到

- marketingskills 的 `.agents/skills` 安裝位置，這個 agent 讀不到。真源要放 `02_Knowledge_Base/skills/` 再 symlink
- 工作室用 `../cro/SKILL.md`。下游沒有檔時略過，所以要進 manifest，設計師才真的做得到轉換檢查
