#!/usr/bin/env bash
# 05-dotfiles.sh - Safely symlink configuration files with automatic backups

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOTFILES_DIR="${REPO_ROOT}/dotfiles"

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(eval echo "~${TARGET_USER}")"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${TARGET_HOME}/.dotfiles_backup/${TIMESTAMP}"
HAS_BACKUPS=false

log_info "Running 05-dotfiles.sh: Linking dotfiles to ${TARGET_HOME}..."

safe_symlink() {
    local src="$1"
    local dest="$2"

    if [ ! -e "${src}" ] && [ ! -d "${src}" ]; then
        log_warn "Source ${src} does not exist. Skipping."
        return 0
    fi

    # If destination is already the desired symlink, skip
    if [ -L "${dest}" ] && [ "$(readlink -f "${dest}")" = "$(readlink -f "${src}")" ]; then
        log_info "${dest} is already linked to ${src}."
        return 0
    fi

    # If destination exists (as regular file, directory, or different symlink), back it up
    if [ -e "${dest}" ] || [ -L "${dest}" ]; then
        if [ "$HAS_BACKUPS" = false ]; then
            mkdir -p "${BACKUP_DIR}"
            HAS_BACKUPS=true
            log_info "Creating backup directory at ${BACKUP_DIR}..."
        fi
        local rel_path="${dest#${TARGET_HOME}/}"
        local dest_backup="${BACKUP_DIR}/${rel_path}"
        mkdir -p "$(dirname "${dest_backup}")"
        mv "${dest}" "${dest_backup}"
        log_warn "Backed up existing ${dest} -> ${dest_backup}"
    fi

    mkdir -p "$(dirname "${dest}")"
    ln -sfn "${src}" "${dest}"
    log_success "Linked: ${dest} -> ${src}"
}

# 1. Setup ~/.gitconfig.local first (before linking ~/.gitconfig) to preserve existing identity
GITCONFIG_LOCAL="${TARGET_HOME}/.gitconfig.local"
if [ ! -f "${GITCONFIG_LOCAL}" ]; then
    log_info "Setting up local Git identity in ${GITCONFIG_LOCAL}..."
    CURRENT_NAME="$(git config --global user.name 2>/dev/null || echo "")"
    CURRENT_EMAIL="$(git config --global user.email 2>/dev/null || echo "")"

    # Interactive prompt if running in a TTY and fields are missing
    if [ -t 0 ] && [ -z "${CURRENT_NAME}" ]; then
        read -rp "Enter your Git User Name: " INPUT_NAME
        CURRENT_NAME="${INPUT_NAME:-User}"
    fi
    if [ -t 0 ] && [ -z "${CURRENT_EMAIL}" ]; then
        read -rp "Enter your Git Email Address: " INPUT_EMAIL
        CURRENT_EMAIL="${INPUT_EMAIL:-user@example.com}"
    fi

    CURRENT_NAME="${CURRENT_NAME:-User}"
    CURRENT_EMAIL="${CURRENT_EMAIL:-user@example.com}"

    cat <<EOF > "${GITCONFIG_LOCAL}"
[user]
	name = ${CURRENT_NAME}
	email = ${CURRENT_EMAIL}

[url "ssh://git@stash.trioptima.net:7999"]
	insteadOf = https://stash.trioptima.net/scm
EOF
    log_success "Created ${GITCONFIG_LOCAL} with user '${CURRENT_NAME}' <${CURRENT_EMAIL}>."
else
    log_info "Existing ${GITCONFIG_LOCAL} preserved."
fi

# 2. Symlink root-level dotfiles
safe_symlink "${DOTFILES_DIR}/.zshrc" "${TARGET_HOME}/.zshrc"
safe_symlink "${DOTFILES_DIR}/.p10k.zsh" "${TARGET_HOME}/.p10k.zsh"
safe_symlink "${DOTFILES_DIR}/.tmux.conf" "${TARGET_HOME}/.tmux.conf"
safe_symlink "${DOTFILES_DIR}/.tool-versions" "${TARGET_HOME}/.tool-versions"
safe_symlink "${DOTFILES_DIR}/.gitconfig" "${TARGET_HOME}/.gitconfig"

# 3. Symlink .config directories
if [ -d "${DOTFILES_DIR}/.config/nvim" ]; then
    safe_symlink "${DOTFILES_DIR}/.config/nvim" "${TARGET_HOME}/.config/nvim"
fi

if [ "$HAS_BACKUPS" = true ]; then
    log_warn "Pre-existing files were safely preserved in: ${BACKUP_DIR}"
fi

log_success "Dotfiles linked successfully."
