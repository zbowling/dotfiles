#!/bin/bash
# Desktop application installers
# Cross-platform: macOS, Ubuntu/Debian, Arch/CachyOS

# ============================================================
# Google Chrome
# ============================================================
install_chrome() {
    print_section "Installing Google Chrome"

    # Check if already installed (handles both command and macOS app)
    require_app_not_installed "Google Chrome" "Chrome" || return 0
    if command -v google-chrome &> /dev/null || command -v google-chrome-stable &> /dev/null; then
        status_skip "Chrome" "already installed"
        return
    fi
    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Chrome"
        return
    fi

    if is_macos; then
        brew install --cask google-chrome
    elif is_debian; then
        echo "Downloading Google Chrome..."
        download_file "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" "/tmp/chrome.deb"
        sudo apt install -y /tmp/chrome.deb
        rm -f /tmp/chrome.deb
    elif is_arch; then
        aur_install google-chrome
    fi

    status_success "Chrome"
}

# ============================================================
# Ghostty Terminal
# ============================================================
install_ghostty() {
    print_section "Installing Ghostty"

    require_app_not_installed "Ghostty" "Ghostty" || return 0
    require_not_installed ghostty "Ghostty" || return 0

    if is_macos; then
        brew install --cask ghostty
    elif is_debian; then
        if command -v snap &> /dev/null; then
            sudo snap install ghostty --classic
        else
            echo "Ghostty not available via apt. Options:"
            echo "  1. Install snap: sudo snap install ghostty --classic"
            echo "  2. Build from source: https://ghostty.org/docs/install/build"
            return 1
        fi
    elif is_arch; then
        sudo pacman -S --noconfirm --needed ghostty
    fi

    status_success "Ghostty"
}

# ============================================================
# Alacritty Terminal
# ============================================================
install_alacritty() {
    echo ""
    echo "=== Installing Alacritty ==="
    echo ""

    # Check if already installed
    if (is_macos && [[ -d "/Applications/Alacritty.app" ]]) || command -v alacritty &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Alacritty (already installed)"
            return
        fi
        echo "Alacritty already installed"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Alacritty"
        return
    fi

    if is_macos; then
        brew install --cask alacritty
    elif is_debian; then
        sudo apt install -y alacritty
    elif is_arch; then
        sudo pacman -S --noconfirm --needed alacritty
    fi

    # Create config directory
    mkdir -p ~/.config/alacritty
}

# ============================================================
# Discord
# ============================================================
install_discord() {
    echo ""
    echo "=== Installing Discord ==="
    echo ""

    # Check if already installed
    if (is_macos && [[ -d "/Applications/Discord.app" ]]) || command -v discord &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Discord (already installed)"
            return
        fi
        echo "Discord already installed"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Discord"
        return
    fi

    if is_macos; then
        brew install --cask discord
    elif is_debian; then
        if ! command -v discord &> /dev/null; then
            echo "Downloading Discord..."
            (
                cd /tmp || exit 1
                wget -q "https://discord.com/api/download?platform=linux&format=deb" -O discord.deb
                sudo apt install -y ./discord.deb
                rm discord.deb
            )
        else
            echo "Discord already installed"
        fi
    elif is_arch; then
        if ! command -v discord &> /dev/null; then
            # Discord is in community repo on Arch
            sudo pacman -S --noconfirm --needed discord
        else
            echo "Discord already installed"
        fi
    fi
}

# ============================================================
# Ollama (LLM server)
# ============================================================
install_ollama() {
    echo ""
    echo "=== Installing Ollama ==="
    echo ""

    if command -v ollama &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Ollama (already installed)"
            return
        fi
        echo "Ollama already installed: $(ollama --version 2>/dev/null || echo 'version unknown')"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Ollama"
        return
    fi

    if is_macos; then
        brew install ollama
    else
        # Universal Linux installer
        echo "Installing Ollama via official script..."
        curl -fsSL https://ollama.com/install.sh | sh
    fi

    echo ""
    echo "Ollama installed! Start with: ollama serve"
}

# ============================================================
# Tailscale (VPN)
# ============================================================
install_tailscale() {
    echo ""
    echo "=== Installing Tailscale ==="
    echo ""

    if command -v tailscale &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Tailscale (already installed)"
            return
        fi
        echo "Tailscale already installed: $(tailscale version 2>/dev/null | head -1)"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Tailscale"
        return
    fi

    if is_macos; then
        brew install --cask tailscale
    else
        # Universal Linux installer
        echo "Installing Tailscale via official script..."
        curl -fsSL https://tailscale.com/install.sh | sh
    fi

    echo ""
    echo "Tailscale installed! Connect with: sudo tailscale up"
}

