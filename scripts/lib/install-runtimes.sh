#!/bin/bash
# Runtime installers: mise, uv, nvm, rustup

install_runtimes() {
    echo ""
    echo "=== Installing Runtimes ==="
    echo ""

    try_install install_mise "mise"
    try_install install_uv "uv"
    try_install _install_bun_runtime "bun"
    try_install install_nvm "nvm"
    try_install install_rustup "rustup"

    # Make freshly installed tools available for later installs
    refresh_path

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

_install_bun_runtime() {
    echo ""
    echo "--- Installing bun (fast JavaScript runtime) ---"

    if command -v bun &> /dev/null || [[ -x "$HOME/.bun/bin/bun" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[SKIP] bun (already installed)"
            return
        fi
        local bun_path="${HOME}/.bun/bin/bun"
        [[ -x "$bun_path" ]] || bun_path="$(command -v bun)"
        echo "bun already installed: $("$bun_path" --version 2>/dev/null || echo 'version unknown')"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[WOULD INSTALL] bun"
        return
    fi

    # SECURITY NOTE: This uses curl|bash which is the official bun install method.
    # The script is from the official bun website: https://bun.sh
    curl -fsSL https://bun.sh/install | bash

    # Add to PATH for current session
    export PATH="$HOME/.bun/bin:$PATH"

    echo "bun installed."
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

    # Fetch latest nvm version from GitHub API, fallback to known stable if API fails
    # SECURITY NOTE: This uses curl|bash which is the official nvm install method.
    # The script is from the official nvm repository: https://github.com/nvm-sh/nvm
    local nvm_version
    nvm_version=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [[ -z "$nvm_version" ]]; then
        nvm_version="v0.40.3"  # Fallback to known stable version
        echo "  Note: Could not fetch latest nvm version, using $nvm_version"
    fi
    echo "  Installing nvm $nvm_version..."
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" | bash

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
