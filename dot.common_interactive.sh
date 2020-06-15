alias ls='/bin/ls --color=auto'
alias ll='ls -l'
alias la='ls -a'

alias grep='/bin/grep --color=auto'
alias egrep='/bin/egrep --color=auto'
alias fgrep='/bin/fgrep --color=auto'

alias vim=nvim


# --- color definitions, can be used via (e.g.) echo -e "This is {BLUE}, this is now {NOCOLOR} again."
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

msg() {
	echo -e "${BLUE}$*${NOCOLOR}" >&2
}

error() {
	echo -e "${RED}$*${NOCOLOR}" >&2
}

# -- git stuff ---
alias ga='git add'
alias gc='git commit'

export VISUAL=nvim
export EDITOR=$VISUAL
export PAGER=less
export LESS='-C'
export GZIP=-9

export LS_COLORS='rs=0:di=34;01:ln=0:mh=0:pi=0:so=0:do=0:bd=0:cd=0:or=37;41:mi=0:su=0:sg=0:ca=0:tw=0:ow=0:st=0:ex=31;01'

export GREP_COLORS='sl=49;39:cx=49;39:mt=49;38;5;178;1:fn=49;39:ln=49;39:bn=49;39:se=49;39';

set -o vi

test -f $HOME/.common_interactive_local.sh && . $HOME/.common_interactive_local.sh
