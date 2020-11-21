export LD_LIBRARY_PATH=/usr/local/lib

lkl_add2path() {
	typeset new_path="$1"
	typeset pos="${2:-post}"

	[ -d "$new_path" ] || return

	if [ "$pos" = pre ]
	then
		path_contains "$new_path" || PATH=$new_path:$PATH
	else
		path_contains "$new_path" || PATH=$PATH:$new_path
	fi
}

path_contains() {
	typeset check_path="$1"

	[[ "$PATH" ==   $check_path   ]] && return 0
	[[ "$PATH" == *:$check_path   ]] && return 0
	[[ "$PATH" ==   $check_path:* ]] && return 0
	[[ "$PATH" == *:$check_path:* ]] && return 0

	return 1
}

lkl_add2path $HOME/bin pre
lkl_add2path $HOME/local/bin pre
lkl_add2path $HOME/go/bin post
lkl_add2path $HOME/.cargo/bin post
export PATH

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

export PATH="$HOME/.cargo/bin:$PATH"

# map CapsLock to Escape
setxkbmap  -option caps:escape
