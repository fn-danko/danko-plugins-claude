# Hooks — first iteration

One hook ships, `SessionStart`. `Stop` was considered and deliberately
dropped (see bottom of this file).

## Scoping

Both the hook script and any future additions use `scripts/_scope.sh`.
Two-step check:

1. `agent_id` / `agent_type` in the hook input JSON. `agent_type` is
   populated at SessionStart for main-session `--agent` as
   `<plugin>:<agent>` (e.g. `second-mind:brainstorm`); the scope helper
   accepts both the namespaced and the bare form. `agent_id` is absent.
2. Fallback: grep the transcript file for the `identity:
   brainstorming-agent` marker the agent's system prompt carries.
   Still there as a safety net for edge cases where `agent_type` is
   unexpectedly missing.

Any other session no-ops silently.

## SessionStart

Script: `scripts/on-session-start.sh`.

Fires when the conversation context has been lost or never existed:

- `startup` — fresh session
- `clear` — `/clear` issued mid-session
- `compact` — auto-compaction dropped older turns

On `resume` we do nothing — the previous transcript still carries
whatever the agent read last session, so re-injection would be
redundant.

### Memory read strategy

Two paths, decided at hook runtime.

**Preferred: filesystem read.** If `SECOND_MIND_VAULT_PATH` is set and
`$vault/80-claude/memory.md` exists, the hook reads it directly and
emits the contents as `additionalContext`. The agent sees memory as
ambient context on startup with no tool call, matching the "memory is
present, not retrieved" frame cleanly.

**Fallback: nudge.** If the env var is unset or the file is missing,
the hook emits an instruction asking the agent to read `memory.md` via
the obsidian MCP server on its first turn, plus a note to the user
suggesting they set the env var. The fallback is lossier — the read
shows up as a tool call in the transcript and the agent has to
ToolSearch/load the obsidian MCP server's tools before it can fetch — but keeps the plugin
usable before the env var is set.

The plugin deliberately does not try to share a vault-path source with
the MCP server. `@bitbonsai/mcpvault` reads its vault path exclusively
from a CLI positional argument (no env var, no config file), so any
"single source" story would require the user to refactor their MCP
config, which is outside the plugin's scope.

### Output envelope

SessionStart requires the stdout JSON wrapped in `hookSpecificOutput`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "..."
  }
}
```

Top-level `additionalContext` is silently ignored — the harness falls
back to treating the raw stdout as plain text, so the literal JSON
string leaks into context. Verified empirically during first-run
debugging.

## Why Stop was dropped

The `Stop` hook in Claude Code fires after **every** agent turn, not at
session end. The original design — "nudge the agent to check for open
threads at session end" — does not map onto it:

- A once-per-session guard would fire on the first turn boundary, when
  there is nothing to check.
- A no-guard version would nudge on every turn, polluting context and
  burning tokens, and the agent cannot tell whether a given turn will
  be its last.
- `SessionEnd` fires at actual termination but cannot give the agent
  another turn, so it cannot drive thread-writing.

Instead, thread-writing is prompt-driven. The agent's system prompt
and `claude-space.md` instruct the agent to check for open threads
when the user signals end-of-session, or when the user explicitly
asks to save a thread.

## Planned — list open threads alongside memory

Alongside the memory inject, the SessionStart hook should also list
the contents of `$vault/80-claude/threads/` and include the filenames
(or a short index) in `additionalContext`. Rationale: threads are the
unresolved-work ledger; knowing what's open at session start is the
natural counterpart to knowing what's in memory.

Design sketch for the next iteration:

- Same env-var gate (`SECOND_MIND_VAULT_PATH`). If set, list
  `*.md` under `threads/`; if unset, add a nudge asking the agent to
  list threads via the obsidian MCP server on its first turn.
- Empty `threads/` → omit the section rather than say "no threads";
  keep the injection terse.
- Filenames only, not contents. Opening a thread is a deliberate act,
  not something the hook should pre-load.

## Known unknowns

- `agent_type` **is** populated at SessionStart for main-session
  `--agent`, as `<plugin>:<agent>` (e.g. `second-mind:brainstorm`).
  `agent_id` is absent. The scope check accepts either the bare or the
  namespaced form. Confirmed via SECOND_MIND_DEBUG capture on
  2026-04-19.
- Exact format of the input JSON for each event is not published in
  the official hooks docs — only a single generic "common fields"
  example covering all events. Community sources (base76 reference,
  FrancisBourre gist) describe `source` on SessionStart and
  `stop_hook_active` on Stop; we rely on `source` here.
