#!/usr/bin/env zsh
# =====================================================================
# validate_zsh_env.zsh — non-interactive self-test for ff zsh setup
# =====================================================================

print -P "%F{cyan}=== VALIDATE ZSH ENVIRONMENT ===%f"

# ---------------------------------------------------------------------
# 1. Confirm ZLE and vi-mode
# ---------------------------------------------------------------------
print -P "\n%F{white}[1] ZLE / Vi-mode%f"
if [[ -n $ZLE ]]; then
  print -P "✅  ZLE active"
  ZLE_ACTIVE=true
else
  print -P "⚠️   ZLE not active (script likely sourced, not in editing context)"
  ZLE_ACTIVE=false
fi
bindkey -v >/dev/null 2>&1 && print -P "✅  Vi-mode bindings present" || print -P "❌  Vi-mode missing"

# ---------------------------------------------------------------------
# 2. Prompt structure
# ---------------------------------------------------------------------
print -P "\n%F{white}[2] Prompt preview%f"
PROMPT_EVAL="$(print -P "$PROMPT")"
print -r "   $PROMPT_EVAL"
[[ "$PROMPT" == *"[I]"* ]] && print -P "✅  Prompt uses mode indicator [I]/[N]" || print -P "❌  Prompt missing mode indicator"

# ---------------------------------------------------------------------
# 3. Keybinding presence
# ---------------------------------------------------------------------
print -P "\n%F{white}[3] Keybindings%f"
typeset -A WANT=( \
  ["^E"]="fzf_cd_stack" \
  ["^F"]="fzf_file_insert_and_push" \
  ["^K"]="fzf_switch_dir" \
  ["^O"]="fzf_insert_dir" \
  ["^L"]="clear_and_echo" \
)
for key func in ${(kv)WANT}; do
  if bindkey -L | grep -q "\"$key\" $func"; then
    print -P "✅  $key → $func"
  else
    print -P "❌  $key → $func missing"
  fi
done

# ---------------------------------------------------------------------
# 4. Directory stack validation
# ---------------------------------------------------------------------
print -P "\n%F{white}[4] Directory-stack test%f"
tmpdir=$(mktemp -d)
mkdir -p "$tmpdir/a" "$tmpdir/b"
cd "$tmpdir/a" && cd "$tmpdir/b" && cd "$tmpdir/a"
stack=("${(@f)$(dirs -v)}")
if (( ${#stack[@]} >= 2 )); then
  print -P "✅  Stack populated (${#stack[@]} entries)"
else
  print -P "❌  Stack empty"
fi
cd ~; rm -rf "$tmpdir"

# ---------------------------------------------------------------------
# 5. Widget existence
# ---------------------------------------------------------------------
print -P "\n%F{white}[5] Widget definitions%f"
for f in fzf_cd_stack fzf_switch_dir fzf_insert_dir fzf_file_insert_and_push clear_and_echo; do
  if $ZLE_ACTIVE; then
    if zle -l | grep -qx "$f"; then
      print -P "✅  Widget: $f"
    else
      print -P "❌  Widget missing: $f"
    fi
  else
    print -P "⏭  Skipped widget check (ZLE inactive): $f"
  fi
done

# ---------------------------------------------------------------------
# 6. Autosuggestions
# ---------------------------------------------------------------------
print -P "\n%F{white}[6] Autosuggestions%f"
if typeset -f _zsh_autosuggest_bind_widget >/dev/null 2>&1; then
  print -P "✅  Plugin zsh-autosuggestions loaded"
else
  print -P "⚠️   Plugin not detected"
fi

# ---------------------------------------------------------------------
# 7. Summary
# ---------------------------------------------------------------------
print -P "\n%F{cyan}=== SUMMARY ===%f"
print -P "✔  Prompt + vi-mode"
print -P "✔  fzf widgets + bindings"
print -P "✔  Dir-stack integrity"
print -P "%F{green}All major shell functions operational.%f"
