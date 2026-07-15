# Figma MCP — reference

## Canonical sources

- Repository: [figma/mcp-server-guide](https://github.com/figma/mcp-server-guide)
- Developer documentation: [Figma MCP Server](https://developers.figma.com/docs/figma-mcp-server/)
- Code Connect: [Figma Help Center](https://help.figma.com/hc/en-us/articles/23920389749655-Code-Connect)

## Tools (summary)

- **`get_design_context`** — Structured design for selection; default React + Tailwind; customize via prompts.
- **`get_screenshot`** — Raster reference for layout fidelity.
- **`get_variable_defs`** — Variables and styles (color, spacing, type).
- **`get_metadata`** — XML outline (ids, names, geometry); use before drilling into huge trees.
- **`get_code_connect_map` / `add_code_connect_map`** — Existing mappings.
- **`get_code_connect_suggestions` / `send_code_connect_mappings`** — Suggest and confirm mappings.
- **`generate_figma_design`** — Web → Figma (client support varies; remote).
- **`create_design_system_rules`** — Generate agent rule content for design systems.
- **`get_figjam`** — FigJam metadata (with screenshots).
- **`generate_diagram`** — FigJam diagrams from Mermaid-style intent.
- **`whoami`** — Authenticated user and seat info (remote).
- **`use_figma`** — General write API to Figma/FigJam files (remote); use with care and a focused skill.
- **`search_design_system`** — Search connected libraries for components, variables, styles.
- **`create_new_file`** — New Design or FigJam file in drafts.

Exact parameter names and shapes **vary by MCP client**; always follow the live tool schema in the IDE.

## Figma file hygiene (improves MCP output)

- Reuse via **components**; **variables** for spacing, color, radius, type.
- **Semantic layer names**; **Auto layout** for responsive intent.
- Annotations and dev resources for behavior notes.

## Large selections

Prefer smaller frames or components; large selections increase failures, truncation, and token use.
