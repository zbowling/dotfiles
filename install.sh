#!/bin/bash
# Dotfiles installer - XDG Base Directory compliant
# Works on: macOS, Ubuntu/Debian, Arch/CachyOS

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Parse arguments
INTERACTIVE=false
if [[ "$1" == "--interactive" ]] || [[ "$1" == "-i" ]]; then
    INTERACTIVE=true
fi

# If interactive mode, run wizard
if [[ "$INTERACTIVE" == true ]]; then
    exec "$DOTFILES_DIR/scripts/setup-wizard.sh"
fi

# Colors
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m'

echo "========================================="
echo "Dotfiles Installer"
echo "========================================="
echo "From: $DOTFILES_DIR"
echo "To: $XDG_CONFIG_HOME"
echo ""
echo "Tip: Use './install.sh -i' for guided setup"
echo ""

# Backup function - returns 0 even when nothing to backup (for set -e compatibility)
backup_if_exists() {
    if [[ -e "$1" && ! -L "$1" ]]; then
        cp "$1" "${1}.bak" && echo -e "  ${GREEN}✓${NC} Backed up $1"
    fi
    if [[ -L "$1" ]]; then
        rm "$1"
    fi
    return 0
}

backup_dir_if_exists() {
    if [[ -d "$1" && ! -L "$1" ]]; then
        mv "$1" "${1}.bak" && echo -e "  ${GREEN}✓${NC} Backed up $1"
    fi
    if [[ -L "$1" ]]; then
        rm "$1"
    fi
    return 0
}

# Create directories
echo "Creating directories..."
mkdir -p "$XDG_CONFIG_HOME"/{zsh,bash,fish,ghostty} ~/.ssh
echo -e "${GREEN}✓${NC} Directories created"
echo ""

# Install Zsh (XDG-compliant with ZDOTDIR)
echo "Installing zsh configs..."
backup_if_exists ~/.zshenv
ln -sf "$DOTFILES_DIR/home/dot_zshenv" ~/.zshenv
backup_dir_if_exists "$XDG_CONFIG_HOME/zsh"
ln -sfn "$DOTFILES_DIR/config/zsh" "$XDG_CONFIG_HOME/zsh"
# Note: .zsh_plugins.txt is inside config/zsh/ and accessed via ZDOTDIR
echo -e "${GREEN}✓${NC} Zsh configs installed"
echo ""

# Install Bash (XDG-style, appended to ~/.bashrc)
echo "Installing bash configs..."
backup_dir_if_exists "$XDG_CONFIG_HOME/bash"
ln -sfn "$DOTFILES_DIR/config/bash" "$XDG_CONFIG_HOME/bash"
if ! grep -q "XDG_CONFIG_HOME.*bash/rc.d" ~/.bashrc 2>/dev/null; then
    backup_if_exists ~/.bashrc
    cat "$DOTFILES_DIR/home/dot_bashrc_append" >> ~/.bashrc
    echo -e "${GREEN}✓${NC} Bash configs installed"
else
    echo -e "${BLUE}ℹ${NC} Bash already configured"
fi
echo ""

# Install Fish (native XDG support)
echo "Installing fish configs..."
backup_if_exists "$XDG_CONFIG_HOME/fish/config.fish"
ln -sf "$DOTFILES_DIR/config/fish/config.fish" "$XDG_CONFIG_HOME/fish/config.fish"
backup_dir_if_exists "$XDG_CONFIG_HOME/fish/conf.d"
ln -sfn "$DOTFILES_DIR/config/fish/conf.d" "$XDG_CONFIG_HOME/fish/conf.d"
echo -e "${GREEN}✓${NC} Fish configs installed"
echo ""

# Install other configs
echo "Installing other configs..."
backup_if_exists "$XDG_CONFIG_HOME/starship.toml"
ln -sf "$DOTFILES_DIR/starship/starship.toml" "$XDG_CONFIG_HOME/starship.toml"
backup_if_exists "$XDG_CONFIG_HOME/ghostty/config"
ln -sf "$DOTFILES_DIR/ghostty/config" "$XDG_CONFIG_HOME/ghostty/config"
backup_dir_if_exists "$XDG_CONFIG_HOME/alacritty"
ln -sfn "$DOTFILES_DIR/alacritty" "$XDG_CONFIG_HOME/alacritty"
backup_dir_if_exists "$XDG_CONFIG_HOME/zellij"
ln -sfn "$DOTFILES_DIR/zellij" "$XDG_CONFIG_HOME/zellij"
echo -e "${GREEN}✓${NC} All configs installed"
echo ""

# Claude Code config (merge if exists)
mkdir -p ~/.claude
if command -v jq &> /dev/null && [[ -f ~/.claude/settings.json ]]; then
    jq -s '.[0] * .[1]' ~/.claude/settings.json "$DOTFILES_DIR/claude/settings.json" > ~/.claude/settings.json.tmp
    mv ~/.claude/settings.json.tmp ~/.claude/settings.json
    echo -e "${GREEN}✓${NC} Claude settings merged"
elif [[ ! -f ~/.claude/settings.json ]]; then
    cp "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
    echo -e "${GREEN}✓${NC} Claude settings created"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Dotfiles Installed${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo ""
echo "  1. Install packages (guided):"
echo "     ./install.sh -i"
echo ""
echo "  2. Or install manually:"
echo "     ./scripts/install-packages.sh --all"
echo ""
echo "  3. Open new terminal or: exec zsh"
echo "     (Antidote will auto-install on first run)"
echo ""
