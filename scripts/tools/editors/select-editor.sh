#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Select an editor to install:"
echo "  1) nano"
echo "  2) vim"
echo "  3) nvim"
echo "  4) emacs"
read -r -p "Enter choice [1-4]: " editor_choice

case "$editor_choice" in
    1) editor="nano" ;;
    2) editor="vim" ;;
    3) editor="nvim" ;;
    4) editor="emacs" ;;
    *)
        echo "Invalid selection: $editor_choice" >&2
        exit 1
        ;;
esac

bash "$script_dir/$editor/install.sh"
