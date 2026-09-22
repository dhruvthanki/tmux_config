#!/usr/bin/env bash
# Cross-host session switcher for `prefix + Space`.
#
# Lists local tmux sessions plus every host's sessions from config/hosts.conf,
# in one fzf popup. Enter attaches (local: switch-client; remote: opens a new
# local window running `ssh -t host tmux new -A -s session`, bootstrapping the
# host's dotfiles first if needed). Ctrl-K kills the highlighted session.
#
# Does NOT create new remote sessions from here — that's tmux-sessionizer's
# job, on whichever host you're already on. This only shows what already exists.
#
# Local-only for now: the activity dot (agent-status-hook.sh) is read from
# this machine's status dir. Wiring it up for remote hosts too is a cheap
# follow-on (one batched `ssh host cat status/*` per popup open) but isn't
# done yet, so remote rows always show a plain grey dot.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOSTS_FILE="$REPO_DIR/config/hosts.conf"
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=2)
STATUS_DIR="${XDG_RUNTIME_DIR:-/tmp/tmux-remote-$UID}/agent-status"

hosts() {
  [[ -f "$HOSTS_FILE" ]] || return 0
  grep -vE '^\s*(#|$)' "$HOSTS_FILE" | cut -f1
}

dot_for_local_session() {
  local session="$1" worst="none" pane state
  while IFS= read -r pane; do
    [[ -f "$STATUS_DIR/$pane" ]] || continue
    state="$(cat "$STATUS_DIR/$pane" 2>/dev/null)"
    case "$state" in
    waiting) worst="waiting" ;;
    working) [[ "$worst" != "waiting" ]] && worst="working" ;;
    esac
  done < <(tmux list-panes -t "$session" -s -F '#{pane_id}' 2>/dev/null)
  case "$worst" in
  waiting) printf '\033[33m\xe2\x97\x8f\033[0m' ;;
  working) printf '\033[32m\xe2\x97\x8f\033[0m' ;;
  *) printf '\033[90m\xe2\x97\x8b\033[0m' ;;
  esac
}

list_rows() {
  local tmp
  tmp="$(mktemp -d)"

  {
    while IFS=$'\t' read -r name windows; do
      [[ -z "$name" ]] && continue
      printf '%s\tlocal\t%s\t%s\n' "$(dot_for_local_session "$name")" "$name" "$windows"
    done < <(tmux list-sessions -F '#{session_name}	#{session_windows} win' 2>/dev/null)
  } >"$tmp/local" &

  local i=0
  while IFS= read -r h; do
    i=$((i + 1))
    {
      ssh "${SSH_OPTS[@]}" "$h" "tmux list-sessions -F '#{session_name}	#{session_windows} win'" 2>/dev/null |
        while IFS=$'\t' read -r name windows; do
          [[ -z "$name" ]] && continue
          printf '\033[90m\xe2\x97\x8b\033[0m\t%s\t%s\t%s\n' "$h" "$name" "$windows"
        done
    } >"$tmp/r$i" &
  done < <(hosts)

  wait
  cat "$tmp"/local "$tmp"/r* 2>/dev/null
  rm -rf "$tmp"
}

kill_session() {
  local host="$1" session="$2"
  if [[ "$host" == "local" ]]; then
    tmux kill-session -t "$session" 2>/dev/null
  else
    ssh "${SSH_OPTS[@]}" "$host" "tmux kill-session -t '$session'" 2>/dev/null
  fi
}

case "${1:-}" in
--list)
  list_rows
  exit 0
  ;;
--kill)
  kill_session "$2" "$3"
  exit 0
  ;;
esac

selection="$(list_rows | fzf --ansi \
  --delimiter=$'\t' --with-nth=1,2,3,4 \
  --header ' enter: attach   ctrl-k: kill session   esc: cancel' \
  --preview "$REPO_DIR/scripts/remote-preview.sh {2} {3}" \
  --preview-window=right:60% \
  --bind "ctrl-k:execute-silent($REPO_DIR/scripts/remote-picker.sh --kill {2} {3})+reload($REPO_DIR/scripts/remote-picker.sh --list)")"

[[ -z "$selection" ]] && exit 0

IFS=$'\t' read -r _dot host session _windows <<<"$selection"
[[ -z "$host" || -z "$session" ]] && exit 0

if [[ "$host" == "local" ]]; then
  tmux switch-client -t "$session"
else
  "$REPO_DIR/scripts/remote-bootstrap.sh" "$host"
  tmux new-window -n "${host}:${session}" "ssh -t $host 'tmux new-session -A -s $session'"
fi
