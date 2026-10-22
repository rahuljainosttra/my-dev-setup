#!/usr/bin/env bash
# 03-fonts.sh - Install MesloLGS NF and JetBrainsMono Nerd Fonts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(eval echo "~${TARGET_USER}")"
FONTS_DIR="${TARGET_HOME}/.local/share/fonts/NerdFonts"

log_info "Running 03-fonts.sh: Setting up Nerd Fonts in ${FONTS_DIR}..."

mkdir -p "${FONTS_DIR}"

# 1. Install MesloLGS NF (Recommended by Powerlevel10k)
MESLO_URL_BASE="https://github.com/romkatv/powerlevel10k-media/raw/master"
MESLO_FONTS=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
)

log_info "Installing MesloLGS NF fonts..."
for font in "${MESLO_FONTS[@]}"; do
    if [ ! -f "${FONTS_DIR}/${font}" ]; then
        log_info "Downloading ${font}..."
        curl -fsSL "${MESLO_URL_BASE}/${font// /%20}" -o "${FONTS_DIR}/${font}"
    fi
done

# 2. Install JetBrains Mono Nerd Font
JB_DIR="${FONTS_DIR}/JetBrainsMono"
if [ ! -d "${JB_DIR}" ]; then
    log_info "Downloading JetBrains Mono Nerd Font..."
    mkdir -p "${JB_DIR}"
    TEMP_ARCHIVE="$(mktemp /tmp/jetbrains-mono-XXXXXX.tar.xz)"
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" -o "${TEMP_ARCHIVE}"
    tar -xf "${TEMP_ARCHIVE}" -C "${JB_DIR}"
    rm -f "${TEMP_ARCHIVE}"
    log_success "JetBrains Mono Nerd Font extracted."
else
    log_info "JetBrains Mono Nerd Font already present."
fi

# Refresh font cache
if has_cmd fc-cache; then
    log_info "Updating system font cache..."
    fc-cache -f "${FONTS_DIR}" >/dev/null 2>&1 || true
    log_success "Font cache updated."
fi

log_success "Nerd fonts installation complete."
