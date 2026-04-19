# Hooks — design notes (not yet implemented)

Two hooks, both firing only for the brainstorming agent. Other agents use
`--resume` for continuity and do not need these.

## SessionStart

Fires when a brainstorming-agent session starts. Injects the contents of
`80-claude/memory.md` (via MCPVault) into the agent's context before the
first user message.

Rationale: memory must be present, not retrieved. The agent should speak
from the frame ("given you prefer prose over bullets") rather than
about it ("I see from my memory that…"). See
`skills/vault-conventions/claude-space.md`.

## Stop

Fires at session end. Prompts the agent to scan the conversation for
open threads worth writing to `80-claude/threads/`.

Bar for writing a thread (from `claude-space.md`):

- Unresolved question the conversation was actively working on, or
- A decision about to be made and not made.

Default is no thread. Concluded conversations do not earn one.

## Implementation sketch

`hooks/hooks.json` will declare the two events; shell scripts under
`hooks/scripts/` do the work and invoke MCPVault. The matcher must scope
each hook to the brainstorming agent only — likely by inspecting the
agent identity frontmatter or a dedicated env flag. Exact mechanism to
be decided together.
