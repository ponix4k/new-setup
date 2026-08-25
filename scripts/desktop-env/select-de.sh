#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Select a desktop environment to install:"
echo "  1) XFCE"
echo "  2) KDE Plasma"
echo "  3) Wayland components only"
echo "  4) Skip desktop installation"
read -r -p "Enter choice [1-4]: " de_choice

case "$de_choice" in
    1)
        bash "$script_dir/install-xfce.sh"
        ;;
    2)
        bash "$script_dir/install-plasma.sh"
        ;;
    3)
        bash "$script_dir/install-wayland.sh"
        ;;
    4)
        echo "Skipping desktop environment installation."
        ;;
    *)
        echo "Invalid selection: $de_choice" >&2
        exit 1
        ;;
esac
