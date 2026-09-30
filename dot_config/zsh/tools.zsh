# Tool integrations
if command -v fzf >/dev/null 2>&1; then
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
  source <(carapace _carapace)
fi

# Syntax highlighting (binary from .chezmoiexternals/zsh-patina.toml.tmpl)
if command -v zsh-patina >/dev/null 2>&1; then
  eval "$(zsh-patina activate)"
  eval "$(zsh-patina completion)"
fi

# Autosuggestions (binary from .chezmoiexternals/deja.toml.tmpl)
if command -v deja >/dev/null 2>&1; then
  # export DEJA_CYCLE_KEY=^N
  export DEJA_CYCLE_FUZZY_KEY=
  export DEJA_CYCLE_FUZZY_BACK_KEY=
  export DEJA_TOGGLE_EMPTY_KEY=

  if [[ -r "$HOME/.local/share/deja/init.zsh" ]]; then
    source "$HOME/.local/share/deja/init.zsh"
  else
    eval "$(deja init zsh)"
  fi
fi
