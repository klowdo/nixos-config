#!/usr/bin/env bash
# rtk-hook-version: 3
# RTK Claude Code PreToolUse hook — rewrites Bash commands to use rtk for token savings.
# Delegates all rewrite logic to `rtk rewrite` (single source of truth).
# shellcheck disable=SC2016

INPUT=$(cat)
CMD=$(@jq@ -r '.tool_input.command // empty' <<<"$INPUT")

[ -z "$CMD" ] && exit 0

REWRITTEN=$(@rtk@ rewrite "$CMD" 2>/dev/null)
EXIT_CODE=$?

case $EXIT_CODE in
0)
	[ "$CMD" = "$REWRITTEN" ] && exit 0
	;;
1 | 2)
	exit 0
	;;
3) ;;
*)
	exit 0
	;;
esac

UPDATED_INPUT=$(@jq@ -c --arg cmd "$REWRITTEN" '.tool_input | .command = $cmd' <<<"$INPUT")

if [ "$EXIT_CODE" -eq 3 ]; then
	@jq@ -n --argjson updated "$UPDATED_INPUT" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      updatedInput: $updated
    }
  }'
else
	@jq@ -n --argjson updated "$UPDATED_INPUT" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: "RTK auto-rewrite",
      updatedInput: $updated
    }
  }'
fi
