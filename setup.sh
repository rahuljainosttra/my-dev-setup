#!/usr/bin/env bash
# setup.sh - Master setup script for workstation development environment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/lib/common.sh"

show_help() {
    cat <<EOF
Usage: ./setup.sh [OPTIONS]

Master bootstrap script for personal development environment on Ubuntu 24.04+.

Options:
  --all            Run complete setup (default if no options given)
  --packages       Install system packages & compilation libraries
  --docker         Install Docker CE and add user to docker group
  --zsh            Setup Zsh, Oh My Zsh, Powerlevel10k, and plugins
  --fonts          Install MesloLGS NF and JetBrainsMono Nerd Fonts
  --asdf           Install asdf, plugins, runtimes (Go, Node, Python), and tools (Neovim, Tmux, kubectl)
  --dotfiles       Safely backup and symlink dotfiles into \$HOME
  -h, --help       Show this help message and exit

Examples:
  ./setup.sh                 # Full end-to-end setup
  ./setup.sh --dotfiles      # Re-link dotfiles only
  ./setup.sh --asdf          # Re-install or update asdf runtimes
EOF
}

# Default actions
RUN_PACKAGES=false
RUN_DOCKER=false
RUN_ZSH=false
RUN_FONTS=false
RUN_ASDF=false
RUN_DOTFILES=false

if [ $# -eq 0 ]; then
    RUN_PACKAGES=true
    RUN_DOCKER=true
    RUN_ZSH=true
    RUN_FONTS=true
    RUN_ASDF=true
    RUN_DOTFILES=true
else
    while [ $# -gt 0 ]; do
        case "$1" in
            --all)
                RUN_PACKAGES=true
                RUN_DOCKER=true
                RUN_ZSH=true
                RUN_FONTS=true
                RUN_ASDF=true
                RUN_DOTFILES=true
                shift
                ;;
            --packages)
                RUN_PACKAGES=true
                shift
                ;;
            --docker)
                RUN_DOCKER=true
                shift
                ;;
            --zsh)
                RUN_ZSH=true
                shift
                ;;
            --fonts)
                RUN_FONTS=true
                shift
                ;;
            --asdf)
                RUN_ASDF=true
                shift
                ;;
            --dotfiles)
                RUN_DOTFILES=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
fi

printf "${COLOR_BLUE}${COLOR_BOLD}"
cat << "EOF"
============================================================
           🚀 Personal Dev Setup Bootstrap 🚀
============================================================
EOF
printf "${COLOR_RESET}\n"

START_TIME=$(date +%s)

# If operations requiring root are scheduled, initialize sudo once
if [ "$RUN_PACKAGES" = true ] || [ "$RUN_DOCKER" = true ] || [ "$RUN_ZSH" = true ]; then
    init_sudo
fi

if [ "$RUN_PACKAGES" = true ]; then
    "${SCRIPT_DIR}/scripts/00-packages.sh"
fi

if [ "$RUN_DOCKER" = true ]; then
    "${SCRIPT_DIR}/scripts/01-docker.sh"
fi

if [ "$RUN_ZSH" = true ]; then
    "${SCRIPT_DIR}/scripts/02-zsh.sh"
fi

if [ "$RUN_FONTS" = true ]; then
    "${SCRIPT_DIR}/scripts/03-fonts.sh"
fi

if [ "$RUN_ASDF" = true ]; then
    "${SCRIPT_DIR}/scripts/04-asdf.sh"
fi

if [ "$RUN_DOTFILES" = true ]; then
    "${SCRIPT_DIR}/scripts/05-dotfiles.sh"
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

printf "\n${COLOR_GREEN}${COLOR_BOLD}"
cat << "EOF"
============================================================
           ✨ Development Setup Complete! ✨
============================================================
EOF
printf "${COLOR_RESET}\n"
log_success "Completed in ${DURATION}s."
log_info "Next Steps:"
echo "  1. Switch to Zsh or restart your terminal: exec zsh"
echo "  2. Activate docker group permissions (if newly added): newgrp docker"
echo "  3. Configure your terminal font to MesloLGS NF or JetBrainsMono Nerd Font"
echo "  4. Launch Neovim ('nvim') to let plugins initialize"
echo ""
