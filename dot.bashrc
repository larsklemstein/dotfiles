# Exit if not interactive
[[ $- != *i* ]] && return


# Colors

# History settings
HISTCONTROL=ignoredups
HISTSIZE=20000
HISTFILESIZE=20000
HISTTIMEFORMAT='[%m-%d %H:%M] '
HISTIGNORE="clear:history:ls:ll:la:pwd"
PROMPT_COMMAND='history -a'
shopt -s histappend

set -o vi

alias h=history

# Shell options
shopt -s checkwinsize    # auto-update LINES/COLUMNS
shopt -u progcomp        # disable programmable completion
# shopt -s globstar      # enable ** recursive globbing if wanted

# Terminal type
export TERM=${DISPLAY:+xterm-256color}
export TERM=${TERM:-vt100}

# Prompt
PS1='${PWD##*/} $ '

# Helpers
my_session_type() {
    echo "login shell....: $([[ $- == *l* ]] && echo yes || echo no)"
    echo "interactive....: $([[ $- == *i* ]] && echo yes || echo no)"
}
alias mst=my_session_type

[[ -f "$HOME/.bash_colors" ]] && . "$HOME/.bash_colors"

[[ -s "$HOME/.common_interactive_sh" ]] && . "$HOME/.common_interactive_sh"
