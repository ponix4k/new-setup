#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../../.." && pwd)"

echo "Installing vim..."
sudo apt update
sudo apt install -y vim git curl fzf ripgrep universal-ctags fontconfig

mkdir -p "$HOME/backups" "$HOME/.vim/new-setup" "$HOME/.vim/undo"
if [ -f "$HOME/.vimrc" ] && [ ! -f "$HOME/backups/vimrc.bak" ]; then
    cp "$HOME/.vimrc" "$HOME/backups/vimrc.bak"
fi
cp "$repo_root/configs/vim/.vimrc" "$HOME/.vimrc"
cp "$repo_root/configs/editors/plugins.vim" "$HOME/.vim/new-setup/plugins.vim"
cp "$repo_root/configs/editors/settings.vim" "$HOME/.vim/new-setup/settings.vim"

bash "$script_dir/../install-nerd-fonts.sh"
bash "$script_dir/install-plugins.sh"
