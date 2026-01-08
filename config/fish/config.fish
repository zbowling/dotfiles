# ~/.config/fish/config.fish - Main fish configuration
# Managed by dotfiles - Uses XDG Base Directory specification (native to fish!)

# Fish natively uses ~/.config/fish/ and loads conf.d/*.fish automatically
# No need for manual sourcing - fish does it for us!

# Modular configuration structure:
#   - Fish automatically loads all files in conf.d/ directory
#   - Numbered files (00-99) to control load order
#   - This file (config.fish) loads AFTER conf.d/ files

# ----- Local Overrides -----
# Put machine-specific customizations in ~/.config/fish/config.local.fish
# This file is NOT managed by dotfiles and won't be overwritten

if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end

# ----- Chezmoi Integration -----
# If using chezmoi to manage dotfiles across machines:
#   - Add new modules to conf.d/ with descriptive names
#   - Use chezmoi templates for machine-specific configs
#   - Run 'chezmoi add' to track new files
#   - Use config.local.fish for truly local, untracked customizations
