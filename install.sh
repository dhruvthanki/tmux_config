#!/usr/bin/env bash
# Idempotent setup, safe to re-run. Run once per machine after cloning this
# repo to ~/.config/tmux (remote-bootstrap.sh runs this automatically too).
#
#   git clone git@github-personal:dhruvthanki/tmux_config.git ~/.config/tmux
#   git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
#   ~/.config/tmux/install.sh
#   tmux   # then prefix + I to install plugins
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

chmod +x "$REPO_DIR"/scripts/*.sh "$REPO_DIR/scripts/tmux-sessionizer"

ln -sf "$REPO_DIR/scripts/tmux-sessionizer" "$BIN_DIR/tmux-sessionizer"

mkdir -p "$HOME/.config/tmux-sessionizer"
ln -sf "$REPO_DIR/config/tmux-sessionizer.conf" "$HOME/.config/tmux-sessionizer/tmux-sessionizer.conf"

echo "install.sh: done ($REPO_DIR)."
