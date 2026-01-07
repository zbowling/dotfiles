# Fish shell configuration
# Managed by dotfiles in ~/projects/llm-host/dotfiles/

# ----- Environment -----
set -gx EDITOR nvim
set -gx SUDO_EDITOR nvim
set -gx VISUAL nvim

# ----- Tool Integrations -----

# Mise (polyglot runtime manager)
if command -v mise &> /dev/null
    mise activate fish | source
end

# Zoxide (smart cd)
if command -v zoxide &> /dev/null
    zoxide init fish | source
end

# fzf (fuzzy finder)
if command -v fzf &> /dev/null
    fzf --fish | source
end

# Starship prompt
if command -v starship &> /dev/null
    starship init fish | source
end

# Atuin (shell history sync)
if command -v atuin &> /dev/null
    atuin init fish | source
end

# 1Password SSH Agent
if test -S ~/.1password/agent.sock
    set -gx SSH_AUTH_SOCK ~/.1password/agent.sock
end

# ----- Aliases -----

# File system (eza - better ls)
if command -v eza &> /dev/null
    alias ls 'eza -lh --group-directories-first'
    alias lsa 'ls -a'
    alias lt 'eza --tree --level=2 --long --git'
    alias lta 'lt -a'
    # Use these if you want icons (requires Nerd Font)
    alias lsi 'eza -lh --group-directories-first --icons'
    alias lti 'eza --tree --level=2 --long --icons --git'
end

# fzf with bat preview
alias ff "fzf --preview 'batcat --style=numbers --color=always {}'"
alias fd 'fdfind'

# Zoxide replaces cd
alias cd 'z'

# Directories
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'

# Tools
function n
    if test (count $argv) -eq 0
        nvim .
    else
        nvim $argv
    end
end

alias g 'git'
alias d 'docker'
alias r 'rails'
alias bat 'batcat'
alias lzg 'lazygit'
alias lzd 'lazydocker'

# Git shortcuts
alias gcm 'git commit -m'
alias gcam 'git commit -a -m'
alias gcad 'git commit -a --amend'

# ----- Fish specific -----
# Disable greeting
set -g fish_greeting

# ----- Local Overrides -----
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end
