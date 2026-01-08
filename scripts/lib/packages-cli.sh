#!/bin/bash
# CLI tools package definitions

install_cli_packages() {
    echo ""
    echo "=== Installing CLI Tools ==="
    echo ""

    # Common packages (same name across all package managers)
    local common_packages=(
        git
        curl
        wget
        jq
        htop
        tree
        fzf
        zoxide
        eza
        bat
        btop
        ripgrep
        neovim
        httpie
    )

    # Install common packages
    for pkg in "${common_packages[@]}"; do
        pkg_install "$pkg"
    done

    # OS-specific packages
    if is_macos; then
        pkg_install fd
        pkg_install gh
        pkg_install lazygit
        pkg_install lazydocker
        pkg_install git-delta
        pkg_install atuin
        pkg_install gum
        pkg_install tldr
    elif is_debian; then
        pkg_install fd-find
        pkg_install gh
        pkg_install git-delta
        # lazygit and lazydocker need special handling on Debian
        try_install install_lazygit_debian "lazygit"
        try_install install_lazydocker_debian "lazydocker"
        try_install install_atuin_debian "atuin"
        try_install install_gum_debian "gum"
        try_install install_tldr_debian "tldr"
    elif is_arch; then
        pkg_install fd
        pkg_install github-cli
        pkg_install lazygit
        pkg_install git-delta
        pkg_install atuin
        pkg_install gum
        pkg_install tldr  # tealdeer package
        # lazydocker is in AUR
        if [[ "$PKG_MANAGER" != "pacman" ]]; then
            pkg_install lazydocker-bin
        else
            echo "Skipping lazydocker (requires AUR helper)"
        fi
    fi

    echo ""
    echo "CLI tools installed!"
}

install_lazygit_debian() {
    require_not_installed lazygit "lazygit" || return 0

    # Fetch latest version from GitHub API
    local version
    version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p' | head -1)
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm /tmp/lazygit.tar.gz /tmp/lazygit
}

install_lazydocker_debian() {
    require_not_installed lazydocker "lazydocker" || return 0

    # SECURITY NOTE: This uses curl|bash which is the official lazydocker install method.
    # The script is from the official lazydocker repo: https://github.com/jesseduffield/lazydocker
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
}

install_atuin_debian() {
    require_not_installed atuin "atuin" || return 0

    # SECURITY NOTE: This uses curl|sh which is the official atuin install method.
    # The script is from the official atuin website: https://atuin.sh
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
}

install_gum_debian() {
    require_not_installed gum "gum" || return 0

    setup_apt_repo "Charm" \
        "https://repo.charm.sh/apt/gpg.key" \
        "/etc/apt/keyrings/charm.gpg" \
        "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
        "/etc/apt/sources.list.d/charm.list"
    sudo apt install -y gum
}

install_tldr_debian() {
    require_not_installed tldr "tldr" || return 0

    # Install tealdeer (Rust implementation) via cargo or binary
    if command -v cargo &> /dev/null; then
        cargo install tealdeer
    else
        # Download pre-built binary
        local arch url
        arch=$(uname -m)
        if [[ "$arch" == "x86_64" ]]; then
            url="https://github.com/tealdeer-rs/tealdeer/releases/latest/download/tealdeer-linux-x86_64-musl"
        elif [[ "$arch" == "aarch64" ]]; then
            url="https://github.com/tealdeer-rs/tealdeer/releases/latest/download/tealdeer-linux-arm-musleabi"
        else
            echo "Unsupported architecture for tldr: $arch"
            return 1
        fi
        curl -fsSL "$url" -o /tmp/tldr
        sudo install -m 755 /tmp/tldr /usr/local/bin/tldr
        rm /tmp/tldr
    fi
    echo "  Run 'tldr --update' to download pages."
}

# 1Password desktop app and CLI
install_1password() {
    echo ""
    echo "=== Installing 1Password ==="
    echo ""

    # Check if already fully installed
    if command -v op &> /dev/null && (command -v 1password &> /dev/null || [[ -d "/Applications/1Password.app" ]]); then
        echo "1Password already installed"
        echo "1Password CLI: $(op --version)"
        configure_1password_ssh_git
        return
    fi

    if is_macos; then
        install_1password_macos
    elif is_debian; then
        install_1password_debian
    elif is_arch; then
        install_1password_arch
    fi

    # Configure SSH and git signing for 1Password
    configure_1password_ssh_git

    echo ""
    echo "1Password installed!"
    echo ""
    echo "Next steps:"
    echo "  1. Open 1Password and sign in"
    echo "  2. Settings > Developer > Integrate with 1Password CLI"
    echo "  3. Settings > Developer > Set Up SSH Agent"
    echo "  4. Add SSH key to GitHub as signing key"
}

