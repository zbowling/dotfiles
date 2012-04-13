export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export EDITOR='mate -w'
export GIT_EDITOR='mate -wl1'

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

alias gitg="git log --oneline --graph --decorate"

export PATH=${PATH}:~/android-sdk-macosx/tools:~/android-sdk-macosx/platform-tools
