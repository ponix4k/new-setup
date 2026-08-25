#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
config_source="$repo_root/configs/terminals/ghostty.conf"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
config_file="$config_dir/config.ghostty"
xdg_terminal_file="${XDG_CONFIG_HOME:-$HOME/.config}/xdg-terminals.list"
os="$(uname -s)"

if [ ! -f "$config_source" ]; then
    echo "Missing Ghostty configuration: $config_source" >&2
    exit 1
fi

echo "Installing Ghostty..."
if [ "$os" = "Darwin" ]; then
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required to install Ghostty on macOS." >&2
        exit 1
    fi
    brew install --cask ghostty
elif command -v apt-get >/dev/null 2>&1; then
    if ! apt-cache show ghostty >/dev/null 2>&1; then
        echo "Ghostty is not available from this system's configured APT repositories." >&2
        echo "Choose Kitty or add a repository that packages Ghostty for this distribution." >&2
        exit 1
    fi
    sudo apt-get update
    sudo apt-get install -y ghostty
else
    echo "Unsupported operating system: $os" >&2
    exit 1
fi

mkdir -p "$config_dir" "$HOME/backups"
if [ -f "$config_file" ] && [ ! -f "$HOME/backups/ghostty-config.new-setup.bak" ]; then
    cp "$config_file" "$HOME/backups/ghostty-config.new-setup.bak"
fi
cp "$config_source" "$config_file"

if [ "$os" = "Darwin" ]; then
    if ! command -v duti >/dev/null 2>&1; then
        brew install duti
    fi
    duti -s com.mitchellh.ghostty ssh
    duti -s com.mitchellh.ghostty telnet
else
    ghostty_bin="$(command -v ghostty)"
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$ghostty_bin" 50
    sudo update-alternatives --set x-terminal-emulator "$ghostty_bin"
    if [ -f "$xdg_terminal_file" ] && [ ! -f "$HOME/backups/xdg-terminals.list.new-setup.bak" ]; then
        cp "$xdg_terminal_file" "$HOME/backups/xdg-terminals.list.new-setup.bak"
    fi
    printf '%s\n' 'com.mitchellh.ghostty.desktop' > "$xdg_terminal_file"
fi

echo "Ghostty installed and configured as the default terminal where supported by $os."
