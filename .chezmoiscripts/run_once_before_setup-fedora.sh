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
  adw-gtk3-theme
  bash
  bat
  btop
  du-dust
  eza
  fd-find
  fish
  fzf
  ghostty
  git
  git-delta
  git-extras
  gnome-shell-extension-appindicator
  gnome-shell-extension-caffeine
  golang-github-jesseduffield-lazygit
  gstreamer1-plugin-libav
  gstreamer1-plugins-bad-freeworld
  gstreamer1-plugins-ugly
  helium-browser-bin
  helix
  jetbrainsmono-nerd-fonts
  libheif-freeworld
  mesa-va-drivers-freeworld
  mise
  nextcloud-client
  niri
  noctalia
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
  com.bitwarden.desktop            # password manager
  com.discordapp.Discord           # discord
  com.github.tchx84.Flatseal       # flatpak permission editor
  com.github.wwmm.easyeffects      # audio effects/EQ
  com.mastermindzh.tidal-hifi      # tidal
  com.mattjakeman.ExtensionManager # GNOME Shell extensions
  com.orcaslicer.OrcaSlicer        # orcaslicer
  com.protonvpn.www                # protonvpn
  com.todoist.Todoist              # todoist-app
  me.proton.Mail                   # proton-mail
  org.gtk.Gtk3theme.adw-gtk3-dark  # GTK3 theme for flatpaks, pairs with adw-gtk3-theme
  org.jeffvli.feishin              # music player (Navidrome/Jellyfin client)
  org.jellyfin.JellyfinDesktop     # jellyfin-media-player
  org.localsend.localsend_app      # localsend
  org.signal.Signal                # signal
)

echo "Configuring dnf..."
sudo dnf config-manager setopt max_parallel_downloads=10

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

echo "Installing codecs..."
# RPM Fusion's ffmpeg replaces Fedora's stripped-down ffmpeg-free/libavcodec-free
if ! rpm -q ffmpeg &>/dev/null; then
  sudo dnf install -y --allowerasing ffmpeg
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
enable_extension() {
  local uuid="$1" current items
  current=$(gsettings get org.gnome.shell enabled-extensions)
  [[ "$current" == *"'$uuid'"* ]] && return
  items=$(tr -d '[]' <<<"${current#@as }")
  gsettings set org.gnome.shell enabled-extensions "[${items:+$items, }'$uuid']"
}
enable_extension appindicatorsupport@rgcjonas.gmail.com
enable_extension caffeine@patapon.info

## Settings
echo "Setting up GNOME..."

# Appearance
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"   # Dark theme
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"    # GTK3 apps match libadwaita, dark variant to pair with color-scheme
gsettings set org.gnome.desktop.interface accent-color "blue"          # Accent color
gsettings set org.gnome.desktop.interface show-battery-percentage true # Show battery percentage

# Input
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']" # Caps Lock acts as Escape
gsettings set org.gnome.desktop.peripherals.mouse accel-profile "flat"      # No mouse acceleration
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click false     # Tap to click off (physical click only)

# Privacy
gsettings set org.gnome.desktop.privacy report-technical-problems false # Don't report technical problems

# Power
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false               # No automatic brightness
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true            # Night light on
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000        # GNOME default temperature
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true # Sunset to sunrise, needs location services

# Nautilus
gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view" # List view by default
