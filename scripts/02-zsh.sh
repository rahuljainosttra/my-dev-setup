#!/usr/bin/env bash
# 02-zsh.sh - Setup Zsh as default shell, Oh My Zsh, Powerlevel10k, and plugins

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

ZSH_BIN="$(command -v zsh || echo "/usr/bin/zsh")"

log_info "Running 02-zsh.sh: Configuring Zsh for ${TARGET_USER}..."

# Ensure Zsh is the default shell
CURRENT_SHELL="$(getent passwd "${TARGET_USER}" | cut -d: -f7)"
if [ "${CURRENT_SHELL}" != "${ZSH_BIN}" ]; then
    log_info "Setting default shell to ${ZSH_BIN} for ${TARGET_USER}..."
    sudo chsh -s "${ZSH_BIN}" "${TARGET_USER}"
else
    log_info "Default shell is already ${ZSH_BIN}."
fi

# Install Oh My Zsh if not already installed
OH_MY_ZSH_DIR="${TARGET_HOME}/.oh-my-zsh"
if [ ! -d "${OH_MY_ZSH_DIR}" ]; then
    log_info "Installing Oh My Zsh (unattended)..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended --keep-zshrc
    log_success "Oh My Zsh installed."
else
    log_info "Oh My Zsh is already installed at ${OH_MY_ZSH_DIR}."
fi

ZSH_CUSTOM="${OH_MY_ZSH_DIR}/custom"
mkdir -p "${ZSH_CUSTOM}/themes" "${ZSH_CUSTOM}/plugins"

# Install / update Powerlevel10k theme
P10K_DIR="${ZSH_CUSTOM}/themes/powerlevel10k"
if [ ! -d "${P10K_DIR}" ]; then
    log_info "Cloning Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${P10K_DIR}"
else
    log_info "Powerlevel10k theme already present. Updating..."
    git -C "${P10K_DIR}" pull --ff-only 2>/dev/null || true
fi

# Clone / update custom plugins
clone_or_update_plugin() {
    local repo_url="$1"
    local dest_dir="$2"
    local plugin_name="$3"

    if [ ! -d "${dest_dir}" ]; then
        log_info "Installing zsh plugin: ${plugin_name}..."
        git clone --depth=1 "${repo_url}" "${dest_dir}"
    else
        log_info "Plugin ${plugin_name} already present. Updating..."
        git -C "${dest_dir}" pull --ff-only 2>/dev/null || true
    fi
}

clone_or_update_plugin \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" \
    "zsh-syntax-highlighting"

clone_or_update_plugin \
    "https://github.com/jeffreytse/zsh-vi-mode.git" \
    "${ZSH_CUSTOM}/plugins/zsh-vi-mode" \
    "zsh-vi-mode"

log_success "Zsh environment and plugins configured successfully."
