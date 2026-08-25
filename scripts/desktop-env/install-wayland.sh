#!/bin/bash
set -euo pipefail

wayland_packages=(
    wayland-protocols
    wayland-utils
    xwayland
)

echo "Installing shared Wayland components..."
sudo apt update
sudo apt install -y "${wayland_packages[@]}"

echo "Wayland components installed. Choose a Wayland session from your login screen when one is available."
