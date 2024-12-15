[[ $- == *i* ]] || return

test -f $HOME/.bash_colors && . $_

# unset variables should alert us

# history related stuff
export HISTCONTROL=ignoredups
export HISTSIZE=20000
export HISTFILESIZE=20000

alias h=history

export HISTTIMEFORMAT='[%m-%d %H:%M] '
export HISTIGNORE="clear:history:ls:ll:la:pwd"

export PROMPT_COMMAND='history -a'
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# disable programmable completion, will although stop adding a $ before pathes
shopt -u progcomp

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
# shopt -s globstar

if [ -n "$DISPLAY" ]
then
    export TERM=xterm-256color
else
    export TERM=vt100
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ $(id -un) = root ]
then
    export PS1="${Col_IRed}\u@\h \W ${Col_Off} # "
else
    PA
fi

my_session_type() {
    local login_shell interactive

    shopt -q login_shell && login_shell='yes' || login_shell='no'
    [[ $- == *i* ]] && interactive='yes' || interactive='no'

    echo "logn shell....: $login_shell"
    echo "interactive...: $interactive"
}

alias mst=my_session_type


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#         this should be the last lines
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

test -s $HOME/.common_interactive_sh && . $HOME/.common_interactive_sh
