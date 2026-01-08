# 15-environment.zsh - Environment variables

export EDITOR=nvim
export SUDO_EDITOR=nvim
export VISUAL=nvim

# 1Password SSH Agent
if [[ -S ~/.1password/agent.sock ]]; then
  export SSH_AUTH_SOCK=~/.1password/agent.sock
fi

# VSCode/Cursor Shell Integration Fix
# Define stub function to prevent "command not found: dump_zsh_state" errors
dump_zsh_state() { :; }
