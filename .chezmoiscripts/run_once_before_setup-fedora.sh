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
  tree-sitter
  tree-sitter-cli
  vicinae
  yazi
  zed
  zoxide
  zsh
)

flatpaks=(
  app.zen_browser.zen              # browser
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

# Append a string to a gsettings list, unless it's already there
gsettings_append() {
  local schema="$1" key="$2" value="$3" current items
  current=$(gsettings get "$schema" "$key")
  [[ "$current" == *"'$value'"* ]] && return
  items=$(tr -d '[]' <<<"${current#@as }")
  gsettings set "$schema" "$key" "[${items:+$items, }'$value']"
}

echo "Enabling GNOME extensions..."
gsettings_append org.gnome.shell enabled-extensions appindicatorsupport@rgcjonas.gmail.com
gsettings_append org.gnome.shell enabled-extensions caffeine@patapon.info

echo "Setting default apps..."
xdg-settings set default-web-browser app.zen_browser.zen.desktop
xdg-mime default me.proton.Mail.desktop x-scheme-handler/mailto

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

# Shortcuts
add_custom_keybinding() {
  local name="$1" binding="$2" command="$3"
  local schema="org.gnome.settings-daemon.plugins.media-keys"
  local base="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
  local current path i=0
  current=$(gsettings get "$schema" custom-keybindings)
  # Skip if a shortcut with this name already exists
  for path in $(tr -d "'[]," <<<"${current#@as }"); do
    [[ "$(gsettings get "$schema.custom-keybinding:$path" name)" == "'$name'" ]] && return
  done
  while [[ "$current" == *"$base/custom$i/"* ]]; do i=$((i + 1)); done
  path="$base/custom$i/"
  gsettings set "$schema.custom-keybinding:$path" name "$name"
  gsettings set "$schema.custom-keybinding:$path" binding "$binding"
  gsettings set "$schema.custom-keybinding:$path" command "$command"
  gsettings_append "$schema" custom-keybindings "$path"
}
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]"          # Free up Super+Space
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]" # Free up Shift+Super+Space
add_custom_keybinding vicinae "<Super>space" "vicinae toggle"                    # Launcher

# Privacy
gsettings set org.gnome.desktop.privacy report-technical-problems false # Don't report technical problems

# Power
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false               # No automatic brightness
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true            # Night light on
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000        # GNOME default temperature
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true # Sunset to sunrise, needs location services

# Nautilus
gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view" # List view by default
