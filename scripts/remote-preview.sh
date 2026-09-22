#!/usr/bin/env bash
# Preview pane for remote-picker.sh. Reuses session-preview.sh verbatim —
# for a remote host it's piped over SSH and run against that host's own
# tmux, since the script only ever shells out to `tmux`.
set -uo pipefail

host="$1"
session="$2"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$host" == "local" ]]; then
  "$REPO_DIR/scripts/session-preview.sh" "$session"
else
  ssh -o BatchMode=yes -o ConnectTimeout=2 "$host" 'bash -s' -- "$session" \
    < "$REPO_DIR/scripts/session-preview.sh" 2>/dev/null
fi
