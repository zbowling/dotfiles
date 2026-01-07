#!/bin/bash
# Cross-platform package installer
# Usage: ./install-packages.sh [--cli] [--dev] [--runtimes] [--apps] [--all] [--extra]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source sudo helper first
source "$SCRIPT_DIR/lib/sudo-helper.sh"

# Check we're not running as root
check_not_root

# Source library scripts (detect-os will set up package manager)
source "$SCRIPT_DIR/lib/detect-os.sh"
source "$SCRIPT_DIR/lib/packages-cli.sh"
source "$SCRIPT_DIR/lib/packages-dev.sh"
source "$SCRIPT_DIR/lib/install-runtimes.sh"
source "$SCRIPT_DIR/lib/packages-apps.sh"
source "$SCRIPT_DIR/lib/packages-editors.sh"
source "$SCRIPT_DIR/lib/git-config.sh"
source "$SCRIPT_DIR/lib/macos-defaults.sh"

# Parse flags
INSTALL_CLI=false
INSTALL_DEV=false
INSTALL_RUNTIMES=false
INSTALL_APPS=false
INSTALL_EXTRA=false
INSTALL_DEV_EDITOR=false
INSTALL_1PASSWORD=false
INIT_GIT=false
MACOS_DEFAULTS=false
SHOW_HELP=false

# Individual app flags
INSTALL_CHROME=false
INSTALL_GHOSTTY=false
INSTALL_ALACRITTY=false
INSTALL_DISCORD=false
INSTALL_SPOTIFY=false
INSTALL_SIGNAL=false
INSTALL_OLLAMA=false
INSTALL_TAILSCALE=false
INSTALL_ZOOM=false
INSTALL_STEAM=false
INSTALL_DOCKER=false
INSTALL_FONTS=false

# Individual editor flags
INSTALL_VSCODE=false
INSTALL_CURSOR=false
INSTALL_ZED=false
INSTALL_ANTIGRAVITY=false
INSTALL_GEMINI_CLI=false
INSTALL_CODEX=false
INSTALL_CLAUDE_CODE=false
INSTALL_LAZYVIM=false

if [[ $# -eq 0 ]]; then
    SHOW_HELP=true
fi

for arg in "$@"; do
    case $arg in
        --cli)
            INSTALL_CLI=true
            ;;
        --dev)
            INSTALL_DEV=true
            ;;
        --runtimes)
            INSTALL_RUNTIMES=true
            ;;
        --apps)
            INSTALL_APPS=true
            ;;
        --extra)
            INSTALL_EXTRA=true
            ;;
        --dev-editor|--dev-editors)
            INSTALL_DEV_EDITOR=true
            ;;
        --1password)
            INSTALL_1PASSWORD=true
            ;;
        --init-git)
            INIT_GIT=true
            ;;
        --macos-defaults|--macos)
            MACOS_DEFAULTS=true
            ;;
        --chrome)
            INSTALL_CHROME=true
            ;;
        --ghostty)
            INSTALL_GHOSTTY=true
            ;;
        --alacritty)
            INSTALL_ALACRITTY=true
            ;;
        --discord)
            INSTALL_DISCORD=true
            ;;
        --spotify)
            INSTALL_SPOTIFY=true
            ;;
        --signal)
            INSTALL_SIGNAL=true
            ;;
        --ollama)
            INSTALL_OLLAMA=true
            ;;
        --tailscale)
            INSTALL_TAILSCALE=true
            ;;
        --zoom)
            INSTALL_ZOOM=true
            ;;
        --steam)
            INSTALL_STEAM=true
            ;;
        --docker)
            INSTALL_DOCKER=true
            ;;
        --fonts)
            INSTALL_FONTS=true
            ;;
        --vscode)
            INSTALL_VSCODE=true
            ;;
        --cursor)
            INSTALL_CURSOR=true
            ;;
        --zed)
            INSTALL_ZED=true
            ;;
        --antigravity)
            INSTALL_ANTIGRAVITY=true
            ;;
        --gemini-cli|--gemini)
            INSTALL_GEMINI_CLI=true
            ;;
        --codex)
            INSTALL_CODEX=true
            ;;
        --claude-code|--claude)
            INSTALL_CLAUDE_CODE=true
            ;;
        --lazyvim|--neovim-lazyvim)
            INSTALL_LAZYVIM=true
            ;;
        --all)
            INSTALL_CLI=true
            INSTALL_DEV=true
            INSTALL_RUNTIMES=true
            INSTALL_APPS=true
            ;;
        --help|-h)
            SHOW_HELP=true
            ;;
        *)
            echo "Unknown option: $arg"
            SHOW_HELP=true
            ;;
    esac
