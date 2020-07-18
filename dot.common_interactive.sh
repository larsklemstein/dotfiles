# --- use either exa (new style ls) or standard ls ---

alias ls='/bin/ls --color=auto'
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -la'

unset _exa_prog


alias grep='/bin/grep --color=auto'
alias egrep='/bin/egrep --color=auto'
alias fgrep='/bin/fgrep --color=auto'

alias vim=nvim


# --- git stuff ---

alias ga='git add'
alias gc='git commit'
alias gp='git push'


# --- doc stuff ---

export DOC_BROWSER=badwolf
# export DOC_BROWSER=firefox

alias dbg='$DOC_BROWSER www.golang.com/doc >/dev/null 2>&1 &'


# --- color stuff ---

# vivid: tool to generate themed LS_COLORS, https://github.com/sharkdp/vivid
#
which vivid 2>/dev/null >&2 && export LS_COLORS=$(vivid generate snazzy)

export GREP_COLORS='sl=49;39:cx=49;39:mt=49;38;5;178;1:fn=49;39:ln=49;39:bn=49;39:se=49;39';

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quo
te=01'

# --- activate Python virtualenv in sub directory ---

alias avenv='__apy__=$(find . -maxdepth 4 -path "*/bin/activate" -type f|head -1) && [ -n "$__apy__" -a -f "$__apy__" ] && PS1="\W > " && . $__apy__ && python -V || echo "no python venv detected!"; unset __apy__'


export VISUAL=nvim
export EDITOR=$VISUAL
export PAGER=less
export LESS='-RC'


test -f ~/.fzf.bash && . $_

set -o vi

test -f $HOME/.common_interactive_local.sh && . $HOME/.common_interactive_local.sh
