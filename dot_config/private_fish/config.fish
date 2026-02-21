# disable fish greeting
set -g fish_greeting

if not status --is-interactive
  exit
end

# Setup PATH
fish_add_path ~/.local/bin

# Setup ENV
set -gx BAT_THEME_DARK "Catppuccin Mocha"
set -gx BAT_THEME_LIGHT "Catppuccin Latte"

set -gx EZA_CONFIG_DIR ~/.config/eza

set -gx RIPGREP_CONFIG_PATH ~/.config/ripgreprc

# Setup homebrew if installed
for brew_prefix in /opt/homebrew /home/linuxbrew/.linuxbrew ~/.linuxbrew
  if test -x "$f/bin/brew"
    $brew_prefix/bin/brew shellenv fish | source

    set -gx HOMEBREW_BUNDLE_FILE ~/.config/Brewfile

    abbr -a brewfile "chezmoi edit -a --watch $HOMEBREW_BUNDLE_FILE"
    abbr -a brewup "brew bundle install --cleanup"
    break
  end
end

# Setup other utilities if installed
if command -q nvim
  set -gx EDITOR nvim
  set -gx MANPAGER "nvim +Man!"
end

if command -q fzf
  set -gx FZF_DEFAULT_OPTS_FILE ~/.config/fzfrc
  fzf --fish | source
end

if command -q starship
  starship init fish | source
end

if command -q zoxide
  zoxide init fish | source
end

if command -q mise
  mise activate fish | source
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

# abbreviations
abbr -a sshconf 'cd $HOME/.ssh; nvim config; cd -'
abbr -a sshpub 'cat $HOME/.ssh/id_ed25519.pub'

# Bitwarden as SSH Agent
set -l bw_socket_locations \
  ~/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock \
  ~/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock \
  ~/.bitwarden-ssh-agent.sock

for socket in $bw_socket_locations
  if test -S $socket
    set -gx SSH_AUTH_SOCK "$socket"
    break
  end
end

fish_vi_key_bindings

fish_config theme choose "Catppuccin Mocha"
