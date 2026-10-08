# History settings
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt inc_append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_reduce_blanks
setopt hist_ignore_space
setopt no_beep

# Shell behavior
setopt interactive_comments
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

# Enable Vi keybinds
bindkey -v
KEYTIMEOUT=5

# Let insert mode delete text typed before entering it (vi-* versions stop at the insert point)
bindkey -M viins '^?' backward-delete-char   # Backspace
bindkey -M viins '^H' backward-delete-char   # Ctrl+H
bindkey -M viins '^W' backward-kill-word     # Ctrl+W: delete previous word
bindkey -M viins '^U' backward-kill-line     # Ctrl+U: delete to start of line

# Edit current line in $EDITOR with alt+e
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^[e' edit-command-line
bindkey -M vicmd '^[e' edit-command-line

# Completion
autoload -Uz compinit
compinit

# Completion styling
# Show an arrow-key navigable menu instead of a plain list
zstyle ':completion:*' menu select
# Try matchers in order: case-insensitive, then partial words around . _ -, then substring
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# Group matches by their tag (e.g. main commands vs. aliases) instead of one merged list
zstyle ':completion:*' group-name ''
# Color file matches the same way ls does
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Header shown above each group of matches (%d is the group description)
zstyle ':completion:*:descriptions' format $'\e[2;37m-- %d --\e[m'
# Header for completers that don't use the descriptions tag (carapace relies on this)
zstyle ':completion:*' format $'\e[2;37m-- %d --\e[m'
