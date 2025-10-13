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
#   Ctrl-J   → Accept autosuggestion (insert only)
#   Enter    → Execute current command line
#   Ctrl-R   → Fuzzy search command history
#   Ctrl-F   → Files only:
#                – if line empty → open in $EDITOR
#                – otherwise → insert file path
#   Ctrl-P   → Directories only:
#                – if line empty → cd into dir
#                – otherwise → insert dir path
#   Ctrl-G   → Fuzzy choose directory from stack → cd
#   Ctrl-L   → Clear screen
#
#   dv       → List directory stack
#   dc       → Clear directory stack
#   zm       → Show this built-in cheat sheet
#
#  Prompt:
#  -------
#   • Displays user@host, short path, and (truncated) Git branch
#   • Vi-mode indicator: [I] insert mode / [N] normal mode
#
#  Design tags:
#  ------------
#     lkl_zsh_v1.3.2_contextual_ctrlg
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

# Helper: detect empty or whitespace-only command line
is_empty_buffer() {
  [[ -z "${BUFFER//[[:space:]]/}" ]]
}

# Ctrl-F → files only → insert or edit depending on context
fzf_file_action() {
  local file
  file=$(fd --type f --hidden --exclude .git --max-results "$FZF_MAX_FILES" . 2>/dev/null \
        | command fzf --height="$FZF_WIN_HEIGHT" --ansi --prompt='files › ' \
            --preview 'bat --theme=gruvbox-dark --style=numbers --color=always {}' \
            --preview-window=right:60%:wrap) || { zle reset-prompt; return; }

  [[ -z $file ]] && { zle reset-prompt; return; }

  pushd $(dirname "$file")

  if is_empty_buffer; then
    ${EDITOR:-vi} "$file"
    zle reset-prompt
  else
    LBUFFER+="$file"
    zle redisplay
  fi
}
zle -N fzf_file_action

# Ctrl-P → directories only → cd or insert depending on context
fzf_dir_action() {
  local dir
  dir=$(fd --type d --hidden --exclude .git --max-results "$FZF_MAX_DIRS" . 2>/dev/null \
        | command fzf --height="$FZF_WIN_HEIGHT" --ansi --prompt='dirs › ') || { zle reset-prompt; return; }

  [[ -z $dir ]] && { zle reset-prompt; return; }

  pushd "$dir"

  if is_empty_buffer; then
    builtin cd -- "$dir"
    zle reset-prompt
  else
    LBUFFER+="$dir"
    zle redisplay
  fi
}
zle -N fzf_dir_action

# Ctrl-G → choose directory from stack and cd
fzf_cd_stack() {
  local choice dir
  choice=$(
    dirs -v | awk '{printf "%s\t%s\n",$1,$2}' |
    command fzf --height="${FZF_WIN_HEIGHT:-80%}" --ansi --no-sort \
      --with-nth=2 --prompt='stack › '
  ) || { zle reset-prompt; return; }
  [[ -z $choice ]] && { zle reset-prompt; return; }

  dir="${choice#*	}"         # strip index
  dir="${dir/#\~/$HOME}"      # expand tilde
  dir="${dir:A}"              # normalize absolute
  [[ -d $dir ]] && builtin cd -- "$dir"
  zle reset-prompt
}
zle -N fzf_cd_stack

# ----------------------- Dir stack commands --------------------------
dv() { dirs -v; }
dc() { dirs -c; }

alias C='clear'

# ----------------------------- Bindings ------------------------------
for m in viins vicmd main menuselect; do
  bindkey -M $m '^J' autosuggest-accept
  bindkey -M $m '^M' accept-line
  bindkey -M $m '^R' fzf-history-widget
  bindkey -M $m '^F' fzf_file_action
  bindkey -M $m '^A' fzf_dir_action
  bindkey -M $m '^E' fzf_cd_stack
done


# ---------------------------- Cheat sheet ----------------------------
zm() {
  /bin/cat <<'EOF'
+-------------------------+----------------------------------------------+
| KEY / COMMAND           | ACTION                                       |
+-------------------------+----------------------------------------------+
| Ctrl-J                  | Accept autosuggestion                        |
| Enter                   | Execute current command line                 |
| Ctrl-R                  | Fuzzy search history                         |
| Ctrl-F                  | Files: edit (empty line) / insert (non-empty)|
| Ctrl-A                  | Dirs:  cd (empty line) / insert (non-empty)  |
| Ctrl-E                  | Choose directory from stack → cd             |
| C                       | Clear screen                                 |
| dv                      | Show directory stack                         |
| dc                      | Clear stack                                  |
+-------------------------+----------------------------------------------+
EOF
}

