#!/bin/sh

# set reasonable macOS defaults
# inspired by : https://github.com/mathiasbynens/dotfiles
# more can be found here : https://gist.github.com/brandonb927/3195465

if [ "$(uname -s)" != "Darwin" ]; then
	exit 0
fi

set +e

echo "  › Use AirDrop over every interface. srsly this should be a default."
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

echo "  › show the ~/Library folder"
chflags nohidden ~/Library

echo "  › disable smart quotes and smart dashes as they're annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "  › Show path bar"
defaults write com.apple.finder ShowPathbar -bool true

echo "  › Show hidden files"
defaults write com.apple.finder AppleShowAllFiles -bool true

echo "  › Set Dock size to 48 pixels"
defaults write com.apple.dock tilesize -int 48

echo "  › Position Dock on left side"
defaults write com.apple.dock orientation -string "left"

echo "  › Disable Dock autohide (user preference)"
defaults write com.apple.dock autohide -bool false

echo "  › Disable trackpad tap-to-click"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 0

echo "  › Set screenshot format to PNG"
defaults write com.apple.screencapture type -string "png"

echo "  › Set screenshot location to iCloud Drive screenshots folder"
defaults write com.apple.screencapture location -string "~/Library/Mobile Documents/com~apple~CloudDocs/02 - screenshots"

echo "  › Apply Dock changes"
killall Dock

echo "  › Apply Finder changes"
killall Finder

echo "  › Enable key repeat in VSCodeVim"
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false 
