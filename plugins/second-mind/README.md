# second-mind

Claude Code plugin pairing a brainstorming agent with a vault-conventions
skill, so Claude can act as a thinking partner that shares an Obsidian
vault with the user through the obsidian MCP server.

## Contents

```
.claude-plugin/
  plugin.json
agents/
  brainstorm.md                    system prompt (carries identity marker)
skills/
  vault-conventions/
    SKILL.md                        router (brainstorming vs generic preamble)
    preamble-brainstorming.md       entry point: brainstorming agent
    preamble-generic.md             entry point: any other agent
    claude-space.md                 brainstorming-only: memory/threads/scratch
    operations.md                   shared: extraction, linking, restructuring
    folders.md                      shared: per-folder reference
    naming.md                       shared: naming conventions
hooks/
  hooks.json                        event registrations
  NOTES.md                          implementation notes, trade-offs,
                                    known unknowns
  scripts/
    _scope.sh                       shared: brainstorm-agent scoping
    on-session-start.sh             SessionStart handler
```

## Dependencies

- **obsidian MCP server** — agent-side vault reads and writes go through
  this server (the plugin has been developed against
  [`@bitbonsai/mcpvault`](https://github.com/bitbonsai/mcpvault), but any
  Obsidian-flavored MCP server with equivalent tools should work). Never
  raw filesystem from the agent. If the server is not available, the
  skill tells the user and stops.

## Configuration

### `SECOND_MIND_VAULT_PATH` (recommended)

Absolute path to the Obsidian vault root. Set this in your shell rc so
it's present for every Claude Code session. The value should not have
a trailing slash.

```bash
# bash / zsh
export SECOND_MIND_VAULT_PATH=/absolute/path/to/your/vault
```

```fish
set -Ux SECOND_MIND_VAULT_PATH /absolute/path/to/your/vault
```

**With the variable set** (preferred path):

- SessionStart reads `$SECOND_MIND_VAULT_PATH/80-claude/memory.md`
  from the filesystem and injects the contents directly into the
  agent's context at session start.
- The agent sees memory as ambient context with zero tool calls — the
  "memory is present, not retrieved" frame from the agent prompt holds
  cleanly.

**Without it** (fallback path):

- SessionStart emits a nudge asking the agent to read memory via the
  obsidian MCP server on its first turn.
- Memory still loads, but the agent has to ToolSearch → load the
  server's tools → call `read_note` before replying.
- The tool call shows up in the transcript, which makes the frame
  approximate rather than exact.

**If the variable is set but the memory file is missing**, the hook
falls back to the nudge and logs the mismatch both to stderr and to:

```
${CLAUDE_PLUGIN_DATA}/diagnostics.log
```

Check that file if the preferred path doesn't seem to be firing —
usually a typo in the path or a vault that doesn't yet have a
`80-claude/memory.md`.

### `SECOND_MIND_DEBUG` (optional)

Set `SECOND_MIND_DEBUG=1` to log raw SessionStart input JSON (one
object per line) to `${CLAUDE_PLUGIN_DATA}/session-start.log`. Useful
when diagnosing per-event schema questions — see `hooks/NOTES.md` for
context. Leave unset in normal use.

## Identity marker

The skill routes by greping the agent's system prompt for the literal
string `identity: brainstorming-agent`. The marker is intentionally
decoupled from the agent's Claude Code name (`brainstorm`), so renaming
the agent does not break the router.

**If you ever change the marker string, update it in both places:**

1. `agents/brainstorm.md` — first body line (below the frontmatter).
   Must live in the body, not the frontmatter; Claude Code strips
   frontmatter before the system prompt reaches the model.
2. `skills/vault-conventions/SKILL.md` — the router `if` line.

## Design decisions (settled)

- **One skill, two preambles.** The router in `SKILL.md` branches on
  the identity marker in the system prompt.
- **`80-claude/` is brainstorming-only.** Generic agents never read or
  write it.
- **Generic agents** match the session's CWD basename against
  `40-library/` on start; one match confirms a library link.
- **Git is the error backstop.** No staging, no `.bak` files.
- **Hooks fire only for the brainstorming agent.** Other agents rely on
  `--resume` for continuity.

## Open work

- Exercise the untested rows in `TESTING.md` (scope-fallback,
  `/clear` and auto-compact re-fires, resume no-op, non-brainstorm
  scoping, filesystem memory injection once `80-claude/memory.md`
  exists).
- Extend SessionStart to also list `80-claude/threads/` contents
  alongside memory. Design sketch in `hooks/NOTES.md` under
  "Planned".

## Install

From this marketplace:

```
/plugin marketplace add fn-danko/danko-plugins
/plugin install second-mind@danko-plugins
```

## License

MIT. See the `LICENSE` file at the root of the marketplace repo.
