# PoC smoke — 2026-10-13（Cursor Cloud Agent）

## 環境

- Figma MCP：`whoami` OK（HKTVmall team admin）
- Index：`search-result-category-tree` entry

## 試跑

| Query | Index | Figma MCP | 結果 |
|-------|-------|-----------|------|
| category tree / 零食甜品 | `search-result-category-tree` | `get_metadata` `23987:694` | high — frame「SubCate - 圖上字下（1）」含 Brand Logo Section |

## 命令

```bash
python3 design-index/scripts/search_design_index.py search result
```

## Next

- 對 PoC 5 題逐題跑 lookup + screenshot（可選）
- 補 `checkout-v3`／`cart-v2` 真實 file_key
