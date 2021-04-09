# Zoom Installation Script

This script is am example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Zoom.pkg file from the Zoom download servers and then install it onto the Mac.


## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Weekly
- Mac number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installZoom/Zoom.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
Fri  9 Apr 2021 12:44:27 BST | Creating [/Library/Logs/Microsoft/IntuneScripts/installZoom] to store logs

##############################################################
# Fri  9 Apr 2021 12:44:27 BST | Logging install of [Zoom] to [/Library/Logs/Microsoft/IntuneScripts/installZoom/Zoom.log]
############################################################

Fri  9 Apr 2021 12:44:27 BST | Checking if we need Rosetta 2 or not
Fri  9 Apr 2021 12:44:27 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri  9 Apr 2021 12:44:27 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri  9 Apr 2021 12:44:27 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Fri  9 Apr 2021 12:44:27 BST | Checking if we need to install or update [Zoom]
Fri  9 Apr 2021 12:44:27 BST | [Zoom] not installed, need to download and install
Fri  9 Apr 2021 12:44:27 BST | Dock is here, lets carry on
Fri  9 Apr 2021 12:44:27 BST | Starting downlading of [Zoom]
Fri  9 Apr 2021 12:44:27 BST | Waiting for other [curl] processes to end
Fri  9 Apr 2021 12:44:28 BST | No instances of [curl] found, safe to proceed
Fri  9 Apr 2021 12:44:28 BST | Downloading Zoom
Fri  9 Apr 2021 12:44:32 BST | Downloaded [zoom.us.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.0Kqg6V92/Zoom.pkg]
Fri  9 Apr 2021 12:44:32 BST | Detected install type as [PKG]
Fri  9 Apr 2021 12:44:32 BST | Waiting for other [/Applications/zoom.us.app/Contents/MacOS/zoom.us] processes to end
Fri  9 Apr 2021 12:44:32 BST | No instances of [/Applications/zoom.us.app/Contents/MacOS/zoom.us] found, safe to proceed
Fri  9 Apr 2021 12:44:32 BST | Installing Zoom
Fri  9 Apr 2021 12:44:32 BST | Waiting for other [installer -pkg] processes to end
Fri  9 Apr 2021 12:44:33 BST | No instances of [installer -pkg] found, safe to proceed
Fri  9 Apr 2021 12:44:33 BST | Waiting for other [cp -Rf] processes to end
Fri  9 Apr 2021 12:44:33 BST | No instances of [cp -Rf] found, safe to proceed
Fri  9 Apr 2021 12:44:33 BST | Waiting for other [unzip] processes to end
Fri  9 Apr 2021 12:44:33 BST | No instances of [unzip] found, safe to proceed
installer: Package name is Zoom
installer: Installing at base path /
installer: The install was successful.
Fri  9 Apr 2021 12:44:40 BST | Zoom Installed
Fri  9 Apr 2021 12:44:40 BST | Cleaning Up
Fri  9 Apr 2021 12:44:40 BST | Application [Zoom] succesfully installed
Fri  9 Apr 2021 12:44:41 BST | Writing last modifieddate [Mon, 29 Mar 2021 09:52:33 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installZoom/Zoom.meta]
```
