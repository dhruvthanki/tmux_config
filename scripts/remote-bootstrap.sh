#!/usr/bin/env bash
# Ensures <host> has this dotfiles repo, TPM + plugins, and the symlinks from
# install.sh in place — so a remote-picker.sh attach never lands on unbound
# keys or missing tmux-sessionizer.
#
# Cheap by default: skips the whole thing if the host's cached synced commit
# already matches this repo's HEAD. Run with --force to resync regardless.
#
# Note: this can only reach a host that already has SSH access to the git
# remote (e.g. the personal deploy key already placed there). It provisions
# tmux config, not git credentials — a brand-new machine still needs that
# one manual step first.
set -uo pipefail

host="${1:?usage: remote-bootstrap.sh <host> [--force]}"
force="${2:-}"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-remote"
STATE_FILE="$STATE_DIR/$host.synced"
mkdir -p "$STATE_DIR"

local_sha="$(git -C "$REPO_DIR" rev-parse HEAD)"

if [[ "$force" != "--force" && "$(cat "$STATE_FILE" 2>/dev/null)" == "$local_sha" ]]; then
  exit 0
fi

remote_url="$(git -C "$REPO_DIR" remote get-url origin)"

ssh -o BatchMode=yes "$host" "REMOTE_URL='$remote_url' bash -s" <<'REMOTE'
set -eu
REPO="$HOME/.config/tmux"
if [[ ! -d "$REPO/.git" ]]; then
  git clone "$REMOTE_URL" "$REPO"
else
  git -C "$REPO" pull --ff-only
fi
[[ -d "$REPO/plugins/tpm" ]] || git clone https://github.com/tmux-plugins/tpm "$REPO/plugins/tpm"
"$REPO/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 || true
bash "$REPO/install.sh"
REMOTE

echo "$local_sha" >"$STATE_FILE"
