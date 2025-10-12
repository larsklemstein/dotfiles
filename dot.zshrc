# =====================================================================
#  Overview:
#  ----------
#  This configuration provides a carefully balanced, high-performance
#  Zsh environment designed for consistent behavior across:
#      • macOS (iTerm2, Terminal.app)
#      • Blink (iPadOS)
#      • Linux / Debian / PuTTY
#
#  Core principles:
#    • Pure Zsh implementation — minimal plugins, no async redraws
#    • Fast startup (<100 ms)
#    • Predictable vi-mode behavior
#    • Portable keybindings, same everywhere
#    • Strong separation of logic and presentation
#
#  Plugins:
#    • zsh-users/zsh-autosuggestions   – inline grey autosuggestions
#    • Aloxaf/fzf-tab                  – fzf-enhanced tab completion
#    • zsh-users/zsh-completions       – extended completion database
#
#  Keybinding summary:
#  -------------------
#   Ctrl-J   → Accept autosuggestion (insert only, don’t execute)
#   Enter    → Execute current command line
#   Ctrl-R   → Fuzzy search command history (fzf-history-widget)
#   Ctrl-F   → Fuzzy pick file → insert path + push dir
#   Ctrl-K   → Fuzzy pick directory → switch (cd)
#   Ctrl-O   → Fuzzy pick directory → insert path only
#   Ctrl-E   → Choose directory from Zsh dir-stack → cd
#   Ctrl-L   → Clear screen and reset prompt
#
#   dv       → List directory stack
#   dc       → Clear directory stack
#   g <N>    → Jump to stack entry N
#   zm       → Show this built-in cheat sheet
#
#  Directory stack:
#  ----------------
#   • Uses pure Zsh pushd/popd mechanics (no custom hooks)
#   • Ensures natural ordering and maximum portability
#   • Ctrl-E shows stack in fzf chooser for instant navigation
#
#  Prompt:
#  -------
#   • Displays user@host, short path, and (truncated) Git branch
#   • Vi-mode indicator: [I] insert mode / [N] normal mode
#
#  Design tags:
#  ------------
#     lkl_zsh_v1.2.0_balanced
#     verified with validate_zsh_env.zsh
#
# =====================================================================

[[ -o interactive ]] || return

# ----------------------------- Core ----------------------------------
source "$HOME/.common_interactive_sh" 2>/dev/null || true
setopt no_chase_links

# Homebrew prefix (optional)
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
else
  BREW_PREFIX=""
fi

