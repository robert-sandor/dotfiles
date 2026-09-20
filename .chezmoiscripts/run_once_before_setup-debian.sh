#!/usr/bin/env bash
set -eo pipefail

if [[ "$OSID" != "linux-debian" ]]; then
  exit 0
fi

if [[ "$HEADLESS" != "true" ]]; then
  exit 0
fi

packages=(
  bat
  btop
  curl
  du-dust
  eza
  fd-find
  fish
  fzf
  git
  git-delta
  htop
  lazygit
  mise
  neovim
  ripgrep
  rsync
  starship
  tealdeer
  unzip
  yazi
  zoxide
)

echo "Adding yazi repository..."
if [[ ! -f /etc/apt/sources.list.d/yazi.list ]]; then
  curl -fsSL https://yazi-rs.github.io/builds/yazi-keyring.gpg | sudo tee /usr/share/keyrings/yazi-keyring.gpg >/dev/null
  echo "deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main" | sudo tee /etc/apt/sources.list.d/yazi.list >/dev/null
fi

echo "Adding mise repository..."
if ! dpkg -s mise &>/dev/null; then
  sudo apt-get install -y extrepo
  sudo extrepo enable mise
fi

echo "Installing packages..."
sudo apt-get update
sudo apt-get install -y "${packages[@]}"
