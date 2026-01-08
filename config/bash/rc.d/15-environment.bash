# 15-environment.bash - Environment variables

export EDITOR=nvim
export SUDO_EDITOR=nvim
export VISUAL=nvim

# 1Password SSH Agent (only activates if 1Password is installed)
if [[ -S ~/.1password/agent.sock ]]; then
  export SSH_AUTH_SOCK=~/.1password/agent.sock
fi
