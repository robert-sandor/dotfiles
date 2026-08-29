# disable fish greeting
set -g fish_greeting

if not status --is-interactive
    exit
end

fish_vi_key_bindings
fish_config theme choose catppuccin-mocha
fish_add_path ~/.local/bin ~/bin

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

if command -q eza
    set -gx EZA_CONFIG_DIR ~/.config/eza
    set -gx EZA_ICONS_AUTO true

    abbr -a l eza
    abbr -a la eza -al
    abbr -a ll eza -l
    abbr -a tree eza --tree
end

if command -q bat
    set -gx BAT_THEME_DARK "Catppuccin Mocha"
    set -gx BAT_THEME_LIGHT "Catppuccin Latte"

    abbr -a cat bat -p
end

if command -q rg
    set -gx RIPGREP_CONFIG_PATH ~/.config/ripgreprc
end

# Other abbreviations
abbr -a sshconf 'nvim ~/.ssh/config'
abbr -a sshpub 'cat $HOME/.ssh/id_ed25519.pub'
