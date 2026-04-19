# Hooks — first iteration

One hook ships, `SessionStart`. `Stop` was considered and deliberately
dropped (see bottom of this file).

## Scoping

Both the hook script and any future additions use `scripts/_scope.sh`.
Two-step check:

1. `agent_id` / `agent_type` in the hook input JSON. These are
   documented for SubagentStart / SubagentStop; not reliably populated
   at SessionStart for main-session `--agent` invocation.
2. Fallback: grep the transcript file for the `identity:
   brainstorming-agent` marker the agent's system prompt carries.

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

The injected `additionalContext` tells the agent to read
`80-claude/memory.md` via MCPVault before the first user message and to
internalize it silently. Deliberate choice for this iteration: defer
the vault read to the agent, so the plugin does not need to know the
vault path (MCPVault already holds that configuration).

Trade-off: the read shows up as a tool call in the transcript, so the
"memory is present, not retrieved" frame from the system prompt is
approximate. Revisit if it feels wrong in real use.

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
