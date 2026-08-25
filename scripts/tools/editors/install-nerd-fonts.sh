#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
font_source="$repo_root/configs/fonts"
font_target="$HOME/.local/share/fonts"

if ! compgen -G "$font_source/*.otf" >/dev/null; then
    echo "No Nerd Font files found in $font_source." >&2
    exit 1
fi

fonts_current=true
for source_font in "$font_source"/*.otf; do
    target_font="$font_target/$(basename "$source_font")"
    if [ ! -f "$target_font" ] || ! cmp -s "$source_font" "$target_font"; then
        fonts_current=false
        break
    fi
done

if [ "$fonts_current" = true ]; then
    echo "Bundled Nerd Fonts are already installed; skipping."
    exit 0
fi

echo "Installing DroidSansMono Nerd Font..."
mkdir -p "$font_target"
cp "$font_source"/*.otf "$font_target/"

if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$font_target"
fi
