[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -Uz vcs_info
autoload -Uz compinit && compinit

# enable auto-completion
# this is needed for the completion of git commands
zstyle ':completion:*' completer _complete _ignored _approximate _correct


precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST

PROMPT="$(/bin/hostname -s | tr '[:upper:]' '[:lower:]')"' %F{white}%2~ %F{magenta}${vcs_info_msg_0_}%f%% '

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

. $HOME/.common_interactive_sh


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/larsklemstein/.opam/opam-init/init.zsh' ]] || source '/Users/larsklemstein/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration
