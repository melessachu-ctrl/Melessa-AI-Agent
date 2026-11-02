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

## 給 Cursor／其他 agent

同一規則的共享真源是 `sync/cursor-rules/hktvmall-ui-price.mdc`。本 repo 的 `.cursor/rules/hktvmall-ui-price.mdc` 指向這份檔，clone 後在 Melessa 工作區自動生效。

下游 [UIUX-Skills](https://github.com/melessachu-ctrl/UIUX-Skills) 同步後會有：

- `rules/hktvmall-ui-price.mdc`（Cursor 安裝用）
- `rules/hktvmall-ui-price.md`（Claude／其他只接受 `.md` 的環境）
