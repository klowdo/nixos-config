#!/usr/bin/env bash
# shellcheck disable=SC2016
input=$(cat)

tool_name=$(@jq@ -r '.tool_name // empty' <<<"$input")
[[ $tool_name == "Write" || $tool_name == "Edit" || $tool_name == "MultiEdit" ]] || exit 0

file_path=$(@jq@ -r '.tool_input.file_path // empty' <<<"$input")
[ -z "$file_path" ] || [ ! -f "$file_path" ] && exit 0

PK="PRIVATE KEY"
patterns=(
	"PRIVATE.KEY"
	"BEGIN RSA ${PK}"
	"BEGIN OPENSSH ${PK}"
	"BEGIN EC ${PK}"
	"BEGIN PGP ${PK}"
	'AWS_SECRET_ACCESS_KEY'
	'AKIA[0-9A-Z]{16}'
	'ghp_[a-zA-Z0-9]{36}'
	'gho_[a-zA-Z0-9]{36}'
	'sk-[a-zA-Z0-9]{48}'
	'AGE-SECRET-KEY-'
	'op://[^ ]+'
)

combined=$(printf '%s\n' "${patterns[@]}" | paste -sd'|')

if @grep@ -qEi "$combined" "$file_path" 2>/dev/null; then
	match=$(@grep@ -nEi "$combined" "$file_path" 2>/dev/null | head -3)
	@jq@ -n --arg reason "Potential secret/key detected in $file_path: $match" '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: ("⚠️ SECRET DETECTED — review before committing:\n" + $reason)
    }
  }'
	exit 2
fi

exit 0
