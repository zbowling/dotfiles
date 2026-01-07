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
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] mise (already installed)"
            return
        fi
        echo "mise already installed: $(mise --version)"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] mise"
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
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] uv (already installed)"
            return
        fi
        echo "uv already installed: $(uv --version)"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] uv"
        return
    fi

    curl -LsSf https://astral.sh/uv/install.sh | sh

    echo "uv installed."
}

install_nvm() {
    echo ""
    echo "--- Installing nvm (Node version manager) ---"

    if [[ -d "$HOME/.nvm" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] nvm (already installed)"
            return
        fi
        echo "nvm already installed"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] nvm"
        return
    fi

    # Use nvm's official install script (it handles version detection)
    # Fallback to known stable version if API fails
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

    echo "nvm installed."
    echo "Run 'nvm install --lts' to install Node.js LTS"
}

install_rustup() {
    echo ""
    echo "--- Installing rustup (Rust toolchain) ---"

    if command -v rustup &> /dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] rustup (already installed)"
            return
        fi
        echo "rustup already installed: $(rustup --version)"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] rustup"
        return
    fi

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

    # Add to PATH for current session
    source "$HOME/.cargo/env" 2>/dev/null || true

    echo "rustup installed."
    echo "Rust toolchain: $(rustc --version 2>/dev/null || echo 'restart shell to use')"
}
