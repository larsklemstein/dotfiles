[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -Uz vcs_info

precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '

. $HOME/.common_interactive_sh
