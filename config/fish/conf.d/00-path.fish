# 00-path.fish - PATH configuration

# Add .local/bin to PATH if it exists
if test -d $HOME/.local/bin
    set -gx PATH $HOME/.local/bin $PATH
end

# Add .cargo/bin to PATH if it exists
if test -d $HOME/.cargo/bin
    set -gx PATH $HOME/.cargo/bin $PATH
end
