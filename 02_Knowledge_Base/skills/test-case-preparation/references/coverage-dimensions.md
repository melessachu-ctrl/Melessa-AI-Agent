# Coverage dimensions and falsifiability rules

Walk every FR and AC through these lists. Keep a dimension only when it changes the feature's outcome; write down
why you dropped the rest if the PM asks.

## 1. Pre-condition categories

| Category | Variants to consider | Usually controlled in |
|---|---|---|
| User state | guest / logged in; member tier (regular / VIP / SVIP); first-time / returning; PAT group in/out | Auth, CRM, PAT config |
| Platform | iOS app, Android app, mobile web, desktop web, back office | Build, device |
| Account state | new, existing, suspended; wallet / Mall Dollar balance; saved payment methods; saved addresses (HK / Macau / overseas / remote area) | Customer App, Hybris |
| Cart composition | empty, single item, multiple, mixed merchants, mixed temperature zones, bundles, max cart size | Customer App, MMS |
| Product / SKU attributes | fulfilment type (SSI / merchant), location group, temperature type, stock (in / low / out / pre-order), bundle components | MMS, PIM, inventory |
| Promotion / offer | none, single, stacked, expired, conflicting, voucher (paid / free) | Promotion service, back office |
| Order type | main, unlimited add-on, marketing add-on, split delivery rounds, multi-waybill, multi-courier | Order service, OIX |
| Delivery method / geography | face-to-face, 放門口, locker, self-pickup; HK, Macau, overseas, remote area | Checkout, address DB |
| Payment state | valid, expired card, insufficient funds, timeout, partial, retry | Payment server / mock gateway |
| Feature toggle / config | on / off; threshold values; A/B variant | Backend config, PAT group |
| Timing | normal, cut-off either side, flash sale, cron interval, maintenance window, date-based rules | Clock, cron config |
| Data volume | 1 item, bulk, maximum, minimum order threshold | Customer App |

## 2. Edge and negative dimensions

1. **Boundaries:** N−1 / N / N+1; cap reached / exceeded; 0 and maximum quantity.
2. **Exclusions:** each attribute that excludes an item from counting (location group, fulfilment type, temperature, geography, order type).
3. **Priority and cap combinations:** all single, pair and triple combinations of the competing fees or rules.
4. **Lifecycle transitions:** each state's allowed and forbidden actions; the window when an action is available or disappears (before / after final delivery).
5. **Group scope:** the action applied on one member of a group reflects on all members; the delivery-round split.
6. **Change after commit:** out-of-stock, amend, cancel, change delivery method after the fee or flag is set.
7. **Async and duplicates:** cron vs real-time trigger, retry, idempotency (manual + automatic refund), concurrent actors (two couriers on one counter).
8. **Fallback / manual path:** CS tool, back-office override, and that the fallback cannot double-apply.
9. **Configurability:** change setting → new behaviour → revert → old behaviour.
10. **Cross-surface consistency:** the value on checkout = order history = receipt = API = stored record = downstream sync.
11. **Regression:** each existing behaviour the change touches stays unchanged (one journey per Features at Risk row in the PRD).
12. **Error handling:** API failure, timeout, offline, backgrounding during the flow (mobile), permission boundaries.
13. **Known bugs:** each Jira bug in the area becomes a journey or an explicit note.

## 3. Falsifiability rules (adapted from qa-test-plan-review)

1. **The changed thing must be the binding constraint.** Derive the expected value from the behaviour model; position the data so the expected result differs between a build with and without the change. If it would be identical, the journey can give a false PASS. Move the data rather than adding cases.
2. **Confirm the flag or branch from live data before the run.** A fix gated on an attribute cannot be tested with an object that also satisfies the old condition. Put "query attribute X for every test object" in the setup.
3. **Every widened condition gets one negative case.** `A` → `A OR B` needs an object that must still be excluded.
4. **Cached read paths need an explicit refresh step** after data is written.
5. **One derivation per expected value, labelled derived.** Show the arithmetic; the tester confirms against the system at execution. A matching run is self-consistency, not proof. Use a fix-off baseline when the stakes justify it.
6. **Date-bearing data expires.** Re-base on the execution day, state the assumption date, and use one date format across setup and checks.
7. **Cover every surface the change touches,** plus one consistency assertion that they agree.
8. **No empty Expected cells.** A blank expected result is a finding.
9. **When an actual result already exists, it outranks your derivation.** Fix the model, not the tester's number.
10. **Write expected values in the shape the surface outputs.** A list surface needs the expected set (must exist / must be absent), not one value.

## 4. Priority guide

- **P0:** core rule on the main channel; money movement (charge, refund); data persisted for downstream systems.
- **P1:** branches, boundaries, exclusions, group behaviour, fallback paths, idempotency.
- **P2:** cosmetic and label checks, rare combinations, configurability beyond the launch value.
