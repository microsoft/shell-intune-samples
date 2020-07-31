# Setting the Mac Desktop Wallpaper

These scripts provide examples of how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to set the Mac Desktop Wallpaper

## downloadWallpaper.sh

This script is intended to be delivered to the Mac by the Intune Scripting Agent. It will download the image that we want to use as the desktop Wallpaper. This stage just downloads the file to the Mac, it's the wallpaper.mobileconfig profile below that instructs the Mac to actually change the wallpaper image.

For this to work you will need a webserver to publish your Desktop Wallpaper image to. [Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) is ideal for this if you have it, otherwise any public web-server will do equally as well.

```
# Define variables
wallpaperurl="https://xxxx.blob.core.windows.net/Wallpaper/MacDesktopWallpaper.jpg"
wallpaperdir="/Library/DesktopWallpaper"
```

### Script Settings

>Note: Script frequency should be set depending on how often you want your devices checking in for a new Desktop Wallpaper image.

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
