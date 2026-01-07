#!/bin/bash
# macOS system defaults configuration
# Only runs on macOS

configure_macos_defaults() {
    if ! is_macos; then
        echo "Skipping macOS defaults (not on macOS)"
        return
    fi

    echo ""
    echo "=== Configuring macOS Defaults ==="
    echo ""

    # Screenshots configuration
    configure_macos_screenshots

    # Finder configuration
    configure_macos_finder

    echo ""
    echo "macOS defaults configured!"
}

# ============================================================
# Screenshots
# ============================================================
configure_macos_screenshots() {
    echo "Configuring screenshots..."

    # Create Screenshots folder on Desktop
    local screenshots_dir="$HOME/Desktop/Screenshots"
    if [[ ! -d "$screenshots_dir" ]]; then
        mkdir -p "$screenshots_dir"
        echo "  Created $screenshots_dir"
    fi

    # Set screenshot location
    defaults write com.apple.screencapture location -string "$screenshots_dir"
    echo "  Set screenshot location to ~/Desktop/Screenshots"

    # Use PNG format (high quality)
    defaults write com.apple.screencapture type -string "png"
    echo "  Set screenshot format to PNG"

    # Disable floating thumbnail preview (optional - faster workflow)
    # defaults write com.apple.screencapture show-thumbnail -bool false

    # Apply changes
    killall SystemUIServer 2>/dev/null || true
}

# ============================================================
# Finder
# ============================================================
configure_macos_finder() {
    echo "Configuring Finder..."

    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true
    echo "  Show hidden files: enabled"

    # Show all file extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    echo "  Show all file extensions: enabled"

    # Show path bar at bottom
    defaults write com.apple.finder ShowPathbar -bool true
    echo "  Show path bar: enabled"

    # Show status bar at bottom
    defaults write com.apple.finder ShowStatusBar -bool true
    echo "  Show status bar: enabled"

    # Default to list view
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    echo "  Default view: list"

    # Keep folders on top when sorting
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    echo "  Sort folders first: enabled"

    # Disable warning when changing file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    echo "  Extension change warning: disabled"

    # Search current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    echo "  Default search scope: current folder"

    # Apply changes
    killall Finder 2>/dev/null || true
}

# ============================================================
# Dock (optional extras)
# ============================================================
configure_macos_dock() {
    echo "Configuring Dock..."

    # Auto-hide dock
    defaults write com.apple.dock autohide -bool true
    echo "  Auto-hide: enabled"

    # Remove auto-hide delay
    defaults write com.apple.dock autohide-delay -float 0
    echo "  Auto-hide delay: 0"

    # Speed up auto-hide animation
    defaults write com.apple.dock autohide-time-modifier -float 0.3
    echo "  Auto-hide animation: 0.3s"

    # Don't show recent apps
    defaults write com.apple.dock show-recents -bool false
    echo "  Show recent apps: disabled"

    # Apply changes
    killall Dock 2>/dev/null || true
}

# ============================================================
# Keyboard & Input
# ============================================================
configure_macos_keyboard() {
    echo "Configuring keyboard..."

    # Fast key repeat
    defaults write NSGlobalDomain KeyRepeat -int 2
    echo "  Key repeat rate: fast (2)"

    # Short delay until repeat
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    echo "  Initial key repeat delay: short (15)"

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    echo "  Auto-correct: disabled"

    # Disable smart quotes
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    echo "  Smart quotes: disabled"

    # Disable smart dashes
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    echo "  Smart dashes: disabled"
}

# ============================================================
# Full configuration (all defaults)
# ============================================================
configure_macos_all() {
    if ! is_macos; then
        echo "Skipping macOS defaults (not on macOS)"
        return
    fi

    echo ""
    echo "=== Configuring All macOS Defaults ==="
    echo ""

    configure_macos_screenshots
    configure_macos_finder
    configure_macos_dock
    configure_macos_keyboard

    echo ""
    echo "All macOS defaults configured!"
    echo "Note: Some changes may require logout/login to take effect."
}
