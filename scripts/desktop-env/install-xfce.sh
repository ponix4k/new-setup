#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
xfce_packages=(
    xfce4
    xfce4-goodies
    lightdm
    lightdm-gtk-greeter
)

echo "Installing XFCE..."
sudo apt update
sudo env DEBIAN_FRONTEND=noninteractive apt install -y "${xfce_packages[@]}"

# XFCE 4.20's Wayland support remains experimental; install the common stack
# without forcing Wayland as the default XFCE session.
bash "$script_dir/install-wayland.sh"

echo "XFCE installed. Select 'Xfce Session' from your login screen, then log in."
