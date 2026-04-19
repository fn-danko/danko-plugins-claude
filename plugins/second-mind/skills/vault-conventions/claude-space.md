# Claude's space: mechanics

Mechanics for working in `80-claude/`. Your system prompt covers what the folder is for and the philosophy around it; this file covers how to operate inside it.

## Layout

```
80-claude/
  memory.md          entry point
  memories/          split-out files when memory.md gets long
  scratch/           ephemeral working files
  threads/           open threads not yet homed
```

## memory.md and memories/

Memory is loaded at session start via MCPVault — treat it as ambient context, not as something to retrieve mid-session.

**What belongs.** Stable, cross-cutting facts about the user, their context, their preferences. The test from the agent prompt applies: if a fact only matters when working on X, it belongs with X, not in memory. One additional heuristic — if updating this fact every few months would feel churny, it's probably not memory material. Memory is for things that are durable by nature.

**Proposing an update.** Don't write silently. When something crosses the bar, say so in the conversation — *"This feels like it belongs in memory — want me to add it?"* or similar. Wait for confirmation, then write.

When you write:

- Prefer appending over rewriting. Memory accretes.
- Match the voice of what's already there — memory reads as a single document, not a changelog.
- If the new fact contradicts something existing, name the conflict before resolving. Don't silently overwrite.

**Splitting into memories/.** Friction-driven. When memory.md is long enough that skimming on session load feels heavy, propose splitting stable chunks into topic files (`memories/work-regesta.md`, `memories/collaboration-patterns.md`). memory.md then holds a linked summary pointing at each chunk. Don't pre-split; the file tells you when it's ready. Splitting is also a proposal, not a silent act.

## threads/

Open thinking worth resuming that doesn't yet have a home.

**What earns a thread.** Two shapes:

- An unresolved question the conversation was actively working on, that didn't resolve before the session ended.
- A decision about to be made, and not made.

Not threads:

- Concluded conversations, even substantive ones. Conclusions graduate to atoms or library items, not threads.
- Ideas you noticed but didn't develop — those are extraction candidates, not threads.
- Session summaries — the user has the transcript.
- Running to-do lists — those go in memory or a library item, not threads.

When in doubt, no thread.

**Writing a thread.** Kebab-case filename shaped around the question or decision: `should-matrix-bot-use-vivy-as-backbone.md`, `naming-convention-for-decision-logs.md`. Body covers what the question is, what's been considered, what's outstanding. Terse — it's a note-to-self for resumption, not an argument. Link from wherever the thread originated (the adjacent library item, the relevant map).

**Graduating a thread.** The moment a thread acquires a home, it leaves `threads/`:

- Becomes an atom → move content to `10-atoms/`, link from where it originated, delete the thread file.
- Joins a library item → fold in, delete the thread file.
- Question resolves without producing a durable artifact → delete the thread file. Resolution is enough.

`threads/` accumulating is a signal that threads aren't graduating, not that the folder needs more structure. If it gets heavy, review — some of what's there is probably ready to move or be deleted.

## scratch/

Ephemeral working files. Intermediate thinking, test notes, anything that would clutter the main vault if it lived there.

- Create and delete freely. No discipline about what goes here.
- Nothing else in the vault links into scratch. A link from elsewhere would silently promote the content — atoms, library items, and maps are where permanent content lives.
- If something in scratch turns out to matter, move it to its real home (atom, library item, thread) and delete the scratch file.

Naming inside scratch doesn't need a convention; pick something that makes sense during the session.

## When memory loads and when threads get written

**Memory loads at session start.** On startup, after `/clear`, and after auto-compaction — whenever context has been lost — the SessionStart hook nudges you to read `memory.md` via MCPVault. On resume the previous transcript still carries what you read, so nothing re-injects. Treat memory as ambient, not as something retrieved mid-session. The hook is wired to you specifically; other agents don't receive it and don't read `80-claude/`.

**Threads are written at session end, prompt-driven.** When the user signals they're wrapping up or asks explicitly to save a thread, apply the bar above. Most sessions end without a thread — that's the default. The user can ask for a thread at any point, not only at the end.
