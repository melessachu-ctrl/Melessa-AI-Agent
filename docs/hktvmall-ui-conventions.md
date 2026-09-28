# HKTVmall UI Design Conventions

給所有參與 HKTVmall UI 的人（含唔用 Cursor 的 designer）：clone / download 本 repo 後，請跟以下慣例。

## Price format（價錢顯示）

**凡有 price 的地方，一律顯示小數點後一位（即使是整數）。**

| ✅ 正確 | ❌ 錯誤 |
|---|---|
| `$289.0` | `$289` |
| `$68.0` | `$68` |
| `$35.8` | `$35.80`（除非明確要求兩位） |
| `$1,530.0` | `$1,530` |

### 適用範圍

- 售價（selling price）
- 刪價錢／原價（was / original price）
- 85 折 bubble／PSP badge
- Promo price、unit price
- 其他所有金額文案

### 例外

只有當次需求**明確指定**其他小數位（例如兩位、或不顯示小數）時，才可偏離此規則。

---

## 給 Cursor 使用者

同一規則亦寫在：

- `.cursor/rules/hktvmall-ui-price.mdc`（本 repo，clone 後自動生效）
- Cursor **User Rules**（個人帳號，所有專案生效）
