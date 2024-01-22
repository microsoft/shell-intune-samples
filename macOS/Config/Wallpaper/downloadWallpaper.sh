#!/bin/bash
#set -x

############################################################################################
##
## Script to download Desktop Wallpaper
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
usebingwallpaper=true # Set to true to have script fetch wallpaper from Bing
wallpaperurl="https://catlab.blob.core.windows.net/public/win11.jpg?sp=r&st=2023-03-17T20:49:42Z&se=2099-03-18T04:49:42Z&spr=https&sv=2021-12-02&sr=b&sig=ZPpGEOoIoA0lpflLee3G71MT4rtwQ07nAPvrFBOMvUA%3D"
wallpaperdir="/Users/Shared/"
wallpaperfile="Wallpaper.jpg"
log="/var/log/fetchdesktopwallpaper.log"

# start logging

exec 1>> $log 2>&1

echo ""
echo "##############################################################"
echo "# $(date) | Starting download of Desktop Wallpaper"
echo "############################################################"
echo ""

##
## Checking if Wallpaper directory exists and create it if it's missing
##
if [ -d $wallpaperdir ]
then
    echo "$(date) | Wallpaper dir [$wallpaperdir] already exists"
else
    echo "$(date) | Creating [$wallpaperdir]"
    mkdir -p $wallpaperdir
fi


##
## Attempt to download the image file. No point checking if it already exists since we want to overwrite it anyway
##

if [ "$usebingwallpaper" = true ]; then

  echo "$(date) | Attempting to dertermine URL of today's Bing Wallpaper"
  bingfileurl=( $(curl -sL https://www.bing.com | grep -Eo "th\?id=.*?.jpg" | head -n 1| sed -e "s/tmb/UHD/"))
  wallpaperurl="https://bing.com/$bingfileurl"
  echo "$(date) | Setting wallpaperurl to todays Bing Desktop [$wallpaperurl]"

fi

echo "$(date) | Downloading Wallpaper from [$wallpaperurl] to [$wallpaperdir/$wallpaperfile]"
curl -L -o $wallpaperdir/$wallpaperfile $wallpaperurl
if [ "$?" = "0" ]; then
   echo "$(date) | Wallpaper [$wallpaperurl] downloaded to [$wallpaperdir/$wallpaperfile]"
   #killall Dock
   exit 0
else
   echo "$(date) | Failed to download wallpaper image from [$wallpaperurl]"
   exit 1
fi
