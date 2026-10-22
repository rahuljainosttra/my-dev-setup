# My Development Environment Setup

An idempotent, modular bootstrap script and dotfiles manager for setting up a complete Linux (Ubuntu 24.04 LTS+) workstation.

---

## 🛠 Features

- **System Packages**: Installs build essentials, compilation libraries, and core CLI utilities (`curl`, `git`, `zsh`, `ripgrep`, `jq`, etc.).
- **Docker CE**: Automated installation of official Docker Engine and CLI, enabling the daemon and adding your user to the `docker` group.
- **Shell & Prompt**: Configures `zsh` as default shell, installs Oh My Zsh, Powerlevel10k theme, and custom plugins (`zsh-syntax-highlighting`, `zsh-vi-mode`).
- **Nerd Fonts**: Automatically downloads and installs **MesloLGS NF** and **JetBrainsMono Nerd Font** to `~/.local/share/fonts/NerdFonts` for terminal & Neovim icons.
- **asdf Version Manager**: Installs asdf and plugins for language runtimes (**Go**, **Node.js**, **Python**) and CLI tools (**Neovim**, **Tmux**, **kubectl**), synchronizing versions from `.tool-versions`.
- **Neovim Configuration**: Neovim configuration pre-bundled from [`rahuljainosttra/nvim`](https://github.com/rahuljainosttra/nvim) (branch `nvim12-without-lazy`).
- **Safe Dotfiles Symlinker**: Safe symlinking with timestamped backups stored in `~/.dotfiles_backup/<timestamp>/`. Keeps Git identity separate in `~/.gitconfig.local`.

---

## 📁 Repository Structure

```
.
├── setup.sh                 # Master setup orchestrator
├── README.md                # Documentation
├── scripts/
│   ├── lib/
│   │   └── common.sh        # Shared utilities, colors & sudo keep-alive
│   ├── 00-packages.sh       # APT packages & compiler dependencies
│   ├── 01-docker.sh         # Docker CE repository & service
│   ├── 02-zsh.sh            # Zsh, Oh My Zsh, P10k & plugins
│   ├── 03-fonts.sh          # MesloLGS & JetBrainsMono Nerd Fonts
│   ├── 04-asdf.sh           # asdf CLI, plugins, runtimes & tool builds
│   └── 05-dotfiles.sh       # Safe backup & symlink manager
└── dotfiles/
    ├── .zshrc               # Zsh shell configuration
    ├── .p10k.zsh            # Powerlevel10k prompt configuration
    ├── .tmux.conf           # Tmux configuration
    ├── TMUX_KEYBINDINGS.md  # Tmux shortcuts cheatsheet
    ├── .tool-versions       # asdf tool versions
    ├── .gitconfig           # Base Git configuration (includes ~/.gitconfig.local)
    └── .config/
        └── nvim/            # Neovim configuration
            └── KEYBINDINGS.md # Neovim shortcuts cheatsheet

---

## ⌨️ Shortcuts & Cheatsheets

- 📄 [Neovim Shortcuts Cheatsheet](dotfiles/.config/nvim/KEYBINDINGS.md) - Leader mappings (`<Space>`), LSP, Telescope, NvimTree, Gitsigns, and splits navigation.
- 📄 [Tmux Shortcuts Cheatsheet](dotfiles/TMUX_KEYBINDINGS.md) - Prefix keys (`Ctrl-b`), pane splitting/resizing, Vi copy mode, and window management.

```

---

## 🚀 Quickstart

### 1. Clone this repository
```bash
git clone https://github.com/rahuljainosttra/my-dev-setup.git ~/trioptima/codebase/my-dev-setup
cd ~/trioptima/codebase/my-dev-setup
```

### 2. Run the full setup
```bash
chmod +x setup.sh scripts/*.sh
./setup.sh
```

---

## 🎯 Modular Execution

You can run individual modules as needed using flags:

| Flag | Description |
|------|-------------|
| `./setup.sh --all` | Run complete end-to-end setup (default) |
| `./setup.sh --packages` | Install system packages and build libraries |
| `./setup.sh --docker` | Install official Docker CE and configure user group |
| `./setup.sh --zsh` | Setup Oh My Zsh, Powerlevel10k, and plugins |
| `./setup.sh --fonts` | Download and install Nerd Fonts |
| `./setup.sh --asdf` | Install/update asdf, plugins, runtimes, and tools |
| `./setup.sh --dotfiles` | Safely symlink configuration files into `$HOME` |
| `./setup.sh --help` | Display help and usage options |

---

## 🔗 Dotfiles & Symlinks

The `scripts/05-dotfiles.sh` script manages symlinks safely:
- If a target file already exists and is not a symlink, it is moved to:
  `~/.dotfiles_backup/<YYYYMMDD_HHMMSS>/`
- Git credentials (`user.name` and `user.email`) are saved to `~/.gitconfig.local` and never committed to this repository.

---

## 🔄 Post-Installation Steps

1. **Activate Zsh**:
   ```bash
   exec zsh
   ```
2. **Activate Docker permissions** (if newly added to group):
   ```bash
   newgrp docker
   ```
3. **Configure Terminal Font**:
   Set your terminal font to **MesloLGS NF** or **JetBrainsMono Nerd Font** in your terminal preferences.
4. **Launch Neovim**:
   ```bash
   nvim
   ```
