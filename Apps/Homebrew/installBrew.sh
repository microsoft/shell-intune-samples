#!/bin/zsh
#set -x
exec > >(tee -a /var/log/brew.log) 2>&1
sudo rm -rf /Library/Developer/CommandLineTools
sudo xcode-select --install
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
consoleuser=$(ls -l /dev/console | awk '{ print $3 }')
sudo -u "$consoleuser" echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/desmondhume/.zprofile
sudo -u "$consoleuser" eval "$(/opt/homebrew/bin/brew shellenv)"