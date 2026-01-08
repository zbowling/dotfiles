# 30-tools.fish - Tool integrations

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
