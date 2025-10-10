# =====================================================================
#  Common shell settings
# =====================================================================
source "$HOME/.common_interactive_sh"
setopt no_chase_links               # behalte /tmp statt /private/tmp

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
#  Vi-Mode
# =====================================================================
bindkey -v
export KEYTIMEOUT=1
bindkey -M menuselect '^N' down-line-or-history
bindkey -M menuselect '^P' up-line-or-history
setopt extendedglob
setopt globstarshort

# =====================================================================
#  Prompt mit ENV_DESC + Branch-Kürzung
# =====================================================================
if [[ -f $HOME/.env_desc ]]; then
  ENV_DESC=$(<"$HOME/.env_desc")
else
  ENV_DESC="%n@%m"
fi

setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*:*' check-for-changes false
zstyle ':vcs_info:git:*' formats '[%b]'
zstyle ':vcs_info:*'     actionformats '[%b|%a]'

# Git-Branch ggf. kürzen (max 20 Zeichen inkl. >)
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
PROMPT_LONG_BASE='%F{cyan}%n@%m%f %F{white}%2~%f%F{magenta}${vcs_info_msg_0_}%f %# '

# -------------------------------------------------
# Globaler Prompt-Mode: "short" (Default) / "long"
# -------------------------------------------------
PR_MODE="short"

zle-keymap-select() {
  if [[ $PR_MODE == "long" ]]; then
    # langer Prompt immer mit user@host
    [[ $KEYMAP = vicmd ]] \
        && PROMPT="%F{yellow}[N]%f $PROMPT_LONG_BASE" \
        || PROMPT="%F{green}[I]%f $PROMPT_LONG_BASE"
  else
    # kurzer Prompt mit ENV_DESC + ggf. gekürztem Branch
    [[ $KEYMAP = vicmd ]] \
        && PROMPT="%F{yellow}[N]%f $PROMPT_SHORT_BASE" \
        || PROMPT="%F{green}[I]%f $PROMPT_SHORT_BASE"
  fi
  zle reset-prompt
}
zle -N zle-keymap-select
zle-line-init() { zle -K viins }
zle -N zle-line-init

# Start-Prompt
PROMPT="%F{green}[I]%f $PROMPT_SHORT_BASE"

prl() {
  PR_MODE="long"
  if zle >/dev/null 2>&1; then
    zle-keymap-select
  fi
}

prs() {
  PR_MODE="short"
  if zle >/dev/null 2>&1; then
    zle-keymap-select
  fi
}

# =====================================================================
#  fzf Defaults
# =====================================================================
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_WIN_HEIGHT="80%"
export BAT_THEME="gruvbox-dark"

# =====================================================================
#  Key-Bindings
# =====================================================================
bindkey -M viins '^@' autosuggest-accept
bindkey -M viins '^R' fzf-history-widget
bindkey -M viins '^F' fzf-file-widget

# =====================================================================
#  Widgets
# =====================================================================
# Ctrl-K → fuzzy-switch dir (cd)
fzf_switch_dir() {
  local sel
  sel=$(fd --type d --hidden --exclude .git . |
        fzf --height="$FZF_WIN_HEIGHT" --layout=default)
  [[ -n $sel ]] && builtin cd "$sel"
  zle reset-prompt
}
zle -N fzf_switch_dir
bindkey -M viins '^K' fzf_switch_dir

