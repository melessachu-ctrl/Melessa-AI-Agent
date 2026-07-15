---
name: figma-mcp-server-guide
description: Guides Figma MCP server usage in Cursor—setup, authentication, tool selection, prompting, asset handling, and rate-limit awareness. Use when working with Figma from the IDE, implementing UI from Figma links, Code Connect, use_figma canvas writes, or when the user mentions Figma MCP, get_design_context, or mcp.figma.com.
---

# Figma MCP Server Guide (Cursor)

Concise operational guide aligned with the official [Figma MCP Server Guide](https://github.com/figma/mcp-server-guide) repository. For the full tool catalog and extended examples, see [reference.md](reference.md) and [Figma developer docs](https://developers.figma.com/docs/figma-mcp-server/).

## Cursor setup

**Recommended:** In Agent chat, run:

```text
/add-plugin figma
```

This adds MCP configuration, bundled workflows, and asset-handling rules.

**Manual MCP:** Cursor → Settings → MCP → add global server with Streamable HTTP:

```json
{
  "mcpServers": {
    "figma": {
      "url": "https://mcp.figma.com/mcp"
    }
  }
}
```

Confirm tools are available (e.g. mention `get_design_context` in chat). See [Cursor MCP documentation](https://docs.cursor.com/context/model-context-protocol).

## Giving the agent a target

1. User copies a **frame or layer link** from Figma (`figma.com/design/...?node-id=...`).
2. The agent does **not** browse the URL; it uses **`fileKey`** and **`node-id`** (normalize `node-id`: replace `-` with `:` in the value passed to tools if the server expects that format—follow the MCP tool schema).
3. For **desktop MCP** (`figma-desktop`), selection in the open file may apply without a URL; remote `https://mcp.figma.com/mcp` requires a link for context.

## Tool selection (quick)

| Goal | Primary tools |
|------|----------------|
| Code from design | `get_design_context` (+ `get_screenshot` for fidelity); split large frames |
| Tokens / styles | `get_variable_defs` |
| Huge / heavy nodes | `get_metadata` first, then `get_design_context` on children |
| Code ↔ Figma mapping | `get_code_connect_map`, `get_code_connect_suggestions`, `send_code_connect_mappings`, `add_code_connect_map` |
| Find library assets | `search_design_system` |
| Write / edit canvas | `use_figma` (pair with a dedicated `figma-use` skill if present) |
| New file in drafts | `create_new_file` |
| Agent rule files for DS | `create_design_system_rules` |
| FigJam structure | `get_figjam`; diagrams | `generate_diagram` |
| Auth / plan check | `whoami` (remote) |

Default output of `get_design_context` is **React + Tailwind**; translate to the project stack via prompts.

## Implementation flow (code in repo)

Do not skip visual verification when implementing UI:

1. `get_design_context` for the exact node(s).
2. If truncated or too large: `get_metadata`, then fetch smaller subtrees.
3. `get_screenshot` unless token limits forbid it.
4. Map to project tokens/components; avoid inventing icon packages if assets come from MCP.
5. Re-check against screenshot for parity.

## Asset rules (from Figma MCP)

- If the server returns **localhost** URLs for images or SVGs, **use those sources directly**.
- **Do not** add new icon packages when Figma provides assets.
- **Do not** use placeholders when a real asset URL is provided.

## Rate limits

Read-heavy tools are rate-limited. **Starter / View / Collab** seats may be capped (e.g. very low monthly read calls); **Dev / Full** seats on paid plans use per-minute limits similar to Figma REST Tier 1. Some write tools are exempt. Treat read calls as precious: batch intent, use `get_metadata` to narrow scope, and avoid redundant calls.

## Prompting

- State framework and file targets explicitly (e.g. “Vue”, “put in `src/features/...`”, “use existing `Button` from `src/components/ui`”).
- For token-aware code: ask for variable names and values in the selection.
- Break large screens into components and iterate.

## Related upstream skills

The [mcp-server-guide repo](https://github.com/figma/mcp-server-guide) ships granular skills under `skills/` (e.g. implement design, Code Connect, `figma-use`). If those folders are copied into `~/.cursor/skills/`, prefer the specialized skill for that task; use this skill as the **overview and routing** layer.

## Legal / product

Using the Figma MCP server is subject to the [Figma Developer Terms](https://www.figma.com/legal/developer-terms/). Features may be Beta; write pricing may change after beta.
