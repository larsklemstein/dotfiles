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
if [[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/opt/zinit/zinit.zsh" ]]; then
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
HISTFILE=$HOME/.zsh_history
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
#  Directory history – last 12 visited (excluding current)
# =====================================================================
DIRSTACKSIZE=12
typeset -ga dirstack     # MRU of previously visited directories

# helper: add path to history (dedupe by physical path, pretty-print /tmp)
__hist_add_path() {
  local in="$1"
  [[ -z $in ]] && return

  local cur_phys="${PWD:P}"             # physical current dir
  local new_phys="${in:P}"              # physical path of entry
  [[ $new_phys == "$cur_phys" ]] && return  # never add current dir

  local pretty="$in"
  [[ $new_phys == /private/tmp ]] && pretty="/tmp"

  local -a newstack=("$pretty")
  local d
  for d in "${dirstack[@]}"; do
    [[ "${d:P}" == "$new_phys" || "${d:P}" == "$cur_phys" ]] && continue
    newstack+=("$d")
    (( ${#newstack[@]} >= DIRSTACKSIZE )) && break
  done

  dirstack=("${newstack[@]}")
}

autoload -Uz add-zsh-hook
__track_dirs_chpwd() {
  [[ -n $OLDPWD ]] && __hist_add_path "$OLDPWD"
}
add-zsh-hook chpwd __track_dirs_chpwd

alias dv='dirs -v'      # show stack (0=current, rest=history)
alias dc='dirstack=()'  # clear history

alias g0='g 0'
alias g1='g 1'
alias g2='g 2'
alias g3='g 3'
alias g4='g 4'
alias g5='g 5'
alias g6='g 6'
alias g7='g 7'
alias g8='g 8'
alias g9='g 9'
alias g10='g 10'
alias g11='g 11'

# g <N> → jump to history entry N
g() {
  emulate -L zsh
  if [[ -z $1 || $1 != <-> ]]; then
    echo "Usage: g <number>"
    dv
    return 1
  fi
  local n=$1
  if ! eval "cd ~${n}" 2>/dev/null; then
    echo "g: no directory at index $n"
    dv
    return 1
  fi
}

# =====================================================================
#  Widgets – live-scanning
# =====================================================================

# Ctrl-K → fuzzy-switch directory (cd)
fzf_switch_dir() {
  local sel
  sel=$(fd --type d --hidden --exclude .git . | fzf --height=100% --layout=default) || return
  builtin cd "$sel"
  zle reset-prompt
}
zle -N fzf_switch_dir
bindkey -M viins '^K' fzf_switch_dir

# Ctrl-O → fuzzy-operate: insert dir path + add to history (no cd)
fzf_insert_dir() {
  local sel
  sel=$(fd --type d --hidden --exclude .git . | fzf --height=100% --layout=default) || return
  [[ ${sel:P} == /private/tmp ]] && sel="/tmp"
  LBUFFER+="$sel"
  zle redisplay
  __hist_add_path "$sel"
}
zle -N fzf_insert_dir
bindkey -M viins '^O' fzf_insert_dir

# Ctrl-G → fuzzy-choose from history → cd  (manual ~ expansion)
fzf_cd_stack() {
  local dir target
  dir=$(dirs -p | fzf --height=100% --layout=default) || return
  [[ -z $dir ]] && return

  # Manually expand leading ~ to $HOME (avoid ${~var} side-effects)
  if [[ $dir == "~" || $dir == "~/"* ]]; then
    target="${dir/#\~/$HOME}"
  else
    target="$dir"
  fi

  builtin cd -- "$target"
  zle reset-prompt
}
zle -N fzf_cd_stack
bindkey -M viins '^G' fzf_cd_stack

# =====================================================================
#  Clear screen (Blink/iPad friendly)
# =====================================================================
blink_clear() { command clear; echo; }
alias clear='blink_clear'
clear_and_echo() { blink_clear; zle reset-prompt }
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
| Ctrl-G                  | Fuzzy choose directory from history → cd     |
| g <N>                   | Jump to directory-history entry N            |
| dv / dc                 | Show / clear directory history               |
| zm                      | Show this cheat-sheet                        |
+-------------------------+----------------------------------------------+
| Built-ins / Misc                                                       |
| Ctrl-L                  | Clear screen                                 |
+-------------------------+----------------------------------------------+
EOF
}
