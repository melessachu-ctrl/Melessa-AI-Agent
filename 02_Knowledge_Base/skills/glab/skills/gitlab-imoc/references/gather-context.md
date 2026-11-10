# Gathering incident context

Use incident.io first, Slack (through Glean) second, `glab` last. Subagents
may not have the MCP tools; check before delegating MCP calls.

## Contents

- [Calling incident.io and Glean](#calling-incidentio-and-glean)
- [incident.io read-only tools](#incidentio-read-only-tools)
- [Finding the user's role](#finding-the-users-role)
- [Never call](#never-call)
- [Slack through Glean](#slack-through-glean)
- [When the data is missing](#when-the-data-is-missing)
- [Fallbacks](#fallbacks)

## Calling incident.io and Glean

Use the incident.io and Glean MCP servers, either connected directly or
through a wrapper. Server and tool names depend on the local setup; the tool
names below are the incident.io and Glean tool names. For example, through a
`lazy-mcp` wrapper (server names `incident_io` and `glean`), keep `server` and
`command_name` at the top level and put the tool input inside `parameters`:

```js
await tools["lazy-mcp"].invoke_command({
  server: "incident_io",
  command_name: "incident_show",
  parameters: { id: "INC-1234", include: ["updates", "call_notes"] },
})
```

- Check a tool's exact input schema before the first call (with a wrapper:
  `describe_commands({server, command_names: [...]})`).
- A tool that is in neither the read-only list nor the
  [never call](#never-call) list may be new: treat it as a write and do not
  call it.
- If a server reports `auth_required`, show the URL to the user and stop for
  that server.
- Results can be large. Save them and read the parts you need. Some tools
  return the same data twice (`content[].text` and `structuredContent`). Use
  `structuredContent` when it exists; otherwise parse `content[].text`
  (`identity_get` and Glean `search` return only text).
- Run independent calls together with `Promise.allSettled`.

## incident.io read-only tools

| Need | Tool and key inputs |
|---|---|
| Who the user is | `identity_get` |
| The user's active incidents | `incident_list` with `status_category: ["active"]`, `assigned_to`, `include: ["summary"]` |
| State, severity, roles, custom fields, timestamps, summary | `incident_show` with `id`, `include: ["updates", "call_notes"]` |
| AI findings (large, see notes) | `incident_show` with `id`, `include: ["investigation"]` |
| Full update history (to check the cadence) | `incident_update_list` with `incident_id`, `page_size: 50` |
| Who was paged and who acked (EOC, CMOC, IMOC, leadership) | `escalation_list` with `incident` |
| What changed before impact (deploys, feature flags, config) | `change_event_list` with `occurred_after` / `occurred_before` around impact start, plus `query: "<service>"` or `change_types` (release tags fill unfiltered results); `code_change_list` for infra MRs, which may not show as change events |
| Vendor status (for example GCP) | `external_service_list` with `query` (for example `Google`) to get the exact name, then `external_service_status` with `services: ["Google Cloud"]`, `from`, `to` |
| Open actions and follow-ups | `action_list` / `follow_up_list` with `incident_id` |
| Who was IMOC when, the user's shift end, next IMOC | `schedule_list` with `user: "me"` gives the user's current shift and its end. Then `schedule_show` for the `Incident Manager - GitLab SaaS` schedule (`query: "IMOC"` finds nothing). Use it in every gather, not only at handoff: a shift change often explains a mid-incident page |
| Post-incident review doc | `postmortem_show` |

Notes:

- `incident_show` returns only the last 5 updates unless `include: ["updates"]`.
- `include: ["investigation"]` can return around 100 KB, mostly findings
  from past incidents. Fetch it in a separate call, and read only
  `investigation.summary` and the findings about this incident.
- The `investigation.summary` and `findings` are AI output. Treat them as leads.
- `ai_summary` and `summary` are not updates. Check the cadence against
  `incident_update_list` only.
- An empty `change_event_list` proves nothing. Infra config MRs (for example
  in `gl-infra/argocd/apps` or `config-mgmt`) often appear only in Slack or
  the investigation findings.
- `external_service_status` showing `up` does not rule out a vendor cause:
  planned maintenance does not show as an outage.
- `timestamps` may only have `Declared at`. Impact start often comes from the
  Slack discussion or the findings. Confirm it with the user or a responder.

## Finding the user's role

The `you` field of `incident_show` only says whether the user is a
participant. incident.io has no IMOC role, so:

1. Get the user's `user_id` from `identity_get`.
2. Compare it with `roles[].user_id` in `incident_show` (Incident Lead,
   Reporter, ...).
3. Check `escalation_list` with `incident`. The `escalation_path.name` tells
   the role: `GitLab.com Production` is the EOC, `Incident Manager Oncall
   (IMOC)` is the IMOC. No path with `CMOC` in the name means no CMOC was
   paged. An entry with `you.paged: true` means the user was paged on that
   path.
4. `acked_by` can be someone other than the paged user (for example the
   Incident Lead acks for the EOC). An ack does not mean the paged person
   engaged; check the Slack channel.
5. The IMOC is often not the Incident Lead. Say who holds the
   `Incident Lead` role, because only they can resolve.

## Never call

These tools write, page or post. The skill is drafts only, so never call them:

- `incident_message`, `incident_update`, `incident_create`, `incident_merge`,
  `incident_unmerge`, `incident_pin`, `incident_attachment_create`
- `action_create`, `action_update`, `action_delete`, `action_convert`
- `follow_up_create`, `follow_up_update`
- `escalation_create`, `escalation_respond`
- `schedule_override_create`, `schedule_override_delete`, `cover_request_*`
- `status_page_update` (it creates a draft card in the conversation; still a write)
- `postmortem_create`, `postmortem_edit`
- `alert_*` write tools (`alert_attach`, `alert_detach`, `alert_resolve`, ...)
- `ask`: incident.io's own agent may act for the user. Never call it.

## Slack through Glean

- `search` requires `_user_goal` (the user's request, verbatim).
- `incident_show` gives only the channel ID, not its name. Search for the
  incident reference (`INC-1234`) first and take the full channel name from
  the results (`matching_filters` may show a cut-off name).
- To read the whole incident channel, use `search` with `query: "*"`,
  `channel: "inc-1234-<slug>"`, `app: "slack"` and `num_results: 100`. This
  works better than putting the channel name in `query`. Results are grouped
  per message or thread with author and time. Page with `cursor`.
- The `INC-1234` search also finds related threads in other channels, such
  as the first report.
- Use `read_document` on a Slack link to read a full thread.
- Avoid `chat`: it often hits the 10 second timeout.
- Glean indexing lags. The newest messages may be missing; say so.

## When the data is missing

- Before gathering, check that the incident.io and Glean MCP tools exist. If
  one is missing, fails, or needs auth, tell the user at the top of the report
  which one and what could not be checked (roles, update cadence,
  `escalation_list`, `change_event_list`). Do not fall back silently.
- incident.io or Glean not configured: say which, then use the `glab`
  production issue and ask the user to paste the Slack thread.
- If incident.io calls fail, ask whether incident.io itself is down (or check
  `https://status.incident.io`) before using the handbook's
  `incident-io-down.md` ([sources](handbook-sources.md#sources)).

## Fallbacks

- **Production issue:** the `ticket` field of `incident_show` links it. Without
  incident.io, search
  `glab issue list -R gitlab-com/gl-infra/production --label incident --search "<words>"`
  and read it with `glab issue view <iid> -R gitlab-com/gl-infra/production --comments`.
- **Status page:** `https://status.gitlab.com` renders with JavaScript, so a
  plain fetch shows nothing. Use the status.io JSON API instead (the page ID
  is in the status.gitlab.com HTML):
  `curl -s https://status.gitlab.com/1.0/status/5b36dc6502d06804c08349f7`.
  `result.incidents` lists open incidents; empty means nothing is posted.
- **Slack without Glean:** ask the user to paste the channel or the thread.
