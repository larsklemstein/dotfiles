export LD_LIBRARY_PATH=/usr/local/lib

test -d $HOME/bin && PATH=$_:$PATH
test -d $HOME/go/bin && PATH=$PATH:$_
test -d $HOME/.cargo/bin && PATH=$PATH:$_

export PATH

ulimit -c 0
umask 002

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
