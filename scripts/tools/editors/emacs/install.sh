#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Emacs..."
sudo apt update
sudo apt install -y emacs git
bash "$script_dir/install-plugins.sh"
