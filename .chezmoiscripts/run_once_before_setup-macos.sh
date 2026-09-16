#!/usr/bin/env bash
set -eo pipefail

if [[ "$OSID" != "darwin" ]]; then
  exit 0
fi

common_formulae=(
  bash
  bat
  btop
  dust
  eza
  fd
  ffmpeg
  fish
  fzf
  git
  git-delta
  git-extras
  helix
  imagemagick
  lazygit
  mas
  mise
  p7zip
  ripgrep
  rsync
  starship
  tealdeer
  yazi
  zoxide
)
personal_formulae=(
  lima
  podman
)
work_formulae=(
)

common_casks=(
  alfred
  appcleaner
  betterdisplay
  claude-code
  font-jetbrains-mono-nerd-font
  ghostty
  iina
  localsend
  protonvpn
  rectangle
  unnaturalscrollwheels
  zed
)
personal_casks=(
  balenaetcher
  discord
  helium-browser
  jellyfin-media-player
  nextcloud
  orcaslicer
  proton-mail
  signal
  tailscale-app
  tidal
  todoist-app
)
work_casks=(
  docker-desktop
  google-chrome
  jetbrains-toolbox
  postman
  slack
)

if [[ "$WORK" == "true" ]]; then
  formulae=("${common_formulae[@]}" "${work_formulae[@]}")
  casks=("${common_casks[@]}" "${work_casks[@]}")
else
  formulae=("${common_formulae[@]}" "${personal_formulae[@]}")
  casks=("${common_casks[@]}" "${personal_casks[@]}")
fi

appstore_apps=(
  1530145038 # Amperfy - music player for Navidrome
  1352778147 # Bitwarden - password manager, appstore release for touch ID support
  310633997 # WhatsApp - consider if needed
  1451685025 # Wireguard - VPN to home
)

if [[ $(command -v brew) == "" ]]; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ $(command -v brew) == "" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi

echo "Installing formulae..."
brew install --no-ask --quiet --formulae "${formulae[@]}"

echo "Installing casks..."
brew install --no-ask --quiet --casks "${casks[@]}"

if [[ "$WORK" == "false" ]]; then
  echo "Installing Mac Appstore apps..."
  mas install "${appstore_apps[@]}" || echo "mas install failed — check you're signed into the App Store"
fi

## Settings
# Dock
echo "Setting up the dock..."
defaults write com.apple.dock "orientation" -string "bottom" # Dock at the bottom
defaults write com.apple.dock "tilesize" -int "48" # Set icon size
defaults write com.apple.dock "autohide" -bool "true" # Autohide the dock
defaults write com.apple.dock "autohide-time-modifier" -float "0.2" # Faster dock animation
defaults write com.apple.dock "autohide-delay" -float "0" # Show dock faster
defaults write com.apple.dock "show-recents" -bool "false" # Don't show recent apps
defaults write com.apple.dock "mineffect" -string "scale" # Animation when minimizing
defaults write com.apple.dock "wvous-tl-corner" -int "2" # Top-left hot corner: Mission Control (GNOME Activities-style)
defaults write com.apple.dock "wvous-tl-modifier" -int "0" # No modifier key needed

add_dock_folder() { # path, label
  defaults write com.apple.dock persistent-others -array-add "<dict>
    <key>tile-data</key><dict>
      <key>file-data</key><dict>
        <key>_CFURLString</key><string>file://$1</string>
        <key>_CFURLStringType</key><integer>15</integer>
      </dict>
      <key>file-label</key><string>$2</string>
      <key>file-type</key><integer>2</integer>
      <key>displayas</key><integer>0</integer>
      <key>showas</key><integer>2</integer>
      <key>arrangement</key><integer>1</integer>
    </dict>
    <key>tile-type</key><string>directory-tile</string>
  </dict>"
}

defaults write com.apple.dock persistent-others -array # Clear existing folder pins
add_dock_folder "/Applications/" "Applications"
add_dock_folder "$HOME/Desktop/" "Desktop"
add_dock_folder "$HOME/Documents/" "Documents"
add_dock_folder "$HOME/Downloads/" "Downloads"

killall Dock 2>/dev/null || true

# Finder
echo "Setting up finder..."
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true" # Always show extensions
defaults write com.apple.finder "AppleShowAllFiles" -bool "true" # Always show hidden files
defaults write com.apple.finder "ShowPathbar" -bool "true" # Always show path bar
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv" # List view by default
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true" # Keep folders on top
defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "false" # Save documents locally by default
defaults write com.apple.finder "ShowStatusBar" -bool "true" # Always show status bar
defaults write com.apple.finder "CreateDesktop" -bool "false" # Don't show icons on desktop
killall Finder 2>/dev/null || true

# Inputs
echo "Setting up input settings..."
defaults write NSGlobalDomain "ApplePressAndHoldEnabled" -bool "false" # Holding a key repeats
defaults write NSGlobalDomain AppleKeyboardUIMode -int "2" # Enable UI keyboard navigation using Tab and Shift-Tab
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false # Disable the double Space insert period bs
defaults write NSGlobalDomain KeyRepeat -int "2" # Fast key repeat rate
defaults write NSGlobalDomain InitialKeyRepeat -int "15" # Short delay until repeat starts

# Trackpad
echo "Setting up trackpad settings..."
for domain in com.apple.AppleMultitouchTrackpad com.apple.driver.AppleBluetoothMultitouch.trackpad; do
  defaults write "$domain" "Clicking" -bool "false" # Tap to click off (physical click only)
  defaults write "$domain" "TrackpadRightClick" -bool "true" # Two-finger right click
  defaults write "$domain" "DragLock" -bool "false" # Drag lock off
  defaults write "$domain" "TrackpadThreeFingerDrag" -bool "false" # Three-finger drag off
done
defaults write NSGlobalDomain "com.apple.mouse.tapBehavior" -int "0" # Tap to click off, mirrored in NSGlobalDomain

# Screenshots
echo "Setting up screenshot settings..."
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture "location" -string "$HOME/Pictures/Screenshots" # Save location
defaults write com.apple.screencapture "type" -string "png" # File format
defaults write com.apple.screencapture "disable-shadow" -bool "false" # Keep window shadows
killall SystemUIServer 2>/dev/null || true

# Menu bar
echo "Setting up menu bar settings..."
defaults write com.apple.controlcenter "BatteryShowPercentage" -bool "true" # Show battery percentage

# Screensaver
echo "Setting up screensaver settings..."
defaults write com.apple.screensaver "askForPassword" -bool "true" # Require password after screensaver/sleep
defaults write com.apple.screensaver "askForPasswordDelay" -int "0" # Ask immediately, no grace period

# Misc
echo "Setting up misc settings..."
defaults write com.apple.appleseed.FeedbackAssistant "Autogather" -bool "false" # Do not autogather large files when submitting a report
defaults write com.apple.ActivityMonitor "UpdatePeriod" -int "1" # Activity Monitor faster updates
killall "Activity Monitor" 2>/dev/null || true

