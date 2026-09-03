# Session｜2026-09-03｜3rd Party Login Permissions List 更新

## 做了甚麼

### Figma｜HKTVmall — 3rd Party Login（`3gnFYaXhhARa39OqRf0MdX`）

將 Permissions List 由舊 4 項（帳戶摘要＋付款摘要）改為 **7 項獨立權限**：

1. HKTVmall 賬戶資料 (登陸及存取HKTVmall 帳戶資料)
2. 帳戶編號
3. 電郵地址
4. 會員級別記錄
5. 手機號碼
6. 送貨地址
7. 儲存在該HKTVmall 賬戶內的付款資料

**更新位置：**

| 節點 | 說明 |
| --- | --- |
| `3907:1420`／主元件 `3907:1343`（ZH Consent） | 主元件 slot + 實例覆寫修正（第二項曾殘留舊文案） |
| `3911:222`（PermissionsList） | 保留「您已授權：」；其下 7 項同步 |

### Skills／約束（本回合有遵循）

- `figma-use`（文字編輯：load font → mutate；主元件＋實例）
- HKTVmall Figma DS 工作區規則（library-first；本回合僅改文案／列數，未新建基礎元件）

## 未完成甚麼

- （無）本任務已完成

## 下次由哪裡開始

- UIUX Design Agent PoC（Step 0–3）— 見 `TASKS.md`／`Now.md`
- （可選）檢查同檔其他語言／變體 Consent 畫面是否也要同步這 7 項

## 今日學到

- SLOT／實例可殘留 **text override**：主元件改完後仍須核對實例文案（本回合第二項曾未同步）
- 單行 permission row 可 clone 擴列；長標題列（帳戶資料）維持 wrap 高度 40

## 連結

- [3rd Party Consent](https://www.figma.com/design/3gnFYaXhhARa39OqRf0MdX/HKTVmall---3rd-Party-Login?node-id=3907-1420)
- [PermissionsList（您已授權）](https://www.figma.com/design/3gnFYaXhhARa39OqRf0MdX/HKTVmall---3rd-Party-Login?node-id=3911-222)
