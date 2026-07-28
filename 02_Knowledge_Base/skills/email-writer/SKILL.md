---
name: email-writer
description: 當使用者說「幫我寫封電郵」「寫封 email」「幫我寫 email」「請幫我寫電郵」「email草稿」或提出寫給上司／同事的電郵需求時，本 Skill 會把中文意思整理成一封可直接 copy and paste 的英文電郵，語氣有禮貌但不過度正式，預設輸出 Subject + Greeting + Body + Closing；若資料不足，不追問，直接以 placeholder 補位。
---

# Email Writer（電郵助手）

## 載入時機（必遵守）
命中下列**任一**情況時，必須載入並依本 skill 執行（不可略過、不可改用其他格式）：
- 使用者直接說：幫我寫封電郵／寫封 email／幫我寫 email／請幫我寫電郵／email 草稿
- 使用者先叫 **Sasa／Personal AI Assistant**，再要求起草給上司／同事的電郵
- 使用者雖然無明講「電郵」，但語意明確是在起草工作電郵，例如：請假申請、病假、覆診、改期、跟進事項、回覆同事、請求批准、通知未能出席

## 目標
把使用者想表達的中文內容，整理成一封**禮貌、自然、可直接寄出**的英文電郵。

預設風格：
- 禮貌，但不用太 over-formal
- 清楚交代目的
- 句子簡潔，避免官腔
- 適合寫給上司或同事

## 資訊不足處理（placeholder 模式）
如資料不足，**不要追問**，直接用 placeholder 補位，讓使用者可之後自行修改。

常見 placeholder 寫法：
- 收件人：`[Manager Name]`、`[Colleague Name]`
- 日期：`[Thursday, Date]`、`[Date]`
- 時間：`[Time]`
- 部門／會議／專案：`[Project Name]`、`[Meeting Name]`
- 署名：`[Your Name]`

原則：
- 缺少稱呼時，按語境預設用 `Dear [Manager Name],` 或 `Dear [Colleague Name],`
- 缺少日期或具體安排時，保留在正文內的對應 placeholder
- 缺少署名時，closing 後用 `[Your Name]`
- 不要因為資料不完整而拒絕產出草稿

## 寫作規則
1. 先抽取核心意圖：請假 / 通知 / 跟進 / 請求批准 / 回覆
2. 把口語中文改寫成自然商務英文，不逐字直譯
3. 先講重點，再補充必要原因或安排
4. 若對上司：
   - 語氣稍正式
   - 可加入 `I would like to...`、`I would be grateful...`
5. 若對同事：
   - 語氣可自然一點
   - 可用 `Just to let you know...`、`Could you please...`
6. 如涉及病假、覆診、遲到、缺席：
   - 原因簡潔即可，不要加太多醫療細節
7. 除非使用者要求長版，正文以 **2–3 段內** 為主

## 輸出格式（每次都照呢個順序）
1. **Subject**
2. **英文電郵正文**

格式如下：

```text
Subject: ...

Dear ...,

...

Best regards,
[Your Name]
```

規則：
- 不要加多餘解說
- 不要輸出「以下是電郵草稿」之類前言
- 直接給可 copy and paste 版本

## 語氣微調規則
- 使用者若要求「有禮貌」：維持預設
- 使用者若要求「再 casual 少少」：保留禮貌，但可縮短句子
- 使用者若要求「再正式啲」：提升語氣，但仍避免過度繁複
- 若無特別要求：預設為「有禮貌，但不太 format」

## 範例（請病假覆診）

### 輸入
我想星期四請一日病假去覆診。

### 輸出
```text
Subject: Sick Leave Request for [Thursday, Date]

Dear [Manager Name],

I would like to request one day of sick leave on [Thursday, Date] as I need to attend a follow-up medical appointment.

Please let me know if you need any further information. Thank you for your understanding.

Best regards,
[Your Name]
```

## 額外例子（通知同事）

### 輸入
幫我寫封 email 比同事，話我今日會遲少少返到公司，大概十點半到。

### 輸出
```text
Subject: Late Arrival This Morning

Dear [Colleague Name],

Just to let you know that I will be arriving at the office a bit later today, at around 10:30 AM.

Sorry for the inconvenience, and thank you for your understanding.

Best regards,
[Your Name]
```
