# Preamble: brainstorming agent

Operational rules for vault work. Your system prompt carries the vault's vocabulary, philosophy, and your role; this file adds the mechanics.

## Access

Use MCPVault tools for every vault operation; tool names come from MCP discovery. Never raw filesystem operations — MCPVault handles frontmatter safety and path validation that raw writes don't.

## Writing

Git is catching errors; wrong edits are reversible. Don't stage, don't make `.bak` files, don't hedge.

When adding to a library item, use the filenames the item already has. If it has `outline.md`, extend it — don't create `outline-additions.md` alongside. If the structure is unfamiliar, read the item's contents first.

Wikilinks use `[[note-name]]`. When writing a new note, also go add incoming links from existing notes that should reference it. Backlinks appear automatically; forward links are manual.

## Extraction

When something in conversation becomes portable — has one honest title — extract it to `10-atoms/` and link back from where it came from. Applies to instructive failures: "Why X doesn't work for Y" is a valid atom. When an idea isn't yet portable, don't force it.

Extraction is a write to `10-atoms/` plus an incoming link from the originating context (library item, journal entry, thread).

## Tags and frontmatter

Tags: for intent or status (`#seedling`, `#to-review`, `#idea`), not topic. Topic goes in links and maps.

Frontmatter on library items: `deadline:`, `status: active | dormant | finished | reference`, `context: work | personal`. These exist to be queryable by Dataview in maps like `active.md`. Don't add frontmatter that nothing queries.

## When to load each module

Load a module when a task needs depth. Most operations are covered above.

**Working inside `80-claude/`** (memory, threads, scratch, or folder structural rules) → `claude-space.md`.

**Non-trivial extraction, linking decision, or handling a note that crosses categories** → `operations.md`.

**Creating a new library item, designing map structure, or working with a folder not covered above** → `folders.md`.

**Naming an atom, map, library item, or journal entry where convention isn't obvious** → `naming.md`.

**Structural question about the vault itself** (why a folder exists, whether to add one) → `99-meta/vault-structure.md` directly. Not part of this skill.

## Hooks

SessionStart injects `80-claude/memory.md` into context before the conversation begins. Stop prompts at session end to check for open threads. Both are wired to you specifically; other agents don't receive them. Details in `claude-space.md`.
