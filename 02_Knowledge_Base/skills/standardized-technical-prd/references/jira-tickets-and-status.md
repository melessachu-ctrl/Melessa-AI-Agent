# Jira tickets and document status

Tool names per runtime: `references/runtime-tools.md`. Every Jira write needs the user's explicit yes in chat.

## 1. Document status lifecycle

| Status | Meaning | Set when | Downstream effect |
|---|---|---|---|
| `DRAFT` | Being written or clarified | Page is created | `test-case-preparation` and `user-story-journey-mapper` treat it as DRAFT: ask whether to proceed on it (shared rule 2). Tickets cannot be created. |
| `FINAL` | Complete and in development | Tickets are created (§3), or the user confirms development has started on a complete spec | Ready for test-plan generation and mapping without asking. Changes after this point go in the Changes Log with a version note. |
| `LAUNCHED` | Released to production | The release version is released in Jira (§5) | Test plans become regression / PAT references. Header shows the launch date and release version. |

Status only moves forward. Moving back (e.g. a re-opened scope) needs the user's instruction, and a Changes Log entry.

## 2. Completeness gate (must pass before tickets)

Read the published page (or the page the user named) live before deciding. The spec is **not complete** if any of these is missing, empty or a placeholder:

- Header: Document owner, Requester, Systems.
- Summary, including what the new flow replaces (Old vs New when a person-facing flow changes).
- Development Objectives (goals and non-goals).
- At least one Functional Requirement covering each system in the Systems row, with rules and simulation steps.
- A Systems to Enhance row for each system, mapped to FR and US IDs.
- User stories with acceptance criteria (or, if the PM dropped user stories, an Acceptance Criteria Summary covering every FR).

Also required when they apply:
- A design source was used → every screen-inventory row has a screen subsection.
- UI copy changes → the copytable exists, ZH is filled in, and EN / zh_CN are filled in for new strings.
- App / Web tracking applies → the Kafka tab exists, or an Open Question with an owner says tracking is out of scope.

**Open questions:** allowed only when each has an owner and none would change scope, behaviour, or which systems need a ticket. Any Open Question marked blocking implementation (`[TBC]`) means the spec is not complete.

Designer may stay TBC. The Ticket row stays TBC until tickets exist.

If the spec is not complete: **do not ask about tickets and do not create any.** List what is missing and stop.

Optional but recommended: if a test plan already exists (`test-case-preparation`), link it in the QA ticket.

## 3. When to create tickets

Create tickets only when **both** are true:
1. The spec passes the completeness gate.
2. The user asked for tickets: either they pointed at a Confluence spec and said to create tickets, or this run published a complete spec and they said yes to: "Spec is on Confluence. Create the Jira tickets?" (ask once; stop on no or no answer).

Ask for the **build version, dev PIC and test PIC** only after both conditions hold; ask before creating the epic if any is missing. Reuse the timesheet label from the Slack thread or an earlier epic when one exists.

## 4. Ticket structure (HKTV)

**Epic** in `TEAMECOM`:
- Epic Name; Priority B; Development PIC `customfield_11563`; Testing PIC `customfield_11562`; Build Date `customfield_11200`; Time Sheet Project Label `customfield_11580`.
- Description: background, spec link, scope per system, build, open questions.

**One child ticket per Systems to Enhance row**, in that system's project (`HYBRIS`, `EER`, `CSIS`, `HSS`, `HKTVAD`, …) with `parent` = the epic. If a system's project is not in that list, ask which project to use; never invent a project key.
- Issue type: New Feature or Improvement.
- Summary: `[System] <what it delivers>` (or `[service-name] …`).
- Same PICs as the epic. Assignee: the document owner, unless the user names someone else.
- fixVersion: `<Project>@YYYY-MM-DD` for the build (look it up in the project's versions).
- Description:
  - background (two lines) and the spec link to the system's section;
  - **what it delivers**, taken from the row's Enhancement Breakdown (functions and interfaces for back-end; UI changes and data exchange for front-end);
  - the **FR / RULE / AC IDs** it covers, and the screen subsections for front-end tickets;
  - interfaces with other tickets (API / queue / event, and which ticket owns the other side);
  - "to confirm with dev".
- EER also requires `System` (`customfield_10300`, single option) and Time Sheet Project Label.
- **QA ticket** (if the team uses one): link the test plan; otherwise put the test-plan link in the epic description.
- Look up account IDs; after creating, re-read each ticket to check the assignee stuck (some projects auto-assign).

`final-draft-prd`'s task breakdown is **not** used for tickets; this structure replaces it, so ticket content always traces to the PRD's IDs.

**After tickets exist:** write the epic key into the header's Ticket row, set Document status to `FINAL`, and add a Changes Log line.

## 5. Moving to LAUNCHED

When the user says the feature launched, or asks to update the status:
1. Read the epic's child tickets and their `fixVersion`s.
2. Look up each version in its project's version list. A version counts when `released = true`; use its `releaseDate`.
3. Launch date = the **latest** `releaseDate` among the child tickets' released versions (the feature is not fully live until the last system ships). If some children are on unreleased versions, report them and keep the status `FINAL` unless the user says those tickets are out of the launch.
4. Update the header: Document status `LAUNCHED`, Launch date `YYYY-MM-DD`, Release version(s) (e.g. `HYBRIS@2026-10-05`, `HKTVAD@2026-10-07`). Add a Changes Log line.
5. If no version has a release date, ask the user for the launch date rather than guessing.

## 6. Slack follow-up (only when tickets were created and the user asks)

- Reply in the feature's existing Slack thread (read it first for context and who is involved).
- List the epic and child tickets as links, plus PICs and the timesheet label.
- Tag the dev PIC to check which tickets are still missing. Tag the owning PM of any other team (e.g. MMS) to create their tickets and link them to the epic.
- Confirm the destination with the user before posting, then give them the message link.
