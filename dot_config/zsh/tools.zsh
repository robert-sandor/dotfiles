if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS_FILE=~/.config/fzfrc
  eval "$(fzf --zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v carapace >/dev/null 2>&1; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  # Match completions case-insensitively (carapace ignores zsh's matcher-list)
  export CARAPACE_MATCH=CASE_INSENSITIVE
  source <(carapace _carapace)
fi

if command -v zsh-patina >/dev/null 2>&1; then
  eval "$(zsh-patina activate)"
  eval "$(zsh-patina completion)"
fi

zsh_autosuggest="$HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
if [[ -r "$zsh_autosuggest" ]]; then
  # Suggest what usually follows the previous command, else the latest history match
  ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history)
  # Skip suggestions for very long buffers (e.g. big pastes)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
  source "$zsh_autosuggest"
  # Accept the whole suggestion with Ctrl+Y (Right arrow also works)
  bindkey -M viins '^Y' autosuggest-accept
fi
unset zsh_autosuggest
