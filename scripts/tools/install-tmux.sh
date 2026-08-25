#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"
tmux_template="$repo_root/configs/tmux/.tmux.conf"
tmux_config="$HOME/.tmux.conf"
tpm_dir="$HOME/.tmux/plugins/tpm"

if [ ! -f "$tmux_template" ]; then
    echo "Missing tmux configuration: $tmux_template" >&2
    exit 1
fi

echo "Installing tmux and the tmux plugin manager..."
sudo apt update
sudo apt install -y tmux git

if [ -f "$tmux_config" ] && [ ! -f "$tmux_config.new-setup.bak" ]; then
    cp "$tmux_config" "$tmux_config.new-setup.bak"
fi
cp "$tmux_template" "$tmux_config"

if [ -d "$tpm_dir/.git" ]; then
    git -C "$tpm_dir" pull --ff-only
else
    git clone https://github.com/tmux-plugins/tpm.git "$tpm_dir"
fi

"$tpm_dir/bin/install_plugins"
echo "tmux configuration and plugins installed."
