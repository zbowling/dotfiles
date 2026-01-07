# ~/.zshrc - zsh configuration
# Managed by dotfiles in ~/projects/llm-host/dotfiles/

# ----- Antidote Plugin Manager -----
source ~/.antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

# ----- History -----
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# ----- Environment -----
export EDITOR=nvim
export SUDO_EDITOR=nvim
export VISUAL=nvim

# ----- Tool Integrations -----

# Mise (polyglot runtime manager)
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# Zoxide (smart cd)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# fzf (fuzzy finder)
if command -v fzf &> /dev/null; then
  source <(fzf --zsh) 2>/dev/null || true
fi

# Starship prompt
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# Atuin (shell history sync)
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh)"
fi

# 1Password SSH Agent
if [[ -S ~/.1password/agent.sock ]]; then
  export SSH_AUTH_SOCK=~/.1password/agent.sock
fi

# ----- Aliases -----

# File system (eza - better ls)
if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --git'
  alias lta='lt -a'
  # Use these if you want icons (requires Nerd Font)
  alias lsi='eza -lh --group-directories-first --icons'
  alias lti='eza --tree --level=2 --long --icons --git'
fi

# fzf with bat preview
alias ff="fzf --preview 'batcat --style=numbers --color=always {}'"
alias fd='fdfind'

# Zoxide replaces cd
alias cd='z'

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }
alias g='git'
alias d='docker'
alias r='rails'
alias bat='batcat'
alias lzg='lazygit'
alias lzd='lazydocker'

# Git shortcuts
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# ----- Key Bindings -----
bindkey -e  # Emacs-style keybindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ----- Completion -----
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ----- Local Overrides -----
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
