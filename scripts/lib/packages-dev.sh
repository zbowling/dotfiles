#!/bin/bash
# Development tools package definitions

install_dev_packages() {
    echo ""
    echo "=== Installing Development Tools ==="
    echo ""

    if is_macos; then
        install_dev_macos
    elif is_debian; then
        install_dev_debian
    elif is_arch; then
        install_dev_arch
    fi

    # Install Bun (cross-platform)
    install_bun

    echo ""
    echo "Development tools installed!"
}

install_dev_macos() {
    # Xcode command line tools (provides make, gcc, etc.)
    if ! xcode-select -p &> /dev/null; then
        echo "Installing Xcode Command Line Tools..."
        xcode-select --install
    fi

    local packages=(
        cmake
        llvm
        ccache
        sccache
        pkg-config
        openssl
    )

    for pkg in "${packages[@]}"; do
        pkg_install "$pkg"
    done
}

install_dev_debian() {
    local packages=(
        build-essential
        cmake
        make
        gcc
        g++
        clang
        clangd
        llvm
        lld
        ccache
        pkg-config
        libssl-dev
        libelf-dev
        flex
        bison
        libncurses-dev
        bc
    )

    for pkg in "${packages[@]}"; do
        pkg_install "$pkg"
    done

    # sccache via cargo (if rust is installed)
    if command -v cargo &> /dev/null; then
        echo "Installing sccache via cargo..."
        cargo install sccache
    else
        echo "Skipping sccache (install rust first with --runtimes)"
    fi
}

install_dev_arch() {
    local packages=(
        base-devel
        cmake
        make
        gcc
        clang
        llvm
        lld
        ccache
        sccache
        pkgconf
        openssl
        libelf
        flex
        bison
        ncurses
        bc
    )

    for pkg in "${packages[@]}"; do
        pkg_install "$pkg"
    done
}

# ============================================================
# Bun (JavaScript runtime & package manager)
# ============================================================
install_bun() {
    echo ""
    echo "--- Installing Bun ---"

    if command -v bun &> /dev/null; then
        echo "Bun already installed: $(bun --version)"
        return
    fi

    if is_macos; then
        brew install oven-sh/bun/bun
    else
        # Linux: use official install script
        # Requires unzip
        if ! command -v unzip &> /dev/null; then
            if is_debian; then
                sudo apt install -y unzip
            elif is_arch; then
                sudo pacman -S --noconfirm --needed unzip
            fi
        fi

        curl -fsSL https://bun.sh/install | bash
    fi

    echo "Bun installed! Preferred for JS dev (faster than Node)."
}
