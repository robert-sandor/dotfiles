# dotfiles

## Setup

Bootstrap a new machine (installs chezmoi to `~/.local/bin` and applies this repo in one step).
Chezmoi then self-manages using an externals file.

For personal machines where dotfiles will be updated regularly:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply --ssh robert-sandor/dotfiles
```

For machines where chezmoi is not updated regularly (i.e. severs):

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply https://github.com/robert-sandor/dotfiles.git
```
