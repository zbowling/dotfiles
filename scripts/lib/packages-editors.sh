#!/bin/bash
# Dev editor/IDE installers
# Cross-platform: macOS, Ubuntu/Debian, Arch/CachyOS

# ============================================================
# Visual Studio Code
# ============================================================
install_vscode() {
    echo ""
    echo "=== Installing Visual Studio Code ==="
    echo ""

    if command -v code &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] VS Code (already installed)"
            return
        fi
        echo "VS Code already installed: $(code --version | head -1)"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] VS Code"
        return
    fi

    if is_macos; then
        brew install --cask visual-studio-code
    elif is_debian; then
        # Add Microsoft apt repository
        if [[ ! -f /etc/apt/keyrings/packages.microsoft.gpg ]]; then
            echo "Adding Microsoft apt repository..."
            (
                cd /tmp || exit 1
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
                echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
                    sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
                rm -f packages.microsoft.gpg
            )
            sudo apt update
        fi
        sudo apt install -y code
    elif is_arch; then
        # VS Code is in AUR as visual-studio-code-bin
        if [[ "$PKG_MANAGER" == "paru" ]]; then
            paru -S --noconfirm --needed visual-studio-code-bin
        elif [[ "$PKG_MANAGER" == "yay" ]]; then
            yay -S --noconfirm --needed visual-studio-code-bin
        else
            echo "VS Code requires an AUR helper (paru or yay)"
        fi
    fi
}

