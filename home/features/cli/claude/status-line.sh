#!/usr/bin/env bash

input=$(cat)

jqr() { jq -r "$1 // 0" <<<"$input"; }

human() {
	local s=$1 sign=""
	((s < 0)) && {
		s=$((-s))
		sign="-"
	}

	local d=$((s / 86400))
	local h=$((s % 86400 / 3600))
	local m=$((s % 3600 / 60))
	local sec=$((s % 60))

	local out=""
	((d > 0)) && out+="${d}d "
	((h > 0)) && out+="${h}h "
	((m > 0)) && out+="${m}m "
	if ((sec > 0)) || [ -z "$out" ]; then out+="${sec}s"; fi

	echo "${sign}${out}"
}

bar() {
	local pct=${1%.*}
	local width=10

	local filled=$((pct * width / 100))
	local empty=$((width - filled))

	printf -v f "%${filled}s"
	printf -v e "%${empty}s"

	echo "${f// /█}${e// /░}"
}

color() {
	local pct=${1%.*}
	if ((pct >= 90)); then
		printf "\033[31m"
	elif ((pct >= 50)); then
		printf "\033[33m"
	else
		printf "\033[32m"
	fi
}

RESET='\033[0m'

# ---------- base ----------
MODEL=$(jqr '.model.display_name')
DIR=$(jqr '.workspace.current_dir')

BRANCH=""
if git rev-parse --git-dir >/dev/null 2>&1; then
	B=$(git branch --show-current 2>/dev/null)
	[ -n "$B" ] && BRANCH=" | 🌿 $B"
fi

# ---------- context ----------
CTX=$(jqr '.context_window.used_percentage')
CTX=${CTX%.*}
CTX=${CTX:-0}

CTX_BAR=$(bar "$CTX")

# ---------- duration ----------
DURATION_MS=$(jqr '.cost.total_duration_ms')
DURATION_MS=${DURATION_MS:-0}

MINS=$((DURATION_MS / 60000))
SECS=$(((DURATION_MS % 60000) / 1000))

# ---------- rate limits ----------
now=$(date +%s)

FIVE=$(jqr '.rate_limits.five_hour.used_percentage')
FIVE=${FIVE%.*}
FIVE_R=$(jqr '.rate_limits.five_hour.resets_at')

WEEK=$(jqr '.rate_limits.seven_day.used_percentage')
WEEK=${WEEK%.*}
WEEK_R=$(jqr '.rate_limits.seven_day.resets_at')

# ---------- line 1 ----------
printf "%s | %b %s%% | ⏱ %sm %ss\n" \
	"[${MODEL}] 📁 ${DIR##*/}${BRANCH}" \
	"$(color "$CTX")${CTX_BAR}${RESET}" \
	"$CTX" "$MINS" "$SECS"

# ---------- line 2 ----------
if [ -n "$FIVE" ] && [ -n "$FIVE_R" ] && [ -n "$WEEK" ] && [ -n "$WEEK_R" ]; then

	d1=$((FIVE_R - now))
	((d1 < 0)) && d1=0
	d2=$((WEEK_R - now))
	((d2 < 0)) && d2=0

	printf "5h %b %s%% | ⏳ %s | 7d %b %s%% | ⏳ %s\n" \
		"$(color "$FIVE")$(bar "$FIVE")${RESET}" "$FIVE" "$(human "$d1")" \
		"$(color "$WEEK")$(bar "$WEEK")${RESET}" "$WEEK" "$(human "$d2")"
fi
