#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
config_source="$repo_root/configs/terminals/kitty.conf"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
config_file="$config_dir/kitty.conf"
xdg_terminal_file="${XDG_CONFIG_HOME:-$HOME/.config}/xdg-terminals.list"
os="$(uname -s)"

if [ ! -f "$config_source" ]; then
    echo "Missing Kitty configuration: $config_source" >&2
    exit 1
fi

echo "Installing Kitty..."
if [ "$os" = "Darwin" ]; then
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required to install Kitty on macOS." >&2
        exit 1
    fi
    brew install --cask kitty
elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y kitty
else
    echo "Unsupported operating system: $os" >&2
    exit 1
fi

mkdir -p "$config_dir" "$HOME/backups"
if [ -f "$config_file" ] && [ ! -f "$HOME/backups/kitty.conf.new-setup.bak" ]; then
    cp "$config_file" "$HOME/backups/kitty.conf.new-setup.bak"
fi
cp "$config_source" "$config_file"

if [ "$os" = "Darwin" ]; then
    # macOS has no single system-wide default-terminal preference. Register
    # Kitty for the URL schemes Launch Services uses to open remote shells.
    if ! command -v duti >/dev/null 2>&1; then
        brew install duti
    fi
    duti -s net.kovidgoyal.kitty ssh
    duti -s net.kovidgoyal.kitty telnet
else
    kitty_bin="$(command -v kitty)"
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$kitty_bin" 50
    sudo update-alternatives --set x-terminal-emulator "$kitty_bin"
    if [ -f "$xdg_terminal_file" ] && [ ! -f "$HOME/backups/xdg-terminals.list.new-setup.bak" ]; then
        cp "$xdg_terminal_file" "$HOME/backups/xdg-terminals.list.new-setup.bak"
    fi
    printf '%s\n' 'kitty.desktop' > "$xdg_terminal_file"
fi

echo "Kitty installed and configured as the default terminal where supported by $os."
