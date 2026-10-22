#!/usr/bin/env bash
# 04-mise.sh - Install mise CLI, runtime languages, and developer tools

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

LOCAL_BIN="${TARGET_HOME}/.local/bin"

export PATH="${LOCAL_BIN}:${PATH}"

# Install mise CLI if not present
if ! has_cmd mise; then
    log_info "mise CLI not found. Installing mise..."
    # Attempt installation via official APT repository
    if has_cmd apt-get && [ "$EUID" -eq 0 -o -n "${SUDO_USER:-}" ]; then
        log_info "Setting up official mise APT repository..."
        sudo install -m 0755 -d /etc/apt/keyrings
        wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg > /dev/null
        sudo chmod a+r /etc/apt/keyrings/mise-archive-keyring.gpg
        ARCH="$(dpkg --print-architecture)"
        echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=${ARCH}] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list > /dev/null
        sudo apt-get update -y
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mise
    else
        log_info "Installing standalone mise binary to ${LOCAL_BIN}/mise..."
        mkdir -p "${LOCAL_BIN}"
        curl -fsSL https://mise.run | MISE_INSTALL_PATH="${LOCAL_BIN}/mise" sh
    fi
    log_success "mise installed successfully: $(mise --version | head -n 1)"
else
    log_info "mise CLI already installed: $(mise --version | head -n 1)"
fi

# Activate mise in default mode
eval "$(mise activate bash)"

# Ensure global tools from mise configuration are installed
DOTFILES_DIR="${SCRIPT_DIR}/../dotfiles"
if [ -f "${TARGET_HOME}/.config/mise/config.toml" ]; then
    log_info "Installing developer runtimes and tools using mise (global config)..."
    mise install --yes
elif [ -f "${DOTFILES_DIR}/.config/mise/config.toml" ] || [ -f "${DOTFILES_DIR}/mise.toml" ]; then
    log_info "Installing developer runtimes and tools using mise (dotfiles repo)..."
    mise install --yes -C "${DOTFILES_DIR}"
fi

log_success "mise setup and tools installation completed."