done

if [[ "$SHOW_HELP" == true ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Categories:"
    echo "  --cli         Install CLI tools (eza, fzf, zoxide, bat, git, gh, etc.)"
    echo "  --dev         Install dev tools (cmake, gcc, clang, llvm, etc.)"
    echo "  --runtimes    Install runtimes (mise, uv, nvm, rustup)"
    echo "  --apps        Install desktop apps (Chrome, Ghostty, Discord, etc.)"
    echo "  --dev-editor  Install dev editors (VSCode, Cursor, Zed, Claude Code, etc.)"
    echo "  --all         Install --cli, --dev, --runtimes, --apps"
    echo "  --extra       Install --all + --dev-editor + 1Password, Docker, Tailscale, Fonts"
    echo ""
    echo "Git configuration:"
    echo "  --init-git    Set git user.name/email if not set, configure git defaults,"
    echo "                and authenticate with GitHub CLI"
    echo ""
    echo "macOS only:"
    echo "  --macos-defaults  Configure Finder, screenshots, and system preferences"
    echo ""
    echo "Desktop apps (included in --apps):"
    echo "  --chrome      Google Chrome browser"
    echo "  --ghostty     Ghostty terminal"
    echo "  --alacritty   Alacritty terminal"
    echo "  --discord     Discord chat"
    echo "  --spotify     Spotify music"
    echo "  --signal      Signal messenger"
    echo "  --ollama      Ollama LLM server"
    echo "  --zoom        Zoom video calls"
    echo "  --steam       Steam gaming"
    echo ""
    echo "Dev editors (included in --dev-editor):"
    echo "  --vscode      Visual Studio Code"
    echo "  --cursor      Cursor AI editor"
    echo "  --zed         Zed editor"
    echo "  --antigravity Google Antigravity IDE"
    echo "  --gemini-cli  Gemini CLI"
    echo "  --codex       OpenAI Codex CLI"
    echo "  --claude-code Claude Code CLI"
    echo "  --lazyvim     Neovim + LazyVim"
    echo ""
    echo "Optional extras (included in --extra, or install individually):"
    echo "  --1password   1Password + CLI (SSH agent, git signing)"
    echo "  --docker      Docker engine"
    echo "  --tailscale   Tailscale VPN"
    echo "  --fonts       Nerd Fonts (CascadiaMono, JetBrains Mono)"
    echo ""
    echo "Examples:"
    echo "  $0 --all                  # Install cli, dev, runtimes, apps"
    echo "  $0 --extra                # Install everything including dev editors"
    echo "  $0 --cli --runtimes       # Install CLI tools and runtimes"
    echo "  $0 --dev-editor           # Install all dev editors"
    echo "  $0 --vscode --cursor      # Install specific editors"
    echo "  $0 --init-git             # Set up git user and GitHub auth"
    echo "  $0 --1password            # Install 1Password only"
    exit 0
fi

echo "========================================"
echo "Cross-Platform Package Installer"
echo "========================================"
echo ""

# Handle --extra flag (install everything)
if [[ "$INSTALL_EXTRA" == true ]]; then
    INSTALL_CLI=true
    INSTALL_DEV=true
    INSTALL_RUNTIMES=true
    INSTALL_APPS=true
    INSTALL_DEV_EDITOR=true
    INSTALL_1PASSWORD=true
    INSTALL_DOCKER=true
    INSTALL_TAILSCALE=true
    INSTALL_FONTS=true
    INSTALL_OLLAMA=true
    MACOS_DEFAULTS=true
fi

# Request sudo upfront if we'll need it (Linux package installation)
# This caches credentials so we don't prompt multiple times
if ! is_macos; then
    # Only request sudo if we're installing packages (not just git config)
    if [[ "$INSTALL_CLI" == true ]] || [[ "$INSTALL_DEV" == true ]] || \
       [[ "$INSTALL_APPS" == true ]] || [[ "$INSTALL_DEV_EDITOR" == true ]] || \
       [[ "$INSTALL_1PASSWORD" == true ]] || [[ "$INSTALL_DOCKER" == true ]] || \
       [[ "$INSTALL_TAILSCALE" == true ]] || [[ "$INSTALL_FONTS" == true ]]; then
        require_sudo "Package installation requires sudo access."
    fi
fi

# Check for brew on macOS
if is_macos && ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update package manager (skip for git-only operations)
if [[ "$INIT_GIT" == false ]] || \
   [[ "$INSTALL_CLI" == true ]] || [[ "$INSTALL_DEV" == true ]] || \
   [[ "$INSTALL_RUNTIMES" == true ]] || [[ "$INSTALL_APPS" == true ]] || \
   [[ "$INSTALL_DEV_EDITOR" == true ]]; then
    echo "Updating package manager..."
    $PKG_UPDATE || true
    echo ""
fi

# Git initialization (run first so gh is available for auth)
if [[ "$INIT_GIT" == true ]]; then
    init_git
fi

# Install selected categories
if [[ "$INSTALL_CLI" == true ]]; then
    install_cli_packages
fi

if [[ "$INSTALL_DEV" == true ]]; then
    install_dev_packages
fi

if [[ "$INSTALL_RUNTIMES" == true ]]; then
    install_runtimes
fi

if [[ "$INSTALL_APPS" == true ]]; then
    install_all_apps
fi

if [[ "$INSTALL_DEV_EDITOR" == true ]]; then
    install_all_editors
fi

if [[ "$INSTALL_1PASSWORD" == true ]]; then
    install_1password
fi

# macOS defaults
if [[ "$MACOS_DEFAULTS" == true ]]; then
    configure_macos_defaults
fi

# Individual apps
if [[ "$INSTALL_CHROME" == true ]]; then
    install_chrome
fi

if [[ "$INSTALL_GHOSTTY" == true ]]; then
    install_ghostty
fi

if [[ "$INSTALL_ALACRITTY" == true ]]; then
    install_alacritty
fi

if [[ "$INSTALL_DISCORD" == true ]]; then
    install_discord
fi

if [[ "$INSTALL_SPOTIFY" == true ]]; then
    install_spotify
fi

if [[ "$INSTALL_SIGNAL" == true ]]; then
    install_signal
fi

if [[ "$INSTALL_OLLAMA" == true ]]; then
    install_ollama
fi

if [[ "$INSTALL_TAILSCALE" == true ]]; then
    install_tailscale
fi

if [[ "$INSTALL_ZOOM" == true ]]; then
    install_zoom
fi

if [[ "$INSTALL_STEAM" == true ]]; then
    install_steam
fi

if [[ "$INSTALL_DOCKER" == true ]]; then
    install_docker
fi

if [[ "$INSTALL_FONTS" == true ]]; then
    install_fonts
fi

# Individual editors
if [[ "$INSTALL_VSCODE" == true ]]; then
    install_vscode
fi

if [[ "$INSTALL_CURSOR" == true ]]; then
    install_cursor
fi

if [[ "$INSTALL_ZED" == true ]]; then
    install_zed
fi

if [[ "$INSTALL_ANTIGRAVITY" == true ]]; then
    install_antigravity
fi

if [[ "$INSTALL_GEMINI_CLI" == true ]]; then
    install_gemini_cli
fi

if [[ "$INSTALL_CODEX" == true ]]; then
    install_codex
fi

if [[ "$INSTALL_CLAUDE_CODE" == true ]]; then
    install_claude_code
fi

if [[ "$INSTALL_LAZYVIM" == true ]]; then
    install_neovim_lazyvim
fi

echo ""
echo "========================================"
echo "Installation complete!"
echo "========================================"
