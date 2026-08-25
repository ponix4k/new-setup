#!/bin/bash
set -euo pipefail

vmware_bundle="${1:-${VMWARE_BUNDLE:-}}"

if [ -z "$vmware_bundle" ]; then
    shopt -s nullglob
    bundles=("$HOME"/Downloads/VMware-Workstation-Full-*.bundle)
    shopt -u nullglob

    if [ "${#bundles[@]}" -eq 1 ]; then
        vmware_bundle="${bundles[0]}"
    elif [ -t 0 ]; then
        echo "Download the Linux VMware Workstation Pro .bundle from the Broadcom Support Portal."
        read -r -p "Path to the VMware .bundle, or leave blank to skip: " vmware_bundle
    fi
fi

if [ -z "$vmware_bundle" ]; then
    echo "Skipping VMware Workstation: no installer bundle was supplied."
    exit 0
fi

if [ ! -f "$vmware_bundle" ]; then
    echo "VMware installer not found: $vmware_bundle" >&2
    exit 1
fi

case "$vmware_bundle" in
    *.bundle) ;;
    *)
        echo "Expected a VMware Workstation .bundle installer: $vmware_bundle" >&2
        exit 1
        ;;
esac

echo "Installing VMware Workstation prerequisites..."
sudo apt update
sudo apt install -y build-essential dkms linux-headers-"$(uname -r)"

chmod +x "$vmware_bundle"
sudo "$vmware_bundle" --console --required --eulas-agreed

applications_dir="$HOME/.local/share/applications"
mkdir -p "$applications_dir"
cat > "$applications_dir/vmware-workstation.desktop" <<'EOF'
[Desktop Entry]
Name=VMware Workstation Pro
Comment=Run and manage virtual machines
Exec=/usr/bin/vmware %U
Icon=vmware-workstation
Terminal=false
Type=Application
Categories=System;Emulator;
StartupNotify=true
EOF

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir"
fi

echo "VMware Workstation Pro installed. Launch it from the application menu."
