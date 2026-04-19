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
# First iteration: defer the actual vault read to the agent. We inject an
# instruction asking the agent to read `80-claude/memory.md` via MCPVault
# as its first action, silently. This keeps the plugin independent of the
# MCPVault vault-path configuration.

set -euo pipefail

# shellcheck source=./_scope.sh
source "$(dirname "$0")/_scope.sh"

input="$(cat)"

source_field="$(jq -r '.source // empty' <<<"$input")"
case "$source_field" in
  startup|clear|compact) ;;
  *) exit 0 ;;
esac

is_brainstorm_agent "$input" || exit 0

jq -n '{
  additionalContext: "Session start. Before the first user message, read `80-claude/memory.md` via MCPVault and internalize it as ambient context. Memory is present, not retrieved — do not narrate or announce the lookup; just let what is there shape how you engage."
}'
