#!/bin/bash
set -euo pipefail

vscode_package="${VSCODE_PACKAGE:-code}"
vscode_version="${VSCODE_VERSION:-}"
microsoft_keyring="/usr/share/keyrings/microsoft.gpg"
vscode_sources="/etc/apt/sources.list.d/vscode.sources"

case "$vscode_package" in
    code|code-insiders) ;;
    *)
        echo "VSCODE_PACKAGE must be 'code' or 'code-insiders'." >&2
        exit 1
        ;;
esac

echo "Installing the Microsoft VS Code repository..."
sudo apt update
sudo apt install -y ca-certificates curl gpg

microsoft_key="$(mktemp)"
trap 'rm -f "$microsoft_key"' EXIT
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc -o "$microsoft_key"
sudo gpg --batch --yes --dearmor -o "$microsoft_keyring" "$microsoft_key"

sudo tee "$vscode_sources" >/dev/null <<EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64 arm64 armhf
Signed-By: $microsoft_keyring
EOF

sudo apt update
if [ -n "$vscode_version" ]; then
    sudo apt install -y "$vscode_package=$vscode_version"
else
    sudo apt install -y "$vscode_package"
fi

applications_dir="$HOME/.local/share/applications"
mkdir -p "$applications_dir"
cat > "$applications_dir/vscode.desktop" <<EOF
[Desktop Entry]
Name=Visual Studio Code
Comment=Edit and debug code
Exec=/usr/bin/$vscode_package %F
Icon=$vscode_package
Terminal=false
Type=Application
Categories=Development;IDE;TextEditor;
MimeType=text/plain;inode/directory;
StartupNotify=true
EOF

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir"
fi

echo "Visual Studio Code installed. Launch it from the application menu or run: $vscode_package"
