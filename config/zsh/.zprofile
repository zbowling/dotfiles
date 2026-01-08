# ~/.config/zsh/.zprofile - Zsh profile for login shells
# Loaded: Login shells only (macOS terminal windows, SSH sessions)

# ----- Preserve Existing Configurations -----
# Source system-wide zprofile if it exists
[[ -f /etc/zprofile ]] && source /etc/zprofile

# Source backup of original user .zprofile if it was backed up during install
[[ -f ~/.zprofile.bak ]] && source ~/.zprofile.bak

# ----- macOS-Specific -----
# Homebrew setup (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Apple Silicon Macs
  if [[ -d "/opt/homebrew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  # Intel Macs
  elif [[ -d "/usr/local/Homebrew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# ----- Local Overrides -----
[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local
