# ~/.config/zsh/.zshenv - Zsh environment configuration
# Loaded for ALL zsh sessions (interactive or non-interactive, login or non-login)
# Keep this minimal - only environment variables and PATH

# ----- Preserve Existing Configurations -----
# Source system-wide zshenv if it exists
[[ -f /etc/zshenv ]] && source /etc/zshenv

# Source backup of original user .zshenv if it was backed up during install
[[ -f ~/.zshenv.bak ]] && source ~/.zshenv.bak

# ----- VSCode/Cursor Shell Integration Fix -----
# Cursor's agent uses non-interactive shells which don't source .zshrc
# This function stub prevents "command not found: dump_zsh_state" errors
dump_zsh_state() { :; }

# ----- Load PATH Configuration -----
# Source the PATH module if it exists in rc.d/
if [[ -f "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/rc.d/00-path.zsh" ]]; then
  source "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/rc.d/00-path.zsh"
fi
