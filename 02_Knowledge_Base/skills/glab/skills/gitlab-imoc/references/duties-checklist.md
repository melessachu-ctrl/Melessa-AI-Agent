# Duties checklist

Checks for the IMOC / Incident Lead on GitLab.com, by phase. Each check names
its source. `IM/` means
`content/handbook/engineering/infrastructure-platforms/incident-management/` in
the handbook repo; see [handbook-sources.md](handbook-sources.md) to re-fetch.

## Contents

- [Just paged](#just-paged)
- [Taking over mid-incident](#taking-over-mid-incident)
- [During the incident](#during-the-incident)
- [Communications](#communications)
- [S1 and S2 extras](#s1-and-s2-extras)
- [Mitigated and monitoring](#mitigated-and-monitoring)
- [Resolution](#resolution)
- [Shift handoff](#shift-handoff)
- [Special cases](#special-cases)
- [Timings](#timings)

## Just paged

- Ack within **15 minutes** (IMOC response SLA). If the IMOC does not respond,
  Infra Leadership gets paged. (`IM/incident-manager-onboarding.md` FAQ)
- Check the severity and change it if needed. Err on the higher side when
  unsure and impact is large. (`IM/incident-manager-onboarding.md` "When an
  incident happens"; `IM/_index.md` "Report an Incident via Slack")
- Make sure the `Incident Lead` role is set on purpose. There is only one
  owner, and only the owner can resolve. (`IM/_index.md` "Ownership")
- Paged by an unanswered EOC escalation: ask in the announcement channel
  `@sre-oncall, I just received an escalation. Are you available to look into LINK_TO_INCIDENT_ESCALATION, or do you need some assistance?`
  If the EOC is unavailable, escalate to Infra Leadership. (`IM/_index.md`
  "Incident Manager Escalation")

## Taking over mid-incident

For an IMOC paged into an incident that is already running, often after a
shift change (`schedule_show` shows who was IMOC before):

- Ack the page within **15 minutes**, then say in the channel that you are
  the IMOC now.
- Find out what the previous IMOC handed over, if anything (Slack, the page
  message). Do not assume they covered comms.
- Check the comms state: status page posted? CMOC paged? Public comms deadline
  from impact start?
- Check who holds the `Incident Lead` role, and the last `/inc update` time.
- If someone else is the Incident Lead, status changes, `/inc update` and
  resolving are theirs: draft them for the Lead and ask. The IMOC can still
  engage CMOC, escalate, and decide on status page comms.
- Then run the [During the incident](#during-the-incident) checks.

## During the incident

From `IM/roles/incident-lead.md` "During the incident" and the runbook IMOC
checklist (`incidents/general_incidents.md`):

- Regular `/inc update` with current customer impact and actions. Compare the
  last update time with the cadence in [Communications](#communications)
  (guideline only, see
  [known contradiction 7](handbook-sources.md#known-contradictions)).
- Required fields set (`/inc field`): affected services, teams, Blocks
  Deployments / Blocks Feature Flags.
- Confidentiality matches the data: `/inc field` → `Keep GitLab Issue
  Confidential` = `true` when needed. RED data never goes in an incident.
  ORANGE/YELLOW data needs a confidential issue or internal note.
  (`IM/_index.md` "Incident Data Classification")
- Incident summary filled in (`/inc summary`), with the cause in `causes` once
  known. An executive summary should exist by **10–15 minutes** (runbook).
- Status matches the work: `Investigating` → `Fixing` (fix identified) →
  `Monitoring` (fix deployed or impact stopped). `Investigating` for more than
  30 minutes after the EOC engages means the IMOC should be engaged.
  (`IM/_index.md` "States and Statuses"; that table is for status.io states,
  see [known contradiction 5](handbook-sources.md#known-contradictions))
- Right people in the room; ask non-contributors to leave a crowded call
  (about 30 people). Restate status for people joining.
- Recent deploys and feature flag changes checked (`change_event_list`).
  Engage `release-managers` if a code change may be the cause.
- Timeline accurate, including impact start and end (drives TTR in
  `IM/metrics.md`). `:pushpin:` adds a public comment on the issue, `:star:`
  an internal one.
- Follow-ups recorded with initial owners.
- Check in on a cadence: **S1 every 5–10 minutes**.
  (`IM/incident-manager-onboarding.md` "Introduction")

## Communications

From `IM/roles/communications-lead.md` and
`content/handbook/support/workflows/cmoc_workflows.md`:

- The Incident Lead is Communications Lead by default. Do not assume CMOC was
  paged; check `escalation_list` first (the handbook disagrees, see
  [known contradictions](handbook-sources.md#known-contradictions)). Page with
  `/inc escalate` → `dotcom CMOC` once a Degraded/Outage condition lasts
  **5 minutes** (`IM/_index.md`), and for S1/S2 or when a lot of communication
  is needed (`IM/roles/communications-lead.md`).
- The IM decides whether to start status page comms. Confirm customer impact
  with the responder first; do not post too early.
- Any Degraded/Outage condition lasting **5 minutes** should be communicated
  publicly **within 1 hour**. Count from impact start. (`IM/_index.md`
  "Definition of Outage vs Degraded vs Disruption")
- `Degraded` means a sustained 5 minutes below the service's Apdex SLO or
  above its error ratio SLO. `Outage` means 5 minutes above the Outage line on
  the error ratio graph. Check the service's Apdex and error ratio panels; SLOs
  are in the runbooks `metrics-catalog/services/<service>.jsonnet` (the
  handbook still links the old `rules/service_apdex_slo.yml`). A responder saying
  "apdex shows user impact" is a strong sign. (`IM/_index.md`, same section)
- Responders sometimes use a stricter bar ("status page if jobs are delayed
  15+ minutes"). The handbook rule is the one above. If the deadline has
  passed, suggest posting now (as `Identified` if the cause is known) instead
  of waiting for the stricter bar.
- Create the status page incident with `/woodhouse incident post-statuspage`.
- Status page update cadence (a guideline; "next update at …" also works):

  | State | S1 | S2 | S3/S4 |
  |---|---|---|---|
  | Investigating | 10m | 15m | 15m |
  | Identified | 10m | 30m | 30m |
  | Monitoring | 30m | 60m | 60m |
  | Resolved | none | none | none |

- Status page main text: 220 characters or less.

## S1 and S2 extras

From `IM/roles/incident-lead.md` "Special Handling for S1 / S2 Incidents". The
IMOC is the DRI:

- Confirmed S1: page Infra Leadership with `/inc escalate` → `On-call teams` →
  `dotcom leadership escalation`, with a notification message, 24/7. In a large
  outage, ask whether a senior person should coordinate recovery.
- Verified S1: page the Infrastructure Liaison with `/pd trigger` →
  `Infrastructure Liaison` (owns e-group communications).
- Make sure comms are accurate and on time.
- Engage development through the InfraDev escalation if needed (`#dev-escalation`).
- S1/S2 automatically get `~blocks deployments` and `~blocks feature-flags`.
- After a first significant S1/S2, a new IMOC schedules a feedback coffee chat
  with the EOC and CMOC.

## Mitigated and monitoring

From `IM/_index.md` "Intermittent and self-resolving incidents" and
`cmoc_workflows.md`:

- Use `Monitoring` even if the cause was external or no action was taken.
- State how long the incident stays in Monitoring (typically 30 minutes).
- If impact comes back, go back to `Investigating` or `Fixing`.
- Keep the status page incident open until recurrence is unlikely.
- Do not lower severity: it reflects the maximum impact.

## Resolution

- Only the Incident Lead resolves. CMOC resolves the status page only after the
  IM gives the all-clear (`Resolved`, `Operational`).
- Final `/inc update` with impact window, cause and next steps.
- Then go to [post-incident.md](post-incident.md).

## Shift handoff

From `IM/incident-manager-onboarding.md` "Ending your on-call shift":

- Page or bring in the next IMOC (`schedule_show` for who is next) and brief
  them on the call.
- If you hold the `Incident Lead` role in incident.io, it **must be taken
  over** before you leave. Otherwise, brief the next IMOC.
- Next IMOC unavailable: look for cover in `#im-general`,
  `#staff_plus_engineers`, `#eng-managers`; create an override for yourself
  while searching; last resort is the Infra Leadership escalation.

## Special cases

- **Two S1/S2 at once:** take the one with the highest customer impact; hand
  the other to Infra Leadership. Ask for more IMs in `#im-general`.
- **Weekends:** only S1/S2 are mitigated. Repeated S3/S4 needing weekend work
  are combined into one `severity::2`. (`IM/_index.md` "Weekend Escalations")
- **Missed Tier 2 page:** forwarded to the IMOC after 15 minutes; find the
  on-call person or someone else. (`IM/incident-manager-onboarding.md`
  "Escalations and Missed pages")
- **Unblocking users:** the IMOC decides, after the EOC confirms mitigation
  holds. Never while abuse is suspected. CMOC contacts the user first.
  (`IM/_index.md` "Incident Mitigation Methods")
- **Customer calls (S1/S2, rare):** find a second IM
  (`/here A second incident manager is required for a customer interaction call for XXX`
  in `#im-general`), page Infra Leadership, find a CSM. (`IM/_index.md`)
- **Security incidents:** `/security`; the lead is usually from Security.
- **incident.io down:** `IM/incident-io-down.md`.

## Timings

| Rule | Time |
|---|---|
| IMOC / EOC / Tier 2 ack | 15 min |
| Engage CMOC after Degraded/Outage lasts | 5 min |
| Public comms after impact start | 1 hour |
| Escalate from `Investigating` after EOC engages | 30 min |
| Executive summary exists | 10–15 min |
| S1 check-ins | every 5–10 min |
| Follow-up triage | 1 business day |
| Incident review closed after resolution | 5 working days |
