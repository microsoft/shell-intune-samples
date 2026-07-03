# Setting the Mac Desktop Wallpaper

These scripts provide examples of how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to set the Mac Desktop Wallpaper

![Desktop Image](https://github.com/microsoft/shell-intune-samples/raw/master/img/desktop.png)

## downloadWallpaper.sh

This script is intended to be delivered to the Mac by the Intune Scripting Agent. It downloads the wallpaper image and **actively sets it as the desktop picture** for the currently logged-in user.

### Why the script changed

Starting with macOS 14 (Sonoma), Apple reworked the wallpaper system to use `WallpaperKit`. Simply placing an image file on disk and relying on the `com.apple.desktop` / `override-picture-path` profile is no longer reliable — the system may not pick up the change. The updated script now:

1. Downloads the image to disk
2. Detects the currently logged-in console user
3. Uses `osascript` (AppleScript via Finder) to actively set the desktop picture
4. Validates that the downloaded file is actually an image before applying it

If no user is logged in when the script runs, it downloads the image but skips the wallpaper set — the `override-picture-path` profile serves as a fallback at next login.

### Requirements

For zero user prompts, you **must** deploy the PPPC profile (`wallpaper-pppc.mobileconfig`) alongside this script. On macOS 10.14+, sending Apple Events from `osascript` to `Finder` requires TCC consent — the PPPC profile pre-authorizes this silently via MDM.

Deploy these three items via Intune:
1. **downloadWallpaper.sh** — Shell script (Intune Scripting Agent)
2. **wallpaper-pppc.mobileconfig** — Custom profile (pre-authorizes osascript → Finder)
3. **wallpaper.mobileconfig** — Custom profile (fallback override-picture-path)

For this to work you will need a webserver to publish your Desktop Wallpaper image to. [Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) is ideal for this if you have it, otherwise any public web-server will do equally as well.

```
# Define variables
usebingwallpaper=false
wallpaperurl="https://github.com/microsoft/shell-intune-samples/raw/master/img/M365.jpg"
wallpaperdir="/Users/Shared"
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
