#!/bin/bash
# Desktop application installers
# Cross-platform: macOS, Ubuntu/Debian, Arch/CachyOS

# ============================================================
# Google Chrome
# ============================================================
install_chrome() {
    echo ""
    echo "=== Installing Google Chrome ==="
    echo ""

    if is_macos; then
        if ! [[ -d "/Applications/Google Chrome.app" ]]; then
            brew install --cask google-chrome
        else
            echo "Google Chrome already installed"
        fi
    elif is_debian; then
        if ! command -v google-chrome &> /dev/null; then
            echo "Downloading Google Chrome..."
            (
                cd /tmp || exit 1
                wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb
                sudo apt install -y ./chrome.deb
                rm chrome.deb
            )
        else
            echo "Google Chrome already installed"
        fi
    elif is_arch; then
        if ! command -v google-chrome-stable &> /dev/null; then
            if [[ "$PKG_MANAGER" == "paru" ]]; then
                paru -S --noconfirm --needed google-chrome
            elif [[ "$PKG_MANAGER" == "yay" ]]; then
                yay -S --noconfirm --needed google-chrome
            else
                echo "Google Chrome requires an AUR helper (paru or yay)"
            fi
        else
            echo "Google Chrome already installed"
        fi
    fi
}

# ============================================================
# Ghostty Terminal
# ============================================================
install_ghostty() {
    echo ""
    echo "=== Installing Ghostty ==="
    echo ""

    if is_macos; then
        if ! [[ -d "/Applications/Ghostty.app" ]]; then
            brew install --cask ghostty
        else
            echo "Ghostty already installed"
        fi
    elif is_debian; then
        if ! command -v ghostty &> /dev/null; then
            # Ghostty on Ubuntu/Debian - try snap first, then build from source
            if command -v snap &> /dev/null; then
                echo "Installing Ghostty via snap..."
                sudo snap install ghostty --classic
            else
                echo "Ghostty not available via apt. Options:"
                echo "  1. Install snap and run: sudo snap install ghostty --classic"
                echo "  2. Build from source: https://ghostty.org/docs/install/build"
            fi
        else
            echo "Ghostty already installed"
        fi
    elif is_arch; then
        if ! command -v ghostty &> /dev/null; then
            # Ghostty is in community repo on Arch
            sudo pacman -S --noconfirm --needed ghostty
        else
            echo "Ghostty already installed"
        fi
    fi
}

# ============================================================
# Alacritty Terminal
# ============================================================
install_alacritty() {
    echo ""
    echo "=== Installing Alacritty ==="
    echo ""

    if is_macos; then
        if ! [[ -d "/Applications/Alacritty.app" ]]; then
            brew install --cask alacritty
        else
            echo "Alacritty already installed"
        fi
    elif is_debian; then
        if ! command -v alacritty &> /dev/null; then
            sudo apt install -y alacritty
        else
            echo "Alacritty already installed"
        fi
    elif is_arch; then
        if ! command -v alacritty &> /dev/null; then
            sudo pacman -S --noconfirm --needed alacritty
        else
            echo "Alacritty already installed"
        fi
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

    if is_macos; then
        if ! [[ -d "/Applications/Discord.app" ]]; then
            brew install --cask discord
        else
            echo "Discord already installed"
        fi
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
        echo "Ollama already installed: $(ollama --version 2>/dev/null || echo 'version unknown')"
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
        echo "Tailscale already installed: $(tailscale version 2>/dev/null | head -1)"
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

    if is_macos; then
        if ! [[ -d "/Applications/zoom.us.app" ]]; then
            brew install --cask zoom
        else
            echo "Zoom already installed"
        fi
    elif is_debian; then
        if ! command -v zoom &> /dev/null; then
            echo "Downloading Zoom..."
            (
                cd /tmp || exit 1
                wget -q https://zoom.us/client/latest/zoom_amd64.deb -O zoom.deb
                sudo apt install -y ./zoom.deb
                rm zoom.deb
            )
        else
            echo "Zoom already installed"
        fi
    elif is_arch; then
        if ! command -v zoom &> /dev/null; then
            if [[ "$PKG_MANAGER" == "paru" ]]; then
                paru -S --noconfirm --needed zoom
            elif [[ "$PKG_MANAGER" == "yay" ]]; then
                yay -S --noconfirm --needed zoom
            else
                echo "Zoom requires an AUR helper (paru or yay)"
            fi
        else
            echo "Zoom already installed"
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

    if is_macos; then
        if ! [[ -d "/Applications/Steam.app" ]]; then
            brew install --cask steam
        else
            echo "Steam already installed"
        fi
    elif is_debian; then
        if ! command -v steam &> /dev/null; then
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
        else
            echo "Steam already installed"
        fi
    elif is_arch; then
        if ! command -v steam &> /dev/null; then
            # Enable multilib repository for Steam
            if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
                echo ""
                echo "Enabling multilib repository..."
                sudo sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
                sudo pacman -Sy
            fi
            sudo pacman -S --noconfirm --needed steam
        else
            echo "Steam already installed"
        fi
    fi
}

