# Zac Bowling's Dotfiles

My personal favorite shell and terminal configuration. Cross-platform: macOS, Ubuntu/Debian, Arch/CachyOS.

Two approaches available to use this:
- **Traditional** - Symlinks via `install.sh` (simple, fast) - great if you just want to use what I use.
- **Chezmoi** - A dotfile syncing system that has state-based management (multi-machine sync, templates)

## What's included

**🎯 One-command setup** - Interactive wizard (`setup-wizard.sh`) or simple flags (`--all`, `--extra`) to install everything you need

**🌍 Truly cross-platform** - Works seamlessly on macOS (Homebrew), Ubuntu/Debian (apt), and Arch/CachyOS (pacman). Same commands, same configs, everywhere while uses the system package manager

**⚡ Modern shell experience** - zsh with Antidote plugins, fish for experimentation, Starship prompt (ASCII-safe, works in any terminal), plus Zellij multiplexer

**🖥️ Beautiful terminals** - Pre-configured Ghostty and Alacritty with ristretto theme, optimized for productivity

**🛠️ Complete dev environment** - Installs 20+ CLI tools (eza, fzf, zoxide, bat, ripgrep, lazygit, etc.), dev tools (compilers, build systems), runtimes (mise, uv, rustup, nvm), and your choice of editors (VS Code, Cursor, Zed, Neovim)

**📦 Desktop apps** - One-command installs for Chrome, Discord, Spotify, Signal, Ollama, Steam, Zoom, and more

**🔐 Security built-in** - 1Password SSH agent integration, git commit signing, secure defaults

**🤖 Production-ready** - Docker-based integration tests, automated linting, CI/CD on GitHub Actions. This isn't just configs—it's a maintained system.

**🔄 Multi-machine sync** - Choose traditional symlinks for simplicity, or Chezmoi for state-based management across multiple machines

## Quick install

```bash
# Clone
git clone https://github.com/zbowling/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles

# Create symlinks
./install.sh

# Option A: Interactive setup wizard (recommended)
./scripts/setup-wizard.sh

# Option B: Manual setup
./scripts/install-packages.sh --all        # Core packages
./scripts/install-packages.sh --init-git   # Git user + GitHub auth
./scripts/install-packages.sh --extra      # Everything including dev editors

# Install Antidote (zsh plugin manager)
git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote

# Set zsh as default
chsh -s $(which zsh)

# See what else needs doing
./scripts/post-install-checklist.sh
```

## Alternative: Chezmoi

For multi-machine setups or if you prefer declarative dotfile management:

```bash
# Option A: Bootstrap from this repo
./scripts/chezmoi-bootstrap.sh --apply

# Option B: One-liner on a new machine (replace username)
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply zbowling

# Daily workflow
chezmoi edit ~/.zshrc   # Edit a dotfile
chezmoi diff            # See pending changes
chezmoi apply           # Apply changes
chezmoi update          # Pull and apply from git
```

See [CHEZMOI.md](CHEZMOI.md) for full documentation.

## Package Categories

### CLI Tools (`--cli`)

| Tool | Description |
|------|-------------|
| eza | Modern ls replacement |
| fzf | Fuzzy finder |
| zoxide | Smart cd |
| bat | Cat with syntax highlighting |
| ripgrep | Fast grep |
| fd | Fast find |
| btop | Resource monitor |
| neovim | Text editor |
| lazygit | Git TUI |
| lazydocker | Docker TUI |
| gh | GitHub CLI |
| atuin | Shell history sync |
| delta | Better git diffs |
| httpie | Better curl for APIs |
| gum | TUI components |
| tldr | Simplified man pages |

### Dev Tools (`--dev`)

| Tool | Description |
|------|-------------|
| bun | Fast JavaScript runtime (preferred over Node) |
| cmake | Build system |
| gcc/clang | C/C++ compilers |
| llvm | Compiler infrastructure |
| pkg-config | Library helper |
| ccache | Compiler cache |
| jq | JSON processor for CLI |

### Runtimes (`--runtimes`)

| Tool | Description |
|------|-------------|
| mise | Polyglot version manager |
| uv | Fast Python package manager |
| nvm | Node version manager |
| rustup | Rust toolchain |

### Desktop Apps (`--apps`)

| App | Flag | Description |
|-----|------|-------------|
| Chrome | `--chrome` | Google Chrome browser |
| Ghostty | `--ghostty` | GPU-accelerated terminal |
| Alacritty | `--alacritty` | Cross-platform terminal |
| Discord | `--discord` | Voice/text chat |
| Spotify | `--spotify` | Music streaming |
| Signal | `--signal` | Encrypted messenger |
| Ollama | `--ollama` | Local LLM server |
| Zoom | `--zoom` | Video conferencing |
| Steam | `--steam` | Gaming platform |

### Dev Editors (`--dev-editor`)

| App | Flag | Description |
|-----|------|-------------|
| VS Code | `--vscode` | Visual Studio Code |
| Cursor | `--cursor` | AI-powered code editor |
| Zed | `--zed` | High-performance editor |
| Antigravity | `--antigravity` | Google AI IDE |
| Gemini CLI | `--gemini-cli` | Google Gemini CLI |
| Codex | `--codex` | OpenAI Codex CLI |
| Claude Code | `--claude-code` | Anthropic Claude CLI |
| LazyVim | `--lazyvim` | Neovim + LazyVim |

