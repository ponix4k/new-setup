#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
nvim_config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim/new-setup.vim"

if command -v nvim >/dev/null 2>&1 && [ -f "$nvim_config" ]; then
    echo "Neovim and its managed configuration are already installed; skipping editor selection."
    exit 0
fi

if command -v vim >/dev/null 2>&1 \
    && [ -f "$HOME/.vimrc" ] \
    && [ -f "$HOME/.vim/new-setup/plugins.vim" ]; then
    echo "Vim and its managed configuration are already installed; skipping editor selection."
    exit 0
fi

if command -v emacs >/dev/null 2>&1 && [ -f "$HOME/.emacs.d/new-setup-plugins.el" ]; then
    echo "Emacs and its managed plugins are already installed; skipping editor selection."
    exit 0
fi

if command -v nano >/dev/null 2>&1 && [ -d "$HOME/.nano/nanorc/.git" ]; then
    echo "Nano and its managed syntax plugins are already installed; skipping editor selection."
    exit 0
fi

echo "Select an editor to install:"
echo "  1) nano"
echo "  2) vim"
echo "  3) nvim"
echo "  4) emacs"
read -r -p "Enter choice [1-4]: " editor_choice

case "$editor_choice" in
    1) editor="nano" ;;
    2) editor="vim" ;;
    3) editor="nvim" ;;
    4) editor="emacs" ;;
    *)
        echo "Invalid selection: $editor_choice" >&2
        exit 1
        ;;
esac

bash "$script_dir/$editor/install.sh"
