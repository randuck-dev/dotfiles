#!/usr/bin/env bash

# Sessionizer — pick a tmux session or project directory.
# Running sessions are listed first (marked ●), then directories from
# the configured search paths.
#
# Originally adapted from ThePrimeagen's tmux-sessionizer.

set -euo pipefail

SEARCH_PATHS=("$HOME/projects" "$HOME/oss-projects")

# ── direct arg: skip the picker ──────────────────────────────────
if [[ $# -eq 1 ]]; then
  selected=$1
else
  # ── build list: sessions first, then dirs ──────────────────────
  sessions=""
  if tmux list-sessions -F '#{session_name}' >/dev/null 2>&1; then
    sessions=$(tmux list-sessions -F '● #{session_name}' 2>/dev/null || true)
  fi

  dirs=$(find "${SEARCH_PATHS[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)

  # Preview script: if line starts with ●, show session windows;
  # otherwise show ls + recent git log of that directory.
  preview='
    line={}
    if [[ $line == ●* ]]; then
      name=${line#● }
      tmux list-windows -t "$name" -F "  #I: #W#{?window_active, (active),}" 2>/dev/null
    else
      echo "── $line ──"
      ls -lh --color=always "$line" 2>/dev/null | head -20
      echo
      if [ -d "$line/.git" ] || git -C "$line" rev-parse --git-dir >/dev/null 2>&1; then
        echo "── recent commits ──"
        git -C "$line" log --oneline --decorate -10 2>/dev/null
      fi
    fi
  '

  selected=$(printf "%s\n%s\n" "$sessions" "$dirs" \
    | sed '/^$/d' \
    | fzf \
        --reverse \
        --border=rounded \
        --prompt="❯ " \
        --header="enter: switch/create · ctrl-c: cancel" \
        --preview="$preview" \
        --preview-window="right:55%:wrap")
fi

[[ -z $selected ]] && exit 0

# ── resolve selection ────────────────────────────────────────────
if [[ $selected == ●* ]]; then
  # Existing session — switch directly
  selected_name=${selected#● }
  if [[ -n ${TMUX:-} ]]; then
    tmux switch-client -t "$selected_name"
  else
    tmux attach -t "$selected_name"
  fi
  exit 0
fi

# Directory — tmux session names can't contain : or .
selected_name=$(basename "$selected" | tr ':.' '__')

# ── create session if needed ─────────────────────────────────────
tmux_running=$(pgrep tmux || true)

if [[ -z ${TMUX:-} ]] && [[ -z $tmux_running ]]; then
  tmux new-session -s "$selected_name" -c "$selected"
  exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
  tmux new-session -ds "$selected_name" -c "$selected"
fi

if [[ -n ${TMUX:-} ]]; then
  tmux switch-client -t "$selected_name"
else
  tmux attach -t "$selected_name"
fi
