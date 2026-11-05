#!/usr/bin/env bash
#
# setup.sh - Automated installer and configuration setup for Neovim 0.12 with asdf
#
set -euo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

DEFAULT_NVIM_VERSION="0.12.6"

log_info() {
    echo -e "${BLUE}[*]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

# 1. Locate nvim configuration source directory
locate_nvim_config() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [[ -f "$script_dir/init.lua" ]]; then
        echo "$script_dir"
    elif [[ -f "$script_dir/nvim/init.lua" ]]; then
        echo "$script_dir/nvim"
    elif [[ -f "$(dirname "$script_dir")/init.lua" ]]; then
        echo "$(cd "$script_dir/.." && pwd)"
    elif [[ -d "$HOME/trioptima/codebase/src/my-dev-utils/nvim" ]]; then
        echo "$HOME/trioptima/codebase/src/my-dev-utils/nvim"
    else
        echo ""
    fi
}

# 2. Ensure asdf is available and loaded in current shell
ensure_asdf() {
    if command -v asdf >/dev/null 2>&1; then
        log_success "asdf is already available in PATH ($(which asdf))"
        return 0
    fi

    log_info "asdf not found in PATH, searching common installation paths..."
    local asdf_locations=(
        "$HOME/.asdf/asdf.sh"
        "$HOME/.asdf/bin/asdf"
        "/opt/asdf-vm/asdf.sh"
        "/usr/local/opt/asdf/libexec/asdf.sh"
    )

    local found=false
    for loc in "${asdf_locations[@]}"; do
        if [[ -f "$loc" && "$loc" == *.sh ]]; then
            # shellcheck source=/dev/null
            source "$loc"
            found=true
            break
        elif [[ -x "$loc" ]]; then
            export PATH="$(dirname "$loc"):$HOME/.asdf/shims:$PATH"
            found=true
            break
        fi
    done

    # If still not found, offer to install asdf automatically
    if ! command -v asdf >/dev/null 2>&1; then
        log_warn "asdf is not installed. Installing asdf to ~/.asdf..."
        if ! command -v git >/dev/null 2>&1; then
            log_error "git is required to install asdf. Please install git first."
            exit 1
        fi
        git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.14.0
        # shellcheck source=/dev/null
        source "$HOME/.asdf/asdf.sh"
    fi

    # Ensure shims and bin are on PATH
    if [[ -d "$HOME/.asdf/shims" ]]; then
        export PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH"
    fi

    if command -v asdf >/dev/null 2>&1; then
        log_success "asdf loaded successfully"
    else
        log_error "Failed to locate or install asdf."
        exit 1
    fi
}

# 3. Check system build and runtime dependencies
check_dependencies() {
    log_info "Checking system build and runtime dependencies..."
    local missing=()
    local tools=("git" "make" "gcc" "rg" "fd" "node" "python3")

    for tool in "${tools[@]}"; do
        if [[ "$tool" == "fd" ]]; then
            if ! command -v fd >/dev/null 2>&1 && ! command -v fdfind >/dev/null 2>&1; then
                missing+=("fd (or fd-find)")
            fi
        elif [[ "$tool" == "gcc" ]]; then
            if ! command -v gcc >/dev/null 2>&1 && ! command -v clang >/dev/null 2>&1; then
                missing+=("gcc (or clang / build-essential)")
            fi
        else
            if ! command -v "$tool" >/dev/null 2>&1; then
                missing+=("$tool")
            fi
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warn "The following recommended dependencies were not found:"
        for m in "${missing[@]}"; do
            echo "    - $m"
        done
        echo ""
        echo "    Install commands for your OS:"
        echo "      • Ubuntu/Debian: sudo apt update && sudo apt install -y build-essential ripgrep fd-find python3 python3-pip nodejs npm git curl"
        echo "      • Fedora:        sudo dnf install -y @development-tools ripgrep fd-find python3 nodejs git curl"
        echo "      • Arch Linux:    sudo pacman -S base-devel ripgrep fd python nodejs git curl"
        echo "      • macOS:         brew install ripgrep fd node python3"
        echo ""
    else
        log_success "All core dependencies (git, make, compiler, rg, fd, node, python3) found"
    fi
}

