#!/bin/bash
# Chezmoi bootstrap script
# Installs chezmoi and initializes dotfiles management
#
# Usage:
#   # From this repo (already cloned):
#   ./scripts/chezmoi-bootstrap.sh
#
#   # One-liner from anywhere (downloads and runs):
#   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply zbowling

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source helpers if available
if [[ -f "$SCRIPT_DIR/lib/sudo-helper.sh" ]]; then
    source "$SCRIPT_DIR/lib/sudo-helper.sh"
    check_not_root
fi

if [[ -f "$SCRIPT_DIR/lib/detect-os.sh" ]]; then
    source "$SCRIPT_DIR/lib/detect-os.sh"
fi

# ============================================================
# Install chezmoi
# ============================================================
install_chezmoi() {
    if command -v chezmoi &> /dev/null; then
        echo "chezmoi already installed: $(chezmoi --version)"
        return 0
    fi

    echo ""
    echo "=== Installing chezmoi ==="
    echo ""

    local bin_dir="${HOME}/.local/bin"
    mkdir -p "$bin_dir"

    if is_macos 2>/dev/null; then
        # Use Homebrew on macOS
        brew install chezmoi
    else
        # Use official install script
        if command -v curl &> /dev/null; then
            sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$bin_dir"
        elif command -v wget &> /dev/null; then
            sh -c "$(wget -qO- get.chezmoi.io)" -- -b "$bin_dir"
        else
            echo "Error: curl or wget required to install chezmoi"
            exit 1
        fi

        # Add to PATH if not already
        if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
            export PATH="$bin_dir:$PATH"
        fi
    fi

    echo "chezmoi installed: $(chezmoi --version)"
}

# ============================================================
# Initialize chezmoi with this dotfiles repo
# ============================================================
init_chezmoi() {
    echo ""
    echo "=== Initializing chezmoi ==="
    echo ""

    local chezmoi_source="${HOME}/.local/share/chezmoi"

    # Check if already initialized
    if [[ -d "$chezmoi_source" ]]; then
        echo "chezmoi source directory already exists: $chezmoi_source"
        echo ""
        echo "Options:"
        echo "  1. Update existing: chezmoi update"
        echo "  2. Re-initialize:   rm -rf $chezmoi_source && chezmoi init"
        echo "  3. View status:     chezmoi status"
        echo ""
        return 0
    fi

    # Check if we have chezmoi-compatible files
    if [[ -d "$DOTFILES_DIR/home" ]]; then
        # We have a chezmoi structure, init from local
        echo "Initializing from local dotfiles directory..."
        chezmoi init --source="$DOTFILES_DIR/home"
    else
        # First time - offer to create chezmoi structure
        echo "This dotfiles repo doesn't have a chezmoi structure yet."
        echo ""
        echo "Would you like to:"
        echo "  1. Migrate existing dotfiles to chezmoi format"
        echo "  2. Use the traditional install.sh approach (symlinks)"
        echo ""
        echo -n "Choose [1/2]: "
        read -r choice

        case "$choice" in
            1)
                migrate_to_chezmoi
                ;;
            2)
                echo ""
                echo "Run: ./install.sh"
                echo "Then: ./scripts/install-packages.sh --all"
                exit 0
                ;;
            *)
                echo "Invalid choice"
                exit 1
                ;;
        esac
    fi
}

