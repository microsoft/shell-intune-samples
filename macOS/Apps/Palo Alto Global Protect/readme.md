# Nudge Installation

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Global Protect pkg file from your download server and then install it onto the Mac.

## Things you'll need to do

1. Modify line 35 with the URL to the storage location you are using for GlobalProtect.PKG (Azure Blob Storage is handy for this)
2. Update line 42 with the Global Protect VPN Portal URL for your users

## Log File

```
#############################################################
# Thu 25 Aug 2022 06:17:23 PDT | Logging install of [GlobalProtect] to [/Library/Logs/Microsoft/IntuneScripts/GlobalProtect/GlobalProtect.log]
############################################################

Thu 25 Aug 2022 06:17:23 PDT | Checking if we need Rosetta 2 or not
Thu 25 Aug 2022 06:17:23 PDT | Waiting for other [/usr/sbin/softwareupdate] processes to end
Thu 25 Aug 2022 06:17:23 PDT | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Thu 25 Aug 2022 06:17:23 PDT | Rosetta is already installed and running. Nothing to do.
Thu 25 Aug 2022 06:17:23 PDT | Checking if we need to install or update [GlobalProtect]
Thu 25 Aug 2022 06:17:23 PDT | [GlobalProtect] not installed, need to download and install
Thu 25 Aug 2022 06:17:23 PDT | Dock is here, lets carry on
Thu 25 Aug 2022 06:17:23 PDT | Starting downlading of [GlobalProtect]
Thu 25 Aug 2022 06:17:23 PDT | Waiting for other [curl -f] processes to end
Thu 25 Aug 2022 06:17:23 PDT | No instances of [curl -f] found, safe to proceed
Thu 25 Aug 2022 06:17:23 PDT | Downloading GlobalProtect [https://catlab.blob.core.windows.net/xxxxx]
Thu 25 Aug 2022 06:17:25 PDT | Found downloaded tempfile [GlobalProtect.pkg]
Thu 25 Aug 2022 06:17:25 PDT | Unknown file type [GlobalProtect.pkg?sp=r&st=2022-08-25T12:37:30Z&se=2099-08-25T20:37:30Z&spr=https&sv=2021-06-08&sr=b&sig=4HnMlm3dA9dJICxnpadFGNXZE8RuyRDCdXyMb1Xt9G0%3D], analysing metadata
Thu 25 Aug 2022 06:17:25 PDT | [DEBUG] File metadata [GlobalProtect.pkg?sp=r&st=2022-08-25T12:37:30Z&se=2099-08-25T20:37:30Z&spr=https&sv=2021-06-08&sr=b&sig=4HnMlm3dA9dJICxnpadFGNXZE8RuyRDCdXyMb1Xt9G0%3D: xar archive compressed TOC: 4686, SHA-1 checksum]
Thu 25 Aug 2022 06:17:25 PDT | Downloaded [GlobalProtect.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.RrdkgvZP/install.pkg]
Thu 25 Aug 2022 06:17:25 PDT | Detected install type as [PKG]
Thu 25 Aug 2022 06:17:25 PDT | Waiting for other [/Applications/GlobalProtect.app/Contents/MacOS/GlobalProtect] processes to end
Thu 25 Aug 2022 06:17:25 PDT | No instances of [/Applications/GlobalProtect.app/Contents/MacOS/GlobalProtect] found, safe to proceed
Thu 25 Aug 2022 06:17:25 PDT | Installing GlobalProtect
installer: Package name is GlobalProtect
installer: Installing at base path /
installer: The install was successful.
Thu 25 Aug 2022 06:17:30 PDT | GlobalProtect Installed
Thu 25 Aug 2022 06:17:30 PDT | Cleaning Up
Thu 25 Aug 2022 06:17:30 PDT | Application [GlobalProtect] succesfully installed
Thu 25 Aug 2022 06:17:30 PDT | Writing last modifieddate [Thu, 25 Aug 2022 12:37:20 GMT] to [/Library/Logs/Microsoft/IntuneScripts/GlobalProtect/GlobalProtect.meta]
```


