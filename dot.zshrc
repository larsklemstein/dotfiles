source $HOME/.common_interactive_sh

# -----------------------------
# Detect Homebrew prefix
# -----------------------------
if command -v brew >/dev/null 2>&1; then
    BREW_PREFIX="$(brew --prefix)"
else
    BREW_PREFIX=""
fi

# -----------------------------
# zinit (plugins)
# -----------------------------
if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/opt/zinit/zinit.zsh" ]; then
    source "$BREW_PREFIX/opt/zinit/zinit.zsh"

    # Plugins with turbo mode (load after prompt appears)
    zinit ice wait lucid
    zinit light zsh-users/zsh-autosuggestions

    zinit ice wait lucid
    zinit light zsh-users/zsh-syntax-highlighting

    zinit ice wait lucid
    zinit light zsh-users/zsh-completions

    zinit ice wait lucid
    zinit light Aloxaf/fzf-tab

    # Keybindings for autosuggestions
    bindkey '^E' autosuggest-accept
    bindkey '^F' autosuggest-accept-word
fi

# -----------------------------
# Completion
# -----------------------------
autoload -Uz compinit && compinit -u
zstyle ':completion:*' completer _complete _ignored _approximate _correct
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' menu select

# -----------------------------
# History
# -----------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt inc_append_history
setopt extended_history
setopt hist_reduce_blanks
setopt hist_verify
setopt hist_ignore_dups

# -----------------------------
# Prompt (with git branch)
# -----------------------------
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '[%b]'
setopt prompt_subst
PROMPT='%F{cyan}%n@%m%f %F{white}%2~ %F{magenta}${vcs_info_msg_0_}%f %% '

# -----------------------------
# fzf (if installed via brew)
# -----------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
