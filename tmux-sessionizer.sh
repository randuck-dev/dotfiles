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

# ── redirect linked worktrees to their parent repo's session ─────
# If the picked directory is a linked git worktree, switch the target to
# the primary worktree's path (so the session is named after the repo,
# not the worktree). Remember the worktree path so we can focus its
# window at the end.
target_worktree=""
if git_dir=$(git -C "$selected" rev-parse --git-dir 2>/dev/null) \
   && common_dir=$(git -C "$selected" rev-parse --git-common-dir 2>/dev/null) \
   && [[ $(cd "$selected" && cd "$git_dir" && pwd) != $(cd "$selected" && cd "$common_dir" && pwd) ]]; then
  # `git worktree list --porcelain`'s first record is the primary worktree.
  primary=$(git -C "$selected" worktree list --porcelain \
    | awk '/^worktree /{print substr($0, 10); exit}')
  if [[ -n $primary && -d $primary ]]; then
    target_worktree=$(git -C "$selected" rev-parse --show-toplevel)
    selected=$primary
  fi
fi

# Directory — tmux session names can't contain : or .
selected_name=$(basename "$selected" | tr ':.' '__')

# ── create session if needed ─────────────────────────────────────
created=0
if ! tmux has-session -t="$selected_name" 2>/dev/null; then
  tmux new-session -ds "$selected_name" -c "$selected"
  created=1
fi

# ── populate worktree windows on fresh sessions ──────────────────
# For new sessions in a git repo, rename the first window to match the
# selected worktree's branch and open one window per additional worktree.
if [[ $created -eq 1 ]] && repo_root=$(git -C "$selected" rev-parse --show-toplevel 2>/dev/null); then
  selected_branch=$(git -C "$selected" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  if [[ -z $selected_branch || $selected_branch == HEAD ]]; then
    selected_branch=$(git -C "$selected" rev-parse --short HEAD 2>/dev/null || echo "main")
  fi
  selected_window=${selected_branch//\//-}
  tmux rename-window -t "$selected_name:" "$selected_window"

  # Pairs: branch<TAB>path, one per line. Detached HEADs get the short sha.
  worktrees=$(git -C "$repo_root" worktree list --porcelain \
    | awk '
      /^worktree /  { path = substr($0, 10); next }
      /^HEAD /      { head = $2; next }
      /^branch /    { sub("refs/heads/", "", $2); printf "%s\t%s\n", $2, path; path = ""; head = ""; next }
      /^detached/   { printf "%s\t%s\n", substr(head, 1, 7), path; path = ""; head = ""; next }
    ')

  while IFS=$'\t' read -r branch path; do
    [[ -z $branch || -z $path ]] && continue
    window_name=${branch//\//-}
    # Skip the worktree we already renamed the first window to.
    [[ $path == "$repo_root" && $window_name == "$selected_window" ]] && continue
    [[ $path == "$selected" && $window_name == "$selected_window" ]] && continue
    # Avoid dupes if a window with that name somehow already exists.
    if ! tmux list-windows -t "$selected_name" -F '#W' | grep -qx "$window_name"; then
      tmux new-window -t "$selected_name:" -n "$window_name" -c "$path"
    fi
  done <<< "$worktrees"

  tmux select-window -t "$selected_name:^"
fi

# ── focus the picked worktree's window, if applicable ────────────
# Works whether the parent session was just created (window exists from
# the populate block above) or already existed (window may exist from a
# prior `wt switch` — create it if not).
if [[ -n $target_worktree ]]; then
  branch=$(git -C "$target_worktree" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  if [[ -z $branch || $branch == HEAD ]]; then
    branch=$(git -C "$target_worktree" rev-parse --short HEAD 2>/dev/null || echo "")
  fi
  if [[ -n $branch ]]; then
    window_name=${branch//\//-}
    if ! tmux list-windows -t "$selected_name" -F '#W' | grep -qx "$window_name"; then
      tmux new-window -t "$selected_name:" -n "$window_name" -c "$target_worktree"
    fi
    tmux select-window -t "$selected_name:$window_name"
  fi
fi

if [[ -n ${TMUX:-} ]]; then
  tmux switch-client -t "$selected_name"
else
  tmux attach -t "$selected_name"
fi
