# My Development Environment Setup

An idempotent, declarative bootstrap configuration and dotfiles manager for setting up a complete Linux (Ubuntu 24.04 LTS+) workstation using [`mise`](https://mise.jdx.dev/).

---

## 🛠 Features

- **Whole-Machine Declarative Bootstrap**: Fully automated workstation setup via `mise bootstrap` or `./setup.sh`.
- **System Packages**: Installs build essentials, compilation libraries, and core CLI utilities (`curl`, `git`, `zsh`, `ca-certificates`, etc.) declaratively via `[bootstrap.packages]`.
- **Docker CE**: Automated configuration of official Docker APT repository (`[bootstrap.apt.sources.docker]`), packages, systemd service management (`[bootstrap.services.docker]`), and user group membership.
- **Shell & Prompt**: Configures `zsh` as default shell (`[bootstrap.user]`), installs Oh My Zsh, Powerlevel10k theme, and custom plugins (`zsh-syntax-highlighting`, `zsh-vi-mode`) via `[bootstrap.repos]`.
- **Nerd Fonts**: Automatically downloads and installs **MesloLGS NF** to `~/.local/share/fonts/NerdFonts` for terminal & Neovim icons via `mise run fonts`.
- **mise Tool Manager**: Installs mise and manages language runtimes (**Go**, **Node.js**, **Python**, **Java**) and CLI tools (**Neovim**, **Tmux**, **Clojure**, **kubectl**, **Terraform**, **Helm**, etc.), synchronizing versions from `mise.toml`.
- **Neovim Configuration**: Neovim configuration pre-bundled from [`rahuljainosttra/nvim`](https://github.com/rahuljainosttra/nvim) (branch `nvim12-without-lazy`).
- **Safe Dotfiles Symlinker**: Safe symlinking managed declaratively by mise (`[dotfiles]`). Keeps Git identity separate in `~/.gitconfig.local`.

---

## 📁 Repository Structure

```
.
├── mise.toml                # Root symlink to dotfiles/.config/mise/config.toml
├── setup.sh                 # Master setup orchestrator (runs mise bootstrap by default)
├── README.md                # Documentation
├── scripts/
│   └── cleanup-legacy.sh    # Standalone cleanup of legacy packages superseded by mise
└── dotfiles/
    ├── .zshrc               # Zsh shell configuration
    ├── .p10k.zsh            # Powerlevel10k prompt configuration
    ├── .tmux.conf           # Tmux configuration
    ├── TMUX_KEYBINDINGS.md  # Tmux shortcuts cheatsheet
    ├── .gitconfig           # Base Git configuration (includes ~/.gitconfig.local)
    └── .config/
        ├── mise/
        │   └── config.toml  # Canonical mise config: [bootstrap], [dotfiles], [tools], [tasks]
        └── nvim/            # Neovim configuration
            └── KEYBINDINGS.md # Neovim shortcuts cheatsheet
```

---

## 🚀 Quickstart

### Method A: Single Command via `mise bootstrap --from` (Recommended)
On any clean Ubuntu machine:
```bash
# 1. Install mise CLI
curl https://mise.run | sh

# 2. Bootstrap the entire workstation directly from the repository
~/.local/bin/mise bootstrap --from https://github.com/rahuljainosttra/my-dev-setup.git
```

> **One-liner:**
> ```bash
> curl https://mise.run | sh && ~/.local/bin/mise bootstrap --from https://github.com/rahuljainosttra/my-dev-setup.git
> ```

### Method B: Clone and Run `./setup.sh`
```bash
git clone https://github.com/rahuljainosttra/my-dev-setup.git ~/trioptima/codebase/my-dev-setup
cd ~/trioptima/codebase/my-dev-setup
./setup.sh
```
`./setup.sh` automatically installs `mise` if not already present, initializes `sudo`, and executes `mise bootstrap --yes --force-dotfiles`.

---

## 🔍 Inspecting Bootstrap State

Because the environment is declared in `mise.toml`, you can inspect and preview state at any time without making changes:

```bash
# Preview what would be created or modified
mise bootstrap plan

# View real-time convergence status of packages, repos, services, dotfiles, user shell
mise bootstrap status

# Simulate a full bootstrap run without applying changes
mise bootstrap --dry-run
```

---

## 🎯 Modular Execution

You can run individual modules or preview state as needed using flags with `./setup.sh`:

| Flag | Description |
|------|-------------|
| `./setup.sh` / `./setup.sh --all` | Run complete end-to-end declarative bootstrap (default) |
| `./setup.sh --plan` | Preview planned resource changes without applying (`mise bootstrap plan`) |
| `./setup.sh --dry-run` | Simulate bootstrap execution without applying changes (`mise bootstrap --dry-run`) |
| `./setup.sh --dotfiles` | Symlink dotfiles only (`mise bootstrap --only dotfiles`) |
| `./setup.sh --packages` | Install system APT packages only (`mise bootstrap --only packages`) |
| `./setup.sh --tools` | Install developer runtimes and tools only (`mise bootstrap --only tools`) |
| `./setup.sh --fonts` | Download and install Nerd Fonts (`mise run fonts`) |
| `./setup.sh --help` | Display help and usage options |

### 🧹 Standalone Legacy Cleanup

To clean up legacy system packages (APT, Snap, `/usr/local/bin`) superseded by `mise`:

```bash
# Preview what would be removed
./scripts/cleanup-legacy.sh --dry-run

# Run cleanup
./scripts/cleanup-legacy.sh

# Preview complete removal including mise itself
./scripts/cleanup-legacy.sh --uninstall-mise --dry-run

# Completely wipe mise and its runtimes, caches, and state
./scripts/cleanup-legacy.sh --uninstall-mise

# Preview complete removal including Docker CE and rootless services
./scripts/cleanup-legacy.sh --uninstall-docker --dry-run

# Completely remove Docker CE, rootless service, containers, and data
./scripts/cleanup-legacy.sh --uninstall-docker

# Preview complete teardown (legacy packages, mise, and Docker)
./scripts/cleanup-legacy.sh --all --dry-run

# Full teardown of all managed and legacy components
./scripts/cleanup-legacy.sh --all
```

---

## ⌨️ Shortcuts & Cheatsheets

- 📄 [Neovim Shortcuts Cheatsheet](dotfiles/.config/nvim/KEYBINDINGS.md) - Leader mappings (`<Space>`), LSP, Telescope, NvimTree, Gitsigns, and splits navigation.
- 📄 [Tmux Shortcuts Cheatsheet](dotfiles/TMUX_KEYBINDINGS.md) - Prefix keys (`Ctrl-b`), pane splitting/resizing, Vi copy mode, and window management.

---

## 🔗 Dotfiles & Symlinks

Dotfiles are declared in `[dotfiles]` within `dotfiles/.config/mise/config.toml`:
- Dotfiles are linked directly to `$HOME`:
  - `~/.zshrc` -> `dotfiles/.zshrc`
  - `~/.p10k.zsh` -> `dotfiles/.p10k.zsh`
  - `~/.tmux.conf` -> `dotfiles/.tmux.conf`
  - `~/.gitconfig` -> `dotfiles/.gitconfig`
  - `~/.config/nvim` -> `dotfiles/.config/nvim`
  - `~/.config/mise/config.toml` -> `dotfiles/.config/mise/config.toml`
- Git credentials (`user.name` and `user.email`) are saved to `~/.gitconfig.local` and never committed to this repository.
- Private machine-specific shell overrides and tokens can be placed in `~/.zshrc.local` (automatically sourced by `~/.zshrc`).
- Tmux Plugin Manager (`tpm`) is declared in `[bootstrap.repos]` and cloned to `~/.tmux/plugins/tpm`.

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
   Set your terminal font to **MesloLGS NF** in your terminal preferences.
4. **Launch Neovim**:
   ```bash
   nvim
   ```
