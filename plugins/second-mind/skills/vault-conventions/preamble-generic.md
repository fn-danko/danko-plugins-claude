# Preamble: generic agent

Operational rules for vault work from any agent that isn't the brainstorming agent.

## The vault

Obsidian vault, structured by relationship to content, not by topic. The folders you work in:

- `10-atoms/` — reusable one-idea notes, flat
- `20-maps/` — navigation hubs
- `30-journal/` — daily and meeting notes
- `40-library/` — folders per body of work (where project documentation lives)

Atoms are portable one-idea notes. Library items are folders holding work the user engages with across time. These are the two note shapes that matter for most vault work.

**Never write:** `80-claude/`, `90-graveyard/`, `99-meta/`, `00-inbox/`, `assets/`. These touch archival, structural, capture-mode, and attachment decisions that belong to the user. Don't read from `80-claude/` either — its contents are calibrated to a different agent and will mislead you.

## Session startup

When a coding session starts, link it to a vault project:

1. Take the basename of your current working directory (the folder name, not the full path).
2. Check `40-library/` for an item with exactly that name.
3. **One match** — tell the user: *"Linked to `40-library/<name>/`."* They can correct if wrong.
4. **No match** — tell the user there's no linked vault project, and ask whether to create an empty `40-library/<basename>/`.
5. **Multiple matches** — surface the situation and let the user pick.

The linked library item is where project documentation, specs, and decisions for this session live. If there's no link, operate without one — don't guess a match.

## Access

Use the obsidian MCP server's tools for every vault operation; tool names come from MCP discovery. Never raw filesystem operations — the server handles frontmatter safety and path validation that raw writes don't.

## Reads

Anywhere except `80-claude/`. Read the linked library item freely to inform the work; fall back to the obsidian MCP server's search when you don't know a filename. Expect to read library items regularly to pick up specs, architecture notes, and decisions.

## Writes

Two tiers.

**Confident** — inside the linked library item:

- Add or edit content, update frontmatter, restructure files as the work calls for it.
- Keep the user informed about changes. A brief summary in the reply ("updated `architecture.md` to note the retry-handling correction") is enough. No silent restructuring.
- Use the item's existing filenames. If it has `outline.md`, extend it — don't create `outline-additions.md` alongside. If the structure is unfamiliar, read the item's contents first.

**Ask first** — propose the change and wait:

- Any other library item (`40-library/<different-project>/`). Describe the edit; the user decides whether you make it or they do.
- New atoms in `10-atoms/` when something from the session generalises into a portable idea. Describe the atom — proposed title, one-line summary, where it came from — and wait for OK before writing.
- Edits or additions in `20-maps/` and `30-journal/`.

"Ask" means propose and wait. Not "mention and proceed unless stopped."

New folders under `40-library/` come up only through the startup link-creation flow or explicit user request.

Git is catching errors; wrong edits inside the linked item are reversible. Don't stage, don't make `.bak` files.

Wikilinks use `[[note-name]]`. If a referenced note doesn't exist, mention it — don't silently create it.

## When to load each module

Most tasks won't need a module. Load when depth is needed.

**Non-trivial write — a new section in the linked library item, updating multiple notes together, restructuring content within an item** → `operations.md`.

**Working with a folder not covered above, or unsure whether a note belongs in one place vs another** → `folders.md`.

**Writing a new note and unsure about naming** → `naming.md`.

## Brainstorming redirect

If the user describes work that sounds like brainstorming — specifying, exploring, pressure-testing — point them at the brainstorming agent. That's a different session mode.
