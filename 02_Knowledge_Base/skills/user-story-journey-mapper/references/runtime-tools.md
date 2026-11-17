# Runtime tools: Claude, Codex, Hermes

These skills are written for **Claude with the Atlassian (Confluence + Jira) connector turned on**. The steps
describe *capabilities*; this table maps each capability to the tool name in each runtime. If a tool is missing, use the
fallback column, or tell the user what you cannot do. Never guess a tool name: list or discover the available tools first.

## Loading another skill

| Runtime | How |
|---|---|
| Claude (Code / desktop / claude.ai) | Invoke the skill by name (Skill tool), or read its `SKILL.md` |
| Codex | Read `<skills dir>/<name>/SKILL.md` (and its `references/`) before continuing |
| Hermes | `skill_view(name='<name>')` |

## Confluence

| Capability | Claude (Atlassian connector) | Hermes (`mcp_atlassian_official_*`) | Codex / fallback |
|---|---|---|---|
| Find site / cloud ID | Pass the site hostname (e.g. `hongkongtv.atlassian.net`) as `cloudId`; or `getAccessibleAtlassianResources` | Cloud ID `3819c19c-0ec7-4434-a6d6-63c237693b8f` | Whatever Atlassian MCP is configured; else REST `https://<site>/wiki/api/v2` with a token from an env var (never paste tokens into files or chat) |
| Read a page | `getConfluenceContent` (`content_format: html`, `detail: full`; returns `snapshotToken`) | `getConfluencePage` (`contentFormat="html"`) | `GET /pages/{id}?body-format=storage` |
| Child pages | `searchConfluence` with CQL `ancestor = <id>` | `searchConfluenceUsingCql` / `getConfluencePageDescendants` | CQL search endpoint |
| Comments | `discover` → "get confluence page comments" → `executeRead` | `getConfluencePageInlineComments` / `getConfluencePageFooterComments` | REST comments endpoints |
| Search | `searchConfluence` (CQL) | `searchConfluenceUsingCql` | CQL search endpoint |
| Create page | `createConfluenceContent` | `createConfluencePage` | `POST /pages` |
| Edit page | `updateConfluenceContent` with `edits` (`replaceNode` / `insertNodeAfter` / `deleteNode` by `data-local-id`, plus the latest `snapshotToken`) | `updateConfluencePage` (full body; re-read immediately before) | `PUT /pages/{id}` with an incremented version (full body) |
| Upload image / file | `discover` → `executeWrite` `createConfluenceAttachment` (`contentId`, `localFilePath`, `fileSize`) → run the returned `uploadCommand` in the shell → read the media id from the response | Not available in most setups → placeholder + manual attach list | `POST /wiki/rest/api/content/{id}/child/attachment` |

## Jira

| Capability | Claude (Atlassian connector) | Hermes | Codex / fallback |
|---|---|---|---|
| Read issue | `getJiraIssue` | `getJiraIssue` | REST `GET /rest/api/3/issue/{key}` |
| Search | `searchJiraIssuesUsingJql` | `searchJiraIssuesUsingJql` | REST search |
| Create issue | `createJiraIssue` | `createJiraIssue` if exposed (check the tool list) | REST `POST /rest/api/3/issue` |
| Edit issue / fields | `editJiraIssue` | `editJiraIssue` if exposed | REST `PUT /rest/api/3/issue/{key}` |
| Account ID lookup | `discover` → "lookup jira account id" → `executeRead` | `lookupJiraAccountId` if exposed | REST user search |
| Project versions (fixVersion, release date) | `discover` → "get jira project versions" → `executeRead` | `getJiraProjectVersions` if exposed | REST `GET /rest/api/3/project/{key}/versions` |

Custom field values appear only with a full view or explicit `fields`; IDs such as `customfield_11563` are site-specific.

## Other connectors used by these skills

| Capability | Claude | Hermes | Codex / fallback |
|---|---|---|---|
| Figma frames and screenshots | Figma connector (`get_metadata`, `get_screenshot`, `get_design_context`) | Figma MCP (`figma-official`), local bridge on `127.0.0.1:3845`; may be down or token-expired | Ask the user for exported frames |
| Google Drive / Sheets (copytable) | Drive connector `create_file` (new file); Sheets connector to edit an existing sheet | Drive tools if configured | Deliver the `.xlsx` and ask the user to upload it |
| Slack (consult threads, follow-up) | Slack connector (`slack_send_message`, `slack_read_thread`, file upload) | Slack tools + `slack_helper.py` (A2A envelope) | Draft the message for the user to post |
| Session / chat history | Not available; ask the user to paste or link | `session_search` | Ask the user |

## Rules that apply in every runtime

- **Ask before any outward action.** Posting to Slack, creating Jira issues, and creating or editing Confluence pages all need the user's explicit yes in chat, unless the user's request already said to do exactly that.
- **Credentials:** never write tokens, passwords or test-account secrets into a page, file or message.
- **Bot consult legs** (`prd-backend-impact-consult`): App Team Agent rejects messages without the Hermes A2A envelope. From Claude or Codex, either run only the TeamEcom leg (if the user approves posting) and mark the app leg "not run", or ask the user to run the consult in Hermes.
- **Large results** may be saved to a file instead of returned inline. Parse the file with a script instead of re-requesting.
