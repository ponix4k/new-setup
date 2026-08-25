#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
config_source="$repo_root/configs/terminals/kitty.conf"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
config_file="$config_dir/kitty.conf"
xdg_terminal_file="${XDG_CONFIG_HOME:-$HOME/.config}/xdg-terminals.list"

if [ ! -f "$config_source" ]; then
    echo "Missing Kitty configuration: $config_source" >&2
    exit 1
fi

echo "Installing Kitty..."
sudo apt update
sudo apt install -y kitty

mkdir -p "$config_dir" "$HOME/backups"
if [ -f "$config_file" ] && [ ! -f "$HOME/backups/kitty.conf.new-setup.bak" ]; then
    cp "$config_file" "$HOME/backups/kitty.conf.new-setup.bak"
fi
cp "$config_source" "$config_file"

kitty_bin="$(command -v kitty)"
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$kitty_bin" 50
sudo update-alternatives --set x-terminal-emulator "$kitty_bin"
if [ -f "$xdg_terminal_file" ] && [ ! -f "$HOME/backups/xdg-terminals.list.new-setup.bak" ]; then
    cp "$xdg_terminal_file" "$HOME/backups/xdg-terminals.list.new-setup.bak"
fi
printf '%s\n' 'kitty.desktop' > "$xdg_terminal_file"

echo "Kitty installed and selected as the default terminal. Log out and back in if desktop shortcuts still open the previous terminal."
