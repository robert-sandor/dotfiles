# disable fish greeting
set -g fish_greeting

if not status --is-interactive
  exit
end

fish_vi_key_bindings

fish_config theme choose "Catppuccin Mocha"

set -gx SHELL (which fish)
set -gx EDITOR nvim
set -gx MANPAGER "nvim +Man!"

# Homebrew
for f in /opt/homebrew/bin /home/linuxbrew/.linuxbrew/bin
  if test -d "$f" && test -x "$f/brew"
    $f/brew shellenv fish | source

    set -gx HOMEBREW_BUNDLE_FILE ~/.config/Brewfile
    abbr -a brewfile "chezmoi edit -a --watch $HOMEBREW_BUNDLE_FILE"
    abbr -a brewup "brew bundle install --cleanup"
    # todo: reconsider this
    command -q rustup; and fish_add_path (brew --prefix rustup)/bin
    break
  end
end

if command -q fzf
  set -gx FZF_DEFAULT_OPTS_FILE ~/.config/fzfrc
  fzf --fish | source
end

if command -q carapace
  set -gx CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'
  carapace _carapace | source
end

if command -q bw
  abbr -a bwopen 'set -x BW_SESSION (bw unlock --raw)'
  abbr -a bwlock 'bw lock; set -e BW_SESSION'
  trap 'test -n "$BW_SESSION"; and bw lock' EXIT
end

command -q zoxide; and zoxide init fish | source
command -q starship; and starship init fish | source
command -q mise; and mise activate fish | source
command -q eza; and set -gx EZA_CONFIG_DIR ~/.config/eza

command -q rg; and set -gx RIPGREP_CONFIG_PATH ~/.config/ripgreprc

# abbreviations
source "$__fish_config_dir/abbrs.fish"

# make bitwarden the ssh agent
set_bitwarden_ssh_agent
