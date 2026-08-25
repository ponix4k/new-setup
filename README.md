# New Setup

`new-setup` contains scripts for configuring a new Debian-based workstation. The main installer sets up SSH keys, the hostname, base packages, an editor, network shares, desktop applications, a desktop environment, fonts, and shell configuration.

> Review the scripts before running the full installer. It uses `sudo`, changes `/etc/fstab`, installs packages, and updates files in your home directory.

Completed installer steps are recorded under `${XDG_STATE_HOME:-~/.local/state}/new-setup/` and skipped on later runs. Delete only the relevant `.done` marker when you intentionally want to rerun a completed step. Network-share setup is always rerun because its server and credentials may change.

## Run the full setup

```bash
./install.sh
```

## Editor setup

The Tool setup section asks which editor to install:

1. nano
2. vim
3. nvim (Neovim)
4. emacs

Each editor has a separate installer and plugin installer under `scripts/tools/editors/`. This makes it possible to test an editor without running the full setup:

```bash
bash scripts/tools/editors/nano/install.sh
bash scripts/tools/editors/vim/install.sh
bash scripts/tools/editors/nvim/install.sh
bash scripts/tools/editors/emacs/install.sh
```

To test only an editor's plugins, run its `install-plugins.sh` file. For example:

```bash
bash scripts/tools/editors/nvim/install-plugins.sh
```

The Vim installer backs up an existing `~/.vimrc` to `~/backups/vimrc.bak` before applying the repository configuration. Both Vim and Neovim install the bundled DroidSansMono Nerd Font and ensure FZF is available.

Vim and Neovim now share a curated Vim Bootstrap configuration and use [Vim-Plug](https://github.com/junegunn/vim-plug), keeping their plugins and keybindings synchronized. Vim-Plug is installed to its standard autoload location for each editor, and plugins are declared between `plug#begin()` and `plug#end()` in `configs/editors/plugins.vim`.

Useful Vim-Plug commands inside Vim or Neovim are:

```vim
:PlugInstall
:PlugUpdate
:PlugStatus
:PlugDiff
:PlugClean
:PlugUpgrade
```

The setup installs and configures:

- NERDTree with Nerd Font icons
- FZF and `fzf.vim`
- Git integration through Fugitive and GitGutter
- ALE diagnostics, Airline, Tagbar, EasyMotion, sessions, and snippets
- Language support for C/C++, Go, JavaScript, PHP, Python, Ruby, Rust, Svelte, and Vue
- NERDTree and FZF keybindings matching the Vim configuration

An existing Neovim `init.vim` or `init.lua` is backed up once under `~/backups/`. Existing Lua configurations are retained and configured to source the managed Neovim settings.

## Terminal setup

The terminal selector replaces the desktop's default terminal with either Kitty or Ghostty while retaining the original terminal as a fallback:

```bash
bash scripts/tools/terminals/select-terminal.sh
```

Both choices use the bundled `DroidSansM Nerd Font Mono` and the same Solarized Dark-inspired palette with 90% background opacity. They install a tracked configuration under `~/.config/`, register the selected application as Debian's `x-terminal-emulator`, and set it in `~/.config/xdg-terminals.list` for desktops using `xdg-terminal-exec`. Existing terminal configurations are backed up once under `~/backups/`.

If Kitty or Ghostty and its configuration file already exist, the terminal selector treats that terminal as complete and skips reinstalling it.

The Tool setup section also runs standalone installers for aliases and tmux:

```bash
bash scripts/tools/install-aliases.sh
bash scripts/tools/install-tmux.sh
```

The alias installer creates `~/.aliases` from `configs/bash/.aliases` when the file does not already exist. It configures both `~/.bashrc` and `~/.zshrc` to load that file without adding duplicate startup entries. After installation, edit `~/.aliases` directly to add or change aliases; running the installer again will preserve your changes.

The tmux installer installs tmux and TPM, copies the repository's `.tmux.conf`, and installs the configured tmux plugins. An existing tmux configuration is backed up once to `~/.tmux.conf.new-setup.bak`.

## Network share setup

The Setup shares section runs `scripts/setup-shares.sh`. It requests:

- The remote SMB server IPv4 address
- Username
- Password (input is hidden)
- Domain

Run it independently with:

```bash
bash scripts/setup-shares.sh
```

The script installs CIFS support and configures these mount points:

- `/media/shared` for the `Shared` share
- `~/projects` for the `Projects` directory inside that share

The entries are generated from `configs/scripts/fstab_entries.txt` and written to a managed block in `/etc/fstab`. Running the script again replaces that block instead of duplicating it. The original fstab is preserved at `/etc/fstab.new-setup.bak` the first time the script runs.

SMB credentials are stored in `/etc/.creds/creds`. The credentials directory is owned by the current user with mode `0700`, and the credentials file uses mode `0600`.

## Desktop setup

Desktop application installers are split into individual files under `scripts/tools/`. The main setup currently installs Steam, Discord, Obsidian, Flameshot, Oh My Zsh, Visual Studio Code, Docker Desktop, VMware Workstation, and WebApp Manager.

The desktop environment selector offers XFCE, KDE Plasma, Wayland components only, or the option to skip desktop installation.

## Vim key bindings

```text
Ctrl+t       Toggle NERDTree
Ctrl+f       Search with FZF
Leader+h     Move to the left panel
Leader+j     Move to the panel below
Leader+k     Move to the panel above
Leader+l     Move to the right panel
```

If you use PuTTY, open **Connection > Data**, set **Terminal-type string** to `xterm-256color`, save the session, and reconnect.

## Completed improvements

- [x] Added Droid Nerd Fonts to the repository
- [x] Split desktop application installation into standalone scripts
- [x] Added selectable editor installers and separate plugin installers
- [x] Added FZF, NERDTree, and Nerd Font setup for Vim and Neovim
- [x] Moved alias and tmux configuration into standalone installers
- [x] Added selectable desktop environment installers
- [x] Added idempotent SMB share and credentials setup
- [x] Added Visual Studio Code installation
- [x] Added selectable Kitty and Ghostty terminal installation
- [x] Added Flameshot installation

## Remaining work

- [ ] Add custom backgrounds
- [ ] Add more terminal customization
