# ImageOptim Sample Script - TBZ2 sample

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the ImageOptim TBZ2 file from the download servers and then install it onto the Mac.

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/ImageOptim/ImageOptim.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Wed 23 Feb 2022 17:20:52 GMT | Logging install of [ImageOptim] to [/Library/Logs/Microsoft/IntuneScripts/ImageOptim/ImageOptim.log]
############################################################

Wed 23 Feb 2022 17:20:52 GMT | Checking if we need Rosetta 2 or not
Wed 23 Feb 2022 17:20:52 GMT | Waiting for other [/usr/sbin/softwareupdate] processes to end
Wed 23 Feb 2022 17:20:53 GMT | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Wed 23 Feb 2022 17:20:53 GMT | Rosetta is already installed and running. Nothing to do.
Wed 23 Feb 2022 17:20:53 GMT | Checking if we need to install or update [ImageOptim]
Wed 23 Feb 2022 17:20:53 GMT | [ImageOptim] not installed, need to download and install
Wed 23 Feb 2022 17:20:53 GMT | Dock is here, lets carry on
Wed 23 Feb 2022 17:20:53 GMT | Starting downlading of [ImageOptim]
Wed 23 Feb 2022 17:20:53 GMT | Waiting for other [curl -f] processes to end
Wed 23 Feb 2022 17:20:53 GMT | No instances of [curl -f] found, safe to proceed
Wed 23 Feb 2022 17:20:53 GMT | Downloading ImageOptim [https://imageoptim.com/ImageOptim.tbz2]
Wed 23 Feb 2022 17:20:54 GMT | Downloaded [ImageOptim.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.G2FgKRey/ImageOptim.tbz2]
Wed 23 Feb 2022 17:20:54 GMT | Detected install type as [BZ2]
Wed 23 Feb 2022 17:20:54 GMT | Waiting for other [/Applications/ImageOptim.app/Contents/MacOS/ImageOptim] processes to end
Wed 23 Feb 2022 17:20:54 GMT | No instances of [/Applications/ImageOptim.app/Contents/MacOS/ImageOptim] found, safe to proceed
Wed 23 Feb 2022 17:20:54 GMT | Installing ImageOptim
Wed 23 Feb 2022 17:20:54 GMT | Changed current directory to /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.G2FgKRey
Wed 23 Feb 2022 17:20:54 GMT | /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.G2FgKRey/ImageOptim.tbz2 uncompressed
Wed 23 Feb 2022 17:20:55 GMT | ImageOptim moved into /Applications
Wed 23 Feb 2022 17:20:55 GMT | Fix up permissions
Wed 23 Feb 2022 17:20:55 GMT | correctly applied permissions to ImageOptim
Wed 23 Feb 2022 17:20:55 GMT | ImageOptim Installed
Wed 23 Feb 2022 17:20:56 GMT | Cleaning Up
Wed 23 Feb 2022 17:20:56 GMT | Writing last modifieddate [Sun, 16 Dec 2018 02:38:42 GMT] to [/Library/Logs/Microsoft/IntuneScripts/ImageOptim/ImageOptim.meta]
Wed 23 Feb 2022 17:20:56 GMT | Fixing up permissions
Wed 23 Feb 2022 17:20:56 GMT | Application [ImageOptim] succesfully installed
```
