#!/usr/bin/env bash
# Simple statusLine for Claude Code
# Format: <model> | <effort> | Session <pct>% (<used>/<limit>)

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Model name: "claude-sonnet-4-6" -> "sonnet-4.6"
model_raw=$(echo "$input" | jq -r '.model.id // .model.display_name // empty')
model_short=""
if [ -n "$model_raw" ]; then
  model_short=$(echo "$model_raw" | sed 's/^[Cc]laude[- ]//' | sed 's/\([0-9]\)-\([0-9]\)$/\1.\2/')
fi


# Git branch
branch=""
if cd "$cwd" 2>/dev/null; then
  branch=$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
           || git --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

# Context window metrics
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

# Human-readable token count: 44611 -> "44.6k", 200000 -> "200k"
fmt_tokens() {
  local n="$1"
  awk -v n="$n" 'BEGIN{
    if (n >= 1000) {
      val = n / 1000
      if (val == int(val)) printf "%.0fk", val
      else printf "%.1fk", val
    } else {
      printf "%d", n
    }
  }'
}

# Context usage display
if [ -n "$used_pct" ]; then
  tok_display="⧖ ${used_pct}% ($(fmt_tokens "$total_input_tokens")/$(fmt_tokens "$context_window_size"))"
else
  tok_display=""
fi

# 5-hour rate limit display
five_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
five_display=""
if [ -n "$five_used" ]; then
  five_used_fmt=$(awk -v u="$five_used" 'BEGIN{ printf "%.0f", u }')
  if [ -n "$five_resets" ]; then
    now=$(date +%s)
    secs_left=$(( five_resets - now ))
    if [ "$secs_left" -gt 0 ]; then
      reset_at=$(date -r "$five_resets" +"%H:%M" 2>/dev/null || date -d "@$five_resets" +"%H:%M")
      five_display="⏱️5h: ${five_used_fmt}% ⏳${reset_at}"
    else
      five_display="⏱️5h: ${five_used_fmt}%"
    fi
  else
    five_display="⏱️5h: ${five_used_fmt}%"
  fi
fi

# Weekly rate limit display
week_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
week_display=""
if [ -n "$week_used" ]; then
  week_used_fmt=$(awk -v u="$week_used" 'BEGIN{ printf "%.0f", u }')
  if [ -n "$week_resets" ]; then
    now=$(date +%s)
    secs_left=$(( week_resets - now ))
    if [ "$secs_left" -gt 0 ]; then
      reset_at=$(date -r "$week_resets" +"%a %H:%M" 2>/dev/null || date -d "@$week_resets" +"%a %H:%M")
      week_display="🗓️7d: ${week_used_fmt}% ⏳${reset_at}"
    else
      week_display="🗓️7d: ${week_used_fmt}%"
    fi
  else
    week_display="🗓️7d: ${week_used_fmt}%"
  fi
fi

# ANSI color codes (subtle)
RESET='\e[0m'
DIM='\e[2m'
CYAN='\e[36m'
GREEN='\e[32m'
YELLOW='\e[33m'

SEP="$(printf "${DIM}|${RESET}")"

# Build output — folder path, git branch, model name
parts=""

home_dir="$HOME"
if [ -n "$home_dir" ] && [[ "$cwd" == "$home_dir"* ]]; then
  dir_display="~${cwd#$home_dir}"
else
  dir_display="$cwd"
fi
if [ -n "$dir_display" ]; then
  parts="$(printf "${CYAN}%s${RESET}" "$dir_display")"
fi

if [ -n "$branch" ]; then
  parts="${parts} $(printf "${GREEN}%s${RESET}" " $branch")"
fi

if [ -n "$model_short" ]; then
  parts="${parts} ${SEP} $(printf "${CYAN}%s${RESET}" "🧠$model_short")"
fi

if [ -n "$tok_display" ]; then
  parts="${parts} ${SEP} ${tok_display}"
fi

if [ -n "$five_display" ]; then
  parts="${parts} ${SEP} $(printf "${YELLOW}%s${RESET}" "$five_display")"
fi

if [ -n "$week_display" ]; then
  parts="${parts} ${SEP} $(printf "${YELLOW}%s${RESET}" "$week_display")"
fi

printf '%b' "$parts"
