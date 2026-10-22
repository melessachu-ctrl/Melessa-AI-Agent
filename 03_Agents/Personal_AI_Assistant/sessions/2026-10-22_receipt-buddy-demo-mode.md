# Session｜2026-10-22｜Receipt Buddy 訪客示範模式 + 登入 CTA 微調

## 做了甚麼

### Portfolio 示範模式（即棄 Demo Household）

- Lovable 專案 **Receipt Buddy**（收據記帳）  
  `project_id` = `65e78316-0f7d-4004-b3e6-28d9aeac9fa5`  
  Editor：https://lovable.dev/projects/65e78316-0f7d-4004-b3e6-28d9aeac9fa5  
  Live：https://receipt-buddy.lovable.app  
  **Portfolio 深連結**：https://receipt-buddy.lovable.app/demo
- 實作 disposable demo：`startDemoSession` → ephemeral user + `is_demo` household + 種子開支；**唔會** claim orphan expenses
- 防護：OCR 上限 3（atomic reserve/release）、24h 清理、同時最多 50 demo、server 拒 demo invite／移除成員
- UI：訪客 banner（登入／註冊連結）；分享／邀請／成員保留可見但 disabled + hints；Settings「結束試用」
- Login／Signup：「以訪客身份試用」移到 `glass-card` **外面**；白底紫字；上下 padding 12px（`py-3` + `h-auto`）
- Project knowledge 已寫入 Lovable（demo 規則 + URL）

### Melessa repo 收尾

- Session／TASKS／Latest_State／observation log／LOG
- `lovable-mcp-server-guide` 固化 Receipt Buddy project_id／demo URL
- `MEMORY` 記 Receipt Buddy 固定 ID 與 `/demo` 連結

## 未完成甚麼

- Live 站若未反映最新 CTA／padding，需在 Lovable **Publish**（本 session 未 deploy；寫入／deploy 仍要明確要求）
- Portfolio 站 `melessa-chu-design` 尚未寫入 Receipt Buddy 專案文案／卡片連結（可另開）

## 下次由哪裡開始

- Portfolio 放 demo：`https://receipt-buddy.lovable.app/demo`
- 改 Receipt Buddy → Lovable MCP `project_id` `65e78316-0f7d-4004-b3e6-28d9aeac9fa5`（見 `lovable-mcp-server-guide`）
- 說「publish Receipt Buddy」→ `deploy_project`

## 今日學到

- 多租戶產品做 portfolio 試用，應用 **即棄 demo household**，唔好共用 demo 帳
- Guest CTA 要同正式登入方法視覺分離（卡片外 + 實心底），先唔會同 login methods 糊埋
