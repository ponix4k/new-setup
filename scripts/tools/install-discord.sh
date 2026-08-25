#!/bin/bash
set -euo pipefail

discord_channel="latest/stable"

sudo apt install -y snapd
sudo snap install discord --channel="$discord_channel"

applications_dir="$HOME/.local/share/applications"
mkdir -p "$applications_dir"
cat > "$applications_dir/discord_discord.desktop" <<'EOF'
[Desktop Entry]
Name=Discord
Comment=Voice and text chat
Exec=/snap/bin/discord
Icon=/snap/discord/current/meta/gui/discord.png
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupNotify=true
EOF

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir"
fi
