# 40-aliases.zsh - Aliases and functions

# ----- File system (eza - better ls) -----
if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --git'
  alias lta='lt -a'
  # Use these if you want icons (requires Nerd Font)
  alias lsi='eza -lh --group-directories-first --icons'
  alias lti='eza --tree --level=2 --long --icons --git'
fi

# ----- fzf with bat preview -----
alias ff="fzf --preview 'batcat --style=numbers --color=always {}'"
alias fd='fdfind'

# ----- Zoxide replaces cd -----
alias cd='z'

# ----- Directories -----
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ----- Tools -----
n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }
alias g='git'
alias d='docker'
alias r='rails'
alias bat='batcat'
alias lzg='lazygit'
alias lzd='lazydocker'

# ----- Git shortcuts -----
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
