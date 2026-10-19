if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS_FILE=~/.config/fzfrc
  eval "$(fzf --zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
  # Starship re-runs the prompt on every vi mode switch, which makes Esc laggy
  zle -D zle-keymap-select
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