# ============================================================
# Zoom
# ============================================================
install_zoom() {
    echo ""
    echo "=== Installing Zoom ==="
    echo ""

    # Check if already installed
    if (is_macos && [[ -d "/Applications/zoom.us.app" ]]) || command -v zoom &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Zoom (already installed)"
            return
        fi
        echo "Zoom already installed"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Zoom"
        return
    fi

    if is_macos; then
        brew install --cask zoom
    elif is_debian; then
        echo "Downloading Zoom..."
        (
            cd /tmp || exit 1
            wget -q https://zoom.us/client/latest/zoom_amd64.deb -O zoom.deb
            sudo apt install -y ./zoom.deb
            rm zoom.deb
        )
    elif is_arch; then
        if [[ "$PKG_MANAGER" == "paru" ]]; then
            paru -S --noconfirm --needed zoom
        elif [[ "$PKG_MANAGER" == "yay" ]]; then
            yay -S --noconfirm --needed zoom
        else
            echo "Zoom requires an AUR helper (paru or yay)"
        fi
    fi
}

# ============================================================
# Steam
# ============================================================
install_steam() {
    echo ""
    echo "=== Installing Steam ==="
    echo ""

    # Check if already installed
    if (is_macos && [[ -d "/Applications/Steam.app" ]]) || command -v steam &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Steam (already installed)"
            return
        fi
        echo "Steam already installed"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Steam"
        return
    fi

    if is_macos; then
        brew install --cask steam
    elif is_debian; then
        # Enable i386 architecture for Steam
        sudo dpkg --add-architecture i386
        sudo apt update

        echo "Downloading Steam..."
        (
            cd /tmp || exit 1
            wget -q https://cdn.akamai.steamstatic.com/client/installer/steam.deb -O steam.deb
            sudo apt install -y ./steam.deb
            rm steam.deb
        )
    elif is_arch; then
        # Enable multilib repository for Steam
        if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
            echo ""
            echo "Enabling multilib repository..."
            sudo sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
            sudo pacman -Sy
        fi
        sudo pacman -S --noconfirm --needed steam
    fi
}

# ============================================================
# Spotify
# ============================================================
install_spotify() {
    echo ""
    echo "=== Installing Spotify ==="
    echo ""

    # Check if already installed
    if (is_macos && [[ -d "/Applications/Spotify.app" ]]) || command -v spotify &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Spotify (already installed)"
            return
        fi
        echo "Spotify already installed"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Spotify"
        return
    fi

    if is_macos; then
        brew install --cask spotify
    elif is_debian; then
        # Add Spotify apt repository (check both .list and .sources formats)
        if [[ ! -f /etc/apt/sources.list.d/spotify.list ]] && [[ ! -f /etc/apt/sources.list.d/spotify.sources ]]; then
            echo "Adding Spotify apt repository..."
            curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | \
                sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
            echo "deb [signed-by=/etc/apt/trusted.gpg.d/spotify.gpg] https://repository.spotify.com stable non-free" | \
                sudo tee /etc/apt/sources.list.d/spotify.list
            sudo apt update
        fi
        sudo apt install -y spotify-client
    elif is_arch; then
        # Spotify is in AUR
        if [[ "$PKG_MANAGER" == "paru" ]]; then
            paru -S --noconfirm --needed spotify
        elif [[ "$PKG_MANAGER" == "yay" ]]; then
            yay -S --noconfirm --needed spotify
        else
            echo "Spotify requires an AUR helper (paru or yay)"
        fi
    fi
}

# ============================================================
# Signal
# ============================================================
install_signal() {
    echo ""
    echo "=== Installing Signal ==="
    echo ""

    # Check if already installed
    if (is_macos && [[ -d "/Applications/Signal.app" ]]) || command -v signal-desktop &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Signal (already installed)"
            return
        fi
        echo "Signal already installed"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Signal"
        return
    fi

    if is_macos; then
        brew install --cask signal
    elif is_debian; then
        # Add Signal apt repository
        if [[ ! -f /etc/apt/sources.list.d/signal-desktop.sources ]]; then
            echo "Adding Signal apt repository..."
            wget -qO- https://updates.signal.org/desktop/apt/keys.asc | \
                gpg --dearmor | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
            wget -qO /tmp/signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources
            sudo cp /tmp/signal-desktop.sources /etc/apt/sources.list.d/
            rm /tmp/signal-desktop.sources
            sudo apt update
        fi
        sudo apt install -y signal-desktop
    elif is_arch; then
        # Signal is in community repo on Arch
        sudo pacman -S --noconfirm --needed signal-desktop
    fi
}

