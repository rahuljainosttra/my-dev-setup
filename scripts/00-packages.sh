#!/usr/bin/env bash
# 00-packages.sh - Install core system packages and compilation dependencies

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_info "Running 00-packages.sh: Updating APT package lists..."
sudo apt-get update -y

PACKAGES=(
    # Essential utilities
    curl
    wget
    git
    zsh
    unzip
    tar
    ca-certificates
    gnupg
    software-properties-common
    fontconfig

    # Build essentials & libraries for tool compilation (python, tmux, etc.)
    build-essential
    bison
    pkg-config
    libevent-dev
    ncurses-dev
    libssl-dev
    zlib1g-dev
    libbz2-dev
    libreadline-dev
    libsqlite3-dev
    libffi-dev
    liblzma-dev
    llvm
    libxml2-dev
    libxmlsec1-dev
    tk-dev
    xz-utils
)

log_info "Installing essential system packages and build dependencies..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${PACKAGES[@]}"

log_success "System packages and build dependencies installed successfully."
