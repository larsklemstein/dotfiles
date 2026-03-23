# =====================================================================
#  Overview:
#  ----------
#  This configuration provides a carefully balanced, high-performance
#  Zsh environment designed for consistent behavior across:
#      - macOS (iTerm2, Terminal.app)
#      - Blink (iPadOS)
#      - Linux / Debian / PuTTY
#
#  Core principles:
#    - Pure Zsh implementation — minimal plugins, no async redraws
#    - Fast startup (<100 ms)
#    - Predictable vi-mode behavior
#    - Portable keybindings, same everywhere
#    - Strong separation of logic and presentation
#
#  Plugins:
#    - zsh-users/zsh-autosuggestions   - inline grey autosuggestions
#    - Aloxaf/fzf-tab                  - fzf-enhanced tab completion
#    - zsh-users/zsh-completions       - extended completion database
#
#  Keybinding summary:
#  -------------------
#   Ctrl-J   -> Accept autosuggestion (insert only)
#   Enter    -> Execute current command line
#   Ctrl-R   -> Fuzzy search command history
#   Ctrl-F   -> Files only:
#                - if line empty -> open in $EDITOR
#                - otherwise     -> insert file path
#   Ctrl-A   -> Directories only:
#                - if line empty -> cd into dir
#                - otherwise     -> insert dir path
#   Ctrl-E   -> Fuzzy choose directory from stack -> cd
#   C        -> Clear screen
#
#   d        -> List directory stack
#   dc       -> Clear directory stack
#   zm       -> Show this built-in cheat sheet
#
#  Prompt:
#  -------
#   - Displays user@host, short path, and (truncated) Git branch
#   - Vi-mode indicator: [I] insert mode / [N] normal mode
#
#  Design tags:
#     lkl_zsh_v1.3.2_contextual_ctrlg
# =====================================================================

[[ -o interactive ]] || return

# =====================================================================
#  EARLY PERSISTENT DIRSTACK (must run before plugins!)
# =====================================================================

setopt auto_cd autopushd pushd_ignore_dups pushd_silent
DIRSTACKSIZE=20

save_dirstack() {
  [[ -n "$RESTORING_DSTACK" ]] && return
  {
    print -r -- "$PWD"
    local d
    for d in "${dirstack[@]}"; do
      print -r -- "$d"
    done
  } > ~/.zdirs
}

