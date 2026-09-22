#!/usr/bin/env bash
# Called from Claude Code / Codex lifecycle hooks to record this pane's
# activity state, for the dot next to local sessions in remote-picker.sh.
#
# Usage: agent-status-hook.sh <working|waiting|idle>
#
# Wire into Claude Code hooks (~/.claude/settings.json), e.g.:
#   "PreToolUse":  agent-status-hook.sh working
#   "Notification"/permission-wait hooks: agent-status-hook.sh waiting
#   "Stop":        agent-status-hook.sh idle
# Codex: same idea via its own hooks config — see its docs for event names.
#
# One file per pane, named by $TMUX_PANE, so remote-picker.sh only has to
# read files, never talk to this script directly.
set -uo pipefail

state="${1:?usage: agent-status-hook.sh <working|waiting|idle>}"
dir="${XDG_RUNTIME_DIR:-/tmp/tmux-remote-$UID}/agent-status"
mkdir -p "$dir"

[[ -n "${TMUX_PANE:-}" ]] || exit 0
echo "$state" >"$dir/$TMUX_PANE"
