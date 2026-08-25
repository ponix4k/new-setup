#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kitty_config="${XDG_CONFIG_HOME:-$HOME/.config}/kitty/kitty.conf"
ghostty_config="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config.ghostty"

if command -v kitty >/dev/null 2>&1 && [ -f "$kitty_config" ]; then
    echo "Kitty and its configuration are already installed; skipping terminal selection."
    exit 0
fi

if command -v ghostty >/dev/null 2>&1 && [ -f "$ghostty_config" ]; then
    echo "Ghostty and its configuration are already installed; skipping terminal selection."
    exit 0
fi

echo "Select the terminal to install and make the system default:"
echo "  1) Kitty"
echo "  2) Ghostty"
read -r -p "Enter choice [1-2]: " terminal_choice

case "$terminal_choice" in
    1) installer="install-kitty.sh" ;;
    2) installer="install-ghostty.sh" ;;
    *)
        echo "Invalid selection: $terminal_choice" >&2
        exit 1
        ;;
esac

bash "$script_dir/$installer"