restore_dirstack() {
  [[ -r ~/.zdirs ]] || return

  # Load saved array
  local -a saved
  saved=("${(@f)$(< ~/.zdirs)}")
  (( ${#saved[@]} )) || return

  RESTORING_DSTACK=1

  # 1) Restore PWD first (saved[1])
  local new_pwd="${saved[1]}"
  if [[ -d "$new_pwd" ]]; then
    builtin cd -- "$new_pwd"
  fi

  # 2) Explicitly rebuild the dirstack array
  #    This avoids stray entries injected by plugins
  local -a new_stack
  if (( ${#saved[@]} > 1 )); then
    new_stack=("${saved[@]:1}")   # from index 2 -> end
  else
    new_stack=()
  fi

  # 3) Overwrite the global dirstack with the clean version
  dirstack=("${new_stack[@]}")

  unset RESTORING_DSTACK
}


restore_dirstack

autoload -Uz add-zsh-hook
add-zsh-hook chpwd save_dirstack

# =====================================================================
#  CORE CONFIG
# =====================================================================

source "$HOME/.common_interactive_sh" 2>/dev/null || true
setopt no_chase_links

# Homebrew prefix
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
else
  BREW_PREFIX=""
fi

# =====================================================================
#  PLUGINS
# =====================================================================

if [[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/opt/zinit/zinit.zsh" ]]; then
  source "$BREW_PREFIX/opt/zinit/zinit.zsh"
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-autosuggestions
  zinit light Aloxaf/fzf-tab
fi

# =====================================================================
#  COMPLETION
# =====================================================================

autoload -Uz compinit
compinit
zmodload zsh/complist

zstyle ':completion:*' completer _complete _ignored _approximate _correct
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# =====================================================================
#  HISTORY
# =====================================================================

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory inc_append_history hist_ignore_dups

# =====================================================================
#  PROMPT + VI MODE
# =====================================================================

bindkey -v
export KEYTIMEOUT=1
setopt prompt_subst extendedglob globstarshort

autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*:*' check-for-changes false
zstyle ':vcs_info:git:*' formats '[%b]'
zstyle ':vcs_info:*'     actionformats '[%b|%a]'

export PRE_COMMIT_COLOR=never

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

# =====================================================================
#  FZF DEFAULTS
# =====================================================================

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_WIN_HEIGHT="80%"
export BAT_THEME="gruvbox-dark"
: "${FZF_MAX_DIRS:=20000}"
: "${FZF_MAX_FILES:=100000}"

# =====================================================================
#  FZF WIDGETS (unchanged)
# =====================================================================

is_empty_buffer() {
  [[ -z "${BUFFER//[[:space:]]/}" ]]
}

fzf_file_action() {
  local file
  file=$(fd --type f --max-results "$FZF_MAX_FILES" . 2>/dev/null \
        | command fzf --height="$FZF_WIN_HEIGHT" --ansi --prompt='files > ' \
          --preview 'file --mime {}|grep -qi binary && file -b {} || bat --paging=never --style=numbers --line-range :250 --wrap=never --color=always {}' \
          --preview-window=right:60%) || { zle reset-prompt; return; }

  [[ -z $file ]] && { zle reset-prompt; return; }

  dirstack=($(dirname "$file") $dirstack)

  if is_empty_buffer; then
    ${EDITOR:-vi} "$file"
    zle reset-prompt
  else
    LBUFFER+="$file"
    zle redisplay
  fi
}
zle -N fzf_file_action

fzf_dir_action() {
  local dir
  dir=$(fd --type d --max-results "$FZF_MAX_DIRS" . 2>/dev/null \
        | command fzf --height="$FZF_WIN_HEIGHT" --ansi --prompt='dirs > ' \
          --preview 'tree -C -d --noreport {}') \
        || { zle reset-prompt; return; }

  [[ -z $dir ]] && { zle reset-prompt; return; }

  dirstack=("$dir" $dirstack)

  if is_empty_buffer; then
    builtin cd -- "$dir"
    zle reset-prompt
  else
    LBUFFER+="$dir"
    zle redisplay
  fi
}
zle -N fzf_dir_action

fzf_cd_stack() {
  local choice dir
  choice=$(
    dirs -v | awk '{printf "%s\t%s\n",$1,$2}' |
    command fzf --height="${FZF_WIN_HEIGHT:-80%}" --ansi --no-sort \
      --with-nth=2 --prompt='stack > '
  ) || { zle reset-prompt; return; }
  [[ -z $choice ]] && { zle reset-prompt; return; }

  dir="${choice#*	}"
  dir="${dir/#\~/$HOME}"
  dir="${dir:A}"
  [[ -d $dir ]] && builtin cd -- "$dir"
  zle reset-prompt
}
zle -N fzf_cd_stack

el() {
    local h_id
    h_id=$(history | grep "$EDITOR" | tail -1 | awk '{print $1}')
    [ -z "$h_id" ] && { echo '???' >&2; return 1; }
    fc -e - "$h_id"
}

# =====================================================================
#  DSTACK COMMANDS
# =====================================================================

d() { dirs -v; }
dc() { dirs -c; }

alias C='clear'

# =====================================================================
#  KEYBINDINGS
# =====================================================================

for m in viins vicmd main menuselect; do
  bindkey -M $m '^J' autosuggest-accept
  bindkey -M $m '^M' accept-line
  bindkey -M $m '^R' fzf-history-widget
  bindkey -M $m '^F' fzf_file_action
  bindkey -M $m '^A' fzf_dir_action
  bindkey -M $m '^E' fzf_cd_stack
done

# =====================================================================
#  CHEAT SHEET
# =====================================================================

zm() {
  /bin/cat <<'EOF'
+-------------------------+----------------------------------------------+
| KEY / COMMAND           | ACTION                                       |
+-------------------------+----------------------------------------------+
| Ctrl-J                  | Accept autosuggestion                        |
| Enter                   | Execute current command line                 |
| Ctrl-R                  | Fuzzy search history                         |
| Ctrl-F                  | Files: edit / insert                         |
| Ctrl-A                  | Dirs:  cd / insert                           |
| Ctrl-E                  | Choose directory from stack -> cd            |
| C                       | Clear screen                                 |
| d                       | Show directory stack                         |
| dc                      | Clear stack                                  |
+-------------------------+----------------------------------------------+
EOF
}
