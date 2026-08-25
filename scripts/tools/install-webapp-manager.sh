#!/bin/bash
set -euo pipefail

package_url="http://packages.linuxmint.com/pool/main/w/webapp-manager/webapp-manager_1.4.5_all.deb"
package_file="$(mktemp --suffix=.deb)"
trap 'rm -f "$package_file"' EXIT

echo "Installing WebApp Manager..."
curl -fL "$package_url" -o "$package_file"
sudo apt install -y "$package_file"