# Configure SSH agent and git commit signing for 1Password
configure_1password_ssh_git() {
    echo ""
    echo "Configuring SSH and git for 1Password..."

    # Find the dotfiles directory (parent of scripts/)
    local DOTFILES_DIR
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    # Create SSH directory
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    # Install SSH config (merge with existing if present)
    if [[ -f "$DOTFILES_DIR/ssh/config" ]]; then
        if [[ -f ~/.ssh/config ]]; then
            if ! grep -q "1password/agent.sock" ~/.ssh/config 2>/dev/null; then
                echo "" >> ~/.ssh/config
                cat "$DOTFILES_DIR/ssh/config" >> ~/.ssh/config
                echo "  Appended 1Password agent to ~/.ssh/config"
            else
                echo "  SSH config already has 1Password agent"
            fi
        else
            cp "$DOTFILES_DIR/ssh/config" ~/.ssh/config
            echo "  Created ~/.ssh/config with 1Password agent"
        fi
        chmod 600 ~/.ssh/config
    fi

    # Configure git commit signing
    if ! git config --global --get gpg.format &>/dev/null; then
        git config --global gpg.format ssh
        git config --global commit.gpgsign true
        git config --global tag.gpgsign true
        echo "  Configured git for SSH commit signing"
    else
        echo "  Git signing already configured"
    fi
}

install_1password_macos() {
    # Desktop app
    if ! [[ -d "/Applications/1Password.app" ]]; then
        echo "Installing 1Password desktop app..."
        brew install --cask 1password
    else
        echo "1Password desktop app already installed"
    fi

    # CLI
    if ! command -v op &> /dev/null; then
        echo "Installing 1Password CLI..."
        brew install --cask 1password-cli
    else
        echo "1Password CLI already installed: $(op --version)"
    fi
}

install_1password_debian() {
    # Check if already fully installed
    if command -v op &> /dev/null && command -v 1password &> /dev/null; then
        echo "1Password already installed"
        return
    fi

    # Add 1Password apt repository if not present (check both .list and .sources formats)
    if [[ ! -f /etc/apt/sources.list.d/1password.list ]] && [[ ! -f /etc/apt/sources.list.d/1password.sources ]]; then
        echo "Adding 1Password apt repository..."

        # Add signing key (use --yes to overwrite if exists)
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
            sudo gpg --dearmor --yes --output /usr/share/keyrings/1password-archive-keyring.gpg

        # Add repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
            sudo tee /etc/apt/sources.list.d/1password.list

        # Add debsig policy
        sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
            sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
        sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
            sudo gpg --dearmor --yes --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

        sudo apt update
    fi

    # Desktop app
    if ! command -v 1password &> /dev/null; then
        echo "Installing 1Password desktop app..."
        sudo apt install -y 1password
    else
        echo "1Password desktop app already installed"
    fi

    # CLI
    if ! command -v op &> /dev/null; then
        echo "Installing 1Password CLI..."
        sudo apt install -y 1password-cli
    else
        echo "1Password CLI already installed: $(op --version)"
    fi
}

install_1password_arch() {
    # Check if already fully installed
    if command -v op &> /dev/null && command -v 1password &> /dev/null; then
        echo "1Password already installed"
        return
    fi

    # Import signing key (suppress output if already imported)
    echo "Importing 1Password GPG key..."
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import 2>/dev/null || true

    # Desktop app (AUR)
    if ! command -v 1password &> /dev/null; then
        echo "Installing 1Password desktop app..."
        if [[ "$PKG_MANAGER" == "paru" ]]; then
            paru -S --noconfirm --needed 1password
        elif [[ "$PKG_MANAGER" == "yay" ]]; then
            yay -S --noconfirm --needed 1password
        else
            echo "1Password requires an AUR helper (paru or yay)"
            echo "Install manually: git clone https://aur.archlinux.org/1password.git && cd 1password && makepkg -si"
        fi
    else
        echo "1Password desktop app already installed"
    fi

    # CLI (AUR)
    if ! command -v op &> /dev/null; then
        echo "Installing 1Password CLI..."
        if [[ "$PKG_MANAGER" == "paru" ]]; then
            paru -S --noconfirm --needed 1password-cli
        elif [[ "$PKG_MANAGER" == "yay" ]]; then
            yay -S --noconfirm --needed 1password-cli
        else
            echo "1Password CLI requires an AUR helper (paru or yay)"
        fi
    else
        echo "1Password CLI already installed: $(op --version)"
    fi
}
