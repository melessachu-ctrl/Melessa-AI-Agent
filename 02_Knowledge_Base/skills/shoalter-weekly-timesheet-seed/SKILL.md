---
name: Shoalter weekly timesheet seed
description: >-
  Use when creating or seeding Melessa’s Shoalter TimeSheet for the current week
  with the fixed Non-Chargeable rows (PM Standup, Timesheet Input, UIUX Standup,
  Public Holiday on HK holidays and weekends) plus last week’s other Project
  rows (hours blank) at timesheet.shoalter.com.
---
# Shoalter weekly timesheet seed

Create (or open) **This week** on Shoalter TimeSheet, seed the standing Non-Chargeable rows with weekday hours, then copy every **other** Project row from **Last week** with hours left blank. Do **not** Submit unless the user explicitly asks.

## Assumptions
- Runs in the signed-in box Chrome profile.
- Destination: `https://timesheet.shoalter.com/timesheet`
- Staff login uses **Staff ID** + password. Prefer Vault login for `timesheet.shoalter.com` (Staff ID is often `SF210045`). Never store or type a password from memory; if the login page appears, stop and ask the user in chat to approve a Vault/login fill (or sign in once so the session sticks).

## Inputs
- `{week}`: default **This week**. Only change if the user names another week.
- `{submit}`: default **false**. Save only unless the user asks to Submit.

## Fixed rows (from My Projects)
Apply these four My Projects favorites (toast should say Applied 4 items):

| Project Labels | Detail Work Done | Remark |
| --- | --- | --- |
| Non-Chargeable Tasks | Public Holiday | (empty) |
| Non-Chargeable Tasks | Office/ Department admin work | PM Standup |
| Non-Chargeable Tasks | Office/ Department admin work | Timesheet Input |
| Non-Chargeable Tasks | Office/ Department admin work | UIUX Standup |

## Hours rules (fixed rows only)
**Public Holiday = 8h** on every day that is:
1. **Saturday or Sunday** of that week, **or**
2. A **Hong Kong public holiday** (even if it falls on Mon–Fri, e.g. 1 Jan on Friday → that Friday is Public Holiday 8h, not standup hours).

Look up Hong Kong public holidays for the week’s calendar dates before filling (official HK holiday calendar for that year). On a HK public holiday weekday: put **8** only on the Public Holiday row for that day; leave PM Standup / Timesheet Input / UIUX Standup **empty** for that day.

**Normal Mon–Fri (not a HK public holiday):**
- **PM Standup** → 0.5
- **Timesheet Input** → 0.25
- **UIUX Standup** → 1
- Public Holiday cell for that day → empty

Leave chargeable / other project rows alone after adding them. Leave remaining daily hours empty for Melessa to fill later.

## Copy other rows from Last week
After the four fixed rows are present and hours filled:

1. Open **Last week** (or the previous week relative to `{week}`) in view or edit mode and list every timesheet row.
2. **Exclude** the four fixed Non-Chargeable items above (match by Project Labels + Detail Work Done + Remark). Melessa may call them “Project Labels” loosely; treat Public Holiday / PM Standup / Timesheet Input / UIUX Standup as those four standing rows.
3. For every **other** row, record the full identity needed to recreate it: Project Labels, Detail Work Done, Remark (and any other required fields the UI shows).
4. Switch back to **This week** / `{week}` in **Edit** mode.
5. For each recorded row that is **not already** on This week (same Project + Detail + Remark), add it via **My Projects** if it is a favorite, otherwise **+ Add New** with the same labels.
6. Leave **all hours blank** on these copied rows. Do not copy last week’s hour values.
7. Do not duplicate a row that already exists on This week.

## Steps
1. Open Chrome → go to `https://timesheet.shoalter.com/timesheet`.
2. If redirected to `/login`: use Vault / secure fill for `timesheet.shoalter.com`, or **ping the user** for password / Vault fill. After login, open **Timesheet** in the left nav if landed on Announcement.
3. Confirm the **TimeSheet** tab (not team tabs). Select **This week** (or `{week}`).
4. If the grid is view-only, click **Edit** so Cancel / Save / Submit appear.
5. Click **My Projects**. In the modal, tick the four Non-Chargeable rows listed above. Apply/confirm so rows appear (expect “Applied 4 items to timesheet”). Close the modal if it stays open.
6. If those four rows already exist for the week, **do not duplicate**—reuse them and only fill missing hours.
7. Resolve the week’s Sun–Sat dates. Mark which are Sat/Sun or HK public holidays. Fill Public Holiday = 8 on those days; fill standup hours only on remaining weekdays per Hours rules.
8. Run **Copy other rows from Last week** (hours blank).
9. Click **Save**. Do not click **Submit** unless `{submit}` is true.
10. Report back: week label, which days were treated as Public Holiday (and why: weekend vs named HK holiday), hours filled on fixed rows, which Last-week rows were copied (or that none were missing), Save vs Submit, and whether login needed a user ping.

## Stop / edge cases
- Session expired or captcha → stop and message the user; do not invent credentials.
- My Projects missing one of the four favorites → add that row via **+ Add New** with the same Project / Detail / Remark labels, then fill hours.
- Last week has no other rows besides the four fixed ones → skip the copy step and say so.
- A Last-week row cannot be recreated (missing dropdown option) → skip that row, list it in the report, continue with the rest.
- Red daily totals (e.g. −6.25) are expected after seeding; do not invent extra chargeable work to zero them out.
- If HK holiday list cannot be verified for that year, ping Melessa before guessing weekday Public Holiday cells.
