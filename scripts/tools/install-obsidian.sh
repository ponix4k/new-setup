#!/bin/bash
set -euo pipefail

obsidian_channel="latest/stable"

sudo apt install -y snapd
sudo snap install obsidian --classic --channel="$obsidian_channel"

applications_dir="$HOME/.local/share/applications"
mkdir -p "$applications_dir"
cat > "$applications_dir/obsidian_obsidian.desktop" <<'EOF'
[Desktop Entry]
Name=Obsidian
Comment=Open a local knowledge base
Exec=/snap/bin/obsidian %U
Icon=/snap/obsidian/current/meta/gui/icon.png
Terminal=false
Type=Application
Categories=Office;
MimeType=x-scheme-handler/obsidian;
StartupNotify=true
EOF

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir"
fi
