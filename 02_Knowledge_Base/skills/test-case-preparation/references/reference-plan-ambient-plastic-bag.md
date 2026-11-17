# Minimum-bar reference: Ambient Plastic Bag (Oct 5) — Test Plan

Read on 2026-11-17 (master v15, children v7 / v2 / v3 / v1).

| Page | Confluence ID | Content |
|---|---|---|
| Ambient Plastic Bag (Oct 5) - Test Plan (master) | `5970526373` | Sections 1–8 |
| 1.1–1.2 Checkout Fee Calculation & $2 Cap | `5977505836` | TC-01 … TC-09 |
| 1.3–1.4 Order Types, Add-Ons & Geographic Scope | `5976588361` | TC-10 … TC-14 |
| 1.5–1.6 Refund Opt-In & Courier Collection | `5976555574` | TC-15 … TC-24 |
| 1.7–1.9 CS, Edge, Regression | `5976326246` | TC-25 … TC-30 |

Space: SPECDOCS on hongkongtv.atlassian.net. Re-read the live pages before reusing anything here; they may have changed.

## Structure to reproduce (minimum)

**Master:** 1 Acceptance Objectives · 2 System / Tool | Access / Role Needed · 3 Common Data Setup (`Data Item | System to Set Up | Notes`) · 4 All User Journeys (child-page links with TC ranges) · 5 Journey Dependency Map (`Journey ID | Section | Depends on | Followed by`) · 6 Suggested Execution Order for End-to-End Scenario Chains · 7 Acceptance Criteria Summary (`Area | Acceptance Criteria`) · 8 Open Items / Notes.

**Child pages:** `## <section no.> <section name>` → `### Journey TC-xx — <description>` → a two-column `Field | Value` table with rows a.)–g.):
a.) ID · b.) brief description · c.) depends on · d.) Preconditions / Data Setup · e.) Tester steps (`System/API | Screen | Action`, numbered) · f.) Expected Observations / Pass Criteria (`•` bullets) · g.) followed by.

## What it does well (keep)

- Groups journeys by PRD section, so each child page maps to one area of the requirement.
- Every step names system, screen and action, including the courier app, CSIS, the refund engine and backend checks.
- Pass criteria cover the UI label and amount, the payment amount, the Hybris fields (TC-01: `ambient_plastic_bag_paid = 1`, `ambient_plastic_bag_fee = 1.00`) and the OIX flag.
- Rule coverage is systematic: threshold met / not met / across location groups / exclusions / bundle expansion; every cap combination; main vs unlimited add-on vs marketing add-on; HK / Macau / overseas / self-pickup; group-level opt-in; window closing; atomic courier counter; group-delivery gate; CS fallback + idempotency; non-refundable zones; stock change after checkout; configurable N; regression of the existing fees.
- Explicit dependency map and execution chains, so state produced by one journey is reused.
- Derived arithmetic is shown (TC-05: `2 + 2×3 + 2×1 = 10 ≥ 6`).

## Where it falls short (what this skill must exceed)

| # | Gap in the reference | Example | Required by this skill |
|---|---|---|---|
| 1 | Data are aliases with no concrete identifiers, path or verification | "SSI SKU A — PBL1, ambient", "Test courier A" | Register with real code or `[TBC — assign]`, system → path, verification |
| 2 | Threshold N and other settings are not in the common setup | N = 6 appears only inside journeys; no cache step | CFG rows with controlling system, verification, cache, revert |
| 3 | Some preconditions do not say how to reach the state | TC-21 "split across two delivery rounds"; TC-23 "split into 2 waybills"; TC-25 "courier did NOT confirm; customer complains"; TC-29 "Admin access" | Setup method + owner for hard-to-reach states |
| 4 | Precondition and steps disagree | TC-05 precondition lists only Bundle SKU E, but the steps also add SSI SKU A ×2 | Preconditions list every data item the steps use |
| 5 | Pass criteria are not tied to steps; no checkpoints | All criteria are listed after the last step | `(step n)` tags; `→ Expect:` checkpoints |
| 6 | Persisted state is not checked consistently | TC-06, TC-08, TC-09, TC-12 stop at the checkout summary; TC-30 pays but checks nothing in the backend | UI + persisted + sync for every fee-writing journey |
| 7 | Backend checks are generic | "Hybris/OIX flag = 1" without field or table (except TC-01); TC-26 "system log shows idempotency guard" without a log name | System + table/API + field; log name or `[TBC]` |
| 8 | Async waits are open-ended | TC-22 "Wait for cron or real-time refund event" | Trigger, interval, maximum wait |
| 9 | Criteria with no step that produces them | TC-20 "new opt-in API call rejected", but no step makes the call; TC-29 "with N = 6 … does not appear", but no step re-runs at N = 6 | Every criterion has a step that observes it |
| 10 | Shared-state collisions between followers | TC-16 changes TC-01's delivery method; TC-20 delivers TC-01; TC-28 zeroes stock, all on the same TC-01 order, so the order matters and is not stated | Producer journeys say what they leave; destructive followers get their own instance or a fixed order |
| 11 | Dependency map inconsistencies | TC-01 "followed by" TC-19, but TC-19 depends on TC-17/TC-18 | Rows c/g and the map must agree |
| 12 | No platform split or evidence | iOS vs Android vs Web not distinguished; no screenshots specified | Row i.) platforms & evidence; result columns per platform |
| 13 | No link back to requirements | No US / FR per journey; the mapper has to infer | Row h.) coverage + master §8 coverage matrix |
| 14 | Assumed entry points | TC-11 "marketing add-on entry (e.g., promo banner / campaign page per confirmed flag)" | Flag `[assumed — confirm]` and list it in Open Items with an owner |

