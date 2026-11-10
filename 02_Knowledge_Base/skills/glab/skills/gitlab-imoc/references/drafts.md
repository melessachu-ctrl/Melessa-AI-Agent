# Draft templates

Fill these from gathered data only. Mark unconfirmed facts (for example AI
investigation findings) as "suspected". Put each draft in a fenced `markdown`
block. The user posts them; never post them yourself.

Keep the register short and plain, like a note to a colleague.

## `/inc update`

The user runs `/inc update` in the incident channel and pastes this. It feeds
the incident timeline and the status page.

```markdown
Status: <Investigating | Fixing | Monitoring>

Impact: since <HH:MM> UTC, <who is affected and how, in user terms>.
Cause: <confirmed cause, or "suspected: ..." or "under investigation">.
Actions: <what was done, with MR/issue links>.
Next: <what happens next>. Next update by <HH:MM> UTC.
```

## Status page (first post)

The user or CMOC runs `/woodhouse incident post-statuspage`. Keep the main text
to 220 characters or less. No internal names, hosts or MR links. Take `<N>`
from the update cadence table in
[duties-checklist.md](duties-checklist.md#communications) for the severity and
state (for example 10 for S1).

```markdown
We are investigating <symptom in user terms, for example "delays and failures for CI jobs on hosted runners">. Next update in <N> minutes.
```

If the cause is already known (common when comms start late), post as
`Identified` instead:

```markdown
Since <HH:MM> UTC, <symptom in user terms>. We have found the cause and are applying a fix. <What users may still see>. Next update in <N> minutes.
```

If the impact start is not confirmed, write "about <HH:MM> UTC" or leave the
time out. Never put a guessed time in public text.

Map incident.io status to the status page state: `Investigating` →
Investigating, `Fixing` → Identified, `Monitoring` → Monitoring, resolved →
Resolved.

## Status page (follow-up / resolved)

```markdown
<Identified|Monitoring>: <what we found and did, in user terms>. <What users may still see>. Next update in <N> minutes.
```

```markdown
Resolved: <service> is operating normally since <HH:MM> UTC. <Any action users need to take, for example "retry failed jobs">.
```

## Slack: check in with responders

```markdown
<name>, IMOC here. Catching up now. What is the current impact, and do you need anything from me (people, comms, escalation)?
```

## Slack: decide on comms

```markdown
Impact started around <HH:MM> UTC, so we should post publicly by <HH:MM+1h> UTC. <name>, can you confirm the current customer impact? I'll <page CMOC | post the status page> unless someone objects.
```

## CMOC page note

The user runs `/inc escalate` → `dotcom CMOC` and adds:

```markdown
S<N> on GitLab.com: <one line impact>. Impact since <HH:MM> UTC. Need a status page post. Incident channel: <#channel>.
```

## Shift handoff note

Post in the incident channel. If you hold the `Incident Lead` role in
incident.io, hand it over too.

```markdown
Handing over IMOC to <name>.
- State: S<N>, <status>, impact since <HH:MM> UTC, <current impact>.
- Done: <mitigation so far>.
- Open: <open questions, pending actions with owners>.
- Comms: last status page update <HH:MM> UTC, next due <HH:MM> UTC. CMOC: <name | none>.
```
