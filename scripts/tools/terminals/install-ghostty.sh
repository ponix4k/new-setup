#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
config_source="$repo_root/configs/terminals/ghostty.conf"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
config_file="$config_dir/config.ghostty"
xdg_terminal_file="${XDG_CONFIG_HOME:-$HOME/.config}/xdg-terminals.list"

if [ ! -f "$config_source" ]; then
    echo "Missing Ghostty configuration: $config_source" >&2
    exit 1
fi

if ! apt-cache show ghostty >/dev/null 2>&1; then
    echo "Ghostty is not available from this system's configured APT repositories." >&2
    echo "Choose Kitty or add a repository that packages Ghostty for this distribution." >&2
    exit 1
fi

echo "Installing Ghostty..."
sudo apt update
sudo apt install -y ghostty

mkdir -p "$config_dir" "$HOME/backups"
if [ -f "$config_file" ] && [ ! -f "$HOME/backups/ghostty-config.new-setup.bak" ]; then
    cp "$config_file" "$HOME/backups/ghostty-config.new-setup.bak"
fi
cp "$config_source" "$config_file"

ghostty_bin="$(command -v ghostty)"
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$ghostty_bin" 50
sudo update-alternatives --set x-terminal-emulator "$ghostty_bin"
if [ -f "$xdg_terminal_file" ] && [ ! -f "$HOME/backups/xdg-terminals.list.new-setup.bak" ]; then
    cp "$xdg_terminal_file" "$HOME/backups/xdg-terminals.list.new-setup.bak"
fi
printf '%s\n' 'com.mitchellh.ghostty.desktop' > "$xdg_terminal_file"

echo "Ghostty installed and selected as the default terminal. Log out and back in if desktop shortcuts still open the previous terminal."
