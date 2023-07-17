# Spotify Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Teams pkg file from the Microsoft download servers and then install it onto the Mac.

## Scenario

This script is intended for customers who need to deploy Spotify via the Intune Scripting Agent.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/macOS/Apps/Spotify/installSpotify.zsh)"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Weekly
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/Spotify/Spotify.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Mon 17 Jul 2023 15:01:52 BST | Logging install of [Spotify] to [/Library/Logs/Microsoft/IntuneScripts/Spotify/Spotify.log]
############################################################

Mon 17 Jul 2023 15:01:52 BST | Aria2 already installed, nothing to do
Mon 17 Jul 2023 15:01:52 BST | Checking if we need Rosetta 2 or not
Mon 17 Jul 2023 15:01:52 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Mon 17 Jul 2023 15:01:52 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Mon 17 Jul 2023 15:01:52 BST | Rosetta is already installed and running. Nothing to do.
Mon 17 Jul 2023 15:01:52 BST | Checking if we need to install or update [Spotify]
Mon 17 Jul 2023 15:01:52 BST | [Spotify] not installed, need to download and install
Mon 17 Jul 2023 15:01:52 BST | Dock is here, lets carry on
Mon 17 Jul 2023 15:01:52 BST | Starting downlading of [Spotify]
Mon 17 Jul 2023 15:01:52 BST | Waiting for other [/usr/local/aria2/bin/aria2c] processes to end
Mon 17 Jul 2023 15:01:52 BST | No instances of [/usr/local/aria2/bin/aria2c] found, safe to proceed
Mon 17 Jul 2023 15:01:52 BST | Downloading Spotify [https://download.scdn.co/SpotifyARM64.dmg]
Mon 17 Jul 2023 15:01:54 BST | Found downloaded tempfile [SpotifyARM64.dmg]
Mon 17 Jul 2023 15:01:54 BST | Found DMG, looking inside...
Mon 17 Jul 2023 15:01:54 BST | Mounting Image [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.OPtiZTos/Spotify] [SpotifyARM64.dmg]
Mon 17 Jul 2023 15:02:01 BST | Mounted succesfully to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.OPtiZTos/Spotify]
Mon 17 Jul 2023 15:02:01 BST | Detected APP, setting PackageType to DMG
Mon 17 Jul 2023 15:02:01 BST | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.OPtiZTos/Spotify]
Mon 17 Jul 2023 15:02:01 BST | Downloaded [Spotify.app] to [SpotifyARM64.dmg]
Mon 17 Jul 2023 15:02:01 BST | Detected install type as [DMG]
Mon 17 Jul 2023 15:02:01 BST | Waiting for other [/Applications/Spotify.app/Contents/MacOS/Spotify] processes to end
Mon 17 Jul 2023 15:02:01 BST | No instances of [/Applications/Spotify.app/Contents/MacOS/Spotify] found, safe to proceed
Mon 17 Jul 2023 15:02:01 BST | Installing [Spotify]
Mon 17 Jul 2023 15:02:01 BST | Mounting Image [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.OPtiZTos/Spotify] [SpotifyARM64.dmg]
Mon 17 Jul 2023 15:02:01 BST | Copying app files to /Applications/Spotify.app
Mon 17 Jul 2023 15:02:10 BST | Fix up permissions
Mon 17 Jul 2023 15:02:10 BST | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.OPtiZTos/Spotify]
Mon 17 Jul 2023 15:02:10 BST | [Spotify] Installed
Mon 17 Jul 2023 15:02:10 BST | Cleaning Up
Mon 17 Jul 2023 15:02:10 BST | Fixing up permissions
Mon 17 Jul 2023 15:02:10 BST | Application [Spotify] succesfully installed
Mon 17 Jul 2023 15:02:10 BST | Writing last modifieddate [Fri, 07 Jul 2023 11:14:50 GMT] to [/Library/Logs/Microsoft/IntuneScripts/Spotify/Spotify.meta]
```
