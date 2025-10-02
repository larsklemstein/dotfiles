# ------------------------------------------------------------
#  Common shell settings
# ------------------------------------------------------------
source "$HOME/.common_interactive_sh"

# ------------------------------------------------------------
#  Detect Homebrew prefix
# ------------------------------------------------------------
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
else
  BREW_PREFIX=""
fi

# ------------------------------------------------------------
#  zinit plugin manager
# ------------------------------------------------------------
if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/opt/zinit/zinit.zsh" ]; then
  source "$BREW_PREFIX/opt/zinit/zinit.zsh"

  # Deferred plugins
  zinit ice wait lucid
  zinit light zsh-users/zsh-completions

  zinit ice wait lucid
  zinit light Aloxaf/fzf-tab

  zinit ice wait lucid
  zinit light zsh-users/zsh-autosuggestions

  # ↓ may re-enable later if you want highlighting
  # zinit ice wait lucid
  # zinit light zsh-users/zsh-syntax-highlighting   # keep LAST
fi

# ------------------------------------------------------------
#  Tmux: start each new session in the directory you launch from
#  - Names each session after the current folder (avoids confusion)
#  - Ignores any old default-path set by `tmh` in previous sessions
# ------------------------------------------------------------
alias tmux='tmux new-session -s "$(basename "$PWD")-$(date +%H%M%S)" -c "$PWD"'

# ------------------------------------------------------------
#  Completion system
# ------------------------------------------------------------
autoload -Uz compinit
compinit

zmodload zsh/complist   # for menu-select keymap

zstyle ':completion:*' completer _complete _ignored _approximate _correct
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:warnings'     format 'No matches for: %d'
zstyle ':completion:*'              menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'   # case-insensitive

# ------------------------------------------------------------
#  History
# ------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory inc_append_history extended_history hist_reduce_blanks hist_verify hist_ignore_dups

# ------------------------------------------------------------
#  Vi-mode editing
# ------------------------------------------------------------
bindkey -v
export KEYTIMEOUT=1
bindkey -M menuselect '^N' down-line-or-history
bindkey -M menuselect '^P' up-line-or-history

setopt extendedglob
setopt globstarshort

# ------------------------------------------------------------
#  Prompt with live vi-mode tag + git branch
# ------------------------------------------------------------
setopt prompt_subst
autoload -Uz vcs_info

# Git branch styles
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*:*' check-for-changes false
zstyle ':vcs_info:git:*' formats '[%b]'
zstyle ':vcs_info:*'     actionformats '[%b|%a]'

# only run on each new prompt (no chpwd hook)
precmd() { vcs_info }

PROMPT_BASE='%F{cyan}%n@%m%f %F{white}%2~%f%F{magenta}${vcs_info_msg_0_:+ $vcs_info_msg_0_}%f %# '

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

PROMPT="%F{green}[I]%f $PROMPT_BASE"

# ------------------------------------------------------------
#  fzf integration
# ------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if command -v fn >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fn --type f --hidden --follow --exclude .git .'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fn --type d --hidden --exclude .git .'
elif command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git .'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git .'
fi

bindkey -M viins '^E' autosuggest-accept
bindkey -M viins '^R' fzf-history-widget

# fuzzy **file** picker (Ctrl-F)
bindkey '^F' fzf-file-widget
bindkey -M viins '^F' fzf-file-widget

# silent fuzzy-cd (Ctrl-G)
silent-cd() {
  local dir
  if command -v fn >/dev/null 2>&1; then
    dir=$(fn --type d --hidden --exclude .git . | fzf --no-clear) || return
  else
    dir=$(fd --type d --hidden --exclude .git . | fzf --no-clear) || return
  fi
  builtin cd "$dir"
  zle reset-prompt          # redraw prompt (branch shows after first Enter)
}
zle -N silent-cd
bindkey '^G' silent-cd

# fuzzy **insert directory path** (Ctrl-P)
fzf-insert-dir() {
  local dir
  if command -v fn >/dev/null 2>&1; then
    dir=$(fn --type d --hidden --exclude .git . | fzf) || return
  else
    dir=$(fd --type d --hidden --exclude .git . | fzf) || return
  fi
  LBUFFER+="$dir"
  zle redisplay
}
zle -N fzf-insert-dir
bindkey '^P' fzf-insert-dir

# --- tmh : set tmux session’s future panes/windows to current dir ---
tmh() {
  if [[ -z $TMUX ]]; then
    echo "Not inside a tmux session." >&2
    return 1
  fi
  local dir=$PWD
  # prepend a cd to the default-command
  tmux set-option -g default-command "cd $dir; exec ${SHELL:-/bin/zsh} -l"
  echo "All new panes/windows will start in: $dir"
}

# optional reset: revert to plain login shell
tmr() {
  if [[ -z $TMUX ]]; then
    echo "Not inside a tmux session." >&2
    return 1
  fi
  tmux set-option -g default-command ""
  echo "tmux default-command reset (splits inherit active pane again)."
}

# ------------------------------------------------------------
# Clear screen: nicer behaviour on Blink/iPad
# ------------------------------------------------------------

# Function that always does the nicer clear
function blink_clear() {
  command clear        # call the real /usr/bin/clear
  echo                 # extra blank line to push prompt down
}

# Detect Blink
if true
then
    # Alias clear → blink_clear
    #
    alias clear='blink_clear'

    # Widget for Ctrl-L inside ZLE
    function clear_and_echo() { blink_clear; zle reset-prompt }
    zle -N clear_and_echo

    bindkey -M viins '^L' clear_and_echo
    bindkey -M vicmd '^L' clear_and_echo
else
    # on macOS desktop keep default clear
    unalias clear 2>/dev/null
fi

# ------------------------------------------------------------
#  zm : simple ASCII cheat-sheet
# ------------------------------------------------------------
zm() {
  cat <<'EOF'
+------------------------+-----------------------------------------------+
| KEY / COMMAND          | ACTION                                        |
+------------------------+-----------------------------------------------+
| [I] / [N]              | Shows vi-insert / vi-normal mode              |
| ↑ / ↓                  | Navigate shell history                        |
| Ctrl-R                 | Fzf-powered history search (insert mode)      |
| Ctrl-E                 | Accept grey autosuggestion                    |
| Ctrl-F                 | Fuzzy file picker → insert path(s)            |
| Ctrl-G                 | Silent fuzzy-cd → change directory            |
| Ctrl-P                 | Fuzzy-choose directory → insert path          |
| TAB                    | Fzf-tab completion popup                      |
| zm                     | Show this cheat-sheet                         |
+------------------------+-----------------------------------------------+
| INSERT-MODE EDITING KEYS (built-in)                                    |
| Ctrl-U                 | Delete from cursor → start of line            |
| Ctrl-K                 | Delete from cursor → end of line              |
| Ctrl-A                 | Move cursor to start of line                  |
| Ctrl-E                 | Move cursor to end of line                    |
| Ctrl-L                 | Clear screen                                  |
+------------------------+-----------------------------------------------+
EOF
}

