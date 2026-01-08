# 20-plugins.zsh - Antidote plugin manager

# Auto-install antidote if not present
if [[ ! -f ~/.antidote/antidote.zsh ]]; then
  echo "Installing Antidote plugin manager..."
  git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
fi

# Load antidote and plugins
source ~/.antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt
