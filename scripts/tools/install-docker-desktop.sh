#!/bin/bash
set -euo pipefail

docker_desktop_url="${DOCKER_DESKTOP_URL:-https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb}"
docker_keyring="/etc/apt/keyrings/docker.asc"
docker_sources="/etc/apt/sources.list.d/docker.sources"

if [ "$(dpkg --print-architecture)" != "amd64" ]; then
    echo "Docker Desktop for Ubuntu requires an amd64 system." >&2
    exit 1
fi

echo "Installing Docker Desktop prerequisites..."
sudo apt update
sudo apt install -y ca-certificates curl gnome-terminal pass qemu-system-x86

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "$docker_keyring"
sudo chmod a+r "$docker_keyring"

. /etc/os-release
docker_codename="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
docker_arch="$(dpkg --print-architecture)"
sudo tee "$docker_sources" >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $docker_codename
Components: stable
Architectures: $docker_arch
Signed-By: $docker_keyring
EOF

docker_deb="$(mktemp --suffix=.deb)"
trap 'rm -f "$docker_deb"' EXIT
curl -fL "$docker_desktop_url" -o "$docker_deb"

sudo apt update
sudo apt install -y "$docker_deb"
desktop_user="${SUDO_USER:-$USER}"
sudo usermod -aG kvm "$desktop_user"

applications_dir="$HOME/.local/share/applications"
mkdir -p "$applications_dir"
cat > "$applications_dir/docker-desktop.desktop" <<'EOF'
[Desktop Entry]
Name=Docker Desktop
Comment=Manage containers with Docker Desktop
Exec=/opt/docker-desktop/bin/docker-desktop
Icon=docker-desktop
Terminal=false
Type=Application
Categories=Development;
StartupNotify=true
EOF

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir"
fi

echo "Docker Desktop installed. Log out and back in for KVM group access, then launch it from the application menu."
