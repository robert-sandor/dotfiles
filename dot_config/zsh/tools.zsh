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
  source <(carapace _carapace)
fi

if command -v zsh-patina >/dev/null 2>&1; then
  eval "$(zsh-patina activate)"
  eval "$(zsh-patina completion)"
fi

if command -v deja >/dev/null 2>&1; then
  # Customize keybinds
  export DEJA_ACCEPT_KEY='^Y'
  export DEJA_CYCLE_KEY='^N'
  # Disable keybinds I don't use
  export DEJA_CYCLE_FUZZY_KEY=''
  export DEJA_CYCLE_FUZZY_BACK_KEY=''
  export DEJA_TOGGLE_EMPTY_KEY=''

  # Set defaults here
  export DEJA_FUZZY=smart
  export DEJA_EMPTY=off

  if [[ -r "$HOME/.local/share/deja/init.zsh" ]]; then
    source "$HOME/.local/share/deja/init.zsh"
  else
    eval "$(deja init zsh)"
  fi
fi
