# AGENTS.md

Instructions for AI coding assistants (Claude Code, Cursor, GitHub Copilot, etc.) working with this repository.

## Project Overview

Personal dotfiles repository for cross-platform shell and terminal configuration. Supports:
- **macOS** (Homebrew)
- **Ubuntu/Debian** (apt)
- **Arch/CachyOS** (pacman, paru, yay)

## Guiding Principles

These principles guide all development on this repository:

1. **Non-destructive** - Never corrupt the user's machine or break their setup. Warn about potential conflicts (Oh-My-Zsh, Prezto, etc.) before making changes. Backup existing configs with `.bak` files.

2. **Safe installation** - Look before leaping. Check if packages/commands already exist before installing. Verify paths exist before creating symlinks. Use `command -v` and file existence checks.

3. **Backup and ask permission** - Preserve existing configurations. The install script backs up existing files to `.bak` before replacing. Never silently overwrite user customizations.

4. **DRY utilities** - Use helper functions from `scripts/lib/common.sh` to avoid repetitive code. Patterns like installation checks, dry-run handling, and status messages should use shared helpers.

5. **Portable and friendly code** - Works on macOS, Ubuntu/Debian, and Arch. Use bash (not zsh-specific syntax in scripts). Clear progress messages. Handle missing dependencies gracefully.

6. **Always test changes** - Run `./tests/run-tests.sh` before committing. CI runs tests on Ubuntu, Arch, and macOS. Add new test cases for new features.

7. **Idempotent** - Running the install script twice should be safe and produce the same result. Users may re-run to pick up new features. Never duplicate entries or break existing configs.

## Key Concepts

### Symlink-based Configuration
The `install.sh` script creates symlinks from `~/.config/` and `~/` to files in this repo. Config files are stored in subdirectories (e.g., `config/zsh/.zshrc`, `starship/starship.toml`).

### Cross-platform Package Installation
The `scripts/install-packages.sh` script detects the OS and uses the appropriate package manager. Individual installers are in `scripts/lib/`.

### ASCII-safe by Default
All prompts and aliases avoid Nerd Font glyphs by default to work in any terminal. Icon variants (like `lsi`, `lti`) are available for terminals with Nerd Fonts.

## Directory Structure

