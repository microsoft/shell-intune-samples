# Setting the Mac Desktop Wallpaper

These scripts provide examples of how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to set the Mac Desktop Wallpaper

![Desktop Image](https://github.com/microsoft/shell-intune-samples/raw/master/img/desktop.png)

## downloadWallpaper.sh

This script is intended to be delivered to the Mac by the Intune Scripting Agent. It will download the image that we want to use as the desktop Wallpaper. This stage just downloads the file to the Mac, it's the wallpaper.mobileconfig profile below that instructs the Mac to actually change the wallpaper image.

For this to work you will need a webserver to publish your Desktop Wallpaper image to. [Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) is ideal for this if you have it, otherwise any public web-server will do equally as well.

```
# Define variables
usebingwallpaper=false
wallpaperurl="https://github.com/microsoft/shell-intune-samples/raw/master/img/M365.jpg"
wallpaperdir="/Library/Desktop"
wallpaperfile="Wallpaper.jpg"
log="/var/log/fetchdesktopwallpaper.log"
```

>Note: If you set usebingwallpaper=true the script will attempt to determine the Bing daily wallpaper image and download it instead of the one specified in wallpaperurl.

### Log file example

The log file will output to /var/log/fetchdesktopwallpaper.log by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Tue  4 Aug 2020 09:03:51 BST | Starting download of Desktop Wallpaper
############################################################

Tue  4 Aug 2020 09:03:51 BST | Creating [/Library/Desktop]
Tue  4 Aug 2020 09:03:51 BST | Downloading Wallpaper from [https://github.com/microsoft/shell-intune-samples/raw/master/img/M365.jpg] to [/Library/Desktop/Wallpaper.jpg]
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   150  100   150    0     0   1111      0 --:--:-- --:--:-- --:--:--  1111
100  420k  100  420k    0     0  1343k      0 --:--:-- --:--:-- --:--:-- 1343k
Tue  4 Aug 2020 09:03:51 BST | Wallpaper [Wallpaper.jpg] downloaded to [/Library/Desktop]
```

### Script Settings

>Note: Script frequency should be set depending on how often you want your devices checking in for a new Desktop Wallpaper image. Once downloaded the Wallpaper will not change until the user logs out or you uncomment the 'killall Dock' lines 66 in the script which will trigger the Wallpaper to change immediately the script downloads the image.

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Every 1 day
- Number of times to retry if script fails : 3

## wallpaper.mobileconfig

This is a mobileconfig file that configures the Mac to use a specific path for wallpaper. It should be delivered to the Mac via an Intune Custom Profile. For more information see the following: [Use custom settings for macOS devices in Microsoft Intune](https://docs.microsoft.com/en-us/mem/intune/configuration/custom-settings-macos)

>Note: Make sure that the override-picture-path location is the same as the location you use to store the Wallpaper image downloaded in the downloadWallpaper.sh script.
```
<key>override-picture-path</key>
<string>/Library/Desktop/Wallpaper.jpg</string>
```
