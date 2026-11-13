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
# Prompt Helpers (fork-frei, macOS + Linux)
# ----------------------------------
# Label einmalig beim Start ermitteln
if [[ -r "$HOME/.env_id" ]]; then
  read -r _lk_label < "$HOME/.env_id"
else
  _lk_label="${USER:-$LOGNAME}@${HOST%%.*}"
fi

_lk_update_pwd() {
  local p="${PWD/#$HOME/~}"
  local -a parts=("${(@s:/:)p}")

  if (( ${#parts} >= 2 )); then
    _lk_pwd="${parts[-2]}/${parts[-1]}"
  else
    _lk_pwd="$p"
  fi
}

# Git-Branch ohne git-Prozess: .git/HEAD direkt lesen
_lk_update_git() {
  _lk_git=""
  local dir="$PWD" head gitdir line
  while [[ -n "$dir" ]]; do
    if [[ -d "$dir/.git" ]]; then
      gitdir="$dir/.git"
      break
    elif [[ -f "$dir/.git" ]]; then
      # Worktree/Submodule: "gitdir: <pfad>"
      read -r line < "$dir/.git"
      gitdir="${line#gitdir: }"
      [[ "$gitdir" = /* ]] || gitdir="$dir/$gitdir"
      break
    fi
    dir="${dir%/*}"
  done
  [[ -r "$gitdir/HEAD" ]] || return
  read -r head < "$gitdir/HEAD"
  if [[ "$head" = ref:\ refs/heads/* ]]; then
    _lk_git="%F{magenta}(${head#ref: refs/heads/})%f "
  else
    _lk_git="%F{magenta}(${head[1,7]})%f "
  fi
}

# ----------------------------------
# VI Mode Anzeige
# ----------------------------------
VI_MODE="I"

zle-keymap-select() {
  local new="I"
  [[ $KEYMAP == vicmd ]] && new="N"
  if [[ $new != $VI_MODE ]]; then
    VI_MODE=$new
    zle reset-prompt
  fi
}

zle-line-init() {
  VI_MODE="I"
}

zle -N zle-keymap-select
zle -N zle-line-init

# ----------------------------------
# Prompt + Git
# ----------------------------------
precmd() {
  _lk_update_pwd
  _lk_update_git
}

PROMPT='%F{yellow}${VI_MODE}%f %F{green}${_lk_label}%f %F{white}${_lk_pwd}%f ${_lk_git}%# '

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

  typeset -U stack
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

# zsh-autosuggestions: Homebrew (macOS/Linuxbrew) oder Distro-Pakete
for _f in \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  "$HOME/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
do
  [[ -r "$_f" ]] && { source "$_f"; break; }
done
unset _f

# Ctrl+J → accept autosuggestion
bindkey -M viins '^J' autosuggest-accept

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#444444'

bindkey -M viins '^[[C' forward-char
