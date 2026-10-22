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

# Resolve non-root target user and home directory safely (handling minimal containers where USER or HOME is unbound)
TARGET_USER="${SUDO_USER:-${USER:-$(id -un 2>/dev/null || whoami 2>/dev/null || echo "root")}}"
TARGET_HOME="$(getent passwd "${TARGET_USER}" 2>/dev/null | cut -d: -f6)"
if [ -z "${TARGET_HOME}" ]; then
    TARGET_HOME="${HOME:-}"
fi
if [ -z "${TARGET_HOME}" ]; then
    if [ "${TARGET_USER}" = "root" ]; then
        TARGET_HOME="/root"
    else
        TARGET_HOME="/home/${TARGET_USER}"
    fi
fi
export TARGET_USER TARGET_HOME
export USER="${USER:-$TARGET_USER}"
export HOME="${HOME:-$TARGET_HOME}"

# In minimal container environments without sudo where running as root, provide a pass-through wrapper
if [ "$EUID" -eq 0 ] && ! has_cmd sudo; then
    sudo() {
        while [ $# -gt 0 ]; do
            case "$1" in
                -u|-g)
                    shift 2
                    ;;
                -n|-v|-k|-E|-S|-s|-i)
                    shift 1
                    ;;
                *=*)
                    export "$1"
                    shift 1
                    ;;
                --)
                    shift
                    break
                    ;;
                *)
                    break
                    ;;
            esac
        done
        if [ $# -gt 0 ]; then
            "$@"
        fi
    }
fi

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
