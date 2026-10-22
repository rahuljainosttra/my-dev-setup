#!/usr/bin/env bash
# cleanup-legacy.sh - Safely clean up system packages and binaries superseded by mise

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=true
fi

log_info "Evaluating legacy system packages and binaries superseded by mise..."

# 1. User-local binaries (~/.local/bin)
LOCAL_BIN="${TARGET_HOME}/.local/bin"
LOCAL_REMOVALS=(
    "${LOCAL_BIN}/terraform"
    "${LOCAL_BIN}/fd"
    "${LOCAL_BIN}/ruff"
    "${LOCAL_BIN}/pre-commit"
)

for file in "${LOCAL_REMOVALS[@]}"; do
    if [ -e "${file}" ] || [ -L "${file}" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would remove user binary: ${file}"
        else
            rm -f "${file}"
            log_success "Removed user binary: ${file}"
        fi
    fi
done

# 2. Obsolete root-owned backups in home
ROOT_BACKUPS=(
    "${TARGET_HOME}/nvim_backup_09_19"
)
for file in "${ROOT_BACKUPS[@]}"; do
    if [ -e "${file}" ] || [ -L "${file}" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would remove old backup binary: ${file}"
        else
            sudo rm -f "${file}"
            log_success "Removed old backup binary: ${file}"
        fi
    fi
done

# 3. APT packages superseded by mise
APT_PACKAGES=(
    neovim
    tmux
    ripgrep
    fd-find
    fzf
    gh
    helm
    vault
    pre-commit
)

INSTALLED_APT=()
for pkg in "${APT_PACKAGES[@]}"; do
    if dpkg -l "${pkg}" 2>/dev/null | grep -q "^ii"; then
        INSTALLED_APT+=("${pkg}")
    fi
done

if [ ${#INSTALLED_APT[@]} -gt 0 ]; then
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would remove APT packages: ${INSTALLED_APT[*]}"
    else
        log_info "Removing superseded APT packages: ${INSTALLED_APT[*]}..."
        sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y "${INSTALLED_APT[@]}"
        sudo apt-get autoremove -y
        log_success "APT packages removed."
    fi
else
    log_info "No superseded APT packages found."
fi

# 4. Snap packages superseded by mise
SNAP_PACKAGES=(
    kubectl
    yq
)

if has_cmd snap; then
    for snap_pkg in "${SNAP_PACKAGES[@]}"; do
        if snap list "${snap_pkg}" >/dev/null 2>&1; then
            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY-RUN] Would remove Snap package: ${snap_pkg}"
            else
                log_info "Removing Snap package: ${snap_pkg}..."
                sudo snap remove "${snap_pkg}"
                log_success "Snap package ${snap_pkg} removed."
            fi
        fi
    done
fi

# 5. Outdated standalone binaries in /usr/local/bin
USR_LOCAL_BIN_SUPERSEDED=(
    /usr/local/bin/kubectl
    /usr/local/bin/flux
    /usr/local/bin/clojure
    /usr/local/bin/clj
    /usr/local/bin/cljstyle
    /usr/local/bin/zprint
    /usr/local/bin/pre-commit
)

for bin_path in "${USR_LOCAL_BIN_SUPERSEDED[@]}"; do
    if [ -f "${bin_path}" ] || [ -L "${bin_path}" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would remove outdated binary: ${bin_path}"
        else
            sudo rm -f "${bin_path}"
            log_success "Removed outdated binary: ${bin_path}"
        fi
    fi
done

# 6. Superseded mise tools
if has_cmd mise && [ -d "${TARGET_HOME}/.local/share/mise/installs/pre-commit" ]; then
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would uninstall obsolete mise tool: pre-commit"
    else
        log_info "Uninstalling obsolete mise tool: pre-commit..."
        mise uninstall pre-commit
        mise reshim
        log_success "Obsolete mise tool pre-commit removed."
    fi
fi

# 7. Legacy tool caches and runtime directories (superseded by prek)
CACHE_REMOVALS=(
    "${TARGET_HOME}/.cache/pre-commit"
    "${TARGET_HOME}/.cache/pre-commit-zipapp"
    "${TARGET_HOME}/.cache/mise/pre-commit"
)

for cache_path in "${CACHE_REMOVALS[@]}"; do
    if [ -e "${cache_path}" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would remove legacy cache directory: ${cache_path}"
        else
            rm -rf "${cache_path}"
            log_success "Removed legacy cache directory: ${cache_path}"
        fi
    fi
done

# 8. Pipx packages superseded by mise/prek
if has_cmd pipx; then
    if pipx list --short 2>/dev/null | grep -q "^pre-commit "; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would remove pipx package: pre-commit"
        else
            log_info "Removing pipx package: pre-commit..."
            pipx uninstall pre-commit
            log_success "pipx package pre-commit removed."
        fi
    fi
fi

log_success "Cleanup process finished."
