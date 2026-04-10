# ----------------------------------
# Nur interaktiv
# ----------------------------------
[[ -o interactive ]] || return

# ----------------------------------
# Common config
# ----------------------------------
[[ -f "$HOME/.common_interactive_sh" ]] && source "$HOME/.common_interactive_sh"

# ----------------------------------
# Core
# ----------------------------------
autoload -Uz compinit
# compinit
compinit -C -d ~/.zcompdump

bindkey -v

# ----------------------------------
# Prompt Substitution (wichtig)
# ----------------------------------
setopt PROMPT_SUBST

# ----------------------------------
# Editor
# ----------------------------------
: "${EDITOR:=nvim}"
export EDITOR
: "${VISUAL:=$EDITOR}"
export VISUAL

# ----------------------------------
# Completion
# ----------------------------------
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  'r:|=*'

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''

bindkey '^I' expand-or-complete

# ----------------------------------
# History
# ----------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ----------------------------------
# Directory Stack
# ----------------------------------
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ----------------------------------
# Prompt Helpers
# ----------------------------------
get_user_label() {
  if [[ -f "$HOME/.env_id" ]]; then
    head -n1 "$HOME/.env_id"
  else
    echo "${USER}@${HOST%%.*}"
  fi
}

short_pwd() {
  local p="$PWD"
  p="${p/#$HOME/~}"

  local parts
  parts=("${(@s:/:)p}")

  if (( ${#parts} >= 2 )); then
    echo "${parts[-2]}/${parts[-1]}"
  else
    echo "$p"
  fi
}

# ----------------------------------
# VI Mode Anzeige
# ----------------------------------
VI_MODE="I"

zle-keymap-select() {
  case $KEYMAP in
    vicmd) VI_MODE="N" ;;
    *)     VI_MODE="I" ;;
  esac
  zle reset-prompt
}

zle-line-init() {
  VI_MODE="I"
  zle reset-prompt
}

zle -N zle-keymap-select
zle -N zle-line-init

# ----------------------------------
# Prompt + Git
# ----------------------------------
autoload -Uz vcs_info

precmd() {
  vcs_info
}

zstyle ':vcs_info:git:*' formats '%F{magenta}(%b)%f'

PROMPT='%F{yellow}${VI_MODE}%f %F{green}$(get_user_label)%f %F{white}$(short_pwd)%f ${vcs_info_msg_0_}%# '

# ----------------------------------
# Ctrl-F → FILE (balanced layout)
# ----------------------------------
lk_fzf_file_widget() {
  emulate -L zsh
  setopt localoptions no_aliases noshwordsplit

  local selected editor_cmd

  zle -I

  selected=$(
    fd --type f \
      --hidden \
      --exclude .git \
      --exclude node_modules \
      --exclude .cache \
      --exclude .venv \
      --exclude venv \
      --exclude dist \
      --exclude build \
      --exclude target \
      --exclude Library \
      --exclude .Trash \
      --exclude Nextcloud \
      2>/dev/null \
    | sed 's|^\./||' \
    | fzf \
      --height=24 \
      --layout=reverse \
      --border \
      --prompt 'Files> ' \
      --preview 'bat --style=numbers --color=always --theme=1337 --line-range :100 {} 2>/dev/null || sed -n "1,100p" {}' \
      --preview-window=up:8:wrap
  ) || {
    zle redisplay
    return 0
  }

  selected="./${selected}"

  if [[ -z "${BUFFER//[[:space:]]/}" ]]; then
    editor_cmd="${VISUAL:-$EDITOR}"
    command "$editor_cmd" -- "$selected" < /dev/tty > /dev/tty 2>&1
    zle reset-prompt
  else
    BUFFER="${BUFFER:+$BUFFER }${(q)selected}"
    CURSOR=${#BUFFER}
    zle redisplay
  fi
}

zle -N lk_fzf_file_widget
bindkey '^F' lk_fzf_file_widget

# ----------------------------------
# Ctrl-A → DIR (smart)
# ----------------------------------
lk_fzf_dir_widget() {
  emulate -L zsh
  setopt localoptions no_aliases noshwordsplit

  local selected

  zle -I
  selected=$(fd --type d \
    --hidden \
    --exclude .git \
    --exclude node_modules \
    --exclude .cache \
    --exclude .venv \
    --exclude venv \
    --exclude dist \
    --exclude build \
    --exclude target \
    --exclude Library \
    --exclude .Trash \
    --exclude Nextcloud \
    2>/dev/null | fzf) || {
    zle redisplay
    return 0
  }

  [[ -d "$selected" ]] || {
    zle redisplay
    return 0
  }

  if [[ -z "${BUFFER//[[:space:]]/}" ]]; then
    builtin cd -- "$selected"
    zle reset-prompt
  else
    BUFFER="cd -- ${(q)selected}"
    CURSOR=${#BUFFER}
    zle redisplay
  fi
}
zle -N lk_fzf_dir_widget
bindkey '^A' lk_fzf_dir_widget

# ----------------------------------
# Ctrl-E → DIRECTORY STACK
# ----------------------------------
lk_fzf_stack_widget() {
  emulate -L zsh
  setopt localoptions no_aliases noshwordsplit

  local -a stack
  local selected

  stack=("$PWD" "${dirstack[@]}")

  zle -I
  selected=$(printf '%s\n' "${stack[@]}" | fzf) || {
    zle redisplay
    return 0
  }

  [[ -d "$selected" ]] || {
    zle redisplay
    return 0
  }

  builtin cd -- "$selected"
  zle reset-prompt
}
zle -N lk_fzf_stack_widget
bindkey '^E' lk_fzf_stack_widget

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Ctrl+J → accept autosuggestion
bindkey -M viins '^J' autosuggest-accept

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#444444'

bindkey -M viins '^[[C' forward-char
