#!/usr/bin/env bash
# SessionStart hook for the brainstorm agent.
#
# Fires only when the conversation context has been lost or never existed:
#   - startup : fresh session
#   - clear   : /clear inside a session
#   - compact : auto-compaction dropped older turns
# On resume the previous transcript still carries whatever the agent read
# last session, so re-injection would be redundant.
#
# Memory read strategy
#
#   If SECOND_MIND_VAULT_PATH is set and $vault/80-claude/memory.md
#   exists, the hook reads it from the filesystem and injects the
#   contents directly. The agent sees memory as ambient context on
#   startup with no tool call, matching the "memory is present, not
#   retrieved" frame.
#
#   Otherwise the hook falls back to instructing the agent to read
#   memory.md via the obsidian MCP server on its first turn. The
#   fallback is lossier (the agent has to invoke tools and may narrate
#   the lookup), but keeps the plugin usable before the env var is set.

set -euo pipefail

# shellcheck source=./_scope.sh
source "$(dirname "$0")/_scope.sh"

input="$(cat)"

# Gated debug capture. Set SECOND_MIND_DEBUG=1 in the session environment
# to append raw hook input (one JSON object per line) to the log. Useful
# for verifying per-event schema fields (source, agent_id, agent_type)
# that are not published in the official docs.
if [[ -n "${SECOND_MIND_DEBUG:-}" ]]; then
  log_dir="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/second-mind}"
  mkdir -p "$log_dir"
  printf '%s\n' "$input" >> "$log_dir/session-start.log"
fi

source_field="$(jq -r '.source // empty' <<<"$input")"
case "$source_field" in
  startup|clear|compact) ;;
  *) exit 0 ;;
esac

is_brainstorm_agent "$input" || exit 0

vault_path="${SECOND_MIND_VAULT_PATH:-}"
memory_file="${vault_path%/}/80-claude/memory.md"

nudge_base="Session start. Before the first user message, read \`80-claude/memory.md\` via the obsidian MCP server and internalize it as ambient context. Memory is present, not retrieved — do not narrate or announce the lookup; just let what is there shape how you engage."

if [[ -n "$vault_path" && -f "$memory_file" ]]; then
  # Preferred path: read the memory file from disk and inject.
  memory_contents="$(cat "$memory_file")"
  jq -n --arg mem "$memory_contents" '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: ("Your memory, loaded from `80-claude/memory.md`. Treat as ambient context you already carry — do not narrate or announce this block, and do not re-read the file during this session unless the conversation is about memory itself.\n\n" + $mem)
    }
  }'
elif [[ -n "$vault_path" ]]; then
  # Env var is set but the file can't be read — almost always a typo in
  # the path, or the vault doesn't yet have 80-claude/memory.md. Tell
  # the agent the specific mismatch (so it can relay to the user) and
  # also write to stderr + diagnostics log for out-of-band inspection.
  diag_dir="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/second-mind}"
  mkdir -p "$diag_dir"
  diag_msg="SECOND_MIND_VAULT_PATH is set to '$vault_path' but '$memory_file' is missing or unreadable. Falling back to the MCP-read nudge. Fix the path or create the file to use the preferred injection path."
  printf '[%s] %s\n' "$(date -Iseconds)" "$diag_msg" | tee -a "$diag_dir/diagnostics.log" >&2

  jq -n --arg nudge "$nudge_base" --arg vault "$vault_path" --arg mem "$memory_file" '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: ($nudge + "\n\n(Note for the user: `SECOND_MIND_VAULT_PATH` is set to `" + $vault + "` but `" + $mem + "` was not found. Check the path points at the vault root that contains `80-claude/`, or create the memory file.)")
    }
  }'
else
  # Env var unset — suggest the user set it to get the faster path.
  jq -n --arg nudge "$nudge_base" '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: ($nudge + "\n\n(Note for the user: set `SECOND_MIND_VAULT_PATH` in your shell to the vault root to let this hook inject memory directly and skip the tool call.)")
    }
  }'
fi
