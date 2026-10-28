#!/usr/bin/env bash
# setup.sh - Workstation bootstrap entrypoint using declarative mise bootstrap

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ANSI color codes & loggers
COLOR_BLUE='\033[0;34m'
COLOR_GREEN='\033[0;32m'
COLOR_BOLD='\033[1m'
COLOR_RESET='\033[0m'

log_info() { printf "${COLOR_BLUE}${COLOR_BOLD}[INFO]${COLOR_RESET} %s\n" "$*"; }
log_success() { printf "${COLOR_GREEN}${COLOR_BOLD}[OK]${COLOR_RESET} %s\n" "$*"; }
log_error() { printf "\033[0;31m\033[1m[ERROR]\033[0m %s\n" "$*" >&2; }

init_sudo() {
    if [ "$EUID" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
        sudo -v || { log_error "Failed to authenticate with sudo."; exit 1; }
    fi
}

ensure_mise_installed() {
    export PATH="${HOME}/.local/bin:${PATH}"
    if command -v mise >/dev/null 2>&1; then
        log_info "mise CLI already installed: $(mise --version | head -n 1)"
        return 0
    fi
    log_info "mise CLI not found. Installing mise via https://mise.run..."
    curl -fsSL https://mise.run | sh
    export PATH="${HOME}/.local/bin:${PATH}"
    if ! command -v mise >/dev/null 2>&1; then
        log_error "Failed to locate mise after installation."
        return 1
    fi
    log_success "mise installed successfully: $(mise --version | head -n 1)"
}

# Prevent running master setup script directly as root (unless explicitly allowed in containers/CI)
ALLOW_ROOT="${ALLOW_ROOT:-0}"
for arg in "$@"; do
    if [ "$arg" = "--allow-root" ]; then
        ALLOW_ROOT=1
        break
    fi
done

if [ "$EUID" -eq 0 ] && [ "${ALLOW_ROOT}" != "1" ]; then
    log_error "Do not run setup.sh as root or with sudo."
    log_error "Run as your normal user: ./setup.sh (sudo credentials will be requested when needed)"
    log_error "If running in a Docker container or CI environment as root, pass --allow-root or set ALLOW_ROOT=1."
    exit 1
fi

show_help() {
    cat <<EOF
Usage: ./setup.sh [OPTIONS]

Master bootstrap script for personal development environment on Ubuntu 24.04+.
Executes declarative whole-machine provisioning via 'mise bootstrap'.

Options:
  --all, --bootstrap Run complete setup via 'mise bootstrap' (default)
  --plan             Show planned resource changes without applying ('mise bootstrap plan')
  --dry-run          Simulate execution without applying changes ('mise bootstrap --dry-run')
  --fonts            Install MesloLGS NF fonts ('mise run fonts')
  --dotfiles         Symlink dotfiles only ('mise bootstrap --only dotfiles')
  --packages         Install system APT packages only ('mise bootstrap --only packages')
  --tools            Install developer runtimes and tools only ('mise bootstrap --only tools')
  --allow-root       Allow running setup as root (e.g. inside containers or CI)
  -h, --help         Show this help message and exit

Standalone Utilities:
  ./scripts/cleanup-legacy.sh  Clean up legacy system packages (supports --all, --uninstall-mise, --uninstall-docker)

Examples:
  ./setup.sh                 # Full end-to-end bootstrap
  ./setup.sh --plan          # Inspect what changes will be applied
  ./setup.sh --dry-run       # Test run without applying changes
  ./setup.sh --fonts         # Install terminal fonts only
EOF
}

MODE="bootstrap"
EXTRA_ARGS=()

while [ $# -gt 0 ]; do
    case "$1" in
        --all|--bootstrap)
            MODE="bootstrap"
            shift
            ;;
        --plan)
            MODE="plan"
            shift
            ;;
        --dry-run)
            MODE="dry-run"
            shift
            ;;
        --fonts)
            MODE="fonts"
            shift
            ;;
        --dotfiles)
            MODE="dotfiles"
            shift
            ;;
        --packages)
            MODE="packages"
            shift
            ;;
        --tools)
            MODE="tools"
            shift
            ;;
        --allow-root)
            ALLOW_ROOT=1
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

printf "${COLOR_BLUE}${COLOR_BOLD}"
cat << "EOF"
============================================================
           🚀 Personal Dev Setup Bootstrap 🚀
============================================================
EOF
printf "${COLOR_RESET}\n"

START_TIME=$(date +%s)

ensure_mise_installed

case "$MODE" in
    plan)
        log_info "Previewing planned bootstrap changes..."
        mise -C "${SCRIPT_DIR}" bootstrap plan "${EXTRA_ARGS[@]}"
        ;;
    dry-run)
        log_info "Simulating workstation setup (dry-run)..."
        mise -C "${SCRIPT_DIR}" bootstrap --dry-run "${EXTRA_ARGS[@]}"
        ;;
    fonts)
        log_info "Installing fonts via mise run fonts..."
        mise -C "${SCRIPT_DIR}" run fonts
        ;;
    dotfiles)
        log_info "Applying dotfiles symlinks..."
        mise -C "${SCRIPT_DIR}" bootstrap --only dotfiles --force-dotfiles "${EXTRA_ARGS[@]}"
        ;;
    packages)
        init_sudo
        log_info "Applying system packages..."
        mise -C "${SCRIPT_DIR}" bootstrap --only packages --yes "${EXTRA_ARGS[@]}"
        ;;
    tools)
        log_info "Installing developer runtimes and tools..."
        mise -C "${SCRIPT_DIR}" bootstrap --only tools --yes "${EXTRA_ARGS[@]}"
        ;;
    bootstrap)
        init_sudo
        log_info "Running full declarative workstation setup via mise bootstrap..."
        mise -C "${SCRIPT_DIR}" bootstrap --yes --force-dotfiles "${EXTRA_ARGS[@]}"
        ;;
esac

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
echo "  3. Configure your terminal font to MesloLGS NF"
echo "  4. Launch Neovim ('nvim') to let plugins initialize"
echo ""
