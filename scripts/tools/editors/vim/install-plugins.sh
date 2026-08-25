#!/bin/bash
set -euo pipefail

vim_plug="$HOME/.vim/autoload/plug.vim"

echo "Installing Vim-Plug and Vim plugins..."
if [ ! -f "$vim_plug" ]; then
    curl -fLo "$vim_plug" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

vim '+PlugInstall --sync' +qa
echo "Vim plugins installed."
