#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Select the terminal to install and make the system default:"
echo "  1) Kitty"
echo "  2) Ghostty"
echo "  3) Skip terminal installation"
read -r -p "Enter choice [1-3]: " terminal_choice

case "$terminal_choice" in
    1) installer="install-kitty.sh" ;;
    2) installer="install-ghostty.sh" ;;
    3)
        echo "Skipping terminal installation."
        exit 0
        ;;
    *)
        echo "Invalid selection: $terminal_choice" >&2
        exit 1
        ;;
esac

bash "$script_dir/$installer"
