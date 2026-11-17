# Journey table, master page and HTML templates

## 1. Journey (Markdown, for in-chat review)

```markdown
### Journey TC-xx — <rule under test → expected outcome>

| **Field** | **Value** |
| --- | --- |
| a.) ID of the journey | TC-xx |
| b.) Brief description of the journey | <one line> |
| c.) ID of journey it depends on | — / TC-yy (consumes: <state>) |
| d.) Preconditions / Data Setup | **Prior state:** … <br>**Data:** D-01 <alias> (`<code>`), D-04 <alias> (`<code>`) … <br>**Settings:** CFG-01 <name> = <value> … <br>**Setup steps (not inherited):** 1. <System> → <path> → <action> → verify <check> |
| e.) Tester steps | 1. **System/API:** … **\| Screen:** … **\| Action:** … <br>2. … → *Expect:* … <br>… |
| f.) Expected Observations / Pass Criteria | • (step n) … <br>• (step n) … NOT shown <br>• (step n) <System>: `<field>` = <value> |
| g.) Journey IDs that follow the current journey | TC-zz / — |
| h.) Requirement coverage | US-xx · AC-xx.y · FR-xx (RULE-xx.y, V-xx.y) · Kafka events checked |
| i.) Platforms & evidence | iOS ✓ Android ✓ Web ✓/— (App-only) · Screenshots: steps n, m · Record: <query output> |
| j.) State left behind / Cleanup | Leaves: <state for followers> · Revert: <config/stock/wallet> |
```

## 2. Step line grammar

```
N. **System/API:** <Customer App (iOS/Android) | Web | Hybris Backoffice | OIX | Courier App | CSIS | Payment Server | <API name>>
   **| Screen:** <exact screen name from the PRD screen inventory, or — for backend>
   **| Action:** <verb> <"exact UI label"> <exact value/selection>   [→ *Expect:* <checkpoint>]
```

Verbs: Launch, Log in as, Search for, Tap, Set, Select, Enter, Toggle ON/OFF, Swipe, Pull to refresh, Confirm,
Query, Wait for, Record.

Backend step examples:
- `**System/API:** Hybris HAC → FlexibleSearch **| Screen:** — **| Action:** Query order <code>: ambient_plastic_bag_paid, ambient_plastic_bag_fee`
- `**System/API:** Refund engine **| Screen:** — **| Action:** Wait for refund cron (interval [TBC]); max 20 min; then Query refund transactions for order group <id>`

## 3. Master page skeleton (Markdown)

```markdown
# <Feature> — Test Plan

## 0. Feature Overview & Scope
- Feature / PM owner / Epic / PRD (link + version) / Environment (UAT/SIT, app build, flags)
- In scope: … · Out of scope: … (reason)

## 1. Acceptance Objectives
1. Validate that …

## 2. System / Tool | Access / Role Needed
| System / Tool | Used for (journeys) | Access / Role Needed | How to obtain |

## 3. Common Data Setup
### 3.1 Configuration & Settings
| ID | Setting | Value | Controlling system → path | Verification | Cache / propagation | Revert |
### 3.2 Test Data
| ID | Data item (alias) | Concrete identifier | Required attributes | System → path | Verification | Notes |

## 4. All User Journeys
- [x.y–x.z <Section names>](<child page link>) — TC-01 … TC-09
| Journey ID | Description | Type | Priority | Platforms |

## 5. Journey Dependency Map
| Journey ID | Section | Depends on | Followed by |

## 6. Suggested Execution Order for End-to-End Scenario Chains
- <chain name>: TC-01 → TC-15 → TC-20

## 7. Acceptance Criteria Summary
| Area | Acceptance Criteria |

## 8. Requirement Coverage Matrix
| US / AC / FR | Journey IDs | Status |

## 9. Conventions
- Step format; shortened navigation macros; result legend PASS / FAIL / BLOCKED / NOT TESTED

## 10. Open Items / Notes / Assumptions
| # | Item | Type ([TBC]/[assumed]) | Blocks journeys | Owner |

## 11. Test Execution Summary
| TC ID | Scenario | iOS | Android | Web | Tester | Date | Evidence | Notes |
```

## 4. Confluence storage HTML: one journey

Generate this from structured data in code (e.g. a Python dict per journey → string). Do not convert Markdown.
Do not put `<table>`, `<ol>` or `<ul>` inside `<p>`.

```html
<h3>Journey TC-01 — Ambient fee triggered when qualifying SSI quantity ≥ N</h3>
<table data-layout="full-width"><tbody>
<tr><th><p><strong>Field</strong></p></th><th><p><strong>Value</strong></p></th></tr>
<tr><td><p>a.) ID of the journey</p></td><td><p>TC-01</p></td></tr>
<tr><td><p>b.) Brief description of the journey</p></td><td><p>…</p></td></tr>
<tr><td><p>c.) ID of journey it depends on</p></td><td><p>—</p></td></tr>
<tr><td><p>d.) Preconditions / Data Setup</p></td><td>
  <p><strong>Prior state:</strong> …</p>
  <p><strong>Data:</strong> …</p>
  <p><strong>Settings:</strong> …</p>
</td></tr>
<tr><td><p>e.) Tester steps</p></td><td><ol>
  <li><p><strong>System/API:</strong> Customer App <strong>| Screen:</strong> Home <strong>| Action:</strong> …</p></li>
</ol></td></tr>
<tr><td><p>f.) Expected Observations / Pass Criteria</p></td><td><ul>
  <li><p>(step 6) …</p></li>
</ul></td></tr>
<tr><td><p>g.) Journey IDs that follow the current journey</p></td><td><p>TC-15, …</p></td></tr>
<tr><td><p>h.) Requirement coverage</p></td><td><p>US-01 · AC-01.1 · FR-01 (RULE-01.1)</p></td></tr>
<tr><td><p>i.) Platforms &amp; evidence</p></td><td><p>…</p></td></tr>
<tr><td><p>j.) State left behind / Cleanup</p></td><td><p>…</p></td></tr>
</tbody></table>
```

Pass criteria in Confluence use `<ul><li>`; the `•` character is used only in the Markdown and chat version.
Escape `&`, `<` and `>` in values. Use `<code>` for field names and SKU codes.
