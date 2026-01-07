#!/bin/bash
# Interactive setup wizard using gum TUI
# Usage: ./setup-wizard.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source library scripts
source "$SCRIPT_DIR/lib/detect-os.sh"
source "$SCRIPT_DIR/lib/packages-cli.sh"
source "$SCRIPT_DIR/lib/packages-dev.sh"
source "$SCRIPT_DIR/lib/install-runtimes.sh"
source "$SCRIPT_DIR/lib/packages-apps.sh"
source "$SCRIPT_DIR/lib/packages-editors.sh"
source "$SCRIPT_DIR/lib/git-config.sh"
source "$SCRIPT_DIR/lib/ssh-setup.sh"
source "$SCRIPT_DIR/lib/macos-defaults.sh"

# ============================================================
# Check for gum
# ============================================================
check_gum() {
    if ! command -v gum &> /dev/null; then
        echo "This wizard requires 'gum' for interactive prompts."
        echo ""
        echo "Installing gum first..."
        echo ""

        if is_macos; then
            brew install gum
        elif is_debian; then
            install_gum_debian
        elif is_arch; then
            pkg_install gum
        fi

        if ! command -v gum &> /dev/null; then
            echo "Failed to install gum. Please install it manually:"
            echo "  https://github.com/charmbracelet/gum"
            exit 1
        fi
    fi
}

# ============================================================
# Welcome screen
# ============================================================
show_welcome() {
    clear
    gum style \
        --border normal \
        --margin "1" \
        --padding "1 2" \
        --border-foreground 212 \
        "$(gum style --foreground 212 --bold 'Dotfiles Setup Wizard')" \
        "" \
        "This wizard will help you set up your development environment." \
        "" \
        "It will:" \
        "  - Configure git identity and defaults" \
        "  - Generate SSH keys (optional)" \
        "  - Install packages you select" \
        "  - Configure shell integrations" \
        ""

    echo ""
    if ! gum confirm "Ready to begin?"; then
        echo "Setup cancelled."
        exit 0
    fi
}

# ============================================================
# Git setup
# ============================================================
setup_git_wizard() {
    echo ""
    gum style --foreground 212 --bold "Git Configuration"
    echo ""

    local current_name current_email
    current_name=$(git config --global --get user.name 2>/dev/null || echo "")
    current_email=$(git config --global --get user.email 2>/dev/null || echo "")

    if [[ -n "$current_name" ]] && [[ -n "$current_email" ]]; then
        echo "Current git identity:"
        echo "  Name:  $current_name"
        echo "  Email: $current_email"
        echo ""
        if ! gum confirm "Keep this identity?"; then
            current_name=""
            current_email=""
        fi
    fi

    if [[ -z "$current_name" ]]; then
        current_name=$(gum input --placeholder "Your Name" --prompt "Name: ")
        if [[ -n "$current_name" ]]; then
            git config --global user.name "$current_name"
            echo "Set user.name = $current_name"
        fi
    fi

    if [[ -z "$current_email" ]]; then
        current_email=$(gum input --placeholder "your@email.com" --prompt "Email: ")
        if [[ -n "$current_email" ]]; then
            git config --global user.email "$current_email"
            echo "Set user.email = $current_email"
        fi
    fi

    echo ""
    if gum confirm "Configure recommended git defaults?"; then
        configure_git_defaults
    fi
}

# ============================================================
# SSH setup
# ============================================================
setup_ssh_wizard() {
    echo ""
    gum style --foreground 212 --bold "SSH Key Setup"
    echo ""

    # Check for existing keys
    local has_key=false
    if [[ -f ~/.ssh/id_ed25519 ]] || [[ -f ~/.ssh/id_rsa ]]; then
        has_key=true
        echo "Found existing SSH key(s):"
        ls -la ~/.ssh/id_*.pub 2>/dev/null | sed 's/^/  /'
        echo ""
    fi

    if [[ "$has_key" == false ]]; then
        if gum confirm "Generate a new SSH key?"; then
            local email
            email=$(git config --global --get user.email 2>/dev/null || echo "")
            if [[ -z "$email" ]]; then
                email=$(gum input --placeholder "your@email.com" --prompt "Email for key: ")
            fi

            if [[ -n "$email" ]]; then
                echo ""
                echo "Generating Ed25519 SSH key..."
                ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519
                echo ""
                echo "Public key:"
                cat ~/.ssh/id_ed25519.pub
            fi
        fi
    fi

    # Offer to add to GitHub
    if [[ -f ~/.ssh/id_ed25519.pub ]] || [[ -f ~/.ssh/id_rsa.pub ]]; then
        echo ""
        if command -v gh &> /dev/null; then
            if gum confirm "Add SSH key to GitHub?"; then
                add_ssh_key_to_github
            fi
        else
            echo "Install GitHub CLI (--cli) to add key to GitHub automatically."
        fi
    fi
}

