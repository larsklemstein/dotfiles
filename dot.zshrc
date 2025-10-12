# =====================================================================
#  Common shell settings
# =====================================================================
source "$HOME/.common_interactive_sh"
setopt no_chase_links               # keep /tmp instead of /private/tmp on macOS

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
#  Completion
# =====================================================================
autoload -Uz compinit
compinit
zmodload zsh/complist
zstyle ':completion:*' completer _complete _ignored _approximate _correct
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:warnings'     format 'No matches for: %d'
zstyle ':completion:*'              menu select
zstyle ':completion:*'              matcher-list 'm:{a-z}={A-Z}'

# =====================================================================
#  History
# =====================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory inc_append_history extended_history hist_reduce_blanks hist_verify hist_ignore_dups

# =====================================================================
#  Vi-mode setup + prompt
# =====================================================================
bindkey -v
export KEYTIMEOUT=1
bindkey -M menuselect '^N' down-line-or-history
bindkey -M menuselect '^P' up-line-or-history
setopt extendedglob globstarshort prompt_subst

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*:*' check-for-changes false
zstyle ':vcs_info:git:*' formats '[%b]'
zstyle ':vcs_info:*'     actionformats '[%b|%a]'

if [[ -f $HOME/.env_desc ]]; then
  ENV_DESC=$(<"$HOME/.env_desc")
else
  ENV_DESC="%n@%m"
fi

