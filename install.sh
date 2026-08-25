#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"
SETUP_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/new-setup"

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    printf '%s\n' 'Do not run this installer with sudo. Run ./install.sh as your normal user; it will request sudo when required.' >&2
    exit 1
fi

section() {
    printf '\n##################################\n#### %s\n##################################\n\n' "$1"
}

append_once() {
    local line="$1"
    local file="$2"
    touch "$file"
    grep -Fqx "$line" "$file" 2>/dev/null || printf '%s\n' "$line" >> "$file"
}

run_installer() {
    local installer="$1"
    shift

    if [ ! -f "$installer" ]; then
        printf 'Missing installer: %s\n' "$installer" >&2
        exit 1
    fi

    bash "$installer" "$@"
}

run_installer_once() {
    local step_name="$1"
    local installer="$2"
    shift 2
    local marker="$SETUP_STATE_DIR/$step_name.done"

    if [ -f "$marker" ]; then
        printf 'Skipping completed step: %s\n' "$step_name"
        return 0
    fi

    run_installer "$installer" "$@"
    mkdir -p "$SETUP_STATE_DIR"
    touch "$marker"
}

desktop_tool_installed() {
    case "$1" in
        install-steam.sh) command -v steam >/dev/null 2>&1 ;;
        install-discord.sh) command -v discord >/dev/null 2>&1 || snap list discord >/dev/null 2>&1 ;;
        install-obsidian.sh) command -v obsidian >/dev/null 2>&1 || snap list obsidian >/dev/null 2>&1 ;;
        install-flameshot.sh) command -v flameshot >/dev/null 2>&1 ;;
        install-oh-my-zsh.sh) command -v zsh >/dev/null 2>&1 && [ -d "$HOME/.oh-my-zsh" ] ;;
        install-vscode.sh) command -v code >/dev/null 2>&1 || command -v code-insiders >/dev/null 2>&1 ;;
        install-docker-desktop.sh) [ -x /opt/docker-desktop/bin/docker-desktop ] ;;
        install-vmware-workstation.sh) command -v vmware >/dev/null 2>&1 ;;
        install-webapp-manager.sh) command -v webapp-manager >/dev/null 2>&1 ;;
        *) return 1 ;;
    esac
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

section "Installing learning and development tools"
run_installer_once "python-learning" "$SCRIPT_DIR/scripts/tools/install-python-learning.sh"
run_installer_once "aws-basics" "$SCRIPT_DIR/scripts/tools/install-aws-basics.sh"
run_installer_once "reversing-tools" "$SCRIPT_DIR/scripts/tools/install-reversing-tools.sh"

if [ "$OS" = "Darwin" ]; then
    section "Selecting terminal"
    run_installer "$SCRIPT_DIR/scripts/tools/terminals/select-terminal.sh"

    section "Skipping Debian workstation modules on macOS"
    printf '%s\n' 'The modular editor, share, desktop application, and desktop environment installers currently target Debian-based Linux.'
else
    section "Selecting editor"
    run_installer_once "editor" "$SCRIPT_DIR/scripts/tools/editors/select-editor.sh"

    section "Installing Nerd Fonts"
    run_installer_once "nerd-fonts" "$SCRIPT_DIR/scripts/tools/editors/install-nerd-fonts.sh"

    section "Selecting terminal"
    run_installer "$SCRIPT_DIR/scripts/tools/terminals/select-terminal.sh"

    section "Installing shell aliases"
    run_installer_once "aliases" "$SCRIPT_DIR/scripts/tools/install-aliases.sh"

    section "Installing tmux"
    run_installer_once "tmux" "$SCRIPT_DIR/scripts/tools/install-tmux.sh"

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
        step_name="${installer%.sh}"
        marker="$SETUP_STATE_DIR/$step_name.done"
        if [ ! -f "$marker" ] && desktop_tool_installed "$installer"; then
            printf 'Skipping already installed tool: %s\n' "$step_name"
            mkdir -p "$SETUP_STATE_DIR"
            touch "$marker"
        else
            run_installer_once "$step_name" "$SCRIPT_DIR/scripts/tools/$installer"
        fi
    done

    section "Selecting desktop environment"
    run_installer_once "desktop-environment" "$SCRIPT_DIR/scripts/desktop-env/select-de.sh"
fi

printf '\nSetup complete. Open a new terminal to load the aliases.\n'
