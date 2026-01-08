# 00-path.zsh - PATH configuration
# Loaded first to ensure PATH is set correctly

# Add local bin directories if they exist
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
[[ -d "$HOME/.cargo/bin" ]] && path=("$HOME/.cargo/bin" $path)

# Export PATH
export PATH
