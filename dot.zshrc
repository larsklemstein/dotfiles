# =====================================================================
#  Common shell settings
# =====================================================================
source "$HOME/.common_interactive_sh"

# =====================================================================
#  Detect Homebrew prefix
# =====================================================================
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
else
  BREW_PREFIX=""
fi

# =====================================================================
#  zinit plugin manager
# =====================================================================
if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/opt/zinit/zinit.zsh" ]; then
  source "$BREW_PREFIX/opt/zinit/zinit.zsh"

  zinit ice wait lucid
  zinit light zsh-users/zsh-completions

  zinit ice wait lucid
  zinit light Aloxaf/fzf-tab

  zinit ice wait lucid
  zinit light zsh-users/zsh-autosuggestions
fi

# =====================================================================
#  Tmux: start each new session in the current directory
# =====================================================================
alias tmux='tmux new-session -s "$(basename "$PWD")-$(date +%H%M%S)" -c "$PWD"'

# =====================================================================
#  Completion system
# =====================================================================
autoload -Uz compinit
compinit

zmodload zsh/complist
zstyle ':completion:*' completer _complete _ignored _approximate _correct
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:warnings'     format 'No matches for: %d'
zstyle ':completion:*'              menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# =====================================================================
#  History
# =====================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory inc_append_history extended_history hist_reduce_blanks hist_verify hist_ignore_dups

# =====================================================================
#  Vi-mode editing
# =====================================================================
bindkey -v
export KEYTIMEOUT=1
bindkey -M menuselect '^N' down-line-or-history
bindkey -M menuselect '^P' up-line-or-history

setopt extendedglob
setopt globstarshort

# =====================================================================
#  Prompt with live vi-mode tag + git branch
# =====================================================================
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*:*' check-for-changes false
zstyle ':vcs_info:git:*' formats '[%b]'
zstyle ':vcs_info:*'     actionformats '[%b|%a]'

precmd() { vcs_info }

PROMPT_BASE='%F{cyan}%n@%m%f %F{white}%2~%f%F{magenta}${vcs_info_msg_0_:+ $vcs_info_msg_0_}%f %# '

function zle-keymap-select {
  case $KEYMAP in
    vicmd) PROMPT="%F{yellow}[N]%f $PROMPT_BASE" ;;
    *)     PROMPT="%F{green}[I]%f $PROMPT_BASE" ;;
  esac
  zle reset-prompt
}
zle -N zle-keymap-select
function zle-line-init { zle -K viins }
zle -N zle-line-init

PROMPT="%F{green}[I]%f $PROMPT_BASE"

# =====================================================================
#  fzf defaults
# =====================================================================
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# =====================================================================
#  Key bindings
# =====================================================================
bindkey -M viins '^A' autosuggest-accept       # accept grey autosuggestion
bindkey -M viins '^R' fzf-history-widget       # fuzzy history search
bindkey -M viins '^F' fzf-file-widget          # fuzzy pick file → insert path

# =====================================================================
#  Widgets – live-scanning version
# =====================================================================

# Ctrl-K → fuzzy-switch directory (live scan)
fzf_switch_dir() {
  local sel
  sel=$(fd --type d --hidden --exclude .git . | fzf --height=100% --layout=default) || return
  builtin cd "$sel"
  zle reset-prompt
}
zle -N fzf_switch_dir
bindkey -M viins '^K' fzf_switch_dir

# Ctrl-O → fuzzy-operate: insert directory path (live scan) + add to push-stack
fzf_insert_dir() {
  local sel abs
  sel=$(fd --type d --hidden --exclude .git . | fzf --height=100% --layout=default) || return
  LBUFFER+="$sel"
  zle redisplay
  abs="$sel"
  local -a newstack
  newstack=("$abs" "${dirstack[@]}")
  typeset -U newstack
  (( ${#newstack[@]} > DIRSTACKSIZE )) && newstack=("${newstack[@]:0:$DIRSTACKSIZE}")
  dirstack=("${newstack[@]}")
}
zle -N fzf_insert_dir
bindkey -M viins '^O' fzf_insert_dir

# Ctrl-G → pick directory from push-stack → cd
fzf_cd_stack() {
  local dir
  dir=$(dirs -v | fzf | awk '{print $2}') || return
  [[ -n $dir ]] && cd "$dir"
  zle reset-prompt
}
zle -N fzf_cd_stack
bindkey -M viins '^G' fzf_cd_stack

# g <N> → jump to directory-stack entry
g() {
  local idx=$1
  [[ -z $idx ]] && { dirs -v; return 1; }
  local d=$(dirs +$idx 2>/dev/null)
  [[ -n $d ]] && cd "$d" || { echo "No directory at index $idx"; dirs -v; }
}

# push-stack behaviour
setopt auto_pushd
setopt pushd_ignore_dups
DIRSTACKSIZE=12

# =====================================================================
#  Clear screen (Blink/iPad friendly)
# =====================================================================
function blink_clear() { command clear; echo; }
alias clear='blink_clear'
function clear_and_echo() { blink_clear; zle reset-prompt }
zle -N clear_and_echo
bindkey -M viins '^L' clear_and_echo
bindkey -M vicmd '^L' clear_and_echo

# =====================================================================
#  zm → cheat-sheet
# =====================================================================
zm() {
  /bin/cat <<'EOF'
+-------------------------+----------------------------------------------+
| KEY / COMMAND           | ACTION                                       |
+-------------------------+----------------------------------------------+
| Ctrl-A                  | Accept grey autosuggestion                   |
| Ctrl-R                  | Fuzzy search history                         |
| Ctrl-F                  | Fuzzy pick file → insert path                |
| Ctrl-K                  | Fuzzy pick directory → SWITCH (cd)           |
| Ctrl-O                  | Fuzzy pick directory → OPERATE (insert path) |
| Ctrl-G                  | Choose directory from push-stack → cd        |
| g <N>                   | Jump to push-stack entry N                   |
| zm                      | Show this cheat-sheet                        |
+-------------------------+----------------------------------------------+
| Built-ins / Misc                                                       |
| Ctrl-L                  | Clear screen                                 |
+-------------------------+----------------------------------------------+
EOF
}
