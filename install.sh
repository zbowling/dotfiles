#!/bin/bash
# Dotfiles installer - creates symlinks for shell configs
# Works on: macOS, Ubuntu/Debian, Arch/CachyOS

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from: $DOTFILES_DIR"

# Backup function
backup_if_exists() {
    local file="$1"
    if [[ -e "$file" && ! -L "$file" ]]; then
        echo "  Backing up existing $file to ${file}.bak"
        mv "$file" "${file}.bak"
    elif [[ -L "$file" ]]; then
        echo "  Removing existing symlink $file"
        rm "$file"
    fi
}

# Create directories
mkdir -p ~/.config/fish
mkdir -p ~/.config/ghostty
mkdir -p ~/.config
mkdir -p ~/.ssh

# Backup directory function (for alacritty, zellij)
backup_dir_if_exists() {
    local dir="$1"
    if [[ -d "$dir" && ! -L "$dir" ]]; then
        echo "  Backing up existing $dir to ${dir}.bak"
        mv "$dir" "${dir}.bak"
    elif [[ -L "$dir" ]]; then
        echo "  Removing existing symlink $dir"
        rm "$dir"
    fi
}

# Install zsh configs
echo "Installing zsh configs..."
backup_if_exists ~/.zshrc
ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc

backup_if_exists ~/.zsh_plugins.txt
ln -sf "$DOTFILES_DIR/zsh/.zsh_plugins.txt" ~/.zsh_plugins.txt

# Install Starship config
echo "Installing Starship config..."
backup_if_exists ~/.config/starship.toml
ln -sf "$DOTFILES_DIR/starship/starship.toml" ~/.config/starship.toml

# Install fish config
echo "Installing fish config..."
backup_if_exists ~/.config/fish/config.fish
ln -sf "$DOTFILES_DIR/fish/config.fish" ~/.config/fish/config.fish

# Install Ghostty config
echo "Installing Ghostty config..."
backup_if_exists ~/.config/ghostty/config
ln -sf "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config

# Install Alacritty config (entire directory)
echo "Installing Alacritty config..."
backup_dir_if_exists ~/.config/alacritty
ln -sf "$DOTFILES_DIR/alacritty" ~/.config/alacritty

# Install Zellij config (entire directory)
echo "Installing Zellij config..."
backup_dir_if_exists ~/.config/zellij
ln -sf "$DOTFILES_DIR/zellij" ~/.config/zellij

# Install Claude Code config (merge attribution settings safely)
echo "Installing Claude Code config..."
mkdir -p ~/.claude
if command -v jq &> /dev/null; then
    # Use jq to safely merge attribution settings into existing config
    if [[ -f ~/.claude/settings.json ]]; then
        # Merge our attribution settings into existing file
        jq -s '.[0] * .[1]' ~/.claude/settings.json "$DOTFILES_DIR/claude/settings.json" > ~/.claude/settings.json.tmp
        mv ~/.claude/settings.json.tmp ~/.claude/settings.json
        echo "  Merged attribution settings into existing ~/.claude/settings.json"
    else
        # No existing file, just copy ours
        cp "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
        echo "  Created ~/.claude/settings.json"
    fi
else
    # jq not available
    if [[ ! -f ~/.claude/settings.json ]]; then
        cp "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
        echo "  Created ~/.claude/settings.json"
    else
        echo "  Warning: jq not installed, cannot safely merge Claude settings"
        echo "  Install jq (--dev) and re-run, or manually merge $DOTFILES_DIR/claude/settings.json"
    fi
fi

# Add Starship and icon-free aliases to bash (append if not already present)
echo "Patching bash config..."
if ! grep -q "starship init bash" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Override prompt with Starship (works in all terminals)" >> ~/.bashrc
    echo 'if command -v starship &> /dev/null; then' >> ~/.bashrc
    echo '  eval "$(starship init bash)"' >> ~/.bashrc
    echo 'fi' >> ~/.bashrc
    echo "  Added Starship to ~/.bashrc"
else
    echo "  Starship already in ~/.bashrc"
fi

if ! grep -q "lsi='eza" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Override eza aliases to not use icons (works in all terminals)" >> ~/.bashrc
    echo 'if command -v eza &> /dev/null; then' >> ~/.bashrc
    echo "  alias ls='eza -lh --group-directories-first'" >> ~/.bashrc
    echo "  alias lsa='ls -a'" >> ~/.bashrc
    echo "  alias lt='eza --tree --level=2 --long --git'" >> ~/.bashrc
    echo "  alias lta='lt -a'" >> ~/.bashrc
    echo "  alias lsi='eza -lh --group-directories-first --icons'" >> ~/.bashrc
    echo "  alias lti='eza --tree --level=2 --long --icons --git'" >> ~/.bashrc
    echo 'fi' >> ~/.bashrc
    echo "  Added icon-free eza aliases to ~/.bashrc"
else
    echo "  eza aliases already in ~/.bashrc"
fi

# Add 1Password SSH agent to bash (conditional - only activates if socket exists)
if ! grep -q "1password/agent.sock" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# 1Password SSH Agent (only activates if 1Password is installed)" >> ~/.bashrc
    echo 'if [[ -S ~/.1password/agent.sock ]]; then' >> ~/.bashrc
    echo '  export SSH_AUTH_SOCK=~/.1password/agent.sock' >> ~/.bashrc
    echo 'fi' >> ~/.bashrc
    echo "  Added 1Password SSH agent to ~/.bashrc (conditional)"
else
    echo "  1Password SSH agent already in ~/.bashrc"
fi

# Note: SSH config and git signing are NOT configured by default.
# Install 1Password with: ./scripts/install-packages.sh --1password
# Then the install script will configure SSH and git signing.

echo ""
echo "Dotfiles installed!"
echo ""
echo "Next steps:"
echo ""
echo "  Option A: Interactive Setup Wizard (recommended)"
echo "     $DOTFILES_DIR/scripts/setup-wizard.sh"
echo ""
echo "  Option B: Manual Setup"
echo ""
echo "  1. Install packages:"
echo "     $DOTFILES_DIR/scripts/install-packages.sh --all        # Core packages"
echo "     $DOTFILES_DIR/scripts/install-packages.sh --extra      # Everything"
echo ""
echo "  2. Set up git and GitHub:"
echo "     $DOTFILES_DIR/scripts/install-packages.sh --init-git"
echo ""
echo "  3. Install Antidote (zsh plugin manager):"
echo "     git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote"
echo ""
echo "  4. Set zsh as your default shell:"
echo "     chsh -s \$(which zsh)"
echo ""
echo "  5. Open a new terminal or run: source ~/.zshrc"
echo ""
echo "  See full checklist: $DOTFILES_DIR/scripts/post-install-checklist.sh"
