# 30-tools.bash - Tool integrations

# Starship prompt
if command -v starship &> /dev/null; then
  eval "$(starship init bash)"
fi

# Atuin (shell history sync)
if command -v atuin &> /dev/null; then
  # Source atuin environment
  [[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"
  [[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
  eval "$(atuin init bash)"
fi
