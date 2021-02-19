export LD_LIBRARY_PATH=/usr/local/lib

export PATH=$HOME/bin:$HOME/local/bin:$HOME/go/bin:$HOME/app/go/bin:$HOME/.cargo/bin:$PATH

test -d $HOME/tmp || mkdir -vp $_
export TMPDIR=$_

ulimit -c 0
umask 002

test -f "$HOME/.profile_local" && . $_

if [[ $- == *i* ]]  # if interactive bash or ksh...
then
    if [[ -z "$KSH_VERSION" && $SHELL = */bin/bash && -f ~/.bashrc ]]
    then
        . ~/.bashrc
    elif [ -n "$KSH_VERSION" -a -f ~/.kshrc ]
    then
        . ~/.kshrc
    fi
fi


# map CapsLock to Escape
setxkbmap  -option caps:escape
source "$HOME/.cargo/env"
