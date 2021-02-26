export PATH=$HOME/bin:$HOME/local/bin:$HOME/go/bin:$HOME/app/go/bin:$PATH


PATH=$HOME/local/bin:$HOME/go/bin:$HOME/app/go/bin:$HOME/go/bin:$PATH

test -f "$HOME/.cargo/env" && . $_

test -d "$HOME/.local/bin" && PATH="$_:$PATH"
test -d "$HOME/app/node/bin" && PATH="$_:$PATH"

export PATH

export TMPDIR=$HOME/tmp
test -d $TMPDIR || mkdir -vp $TMPDIR

test -d $TMPDIR && find $TMPDIR -mtime +3 -exec /bin/rm -rf {} +

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
