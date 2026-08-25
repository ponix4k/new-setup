#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plasma_packages=(
    kde-plasma-desktop
    sddm
)

echo "Installing KDE Plasma..."
sudo apt update
sudo env DEBIAN_FRONTEND=noninteractive apt install -y "${plasma_packages[@]}"

bash "$script_dir/install-wayland.sh"

echo "Plasma installed. Select 'Plasma (Wayland)' from your login screen, then log in."
