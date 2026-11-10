# Handbook sources

The handbook is the source of truth. This skill only keeps the checks. When a
rule matters for a decision, or seems wrong, re-fetch the page.

## Fetching

Handbook repo: `gitlab-com/content-sites/handbook`, branch `main`. The file
path must be fully URL-encoded (`/` → `%2F`):

```sh
# list the incident-management tree
glab api "projects/gitlab-com%2Fcontent-sites%2Fhandbook/repository/tree?path=content/handbook/engineering/infrastructure-platforms/incident-management&ref=main&recursive=true&per_page=100"

# read one file
glab api "projects/gitlab-com%2Fcontent-sites%2Fhandbook/repository/files/content%2Fhandbook%2Fengineering%2Finfrastructure-platforms%2Fincident-management%2Froles%2Fincident-lead.md/raw?ref=main"

# encode a path
python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1],safe=""))' "<path>"
```

Without `glab`: `https://gitlab.com/gitlab-com/content-sites/handbook/-/raw/main/<path>`.
Runbooks use `gitlab-com/runbooks`, branch `master`.

## Sources

`IM/` = `content/handbook/engineering/infrastructure-platforms/incident-management/`.

| Path | Use for |
|---|---|
| `IM/_index.md` | Ownership, severities, statuses, labels, escalation, weekends, data classification, customer calls, corrective actions |
| `IM/roles/incident-lead.md` | Incident Lead duties during and after; S1/S2 handling |
| `IM/roles/communications-lead.md` | When to engage CMOC, comms duties, customer calls |
| `IM/roles/incident-responder.md` | What the EOC does, when they page the IMOC |
| `IM/incident-manager-onboarding.md` | IMOC goals, shifts, start and end of shift, handoff, FAQ |
| `IM/incident-follow-ups.md` | Follow-up triage and target projects |
| `IM/incident-io-down.md` | Running an incident without incident.io |
| `IM/on-call/tier-1.md`, `IM/on-call/tier-2.md` | Rotations, Tier 2 escalation |
| `IM/metrics.md` | MTTR targets, how TTR is computed |
| `content/handbook/support/workflows/cmoc_workflows.md` | Status page stages and update cadence |
| `content/handbook/engineering/infrastructure-platforms/incident-review/_index.md` | Incident review roles and SLOs |
| `content/handbook/engineering/_index.md` ("Feature Change Locks") | FCL process |
| runbooks `incidents/general_incidents.md` ("IMOC Checklist") | IMOC timers and mental checks |

Rendered pages: `https://handbook.gitlab.com/handbook/engineering/infrastructure-platforms/incident-management/`.

## Known contradictions

Flag these to the user instead of picking one silently:

1. **Infra Leadership option name:** `roles/incident-lead.md` says
   `dotcom leadership escalation`; `_index.md` says
   `Infrastructure leadership escalation`. Pick whichever the `/inc escalate`
   dropdown shows.
2. **Who is paged automatically:** `communications-lead.md` says CMOC is not
   paged automatically; `cmoc_workflows.md` says declaring pages the EOC, IM
   and CMOC; `_index.md` says a severity upgrade pages all three. Check
   `escalation_list` for what actually happened.
3. **When to engage CMOC:** `_index.md` says the EOC and IM should engage CMOC
   once any Degraded/Outage condition lasts 5 minutes, at any severity;
   `communications-lead.md` says a separate Communications Lead is assigned
   "based on need". Default to the 5-minute rule and say so.
4. **Default follow-up project:** `_index.md` and `roles/incident-lead.md` say
   `gitlab-com/gl-infra/incident-follow-ups`; `incident-follow-ups.md` says
   `gitlab-com/gl-infra/production-engineering`.
5. **State names:** incident.io uses Investigating / Fixing / Monitoring;
   status.io uses Investigating / Identified / Monitoring / Resolved. They do
   not map one to one; use the mapping in
   [drafts.md](drafts.md#status-page-first-post) and say it is a guideline.
   The 30-minute `Investigating` escalation rule in `_index.md` "States and
   Statuses" is written for status.io states; applying it to the incident.io
   status is a reading, so say so.
6. **Exec updates:** Infra Leadership posts S1 updates in `#cto`, while
   `communications-lead.md` says the Infrastructure Liaison owns e-group
   communications.
7. **`/inc update` cadence:** no page gives a cadence for `/inc update`;
   `roles/incident-lead.md` only says "regular". The only cadence table is for
   the status page (`cmoc_workflows.md`). Using it for `/inc update` is a
   guideline, so say so when you flag an overdue update.
