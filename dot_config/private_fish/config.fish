# disable fish greeting
set -g fish_greeting

# PATH
command -q brew; and fish_add_path (brew --prefix rustup)/bin

if status --is-interactive
    fish_vi_key_bindings

    fish_config theme choose "Catppuccin Mocha"

    set -gx SHELL (which fish)
    set -gx EDITOR nvim
    set -gx MANPAGER "nvim +Man!"

    set -l fish_conf_dir ~/.config/fish

    # Interactive shell initialisation
    command -q brew; and source "$fish_conf_dir/brew.fish"
    command -q chezmoi; and source "$fish_conf_dir/chezmoi.fish"
    command -q fzf; and source "$fish_conf_dir/fzf.fish"
    command -q zoxide; and zoxide init fish | source
    command -q starship; and starship init fish | source; and enable_transience
    command -q mise; and mise activate fish | source
    command -q yazi; and source "$fish_conf_dir/yazi.fish"
    command -q bw; and source "$fish_conf_dir/bitwarden.fish"
    command -q carapace; and set -gx CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'; and carapace _carapace | source

    # abbreviations
    source "$fish_conf_dir/abbrs.fish"

    # make bitwarden the ssh agent
    set_bitwarden_ssh_agent
end
