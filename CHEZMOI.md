# Chezmoi Integration

This dotfiles repository supports two approaches:

1. **Traditional (symlinks)**: Quick setup using `install.sh` + `install-packages.sh`
2. **Chezmoi (state-based)**: For multi-machine sync and templated configs

## Why Chezmoi?

| Feature | Symlinks | Chezmoi |
|---------|----------|---------|
| Setup speed | Fast | Fast |
| Multi-machine sync | Manual | Automatic |
| Machine-specific configs | Scripts | Templates |
| Secrets management | Manual | Built-in (1Password, age) |
| Track changes | Git diff | `chezmoi diff` |
| Rollback | Git checkout | `chezmoi apply` |

**Use symlinks if**: You have one machine or prefer simplicity.

**Use chezmoi if**: You have multiple machines with different configs, need secrets management, or want declarative dotfiles.

## Quick Start with Chezmoi

### Option A: Bootstrap from this repo (already cloned)

```bash
./scripts/chezmoi-bootstrap.sh --apply
```

### Option B: One-liner on a new machine

```bash
# Replace 'zbowling' with your GitHub username
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply zbowling
```

### Option C: Migrate existing dotfiles

```bash
./scripts/chezmoi-bootstrap.sh --migrate
```

## How It Works

### Directory Structure

```
dotfiles/
├── chezmoi/                    # Chezmoi source (optional)
│   ├── .chezmoiscripts/        # Scripts run during apply
│   │   ├── run_once_before_00_install-prerequisites.sh.tmpl
│   │   ├── run_once_01_install-packages.sh.tmpl
│   │   └── run_once_after_99_post-install.sh.tmpl
│   ├── .chezmoidata.toml       # Default configuration
│   ├── .chezmoi.toml.tmpl      # Per-machine config template
│   └── .chezmoiignore          # Files to skip
├── scripts/
│   ├── install-packages.sh     # Package installer (works standalone)
│   └── chezmoi-bootstrap.sh    # Chezmoi setup helper
└── zsh/, fish/, starship/...   # Actual dotfiles
```

### Script Execution Order

When you run `chezmoi apply`, scripts execute in this order:

1. `run_once_before_00_*` - Install prerequisites (git, curl)
2. `run_once_01_*` - Install packages using our installer
3. (dotfiles are applied here)
4. `run_once_after_99_*` - Post-install (Antidote, git config)

Scripts with `run_once_` only execute once per machine (tracked by hash).

### Configuration via Templates

Chezmoi uses Go templates for machine-specific configs:

```go
{{ if eq .chezmoi.os "darwin" }}
# macOS-specific config
{{ else if eq .chezmoi.os "linux" }}
# Linux-specific config
{{ end }}
```

Available variables (see `chezmoi data`):
- `.chezmoi.os` - darwin, linux, windows
- `.chezmoi.hostname` - Machine hostname
- `.chezmoi.osRelease.id` - ubuntu, arch, fedora, etc.

### Per-Machine Configuration

Override defaults in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    install_cli = true
    install_dev = true
    install_runtimes = true
    install_apps = true
    install_1password = true
    install_docker = false
    install_tailscale = true
    configure_git = true
```

## Daily Workflow

### Edit a dotfile

```bash
chezmoi edit ~/.zshrc           # Opens in $EDITOR
chezmoi edit --apply ~/.zshrc   # Edit and apply immediately
```

### See pending changes

```bash
chezmoi diff                    # Show what would change
chezmoi status                  # Summary of changes
```

### Apply changes

```bash
chezmoi apply                   # Apply all changes
chezmoi apply -n                # Dry run (show what would happen)
```

### Pull and apply from git

```bash
chezmoi update                  # git pull + apply
```

### Manage source directory

```bash
chezmoi cd                      # Open shell in source dir
chezmoi source-path             # Print source path
chezmoi managed                 # List all managed files
```

## Adding New Dotfiles

### Add a file

```bash
chezmoi add ~/.bashrc
```

### Add as template (for machine-specific configs)

```bash
chezmoi add --template ~/.gitconfig
```

### Add entire directory

```bash
chezmoi add ~/.config/nvim
```

## Re-running Scripts

Scripts with `run_once_` only run once. To re-run:

```bash
# Re-run a specific script
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply

# Or edit the script (changes its hash, triggering re-run)
chezmoi edit ~/.local/share/chezmoi/.chezmoiscripts/run_once_01_install-packages.sh.tmpl
```

## Secrets with 1Password

If you use 1Password, you can reference secrets in templates:

```go
[user]
    signingkey = {{ onepasswordRead "op://Personal/SSH Key/public key" }}
```

Configure in `~/.config/chezmoi/chezmoi.toml`:

```toml
[onepassword]
    prompt = true
```

## Without Chezmoi (Traditional Approach)

You can still use the traditional symlink approach:

```bash
./install.sh                           # Create symlinks
./scripts/install-packages.sh --all    # Install packages
./scripts/install-packages.sh --init-git
```

The package installer works completely independently of chezmoi.

## Comparison: Symlinks vs Chezmoi

### Symlinks (install.sh)

```
~/.zshrc -> ~/projects/dotfiles/zsh/.zshrc
```

- Files stay in repo, symlinked to home
- Edit either location, changes sync via git
- Simple but less flexible

### Chezmoi

```
~/.local/share/chezmoi/dot_zshrc -> generates ~/.zshrc
```

- Source files with special prefixes (dot_, executable_, private_)
- Templates processed on apply
- More features but slight learning curve

## Troubleshooting

### Reset chezmoi state

```bash
chezmoi state reset               # Clear all state (careful!)
rm -rf ~/.local/share/chezmoi     # Remove source entirely
chezmoi init --apply zbowling     # Start fresh
```

### Debug templates

```bash
chezmoi execute-template '{{ .chezmoi.os }}'
chezmoi cat ~/.zshrc              # Show what would be generated
```

### See what chezmoi knows

```bash
chezmoi data                      # All template variables
chezmoi doctor                    # Health check
chezmoi dump                      # Full state dump
```

## Resources

- [Chezmoi Quick Start](https://www.chezmoi.io/quick-start/)
- [Templating Guide](https://www.chezmoi.io/user-guide/templating/)
- [Scripts Documentation](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)
- [1Password Integration](https://www.chezmoi.io/user-guide/password-managers/1password/)
