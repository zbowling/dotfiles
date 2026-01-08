# 15-environment.fish - Environment variables

set -gx EDITOR nvim
set -gx SUDO_EDITOR nvim
set -gx VISUAL nvim

# 1Password SSH Agent
if test -S ~/.1password/agent.sock
    set -gx SSH_AUTH_SOCK ~/.1password/agent.sock
end
