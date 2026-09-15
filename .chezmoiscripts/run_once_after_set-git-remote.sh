#!/usr/bin/env bash
set -eo pipefail

if [[ "$HEADLESS" == "true" ]]; then
  exit 0
fi

git -C "$HOME/.local/share/chezmoi" remote set-url origin git@github.com:robert-sandor/dotfiles.git
