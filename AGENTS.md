# AGENTS.md

Instructions for AI coding assistants (Claude Code, Cursor, GitHub Copilot, etc.) working with this repository.

## Project Overview

Personal dotfiles repository for cross-platform shell and terminal configuration. Supports:
- **macOS** (Homebrew)
- **Ubuntu/Debian** (apt)
- **Arch/CachyOS** (pacman, paru, yay)

## Key Concepts

### Symlink-based Configuration
The `install.sh` script creates symlinks from `~/.config/` and `~/` to files in this repo. Config files are stored in subdirectories by tool name (e.g., `zsh/.zshrc`, `starship/starship.toml`).

### Cross-platform Package Installation
The `scripts/install-packages.sh` script detects the OS and uses the appropriate package manager. Individual installers are in `scripts/lib/`.

### ASCII-safe by Default
All prompts and aliases avoid Nerd Font glyphs by default to work in any terminal. Icon variants (like `lsi`, `lti`) are available for terminals with Nerd Fonts.

## Directory Structure

```
dotfiles/
├── zsh/                    # Zsh shell config
├── fish/                   # Fish shell config
├── bash/                   # Bash overrides
├── starship/               # Starship prompt config
├── ghostty/                # Ghostty terminal config
├── alacritty/              # Alacritty terminal config
├── ssh/                    # SSH config (1Password agent)
├── scripts/
│   ├── install-packages.sh # Main installer entry point
│   └── lib/
│       ├── detect-os.sh    # OS detection helpers
│       ├── packages-cli.sh # CLI tools + 1Password
│       ├── packages-dev.sh # Dev tools (compilers, build tools)
│       ├── packages-apps.sh # Desktop applications
│       └── install-runtimes.sh # Language runtimes
├── tests/                  # Docker-based integration tests
│   ├── run-tests.sh        # Test runner
│   ├── test-install.sh     # Test validation script
│   ├── Dockerfile.ubuntu   # Ubuntu 24.04 test container
│   └── Dockerfile.arch     # Arch Linux test container
└── install.sh              # Symlink installer
```

## Adding New Packages

### CLI Tools (packages-cli.sh)
Add to the `common_packages` array if the package name is the same across all package managers:
```bash
local common_packages=(
    git
    curl
    your-new-package  # Add here
)
```

For OS-specific packages, add to the appropriate `is_macos`/`is_debian`/`is_arch` block.

### Desktop Apps (packages-apps.sh)
Create a new install function following this pattern:

```bash
install_newapp() {
    echo ""
    echo "=== Installing NewApp ==="
    echo ""

    if is_macos; then
        if ! [[ -d "/Applications/NewApp.app" ]]; then
            brew install --cask newapp
        else
            echo "NewApp already installed"
        fi
    elif is_debian; then
        if ! command -v newapp &> /dev/null; then
            # Install via apt repo, deb download, or snap
        else
            echo "NewApp already installed"
        fi
    elif is_arch; then
        if ! command -v newapp &> /dev/null; then
            # pacman for community, paru/yay for AUR
            sudo pacman -S --noconfirm --needed newapp
        else
            echo "NewApp already installed"
        fi
    fi
}
```

Then:
1. Add to `install_all_apps()` function
2. Add flag in `install-packages.sh` (variable, case statement, help text, install call)
3. Update README.md apps table

## Helper Functions (detect-os.sh)

Available in all lib scripts:
- `is_macos` - Returns true on macOS
- `is_debian` - Returns true on Ubuntu/Debian
- `is_arch` - Returns true on Arch/CachyOS
- `pkg_install <package>` - Install using detected package manager
- `$PKG_MANAGER` - Current package manager (brew, apt, pacman, paru, yay)
- `$PKG_INSTALL` - Install command (e.g., `sudo apt install -y`)
- `$PKG_UPDATE` - Update command (e.g., `sudo apt update`)

## Testing

Run Docker-based integration tests:
```bash
./tests/run-tests.sh          # Test on all distros
./tests/run-tests.sh ubuntu   # Test on Ubuntu only
./tests/run-tests.sh arch     # Test on Arch only
```

Tests validate:
- Symlinks created correctly
- Shell configs have valid syntax
- Runtimes installed to expected paths
- Git signing configured
- SSH config present

When adding new features, consider adding validation to `tests/test-install.sh`.

## Common Tasks

### Add a new shell alias
Edit `zsh/.zshrc` and `fish/config.fish` to add the alias to both shells.

### Add a new zsh plugin
Add the plugin to `zsh/.zsh_plugins.txt` using Antidote format:
```
ohmyzsh/ohmyzsh path:plugins/pluginname
```

### Modify the prompt
Edit `starship/starship.toml`. Keep it ASCII-safe (use `>` not fancy glyphs).

### Add apt/brew repository
In install functions, check if repo exists before adding:
```bash
if [[ ! -f /etc/apt/sources.list.d/example.list ]]; then
    # Add GPG key and repo
    sudo apt update
fi
```

## Code Style

- Use `#!/bin/bash` shebang
- Use `[[ ]]` for conditionals (not `[ ]`)
- Quote variables: `"$var"` not `$var`
- Use `command -v` to check if command exists
- Add `echo` statements to show progress
- Check if already installed before installing
- Clean up temp files after downloads

## Important Notes

- Never commit secrets or API keys
- The `.gitignore` excludes `.env` files
- 1Password integration requires manual setup after install
- Some AUR packages require an AUR helper (paru or yay)
- Steam requires multilib repo on Arch
- Docker requires logout/login after install for group permissions
