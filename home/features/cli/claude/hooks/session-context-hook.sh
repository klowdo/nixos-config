#!/usr/bin/env bash
# shellcheck disable=SC2016
branch=$(@git@ branch --show-current 2>/dev/null || echo "detached")
host=$(hostname -s 2>/dev/null || echo "unknown")
dirty=$(@git@ status --porcelain 2>/dev/null | wc -l | tr -d ' ')

context="Host: $host | Branch: $branch | Dirty files: $dirty"

@jq@ -n --arg ctx "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'
