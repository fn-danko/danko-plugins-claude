# second-mind — smoke tests

Live-session tests to run after installing or updating the plugin. Mark
results in-place as each is run. Keep the log of latest-known-good
below the matrix.

## Debug capture

The SessionStart hook input JSON is not documented per-event. A gated
debug capture lives in `hooks/scripts/on-session-start.sh`; enable it
by setting the environment variable:

```bash
export SECOND_MIND_DEBUG=1
```

Then launch `claude --agent brainstorm` as usual. Raw hook input is
appended (one JSON per line) to:

```
${CLAUDE_PLUGIN_DATA:-$TMPDIR/second-mind}/session-start.log
```

Unset `SECOND_MIND_DEBUG` to stop logging. No plugin bump needed to
toggle.

## Test matrix

| # | Test                                                                 | How                                                                                      | Expect                                                                               | Status |
|:--|:---------------------------------------------------------------------|:-----------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------|:-------|
| 1 | Agent launches                                                       | `claude --agent brainstorm` in a throwaway dir                                           | Session starts; agent voice matches `brainstorm.md`                                  | pass   |
| 2 | Identity marker reaches system prompt                                | Vault-topic question; agent routes via marker to `preamble-brainstorming.md`             | Correct branch taken (brainstorming, not generic)                                    | pass   |
| 3 | `vault-conventions` skill loads on demand                            | Ask something that only `claude-space.md` answers                                        | Agent auto-loads skill, branches to correct preamble, pulls supporting file          | pass   |
| 4 | SessionStart hook fires on startup                                   | Fresh `claude --agent brainstorm`; check debug log exists                                | Log contains one new JSON line                                                       | pass   |
| 5 | `source` field present with value `startup`                          | Inspect the logged JSON                                                                  | `"source": "startup"`                                                                | pass   |
| 6 | `agent_type` populated for main-session `--agent`                    | Inspect the logged JSON                                                                  | `agent_type = "second-mind:brainstorm"`; `agent_id` absent                           | pass   |
| 7 | Scope fallback exercised when primary check fails                    | Manually delete `.agent_type` from captured JSON, pipe into `_scope.sh`                  | Transcript grep finds `identity: brainstorming-agent`                                |        |
| 8a| Memory injected from filesystem (preferred path)                     | `export SECOND_MIND_VAULT_PATH=/abs/path/to/vault`; fresh session; ask agent to summarize its memory | Agent recites memory content without any tool call                                   |        |
| 8b| Memory nudge fallback                                                | Unset `SECOND_MIND_VAULT_PATH`; fresh session; observe first turn                        | Agent reads `80-claude/memory.md` via `mcp__obsidian__*` on first turn               |        |
| 9 | `/clear` re-fires the hook                                           | Inside the session: `/clear`; check log                                                  | New log line with `"source": "clear"`                                                |        |
| 10| Resume does NOT re-inject                                            | `claude --resume` the session from #1                                                    | Either no new log line, or `"source": "resume"` line and the script exited silently  |        |
| 11| Auto-compact re-fires with `source: "compact"`                       | Drive the session long enough to trigger auto-compaction                                 | New log line with `"source": "compact"`; agent re-reads memory                       |        |
| 12| Non-brainstorm session skipped                                       | Plain `claude` (no `--agent`) in the same dir                                            | No log line, no memory injection attempted                                            |        |
| 13| Validator clean                                                      | `/plugin validate .` at marketplace root                                                 | Passes                                                                               |        |

## Priority order

1 → 4 → 5/6 → 7 → 8a/8b. Those answer the biggest unknowns quickly.
Rest is coverage.

## Latest known-good

```
Version: 0.1.5
Date:    2026-04-19

SessionStart input JSON (SECOND_MIND_DEBUG capture):
  Fields present: session_id, transcript_path, cwd,
  agent_type, hook_event_name, source, model.
  agent_id: absent for main-session --agent.
  agent_type: "second-mind:brainstorm" (plugin-namespaced).
  source: "startup" on fresh launch.
  Fields expected by docs but absent in payload: permission_mode.

Agent + skill:
  --agent brainstorm launches cleanly; agent voice matches prompt.
  Identity marker (body line 9) reaches system prompt — skill
  router branches correctly.
  vault-conventions skill auto-loads when a vault topic comes up;
  preamble-brainstorming.md loads, then claude-space.md as a
  supporting module when the question requires it.

Not yet exercised:
  Scope-fallback transcript grep (agent_type worked, didn't need
  it); /clear and auto-compact re-fires; resume no-op; filesystem
  memory injection (needs 80-claude/memory.md to exist in vault);
  non-brainstorm session scoping.
```
