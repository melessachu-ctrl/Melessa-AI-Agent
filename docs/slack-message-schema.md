# Slack inter-agent message schema（草稿）

> **Status:** draft — 待 Hermes PM team 確認（Step 0）  
> Channel 建議：`#agent-uiux-design`  
> 完整背景：`01_Action_Center/outputs/docs/UIUX_Design_Agent_Implementation_8_Steps.md`

## PM Hermes → UIUX Design Agent

```
@uiux-design-agent lookup
query: "<自然語言問題>"
context:
  jira: "<HKTV-xxxx 或空>"
  platform: app | web | lite-app
  requester: "<slack user id 可選>"
```

## UIUX Design Agent → Slack（回覆 thread）

```
status: found | partial | not_found | escalate
confidence: high | medium | low
answer: |
  <2–3 句設計摘要>
figma_url: <https://www.figma.com/design/...>
design_status: approved | wip | deprecated
evidence:
  - design-index entry id
  - optional screenshot upload id
escalate_to: <@designer slack id，confidence=low 或 not_found 時>
```

## Escalation 觸發（建議）

| 條件 | 動作 |
|------|------|
| `confidence: low` | `escalate_to` + 仍提供 best-effort link |
| `status: not_found` | 請 PM 補 Jira／關鍵字 |
| `design_status: wip` | 答案須標明非 final |
| index 無 entry 但 query 含 Jira | 搜尋 Jira 欄位後 partial |

## 待 PM team 確認

- [ ] Channel 名稱與 @mention handle
- [ ] Hermes 如何把回覆整合回 WhatsApp（截圖 vs link only）
- [ ] macOS 第二 Hermes instance／MCP 支援方式