# ============================================================
# Cursor (AI-powered code editor)
# ============================================================
install_cursor() {
    echo ""
    echo "=== Installing Cursor ==="
    echo ""

    if is_macos; then
        if [[ -d "/Applications/Cursor.app" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                echo "[SKIP] Cursor (already installed)"
                return
            fi
            echo "Cursor already installed"
            return
        fi

        if [[ "$DRY_RUN" == true ]]; then
            echo "[WOULD INSTALL] Cursor"
            return
        fi

        brew install --cask cursor
    elif is_debian || is_arch; then
        if [[ -f /opt/cursor.appimage ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                echo "[SKIP] Cursor (already installed)"
                return
            fi
            echo "Cursor already installed"
            return
        fi

        if [[ "$DRY_RUN" == true ]]; then
            echo "[WOULD INSTALL] Cursor"
            return
        fi

        echo "Downloading Cursor AppImage..."
        (
            cd /tmp || exit 1
            curl -L "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable" | \
                jq -r '.downloadUrl' | xargs curl -L -o cursor.appimage
            sudo mv cursor.appimage /opt/cursor.appimage
            sudo chmod +x /opt/cursor.appimage
        )

        # Install fuse for AppImage support
        if is_debian; then
            sudo apt install -y fuse3 libfuse2t64 2>/dev/null || sudo apt install -y fuse libfuse2 2>/dev/null || true
        elif is_arch; then
            sudo pacman -S --noconfirm --needed fuse2
        fi

        # Create desktop entry
        sudo tee /usr/share/applications/cursor.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Cursor
Comment=AI-powered code editor
Exec=/opt/cursor.appimage --no-sandbox
Icon=cursor
Type=Application
Categories=Development;IDE;
EOF
        echo "Cursor installed to /opt/cursor.appimage"
    fi
}

# ============================================================
# Zed Editor
# ============================================================
install_zed() {
    echo ""
    echo "=== Installing Zed ==="
    echo ""

    if command -v zed &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Zed (already installed)"
            return
        fi
        echo "Zed already installed"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Zed"
        return
    fi

    if is_macos; then
        brew install --cask zed
    elif is_debian; then
        # Zed provides an install script for Linux
        curl -fsSL https://zed.dev/install.sh | sh
    elif is_arch; then
        # Zed is in community repo on Arch
        sudo pacman -S --noconfirm --needed zed
    fi
}

# ============================================================
# Google Antigravity IDE
# ============================================================
install_antigravity() {
    echo ""
    echo "=== Installing Google Antigravity ==="
    echo ""

    if command -v antigravity &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Antigravity (already installed)"
            return
        fi
        echo "Antigravity already installed: $(antigravity --version 2>/dev/null || echo 'version unknown')"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Antigravity"
        return
    fi

    if is_macos; then
        brew install --cask antigravity
    elif is_debian; then
        # Add Antigravity apt repository
        echo "Adding Antigravity repository..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
            sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
        echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
            sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null

        echo "Installing Antigravity..."
        sudo apt update
        sudo apt install -y antigravity
    elif is_arch; then
        # Check if available in AUR
        if [[ "$PKG_MANAGER" != "pacman" ]]; then
            echo "Installing Antigravity from AUR..."
            pkg_install antigravity-bin
        else
            echo "Antigravity requires an AUR helper (paru/yay). Install manually:"
            echo "  paru -S antigravity-bin"
            echo "  or visit: https://antigravity.google"
            return 1
        fi
    fi

    echo "Antigravity installed!"
    echo "Run 'antigravity' to launch or visit: https://antigravity.google"
}

# ============================================================
# Gemini CLI
# ============================================================
install_gemini_cli() {
    echo ""
    echo "=== Installing Gemini CLI ==="
    echo ""

    # Check if already installed and handle dry-run
    if command -v gemini &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Gemini CLI (already installed)"
            return
        fi
        echo "Gemini CLI already installed"
        return
    fi

    # In dry-run, report what would be done
    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Gemini CLI"
        return
    fi

    if is_macos; then
        brew install gemini-cli
    else
        # Requires Node.js 20+
        if ! command -v node &> /dev/null; then
            echo "Node.js required for Gemini CLI. Install with --runtimes first."
            return
        fi

        local node_version
        node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [[ "$node_version" -lt 20 ]]; then
            echo "Gemini CLI requires Node.js 20+. Current: $(node --version)"
            echo "Run: nvm install 20 && nvm use 20"
            return
        fi

        npm install -g @google/gemini-cli
    fi

    echo "Gemini CLI installed! Run 'gemini' to start."
}

# ============================================================
# OpenAI Codex CLI
# ============================================================
install_codex() {
    echo ""
    echo "=== Installing OpenAI Codex ==="
    echo ""

    # Check if already installed and handle dry-run
    if command -v codex &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Codex (already installed)"
            return
        fi
        echo "Codex already installed"
        return
    fi

    # In dry-run, report what would be done
    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Codex"
        return
    fi

    if is_macos; then
        brew install --cask codex
    else
        # Install via bun/npm
        if command -v bun &> /dev/null; then
            echo "Installing Codex via bun..."
            bun install --global @openai/codex
        elif command -v npm &> /dev/null; then
            echo "Installing Codex via npm..."
            npm install -g @openai/codex
        else
            echo "Bun or npm required for Codex. Install with --dev or --runtimes first."
            return 1
        fi
    fi

    echo "Codex installed! Run 'codex' to start."
}

# ============================================================
# Claude Code CLI
# ============================================================
install_claude_code() {
    echo ""
    echo "=== Installing Claude Code ==="
    echo ""

    # Check if already installed and handle dry-run
    if command -v claude &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Claude Code (already installed)"
            return
        fi
        echo "Claude Code already installed: $(claude --version 2>/dev/null || echo 'version unknown')"
        return
    fi

    # In dry-run, report what would be done
    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Claude Code"
        return
    fi

    if is_macos; then
        brew install --cask claude-code
    else
        # Use official install script
        echo "Installing Claude Code via official script..."
        curl -fsSL https://claude.ai/install.sh | bash
    fi

    echo "Claude Code installed! Run 'claude' to start."
}

# ============================================================
# Neovim + LazyVim
# ============================================================
install_neovim_lazyvim() {
    echo ""
    echo "=== Installing Neovim + LazyVim ==="
    echo ""

    # Check if LazyVim is already installed
    if [[ -f ~/.config/nvim/.lazyvim ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] LazyVim (already installed)"
            return
        fi
        echo "LazyVim already installed"
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
            cd /tmp
            curl -fsSL "https://github.com/neovim/neovim/releases/download/${nvim_version}/nvim-linux-x86_64.tar.gz" -o nvim.tar.gz
            sudo tar -xzf nvim.tar.gz -C /opt
            sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
            rm nvim.tar.gz
            cd - > /dev/null
        elif is_arch; then
            sudo pacman -S --noconfirm --needed neovim
        fi
    else
        echo "Neovim already installed: $(nvim --version | head -1)"
    fi

    # Install LazyVim dependencies
    echo "Installing LazyVim dependencies..."
    if is_macos; then
        brew install lazygit fd ripgrep
    elif is_debian; then
        sudo apt install -y fd-find ripgrep
        # lazygit installed separately in CLI tools
    elif is_arch; then
        sudo pacman -S --noconfirm --needed lazygit fd ripgrep
    fi

    # Install LazyVim config
    if [[ -d ~/.config/nvim && ! -f ~/.config/nvim/.lazyvim ]]; then
        echo "Existing Neovim config found. Backing up to ~/.config/nvim.bak"
        mv ~/.config/nvim ~/.config/nvim.bak
    fi

    if [[ ! -d ~/.config/nvim ]]; then
        echo "Installing LazyVim starter..."
        git clone https://github.com/LazyVim/starter ~/.config/nvim
        rm -rf ~/.config/nvim/.git
        touch ~/.config/nvim/.lazyvim
        echo "LazyVim installed! Run 'nvim' and wait for plugins to install."
    else
        echo "LazyVim already installed"
    fi
}

# ============================================================
# Install all dev editors
# ============================================================
install_all_editors() {
    install_vscode
    install_cursor
    install_zed
    install_antigravity
    install_gemini_cli
    install_codex
    install_claude_code
    install_neovim_lazyvim

    echo ""
    echo "=== All dev editors installed! ==="
    echo ""
}
