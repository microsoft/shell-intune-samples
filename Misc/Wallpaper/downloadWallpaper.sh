#!/bin/bash
#set -x

############################################################################################
##
## Script to download DesktopWallpaper
##
###########################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables
wallpaperurl="https://github.com/microsoft/shell-intune-samples/raw/master/img/M365.jpg"
wallpaperdir="/Library/DesktopWallpaper"
log="/var/log/fetchdesktopwallpaper.log"

# start logging

exec 1>> $log 2>&1

echo ""
echo "##############################################################"
echo "# $(date) | Starting download of Desktop Wallpaper"
echo "############################################################"
echo ""


mkdir -p $wallpaperdir

echo "Downloading Wallpaper"
curl -L -o $wallpaperdir/Wallpaper.jpg $wallpaperurl
