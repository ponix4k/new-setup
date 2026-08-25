#!/bin/bash
set -euo pipefail

emacs_dir="$HOME/.emacs.d"
init_file="$emacs_dir/init.el"
plugin_file="$emacs_dir/new-setup-plugins.el"

echo "Configuring Emacs packages..."
mkdir -p "$emacs_dir"
cat > "$plugin_file" <<'EOF'
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(dolist (package '(use-package which-key))
  (unless (package-installed-p package)
    (package-install package)))
(which-key-mode 1)
EOF

touch "$init_file"
load_line="(load-file \"$plugin_file\")"
grep -Fqx "$load_line" "$init_file" || printf '%s\n' "$load_line" >> "$init_file"

emacs --batch --load "$plugin_file"
