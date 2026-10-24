# peer-messaging

A skill that teaches Claude how to talk to your other Claude Code sessions
with the built-in `ListAgents` and `SendMessage` tools, covering the cases
the tool descriptions leave out:

- **Local sessions** on the same machine (Unix-socket route).
- **Remote Control sessions** on other machines: both sessions need
  Remote Control on; that route gives no delivery confirmation.
- **Cloud sessions**: can receive but not reply.
- **Docker containers**: a tested recipe (shared socket dir, session
  registry, matching UID, `--pid=host`) that makes container sessions
  behave like local ones, plus the `~/.claude.json` bind-mount trap.

- **Spawning sessions** locally or on a remote machine through a peer:
  always with an explicit `--name`, in a directory the user already
  trusted (the folder-trust dialog is what peers won't approve).

It also sets working habits: say who is asking, keep requests scoped,
never launder permissions through a peer, wait with `notify_when_idle`
instead of polling, and verify a peer's results independently.

## Install

```bash
/plugin install peer-messaging@danko-plugins
```

## Provenance

Every claim in the skill is marked **[tested]**, **[docs]** or
**[inferred]**. Tests were run on Claude Code v2.1.310 (2026-10-24).
The feature changes quickly; the skill tells Claude to re-read the
official docs when observed behavior disagrees:
https://code.claude.com/docs/en/cross-session-messaging
