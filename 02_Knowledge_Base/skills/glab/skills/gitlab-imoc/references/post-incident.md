# Post-incident

Duties after resolution. Sources are in the handbook repo under
`content/handbook/engineering/`; see [handbook-sources.md](handbook-sources.md).

## Follow-ups (within 1 business day)

From `infrastructure-platforms/incident-management/roles/incident-lead.md`
"After the incident" and `incident-management/incident-follow-ups.md`:

- Review the auto-created follow-ups (`follow_up_list` with `incident_id`).
  Any issue link pasted in the channel becomes a follow-up, so some are noise.
- Make sure each one has context from the incident.
- Move each one to the right project with `/move`:
  - application issues: `gitlab-org/gitlab`
  - Gitaly: `gitlab-org/gitaly`
  - Runway: `gitlab-com/gl-infra/platform/runway/team`
  - everything else: `gitlab-com/gl-infra/production-engineering`
    (`incident-follow-ups.md`; other pages still name
    `gitlab-com/gl-infra/incident-follow-ups`, so flag it, see
    [known contradictions](handbook-sources.md#known-contradictions))
  - keep the `infradev` label when moving.
- Add team/group labels and an owner.
- Corrective actions are listed in the incident issue description at any
  severity.

## Corrective actions

From `infrastructure-platforms/incident-management/_index.md` "Corrective
Actions":

- Label `~"corrective action"` only on issues that come from an incident;
  `~infradev` is added automatically. Link the incident.
- Severity is the highest severity of the related incidents. Add the service
  label.

## Incident review (S1/S2)

From `infrastructure-platforms/incident-review/_index.md`:

- All user-facing S1/S2 incidents need a review. Others only with
  `Review-Requested`.
- The Incident Lead starts it: open the review issue in the production
  tracker, link the incident, assign the DRI.
- The DRI is the team that owns the service or feature; its EM owns the review.
- A Bar Raiser approves before closing. Close **within 5 working days** of
  resolution. S1 public RCA within 7 days, owned by the DRI.
- Check `postmortem_show` for an existing review document first.

## Feature Change Lock (S1/S2)

From `content/handbook/engineering/_index.md` "Feature Change Locks":

- Tell the EM of the team that owns the root cause to start the FCL.
- Business day 1: FCL issue `[Group Name] FCL for Incident(s) ####` and a
  `#fcl-incident-[number]` channel. Days 2–3 planning, days 2–9 work, days
  10–11 closing.
- Teams that only felt the impact are out of scope.
- FCLs apply to all S1/S2 incidents. Exceptions need VP of Engineering
  approval, for example no public facing impact, or a cause that was not an
  engineering division change (such as a vendor outage). Request the
  exception on business day 1; do not just skip the FCL.

## Draft: hand off follow-ups

```markdown
Follow-ups for INC-<N> are triaged:
- <issue link>: moved to <project>, owner <name>.
- <issue link>: closed as noise.
<If S1/S2:> Incident review: <issue link>, DRI <team>. <EM name>, can you start the FCL?
```
