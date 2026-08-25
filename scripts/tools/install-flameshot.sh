#!/usr/bin/env bash
set -euo pipefail

echo "Installing Flameshot..."
sudo apt update
sudo apt install -y flameshot

echo "Flameshot installed. Run 'flameshot gui' to capture a region."
