#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"
alias_template="$repo_root/configs/bash/.aliases"
alias_file="$HOME/.aliases"
source_line='[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"'

if [ ! -f "$alias_template" ]; then
    echo "Missing alias template: $alias_template" >&2
    exit 1
fi

if [ ! -e "$alias_file" ]; then
    cp "$alias_template" "$alias_file"
    echo "Created $alias_file from the repository defaults."
else
    echo "Keeping existing $alias_file."
fi

for shell_rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    touch "$shell_rc"
    if ! grep -Fqx "$source_line" "$shell_rc"; then
        printf '\n# Load personal aliases.\n%s\n' "$source_line" >> "$shell_rc"
        echo "Configured $shell_rc to load $alias_file."
    fi
done

echo "Alias setup complete. Edit $alias_file to manage your aliases."
