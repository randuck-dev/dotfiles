#!/usr/bin/env bash

# Worktree picker — fzf over `git worktree list` for the current repo,
# opens (or selects) a tmux window named after the branch.
#
# Intended to be bound to a tmux key (see tmux.conf).

set -euo pipefail

# Resolve the repo root from the pane's cwd.
repo_root=$(git -C "${1:-$PWD}" rev-parse --show-toplevel 2>/dev/null || true)
if [[ -z $repo_root ]]; then
  tmux display-message "not in a git repo"
  exit 0
fi

# Parse `git worktree list --porcelain`: blank-line-separated records of
# `worktree <path>` / `HEAD <sha>` / `branch refs/heads/<name>` (or `detached`).
list=$(git -C "$repo_root" worktree list --porcelain \
  | awk '
    /^worktree /  { path = substr($0, 10); next }
    /^branch /    { sub("refs/heads/", "", $2); printf "%s\t%s\n", $2, path; path = "" }
    /^detached/   { printf "(detached)\t%s\n", path; path = "" }
  ')

[[ -z $list ]] && { tmux display-message "no worktrees"; exit 0; }

selected=$(printf "%s\n" "$list" \
  | fzf \
      --reverse \
      --border=rounded \
      --prompt="❯ " \
      --header="enter: open/switch window · ctrl-c: cancel" \
      --with-nth=1 \
      --delimiter=$'\t' \
      --preview='
        path=$(printf "%s" {} | cut -f2)
        echo "── $path ──"
        git -C "$path" status --short --branch 2>/dev/null
        echo
        echo "── recent commits ──"
        git -C "$path" log --oneline --decorate -10 2>/dev/null
      ' \
      --preview-window="right:55%:wrap")

[[ -z $selected ]] && exit 0

branch=$(printf "%s" "$selected" | cut -f1)
path=$(printf "%s" "$selected" | cut -f2)

# tmux window names can't be empty; sanitise the branch a bit.
window_name=${branch//\//-}

if tmux list-windows -F '#W' | grep -qx "$window_name"; then
  tmux select-window -t "$window_name"
else
  tmux new-window -n "$window_name" -c "$path"
fi
