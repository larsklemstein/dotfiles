[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -Uz vcs_info

precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST

# alias is_vscode_shell="pstree -p $$ | sed -n 2,4p | grep -q '/Applications/Visual Studio Code.app/Contents/MacOS/Electro'"

PROMPT='%F{white}%2~ %F{magenta}${vcs_info_msg_0_}%f%% '

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

. $HOME/.common_interactive_sh

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/lklemstein/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
