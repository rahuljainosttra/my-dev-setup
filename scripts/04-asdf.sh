#!/usr/bin/env bash
# 04-asdf.sh - Install asdf CLI, plugins, runtimes, and developer tools

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(eval echo "~${TARGET_USER}")"
LOCAL_BIN="${TARGET_HOME}/.local/bin"
ASDF_DATA_DIR="${TARGET_HOME}/.asdf"

mkdir -p "${LOCAL_BIN}" "${ASDF_DATA_DIR}"
export PATH="${LOCAL_BIN}:${ASDF_DATA_DIR}/shims:${PATH}"

# Install asdf binary if not present
if ! has_cmd asdf; then
    log_info "asdf CLI not found. Installing latest asdf binary to ${LOCAL_BIN}/asdf..."
    ARCH="$(uname -m)"
    case "${ARCH}" in
        x86_64) ASDF_ARCH="amd64" ;;
        aarch64|arm64) ASDF_ARCH="arm64" ;;
        *) ASDF_ARCH="amd64" ;;
    esac

    ASDF_LATEST_VERSION="v0.16.7"
    ASDF_TAR_URL="https://github.com/asdf-vm/asdf/releases/download/${ASDF_LATEST_VERSION}/asdf-${ASDF_LATEST_VERSION}-linux-${ASDF_ARCH}.tar.gz"

    TEMP_DIR="$(mktemp -d /tmp/asdf-install-XXXXXX)"
    curl -fsSL "${ASDF_TAR_URL}" -o "${TEMP_DIR}/asdf.tar.gz"
    tar -xzf "${TEMP_DIR}/asdf.tar.gz" -C "${TEMP_DIR}"
    install -m 0755 "${TEMP_DIR}/asdf" "${LOCAL_BIN}/asdf"
    rm -rf "${TEMP_DIR}"
    log_success "asdf installed successfully: $(asdf --version)"
else
    log_info "asdf CLI already installed: $(asdf --version)"
fi

# List of plugins and their repositories
declare -A PLUGINS=(
    ["golang"]="https://github.com/asdf-community/asdf-golang.git"
    ["nodejs"]="https://github.com/asdf-vm/asdf-nodejs.git"
    ["python"]="https://github.com/danhper/asdf-python.git"
    ["neovim"]="https://github.com/asdf-community/asdf-neovim.git"
    ["tmux"]="https://github.com/asdf-community/asdf-tmux.git"
    ["kubectl"]="https://github.com/asdf-community/asdf-kubectl.git"
)

log_info "Configuring asdf plugins..."
INSTALLED_PLUGINS="$(asdf plugin list 2>/dev/null || true)"

for plugin in "${!PLUGINS[@]}"; do
    repo="${PLUGINS[$plugin]}"
    if echo "${INSTALLED_PLUGINS}" | grep -qw "${plugin}"; then
        log_info "asdf plugin '${plugin}' is already added."
    else
        log_info "Adding asdf plugin '${plugin}' (${repo})..."
        asdf plugin add "${plugin}" "${repo}" || true
    fi
done

# Read dotfiles/.tool-versions and install
TOOL_VERSIONS_FILE="${SCRIPT_DIR}/../dotfiles/.tool-versions"
if [ -f "${TOOL_VERSIONS_FILE}" ]; then
    log_info "Installing tool versions declared in ${TOOL_VERSIONS_FILE}..."
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        plugin_name="$(echo "$line" | awk '{print $1}')"
        target_version="$(echo "$line" | awk '{print $2}')"

        if [ -n "$plugin_name" ] && [ -n "$target_version" ]; then
            resolved_version="$target_version"
            if [ "$target_version" = "latest" ]; then
                log_info "Resolving latest stable version for ${plugin_name}..."
                resolved_version="$(asdf latest "${plugin_name}" 2>/dev/null || echo "latest")"
            fi

            log_info "Installing ${plugin_name} ${resolved_version}..."
            asdf install "${plugin_name}" "${resolved_version}" || {
                log_warn "Failed to install ${plugin_name} ${resolved_version}. Skipping."
                continue
            }
            asdf set -u "${plugin_name}" "${resolved_version}" || true
            log_success "${plugin_name} ${resolved_version} is set as default."
        fi
    done < "${TOOL_VERSIONS_FILE}"
fi

log_info "Reshimming asdf..."
asdf reshim || true

log_success "asdf setup and tools installation completed."
