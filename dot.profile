PATH=$HOME/bin:$PATH

test -d "$HOME/app/go/bin" && PATH="$_:$PATH"    # go itself
test -d "$HOME/go/bin" && PATH="$_:$PATH"        # go toolchain
test -d "$HOME/app/bin" && PATH="$_:$PATH" 
test -d "$HOME/app/node/bin" && PATH="$_:$PATH"  # nodej
test -f "$HOME/.cargo/env" && . $_               # rust (env will extend PATH)
test -d "$HOME/.local/bin" && PATH="$_:$PATH"    # mainly python programs
test -d "$HOME/app/node/bin" && PATH="$_:$PATH"  # node-js

export PATH


export TMPDIR=$HOME/tmp
test -d $TMPDIR || mkdir -vp $TMPDIR
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
