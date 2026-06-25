No comments in code(functions) functions docs are accepted. use clean code to emphasize intent
Never add Co-Authored-By or similar attribution lines to commits

## CodeGraph

CodeGraph builds semantic knowledge graphs for faster code exploration.

### If .codegraph/ exists in the project

**ALWAYS prefer codegraph over grep/glob.** Reach for codegraph tools FIRST for any code search, symbol lookup, or call-flow question. grep/glob are last resort, only when codegraph cannot answer (e.g. non-code text, config values).

**In main sessions, use the lightweight codegraph tools directly** (search/callers/callees/impact/node). **Only `codegraph_explore` is forbidden in main sessions** — it returns large source volumes that blow context; delegate it to an Explore agent.

**When spawning Explore agents**, include:
> This project has CodeGraph initialized (.codegraph/ exists). Use codegraph tools as PRIMARY.

**Main session lightweight tools only:**
- codegraph_search: Find symbols by name
- codegraph_callers/codegraph_callees: Trace call flow
- codegraph_impact: Check affected code before editing
- codegraph_node: Get symbol details

### If .codegraph/ does NOT exist

Fall back to tokennuke MCP tools for code indexing, symbol search, call graph tracing, and codebase exploration. Use grep/glob as last resort

@RTK.md
