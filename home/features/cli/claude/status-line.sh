#!/usr/bin/env bash

input=$(cat)

MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

GIT_BRANCH=""
if git rev-parse --git-dir >/dev/null 2>&1; then
	BRANCH=$(git branch --show-current 2>/dev/null)
	if [ -n "$BRANCH" ]; then
		GIT_BRANCH=" | 🌿 $BRANCH"
	fi
fi

format_tokens() {
	local tokens=$1
	if [ "$tokens" -ge 1000000 ]; then
		printf "%.1fM" "$(echo "$tokens / 1000000" | bc -l)"
	elif [ "$tokens" -ge 1000 ]; then
		printf "%.1fk" "$(echo "$tokens / 1000" | bc -l)"
	else
		echo "$tokens"
	fi
}

CTX_PART=""
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$CTX_PCT" ]; then
	CTX_PART=" | ctx: ${CTX_PCT}%"
fi

TOK_PART=""
INPUT_TOK=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
OUTPUT_TOK=$(echo "$input" | jq -r '.total_output_tokens // empty')
if [ -n "$INPUT_TOK" ] && [ -n "$OUTPUT_TOK" ]; then
	TOTAL_TOK=$((INPUT_TOK + OUTPUT_TOK))
	TOK_PART=" | $(format_tokens "$TOTAL_TOK") tok"
fi

CAVEMAN_PART=""
CAVEMAN_FLAG="$HOME/.claude/.caveman-active"
if [ -f "$CAVEMAN_FLAG" ]; then
	CAVEMAN_MODE=$(cat "$CAVEMAN_FLAG" 2>/dev/null)
	if [ "$CAVEMAN_MODE" = "full" ] || [ -z "$CAVEMAN_MODE" ]; then
		CAVEMAN_PART=$(printf ' | \033[38;5;172m[CAVEMAN]\033[0m')
	else
		CAVEMAN_PART=$(printf ' | \033[38;5;172m[CAVEMAN:%s]\033[0m' "$(echo "$CAVEMAN_MODE" | tr '[:lower:]' '[:upper:]')")
	fi
fi

echo "[$MODEL_DISPLAY] 📁 ${CURRENT_DIR##*/}$GIT_BRANCH$CTX_PART$TOK_PART$CAVEMAN_PART"