# ============================================================
# Docker (Docker Desktop on macOS, Docker Engine on Linux)
# ============================================================
install_docker() {
    echo ""
    echo "=== Installing Docker ==="
    echo ""

    # Check if already installed
    if (is_macos && [[ -d "/Applications/Docker.app" ]]) || command -v docker &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] Docker (already installed)"
            return
        fi
        if is_macos; then
            echo "Docker Desktop already installed"
        else
            echo "Docker already installed"
        fi
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Docker"
        return
    fi

    if is_macos; then
        brew install --cask docker
        return
    fi

    if command -v docker &> /dev/null; then
        echo "Docker already installed: $(docker --version)"
        return
    fi

    if is_debian; then
        # Add Docker apt repository (check both .list and .sources formats)
        if [[ ! -f /etc/apt/sources.list.d/docker.list ]] && [[ ! -f /etc/apt/sources.list.d/docker.sources ]]; then
            echo "Adding Docker apt repository..."
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo wget -qO /etc/apt/keyrings/docker.asc https://download.docker.com/linux/ubuntu/gpg
            sudo chmod a+r /etc/apt/keyrings/docker.asc
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt update
        fi

        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        # Add user to docker group
        sudo usermod -aG docker ${USER}

        # Configure log rotation
        echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json

        echo ""
        echo "Docker installed! Log out and back in to use docker without sudo."
    elif is_arch; then
        sudo pacman -S --noconfirm --needed docker docker-compose docker-buildx

        # Enable and start Docker
        sudo systemctl enable docker
        sudo systemctl start docker

        # Add user to docker group
        sudo usermod -aG docker ${USER}

        echo ""
        echo "Docker installed! Log out and back in to use docker without sudo."
    fi
}

# ============================================================
# Nerd Fonts (CascadiaMono, JetBrains Mono, iA Writer Mono)
# ============================================================
install_fonts() {
    echo ""
    echo "=== Installing Nerd Fonts ==="
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] Nerd Fonts (CaskaydiaMono, JetBrainsMono)"
        return
    fi

    if is_macos; then
        echo "Installing fonts via Homebrew..."
        brew install --cask font-caskaydia-mono-nerd-font
        brew install --cask font-jetbrains-mono-nerd-font
        echo "Nerd Fonts installed via Homebrew"
        return
    fi

    if is_arch; then
        echo "Installing fonts via pacman..."
        sudo pacman -S --noconfirm --needed \
            ttf-cascadia-mono-nerd \
            ttf-jetbrains-mono-nerd
        echo "Nerd Fonts installed via pacman"
        return
    fi

    # Debian/Ubuntu: Install to ~/.local/share/fonts
    echo "Installing fonts manually..."
    mkdir -p ~/.local/share/fonts

    (
        cd /tmp || exit 1

        # CascadiaMono Nerd Font
        if ! ls ~/.local/share/fonts/CaskaydiaMono* &> /dev/null; then
            echo "Downloading CascadiaMono Nerd Font..."
            wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip
            unzip -q CascadiaMono.zip -d CascadiaFont
            cp CascadiaFont/*.ttf ~/.local/share/fonts/
            rm -rf CascadiaMono.zip CascadiaFont
        else
            echo "CascadiaMono Nerd Font already installed"
        fi

        # JetBrains Mono Nerd Font
        if ! ls ~/.local/share/fonts/JetBrainsMono* &> /dev/null; then
            echo "Downloading JetBrains Mono Nerd Font..."
            wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
            unzip -q JetBrainsMono.zip -d JetBrainsFont
            cp JetBrainsFont/*.ttf ~/.local/share/fonts/
            rm -rf JetBrainsMono.zip JetBrainsFont
        else
            echo "JetBrains Mono Nerd Font already installed"
        fi

        # iA Writer Mono
        if ! ls ~/.local/share/fonts/iAWriterMono* &> /dev/null; then
            echo "Downloading iA Writer Mono..."
            wget -qO iafonts.zip https://github.com/iaolo/iA-Fonts/archive/refs/heads/master.zip
            unzip -q iafonts.zip -d iaFonts
            cp iaFonts/iA-Fonts-master/iA\ Writer\ Mono/Static/iAWriterMonoS-*.ttf ~/.local/share/fonts/
            rm -rf iafonts.zip iaFonts
        else
            echo "iA Writer Mono already installed"
        fi
    )

    # Refresh font cache (only user fonts to avoid permission errors)
    echo "Refreshing font cache..."
    fc-cache -f ~/.local/share/fonts

    echo "Fonts installed to ~/.local/share/fonts"
}

# ============================================================
# Install all desktop apps
# ============================================================
install_all_apps() {
    try_install install_chrome "Chrome"
    try_install install_ghostty "Ghostty"
    try_install install_alacritty "Alacritty"
    try_install install_discord "Discord"
    try_install install_spotify "Spotify"
    try_install install_signal "Signal"
    try_install install_ollama "Ollama"
    try_install install_zoom "Zoom"
    try_install install_steam "Steam"
    # Note: Docker, Fonts, Tailscale, 1Password are optional

    echo ""
    echo "=== Desktop apps section complete ==="
    echo ""
    echo "Optional extras (not included in --apps):"
    echo "  --docker     Docker engine"
    echo "  --fonts      Nerd Fonts"
    echo "  --tailscale  Tailscale VPN"
    echo "  --1password  1Password + CLI"
    echo ""
}
