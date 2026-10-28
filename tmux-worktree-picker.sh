#!/usr/bin/env bash

# Worktree picker — every repo under ~/projects, every worktree of each
# (including Claude desktop's .claude/worktrees/*), and what Claude is
# doing in each one (from bin/claude-status).
#
# Opens on the worktrees of the repo you're in; esc goes to the repo
# list, esc again closes. Enter jumps to the worktree: the tmux pane
# running Claude there, else any pane already in it, else a new window
# in the repo's session (same session naming as the sessionizer).
#
# Usage: tmux-worktree-picker.sh [dir]   (bound to `prefix W`)

set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
status_cmd="$here/bin/claude-status"
SEARCH_PATHS=("$HOME/projects" "$HOME/oss-projects")

# Icons per state, most urgent first.
#   ● input    needs a permission or an answer
#   ◆ done     finished its turn, your move
#   ○ working  Claude is busy
#   · open     a tmux pane is in it, no Claude session
c_gold=$'\033[38;2;246;193;119m'
c_iris=$'\033[38;2;196;167;231m'
c_foam=$'\033[38;2;156;207;216m'
c_muted=$'\033[38;2;110;106;134m'
c_off=$'\033[0m'

# ── gather data ──────────────────────────────────────────────────
# worktrees: primary<TAB>branch<TAB>path, for every repo we can find.
gather_worktrees() {
  local p d primary seen=""
  for p in "${SEARCH_PATHS[@]}"; do
    [[ -d $p ]] || continue
    for d in "$p"/*/; do
      d=${d%/}
      [[ -e $d/.git ]] || continue
      primary=$(git -C "$d" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print substr($0, 10); exit}')
      [[ -n $primary ]] || continue
      case $seen in *$'\n'"$primary"$'\n'*) continue ;; esac
      seen+=$'\n'"$primary"$'\n'
      git -C "$primary" worktree list --porcelain 2>/dev/null | awk -v primary="$primary" '
        /^worktree / { path = substr($0, 10); next }
        /^HEAD /     { head = substr($2, 1, 7); next }
        /^branch /   { sub("refs/heads/", "", $2); printf "%s\t%s\t%s\n", primary, $2, path; next }
        /^detached/  { printf "%s\t%s\t%s\n", primary, head, path; next }
      '
    done
  done
}

worktrees=$(gather_worktrees)
[[ -z $worktrees ]] && { tmux display-message "no git repos found"; exit 0; }

sessions=$("$status_cmd" list 2>/dev/null || true)
panes=$(tmux list-panes -a -F '#{pane_id}	#{pane_current_path}' 2>/dev/null || true)

# For each worktree, work out its state and the pane to jump to.
# Output: primary<TAB>branch<TAB>path<TAB>state<TAB>pane<TAB>where
# Empty values are written as "-": bash's read merges empty tab fields.
# A cwd belongs to the longest worktree path containing it, so a session
# in repo/.claude/worktrees/x counts for x, not for repo.
table=$(awk -F'\t' '
  function owner(cwd,   i, best, bl) {
    best = ""; bl = 0
    for (i = 1; i <= n; i++)
      if ((cwd == wpath[i] || index(cwd, wpath[i] "/") == 1) && length(wpath[i]) > bl) { best = i; bl = length(wpath[i]) }
    return best
  }
  function rank(s) { return s == "input" ? 4 : s == "done" ? 3 : s == "working" ? 2 : s == "open" ? 1 : 0 }
  section == 0 && $0 == "--sessions--" { section = 1; next }
  section == 1 && $0 == "--panes--"    { section = 2; next }
  $0 == "" { next }
  section == 0 { n++; wprim[n] = $1; wbranch[n] = $2; wpath[n] = $3; next }
  section == 1 {
    i = owner($2); if (i == "") next
    if (rank($1) > rank(state[i])) { state[i] = $1; pane[i] = $3; where[i] = ($3 == "" ? "desktop" : "tmux") }
    next
  }
  section == 2 {
    i = owner($2); if (i == "") next
    if (state[i] == "") state[i] = "open"
    if (pane[i] == "") pane[i] = $1
    next
  }
  END {
    for (i = 1; i <= n; i++)
      printf "%s\t%s\t%s\t%s\t%s\t%s\n", wprim[i], wbranch[i], wpath[i], (state[i] == "" ? "idle" : state[i]), (pane[i] == "" ? "-" : pane[i]), (where[i] == "" ? "-" : where[i])
  }
' <<EOF
$worktrees
--sessions--
$sessions
--panes--
$panes
EOF
)

# ── pickers ──────────────────────────────────────────────────────
fzf_common=(--ansi --reverse --border=rounded --prompt="❯ " --gutter=" "
  --delimiter=$'\t' --with-nth=1 --info=inline-right
  --color='fg:#e0def4,hl:#c4a7e7,fg+:#e0def4,bg+:#393552,hl+:#c4a7e7,prompt:#c4a7e7,pointer:#c4a7e7,info:#6e6a86,header:#6e6a86,border:#393552')

icon() {
  case $1 in
    input) printf '%s●%s' "$c_gold" "$c_off" ;;
    done) printf '%s◆%s' "$c_iris" "$c_off" ;;
    working) printf '%s○%s' "$c_foam" "$c_off" ;;
    open) printf '%s·%s' "$c_muted" "$c_off" ;;
    *) printf ' ' ;;
  esac
}

# Repo list: name, worktree count, and a summary of Claude states.
# The repo you're in comes first, then repos with something waiting.
pick_repo() {
  local current=$1
  printf '%s\n' "$table" | awk -F'\t' -v cur="$current" '
    { prim[$1] = 1; wt[$1]++; st[$1, $4]++ }
    END {
      for (p in prim) {
        urgent = st[p, "input"] + st[p, "done"]
        key = (p == cur ? 0 : urgent > 0 ? 1 : st[p, "working"] > 0 ? 2 : 3)
        printf "%d\t%s\t%d\t%d\t%d\t%d\n", key, p, wt[p], st[p, "input"], st[p, "done"], st[p, "working"]
      }
    }' | sort -t$'\t' -k1,1n -k2,2f | while IFS=$'\t' read -r _ p n inp dn wk; do
    name=$(basename "$p")
    summary=""
    [[ $inp -gt 0 ]] && summary+="${c_gold}● $inp${c_off}  "
    [[ $dn -gt 0 ]] && summary+="${c_iris}◆ $dn${c_off}  "
    [[ $wk -gt 0 ]] && summary+="${c_foam}○ $wk${c_off}  "
    word=worktrees
    [[ $n -eq 1 ]] && word=worktree
    printf '%-28s %s%2d %-9s%s   %s\t%s\n' "$name" "$c_muted" "$n" "$word" "$c_off" "$summary" "$p"
  done | fzf "${fzf_common[@]}" \
    --header=$'● needs you  ◆ your move  ○ working\nenter: show worktrees · esc: close' \
    --preview='git -C {2} worktree list 2>/dev/null' \
    --preview-window="down:40%:wrap" |
    cut -f2
}

# Worktree list for one repo, most urgent first.
pick_worktree() {
  local primary=$1
  printf '%s\n' "$table" | awk -F'\t' -v p="$primary" '
    $1 == p {
      r = ($4 == "input" ? 0 : $4 == "done" ? 1 : $4 == "working" ? 2 : $4 == "open" ? 3 : 4)
      print r "\t" $0
    }' | sort -t$'\t' -k1,1n -k3,3f | cut -f2- | while IFS=$'\t' read -r _ branch path state pane where; do
    if [[ $path == "$primary" ]]; then
      rel="(main checkout)"
    elif [[ $path == "$primary"/* ]]; then
      rel=${path#"$primary"/}
    else
      rel=${path/#$HOME/\~}
    fi
    label=""
    [[ $where == desktop ]] && label="${c_muted}desktop${c_off}"
    printf '%s %-40s %s%s%s  %s\t%s\t%s\t%s\n' "$(icon "$state")" "$branch" "$c_muted" "$rel" "$c_off" "$label" "$path" "$pane" "$branch"
  done | fzf "${fzf_common[@]}" \
    --header=$'● needs you  ◆ your move  ○ working  · open in tmux\nenter: jump · esc: all repos' \
    --preview='
      pane={3}
      if [ "$pane" != "-" ] && tmux list-panes -a -F "#{pane_id}" | grep -qx "$pane"; then
        tmux capture-pane -p -e -t "$pane" | grep -v "^[[:space:]]*$" | tail -40
      else
        git -C {2} status --short --branch 2>/dev/null
        echo
        git -C {2} log --oneline --decorate --color=always -10 2>/dev/null
      fi' \
    --preview-window="right:55%:wrap"
}

jump() {
  local primary=$1 path=$2 pane=$3 branch=$4 session window_name
  if [[ $pane != - ]] && tmux list-panes -a -F '#{pane_id}' | grep -qx "$pane"; then
    session=$(tmux display-message -p -t "$pane" '#{session_name}')
    tmux switch-client -t "$session"
    tmux select-window -t "$pane"
    tmux select-pane -t "$pane"
    return
  fi
  session=$(basename "$primary" | tr ':.' '__')
  window_name=${branch//\//-}
  tmux has-session -t="$session" 2>/dev/null || tmux new-session -ds "$session" -c "$primary"
  if ! tmux list-windows -t "$session" -F '#W' | grep -qx "$window_name"; then
    tmux new-window -t "$session:" -n "$window_name" -c "$path"
  fi
  tmux switch-client -t "$session"
  tmux select-window -t "$session:$window_name"
}

# Start on the repo you're in, if any.
start=${1:-$PWD}
current=""
if top=$(git -C "$start" rev-parse --show-toplevel 2>/dev/null); then
  current=$(git -C "$top" worktree list --porcelain | awk '/^worktree /{print substr($0, 10); exit}')
fi

repo=$current
while true; do
  if [[ -z $repo ]]; then
    repo=$(pick_repo "$current" || true)
    [[ -z $repo ]] && exit 0
  fi
  selected=$(pick_worktree "$repo" || true)
  if [[ -z $selected ]]; then
    repo=""
    continue
  fi
  IFS=$'\t' read -r _ path pane branch <<<"$selected"
  jump "$repo" "$path" "$pane" "$branch"
  exit 0
done
