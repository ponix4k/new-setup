#!/bin/bash
set -euo pipefail

data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
vim_plug="$data_dir/site/autoload/plug.vim"

echo "Installing Vim-Plug and Neovim plugins..."
if [ ! -f "$vim_plug" ]; then
    curl -fLo "$vim_plug" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

nvim --headless '+PlugInstall --sync' +qa
echo "Neovim plugins installed."
