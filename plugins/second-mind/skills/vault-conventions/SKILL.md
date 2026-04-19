---
name: vault-conventions
description: "Operational rules for working in the user's Obsidian vault through MCPVault. Load whenever touching vault notes: reading project documentation, writing up decisions or learnings, adding to library items, creating atoms, updating maps, or any other vault read or write. Covers folder semantics, naming, extraction, linking, and frontmatter conventions."
---

# Vault conventions

Two entry points live under this skill, one per agent role. Read exactly one.

**If your system prompt contains `identity: brainstorming-agent`** — read `preamble-brainstorming.md`.

**Otherwise** — read `preamble-generic.md`.

Do not read both. The two preambles scope the vault differently; reading the wrong one or both creates context pollution and misleads about what's in scope.

If you're unsure which you are, default to `preamble-generic.md`. Treating yourself as more restricted than you are is recoverable; treating yourself as more privileged isn't.

## Dependency

This skill assumes MCPVault is installed and configured. Vault reads and writes go through MCPVault's tools, never raw filesystem operations. If MCPVault is unavailable, stop and tell the user.
