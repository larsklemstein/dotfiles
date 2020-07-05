export LD_LIBRARY_PATH=/usr/local/lib

lkl_add2path() {
	typeset new_path="$1"
	typeset pos="$2"

	if [ $pos = "pre" ]
	then
		test -d $new_path && [[ "$PATH" != *$_:* ]] && PATH=$_:$PATH
	else
		test -d $new_path && [[ "$PATH" != *:$_* ]] && PATH=$PATH:$_
	fi
}

lkl_add2path $HOME/bin pre
lkl_add2path $HOME/app/bin post
lkl_add2path $HOME/go/bin post
lkl_add2path $HOME/.cargo/bin post
export PATH

test -d $HOME/tmp || mkdir -vp $_
export TMPDIR=$_

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
