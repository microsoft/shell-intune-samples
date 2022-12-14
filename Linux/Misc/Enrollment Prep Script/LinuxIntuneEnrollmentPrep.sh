#!/bin/bash
#set -x

############################################################################################
##
## Script to install Intune Prerequisites for Linux Enrollment
##
############################################################################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: anders ahl

# Install pre-requisite packages
sudo apt install wget apt-transport-https software-properties-common

# Download the Microsoft repository and GPG keys
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"

# Register the Microsoft repository and GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of packages after we have added packages.microsoft.com
sudo apt update

# Remove the repository & GPG key package (as we imported it above)
rm packages-microsoft-prod.deb

# Install the Intune portal
sudo apt install intune-portal

# Enable the Edge browser repository
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main"

# Install Microsoft Edge
# sudo apt install microsoft-edge-dev
# sudo apt install microsoft-edge-beta
sudo apt install microsoft-edge-stable

# Enable the Microsoft Teams repository
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main"