```
dotfiles/
├── config/                    # XDG Base Directory configs
│   ├── zsh/
│   │   ├── .zshenv           # Environment (loaded for ALL sessions)
│   │   ├── .zshrc            # Interactive shells
│   │   ├── .zprofile         # Login shells (macOS)
│   │   └── rc.d/             # Modular configs (manually sourced)
│   │       ├── 00-path.zsh
│   │       ├── 10-history.zsh
│   │       ├── 15-environment.zsh
│   │       ├── 20-plugins.zsh      # Auto-installs antidote
│   │       ├── 30-tools.zsh
│   │       ├── 40-aliases.zsh
│   │       ├── 50-keybindings.zsh
│   │       └── 99-completion.zsh
│   ├── bash/
│   │   └── rc.d/             # Modular configs (manually sourced)
│   │       ├── 00-path.bash
│   │       ├── 10-history.bash
│   │       ├── 15-environment.bash
│   │       ├── 30-tools.bash
│   │       └── 40-aliases.bash
│   └── fish/
│       ├── config.fish       # Main config (runs AFTER conf.d/)
│       └── conf.d/           # Modular configs (AUTO-LOADED!)
│           ├── 00-path.fish
│           ├── 15-environment.fish
│           ├── 30-tools.fish
│           ├── 40-aliases.fish
│           └── 99-greeting.fish
├── home/                      # Bootstrap files for ~/
│   ├── dot_zshenv            # Sets ZDOTDIR → ~/.config/zsh
│   └── dot_bashrc_append     # Appended to ~/.bashrc
├── starship/                  # Starship prompt config
├── ghostty/                   # Ghostty terminal config
├── alacritty/                 # Alacritty terminal config
├── ssh/                       # SSH config (1Password agent)
├── scripts/
│   ├── install-packages.sh   # Main package installer
│   ├── setup-wizard.sh       # Interactive TUI installer
│   └── lib/
│       ├── detect-os.sh      # OS detection (is_macos, is_debian, is_arch, is_fedora)
│       ├── common.sh         # DRY helpers (run_cmd, pkg_install, sudo_cmd, check_installed)
│       ├── sudo-helper.sh    # Sudo credential caching
│       ├── packages-cli.sh   # CLI tools + 1Password
│       ├── packages-dev.sh   # Dev tools (compilers, build tools)
│       ├── packages-apps.sh  # Desktop applications
│       ├── packages-editors.sh # IDEs (VSCode, Cursor, Zed, Claude Code)
│       └── install-runtimes.sh # Language runtimes (mise, nvm, rustup)
├── tests/                     # Docker-based integration tests
│   ├── run-tests.sh          # Test runner
│   ├── test-install.sh       # Test validation script
│   ├── Dockerfile.ubuntu     # Ubuntu 24.04 test container
│   └── Dockerfile.arch       # Arch Linux test container
└── install.sh                 # Main installer (use -i for interactive)
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
Create a new install function using the DRY helpers from `common.sh`:

```bash
install_newapp() {
    print_section "Installing NewApp"

    # Use helpers for installation checks (handles dry-run automatically)
    require_app_not_installed "NewApp" "NewApp" || return
    require_not_installed newapp "NewApp" || return

    if is_macos; then
        brew install --cask newapp
    elif is_debian; then
        # Prefer: apt repo > .deb download > snap
        pkg_install newapp
    elif is_arch; then
        # Use aur_install for AUR packages
        aur_install newapp-bin
    fi

    status_success "NewApp"
}
```

Then:
1. Add to `install_all_apps()` function
2. Add flag in `install-packages.sh` (variable, case statement, help text, install call)
3. Update README.md apps table

## Helper Functions

### OS Detection (detect-os.sh)
- `is_macos` - Returns true on macOS
- `is_debian` - Returns true on Ubuntu/Debian
- `is_arch` - Returns true on Arch/CachyOS/Manjaro
- `is_fedora` - Returns true on Fedora/RHEL/CentOS
- `pkg_install <package>` - Install using detected package manager
- `$PKG_MANAGER` - Current package manager (brew, apt, pacman, paru, yay, dnf)
- `$PKG_INSTALL` - Install command (e.g., `sudo apt install -y`)
- `$PKG_UPDATE` - Update command (e.g., `sudo apt update`)

### DRY Helpers (common.sh)
**IMPORTANT**: Use these to avoid repetitive code

**Installation Checks** (return 1 to skip, 0 to proceed):
- `require_not_installed <cmd> [name]` - Check command, handle dry-run. Use with `|| return`
- `require_app_not_installed <app> [name]` - Check macOS .app bundle
- `require_not_installed_app <cmd> <app> [name]` - Combined check

**Package Installation**:
- `pkg_install <packages...>` - Install via detected package manager
- `aur_install <pkg>` - Install from AUR (handles paru/yay)
- `setup_apt_repo <name> <key_url> <key_path> <repo_line> <list_path>` - Idempotent apt repo setup

**Command Execution**:
- `run_cmd <cmd>` - Execute or show dry-run
- `sudo_cmd <cmd>` - Sudo with dry-run support
- `download_file <url> <dest>` - Download with dry-run

**Status Messages**:
- `print_section <title>` - Print section header
- `status_success <name>` - Print "✓ X installed"
- `status_skip <name> [reason]` - Print "⊘ X (reason)"

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
Edit `config/zsh/rc.d/40-aliases.zsh`, `config/bash/rc.d/40-aliases.bash`, and `config/fish/conf.d/40-aliases.fish` to add the alias to all shells.

### Add a new zsh plugin
Add the plugin to `config/zsh/.zsh_plugins.txt` using Antidote format:
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

## Critical Implementation Details

### XDG Base Directory Structure
We use XDG Base Directory specification (`~/.config/`) for all shell configs:
- **Zsh**: Uses `ZDOTDIR` set by `~/.zshenv` bootstrap file → all configs in `~/.config/zsh/`
- **Bash**: No native XDG support, we append loader to `~/.bashrc` → configs in `~/.config/bash/`
- **Fish**: Native XDG support → configs in `~/.config/fish/` (auto-loads `conf.d/`)

### Modular Configuration (rc.d/ and conf.d/)
Configs are split into numbered modules (00-99) for organization:
- **00-09**: Core setup (PATH, environment)
- **10-19**: History and settings
- **20-29**: Plugin managers (antidote auto-installs here)
- **30-39**: Tool integrations (mise, zoxide, starship, atuin)
- **40-49**: Aliases and functions
- **50-89**: User customizations
- **90-99**: Completion and finalization

**Fish auto-loads conf.d/** - Zsh/Bash manually source rc.d/ files in `.zshrc`/`.bashrc`

### Antidote Plugin Manager
**CRITICAL**: Antidote auto-installs on first zsh run via `config/zsh/rc.d/20-plugins.zsh`
- Do NOT tell users to manually install antidote
- Do NOT add antidote installation to install scripts
- It handles itself automatically

### Package Installation Best Practices

#### Use Official Repositories
**NEVER** hardcode version numbers or download specific package versions.
**ALWAYS** use official package repositories:

```bash
# ✅ CORRECT - Cursor via official repository
curl -fsSL https://downloads.cursor.com/keys/anysphere.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/cursor.gpg > /dev/null
echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/cursor.gpg] https://downloads.cursor.com/aptrepo stable main" | sudo tee /etc/apt/sources.list.d/cursor.list
sudo apt update && sudo apt install -y cursor

# ❌ WRONG - Hardcoded version
curl -fsSL -o cursor.deb "https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.3"
```

#### Prefer Package Formats
- **Debian/Ubuntu**: Use apt repositories, fallback to .deb
- **Fedora/RHEL**: Use dnf repositories, fallback to .rpm
- **Arch/CachyOS**: Use AUR packages (via paru/yay), fallback to pacman
- **Avoid AppImages** when native packages exist (causes permission/integration issues)

#### Use DRY Helpers
```bash
# ✅ CORRECT
if check_installed cursor; then return; fi
status_installing "Cursor"
pkg_install cursor
status_success "Cursor"

# ❌ WRONG - Repetitive
if command -v cursor &> /dev/null; then
    if [[ "$DRY_RUN" == true ]]; then
        echo "[SKIP] Cursor (already installed)"
        return
    fi
    echo "Cursor already installed"
    return
fi
```

### Interactive Mode
`./install.sh -i` launches the setup wizard (`scripts/setup-wizard.sh`)
- Never duplicate wizard functionality in install.sh
- Keep install.sh simple and fast for non-interactive use

## Important Notes

- Never commit secrets or API keys
- The `.gitignore` excludes `.env` files and `.zcompdump*`
- 1Password integration requires manual setup after install
- Some AUR packages require an AUR helper (paru or yay)
- Steam requires multilib repo on Arch
- Docker requires logout/login after install for group permissions
- `.zcompdump` is generated, should never be committed
