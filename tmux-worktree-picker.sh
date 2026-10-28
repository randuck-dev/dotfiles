#!/usr/bin/env bash

# Worktree picker — every repo under ~/projects, every worktree of each
# (including Claude desktop's .claude/worktrees/*), and what Claude is
# doing in each one (from bin/claude-status).
#
#   tmux-worktree-picker.sh [dir]   worktrees of the repo containing dir;
#                                   esc goes to the repo list (prefix W)
#   tmux-worktree-picker.sh --all   every Claude session, most urgent
#                                   first (prefix A)
#
# Enter jumps to the worktree: the tmux pane running Claude there, else
# any pane already in it, else a new window in the repo's session (same
# session naming as the sessionizer).
#
# The --rows and --preview modes are what fzf calls back into.

set -euo pipefail

self="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
status_cmd="$(dirname "$self")/bin/claude-status"
SEARCH_PATHS=("$HOME/projects" "$HOME/oss-projects")

# ── data ─────────────────────────────────────────────────────────
# primary<TAB>branch<TAB>path for every worktree of every repo found.
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

# Print fzf rows. Every row is: display<TAB>key fields... (never empty;
# "-" stands for none), so fzf shows field 1 and we read the rest back.
#   repos <current>   display, primary
#   wt <primary>      display, path, pane, branch, primary, session id
#   all               same fields as wt
rows() {
  local mode=$1 arg=${2:-}
  jq -nr \
    --arg mode "$mode" --arg arg "$arg" --arg home "$HOME" --argjson now "$(date +%s)" \
    --rawfile wt <(gather_worktrees) \
    --rawfile panes <(tmux list-panes -a -F '#{pane_id} #{pane_current_path}' 2>/dev/null || true) \
    --argjson sessions "$("$status_cmd" json 2>/dev/null || echo '[]')" '
    # colours (Rose Pine Moon)
    def c($hex): "\u001b[38;2;\($hex)m";
    def gold: c("246;193;119"); def iris: c("196;167;231"); def foam: c("156;207;216");
    def text: c("224;222;244"); def subtle: c("144;140;170"); def muted: c("110;106;134");
    def off: "\u001b[0m";

    def pad($n): (if length > $n then .[0:$n-1] + "…" else . end) as $s | $s + (" " * ($n - ($s | length)));
    def lpad($n): (" " * ($n - length)) + .;
    def nz: if . == null or . == "" then "-" else . end;
    def age: ($now - .) as $d
      | if $d < 10 then "now" elif $d < 60 then "\($d)s" elif $d < 3600 then "\($d / 60 | floor)m"
        elif $d < 86400 then "\($d / 3600 | floor)h" else "\($d / 86400 | floor)d" end;
    def rank: {"input": 4, "done": 3, "working": 2, "open": 1}[.] // 0;
    def icon: {"input": (gold + "●"), "done": (iris + "◆"), "working": (foam + "○"), "open": (muted + "·")}[.] // " ";
    def colour: {"input": gold, "done": iris, "working": foam}[.] // muted;
    def words($detail): if . == "input" then (if ($detail // "" | test("permission"; "i")) then "needs permission" else "needs input" end)
      elif . == "done" then "your move" elif . == "working" then "working" elif . == "open" then "open in tmux" else "" end;
    def base: split("/") | map(select(. != "")) | last // "";

    ($wt | split("\n") | map(select(length > 0) | split("\t") | {primary: .[0], branch: .[1], path: .[2]})) as $W
    | ($panes | split("\n") | map(select(length > 0) | capture("^(?<id>[^ ]+) (?<path>.*)$"))) as $P
    | def owner($cwd): [$W[] | select(.path as $p | $cwd == $p or ($cwd | startswith($p + "/")))] | max_by(.path | length) | .path;
    ($sessions | map(. + {owner: owner(.cwd)})) as $S
    | ($P | map(. + {owner: owner(.path)})) as $PP

    # One entry per worktree with its most urgent session and a pane.
    | ($W | map(
        . as $w
        | ([$S[] | select(.owner == $w.path)] | sort_by([(.state | rank), .since]) | reverse) as $ss
        | ([$PP[] | select(.owner == $w.path)]) as $pp
        | . + {
            sessions: $ss, top: $ss[0],
            state: ($ss[0].state // (if ($pp | length) > 0 then "open" else "idle" end)),
            pane: ((if ($ss[0].tmux_pane // "") != "" then $ss[0].tmux_pane else $pp[0].id end) | nz)
          })) as $E

    | def row($repo):
        # A worktree (or session) line: icon, title, state, age, tags.
        ((.top.title // "") | if . == "" then null else . end) as $title
        | (.top.detail // "") as $detail
        | (.top.since // .top.updated // $now) as $since
        | (if .path == .primary then "main checkout" else .branch end) as $name
        | (if $title then text + ($title | pad(48)) else subtle + ($name | pad(48)) end) as $label
        | ((.state | colour) + ((.state | words($detail)) | pad(17))
            + muted + ((if .top then ($since | age) else "" end) | lpad(4))) as $status
        | ([ (if $repo != "" then subtle + ($repo | pad(16)) + muted else empty end),
             (if .top and (.top.tmux_pane // "") == "" then "desktop" else empty end),
             (if (.sessions | length) > 1 then "+\((.sessions | length) - 1)" else empty end) ]
           | join(" ")) as $tags
        | (.state | icon) + " " + $label + "  " + $status + "  " + muted + $tags + off;

    if $mode == "repos" then
      $E | group_by(.primary) | map({
          primary: .[0].primary,
          n: length,
          input: map(select(.state == "input")) | length,
          done: map(select(.state == "done")) | length,
          working: map(select(.state == "working")) | length
        })
      | sort_by([(if .primary == $arg then 0 elif .input > 0 then 1 elif .done > 0 then 2 elif .working > 0 then 3 else 4 end), (.primary | base | ascii_downcase)])
      | .[]
      | text + (.primary | base | pad(28)) + muted + ("\(.n)" | lpad(3)) + " " + ((if .n == 1 then "worktree" else "worktrees" end) | pad(11))
        + (if .input > 0 then gold + "● \(.input)  " else "" end)
        + (if .done > 0 then iris + "◆ \(.done)  " else "" end)
        + (if .working > 0 then foam + "○ \(.working)" else "" end) + off
        + "\t" + .primary
    elif $mode == "wt" then
      $E | map(select(.primary == $arg))
      | sort_by([-(.state | rank), (if .path == .primary then 0 else 1 end), -(.top.since // 0), .branch])
      | .[] | row("") + "\t" + .path + "\t" + .pane + "\t" + (.branch | nz) + "\t" + .primary + "\t" + (.top.session_id | nz)
    else
      # Every Claude session across all repos, most urgent first.
      [$S[] | . as $s
        | ($E | map(select(.path == $s.owner)) | .[0]) as $e
        | {primary: ($e.primary // $s.cwd), path: ($e.path // $s.cwd), branch: ($e.branch // ""),
           top: $s, sessions: [$s], state: $s.state,
           pane: ((if ($s.tmux_pane // "") != "" then $s.tmux_pane else ($e.pane // "-") end) | nz)}]
      | sort_by([-(.state | rank), -(.top.since // 0)])
      | .[] | row(.primary | base) + "\t" + .path + "\t" + .pane + "\t" + (.branch | nz) + "\t" + .primary + "\t" + (.top.session_id | nz)
    end
  '
}

# Preview for one worktree: what Claude last said and what you last
# asked, else the live pane, else git status.
preview() {
  local path=$1 pane=$2 branch=$3 sid=$4 t
  # View: claude (last prompt and reply), changes (diff against the target
  # branch, see bin/git-review) or git (status and log). ctrl-t cycles them
  # via the file in $PICKER_VIEW_FILE so the choice sticks as you move.
  local view=${5:-$(cat "${PICKER_VIEW_FILE:-/dev/null}" 2>/dev/null || true)}
  view=${view:-claude}
  local iris=$'\033[38;2;196;167;231m' muted=$'\033[38;2;110;106;134m' foam=$'\033[38;2;156;207;216m' off=$'\033[0m'
  printf '%s%s  %s%s\n\n' "$muted" "$branch" "${path/#$HOME/~}" "$off"

  if [[ $view == changes ]]; then
    "$(dirname "$self")/bin/git-review" --preview "$path" "${FZF_PREVIEW_COLUMNS:-100}"
    return
  fi

  t=""
  if [[ $view == claude && $sid != - ]]; then
    t=$("$status_cmd" json 2>/dev/null | jq -r --arg sid "$sid" 'map(select(.session_id == $sid)) | .[0].transcript // empty' 2>/dev/null || true)
  fi

  if [[ -n $t && -f $t ]]; then
    local said asked
    # Claude's last message (its last text block).
    said=$(tail -n 600 "$t" | jq -R 'fromjson? // empty' | jq -rs '
      [.[] | select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text]
      | last // empty' 2>/dev/null || true)
    asked=$(grep '"type":"last-prompt"' "$t" | tail -1 | jq -r '.lastPrompt // empty' 2>/dev/null || true)
    if [[ -n $asked ]]; then
      printf '%syou%s  %s\n\n' "$foam" "$off" "$asked"
    fi
    if [[ -n $said ]]; then
      printf '%sclaude%s\n%s\n' "$iris" "$off" "$said"
    fi
    return
  fi

  if [[ $view == claude && $pane != - ]] && tmux list-panes -a -F '#{pane_id}' | grep -qx "$pane"; then
    tmux capture-pane -p -e -t "$pane" | grep -v '^[[:space:]]*$' | tail -40
    return
  fi

  git -C "$path" -c color.status=always status --short --branch 2>/dev/null
  echo
  git -C "$path" diff --stat --color=always HEAD 2>/dev/null | tail -15
  echo
  git -C "$path" log --oneline --decorate --color=always -12 2>/dev/null
}

jump() {
  local path=$1 pane=$2 branch=$3 primary=$4 session window_name
  if [[ $pane != - ]] && tmux list-panes -a -F '#{pane_id}' | grep -qx "$pane"; then
    session=$(tmux display-message -p -t "$pane" '#{session_name}')
    tmux switch-client -t "$session"
    tmux select-window -t "$pane"
    tmux select-pane -t "$pane"
    return
  fi
  session=$(basename "$primary" | tr ':.' '__')
  [[ $branch == - ]] && branch=$(basename "$path")
  window_name=${branch//\//-}
  tmux has-session -t="$session" 2>/dev/null || tmux new-session -ds "$session" -c "$primary"
  if ! tmux list-windows -t "$session" -F '#W' | grep -qx "$window_name"; then
    tmux new-window -t "$session:" -n "$window_name" -c "$path"
  fi
  tmux switch-client -t "$session"
  tmux select-window -t "$session:$window_name"
}

# ── fzf ──────────────────────────────────────────────────────────
fzf_ui() {
  local label=$1 footer=$2
  shift 2
  fzf --ansi --reverse --no-sort --delimiter=$'\t' --with-nth=1 \
    --border=rounded --border-label=" $label " --border-label-pos=3 \
    --prompt="  " --pointer="▌" --gutter=" " --marker="" \
    --info=inline-right --no-scrollbar --separator="─" \
    --footer="$footer" --footer-border=none \
    --color='fg:#908caa,fg+:#e0def4,bg+:#2a273f,hl:#c4a7e7,hl+:#c4a7e7,prompt:#c4a7e7,pointer:#c4a7e7,info:#6e6a86,border:#44415a,label:#c4a7e7,footer:#6e6a86,separator:#393552,preview-border:#393552,query:#e0def4' \
    "$@"
}

q() { printf '%q' "$1"; }

pick_repo() {
  local current=$1
  rows repos "$current" | fzf_ui "repos" "enter worktrees · ctrl-r refresh · esc close" \
    --bind "ctrl-r:reload($(q "$self") --rows repos $(q "$current"))" \
    --preview "git -C {2} worktree list 2>/dev/null | sed \"s#\$HOME#~#\"" \
    --preview-window="down,35%,border-top,wrap" |
    cut -f2
}

# Keys shared by the worktree and all-sessions pickers.
#   ctrl-g  lazygit in the highlighted worktree (back to the picker on quit)
#   ctrl-d  review the branch in Neovim (diffview, via bin/git-review)
#   ctrl-t  cycle the preview: Claude, changes, git
#   ctrl-r  refresh
wt_binds() {
  local reload=$1
  local preview_cmd="$(q "$self") --preview {2} {3} {4} {6}"
  printf '%s\0' \
    --bind "ctrl-r:reload($reload)" \
    --bind "ctrl-g:execute($(q "$self") --lazygit {2})+reload($reload)" \
    --bind "ctrl-d:execute($(q "$(dirname "$self")/bin/git-review") {2})+reload($reload)" \
    --bind "ctrl-t:execute-silent($(q "$self") --toggle-view)+refresh-preview+transform-preview-label($(q "$self") --view-label)" \
    --preview "$preview_cmd" \
    --preview-label " claude " \
    --preview-window "down,45%,border-top,wrap"
}

pick_worktree() {
  local primary=$1 label=$2 footer=$3 args=()
  while IFS= read -r -d '' a; do args+=("$a"); done < <(wt_binds "$(q "$self") --rows wt $(q "$primary")")
  rows wt "$primary" | fzf_ui "$label" "$footer" "${args[@]}"
}

pick_all() {
  local args=()
  while IFS= read -r -d '' a; do args+=("$a"); done < <(wt_binds "$(q "$self") --rows all")
  rows all | fzf_ui "claude sessions" "enter jump · ctrl-d review · ctrl-g lazygit · ctrl-t preview · ctrl-r refresh · esc close" "${args[@]}"
}

main() {
  local start=${1:-$PWD} current="" top repo selected path pane branch primary
  if top=$(git -C "$start" rev-parse --show-toplevel 2>/dev/null); then
    current=$(git -C "$top" worktree list --porcelain | awk '/^worktree /{print substr($0, 10); exit}')
  fi
  repo=$current
  while true; do
    if [[ -z $repo ]]; then
      repo=$(pick_repo "$current" || true)
      [[ -z $repo ]] && exit 0
    fi
    selected=$(pick_worktree "$repo" "$(basename "$repo")" "enter jump · ctrl-d review · ctrl-g lazygit · ctrl-t preview · ctrl-r refresh · esc repos" || true)
    if [[ -z $selected ]]; then
      repo=""
      continue
    fi
    IFS=$'\t' read -r _ path pane branch primary <<<"$selected"
    jump "$path" "$pane" "$branch" "$primary"
    exit 0
  done
}

if [[ ${1:-} == "" || ${1:-} == --all || ${1:-} != --* ]]; then
  PICKER_VIEW_FILE=$(mktemp "${TMPDIR:-/tmp}/worktree-picker.XXXXXX")
  export PICKER_VIEW_FILE
  trap 'rm -f "$PICKER_VIEW_FILE"' EXIT
fi

case ${1:-} in
  --toggle-view)
    case $(cat "$PICKER_VIEW_FILE" 2>/dev/null) in
      changes) echo git ;;
      git) echo claude ;;
      *) echo changes ;;
    esac >"$PICKER_VIEW_FILE"
    ;;
  --view-label)
    v=$(cat "$PICKER_VIEW_FILE" 2>/dev/null || true)
    echo " ${v:-claude} "
    ;;
  --lazygit)
    if command -v lazygit >/dev/null; then
      cd "$2" && lazygit
    else
      echo "lazygit isn't installed (it's in nix/common.nix; rebuild to get it)."
      read -r -n 1 -p "press any key" || true
    fi
    ;;
  --rows) rows "$2" "${3:-}" ;;
  --preview) preview "$2" "$3" "$4" "$5" "${6:-}" ;;
  --all)
    selected=$(pick_all || true)
    [[ -z $selected ]] && exit 0
    IFS=$'\t' read -r _ path pane branch primary <<<"$selected"
    jump "$path" "$pane" "$branch" "$primary"
    ;;
  *) main "$@" ;;
esac
