#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    printf '%s\n' 'Do not run this installer with sudo. Run ./install.sh as your normal user; it will request sudo when required.' >&2
    exit 1
fi

section() {
    printf '\n##################################\n#### %s\n##################################\n\n' "$1"
}

append_once() {
    line="$1"
    file="$2"
    touch "$file"
    grep -Fqx "$line" "$file" 2>/dev/null || printf '%s\n' "$line" >> "$file"
}

run_installer() {
    installer="$1"
    shift

    if [ ! -f "$installer" ]; then
        printf 'Missing installer: %s\n' "$installer" >&2
        exit 1
    fi

    bash "$installer" "$@"
}

section "New install setup"
printf 'Installer directory: %s\n' "$SCRIPT_DIR"

section "Detecting shell"
case "${SHELL:-}" in
    */bash) detected_shell="Bash" ;;
    */zsh) detected_shell="Zsh" ;;
    */fish) detected_shell="Fish" ;;
    "") detected_shell="unknown (SHELL is not set)" ;;
    *) detected_shell="$(basename "$SHELL")" ;;
esac
printf 'Installer shell: Bash %s\n' "${BASH_VERSION:-unknown}"
printf 'Login shell: %s\n' "$detected_shell"

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
legacy_cron_line="* * * * * curl -fsSL https://github.com/${username}.keys -o \"$HOME/.ssh/authorized_keys\""
cron_line="*/15 * * * * curl -fsSL https://github.com/${username}.keys -o \"$HOME/.ssh/authorized_keys\" >/dev/null 2>&1"
current_crontab="$(crontab -l 2>/dev/null || true)"
current_crontab="$(printf '%s\n' "$current_crontab" | grep -Fvx -e "$legacy_cron_line" -e "$cron_line" || true)"
{ printf '%s\n' "$current_crontab"; printf '%s\n' "$cron_line"; } | crontab -

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

if [ "$OS" = "Darwin" ]; then
    section "Skipping Debian workstation modules on macOS"
    printf '%s\n' 'The modular editor, share, desktop application, and desktop environment installers currently target Debian-based Linux.'
else
    section "Selecting editor"
    run_installer "$SCRIPT_DIR/scripts/tools/editors/select-editor.sh"

    section "Installing Nerd Fonts"
    run_installer "$SCRIPT_DIR/scripts/tools/editors/install-nerd-fonts.sh"

    section "Selecting terminal"
    run_installer "$SCRIPT_DIR/scripts/tools/terminals/select-terminal.sh"

    section "Installing shell aliases"
    run_installer "$SCRIPT_DIR/scripts/tools/install-aliases.sh"

    section "Installing tmux"
    run_installer "$SCRIPT_DIR/scripts/tools/install-tmux.sh"

    section "Setting up network shares"
    run_installer "$SCRIPT_DIR/scripts/setup-shares.sh"

    section "Installing desktop applications"
    desktop_installers=(
        install-steam.sh
        install-discord.sh
        install-obsidian.sh
        install-flameshot.sh
        install-oh-my-zsh.sh
        install-vscode.sh
        install-docker-desktop.sh
        install-vmware-workstation.sh
        install-webapp-manager.sh
    )
    for installer in "${desktop_installers[@]}"; do
        run_installer "$SCRIPT_DIR/scripts/tools/$installer"
    done

    section "Selecting desktop environment"
    run_installer "$SCRIPT_DIR/scripts/desktop-env/select-de.sh"
fi

printf '\nSetup complete. Open a new terminal to load the aliases.\n'