# ============================================================
# Spotify
# ============================================================
install_spotify() {
    echo ""
    echo "=== Installing Spotify ==="
    echo ""

    if is_macos; then
        if ! [[ -d "/Applications/Spotify.app" ]]; then
            brew install --cask spotify
        else
            echo "Spotify already installed"
        fi
    elif is_debian; then
        if ! command -v spotify &> /dev/null; then
            # Add Spotify apt repository
            if [[ ! -f /etc/apt/sources.list.d/spotify.list ]]; then
                echo "Adding Spotify apt repository..."
                curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | \
                    sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
                echo "deb [signed-by=/etc/apt/trusted.gpg.d/spotify.gpg] https://repository.spotify.com stable non-free" | \
                    sudo tee /etc/apt/sources.list.d/spotify.list
                sudo apt update
            fi
            sudo apt install -y spotify-client
        else
            echo "Spotify already installed"
        fi
    elif is_arch; then
        if ! command -v spotify &> /dev/null; then
            # Spotify is in AUR
            if [[ "$PKG_MANAGER" == "paru" ]]; then
                paru -S --noconfirm --needed spotify
            elif [[ "$PKG_MANAGER" == "yay" ]]; then
                yay -S --noconfirm --needed spotify
            else
                echo "Spotify requires an AUR helper (paru or yay)"
            fi
        else
            echo "Spotify already installed"
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

    if is_macos; then
        if ! [[ -d "/Applications/Signal.app" ]]; then
            brew install --cask signal
        else
            echo "Signal already installed"
        fi
    elif is_debian; then
        if ! command -v signal-desktop &> /dev/null; then
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
        else
            echo "Signal already installed"
        fi
    elif is_arch; then
        if ! command -v signal-desktop &> /dev/null; then
            # Signal is in community repo on Arch
            sudo pacman -S --noconfirm --needed signal-desktop
        else
            echo "Signal already installed"
        fi
    fi
}

# ============================================================
# Docker (Docker Desktop on macOS, Docker Engine on Linux)
# ============================================================
install_docker() {
    echo ""
    echo "=== Installing Docker ==="
    echo ""

    if is_macos; then
        if ! [[ -d "/Applications/Docker.app" ]]; then
            brew install --cask docker
        else
            echo "Docker Desktop already installed"
        fi
        return
    fi

    if command -v docker &> /dev/null; then
        echo "Docker already installed: $(docker --version)"
        return
    fi

    if is_debian; then
        # Add Docker apt repository
        if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
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

    # Refresh font cache
    echo "Refreshing font cache..."
    fc-cache -f

    echo "Fonts installed to ~/.local/share/fonts"
}

# ============================================================
# Install all desktop apps
# ============================================================
install_all_apps() {
    install_chrome
    install_ghostty
    install_alacritty
    install_discord
    install_spotify
    install_signal
    install_ollama
    install_zoom
    install_steam
    # Note: Docker, Fonts, Tailscale, 1Password are optional

    echo ""
    echo "=== All desktop apps installed! ==="
    echo ""
    echo "Optional extras (not included in --apps):"
    echo "  --docker     Docker engine"
    echo "  --fonts      Nerd Fonts"
    echo "  --tailscale  Tailscale VPN"
    echo "  --1password  1Password + CLI"
    echo ""
}
