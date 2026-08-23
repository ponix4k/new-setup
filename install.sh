#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

section() {
    printf '\n##################################\n#### %s\n##################################\n\n' "$1"
}

append_once() {
    line="$1"
    file="$2"
    touch "$file"
    grep -Fqx "$line" "$file" 2>/dev/null || printf '%s\n' "$line" >> "$file"
}

section "New install setup"
printf 'Installer directory: %s\n' "$SCRIPT_DIR"

section "Pulling GitHub keys"
printf 'Enter GitHub Username: '
read -r username
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if curl -fsSL "https://github.com/${username}.keys" -o "$HOME/.ssh/authorized_keys"; then
    chmod 600 "$HOME/.ssh/authorized_keys"
else
    printf 'Warning: could not download keys for GitHub user %s.\n' "$username" >&2
fi

section "Setting hostname"
printf 'Enter new Hostname (leave blank to keep the current hostname): '
read -r new_hostname
if [ -n "$new_hostname" ]; then
    if [ "$OS" = "Darwin" ]; then
        sudo scutil --set ComputerName "$new_hostname"
        sudo scutil --set LocalHostName "$new_hostname"
        sudo scutil --set HostName "$new_hostname"
    elif command -v hostnamectl >/dev/null 2>&1; then
        sudo hostnamectl set-hostname "$new_hostname"
    else
        printf 'Warning: hostname changes are unsupported on %s.\n' "$OS" >&2
    fi
fi

section "Creating key-pull cron task"
cron_line="* * * * * curl -fsSL https://github.com/${username}.keys -o \"$HOME/.ssh/authorized_keys\""
current_crontab="$(crontab -l 2>/dev/null || true)"
if ! printf '%s\n' "$current_crontab" | grep -Fqx "$cron_line"; then
    { printf '%s\n' "$current_crontab"; printf '%s\n' "$cron_line"; } | crontab -
fi

section "Installing packages"
if [ "$OS" = "Darwin" ]; then
    if ! command -v brew >/dev/null 2>&1; then
        section "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # The Homebrew installer does not update PATH in this running process.
        if [ -x /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -x /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi

    if command -v brew >/dev/null 2>&1; then
        brew_bin="$(command -v brew)"
        case "${SHELL:-}" in
            */zsh) brew_profile="$HOME/.zprofile" ;;
            *) brew_profile="$HOME/.bash_profile" ;;
        esac
        append_once "eval \"\$(${brew_bin} shellenv)\"" "$brew_profile"
        brew install vim git tmux mono go node openjdk libpq postgresql
    else
        printf '%s\n' 'Homebrew installation failed; skipping macOS package installation.' >&2
    fi
elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y vim git tmux snapd mono-complete golang nodejs default-jdk npm libpq-dev postgresql openssh-server
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw allow ssh
    fi
else
    printf 'Warning: no supported package manager found; skipping package installation.\n' >&2
fi

section "Copying mono fonts"
if [ "$OS" = "Darwin" ]; then
    font_dir="$HOME/Library/Fonts"
else
    font_dir="$HOME/.local/share/fonts"
fi
mkdir -p "$font_dir"
for font in "$SCRIPT_DIR"/configs/fonts/*.otf; do
    [ -e "$font" ] || continue
    cp "$font" "$font_dir/"
done
if [ "$OS" != "Darwin" ] && command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$font_dir"
fi

section "Creating files and folders"
mkdir -p "$HOME/backups"
touch "$HOME/.aliases"

case "${SHELL:-}" in
    */zsh) shell_rc="$HOME/.zshrc" ;;
    *) shell_rc="$HOME/.bashrc" ;;
esac
append_once '# Load shared aliases installed by new-setup' "$shell_rc"
append_once '[ -e "$HOME/.aliases" ] && source "$HOME/.aliases"' "$shell_rc"

section "Installing Vundle"
if [ ! -d "$HOME/.vim/bundle/Vundle.vim/.git" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
fi

if [ "$OS" = "Darwin" ]; then
    section "Skipping Linux Mint WebApp Manager on macOS"
else
    section "Installing WebApp Manager"
    webapp_deb="${TMPDIR:-/tmp}/webapp-manager_1.4.5_all.deb"
    if curl -fL 'http://packages.linuxmint.com/pool/main/w/webapp-manager/webapp-manager_1.4.5_all.deb' -o "$webapp_deb"; then
        sudo dpkg -i "$webapp_deb" || sudo apt-get --fix-broken install -y
        sudo dpkg --configure -a
    else
        printf 'Warning: could not download WebApp Manager.\n' >&2
    fi
fi

section "Setting up Vim and aliases"
if [ -f "$HOME/.vimrc" ]; then
    cp "$HOME/.vimrc" "$HOME/backups/vimrc.bak"
fi
cp "$SCRIPT_DIR/configs/vim/vimrc.txt" "$HOME/.vimrc"
cp "$SCRIPT_DIR/configs/bash/bash_aliaes.txt" "$HOME/.aliases"

if command -v vim >/dev/null 2>&1; then
    vim +PluginInstall +qall
else
    printf 'Warning: vim is not available; skipping plugin installation.\n' >&2
fi

printf '\nSetup complete. Open a new terminal to load the aliases.\n'
