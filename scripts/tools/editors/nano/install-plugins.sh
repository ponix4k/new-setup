#!/bin/bash
set -euo pipefail

plugin_dir="$HOME/.nano/nanorc"

echo "Installing nano syntax-highlighting plugins..."
if [ -d "$plugin_dir/.git" ]; then
    git -C "$plugin_dir" pull --ff-only
else
    git clone https://github.com/scopatz/nanorc.git "$plugin_dir"
fi

mkdir -p "$HOME/.nano"
include_line='include "~/.nano/nanorc/*.nanorc"'
touch "$HOME/.nanorc"
grep -Fqx "$include_line" "$HOME/.nanorc" || printf '%s\n' "$include_line" >> "$HOME/.nanorc"