shorten_branch() {
  local raw="$1" max=20
  local b="${raw#[[]}"
  b="${b%[]]}"
  (( ${#b} > max )) && print "${b[1,$((max-1))]}>" || print "$b"
}

precmd() {
  vcs_info
  [[ -n "$vcs_info_msg_0_" ]] \
      && BRANCH_NAME="[$(shorten_branch "$vcs_info_msg_0_")]" \
      || BRANCH_NAME=""
}

PROMPT_SHORT_BASE='%F{cyan}'"$ENV_DESC"'%f %F{white}%2~%f%F{magenta}${BRANCH_NAME}%f %# '

zle-keymap-select() {
  if [[ $KEYMAP == vicmd ]]; then
    PROMPT="%F{yellow}[N]%f $PROMPT_SHORT_BASE"
  else
    PROMPT="%F{green}[I]%f $PROMPT_SHORT_BASE"
  fi
  zle reset-prompt
}
zle -N zle-keymap-select

zle-line-init() { zle -K viins; zle reset-prompt }
zle -N zle-line-init

PROMPT="%F{green}[I]%f $PROMPT_SHORT_BASE"

# =====================================================================
#  fzf defaults
# =====================================================================
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_WIN_HEIGHT="80%"
export BAT_THEME="gruvbox-dark"

# =====================================================================
#  Directory-stack management
# =====================================================================
normalize_abs() {
  local p="$1"
  [[ -z "$p" ]] && return 1
  p="${~p}"
  local abs="${p:A}"
  abs="${abs%/}"
  print -r -- "$abs"
}

dedupe_stack_with_new() {
  local abs="$1" phys="${1:P}" e out=()
  for e in $dirstack; do
    [[ "$e" == "$abs" || "${e:P}" == "$phys" ]] && continue
    [[ "${e%/}" == "/" || "${e%/}" == "${HOME%/}" ]] && continue
    out+=("$e")
  done
  dirstack=("$abs" "${out[@]}")
}

push_dir_unique() {
  local abs home_norm
  abs="$(normalize_abs "$1")" || return
  home_norm="${HOME%/}"
  [[ "$abs" == "/" || "$abs" == "$home_norm" ]] && return
  dedupe_stack_with_new "$abs"
}

chpwd() {
  emulate -L zsh
  push_dir_unique "$PWD"
  local home_norm="${HOME%/}" e out=()
  for e in $dirstack; do
    [[ "${e%/}" == "/" || "${e%/}" == "$home_norm" ]] && continue
    out+=("$e")
  done
  dirstack=("${out[@]}")
  (( ${#dirstack[@]} > DIRSTACKSIZE )) &&
    dirstack=("${(@)dirstack[1,DIRSTACKSIZE]}")
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd chpwd
unsetopt auto_pushd
setopt pushd_ignore_dups
DIRSTACKSIZE=20

# =====================================================================
#  Autosuggestion + history
# =====================================================================
for map in viins vicmd main menuselect; do
  bindkey -M $map '^J' autosuggest-accept
  bindkey -M $map '^M' accept-line
  bindkey -M $map '^R' fzf-history-widget
done

# =====================================================================
#  fzf widgets
# =====================================================================
fzf_switch_dir() {
  local sel abs
  sel=$(fd --type d --hidden --exclude .git . | fzf --height="$FZF_WIN_HEIGHT")
  if [[ -n $sel ]]; then
    abs="$(normalize_abs "$sel")"
    [[ -n $abs ]] && builtin cd "$abs"
  fi
  zle reset-prompt
}
zle -N fzf_switch_dir
bindkey -M viins '^K' fzf_switch_dir

fzf_insert_dir() {
  local sel
  sel=$(fd --type d --hidden --exclude .git . | fzf --height="$FZF_WIN_HEIGHT")
  if [[ -n $sel ]]; then
    LBUFFER+="$sel"
    zle redisplay
    push_dir_unique "$sel"
  fi
  zle reset-prompt
}
zle -N fzf_insert_dir
bindkey -M viins '^O' fzf_insert_dir

# --- Robust directory-stack chooser (Ctrl-E) ---
__fzf_pick_dir_with_fd() {
  local sel abs
  sel=$(fd --type d --hidden --exclude .git . | fzf --height="${FZF_WIN_HEIGHT:-80%}")
  [[ -n $sel ]] || return 1
  abs="${${~sel}:A}"
  abs="${abs%/}"
  [[ -d $abs ]] && builtin cd -- "$abs"
}

__cd_from_stack_pick() {
  emulate -L zsh
  setopt pipe_fail
  local home_norm="${HOME%/}" filtered=() shown=() choice idx dir d d_norm

  # Build filtered stack (drop / and $HOME, non-existent)
  for d in $dirstack; do
    d_norm="${d%/}"
    [[ "$d_norm" == "/" || "$d_norm" == "$home_norm" ]] && continue
    [[ -d "$d" ]] || continue
    filtered+=("$d")
    shown+=("${d/#$HOME/~}")
  done

  # If stack empty, fall back to fzf dir picker
  if (( ${#filtered[@]} == 0 )); then
    __fzf_pick_dir_with_fd
    return
  fi

  if (( $+commands[fzf] )); then
    choice=$(
      for ((i=1; i<=${#filtered[@]}; i++)); do
        printf '%d\t%s\n' $i "$shown[$i]"
      done | fzf --height="${FZF_WIN_HEIGHT:-80%}" --with-nth=2
    )
    [[ -z "$choice" ]] && return 1
    idx="${choice%%$'\t'*}"
    [[ "$idx" == <-> ]] || return 1
    dir="${filtered[$idx]}"
  else
    echo "Directory stack:" >&2
    for ((i=1; i<=${#filtered[@]}; i++)); do
      printf '%2d  %s\n' $i "$shown[$i]" >&2
    done
    printf "Select (1-%d): " ${#filtered[@]} >&2
    read -r idx || return 1
    [[ "$idx" == <-> && idx -ge 1 && idx -le ${#filtered[@]} ]] || return 1
    dir="${filtered[$idx]}"
  fi

  dir="${dir/#\~/$HOME}"
  dir="${dir:A}"
  [[ -d "$dir" ]] && builtin cd -- "$dir"
}

fzf_cd_stack() { __cd_from_stack_pick; zle reset-prompt }
zle -N fzf_cd_stack

# Bind Ctrl-E → directory-stack chooser
for map in viins vicmd main menuselect; do
  bindkey -M $map '^E' fzf_cd_stack
done

# =====================================================================
#  Dir-stack helpers
# =====================================================================
g() {
  emulate -L zsh
  if [[ -z $1 || $1 != <-> ]]; then
    echo "Usage: g <number>"; dv; return 1
  fi
  local target
  target=$(eval echo "~$1")
  [[ -d $target ]] && builtin cd "$target" || { echo "g: invalid"; dv; }
}

dv() {
  local i=0
  for dir in $dirstack; do
    local shown="${dir/#$HOME/~}"
    printf '%2d  %s\n' $i "$shown"
    ((i++))
  done
}
alias dc='dirs -c'
for i in {0..19}; do eval "alias g$i='g $i; lltr'"; done

# =====================================================================
#  Clear screen
# =====================================================================
blink_clear() { command clear; echo; }
alias clear='blink_clear'
clear_and_echo() { blink_clear; zle reset-prompt }
zle -N clear_and_echo
bindkey -M viins '^L' clear_and_echo
bindkey -M vicmd '^L' clear_and_echo

# =====================================================================
#  Cheat-sheet
# =====================================================================
zm() {
  /bin/cat <<'EOF'
+-------------------------+----------------------------------------------+
| KEY / COMMAND           | ACTION                                       |
+-------------------------+----------------------------------------------+
| Ctrl-J                  | Accept autosuggestion (no execute)           |
| Enter                   | Execute (accept if present)                  |
| Ctrl-R                  | Fuzzy search history                         |
| Ctrl-F                  | Fuzzy pick file → insert path + add dir      |
| Ctrl-K                  | Fuzzy pick dir → SWITCH (cd)                 |
| Ctrl-O                  | Fuzzy pick dir → OPERATE (insert path)       |
| Ctrl-E                  | Choose dir from stack → cd (fallback: fd/fzf)|
| cdg                     | Command: choose dir from stack → cd          |
| g <N>                   | Jump to stack entry N                        |
| dv                      | List stack (home shortened)                  |
| dc                      | Clear directory stack                        |
| zm                      | Show this cheat-sheet                        |
+-------------------------+----------------------------------------------+
| Misc / Built-ins                                                       |
| Ctrl-L                  | Clear screen                                 |
+-------------------------+----------------------------------------------+
EOF
}
