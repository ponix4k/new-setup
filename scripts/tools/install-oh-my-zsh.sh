#!/bin/bash
set -euo pipefail

oh_my_zsh_installer_url="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

sudo apt install -y zsh curl

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL "$oh_my_zsh_installer_url")"
fi

applications_dir="$HOME/.local/share/applications"
mkdir -p "$applications_dir"
cat > "$applications_dir/zsh-terminal.desktop" <<'EOF'
[Desktop Entry]
Name=Zsh Terminal
Comment=Open a terminal running Zsh and Oh My Zsh
Exec=/usr/bin/x-terminal-emulator -e /usr/bin/zsh -l
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
StartupNotify=true
EOF

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir"
fi
