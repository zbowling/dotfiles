# 40-aliases.bash - Aliases and functions

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
