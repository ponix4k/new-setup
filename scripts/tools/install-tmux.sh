#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"
tmux_template="$repo_root/configs/tmux/.tmux.conf"
tmux_config="$HOME/.tmux.conf"
tpm_dir="$HOME/.tmux/plugins/tpm"
plugin_dir="$HOME/.tmux/plugins"

if [ ! -f "$tmux_template" ]; then
    echo "Missing tmux configuration: $tmux_template" >&2
    exit 1
fi

if command -v tmux >/dev/null 2>&1 \
    && [ -f "$tmux_config" ] \
    && cmp -s "$tmux_template" "$tmux_config" \
    && [ -d "$tpm_dir/.git" ] \
    && [ -d "$plugin_dir/tmux-sensible/.git" ] \
    && [ -d "$plugin_dir/dracula/.git" ]; then
    echo "tmux and all configured plugins are already installed; skipping."
    exit 0
fi

echo "Installing tmux and the tmux plugin manager..."
sudo apt update
sudo apt install -y tmux git

if [ -f "$tmux_config" ] && [ ! -f "$tmux_config.new-setup.bak" ]; then
    cp "$tmux_config" "$tmux_config.new-setup.bak"
fi
cp "$tmux_template" "$tmux_config"

if [ -d "$tpm_dir/.git" ]; then
    echo "TPM is already cloned."
else
    git clone https://github.com/tmux-plugins/tpm.git "$tpm_dir"
fi

bootstrap_session="new-setup-tpm-$$"
tmux new-session -d -s "$bootstrap_session"
trap 'tmux kill-session -t "$bootstrap_session" 2>/dev/null || true' EXIT
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$plugin_dir/"
"$tpm_dir/bin/install_plugins"
tmux kill-session -t "$bootstrap_session" 2>/dev/null || true
trap - EXIT
echo "tmux configuration and plugins installed."
