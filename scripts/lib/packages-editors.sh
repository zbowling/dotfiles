#!/bin/bash
# Dev editor/IDE installers
# Cross-platform: macOS, Ubuntu/Debian, Arch/CachyOS

# ============================================================
# Visual Studio Code
# ============================================================
install_vscode() {
    print_section "Installing Visual Studio Code"

    require_not_installed code "VS Code" || return 0

    if is_macos; then
        brew install --cask visual-studio-code
    elif is_debian; then
        setup_apt_repo "Microsoft VS Code" \
            "https://packages.microsoft.com/keys/microsoft.asc" \
            "/etc/apt/keyrings/packages.microsoft.gpg" \
            "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
            "/etc/apt/sources.list.d/vscode.list"
        sudo apt install -y code
    elif is_arch; then
        aur_install visual-studio-code-bin
    fi

    status_success "VS Code"
}

# ============================================================
# Cursor (AI-powered code editor)
# ============================================================
install_cursor() {
    print_section "Installing Cursor"

    require_app_not_installed "Cursor" "Cursor" || return 0
    require_not_installed cursor "Cursor" || return 0

    if is_macos; then
        brew install --cask cursor
    elif is_debian; then
        setup_apt_repo "Cursor" \
            "https://downloads.cursor.com/keys/anysphere.asc" \
            "/etc/apt/keyrings/cursor.gpg" \
            "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/cursor.gpg] https://downloads.cursor.com/aptrepo stable main" \
            "/etc/apt/sources.list.d/cursor.list"
        sudo apt install -y cursor
    elif is_fedora; then
        if [[ ! -f /etc/yum.repos.d/cursor.repo ]]; then
            sudo tee /etc/yum.repos.d/cursor.repo << 'EOF'
[cursor]
name=Cursor
baseurl=https://downloads.cursor.com/yumrepo
enabled=1
gpgcheck=1
gpgkey=https://downloads.cursor.com/keys/anysphere.asc
EOF
        fi
        sudo dnf install -y cursor
    elif is_arch; then
        aur_install cursor-bin
    fi

    status_success "Cursor"
}

# ============================================================
# Zed Editor
# ============================================================
install_zed() {
    print_section "Installing Zed"

    require_not_installed zed "Zed" || return 0

    if is_macos; then
        brew install --cask zed
    elif is_debian; then
        # SECURITY NOTE: This uses curl|sh which is the official Zed install method.
        # The script is from the official Zed website: https://zed.dev
        curl -fsSL https://zed.dev/install.sh | sh
    elif is_arch; then
        sudo pacman -S --noconfirm --needed zed
    fi

    status_success "Zed"
}

# ============================================================
# Google Antigravity IDE
# ============================================================
install_antigravity() {
    print_section "Installing Google Antigravity"

    require_not_installed antigravity "Antigravity" || return 0

    if is_macos; then
        brew install --cask antigravity
    elif is_debian; then
        setup_apt_repo "Antigravity" \
            "https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg" \
            "/etc/apt/keyrings/antigravity-repo-key.gpg" \
            "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" \
            "/etc/apt/sources.list.d/antigravity.list"
        sudo apt install -y antigravity
    elif is_arch; then
        aur_install antigravity-bin
    fi

    status_success "Antigravity"
}

# ============================================================
# Gemini CLI
# ============================================================
install_gemini_cli() {
    print_section "Installing Gemini CLI"

    require_not_installed gemini "Gemini CLI" || return 0

    if is_macos; then
        brew install gemini-cli
    else
        # Requires Node.js 20+ or bun
        if find_cmd bun; then
            "$FOUND_CMD_PATH" install --global @google/gemini-cli
        elif require_node 20; then
            find_cmd npm && "$FOUND_CMD_PATH" install -g @google/gemini-cli
        else
            return 1
        fi
    fi

    status_success "Gemini CLI"
}

# ============================================================
# OpenAI Codex CLI
# ============================================================
install_codex() {
    print_section "Installing OpenAI Codex"

    require_not_installed codex "Codex" || return 0

    if is_macos; then
        brew install --cask codex
    else
        # Install via bun (preferred) or npm
        if find_cmd bun; then
            "$FOUND_CMD_PATH" install --global @openai/codex
        elif find_cmd npm; then
            "$FOUND_CMD_PATH" install -g @openai/codex
        else
            require_js_runtime  # Will print helpful error
            return 1
        fi
    fi

    status_success "Codex"
}

# ============================================================
# Claude Code CLI
# ============================================================
install_claude_code() {
    print_section "Installing Claude Code"

    require_not_installed claude "Claude Code" || return 0

    if is_macos; then
        brew install --cask claude-code
    else
        # SECURITY NOTE: This uses curl|bash which is the official Claude Code install method.
        # The script is from the official Claude website: https://claude.ai
        curl -fsSL https://claude.ai/install.sh | bash
    fi

    status_success "Claude Code"
}

# ============================================================
# Neovim + LazyVim
# ============================================================
install_neovim_lazyvim() {
    print_section "Installing Neovim + LazyVim"

    # Check if LazyVim is already installed
    if [[ -f ~/.config/nvim/.lazyvim ]]; then
        status_skip "LazyVim" "already installed"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Neovim + LazyVim"
        return
    fi

    # Install Neovim if not present
    if ! command -v nvim &> /dev/null; then
        echo "Installing Neovim..."
        if is_macos; then
            brew install neovim
        elif is_debian; then
            # Get latest Neovim from GitHub releases for newer version
            local nvim_version
            nvim_version=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | sed -n 's/.*"tag_name": "\([^"]*\)".*/\1/p' | head -1)
            (
                cd /tmp || exit 1
                curl -fsSL "https://github.com/neovim/neovim/releases/download/${nvim_version}/nvim-linux-x86_64.tar.gz" -o nvim.tar.gz
                sudo tar -xzf nvim.tar.gz -C /opt
                sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
                rm nvim.tar.gz
            )
        elif is_arch; then
            sudo pacman -S --noconfirm --needed neovim
        fi
    fi

    # Install LazyVim dependencies
    if is_macos; then
        brew install lazygit fd ripgrep
    elif is_debian; then
        sudo apt install -y fd-find ripgrep
    elif is_arch; then
        sudo pacman -S --noconfirm --needed lazygit fd ripgrep
    fi

    # Backup existing Neovim config if not LazyVim
    if [[ -d ~/.config/nvim && ! -f ~/.config/nvim/.lazyvim ]]; then
        echo "Backing up existing Neovim config to ~/.config/nvim.bak"
        mv ~/.config/nvim ~/.config/nvim.bak
    fi

    # Install LazyVim starter config
    if [[ ! -d ~/.config/nvim ]]; then
        git clone https://github.com/LazyVim/starter ~/.config/nvim
        rm -rf ~/.config/nvim/.git
        touch ~/.config/nvim/.lazyvim
    fi

    status_success "Neovim + LazyVim"
}

# ============================================================
# Install all dev editors
# ============================================================
install_all_editors() {
    try_install install_vscode "VS Code"
    try_install install_cursor "Cursor"
    try_install install_zed "Zed"
    try_install install_antigravity "Antigravity"
    try_install install_gemini_cli "Gemini CLI"
    try_install install_codex "Codex"
    try_install install_claude_code "Claude Code"
    try_install install_neovim_lazyvim "LazyVim"

    echo ""
    echo "=== Dev editors section complete ==="
    echo ""
}
