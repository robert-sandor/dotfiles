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

# Edit current line in $EDITOR with alt+e
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^[e' edit-command-line
bindkey -M vicmd '^[e' edit-command-line

# Completion
autoload -Uz compinit
compinit
