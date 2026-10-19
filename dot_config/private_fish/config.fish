# disable fish greeting
set -g fish_greeting

if not status --is-interactive
    exit
end

fish_vi_key_bindings
fish_config theme choose catppuccin-mocha

# Some potentially handy abbrs
abbr -a c clear
abbr -a q exit

# Setup homebrew if installed
for brew_prefix in /opt/homebrew /home/linuxbrew/.linuxbrew
    if test -x "$brew_prefix/bin/brew"
        $brew_prefix/bin/brew shellenv fish | source
        break
    end
end

fish_add_path --move --path ~/.local/bin

# Setup other utilities if installed
if command -q nvim
    set -gx EDITOR nvim
    set -gx MANPAGER "nvim +Man!"

    abbr -a sshconf 'nvim ~/.ssh/config'
end

if command -q fzf
    set -gx FZF_DEFAULT_OPTS_FILE ~/.config/fzfrc
    fzf --fish | source
end

if command -q starship
    starship init fish --print-full-init | source
end

if command -q zoxide
    zoxide init fish | source
end

# Some mise packages (e.g. homebrew) already activate it via vendor_conf.d
if command -q mise; and not functions -q __mise_env_eval
    mise activate fish | source
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

    abbr -a sshpub 'bat -p $HOME/.ssh/id_ed25519.pub'
end

if command -q lazygit
    abbr -a lg lazygit
end

if command -q rg
    set -gx RIPGREP_CONFIG_PATH ~/.config/ripgreprc
end

# Local, machine-only config (never managed by chezmoi)
if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end
