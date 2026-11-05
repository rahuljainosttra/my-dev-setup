#!/usr/bin/env bash
# cleanup-legacy.sh - Safely clean up system packages and binaries superseded by mise

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper functions
log_info() { printf "\033[0;34m\033[1m[INFO]\033[0m %s\n" "$*"; }
log_success() { printf "\033[0;32m\033[1m[OK]\033[0m %s\n" "$*"; }
log_warn() { printf "\033[0;33m\033[1m[WARN]\033[0m %s\n" "$*"; }
has_cmd() { command -v "$1" >/dev/null 2>&1; }

TARGET_HOME="${HOME:-~}"
TARGET_USER="${SUDO_USER:-${USER:-$(id -un 2>/dev/null || whoami)}}"

DRY_RUN=false
UNINSTALL_MISE=true
UNINSTALL_DOCKER=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Safely clean up legacy system packages and binaries superseded by mise.

Options:
  --all               Completely remove legacy packages, mise, and Docker
  --dry-run           Simulate cleanup without making any changes
  --uninstall-docker  Completely remove Docker CE, rootless service, containers, and data
  -h, --help          Show this help message and exit

Examples:
  ./scripts/cleanup-legacy.sh --dry-run
  ./scripts/cleanup-legacy.sh
  ./scripts/cleanup-legacy.sh --all --dry-run
  ./scripts/cleanup-legacy.sh --all
  ./scripts/cleanup-legacy.sh --uninstall-docker --dry-run
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --all)
            UNINSTALL_MISE=true
            UNINSTALL_DOCKER=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --uninstall-mise)
            UNINSTALL_MISE=true
            shift
            ;;
        --uninstall-docker)
            UNINSTALL_DOCKER=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_warn "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

log_info "Evaluating legacy system packages and binaries superseded by mise..."

