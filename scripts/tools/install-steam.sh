#!/bin/bash
set -euo pipefail

steam_package="steam-installer"

# Steam and many games require 32-bit libraries on 64-bit Ubuntu.
sudo apt install -y software-properties-common
sudo dpkg --add-architecture i386
sudo add-apt-repository -y multiverse
sudo apt update
sudo apt install -y "$steam_package"

applications_dir="$HOME/.local/share/applications"
mkdir -p "$applications_dir"
cat > "$applications_dir/steam.desktop" <<'EOF'
[Desktop Entry]
Name=Steam
Comment=Launch Steam
Exec=steam %U
Icon=steam
Terminal=false
Type=Application
Categories=Game;
MimeType=x-scheme-handler/steam;
StartupNotify=true
EOF

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir"
fi
