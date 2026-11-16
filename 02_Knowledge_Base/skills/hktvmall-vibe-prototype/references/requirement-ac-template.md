# Requirement AC 模板（Spike sign-off · Happy flow）

**用途**：PO／PM 簽 requirement 時用。**唔**包含完整 error／special case（留 **Engineering AC**）。

來源：由 [`../../uiux-review/SKILL.md`](../../uiux-review/SKILL.md) Step 7 從 Must／Should 反推可勾選項。

---

```markdown
## Requirement Sign-off — [功能名 / TICKET]

### 狀態
- Branch（sign-off 時）：spike/<TICKET>-<name> 或已改名
- Build／預覽：[指令 + URL / 建置號]
- Surface：[NativeChrome | WebViewH5（= GCP web／WebView repo）| Mixed]
- DS pin：hktvmall-design tokens @ [meta.synced]（WebView：本 repo `ds/PIN.json`；native app 只開 Remote URL 時註明 web base URL）

### Happy flow（已驗證）
1. …
2. …
3. …
→ 代表使用者（Reviewer Lens）可在 ≤N 步完成，無需猜測

### 非目標（本輪不要求）
- [ ] 完整 error handling（網絡、timeout、session）
- [ ] 完整 empty／edge cases
- [ ] Production API／正式 analytics
- [ ] App Store 上架條件

### Acceptance Criteria（Requirement）

從 uiux-review Must 反推：

- [ ] …（對應 M1）
- [ ] …（對應 M2）
- [ ] 主 CTA／價錢格式符合 HKTVmall（一位小數等）
- [ ] Code Token Bind Gate：Pass（或 Pass with exceptions + 原因）

### 已符合、本輪唔改
- …

### 簽核
- PM／PO：________  日期：________
- 設計：________
- 工程（知悉）：________

### Sign-off 後下一步
- [ ] 分支去掉 spike 前綴（或從 tag 開新分支）
- [ ] 補 Engineering AC 與 error cases 後 MR
```

---

填寫提示：

- 每條 AC 要對應具體 Must 或 Ricky 原則，避免「整體 OK」。
- 轉換型畫面 AC 須含：5 秒內價值、主轉換動作是否清晰（見 `uiux-review` Conversion Pass）。
