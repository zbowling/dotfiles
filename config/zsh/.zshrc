# ~/.config/zsh/.zshrc - Main zsh configuration
# Managed by dotfiles - Uses XDG Base Directory specification

# ----- Preserve Existing Configurations -----
# Source system-wide zsh config if it exists (some distros use this)
[[ -f /etc/zshrc ]] && source /etc/zshrc

# Source backup of original user .zshrc if it was backed up during install
# This preserves Oh-My-Zsh, Prezto, or other existing configs
[[ -f ~/.zshrc.bak ]] && source ~/.zshrc.bak

# ----- Load Modular Configurations -----
# Source all files in rc.d/ in alphabetical order
# Numbering convention: 00-99 (lower numbers load first)
#   00-09: Core setup (PATH, environment)
#   10-19: History and settings
#   20-29: Plugin managers
#   30-39: Tool integrations
#   40-49: Aliases and functions
#   50-89: Customizations
#   90-99: Completion and finalization

if [[ -d "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/rc.d" ]]; then
  for config_file in "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"/rc.d/*.zsh(N); do
    source "$config_file"
  done
  unset config_file
fi

# ----- Local Overrides -----
# Put machine-specific customizations in ~/.zshrc.local
# This file is NOT managed by dotfiles and won't be overwritten
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ----- Chezmoi Integration -----
# If using chezmoi to manage dotfiles across machines:
#   - Add new modules to rc.d/ with descriptive names
#   - Use chezmoi templates for machine-specific configs
#   - Run 'chezmoi add' to track new files
#   - Use .zshrc.local for truly local, untracked customizations

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

# bun completions
[ -s "/home/zbowling/.bun/_bun" ] && source "/home/zbowling/.bun/_bun"
