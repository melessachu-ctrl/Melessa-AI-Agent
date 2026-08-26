# Session｜2026-08-26｜Lite App PDP IMG 對齊＋OOS Demo 頁

## 做了甚麼

### Figma｜HKTVmall — Lite App（`rCF6Dj4hH8rb2lPd85i3C3`）

1. **PDP IMG exact-swap（uiux-design-studio）**
   - 主元件 `PDP - 黑價＝SP`（`17081:17046`）內本地 `img` frame → Lite App DS **`PDP IMG`**（`State=Default`）
   - 保留原商品圖 fill；layout `FILL` × `HUG`；尺寸 393×272 不變
   - 畫布備份：`Backup - img (pre PDP IMG)`（`19012:3242`）— 確認後可刪

2. **新建 OOS Demo 頁**
   - 新 Page：`PDP v3.0 (OOS)`（緊接 `PDP v3.0`）
   - Demo frame：`PDP - OOS`（沿用長者會 PDP 內容）
   - `PDP IMG` → `State=OOS`（「暫時缺貨」遮罩）
   - Sticky `Button / Add to cart` → `Page=PDP, State=OOS`

### Skills／約束（本回合有遵循）

- `uiux-design-studio`、`hktvmall-target-customers`、`ricky-design-guideline`
- `figma-use`、`fix-design-system-finding`／`apply-design-system`（library-first）
- Lite App Design Tokens 規則（本回合無字體節點變更）

## 未完成甚麼

- [ ] （可選）刪除畫布備份 `Backup - img (pre PDP IMG)`
- [ ] （可選）其他 PDP 變體／頁是否也要換成 `PDP IMG` 或補 OOS demo

## 下次由哪裡開始

- Figma：確認 OOS 頁視覺 → 刪備份
- 進行中（無關本 session）：Maps「東京美食」剩餘 ~10 間（Local Agent + `google-maps-bookmark`）

## 今日學到

- Instance 內本地 frame **不能直接結構替換** → 改 **main component** 才會同步所有 instance
- Lite App DS：`PDP IMG`（Default｜OOS）；`Button / Add to cart`（`Page=PDP, State=OOS` 寬 96，MAX 約束會右對齊）
- `search_design_system` 優先於從零畫 carousel／CTA

## 連結

- [PDP（已含 PDP IMG）](https://www.figma.com/design/rCF6Dj4hH8rb2lPd85i3C3/HKTVmall---Lite-App?node-id=17081-17574)
- [OOS Demo](https://www.figma.com/design/rCF6Dj4hH8rb2lPd85i3C3/HKTVmall---Lite-App?node-id=19013-3220)
