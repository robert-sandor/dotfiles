# dotfiles

## Setup

Bootstrap a new machine (installs chezmoi to `~/.local/bin` and applies this repo in one command):

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply https://github.com/robert-sandor/dotfiles.git
```

Chezmoi then self-manages using an externals file. On non-headless machines, the git remote is automatically switched to SSH after the first apply.
