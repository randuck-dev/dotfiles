#!/usr/bin/env bash

# Picker over every tmux window we've tagged with @claude=1. Windows
# whose silence flag is set (claude likely waiting for input) sort to
# the top and are marked ● in gold; busy ones get ○ in muted text.
#
# Bound to `prefix + A` in tmux.conf.

set -euo pipefail

rows=$(tmux list-windows -a -F \
  '#{?#{==:#{@claude},1},x,}#{session_name}:#{window_index}#{?window_silence_flag,#{l:	WAITING	}, #{l:	working	}}#{window_name}	#{pane_current_path}' \
  2>/dev/null \
  | grep -E '^x' \
  | sed 's/^x//')

if [[ -z $rows ]]; then
  tmux display-message "no claude windows"
  exit 0
fi

# Sort: WAITING rows first (column 2), then by session:window.
sorted=$(printf '%s\n' "$rows" | awk -F'\t' '
  {
    key = ($2 == "WAITING") ? "0" : "1"
    print key "\t" $0
  }' | sort | cut -f2-)

# Format for fzf: visible markers + target.
# Columns (tab-separated as we built above): target, state, name, path
selected=$(printf '%s\n' "$sorted" \
  | awk -F'\t' '
    {
      mark = ($2 == "WAITING") ? "●" : "○"
      printf "%s  %-30s  %-20s  %s\t%s\n", mark, $1 " " $3, $2, $4, $1
    }' \
  | fzf \
      --reverse \
      --border=rounded \
      --prompt="❯ " \
      --header="enter: switch to window · ctrl-c: cancel" \
      --with-nth=1 \
      --delimiter=$'\t' \
      --preview='
        target=$(printf "%s" {} | cut -f2)
        tmux capture-pane -p -t "$target" 2>/dev/null | tail -40
      ' \
      --preview-window="right:60%:wrap")

[[ -z $selected ]] && exit 0

target=$(printf "%s" "$selected" | cut -f2)
session=${target%%:*}

tmux switch-client -t "$session"
tmux select-window -t "$target"
