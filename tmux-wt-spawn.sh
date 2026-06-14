#!/usr/bin/env bash

# Spawn a new git worktree for a branch and open a tmux window running
# `claude` in it. Intended to be invoked from a tmux command-prompt
# binding (see tmux.conf).
#
# Usage: tmux-wt-spawn.sh <branch-name>
#
# The repo is determined from the current pane's cwd.

set -euo pipefail

branch=${1:-}
if [[ -z $branch ]]; then
  tmux display-message "wt-spawn: no branch name given"
  exit 0
fi

# Resolve the repo from the active pane's cwd, then resolve the primary
# worktree so we always create new worktrees off the main checkout.
pane_cwd=$(tmux display-message -p '#{pane_current_path}')
repo_root=$(git -C "$pane_cwd" rev-parse --show-toplevel 2>/dev/null || true)
if [[ -z $repo_root ]]; then
  tmux display-message "wt-spawn: not in a git repo"
  exit 0
fi
primary=$(git -C "$repo_root" worktree list --porcelain \
  | awk '/^worktree /{print substr($0, 10); exit}')
[[ -n $primary && -d $primary ]] && repo_root=$primary

# Create the worktree via worktrunk. wt picks the path itself; we read
# it back from `git worktree list` by matching the new branch.
if ! (cd "$repo_root" && wt switch -c "$branch") >/tmp/wt-spawn.$$.log 2>&1; then
  tmux display-message "wt-spawn: wt switch failed (see /tmp/wt-spawn.$$.log)"
  exit 1
fi

path=$(git -C "$repo_root" worktree list --porcelain \
  | awk -v b="$branch" '
    /^worktree / { p = substr($0, 10); next }
    /^branch /   { sub("refs/heads/", "", $2); if ($2 == b) { print p; exit } }
  ')
if [[ -z $path || ! -d $path ]]; then
  tmux display-message "wt-spawn: could not resolve worktree path for $branch"
  exit 1
fi
rm -f /tmp/wt-spawn.$$.log

window_name=${branch//\//-}
session=$(tmux display-message -p '#S')

if tmux list-windows -t "$session" -F '#W' | grep -qx "$window_name"; then
  tmux select-window -t "$session:$window_name"
else
  # Launch claude as the window's command. When claude exits, exec into
  # a shell so the window remains useful instead of dying.
  tmux new-window -t "$session:" -n "$window_name" -c "$path" \
    "claude; exec ${SHELL:-zsh}"
  # Mark this window as containing claude and watch for 30s of silence
  # (typical signal that claude is waiting for input).
  tmux set-option -w -t "$session:$window_name" @claude 1
  tmux set-option -w -t "$session:$window_name" monitor-silence 30
fi
