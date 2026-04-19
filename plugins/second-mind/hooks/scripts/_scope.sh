#!/usr/bin/env bash
# Source this from hook scripts that must run only for the brainstorm agent.
# Call `is_brainstorm_agent "$input_json"` and short-circuit on non-zero.
#
# Scoping strategy:
#   1. Check `agent_id` / `agent_type` in the hook input JSON. The harness
#      populates this when a known agent is active.
#   2. Fallback: grep the transcript file for the identity marker the agent
#      carries in its system prompt body.
#
# Either signal matches — one is enough. Silent exit is the default outside
# the brainstorm agent so other sessions stay untouched.

is_brainstorm_agent() {
  local input="$1"

  local agent
  agent="$(jq -r '.agent_id // .agent_type // empty' <<<"$input")"
  if [[ -n "$agent" ]]; then
    # Plugin-scoped agents arrive namespaced as <plugin>:<agent>; accept
    # both bare and namespaced forms.
    case "$agent" in
      brainstorm|*:brainstorm) return 0 ;;
      *) return 1 ;;
    esac
  fi

  local transcript
  transcript="$(jq -r '.transcript_path // empty' <<<"$input")"
  [[ -n "$transcript" && -f "$transcript" ]] || return 1
  grep -q 'identity: brainstorming-agent' "$transcript"
}