# 4. Install neovim via asdf
install_neovim_asdf() {
    local target_version="$DEFAULT_NVIM_VERSION"

    # Read version from .tool-versions if present
    local config_dir
    config_dir="$(locate_nvim_config)"
    local tool_file=""

    if [[ -n "$config_dir" && -f "$config_dir/.tool-versions" ]]; then
        tool_file="$config_dir/.tool-versions"
    elif [[ -f ".tool-versions" ]]; then
        tool_file=".tool-versions"
    elif [[ -n "$config_dir" && -f "$(dirname "$config_dir")/.tool-versions" ]]; then
        tool_file="$(dirname "$config_dir")/.tool-versions"
    fi

    if [[ -n "$tool_file" ]]; then
        local found_ver
        found_ver="$(grep -E '^[[:space:]]*neovim[[:space:]]+' "$tool_file" | awk '{print $2}' || true)"
        if [[ -n "$found_ver" ]]; then
            target_version="$found_ver"
            log_info "Detected Neovim version $target_version from $tool_file"
        fi
    fi

    # Add neovim asdf plugin if not present
    if ! asdf plugin list 2>/dev/null | grep -qx "neovim"; then
        log_info "Adding asdf neovim plugin..."
        asdf plugin add neovim https://github.com/richin13/asdf-neovim.git
        log_success "asdf neovim plugin added"
    else
        log_success "asdf neovim plugin is already present"
    fi

    # Install target version if missing
    if ! asdf list neovim 2>/dev/null | grep -qw "$target_version"; then
        log_info "Installing Neovim $target_version with asdf (this downloads official prebuilt release)..."
        asdf install neovim "$target_version"
        log_success "Neovim $target_version installed"
    else
        log_success "Neovim $target_version is already installed in asdf"
    fi

    # Set as global / current version
    log_info "Setting global Neovim version to $target_version..."
    if asdf global neovim "$target_version" 2>/dev/null; then
        :
    elif asdf set --home neovim "$target_version" 2>/dev/null; then
        :
    fi
    asdf reshim neovim

    # Ensure shims are on PATH for current session
    export PATH="$HOME/.asdf/shims:$PATH"

    # Verify installation
    if command -v nvim >/dev/null 2>&1; then
        local actual_version
        actual_version="$(nvim --version | head -n 1)"
        log_success "Active Neovim binary: $actual_version ($(which nvim))"
    else
        log_error "Neovim executable not found in PATH after installation!"
        exit 1
    fi
}

# 5. Setup ~/.config/nvim symlink
setup_config() {
    local src
    src="$(locate_nvim_config)"

    if [[ -z "$src" || ! -f "$src/init.lua" ]]; then
        log_error "Could not locate nvim configuration (init.lua not found)."
        exit 1
    fi

    local target="$HOME/.config/nvim"
    mkdir -p "$HOME/.config"

    if [[ -e "$target" || -L "$target" ]]; then
        if [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$src")" ]]; then
            log_success "$target already points to $src"
            return 0
        fi

        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        log_warn "Existing $target detected. Backing up to $backup..."
        mv "$target" "$backup"
        log_success "Backup created: $backup"
    fi

    ln -sfn "$src" "$target"
    log_success "Created symlink: $target -> $src"
}

# 6. Bootstrap plugins and build extensions
bootstrap_plugins() {
    log_info "Bootstrapping plugins and building native extensions..."
    # Run headless nvim; disables auto-update so vim.pack.add clones pinned plugins and compiles fzf-native / luasnip
    NVIM_NO_UPDATE=1 nvim --headless "+qa"
    log_success "Plugins initialized and compiled successfully"
}

# 7. Main entrypoint
main() {
    echo -e "${BOLD}=========================================${NC}"
    echo -e "${BOLD}   Neovim 0.12 + asdf Setup Script      ${NC}"
    echo -e "${BOLD}=========================================${NC}"
    echo ""

    ensure_asdf
    check_dependencies
    install_neovim_asdf
    setup_config
    bootstrap_plugins

    echo ""
    echo -e "${BOLD}=========================================${NC}"
    echo -e "${GREEN}${BOLD}✓ Neovim setup completed successfully!${NC}"
    echo -e "${BOLD}=========================================${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. If asdf was just installed, make sure it is sourced in your shell RC (~/.bashrc or ~/.zshrc):"
    echo '     echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc'
    echo '     echo ". $HOME/.asdf/completions/asdf.bash" >> ~/.bashrc'
    echo ""
    echo "  2. Launch Neovim:"
    echo "     nvim"
    echo ""
}

main "$@"