fzf_insert_dir() {
  local sel abs
  sel=$(fd --type d --hidden --exclude .git . |
        fzf --height="$FZF_WIN_HEIGHT" --layout=default)
  if [[ -n $sel ]]; then
    LBUFFER+="$sel"
    zle redisplay
    abs=$(cd "$sel" 2>/dev/null && pwd -P)
    if [[ -n $abs ]]; then
      # remove existing occurrence, then push to top
      dirstack=(${(@)dirstack:#$abs})
      dirstack=("$abs" "${(@)dirstack}")
    fi
  fi
  zle reset-prompt
}
zle -N fzf_insert_dir
bindkey -M viins '^O' fzf_insert_dir

# Ctrl-G → choose dir from stack → cd
fzf_cd_stack() {
  local choice dir
  choice=$(dirs -v | fzf --height="$FZF_WIN_HEIGHT" --layout=default)
  if [[ -n $choice ]]; then
    dir=$(echo "$choice" | awk '{print $2}')
    dir=$(eval echo "$dir")
    [[ -n $dir ]] && builtin cd "$dir"
  fi
  zle reset-prompt
}
zle -N fzf_cd_stack
bindkey -M viins '^G' fzf_cd_stack

fzf_edit() {
  local file dir abs
  file=$(fd . --type f --hidden --exclude .git |
         fzf --height="$FZF_WIN_HEIGHT" \
             --preview "bat --theme=$BAT_THEME --style=numbers --color=always {}" \
             --preview-window=right:60%)
  if [[ -n $file ]]; then
    dir="${file:h}"
    abs=$(cd "$dir" 2>/dev/null && pwd -P)
    if [[ -n $abs ]]; then
      # remove duplicates, then push on top
      dirstack=(${(@)dirstack:#$abs})
      dirstack=("$abs" "${(@)dirstack}")
    fi
    nvim "$file"
  fi
  zle reset-prompt
}
zle -N fzf_edit
bindkey -M viins '^E' fzf_edit

# =====================================================================
#  Dir-Stack mit g-Fix gegen Doppel-Einträge
# =====================================================================
g() {
  emulate -L zsh
  if [[ -z $1 || $1 != <-> ]]; then
    echo "Usage: g <number>"; dirs -v; return 1
  fi
  local target
  target=$(eval echo "~$1")
  if [[ -d $target ]]; then
    dirstack=(${(@)dirstack:#$target})   # ggf. Duplikat entfernen
    builtin cd "$target"
  else
    echo "g: no directory at index $1"; dirs -v; return 1
  fi
}

alias dv='dirs -v'
alias dc='dirs -c'

setopt auto_pushd
setopt pushd_ignore_dups
DIRSTACKSIZE=20

chpwd() {
  typeset -U dirstack
  (( ${#dirstack[@]} > DIRSTACKSIZE )) &&
      dirstack=("${(@)dirstack[1,DIRSTACKSIZE]}")
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd chpwd

for i in {0..19}; do
  eval "alias g$i='g $i; lltr'"
done

# =====================================================================
#  Clear-Screen
# =====================================================================
blink_clear() { command clear; echo; }
alias clear='blink_clear'
clear_and_echo() { blink_clear; zle reset-prompt }
zle -N clear_and_echo
bindkey -M viins '^L' clear_and_echo
bindkey -M vicmd '^L' clear_and_echo

# =====================================================================
#  zm-Cheat-Sheet
# =====================================================================
zm() {
  /bin/cat <<'EOF'
+-------------------------+----------------------------------------------+
| KEY / COMMAND           | ACTION                                       |
+-------------------------+----------------------------------------------+
| Ctrl-<space>            | Accept grey autosuggestion                   |
| Ctrl-R                  | Fuzzy search history                         |
| Ctrl-F                  | Fuzzy pick file → insert path                |
| Ctrl-K                  | Fuzzy pick dir  → SWITCH (cd)                |
| Ctrl-O                  | Fuzzy pick dir  → OPERATE (insert path)      |
| Ctrl-G                  | Choose dir from push-stack → cd              |
| Ctrl-E                  | Fuzzy-edit file with preview                 |
| g <N>                   | Jump to push-stack entry N                   |
| g0..g19                 | Jump & list (lltr)                           |
| zm                      | Show this cheat-sheet                        |
+-------------------------+----------------------------------------------+
| Built-ins / Misc                                                       |
| Ctrl-L                  | Clear screen                                 |
+-------------------------+----------------------------------------------+
EOF
}
