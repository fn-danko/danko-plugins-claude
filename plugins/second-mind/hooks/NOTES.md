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

### Threads listing

Alongside memory, the hook surfaces `$vault/80-claude/threads/` as an
index of unresolved work. Threads are the open-question / pending-
decision ledger (see `claude-space.md`); knowing what's open at
session start is the natural counterpart to knowing what's in memory.

**Filesystem path.** When the vault env var is set and `threads/`
exists, the hook lists the `*.md` filenames (lexical sort, `.md`
kept) and appends an `Open threads in …` section to
`additionalContext`. Filenames only — never contents. Opening a
thread is a deliberate act; the hook's job is to keep the ledger
visible, not to pre-load it.

**Empty or missing `threads/`.** The section is omitted silently.
No "no open threads" noise. Unlike a missing `memory.md` (which
triggers the path-mismatch diagnostic), an absent `threads/` is a
legitimate state — new vaults and vaults that simply haven't
accumulated open questions are normal.

**Nudge fallback.** When the vault env var is unset, or when it's
set but both `memory.md` and `threads/` are missing, the hook emits
a parallel nudge telling the agent to list `threads/` via the
obsidian MCP server (directory listing, not file contents). The two
reads — memory and threads — are independent, so a partial vault
(e.g. `threads/` present but `memory.md` missing) still uses the
disk listing for whatever is readable.

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
