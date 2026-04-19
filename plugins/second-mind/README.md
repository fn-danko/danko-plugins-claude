# second-mind

Claude Code plugin pairing a brainstorming agent with a vault-conventions
skill, so Claude can act as a thinking partner that shares an Obsidian
vault with the user through MCPVault.

## Contents

```
.claude-plugin/
  plugin.json
agents/
  brainstorming-agent.md           system prompt (identity: brainstorming-agent)
skills/
  vault-conventions/
    SKILL.md                        router (brainstorming vs generic preamble)
    preamble-brainstorming.md       entry point: brainstorming-agent
    preamble-generic.md             entry point: any other agent
    claude-space.md                 brainstorming-only: memory/threads/scratch
    operations.md                   shared: extraction, linking, restructuring
    folders.md                      shared: per-folder reference
    naming.md                       shared: naming conventions
hooks/
  NOTES.md                          design spec for SessionStart + Stop hooks
                                    (not yet implemented)
```

## Dependencies

- **MCPVault** — all vault reads and writes go through MCPVault, never raw
  filesystem. If MCPVault is not available, the skill tells the user and
  stops.

## Design decisions (settled)

- **One skill, two preambles.** The router in `SKILL.md` branches on
  `identity: brainstorming-agent` in the system prompt.
- **`80-claude/` is brainstorming-only.** Generic agents never read or
  write it.
- **Generic agents** match the session's CWD basename against
  `40-library/` on start; one match confirms a library link.
- **Git is the error backstop.** No staging, no `.bak` files.
- **Hooks fire only for the brainstorming agent.** Other agents rely on
  `--resume` for continuity.

## Open work

- SessionStart and Stop hooks — see `hooks/NOTES.md`.

## Install

From this marketplace:

```
/plugin marketplace add fn-danko/danko-plugins
/plugin install second-mind@danko-plugins
```
