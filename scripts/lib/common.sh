#!/usr/bin/env bash
# Common helper functions and environment configuration

set -euo pipefail

# ANSI color codes
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_BOLD='\033[1m'
readonly COLOR_RESET='\033[0m'

log_info() {
    printf "${COLOR_BLUE}${COLOR_BOLD}[INFO]${COLOR_RESET} %s\n" "$*"
}

log_success() {
    printf "${COLOR_GREEN}${COLOR_BOLD}[OK]${COLOR_RESET} %s\n" "$*"
}

log_warn() {
    printf "${COLOR_YELLOW}${COLOR_BOLD}[WARN]${COLOR_RESET} %s\n" "$*"
}

log_error() {
    printf "${COLOR_RED}${COLOR_BOLD}[ERROR]${COLOR_RESET} %s\n" "$*" >&2
}

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# Keep sudo timestamp updated in background
init_sudo() {
    if [ "$EUID" -ne 0 ]; then
        log_info "Elevating privileges for system package operations..."
        sudo -v || {
            log_error "Failed to authenticate with sudo."
            exit 1
        }
        # Keep-alive loop in background
        while true; do
            sudo -n true
            sleep 60
            kill -0 "$$" || exit
        done 2>/dev/null &
        SUDO_PID=$!
        trap 'kill "${SUDO_PID:-}" 2>/dev/null || true' EXIT
    fi
}
