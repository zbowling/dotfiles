#!/bin/bash
# Runtime installers: mise, uv, nvm, rustup

install_runtimes() {
    echo ""
    echo "=== Installing Runtimes ==="
    echo ""

    install_mise
    install_uv
    install_nvm
    install_rustup

    echo ""
    echo "Runtimes installed!"
    echo ""
    echo "NOTE: You may need to restart your shell or source your config:"
    echo "  source ~/.zshrc  # or ~/.bashrc"
}

install_mise() {
    echo ""
    echo "--- Installing mise (polyglot version manager) ---"

    if command -v mise &> /dev/null; then
        echo "mise already installed: $(mise --version)"
        return
    fi

    curl https://mise.run | sh

    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"

    echo "mise installed. Shell integration is already in your dotfiles."
}

install_uv() {
    echo ""
    echo "--- Installing uv (Python package manager) ---"

    if command -v uv &> /dev/null; then
        echo "uv already installed: $(uv --version)"
        return
    fi

    curl -LsSf https://astral.sh/uv/install.sh | sh

    echo "uv installed."
}

install_nvm() {
    echo ""
    echo "--- Installing nvm (Node version manager) ---"

    if [[ -d "$HOME/.nvm" ]]; then
        echo "nvm already installed"
        return
    fi

    # Get latest nvm version
    NVM_VERSION=$(curl -s "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | sed -n 's/.*"tag_name": "\([^"]*\)".*/\1/p' | head -1)
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash

    echo "nvm installed."
    echo "Run 'nvm install --lts' to install Node.js LTS"
}

install_rustup() {
    echo ""
    echo "--- Installing rustup (Rust toolchain) ---"

    if command -v rustup &> /dev/null; then
        echo "rustup already installed: $(rustup --version)"
        return
    fi

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

    # Add to PATH for current session
    source "$HOME/.cargo/env" 2>/dev/null || true

    echo "rustup installed."
    echo "Rust toolchain: $(rustc --version 2>/dev/null || echo 'restart shell to use')"
}
