#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../../.." && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
config_file="$config_dir/init.vim"
lua_config_file="$config_dir/init.lua"
managed_config="$config_dir/new-setup.vim"

echo "Installing Neovim..."
sudo apt update
sudo apt install -y neovim git curl fzf ripgrep universal-ctags fontconfig

mkdir -p "$config_dir/new-setup" "$HOME/backups" "${XDG_STATE_HOME:-$HOME/.local/state}/nvim/undo"
cp "$repo_root/configs/nvim/init.vim" "$managed_config"
cp "$repo_root/configs/editors/plugins.vim" "$config_dir/new-setup/plugins.vim"
cp "$repo_root/configs/editors/settings.vim" "$config_dir/new-setup/settings.vim"

if [ -f "$lua_config_file" ]; then
    if [ ! -f "$HOME/backups/nvim-init.lua.bak" ]; then
        cp "$lua_config_file" "$HOME/backups/nvim-init.lua.bak"
    fi
    lua_source_line="vim.cmd('source ' .. vim.fn.fnameescape(vim.fn.stdpath('config') .. '/new-setup.vim'))"
    grep -Fqx "$lua_source_line" "$lua_config_file" || printf '\n%s\n' "$lua_source_line" >> "$lua_config_file"
else
    if [ -f "$config_file" ] && [ ! -f "$HOME/backups/nvim-init.vim.bak" ]; then
        cp "$config_file" "$HOME/backups/nvim-init.vim.bak"
    fi
    cp "$managed_config" "$config_file"
fi

bash "$script_dir/../install-nerd-fonts.sh"
bash "$script_dir/install-plugins.sh"
