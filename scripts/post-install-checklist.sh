#!/bin/bash
# Generate a post-install checklist based on what's installed
# Usage: ./post-install-checklist.sh

set -e

echo ""
echo "============================================"
echo "  Post-Install Checklist"
echo "============================================"
echo ""

# ============================================================
# Required Steps
# ============================================================
echo "## Required"
echo ""
echo "- [ ] Restart terminal or run: source ~/.zshrc"
echo "- [ ] Set zsh as default shell: chsh -s \$(which zsh)"
echo ""

# ============================================================
# Git
# ============================================================
if command -v git &> /dev/null; then
    echo "## Git"
    echo ""

    if ! git config --global --get user.name &>/dev/null; then
        echo "- [ ] Set git user.name: git config --global user.name \"Your Name\""
    fi

    if ! git config --global --get user.email &>/dev/null; then
        echo "- [ ] Set git user.email: git config --global user.email \"your@email.com\""
    fi

    if command -v gh &> /dev/null; then
        if ! gh auth status &>/dev/null 2>&1; then
            echo "- [ ] Authenticate with GitHub: gh auth login"
        else
            echo "- [x] GitHub CLI authenticated"
        fi
    fi
    echo ""
fi

# ============================================================
# SSH
# ============================================================
echo "## SSH Keys"
echo ""
if [[ -f ~/.ssh/id_ed25519 ]] || [[ -f ~/.ssh/id_rsa ]]; then
    echo "- [x] SSH key exists"
    if command -v gh &> /dev/null && gh auth status &>/dev/null 2>&1; then
        echo "- [ ] Verify key is added to GitHub: gh ssh-key list"
    else
        echo "- [ ] Add SSH key to GitHub/GitLab"
    fi
else
    echo "- [ ] Generate SSH key: ssh-keygen -t ed25519 -C \"your@email.com\""
    echo "- [ ] Add SSH key to GitHub/GitLab"
fi
echo ""

# ============================================================
# 1Password
# ============================================================
if command -v op &> /dev/null || command -v 1password &> /dev/null; then
    echo "## 1Password"
    echo ""
    echo "- [ ] Open 1Password and sign in to your account"
    echo "- [ ] Settings > Developer > Integrate with 1Password CLI"
    echo "- [ ] Settings > Developer > Set Up SSH Agent"
    echo "- [ ] Add SSH key to GitHub as signing key"
    echo "- [ ] In 1Password, click your SSH key > Configure Commit Signing"
    echo ""
fi

# ============================================================
# Tailscale
# ============================================================
if command -v tailscale &> /dev/null; then
    echo "## Tailscale"
    echo ""

    if tailscale status &>/dev/null 2>&1; then
        echo "- [x] Tailscale is connected"
    else
        echo "- [ ] Connect to Tailscale: sudo tailscale up"
        echo "- [ ] Authorize in browser when prompted"
    fi
    echo ""
fi

# ============================================================
# Atuin
# ============================================================
if command -v atuin &> /dev/null; then
    echo "## Atuin (Shell History Sync)"
    echo ""
    echo "- [ ] (Optional) Create account: atuin register"
    echo "- [ ] (Optional) Login for sync: atuin login"
    echo "- [ ] Import existing history: atuin import auto"
    echo ""
fi

# ============================================================
# Docker
# ============================================================
if command -v docker &> /dev/null; then
    echo "## Docker"
    echo ""

    if docker ps &>/dev/null 2>&1; then
        echo "- [x] Docker is running"
    else
        echo "- [ ] Start Docker service: sudo systemctl start docker"
        echo "- [ ] (Optional) Enable at boot: sudo systemctl enable docker"
    fi

    if groups | grep -q docker 2>/dev/null; then
        echo "- [x] User in docker group"
    else
        echo "- [ ] Add user to docker group: sudo usermod -aG docker \$USER"
        echo "      (requires logout/login)"
    fi
    echo ""
fi

# ============================================================
# Neovim / LazyVim
# ============================================================
if command -v nvim &> /dev/null; then
    echo "## Neovim"
    echo ""

    if [[ -d ~/.config/nvim ]]; then
        echo "- [x] Neovim config exists"
    else
        echo "- [ ] Set up Neovim config (LazyVim recommended)"
    fi

    if [[ -d ~/.local/share/nvim/lazy ]]; then
        echo "- [x] Lazy.nvim plugins installed"
    else
        echo "- [ ] Launch nvim to install plugins"
    fi
    echo ""
fi

# ============================================================
# Antidote (zsh plugins)
# ============================================================
echo "## Zsh Plugins"
echo ""
if [[ -d ~/.antidote ]]; then
    echo "- [x] Antidote installed"
else
    echo "- [ ] Install Antidote: git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote"
fi
echo ""

# ============================================================
# Runtimes
# ============================================================
runtime_section=false

if command -v mise &> /dev/null; then
    if [[ "$runtime_section" == false ]]; then
        echo "## Runtimes"
        echo ""
        runtime_section=true
    fi
    echo "- [x] mise installed"
    echo "- [ ] Install a runtime: mise use node@lts"
fi

if command -v rustup &> /dev/null; then
    if [[ "$runtime_section" == false ]]; then
        echo "## Runtimes"
        echo ""
        runtime_section=true
    fi
    if rustup show | grep -q "stable"; then
        echo "- [x] Rust stable installed"
    else
        echo "- [ ] Install Rust stable: rustup install stable"
    fi
fi

if command -v uv &> /dev/null; then
    if [[ "$runtime_section" == false ]]; then
        echo "## Runtimes"
        echo ""
        runtime_section=true
    fi
    echo "- [x] uv (Python) installed"
fi

if command -v bun &> /dev/null; then
    if [[ "$runtime_section" == false ]]; then
        echo "## Runtimes"
        echo ""
        runtime_section=true
    fi
    echo "- [x] Bun installed"
fi

if [[ "$runtime_section" == true ]]; then
    echo ""
fi

# ============================================================
# macOS specific
# ============================================================
if [[ "$(uname)" == "Darwin" ]]; then
    echo "## macOS"
    echo ""
    echo "- [ ] Run macOS defaults: ./scripts/install-packages.sh --macos-defaults"
    echo ""
fi

# ============================================================
# Summary
# ============================================================
echo "============================================"
echo "  Run this script again to update progress"
echo "============================================"
echo ""
