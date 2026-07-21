#!/bin/bash
# macOS system defaults
# Run via chezmoi: run_onchange_after_macos-defaults.sh
# Some changes require a logout/restart to take effect.

set -e

# --- Dock ---
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.4
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock orientation -string "bottom"

# --- Finder ---
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file:///Users/$USER/"
defaults write com.apple.finder QuitMenuItem -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# --- Keyboard ---
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Input sources: U.S. and U.S. International-PC
defaults write com.apple.HIToolbox AppleEnabledInputSources -array \
  '{ "InputSourceKind" = "Keyboard Layout"; "KeyboardLayout ID" = 0; "KeyboardLayout Name" = "U.S."; }' \
  '{ "InputSourceKind" = "Keyboard Layout"; "KeyboardLayout ID" = 15000; "KeyboardLayout Name" = "USInternational-PC"; }'

# CMD + Space to toggle previous input source
# 32 = space, 49 = space keycode, 1048576 = CMD modifier
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 \
  '{ enabled = 1; value = { parameters = (32, 49, 1048576); type = standard; }; }'

# Disable "Select next input source" shortcut to avoid conflicts
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 \
  '{ enabled = 0; value = { parameters = (32, 49, 786432); type = standard; }; }'

# Disable Spotlight CMD+Space shortcut to free it for input switching
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 \
  '{ enabled = 0; value = { parameters = (32, 49, 1048576); type = standard; }; }'

# --- Trackpad ---
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.trackpad.scaling -int 2

# Reverse scroll direction (disable "Natural scrolling")
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# --- Menubar ---
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# --- Clock ---
defaults write com.apple.menuextra.clock ShowSeconds -bool true
defaults write com.apple.menuextra.clock ShowDate -int 2
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock FlashDateSeparators -bool false

# --- Screenshots ---
mkdir -p "~/Screenshots"
defaults write com.apple.screencapture location -string "~/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# --- Mission Control / Hot Corners ---
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock wvous-bl-corner -int 5  # bottom-left: screen saver

# --- Feedback / Sound ---
defaults write com.apple.sound.beep.feedback -bool false

# --- Browser extensions (managed policy / force-install) ---
# Extensions install automatically on next browser launch.
# They appear as "installed by your administrator" and cannot be easily removed.

BROWSER_EXTENSIONS=(
  "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx"
  "ldgfbffkinooeloadekpmfoklnobpien;https://clients2.google.com/service/update2/crx"
  "knagdmgmegmgbkjkghjkhnogekdaepel;https://clients2.google.com/service/update2/crx"
)

defaults write com.brave.Browser ExtensionInstallForcelist -array "${BROWSER_EXTENSIONS[@]}"
defaults write net.imput.helium ExtensionInstallForcelist -array "${BROWSER_EXTENSIONS[@]}"
defaults write org.chromium.Chromium ExtensionInstallForcelist -array "${BROWSER_EXTENSIONS[@]}"

# --- Restart affected apps ---
for app in "Dock" "Finder" "SystemUIServer"; do
  killall "${app}" > /dev/null 2>&1 || true
done

echo "macOS defaults applied. Some changes may require a logout/restart."
