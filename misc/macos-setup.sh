#!/bin/bash

# Interface
defaults write NSGlobalDomain "AppleInterfaceStyleSwitchesAutomatically" -bool "false"
defaults write NSGlobalDomain "NSWindowShouldDragOnGesture" -bool "true"

defaults write NSGlobalDomain "AppleReduceDesktopTinting" -bool "true"
defaults delete NSGlobalDomain "AppleReduceDesktopTinting"

defaults write com.apple.Accessibility "ReduceMotionEnabled" -int "1"
defaults delete com.apple.Accessibility

defaults write -g NSSplitViewItemSidebarDefaultsToFloatingAppearance -bool "false"
defaults write -g NSSplitViewItemGlassMinimumCornerRadius -float "0.1"
defaults write -g NSConvolutionOverride1 -float "0.1"

# Dock
defaults write com.apple.dock "tilesize" -int "48"
defaults write com.apple.dock "autohide" -bool "true"
defaults write com.apple.dock "autohide-time-modifier" -float "0"
defaults write com.apple.dock "autohide-delay" -float "0"
defaults write com.apple.dock "show-recents" -bool "false"
defaults write com.apple.dock "mineffect" -string "scale"

# Finder
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "false"
defaults write com.apple.finder "AppleShowAllFiles" -bool "true"
defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv" # List view
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"
defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf" # Search Current Folder
defaults write com.apple.finder "FXRemoveOldTrashItems" -bool "true"
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"
defaults write com.apple.finder "ShowStatusBar" -bool "true"

# Desktop
defaults write com.apple.finder "CreateDesktop" -bool "false"
defaults write com.apple.finder "ShowExternalHardDrivesOnDesktop" -bool "false"
defaults write com.apple.finder "ShowRemovableMediaOnDesktop" -bool "false"

# Menu
defaults write NSGlobalDomain "_HIHideMenuBar" -bool "true"

# Keyboard
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool "true"
defaults write NSGlobalDomain "ApplePressAndHoldEnabled" -bool "false"
defaults write NSGlobalDomain "NSAutomaticPeriodSubstitutionEnabled" -bool "false"
defaults write NSGlobalDomain "InitialKeyRepeat" -int 12
defaults write NSGlobalDomain "KeyRepeat" -int 1
defaults write kCFPreferencesAnyApplication "TSMLanguageIndicatorEnabled" -bool "false"

# Mission Control
defaults write NSGlobalDomain "AppleSpacesSwitchOnActivate" -bool "false"
defaults write com.apple.spaces "spans-displays" -bool "false"
defaults write com.apple.dock "mru-spaces" -bool "false"
defaults write com.apple.dock "wvous-tl-corner" -int 0
defaults write com.apple.dock "wvous-tr-corner" -int 0
defaults write com.apple.dock "wvous-bl-corner" -int 0
defaults write com.apple.dock "wvous-br-corner" -int 0

# Screenshots
defaults write com.apple.screencapture "location" "$HOME/Documents/Screenshots"
defaults write com.apple.iphonesimulator "ScreenShotSaveLocation" -string "$HOME/Documents/Screenshots"

# Feedback
defaults write com.apple.appleseed.FeedbackAssistant "Autogather" -bool "false"

# Apple Intelligence
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool "false" # Disable

# Quarantine
defaults write com.apple.LaunchServices "LSQuarantine" -bool "false"

# Kill affected applications
killall Finder &>/dev/null
killall Dock &>/dev/null
killall SystemUIServer &>/dev/null
killall Simulator &>/dev/null

/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
