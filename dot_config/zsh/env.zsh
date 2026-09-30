# Include user bins
typeset -U path
path=("$HOME/.local/bin" $path)
export PATH

# Setup homebrew if installed
for brew_prefix in /opt/homebrew /home/linuxbrew/.linuxbrew ~/.linuxbrew; do
  if [ -x "$brew_prefix/bin/brew" ]; then
    eval "$($brew_prefix/bin/brew shellenv zsh)"
    break
  fi
done

# Editor
if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
  export MANPAGER="nvim +Man!"
fi

export FZF_DEFAULT_OPTS_FILE=~/.config/fzfrc
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
export EZA_CONFIG_DIR=~/.config/eza
export EZA_ICONS_AUTO=true
export BAT_THEME_DARK="Catppuccin Mocha"
export BAT_THEME_LIGHT="Catppuccin Latte"
export RIPGREP_CONFIG_PATH=~/.config/ripgreprc