# 1. User-local binaries (~/.local/bin)
LOCAL_BIN="${TARGET_HOME}/.local/bin"
LOCAL_REMOVALS=(
    "${LOCAL_BIN}/terraform"
    "${LOCAL_BIN}/fd"
    "${LOCAL_BIN}/ruff"
    "${LOCAL_BIN}/openstack"
    "${LOCAL_BIN}/pre-commit"
    "${LOCAL_BIN}/powerline"
    "${LOCAL_BIN}/powerline-config"
    "${LOCAL_BIN}/powerline-daemon"
    "${LOCAL_BIN}/powerline-lint"
    "${LOCAL_BIN}/powerline-render"
    "${LOCAL_BIN}/chardetect"
    "${LOCAL_BIN}/gcloud"
    "${LOCAL_BIN}/gsutil"
    "${LOCAL_BIN}/bq"
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

# 2. Obsolete backup files and directories in home
HOME_BACKUPS=(
    "${TARGET_HOME}/nvim_backup_09_19"
    "${TARGET_HOME}/.vimrc.1"
    "${TARGET_HOME}/.vimrc.29nov2023"
    "${TARGET_HOME}/.vimrc.old.1701165444"
    "${TARGET_HOME}/.profile.bak"
    "${TARGET_HOME}/.dotfiles_backup"
    "${TARGET_HOME}/.zcompdump-LIN6K0YRQ3-5.8.1"
    "${TARGET_HOME}/.zcompdump-LIN6K0YRQ3-5.8.1.zwc"
)
for file in "${HOME_BACKUPS[@]}"; do
    if [ -e "${file}" ] || [ -L "${file}" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would remove backup file/dir: ${file}"
        else
            rm -rf "${file}" 2>/dev/null || sudo rm -rf "${file}"
            log_success "Removed backup file/dir: ${file}"
        fi
    fi
done

# 3. Pipx packages and pipx cleanup (superseded by uv)
if has_cmd pipx; then
    PIPX_PKGS="$(pipx list --short 2>/dev/null || true)"
    if [ -n "${PIPX_PKGS}" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would uninstall all pipx packages:"
            while IFS= read -r line; do
                [ -n "$line" ] && log_info "  - ${line}"
            done <<< "${PIPX_PKGS}"
        else
            log_info "Uninstalling all pipx packages..."
            pipx uninstall-all
            log_success "All pipx packages uninstalled."
        fi
    else
        log_info "No pipx packages found to uninstall."
    fi

    # After uninstalling all packages installed by pipx, cleanup pipx itself
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would cleanup pipx (remove APT package and ~/.local/pipx)"
    else
        log_info "Cleaning up pipx..."
        if dpkg -l pipx 2>/dev/null | grep -q "^ii"; then
            sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y pipx
            sudo apt-get autoremove -y
            log_success "Removed pipx APT package."
        fi
        rm -rf "${TARGET_HOME}/.local/pipx" "${TARGET_HOME}/.cache/pipx" "${TARGET_HOME}/.local/state/pipx"
        log_success "Cleaned up pipx directories."
    fi
elif [ -d "${TARGET_HOME}/.local/pipx" ]; then
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would remove leftover pipx directory: ${TARGET_HOME}/.local/pipx"
    else
        rm -rf "${TARGET_HOME}/.local/pipx"
        log_success "Removed leftover pipx directory."
    fi
fi

# 4. APT packages superseded by mise
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
    google-cloud-cli
    google-cloud-sdk
)

INSTALLED_APT=()
for pkg in "${APT_PACKAGES[@]}"; do
    if dpkg -l "${pkg}" 2>/dev/null | grep -q "^ii"; then
        INSTALLED_APT+=("${pkg}")
    fi
done

# Also discover any installed Google Cloud CLI components (e.g. google-cloud-cli-*)
for pkg in $(dpkg -l "google-cloud-*" 2>/dev/null | awk '/^ii/{print $2}'); do
    if [[ ! " ${INSTALLED_APT[*]} " =~ " ${pkg} " ]]; then
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

# 5. Legacy Docker APT sources and signing keys (superseded by declarative mise-docker.sources)
LEGACY_DOCKER_SOURCES=(
    /etc/apt/sources.list.d/docker.list
    /etc/apt/sources.list.d/docker.list.disabled
    /etc/apt/sources.list.d/docker.list.save
    /etc/apt/keyrings/docker.asc
    /etc/apt/trusted.gpg.d/docker.gpg
)

FOUND_LEGACY_DOCKER=()
for src in "${LEGACY_DOCKER_SOURCES[@]}"; do
    if [ -e "${src}" ] || [ -L "${src}" ]; then
        FOUND_LEGACY_DOCKER+=("${src}")
    fi
done

if [ ${#FOUND_LEGACY_DOCKER[@]} -gt 0 ]; then
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would remove conflicting legacy Docker APT source(s)/key(s): ${FOUND_LEGACY_DOCKER[*]}"
    else
        log_info "Removing conflicting legacy Docker APT source(s)/key(s): ${FOUND_LEGACY_DOCKER[*]}..."
        for src in "${FOUND_LEGACY_DOCKER[@]}"; do
            sudo rm -f "${src}"
        done
        log_success "Conflicting legacy Docker APT sources/keys removed."
    fi
else
    log_info "No conflicting legacy Docker APT sources found."
fi

# 5b. Legacy Google Cloud SDK APT sources and signing keys (superseded by mise gcloud)
LEGACY_GCLOUD_SOURCES=(
    /etc/apt/sources.list.d/google-cloud-sdk.list
    /etc/apt/sources.list.d/google-cloud-sdk.list.save
    /etc/apt/sources.list.d/google-cloud-sdk.list.distUpgrade
    /etc/apt/sources.list.d/google-cloud-sdk.sources
    /usr/share/keyrings/cloud.google.gpg
    /usr/share/keyrings/cloud.google.gpg~
    /etc/apt/trusted.gpg.d/cloud.google.gpg
    /etc/apt/keyrings/google-cloud-sdk.gpg
)

FOUND_LEGACY_GCLOUD=()
for src in "${LEGACY_GCLOUD_SOURCES[@]}"; do
    if [ -e "${src}" ] || [ -L "${src}" ]; then
        FOUND_LEGACY_GCLOUD+=("${src}")
    fi
done

if [ ${#FOUND_LEGACY_GCLOUD[@]} -gt 0 ]; then
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would remove legacy Google Cloud SDK APT source(s)/key(s): ${FOUND_LEGACY_GCLOUD[*]}"
    else
        log_info "Removing legacy Google Cloud SDK APT source(s)/key(s): ${FOUND_LEGACY_GCLOUD[*]}..."
        for src in "${FOUND_LEGACY_GCLOUD[@]}"; do
            sudo rm -f "${src}"
        done
        log_success "Legacy Google Cloud SDK APT sources/keys removed."
    fi
else
    log_info "No legacy Google Cloud SDK APT sources found."
fi

# 6. Snap packages superseded by mise / obsolete
SNAP_PACKAGES=(
    kubectl
    yq
    cqlsh
    google-cloud-cli
    google-cloud-sdk
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

    # Prune old disabled snap revisions to reclaim disk space
    DISABLED_SNAPS="$(LANG=C snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}' || true)"
    if [ -n "${DISABLED_SNAPS}" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would prune disabled snap revisions:"
            while read -r name rev; do
                [ -n "$name" ] && log_info "  - ${name} (rev ${rev})"
            done <<< "${DISABLED_SNAPS}"
        else
            log_info "Pruning disabled snap revisions..."
            while read -r name rev; do
                if [ -n "$name" ] && [ -n "$rev" ]; then
                    sudo snap remove "$name" --revision="$rev" 2>/dev/null || true
                fi
            done <<< "${DISABLED_SNAPS}"
            log_success "Disabled snap revisions pruned."
        fi
    fi
fi

# 7. Outdated standalone binaries and global node modules in /usr/local
USR_LOCAL_BIN_SUPERSEDED=(
    /usr/local/bin/kubectl
    /usr/local/bin/flux
    /usr/local/bin/fluxv1
    /usr/local/bin/clojure
    /usr/local/bin/clj
    /usr/local/bin/cljstyle
    /usr/local/bin/zprint
    /usr/local/bin/pre-commit
    /usr/local/bin/npx
    /usr/local/bin/yarn
    /usr/local/bin/yarnpkg
    /usr/local/bin/instant-markdown-d
    /usr/local/bin/gcloud
    /usr/local/bin/gsutil
    /usr/local/bin/bq
    /usr/local/lib/node_modules/instant-markdown-d
    /usr/local/lib/node_modules/npx
    /usr/local/lib/node_modules/yarn
)

for bin_path in "${USR_LOCAL_BIN_SUPERSEDED[@]}"; do
    if [ -e "${bin_path}" ] || [ -L "${bin_path}" ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would remove outdated binary/module: ${bin_path}"
        else
            sudo rm -rf "${bin_path}"
            log_success "Removed outdated binary/module: ${bin_path}"
        fi
    fi
done

# 8. Mise cleanup / superseded tools
if [ "$UNINSTALL_MISE" = true ]; then
    log_info "Evaluating complete removal of mise..."
    if has_cmd mise; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would run 'mise implode --config' to remove mise runtimes and shims:"
            mise implode --dry-run --config 2>/dev/null || true
        else
            log_info "Running 'mise implode --yes --config' to remove mise runtimes and shims..."
            mise implode --yes --config || true
            log_success "mise imploded successfully."
        fi
    fi

    # Remove APT package if installed via APT
    if dpkg -l mise 2>/dev/null | grep -q "^ii"; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would remove mise APT package"
        else
            log_info "Removing mise APT package..."
            sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y mise
            sudo apt-get autoremove -y
            log_success "Removed mise APT package."
        fi
    fi

    # Ensure all mise directories, binaries, APT sources, and keyrings are removed
    MISE_PATHS=(
        "${TARGET_HOME}/.local/share/mise"
        "${TARGET_HOME}/.local/state/mise"
        "${TARGET_HOME}/.cache/mise"
        "${TARGET_HOME}/.config/mise"
        "${TARGET_HOME}/.local/bin/mise"
        "/usr/local/bin/mise"
        "/usr/local/share/mise"
        "/etc/apt/sources.list.d/mise.list"
        "/etc/apt/keyrings/mise-archive-keyring.gpg"
    )
    for path in "${MISE_PATHS[@]}"; do
        if [ -e "${path}" ] || [ -L "${path}" ]; then
            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY-RUN] Would remove leftover mise directory/file: ${path}"
            else
                if [ -w "$(dirname "${path}")" ]; then
                    rm -rf "${path}"
                else
                    sudo rm -rf "${path}" 2>/dev/null || true
                fi
                log_success "Removed mise directory/file: ${path}"
            fi
        fi
    done
fi

# 9. Legacy tool caches and runtime directories
CACHE_REMOVALS=(
    "${TARGET_HOME}/.cache/pip"
    "${TARGET_HOME}/.cache/virtualenv"
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

# 10. Clean APT package cache
if has_cmd apt-get; then
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would clean APT archive cache (apt-get clean)"
    else
        log_info "Cleaning APT archive cache..."
        sudo apt-get clean
        log_success "APT archive cache cleaned."
    fi
fi

# 11. Docker cleanup
if [ "$UNINSTALL_DOCKER" = true ]; then
    log_info "Evaluating complete removal of Docker..."

    # 10a. Stop and disable Docker services (rootless and system)
    if has_cmd systemctl; then
        if systemctl --user is-active docker >/dev/null 2>&1 || [ -f "${TARGET_HOME}/.config/systemd/user/docker.service" ]; then
            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY-RUN] Would stop and disable rootless docker service"
            else
                systemctl --user stop docker.service 2>/dev/null || true
                systemctl --user disable docker.service 2>/dev/null || true
                log_success "Rootless docker service stopped and disabled."
            fi
        fi
        if has_cmd dockerd-rootless-setuptool.sh; then
            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY-RUN] Would run dockerd-rootless-setuptool.sh uninstall"
            else
                dockerd-rootless-setuptool.sh uninstall --force 2>/dev/null || true
                log_success "Rootless dockerd uninstalled."
            fi
        fi
        if systemctl is-active docker >/dev/null 2>&1 || [ -f /lib/systemd/system/docker.service ] || [ -f /etc/systemd/system/docker.service ]; then
            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY-RUN] Would stop and disable system docker and containerd services"
            else
                sudo systemctl stop docker.service docker.socket containerd.service 2>/dev/null || true
                sudo systemctl disable docker.service docker.socket containerd.service 2>/dev/null || true
                log_success "System docker and containerd services stopped."
            fi
        fi
    fi

    # 10b. Remove Docker APT packages
    DOCKER_APT_PACKAGES=(
        docker-ce
        docker-ce-cli
        containerd.io
        docker-buildx-plugin
        docker-compose-plugin
        docker-ce-rootless-extras
        docker.io
        docker-doc
        docker-compose
        podman-docker
    )
    INSTALLED_DOCKER_APT=()
    for pkg in "${DOCKER_APT_PACKAGES[@]}"; do
        if dpkg -l "${pkg}" 2>/dev/null | grep -q "^ii"; then
            INSTALLED_DOCKER_APT+=("${pkg}")
        fi
    done
    if [ ${#INSTALLED_DOCKER_APT[@]} -gt 0 ]; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would purge Docker APT packages: ${INSTALLED_DOCKER_APT[*]}"
        else
            log_info "Purging Docker APT packages: ${INSTALLED_DOCKER_APT[*]}..."
            sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y "${INSTALLED_DOCKER_APT[@]}"
            sudo apt-get autoremove -y
            log_success "Docker APT packages purged."
        fi
    fi

    # 10c. Remove Docker APT repositories and signing keys
    DOCKER_APT_SOURCES=(
        /etc/apt/sources.list.d/docker.list
        /etc/apt/sources.list.d/docker.list.disabled
        /etc/apt/sources.list.d/mise-docker.sources
        /etc/apt/keyrings/docker.asc
        /etc/apt/trusted.gpg.d/docker.gpg
    )
    for src in "${DOCKER_APT_SOURCES[@]}"; do
        if [ -e "${src}" ]; then
            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY-RUN] Would remove Docker APT source/key: ${src}"
            else
                sudo rm -f "${src}"
                log_success "Removed Docker APT source/key: ${src}"
            fi
        fi
    done

    # 10d. Remove user Docker configuration, credentials, and systemd units
    DOCKER_USER_PATHS=(
        "${TARGET_HOME}/.docker"
        "${TARGET_HOME}/.local/bin/docker-credential-secretservice"
        "${TARGET_HOME}/.config/systemd/user/docker.service"
    )
    for u_path in "${DOCKER_USER_PATHS[@]}"; do
        if [ -e "${u_path}" ] || [ -L "${u_path}" ]; then
            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY-RUN] Would remove user Docker file/dir: ${u_path}"
            else
                rm -rf "${u_path}"
                log_success "Removed user Docker file/dir: ${u_path}"
            fi
        fi
    done

    # 10e. Remove system Docker data directories and sockets
    DOCKER_SYSTEM_DIRS=(
        /var/lib/docker
        /var/lib/containerd
        /etc/docker
        /var/run/docker.sock
    )
    for s_dir in "${DOCKER_SYSTEM_DIRS[@]}"; do
        if [ -e "${s_dir}" ] || [ -L "${s_dir}" ]; then
            if [ "$DRY_RUN" = true ]; then
                log_info "[DRY-RUN] Would remove system Docker data dir: ${s_dir}"
            else
                sudo rm -rf "${s_dir}"
                log_success "Removed system Docker data dir: ${s_dir}"
            fi
        fi
    done

    # 10f. Remove user from docker group
    if groups "${TARGET_USER}" 2>/dev/null | grep -q '\bdocker\b'; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would remove user '${TARGET_USER}' from 'docker' group"
        else
            sudo gpasswd -d "${TARGET_USER}" docker 2>/dev/null || true
            log_success "Removed user '${TARGET_USER}' from 'docker' group."
        fi
    fi
else
    # Prune dangling Docker resources (networks, build cache, stopped containers)
    if has_cmd docker && docker info >/dev/null 2>&1; then
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would prune dangling Docker build cache and networks"
        else
            log_info "Pruning dangling Docker build cache and networks..."
            docker system prune -f >/dev/null 2>&1 || true
            log_success "Dangling Docker build cache pruned."
        fi
    fi
fi

log_success "Cleanup process finished."
