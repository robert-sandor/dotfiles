alias c='clear'
alias q='exit'

if command -v nvim >/dev/null 2>&1; then
  alias sshconf='nvim ~/.ssh/config'
fi

if command -v eza >/dev/null 2>&1; then
  alias l='eza'
  alias la='eza -al'
  alias ll='eza -l'
  alias tree='eza --tree'
else
  alias ls='ls --color=auto'
  alias l='ls --color=auto'
  alias la='ls -Al --color=auto'
  alias ll='ls -l --color=auto'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat -p'
  alias sshpub='bat -p ~/.ssh/id_ed25519.pub'
fi
