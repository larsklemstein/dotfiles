# =====================================================================
#  Common shell settings
# =====================================================================
source "$HOME/.common_interactive_sh"
setopt no_chase_links

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
if [[ -n $BREW_PREFIX && -f "$BREW_PREFIX/opt/zinit/zinit.zsh" ]]; then
  source "$BREW_PREFIX/opt/zinit/zinit.zsh"
  zinit ice wait lucid; zinit light zsh-users/zsh-completions
  zinit ice wait lucid; zinit light Aloxaf/fzf-tab
  zinit ice wait lucid; zinit light zsh-users/zsh-autosuggestions
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
#  Vi-mode
# =====================================================================
bindkey -v
export KEYTIMEOUT=1
bindkey -M menuselect '^N' down-line-or-history
bindkey -M menuselect '^P' up-line-or-history
setopt extendedglob
setopt globstarshort

# =====================================================================
#  Prompt: env-desc fallback to user@host
# =====================================================================
if [[ -f $HOME/.env_desc ]]; then
  ENV_DESC=$(<"$HOME/.env_desc")
else
  ENV_DESC="%n@%m"
fi

# ---------- vcs_info + branch-shortening ----------
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*:*' check-for-changes false
zstyle ':vcs_info:git:*' formats '[%b]'
zstyle ':vcs_info:*'     actionformats '[%b|%a]'

precmd_short() {
  vcs_info
  if [[ -n $vcs_info_msg_0_ ]]; then
    local limit=15
    local b="${vcs_info_msg_0_:1:${#vcs_info_msg_0_}-2}"
    if (( ${#b} > limit )); then
      b="${b:0:$((limit-1))}>"
      vcs_info_msg_0_="[$b]"
    fi
  fi
}

precmd_long() { vcs_info }

PROMPT_SHORT_BASE="%F{cyan}${ENV_DESC}%f %F{white}%2~%f%F{magenta}\${vcs_info_msg_0_:+ \$vcs_info_msg_0_}%f %# "
PROMPT_LONG_BASE="%F{cyan}%n@%m%f %F{white}%2~%f%F{magenta}\${vcs_info_msg_0_:+ \$vcs_info_msg_0_}%f %# "

precmd() { precmd_short }
PROMPT_BASE="$PROMPT_SHORT_BASE"
PROMPT="%F{green}[I]%f $PROMPT_BASE"

# live [I]/[N] indicator
function zle-keymap-select {
  case $KEYMAP in
    vicmd) PROMPT="%F{yellow}[N]%f $PROMPT_BASE" ;;
    *)     PROMPT="%F{green}[I]%f $PROMPT_BASE"  ;;
  esac
  zle reset-prompt
}
zle -N zle-keymap-select
function zle-line-init { zle -K viins }
zle -N zle-line-init

# switchers
prs() {
  precmd() { precmd_short }
  PROMPT_BASE="$PROMPT_SHORT_BASE"
  PROMPT="%F{green}[I]%f $PROMPT_BASE"
}
prl() {
  precmd() { precmd_long }
  PROMPT_BASE="$PROMPT_LONG_BASE"
  PROMPT="%F{green}[I]%f $PROMPT_BASE"
}

# =====================================================================
#  FZF & BAT configuration
# =====================================================================
export FZF_HEIGHT="70%"
export FZF_DEFAULT_OPTS="--layout=default --color=dark --border --height=${FZF_HEIGHT}"

# unified bat preview
export BAT_THEME="gruvbox-dark"
BAT_PREVIEW_CMD="bat --style=numbers --color=always --theme=${BAT_THEME} --line-range=:500 {}"

# =====================================================================
#  Key bindings
# =====================================================================
bindkey -M viins '^A' autosuggest-accept
bindkey -M viins '^R' fzf-history-widget
bindkey -M viins '^F' fzf-file-widget

# =====================================================================
#  Directory stack
# =====================================================================
setopt auto_pushd
setopt pushd_ignore_dups
DIRSTACKSIZE=12
alias dv='dirs -v'
alias dc='dirs -c'

g() {
  emulate -L zsh
  if [[ -z $1 || $1 != <-> ]]; then
    echo "Usage: g <number>"
    dirs -v; return 1
  fi
  eval "cd ~${1}" 2>/dev/null || { echo "g: no directory at index $1"; dirs -v; return 1; }
}


# =====================================================================
#  Widgets
# =====================================================================

# Ctrl-K → fuzzy-SWITCH directory
fzf_switch_dir() {
  local sel
  sel=$(fd --type d --hidden --exclude .git . | fzf) || return
  builtin cd "$sel"
  zle reset-prompt
}
zle -N fzf_switch_dir
bindkey -M viins '^K' fzf_switch_dir

# Ctrl-O → fuzzy-OPERATE: insert directory path + add to push-stack (absolute paths only)
fzf_insert_dir() {
  local sel abs
  sel=$(fd --type d --hidden --exclude .git . | fzf --height=${FZF_HEIGHT} --layout=default)
  if [[ -z $sel ]]; then
    zle reset-prompt
    return
  fi

  # absoluter Pfad
  abs=$(realpath "$sel")

  # Pfad in die aktuelle Eingabezeile einfügen
  LBUFFER+="$abs"
  zle redisplay

  # absoluten Pfad in den Stack pushen
  local -a newstack
  newstack=("$abs" "${dirstack[@]}")
  typeset -U newstack
  (( ${#newstack[@]} > DIRSTACKSIZE )) && newstack=("${newstack[@]:0:$DIRSTACKSIZE}")
  dirstack=("${newstack[@]}")
}

zle -N fzf_insert_dir
bindkey -M viins '^O' fzf_insert_dir


# Ctrl-G → pick directory from stack → cd (robust)
fzf_cd_stack() {
  emulate -L zsh
  local dir target
  dir=$(dirs -p | fzf --height=${FZF_HEIGHT} --layout=default)
  if [[ -z $dir ]]; then
    zle reset-prompt         # auch bei Abbruch Prompt neu zeichnen
    return
  fi
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

# Ctrl-E → fuzzy-edit file with nvim + bat preview
fzf_edit() {
  local file
  file=$(
    fd . --type f --hidden --exclude .git \
    | fzf --preview "${BAT_PREVIEW_CMD}" \
          --preview-window=right:60%
  )
  if [[ -z $file ]]; then
    zle reset-prompt          # auch bei Abbruch Prompt neu zeichnen
    return
  fi

  local dir="${file%/*}"
  [[ -z $dir ]] && dir="."
  pushd -q "$dir" && popd -q
  nvim "$file"
  zle reset-prompt            # Prompt nach Editor-Schließen neu zeichnen
}
zle -N fzf_edit
bindkey -M viins '^E' fzf_edit

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
| Ctrl-E                  | Fuzzy pick file → open in nvim (bat preview) |
| Ctrl-K                  | Fuzzy pick directory → SWITCH (cd)           |
| Ctrl-O                  | Fuzzy pick directory → OPERATE (insert path) |
| Ctrl-G                  | Pick directory from push-stack → cd          |
| g <N>                   | Jump to directory-stack entry N              |
| prs / prl               | Switch SHORT ↔ LONG prompt                   |
| dv / dc                 | Show / clear directory-stack                 |
| zm                      | Show this cheat-sheet                        |
+-------------------------+----------------------------------------------+
| Built-ins / Misc                                                       |
| Ctrl-L                  | Clear screen                                 |
+-------------------------+----------------------------------------------+
EOF
}
