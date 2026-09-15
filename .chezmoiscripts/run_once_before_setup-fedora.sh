#!/usr/bin/env bash
set -eo pipefail

if [[ "$OSID" != "linux-fedora" ]]; then
  exit 0
fi

if [[ "$HEADLESS" == "true" ]]; then
  exit 0
fi

packages=(
  7zip
  ImageMagick
  bash
  bat
  btop
  chezmoi
  du-dust
  eza
  fd-find
  ffmpeg
  fish
  fzf
  ghostty
  git
  git-delta
  git-extras
  gnome-shell-extension-appindicator
  gnome-shell-extension-caffeine
  golang-github-jesseduffield-lazygit
  helium-browser-bin
  helix
  jetbrainsmono-nerd-fonts
  mise
  nextcloud-client
  podman
  ripgrep
  rsync
  starship
  tailscale
  tealdeer
  yazi
  zed
  zoxide
)

flatpaks=(
  com.bitwarden.desktop           # password manager
  com.discordapp.Discord          # discord
  com.github.tchx84.Flatseal      # flatpak permission editor
  com.github.wwmm.easyeffects     # audio effects/EQ
  com.mastermindzh.tidal-hifi     # tidal
  com.mattjakeman.ExtensionManager # GNOME Shell extensions
  com.orcaslicer.OrcaSlicer       # orcaslicer
  com.protonvpn.www               # protonvpn
  com.todoist.Todoist             # todoist-app
  me.proton.Mail                  # proton-mail
  org.jeffvli.feishin             # music player (Navidrome/Jellyfin client)
  org.jellyfin.JellyfinDesktop    # jellyfin-media-player
  org.localsend.localsend_app     # localsend
  org.signal.Signal               # signal
)

echo "Adding RPM Fusion repositories..."
if ! rpm -q rpmfusion-free-release &>/dev/null; then
  sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
fi
if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
  sudo dnf install -y "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
fi

echo "Adding Terra repository..."
if ! rpm -q terra-release &>/dev/null; then
  sudo dnf install -y --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" terra-release
fi

echo "Adding Tailscale repository..."
if [[ ! -f /etc/yum.repos.d/tailscale.repo ]]; then
  sudo dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
fi

echo "Installing packages..."
sudo dnf install -y "${packages[@]}"

echo "Adding Flathub remote..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Installing flatpaks..."
flatpak install -y --noninteractive flathub "${flatpaks[@]}"

echo "Setting up tailscale..."
sudo systemctl enable --now tailscaled
sudo tailscale set --operator="$USER"
tailscale configure systray --enable-startup=systemd
systemctl --user daemon-reload
systemctl --user enable --now tailscale-systray

echo "Enabling GNOME extensions..."
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com || echo "appindicator extension not loaded yet — log out/in, then run: gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com"
gnome-extensions enable caffeine@patapon.info || echo "caffeine extension not loaded yet — log out/in, then run: gnome-extensions enable caffeine@patapon.info"

## Settings
echo "Setting up GNOME..."

# Appearance
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" # Dark theme
gsettings set org.gnome.desktop.interface accent-color "blue" # Accent color
gsettings set org.gnome.desktop.interface show-battery-percentage true # Show battery percentage

# Input
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']" # Caps Lock acts as Escape
gsettings set org.gnome.desktop.peripherals.mouse accel-profile "flat" # No mouse acceleration
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click false # Tap to click off (physical click only)

# Privacy
gsettings set org.gnome.desktop.privacy report-technical-problems false # Don't report technical problems

# Power
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false # No automatic brightness
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true # Night light on
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000 # GNOME default temperature
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true # Sunset to sunrise, needs location services

# Nautilus
gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view" # List view by default