### Optional Extras (`--extra` or install individually)

The `--extra` flag installs everything: `--all` + `--dev-editor` + these extras:

| App | Flag | Description |
|-----|------|-------------|
| 1Password | `--1password` | Password manager + SSH agent + git signing |
| Docker | `--docker` | Container engine (Desktop on macOS) |
| Tailscale | `--tailscale` | VPN mesh network |
| Fonts | `--fonts` | Nerd Fonts (CascadiaMono, JetBrains Mono) |

### Git Configuration (`--init-git`)

Interactive git setup that:
- Prompts for `user.name` and `user.email` if not set
- Configures recommended git defaults:
  - `merge.conflictStyle = diff3` (better conflict markers)
  - `pull.ff = only` (prevent accidental merge commits)
  - `rebase.autosquash = true` (auto-squash fixup commits)
  - `rerere.enabled = true` (reuse recorded resolutions)
- Authenticates with GitHub CLI (`gh auth login`)

### macOS Defaults (`--macos-defaults`)

Configures macOS system preferences:

**Screenshots:**
- Creates `~/Desktop/Screenshots` folder
- Saves screenshots there (instead of cluttering Desktop)
- Uses PNG format

**Finder:**
- Shows hidden files
- Shows all file extensions
- Shows path bar and status bar
- Keeps folders on top when sorting
- Searches current folder by default

## Structure

```
dotfiles/
├── zsh/
│   ├── .zshrc              # Main zsh config
│   └── .zsh_plugins.txt    # Antidote plugin list
├── fish/
│   └── config.fish         # Fish shell config
├── bash/
│   └── .bashrc.local       # Bash overrides
├── starship/
│   └── starship.toml       # Prompt config (ASCII-safe)
├── ghostty/
│   └── config              # Ghostty terminal config
├── alacritty/              # Alacritty terminal config (ristretto theme)
├── zellij/
│   ├── config.kdl          # Zellij multiplexer config
│   └── themes/             # Zellij themes (ristretto)
├── ssh/
│   └── config              # SSH config (1Password agent)
├── scripts/
│   ├── install-packages.sh    # Cross-platform package installer
│   ├── setup-wizard.sh        # Interactive setup wizard (gum TUI)
│   ├── post-install-checklist.sh # Generate checklist
│   ├── chezmoi-bootstrap.sh   # Chezmoi setup helper
│   └── lib/
│       ├── detect-os.sh       # OS detection helpers
│       ├── sudo-helper.sh     # Sudo credential caching
│       ├── packages-cli.sh    # CLI tools + 1Password
│       ├── packages-dev.sh    # Dev tools + Bun
│       ├── packages-apps.sh   # Desktop apps
│       ├── packages-editors.sh # Dev editors
│       ├── git-config.sh      # Git configuration + delta
│       ├── ssh-setup.sh       # SSH key generation
│       ├── macos-defaults.sh  # macOS system preferences
│       └── install-runtimes.sh
├── chezmoi/                # Chezmoi templates (optional)
│   ├── .chezmoiscripts/    # Run-once installation scripts
│   ├── .chezmoidata.toml   # Default configuration
│   └── .chezmoiignore      # Files to skip
├── tests/                  # Docker-based integration tests
├── install.sh              # Symlink installer
├── AGENTS.md               # AI assistant instructions
├── CHEZMOI.md              # Chezmoi integration guide
├── TAILSCALE.md            # Tailscale setup guide
└── LICENSE                 # BSD 2-Clause
```

## 1Password Integration

After installing 1Password (`--1password`), complete the setup:

1. Open 1Password and sign in
2. **Settings > Developer > Integrate with 1Password CLI**
3. **Settings > Developer > Set Up SSH Agent**
4. Add your SSH key to GitHub/GitLab as a signing key
5. In 1Password, click your SSH key > **Configure Commit Signing**

The dotfiles automatically configure:
- `SSH_AUTH_SOCK` pointing to 1Password agent (all shells)
- `~/.ssh/config` with `IdentityAgent` setting
- Git config for SSH commit signing

## Development

### Linting

Run linters locally before committing:

```bash
./scripts/lint.sh        # Run all linters
./scripts/lint.sh --fix  # Auto-fix where possible
```

Linters used:
- **ShellCheck** - Shell script static analysis
- **shfmt** - Shell script formatting
- **markdownlint** - Markdown formatting
- **yamllint** - YAML validation

### Testing

Run Docker-based integration tests:

```bash
./tests/run-tests.sh          # Test on Ubuntu and Arch
./tests/run-tests.sh ubuntu   # Test on Ubuntu 24.04 only
./tests/run-tests.sh arch     # Test on Arch Linux only
```

### CI/CD

GitHub Actions automatically runs on push/PR:
- **Lint** - ShellCheck, shfmt, markdownlint, yamllint
- **Test (Ubuntu)** - Docker-based full test suite
- **Test (Arch)** - Docker-based full test suite
- **Test (macOS)** - Native macOS runner (install.sh, CLI, dev, runtimes)

## Notes

- `ls` uses eza without icons by default (works in all terminals)
- Use `lsi` or `lti` for icon variants (requires Nerd Font)
- Prompt uses `>` character instead of Nerd Font glyphs
- See [AGENTS.md](AGENTS.md) for AI assistant instructions
