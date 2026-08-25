#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing nano..."
sudo apt update
sudo apt install -y nano git
bash "$script_dir/install-plugins.sh"