# ============================================================
# Package selection
# ============================================================
select_packages() {
    echo ""
    gum style --foreground 212 --bold "Package Selection"
    echo ""

    local choices
    choices=$(gum choose --no-limit --cursor-prefix "[ ] " --selected-prefix "[x] " \
        "CLI Tools (eza, fzf, bat, ripgrep, lazygit, etc.)" \
        "Dev Tools (cmake, gcc, clang, bun, etc.)" \
        "Runtimes (mise, uv, nvm, rustup)" \
        "Desktop Apps (Chrome, Ghostty, Discord, etc.)" \
        "Dev Editors (VSCode, Cursor, Zed, Claude Code, etc.)" \
        "1Password (SSH agent, git signing)" \
        "Docker" \
        "Tailscale VPN" \
        "Nerd Fonts")

    echo ""
    echo "Installing selected packages..."
    echo ""

    # Build install command
    local install_args=()

    if echo "$choices" | grep -q "CLI Tools"; then
        install_args+=(--cli)
    fi
    if echo "$choices" | grep -q "Dev Tools"; then
        install_args+=(--dev)
    fi
    if echo "$choices" | grep -q "Runtimes"; then
        install_args+=(--runtimes)
    fi
    if echo "$choices" | grep -q "Desktop Apps"; then
        install_args+=(--apps)
    fi
    if echo "$choices" | grep -q "Dev Editors"; then
        install_args+=(--dev-editor)
    fi
    if echo "$choices" | grep -q "1Password"; then
        install_args+=(--1password)
    fi
    if echo "$choices" | grep -q "Docker"; then
        install_args+=(--docker)
    fi
    if echo "$choices" | grep -q "Tailscale"; then
        install_args+=(--tailscale)
    fi
    if echo "$choices" | grep -q "Nerd Fonts"; then
        install_args+=(--fonts)
    fi

    if [[ ${#install_args[@]} -gt 0 ]]; then
        "$SCRIPT_DIR/install-packages.sh" "${install_args[@]}"
    else
        echo "No packages selected."
    fi
}

# ============================================================
# GitHub auth
# ============================================================
setup_github_auth() {
    echo ""
    gum style --foreground 212 --bold "GitHub Authentication"
    echo ""

    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI not installed. Skipping..."
        return
    fi

    if gh auth status &>/dev/null; then
        echo "Already authenticated with GitHub:"
        gh auth status 2>&1 | head -5 | sed 's/^/  /'
    else
        if gum confirm "Authenticate with GitHub CLI?"; then
            gh auth login
        fi
    fi
}

# ============================================================
# macOS defaults
# ============================================================
setup_macos_defaults() {
    if ! is_macos; then
        return
    fi

    echo ""
    gum style --foreground 212 --bold "macOS Configuration"
    echo ""

    echo "This will configure:"
    echo "  - Screenshots saved to ~/Desktop/Screenshots"
    echo "  - Finder: show hidden files, extensions, path bar"
    echo ""

    if gum confirm "Apply macOS defaults?"; then
        configure_macos_defaults
    fi
}

# ============================================================
# Post-install summary
# ============================================================
show_summary() {
    echo ""
    gum style \
        --border normal \
        --margin "1" \
        --padding "1 2" \
        --border-foreground 212 \
        "$(gum style --foreground 212 --bold 'Setup Complete!')" \
        "" \
        "Next steps:" \
        "  1. Restart terminal or: source ~/.zshrc" \
        "  2. Set zsh as default: chsh -s \$(which zsh)" \
        ""

    # 1Password reminder
    if command -v op &> /dev/null; then
        echo ""
        gum style --foreground 214 "1Password setup:"
        echo "  1. Open 1Password and sign in"
        echo "  2. Settings > Developer > Integrate with 1Password CLI"
        echo "  3. Settings > Developer > Set Up SSH Agent"
    fi

    # Tailscale reminder
    if command -v tailscale &> /dev/null; then
        echo ""
        gum style --foreground 214 "Tailscale setup:"
        echo "  Run: sudo tailscale up"
    fi

    # Atuin reminder
    if command -v atuin &> /dev/null; then
        echo ""
        gum style --foreground 214 "Atuin (shell history sync):"
        echo "  Run: atuin login (optional, for sync)"
    fi

    echo ""
    echo "Full checklist: ./scripts/post-install-checklist.sh"
    echo ""
}

# ============================================================
# Main wizard flow
# ============================================================
main() {
    check_gum
    show_welcome
    setup_git_wizard
    setup_ssh_wizard
    select_packages
    setup_github_auth
    setup_macos_defaults
    show_summary
}

main "$@"
