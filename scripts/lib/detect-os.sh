#!/bin/bash
# OS and package manager detection
# Sets: OS, PKG_MANAGER, PKG_INSTALL, PKG_UPDATE

# Source sudo helper if available (for maybe_sudo)
SCRIPT_DIR_DETECT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR_DETECT/sudo-helper.sh" ]]; then
    source "$SCRIPT_DIR_DETECT/sudo-helper.sh"
fi

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MANAGER="brew"
        PKG_INSTALL="brew install"
        PKG_UPDATE="brew update"
    elif [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                OS="$ID"
                PKG_MANAGER="apt"
                PKG_INSTALL="sudo apt install -y"
                PKG_UPDATE="sudo apt update"
                ;;
            arch|cachyos|endeavouros|manjaro)
                OS="$ID"
                # Prefer AUR helpers
                if command -v paru &> /dev/null; then
                    PKG_MANAGER="paru"
                    PKG_INSTALL="paru -S --noconfirm --needed"
                    PKG_UPDATE="paru -Sy"
                elif command -v yay &> /dev/null; then
                    PKG_MANAGER="yay"
                    PKG_INSTALL="yay -S --noconfirm --needed"
                    PKG_UPDATE="yay -Sy"
                else
                    PKG_MANAGER="pacman"
                    PKG_INSTALL="sudo pacman -S --noconfirm --needed"
                    PKG_UPDATE="sudo pacman -Sy"
                fi
                ;;
            fedora|rhel|centos)
                OS="$ID"
                PKG_MANAGER="dnf"
                PKG_INSTALL="sudo dnf install -y"
                PKG_UPDATE="sudo dnf check-update || true"
                ;;
            *)
                echo "Unsupported OS: $ID"
                exit 1
                ;;
        esac
    else
        echo "Cannot detect OS"
        exit 1
    fi

    export OS PKG_MANAGER PKG_INSTALL PKG_UPDATE
    echo "Detected OS: $OS (package manager: $PKG_MANAGER)"
}

# Helper to check if running on macOS
is_macos() {
    [[ "$OS" == "macos" ]]
}

# Helper to check if running on Arch-based
is_arch() {
    [[ "$PKG_MANAGER" == "pacman" || "$PKG_MANAGER" == "paru" || "$PKG_MANAGER" == "yay" ]]
}

# Helper to check if running on Debian-based
is_debian() {
    [[ "$PKG_MANAGER" == "apt" ]]
}

# Helper to check if running on Fedora/RHEL
is_fedora() {
    [[ "$PKG_MANAGER" == "dnf" ]]
}

# Helper to install a package with the detected package manager
pkg_install() {
    echo "Installing: $*"
    $PKG_INSTALL "$@"
}

# Run detection
detect_os