## TC-01 rewritten to this skill's standard (illustrative)

Values marked `[TBC]` were not in the reference and must be confirmed. They are not facts.

| **Field** | **Value** |
| --- | --- |
| a.) ID of the journey | TC-01 |
| b.) Brief description of the journey | Ambient fee $1 charged when qualifying SSI quantity reaches N (= 6) with a single SKU |
| c.) ID of journey it depends on | — |
| d.) Preconditions / Data Setup | **Prior state:** cart empty; no unpaid order for D-01. <br>**Data:** D-01 test customer (verified HK mobile, default address D-02 HK face-to-face); D-04 SSI SKU A `[TBC — SKU code]`, SSI, ambient, location group PBL1, stock ≥ 10. <br>**Settings:** CFG-01 ambient threshold N = 6; CFG-02 ambient bag feature flag = ON for app build `[TBC]`. <br>**Setup steps:** none beyond the master §3 register (verify D-04 stock in MMS → Product → Inventory before the run). |
| e.) Tester steps | 1. **System/API:** Customer App (iOS) **\| Screen:** Login **\| Action:** Log in as D-01 → *Expect:* Home shows account name. <br>2. **System/API:** Customer App **\| Screen:** Cart **\| Action:** Confirm cart is empty; remove items if not. <br>3. **System/API:** Customer App **\| Screen:** Search **\| Action:** Search `[TBC — SKU code]`, tap SSI SKU A. <br>4. **System/API:** Customer App **\| Screen:** PDP of SSI SKU A **\| Action:** Set quantity stepper to 6, tap "加入購物車" `[assumed — confirm label]` → *Expect:* cart badge = 6. <br>5. **System/API:** Customer App **\| Screen:** Cart **\| Action:** Tap "Checkout". <br>6. **System/API:** Customer App **\| Screen:** Checkout summary **\| Action:** Confirm delivery address = D-02 and method = face-to-face; read the fee breakdown. <br>7. **System/API:** Payment Server / mock gateway **\| Screen:** Payment **\| Action:** Pay with test card; record order number. <br>8. **System/API:** Hybris HAC → FlexibleSearch **\| Screen:** — **\| Action:** Query order `<order no.>`: `ambient_plastic_bag_paid`, `ambient_plastic_bag_fee`. <br>9. **System/API:** OIX order table **\| Screen:** — **\| Action:** Query order `<order no.>`: ambient bag flag column `[TBC — column name]`. |
| f.) Expected Observations / Pass Criteria | • (step 6) Line "常溫商品膠袋費" = $1.00 shown. <br>• (step 6) No "冷藏商品膠袋費" or "急凍商品膠袋費" lines. <br>• (step 7) Amount paid = item subtotal + delivery fee + $1.00 `[derived]`. <br>• (step 8) `ambient_plastic_bag_paid = 1`, `ambient_plastic_bag_fee = 1.00`. <br>• (step 9) OIX ambient bag flag = 1. |
| g.) Journey IDs that follow the current journey | TC-15, TC-16, TC-20, TC-28 (the reference also lists TC-19 and TC-27, which depend on TC-17/TC-18 and TC-07 respectively — corrected) |
| h.) Requirement coverage | US-01 · AC-01.1 · FR-01 (RULE-01.1) `[map to PRD IDs]` |
| i.) Platforms & evidence | iOS ✓ Android ✓ Web ✓ · Screenshots: step 6 (fee breakdown), step 7 (payment amount) · Records: step 8 and 9 query output |
| j.) State left behind / Cleanup | Leaves: paid order, face-to-face, not delivered, ambient fee paid. TC-16, TC-20 and TC-28 each change this order; run TC-01 once per follower (or in the order TC-15 → TC-16; a fresh TC-01 for TC-20; a fresh TC-01 for TC-28). Revert: none. |
