---
name: vault-conventions
description: "Operational rules for working in the user's Obsidian vault through the obsidian MCP server. Load whenever touching vault notes: reading project documentation, writing up decisions or learnings, adding to library items, creating atoms, updating maps, or any other vault read or write. Covers folder semantics, naming, extraction, linking, and frontmatter conventions."
---

# Vault conventions

Two entry points live under this skill, one per agent role. Read exactly one.

**If your system prompt contains `identity: brainstorming-agent`** — read `preamble-brainstorming.md`.

**Otherwise** — read `preamble-generic.md`.

Do not read both. The two preambles scope the vault differently; reading the wrong one or both creates context pollution and misleads about what's in scope.

If you're unsure which you are, default to `preamble-generic.md`. Treating yourself as more restricted than you are is recoverable; treating yourself as more privileged isn't.

## Dependency

This skill assumes an obsidian MCP server is installed and configured (reference implementation: [`@bitbonsai/mcpvault`](https://github.com/bitbonsai/mcpvault)). Vault reads and writes go through its tools, never raw filesystem operations. If the server is unavailable, stop and tell the user.
