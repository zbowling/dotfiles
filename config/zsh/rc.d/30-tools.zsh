# 30-tools.zsh - Tool integrations

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
  # Source atuin environment
  [[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"
  eval "$(atuin init zsh)"
fi
