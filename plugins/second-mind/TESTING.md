# second-mind — smoke tests

Live-session tests to run after installing or updating the plugin. Mark
results in-place as each is run. Keep the log of latest-known-good
below the matrix.

## Debug capture (run first, remove after)

The SessionStart hook input JSON is not documented per-event. Capture
it once so the rest of the tests can verify fields.

Add one line to `hooks/scripts/on-session-start.sh`, just after
`input="$(cat)"`:

```bash
echo "$input" >> "${CLAUDE_PLUGIN_DATA:-/tmp}/session-start.log"  # TEMP — remove after
```

Commit, push, bump plugin version (patch), re-install, trigger events.
Inspect `${CLAUDE_PLUGIN_DATA}/session-start.log`. Remove the line and
bump again when done.

## Test matrix

| # | Test                                                                 | How                                                                                      | Expect                                                                               | Status |
|:--|:---------------------------------------------------------------------|:-----------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------|:-------|
| 1 | Agent launches                                                       | `claude --agent brainstorm` in a throwaway dir                                           | Session starts; agent voice matches `brainstorm.md`                                  |        |
| 2 | Identity marker reaches system prompt                                | In-session: ask the agent to quote its first body line                                   | It returns `identity: brainstorming-agent`                                           |        |
| 3 | `vault-conventions` skill preloaded                                  | Ask a question answered only in `claude-space.md` (e.g. "what earns a thread?")          | Answer aligns with skill; agent did not have to be pointed at the skill              |        |
| 4 | SessionStart hook fires on startup                                   | Fresh `claude --agent brainstorm`; check debug log exists                                | Log contains one new JSON line                                                       |        |
| 5 | `source` field present with value `startup`                          | Inspect the logged JSON                                                                  | `"source": "startup"`                                                                |        |
| 6 | `agent_id` / `agent_type` populated for main-session `--agent`       | Inspect the logged JSON                                                                  | Record observed value; empty is expected per research                                |        |
| 7 | Scope fallback works when `agent_id` empty                           | If #6 is empty: `grep 'identity: brainstorming-agent' $transcript_path` (from logged JSON)| Match found — `_scope.sh` fallback will succeed                                      |        |
| 8 | `additionalContext` injected                                         | First agent turn: watch for an MCPVault read of `80-claude/memory.md`                    | Tool call happens without user prompting                                             |        |
| 9 | `/clear` re-fires the hook                                           | Inside the session: `/clear`; check log                                                  | New log line with `"source": "clear"`                                                |        |
| 10| Resume does NOT re-inject                                            | `claude --resume` the session from #1                                                    | Either no new log line, or `"source": "resume"` line and the script exited silently  |        |
| 11| Auto-compact re-fires with `source: "compact"`                       | Drive the session long enough to trigger auto-compaction                                 | New log line with `"source": "compact"`; agent re-reads memory                       |        |
| 12| Non-brainstorm session skipped                                       | Plain `claude` (no `--agent`) in the same dir                                            | No log line, no MCPVault read attempted                                              |        |
| 13| Validator clean                                                      | `/plugin validate .` at marketplace root                                                 | Passes                                                                               |        |

## Priority order

1 → 4 → 5/6 → 7 → 8. Those answer the biggest unknowns quickly. Rest is
coverage.

## Latest known-good

```
Version: <plugin version tested>
Date:    <YYYY-MM-DD>
Notes:   <observed agent_id/agent_type values, any deviations,
          anything worth flagging>
```
