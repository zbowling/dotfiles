#!/bin/bash
# Sudo handling utilities
# Provides safe sudo credential caching and privilege escalation

# Global state
SUDO_KEEP_ALIVE_PID=""
SUDO_AVAILABLE=""

# ============================================================
# Check if running as root (should NOT be)
# ============================================================
check_not_root() {
    if [[ "$EUID" -eq 0 ]] || [[ "$(id -u)" -eq 0 ]]; then
        echo ""
        echo "ERROR: Do not run this script as root!"
        echo ""
        echo "This script should be run as a regular user."
        echo "It will use 'sudo' for individual commands that need elevated privileges."
        echo ""
        echo "Usage: ./install-packages.sh [OPTIONS]"
        echo "   or: ./setup-wizard.sh"
        echo ""
        exit 1
    fi
}

# ============================================================
# Check if sudo is available and user has access
# ============================================================
check_sudo_available() {
    # Already checked
    if [[ -n "$SUDO_AVAILABLE" ]]; then
        return "$SUDO_AVAILABLE"
    fi

    # Check if sudo command exists
    if ! command -v sudo &> /dev/null; then
        SUDO_AVAILABLE=1
        return 1
    fi

    # Check if user can use sudo (with timeout to avoid hanging)
    # Use -n to avoid prompting, just check access
    if sudo -n true 2>/dev/null; then
        SUDO_AVAILABLE=0
        return 0
    fi

    # User may have sudo access but needs password
    # We'll find out when we actually try to use it
    SUDO_AVAILABLE=0
    return 0
}

# ============================================================
# Request sudo credentials upfront
# Call this at the start of scripts that need sudo
# ============================================================
require_sudo() {
    local prompt="${1:-This script requires sudo access for some operations.}"

    # Don't require sudo on macOS for brew-only operations
    # (Homebrew doesn't need sudo)
    if is_macos 2>/dev/null; then
        # Still validate sudo is available for potential system operations
        if ! check_sudo_available; then
            echo "Warning: sudo not available. Some operations may fail."
            return 0
        fi
        return 0
    fi

    # Check if sudo is available
    if ! check_sudo_available; then
        echo ""
        echo "ERROR: sudo is not available or user is not in sudoers."
        echo ""
        echo "Please ensure:"
        echo "  1. The 'sudo' command is installed"
        echo "  2. Your user is in the sudo/wheel group"
        echo ""
        echo "To add yourself to sudo group (as root):"
        echo "  usermod -aG sudo $USER  # Debian/Ubuntu"
        echo "  usermod -aG wheel $USER # Arch/Fedora"
        echo ""
        exit 1
    fi

    # Check if we already have cached credentials
    if sudo -n true 2>/dev/null; then
        # Already have cached credentials, start keep-alive
        start_sudo_keep_alive
        return 0
    fi

    # Need to prompt for password
    echo ""
    echo "$prompt"
    echo ""

    # Prompt for sudo password
    if ! sudo -v; then
        echo ""
        echo "ERROR: Failed to obtain sudo credentials."
        exit 1
    fi

    # Start keep-alive in background
    start_sudo_keep_alive
}

# ============================================================
# Keep sudo credentials alive during long-running scripts
# ============================================================
start_sudo_keep_alive() {
    # Don't start multiple keep-alive processes
    if [[ -n "$SUDO_KEEP_ALIVE_PID" ]]; then
        return 0
    fi

    # Start background process to refresh sudo timestamp
    (
        while true; do
            # Refresh sudo timestamp silently
            sudo -n true 2>/dev/null || true
            sleep 50  # Refresh before the typical 5-minute timeout
            # Exit if parent script has finished
            kill -0 "$$" 2>/dev/null || exit 0
        done
    ) &
    SUDO_KEEP_ALIVE_PID=$!

    # Clean up on script exit
    trap 'stop_sudo_keep_alive' EXIT
}

# ============================================================
# Stop sudo keep-alive process
# ============================================================
stop_sudo_keep_alive() {
    if [[ -n "$SUDO_KEEP_ALIVE_PID" ]]; then
        kill "$SUDO_KEEP_ALIVE_PID" 2>/dev/null || true
        SUDO_KEEP_ALIVE_PID=""
    fi
}

# ============================================================
# Run a command with sudo, but only if needed
# Usage: maybe_sudo command args...
# ============================================================
maybe_sudo() {
    if [[ "$EUID" -eq 0 ]]; then
        # Already root (shouldn't happen with check_not_root)
        "$@"
    else
        sudo "$@"
    fi
}

# ============================================================
# Check if a path requires sudo to write
# ============================================================
needs_sudo_for_path() {
    local path="$1"
    local dir

    # Get parent directory if path doesn't exist
    if [[ -e "$path" ]]; then
        dir="$path"
    else
        dir="$(dirname "$path")"
    fi

    # Check if we can write to it
    if [[ -w "$dir" ]]; then
        return 1  # No sudo needed
    else
        return 0  # Sudo needed
    fi
}

# ============================================================
# Wrapper for install commands that handles sudo smartly
# Usage: smart_install /path/to/file /destination
# ============================================================
smart_install() {
    local source="$1"
    local dest="$2"

    if needs_sudo_for_path "$dest"; then
        sudo install "$source" "$dest"
    else
        install "$source" "$dest"
    fi
}
