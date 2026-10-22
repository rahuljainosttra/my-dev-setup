#!/usr/bin/env bash
# 01-docker.sh - Install official Docker CE and configure user group permissions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_info "Running 01-docker.sh: Configuring official Docker CE repository..."

if has_cmd docker && docker --version >/dev/null 2>&1; then
    log_info "Docker is already installed: $(docker --version)"
else
    # Install prerequisites
    sudo install -m 0755 -d /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/docker.asc ]; then
        log_info "Fetching Docker official GPG key..."
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
    fi

    UBUNTU_CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME:-noble}")"
    ARCH="$(dpkg --print-architecture)"

    log_info "Adding Docker APT repository for ${UBUNTU_CODENAME} (${ARCH})..."
    echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME} stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    log_success "Docker CE installed successfully."
fi

# Ensure docker service is running
if has_cmd systemctl; then
    sudo systemctl enable --now docker 2>/dev/null || true
fi

# Add target user to docker group
if ! groups "${TARGET_USER}" | grep -q '\bdocker\b'; then
    log_info "Adding user '${TARGET_USER}' to 'docker' group..."
    sudo groupadd -f docker
    sudo usermod -aG docker "${TARGET_USER}"
    log_warn "Note: You may need to log out and back in (or run 'newgrp docker') for docker group permissions to take effect."
else
    log_info "User '${TARGET_USER}' is already in 'docker' group."
fi

log_success "Docker setup completed."