# ============================================================
# Migrate existing dotfiles to chezmoi format
# ============================================================
migrate_to_chezmoi() {
    echo ""
    echo "=== Migrating to chezmoi ==="
    echo ""

    # Initialize empty chezmoi
    chezmoi init

    echo "Adding dotfiles to chezmoi..."
    echo ""

    # Add shell configs
    if [[ -f "$DOTFILES_DIR/zsh/.zshrc" ]]; then
        # Create symlink first, then add to chezmoi
        ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc 2>/dev/null || true
        chezmoi add ~/.zshrc --follow || true
        echo "  Added .zshrc"
    fi

    if [[ -f "$DOTFILES_DIR/zsh/.zsh_plugins.txt" ]]; then
        ln -sf "$DOTFILES_DIR/zsh/.zsh_plugins.txt" ~/.zsh_plugins.txt 2>/dev/null || true
        chezmoi add ~/.zsh_plugins.txt --follow || true
        echo "  Added .zsh_plugins.txt"
    fi

    # Add fish config
    if [[ -f "$DOTFILES_DIR/fish/config.fish" ]]; then
        mkdir -p ~/.config/fish
        ln -sf "$DOTFILES_DIR/fish/config.fish" ~/.config/fish/config.fish 2>/dev/null || true
        chezmoi add ~/.config/fish/config.fish --follow || true
        echo "  Added fish/config.fish"
    fi

    # Add starship config
    if [[ -f "$DOTFILES_DIR/starship/starship.toml" ]]; then
        ln -sf "$DOTFILES_DIR/starship/starship.toml" ~/.config/starship.toml 2>/dev/null || true
        chezmoi add ~/.config/starship.toml --follow || true
        echo "  Added starship.toml"
    fi

    # Add terminal configs
    if [[ -f "$DOTFILES_DIR/ghostty/config" ]]; then
        mkdir -p ~/.config/ghostty
        ln -sf "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config 2>/dev/null || true
        chezmoi add ~/.config/ghostty/config --follow || true
        echo "  Added ghostty/config"
    fi

    if [[ -d "$DOTFILES_DIR/alacritty" ]]; then
        ln -sf "$DOTFILES_DIR/alacritty" ~/.config/alacritty 2>/dev/null || true
        chezmoi add ~/.config/alacritty --follow || true
        echo "  Added alacritty/"
    fi

    if [[ -d "$DOTFILES_DIR/zellij" ]]; then
        ln -sf "$DOTFILES_DIR/zellij" ~/.config/zellij 2>/dev/null || true
        chezmoi add ~/.config/zellij --follow || true
        echo "  Added zellij/"
    fi

    echo ""
    echo "Migration complete!"
    echo ""
    echo "Your chezmoi source is at: $(chezmoi source-path)"
    echo ""
    echo "Next steps:"
    echo "  chezmoi diff          # See what chezmoi will change"
    echo "  chezmoi apply         # Apply the dotfiles"
    echo "  chezmoi cd            # Go to chezmoi source directory"
    echo "  git add . && git commit -m 'Add chezmoi'  # Commit changes"
    echo ""
}

# ============================================================
# Show help
# ============================================================
show_help() {
    echo "Chezmoi Bootstrap Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --install   Install chezmoi only"
    echo "  --init      Initialize chezmoi with this repo"
    echo "  --migrate   Migrate existing dotfiles to chezmoi"
    echo "  --apply     Install chezmoi, init, and apply"
    echo "  --help      Show this help"
    echo ""
    echo "Without options, runs interactive setup."
    echo ""
    echo "Chezmoi Workflow:"
    echo ""
    echo "  First time setup:"
    echo "    $0 --apply"
    echo ""
    echo "  On a new machine (one-liner):"
    echo "    sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --apply zbowling"
    echo ""
    echo "  Daily usage:"
    echo "    chezmoi edit ~/.zshrc   # Edit a dotfile"
    echo "    chezmoi diff            # See pending changes"
    echo "    chezmoi apply           # Apply changes"
    echo "    chezmoi update          # Pull and apply from git"
    echo ""
}

# ============================================================
# Main
# ============================================================
main() {
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --install)
            install_chezmoi
            ;;
        --init)
            install_chezmoi
            init_chezmoi
            ;;
        --migrate)
            install_chezmoi
            migrate_to_chezmoi
            ;;
        --apply)
            install_chezmoi
            init_chezmoi
            echo ""
            echo "Applying dotfiles..."
            chezmoi apply
            echo ""
            echo "Done! Dotfiles applied via chezmoi."
            ;;
        "")
            # Interactive mode
            echo "========================================"
            echo "Chezmoi Bootstrap"
            echo "========================================"
            echo ""
            install_chezmoi
            echo ""
            init_chezmoi
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
