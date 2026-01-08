#!/bin/bash
# Common helper functions to DRY up the codebase

# ============================================================
# DRY-RUN HELPERS
# ============================================================

# Execute command or show what would be executed
run_cmd() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] $*"
        return 0
    fi
    "$@"
}

# Check if package/command already installed, handle dry-run
check_installed() {
    local cmd="$1"
    local name="${2:-$cmd}"

    if command -v "$cmd" &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[DRY-RUN] $name already installed (would skip)"
        else
            echo "$name already installed (skipping)"
        fi
        return 0
    fi
    return 1
}

# Sudo wrapper with dry-run support
sudo_cmd() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] sudo $*"
        return 0
    fi
    sudo "$@"
}

# Package manager install with dry-run
pkg_install() {
    local packages=("$@")

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] Would install: ${packages[*]}"
        return 0
    fi

    if is_macos; then
        brew install "${packages[@]}"
    elif is_debian; then
        sudo apt-get install -y "${packages[@]}"
    elif is_arch; then
        sudo pacman -S --noconfirm "${packages[@]}"
    fi
}

# Download file with dry-run support
download_file() {
    local url="$1"
    local dest="$2"

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] Would download $url → $dest"
        return 0
    fi

    curl -fsSL "$url" -o "$dest"
}

# Create directory with dry-run support
make_dir() {
    local dir="$1"

    if [[ -d "$dir" ]]; then
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] Would create directory: $dir"
        return 0
    fi

    mkdir -p "$dir"
}

# Move/install file with dry-run support
install_file() {
    local src="$1"
    local dest="$2"
    local use_sudo="${3:-false}"

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] Would install $src → $dest"
        return 0
    fi

    if [[ "$use_sudo" == true ]]; then
        sudo install -m 755 "$src" "$dest"
    else
        install -m 755 "$src" "$dest"
    fi
}

# ============================================================
# COMMON PATTERNS
# ============================================================

# Check if app is already installed (macOS .app check)
check_app_installed() {
    local app_name="$1"
    local app_path="/Applications/${app_name}.app"

    if [[ -d "$app_path" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[DRY-RUN] $app_name already installed (would skip)"
        else
            echo "$app_name already installed (skipping)"
        fi
        return 0
    fi
    return 1
}

# Standard status messages
status_installing() {
    local name="$1"
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] Would install $name..."
    else
        echo "Installing $name..."
    fi
}

status_success() {
    local name="$1"
    if [[ "$DRY_RUN" != true ]]; then
        echo "✓ $name installed successfully"
    fi
}

status_skip() {
    local name="$1"
    local reason="${2:-already installed}"
    echo "⊘ $name ($reason)"
}

# ============================================================
# FIND TOOLS (even if not in PATH yet)
# ============================================================

# Find a command in PATH or common install locations
# Usage: find_cmd <cmd> [paths...]
# Returns: 0 if found (and exports FOUND_CMD_PATH), 1 if not found
find_cmd() {
    local cmd="$1"
    shift
    local extra_paths=("$@")

    # Check PATH first
    if command -v "$cmd" &> /dev/null; then
        FOUND_CMD_PATH="$(command -v "$cmd")"
        return 0
    fi

    # Common install locations
    local common_paths=(
        "$HOME/.local/bin"
        "$HOME/.cargo/bin"
        "$HOME/.bun/bin"
        "$HOME/.nvm/versions/node/*/bin"
        "$HOME/.local/share/mise/shims"
        "/usr/local/bin"
    )

    # Add extra paths
    common_paths+=("${extra_paths[@]}")

    for path_pattern in "${common_paths[@]}"; do
        # Handle glob patterns
        for path in $path_pattern; do
            if [[ -x "$path/$cmd" ]]; then
                FOUND_CMD_PATH="$path/$cmd"
                return 0
            fi
        done
    done

    return 1
}

# Check if npm/bun is available, with helpful message
# Usage: require_js_runtime || return 1
require_js_runtime() {
    if find_cmd bun || find_cmd npm; then
        return 0
    fi

    echo "  ERROR: No JavaScript runtime found (bun or npm)"
    echo "  Install with: ./scripts/install-packages.sh --runtimes"
    echo "  Or manually: curl -fsSL https://bun.sh/install | bash"
    return 1
}

# Check if Node.js is available with minimum version
# Usage: require_node <min_version> || return 1
require_node() {
    local min_version="${1:-18}"

    if ! find_cmd node; then
        echo "  ERROR: Node.js not found"
        echo "  Install with: ./scripts/install-packages.sh --runtimes"
        echo "  Then run: nvm install --lts"
        return 1
    fi

    local node_version
    node_version=$("$FOUND_CMD_PATH" --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ "$node_version" -lt "$min_version" ]]; then
        echo "  ERROR: Node.js $min_version+ required (found: v$node_version)"
        echo "  Run: nvm install $min_version && nvm use $min_version"
        return 1
    fi

    return 0
}

