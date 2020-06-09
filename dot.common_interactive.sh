alias ls='/bin/ls --color=auto'
alias ll='ls -l'
alias la='ls -a'

alias grep='/bin/grep --color=auto'
alias egrep='/bin/egrep --color=auto'
alias fgrep='/bin/fgrep --color=auto'

export VISUAL=vi
export EDITOR=$VISUAL
export PAGER=less
export LESS='-CN'
export GZIP=-9

export LS_COLORS='rs=0:di=34;01:ln=0:mh=0:pi=0:so=0:do=0:bd=0:cd=0:or=37;41:mi=0:su=0:sg=0:ca=0:tw=0:ow=0:st=0:ex=31;01'

export GREP_COLORS='sl=49;39:cx=49;39:mt=49;38;5;178;1:fn=49;39:ln=49;39:bn=49;39:se=49;39';

set -o vi

test -f $HOME/.common_interactive_local.sh && . $HOME/.common_interactive_local.sh
