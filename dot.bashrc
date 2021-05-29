[[ $- == *i* ]] || return

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=2000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# disable programmable completion, will although stop
# adding a $ before pathes
shopt -u progcomp

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
# shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

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

PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W $ '


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


my_session_type() {
    local login_shell interactive

    shopt -q login_shell && login_shell='yes' || login_shell='no'
    [[ $- == *i* ]] && interactive='yes' || interactive='no'

    echo "logn shell....: $login_shell"
    echo "interactive...: $interactive"
}

alias mst=my_session_type

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# !! this should be the last line:
test -s $HOME/.common_interactive_sh && . $HOME/.common_interactive_sh

. $HOME/.config/broot/launcher/bash/br