# Add freshly installed tool paths to current session
refresh_path() {
    local new_paths=(
        "$HOME/.local/bin"
        "$HOME/.cargo/bin"
        "$HOME/.bun/bin"
        "$HOME/.local/share/mise/shims"
    )

    for p in "${new_paths[@]}"; do
        if [[ -d "$p" ]] && [[ ":$PATH:" != *":$p:"* ]]; then
            export PATH="$p:$PATH"
        fi
    done

    # Source nvm if available but not loaded
    if [[ -z "$NVM_DIR" ]] && [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        export NVM_DIR="$HOME/.nvm"
        source "$NVM_DIR/nvm.sh"
    fi
}

# ============================================================
# UNIFIED INSTALLATION CHECKS
# ============================================================

# Check if command already installed - returns 1 to signal "skip"
# Usage: require_not_installed <cmd> [name] || return 0
require_not_installed() {
    local cmd="$1"
    local name="${2:-$cmd}"

    if command -v "$cmd" &> /dev/null; then
        status_skip "$name" "already installed"
        return 1  # Signal: skip installation
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] $name"
        return 1  # Signal: skip in dry-run
    fi

    return 0  # Signal: proceed with install
}

# Check macOS app bundle - returns 1 to signal "skip"
# Usage: require_app_not_installed "Google Chrome" "Chrome" || return 0
require_app_not_installed() {
    local app="$1"
    local name="${2:-$app}"

    if is_macos && [[ -d "/Applications/${app}.app" ]]; then
        status_skip "$name" "already installed"
        return 1
    fi

    return 0  # Proceed (either not macOS or not installed)
}

# Unified pre-install check for apps (combines command + macOS app check)
# Usage: require_not_installed_app <cmd> <app_bundle_name> [display_name] || return 0
require_not_installed_app() {
    local cmd="$1"
    local app_bundle="$2"
    local name="${3:-$cmd}"

    # Check command first
    if command -v "$cmd" &> /dev/null; then
        status_skip "$name" "already installed"
        return 1
    fi

    # Check macOS app bundle
    if is_macos && [[ -d "/Applications/${app_bundle}.app" ]]; then
        status_skip "$name" "already installed"
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] $name"
        return 1
    fi

    return 0
}

# ============================================================
# APT REPOSITORY SETUP
# ============================================================

# Setup apt repository idempotently
# Usage: setup_apt_repo "name" "key_url" "key_path" "repo_line" "list_path"
setup_apt_repo() {
    local name="$1"
    local key_url="$2"
    local key_path="$3"
    local repo_line="$4"
    local list_path="$5"

    # Check for both .list and .sources formats (DEB822)
    local base_path="${list_path%.list}"
    local sources_path="${base_path}.sources"

    # Skip if already configured in either format
    if [[ -f "$list_path" ]] || [[ -f "$sources_path" ]]; then
        echo "  $name repository already configured"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] Would add $name apt repository"
        return 0
    fi

    echo "  Adding $name repository..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL "$key_url" | gpg --dearmor | sudo tee "$key_path" > /dev/null
    echo "$repo_line" | sudo tee "$list_path" > /dev/null
    sudo apt-get update
}

# ============================================================
# AUR HELPER
# ============================================================

# Install package from AUR
# Usage: aur_install <package>
aur_install() {
    local pkg="$1"

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] Would install $pkg from AUR"
        return 0
    fi

    if command -v paru &> /dev/null; then
        paru -S --noconfirm --needed "$pkg"
    elif command -v yay &> /dev/null; then
        yay -S --noconfirm --needed "$pkg"
    else
        echo "ERROR: AUR helper (paru/yay) required for $pkg"
        echo "Install paru first:"
        echo "  sudo pacman -S --needed base-devel git"
        echo "  git clone https://aur.archlinux.org/paru.git /tmp/paru"
        echo "  cd /tmp/paru && makepkg -si"
        return 1
    fi
}

# ============================================================
# SECTION FORMATTING
# ============================================================

# Print section header
print_section() {
    local title="$1"
    echo ""
    echo "=== $title ==="
    echo ""
}

# ============================================================
# SECURITY WARNINGS
# ============================================================

# Warn about curl|bash pattern (call before such installs)
# IMPORTANT: While curl|bash is convenient, it has security implications.
# We use it only for well-known, official install scripts from trusted sources.
# The alternative would be manual multi-step installation which is error-prone.
warn_remote_script() {
    local url="$1"
    local name="${2:-remote script}"
    if [[ "$VERBOSE" == true ]]; then
        echo "  NOTE: Installing $name via remote script ($url)"
        echo "        This is the official installation method for this tool."
    fi
}
