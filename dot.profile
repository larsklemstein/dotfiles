export LD_LIBRARY_PATH=/usr/local/lib

test -d $HOME/bin && PATH=$_:$PATH
test -d $HOME/go/bin && PATH=$PATH:$_
test -d $HOME/.cargo/bin && PATH=$PATH:$_

export PATH

ulimit -c 0

<<<<<<< HEAD
# save more commands in history
=======
>>>>>>> 65a06fd773ca8b6202053ff1523b4a47fd3b7636
HISTSIZE=500
HISTEDIT=$EDITOR

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
set +x
