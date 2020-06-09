export LD_LIBRARY_PATH=/usr/local/lib

test -d $HOME/bin && PATH=$_:$PATH
test -d $HOME/go/bin && PATH=$PATH:$_
test -d $HOME/.cargo/bin && PATH=$PATH:$_

export PATH

export VISUAL=vi
export EDITOR=$VISUAL
export PAGER=less
export GZIP=-9

ulimit -c 0

# avoid certain file types in completion
FIGNORE='@(*.o|~*)'

# save more commands in history
HISTSIZE=500
HISTEDIT=$EDITOR

if [ -z "$KSH_VERSION" -a $SHELL = /bin/bash ] && \
	[[ $- == *i* ]] && test -f $HOME/.bashrc
then
	. $HOME/.bashrc
fi
