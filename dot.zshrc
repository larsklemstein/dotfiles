[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -Uz vcs_info

precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST
PROMPT='%F{white}%2~ %F{magenta}${vcs_info_msg_0_}%f%% '

. $HOME/.common_interactive_sh

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/lklemstein/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
