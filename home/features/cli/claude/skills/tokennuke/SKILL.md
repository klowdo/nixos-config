---
name: tokennuke
description: Index and search codebases using tokennuke's semantic code intelligence. Use when the user wants to index a project, search for symbols, trace call graphs, analyze dependencies, or review changes across a codebase.
user-invocable: true
allowed-tools: mcp__tokennuke__index_folder, mcp__tokennuke__index_repo, mcp__tokennuke__list_repos, mcp__tokennuke__invalidate_cache, mcp__tokennuke__file_tree, mcp__tokennuke__file_outline, mcp__tokennuke__repo_outline, mcp__tokennuke__get_symbol, mcp__tokennuke__get_symbols, mcp__tokennuke__search_symbols, mcp__tokennuke__search_text, mcp__tokennuke__get_callees, mcp__tokennuke__get_callers, mcp__tokennuke__diff_symbols, mcp__tokennuke__dependency_map
---

# TokenNuke Code Intelligence

Index the current project and answer the user's query using tokennuke's MCP tools.

## Steps

1. Check if the current project is already indexed with `list_repos`
2. If not indexed, use `index_folder` on the current working directory
3. Use the appropriate tool for the user's request:
   - Symbol lookup: `get_symbol` / `get_symbols`
   - Semantic search: `search_symbols` (hybrid FTS5 + vector RRF)
   - Text search: `search_text`
   - Code structure: `file_tree` / `file_outline` / `repo_outline`
   - Call graph: `get_callers` / `get_callees`
   - Dependencies: `dependency_map`
   - Change review: `diff_symbols`
4. Present results with file paths and relevant context