# ----------------------------- Plugins -------------------------------
if [[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/opt/zinit/zinit.zsh" ]]; then
  source "$BREW_PREFIX/opt/zinit/zinit.zsh"
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-autosuggestions
  zinit light Aloxaf/fzf-tab
fi

# --------------------------- Completion ------------------------------
autoload -Uz compinit
compinit
zmodload zsh/complist
zstyle ':completion:*' completer _complete _ignored _approximate _correct
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ----------------------------- History -------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory inc_append_history hist_ignore_dups

# ---------------------- Vi-mode + Prompt -----------------------------
bindkey -v
export KEYTIMEOUT=1
setopt prompt_subst extendedglob globstarshort

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
  if [[ -n "$vcs_info_msg_0_" ]]; then
    BRANCH_NAME="[$(shorten_branch "$vcs_info_msg_0_")]"
  else
    BRANCH_NAME=""
  fi
}

PROMPT_BASE='%F{cyan}'"$ENV_DESC"'%f %F{white}%2~%f%F{magenta}${BRANCH_NAME}%f %# '

zle-keymap-select() {
  if [[ $KEYMAP == vicmd ]]; then
    PROMPT="%F{yellow}[N]%f $PROMPT_BASE"
  else
    PROMPT="%F{green}[I]%f $PROMPT_BASE"
  fi
  zle reset-prompt
}
zle -N zle-keymap-select

zle-line-init() { zle -K viins; zle reset-prompt; }
zle -N zle-line-init

PROMPT="%F{green}[I]%f $PROMPT_BASE"

# ------------------------- fzf defaults ------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_WIN_HEIGHT="80%"
export BAT_THEME="gruvbox-dark"
: "${FZF_MAX_DIRS:=30000}"
: "${FZF_MAX_FILES:=200000}"

# ----------------------- Directory stack -----------------------------
setopt auto_pushd pushd_ignore_dups pushd_silent
DIRSTACKSIZE=20

# -------------------------- fzf widgets ------------------------------

# Ctrl-K → directories only → cd
fzf_switch_dir() {
  local dir
  dir=$(fd --type d --hidden --exclude .git --max-results "$FZF_MAX_DIRS" . 2>/dev/null \
        | command fzf --height="$FZF_WIN_HEIGHT" --ansi --prompt='dirs › ')
  [[ -n $dir ]] && builtin cd -- "$dir"
  zle reset-prompt
}
zle -N fzf_switch_dir

# Ctrl-O → directories only → insert path
fzf_insert_dir() {
  local dir
  dir=$(fd --type d --hidden --exclude .git --max-results "$FZF_MAX_DIRS" . 2>/dev/null \
        | command fzf --height="$FZF_WIN_HEIGHT" --ansi --prompt='insert-dir › ')
  [[ -n $dir ]] && LBUFFER+="$dir"
  zle redisplay
  zle reset-prompt
}
zle -N fzf_insert_dir

# Ctrl-F → files only → insert path + preview
fzf_file_insert_and_push() {
  local file
  file=$(fd --type f --hidden --exclude .git --max-results "$FZF_MAX_FILES" . 2>/dev/null \
        | command fzf --height="$FZF_WIN_HEIGHT" --ansi --prompt='files › ' \
            --preview 'bat --theme=gruvbox-dark --style=numbers --color=always {}' \
            --preview-window=right:60%:wrap)
  [[ -n $file ]] && LBUFFER+="$file"
  zle redisplay
  zle reset-prompt
}
zle -N fzf_file_insert_and_push

# Ctrl-E → reliable dir-stack chooser → cd
fzf_cd_stack() {
  local choice idx dir
  choice=$(
    dirs -v | awk '{printf "%s\t%s\n",$1,$2}' |
    command fzf --height="${FZF_WIN_HEIGHT:-80%}" --ansi --no-sort \
      --with-nth=2 --prompt='stack › '
  ) || return
  [[ -z $choice ]] && return
  dir="${choice#*	}"         # strip index
  dir="${dir/#\~/$HOME}"      # expand tilde
  dir="${dir:A}"              # normalize to absolute
  [[ -d $dir ]] && builtin cd -- "$dir"
  zle reset-prompt
}
zle -N fzf_cd_stack

# --------------------------- Clear screen ----------------------------
blink_clear() { command clear; echo; }
alias clear='blink_clear'
clear_and_echo() { blink_clear; zle reset-prompt; }
zle -N clear_and_echo

# ------------------------- Dir stack helpers -------------------------
dv() { dirs -v; }
alias dc='dirs -c'
for i in {0..19}; do eval "alias g$i='cd ~$i'"; done

# ----------------------------- Bindings ------------------------------
for m in viins vicmd main menuselect; do
  bindkey -M $m '^J' autosuggest-accept
  bindkey -M $m '^M' accept-line
  bindkey -M $m '^R' fzf-history-widget
  bindkey -M $m '^F' fzf_file_insert_and_push
  bindkey -M $m '^K' fzf_switch_dir
  bindkey -M $m '^O' fzf_insert_dir
  bindkey -M $m '^E' fzf_cd_stack
  bindkey -M $m '^L' clear_and_echo
done

# ---------------------------- Cheat sheet ----------------------------
zm() {
  /bin/cat <<'EOF'
+-------------------------+----------------------------------------------+
| KEY / COMMAND           | ACTION                                       |
+-------------------------+----------------------------------------------+
| Ctrl-J                  | Accept autosuggestion (no execute)           |
| Enter                   | Execute (accept if present)                  |
| Ctrl-R                  | Fuzzy search history                         |
| Ctrl-F                  | Files only  → insert path (bat preview)      |
| Ctrl-K                  | Directories → cd                             |
| Ctrl-O                  | Directories → insert path                    |
| Ctrl-E                  | Dir-stack chooser → cd                       |
| dv                      | Show directory stack (dirs -v)               |
| dc                      | Clear stack                                  |
+-------------------------+----------------------------------------------+
EOF
}
