# FileZilla Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the FileZilla tar.bz2 file from the download servers and then install it onto the Mac.

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/FileZilla/FileZilla.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Mon 28 Feb 2022 12:09:26 GMT | Logging install of [FileZilla] to [/Library/Logs/Microsoft/IntuneScripts/FileZilla/FileZilla.log]
############################################################

Mon 28 Feb 2022 12:09:26 GMT | Checking if we need Rosetta 2 or not
Mon 28 Feb 2022 12:09:26 GMT | Waiting for other [/usr/sbin/softwareupdate] processes to end
Mon 28 Feb 2022 12:09:26 GMT | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Mon 28 Feb 2022 12:09:26 GMT | Rosetta is already installed and running. Nothing to do.
Mon 28 Feb 2022 12:09:26 GMT | Checking if we need to install or update [FileZilla]
Mon 28 Feb 2022 12:09:26 GMT | [FileZilla] not installed, need to download and install
Mon 28 Feb 2022 12:09:27 GMT | Dock is here, lets carry on
Mon 28 Feb 2022 12:09:27 GMT | Starting downlading of [FileZilla]
Mon 28 Feb 2022 12:09:27 GMT | Waiting for other [curl -f] processes to end
Mon 28 Feb 2022 12:09:27 GMT | No instances of [curl -f] found, safe to proceed
Mon 28 Feb 2022 12:09:27 GMT | Downloading FileZilla [https://dl3.cdn.filezilla-project.org/client/FileZilla_3.58.0_macosx-x86.tar.bz2?h=SZgBP-QNYQxJtPn8uo_kBw&x=1646051403]
Mon 28 Feb 2022 12:09:28 GMT | Unknown file type [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.fVerKKnw/FileZilla_3.58.0_macosx-x86.tar.bz2?h=SZgBP-QNYQxJtPn8uo_kBw&x=1646051403], analysing metadata
Mon 28 Feb 2022 12:09:28 GMT | Downloaded [FileZilla.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.fVerKKnw/install.tar.bz2]
Mon 28 Feb 2022 12:09:28 GMT | Detected install type as [BZ2]
Mon 28 Feb 2022 12:09:28 GMT | Waiting for other [/Applications/FileZilla.app/Contents/MacOS/filezilla] processes to end
Mon 28 Feb 2022 12:09:28 GMT | No instances of [/Applications/FileZilla.app/Contents/MacOS/filezilla] found, safe to proceed
Mon 28 Feb 2022 12:09:28 GMT | Installing FileZilla
Mon 28 Feb 2022 12:09:28 GMT | Changed current directory to /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.fVerKKnw
Mon 28 Feb 2022 12:09:29 GMT | /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.fVerKKnw/install.tar.bz2 uncompressed
Mon 28 Feb 2022 12:09:30 GMT | FileZilla moved into /Applications
Mon 28 Feb 2022 12:09:30 GMT | Fix up permissions
Mon 28 Feb 2022 12:09:30 GMT | correctly applied permissions to FileZilla
Mon 28 Feb 2022 12:09:30 GMT | FileZilla Installed
Mon 28 Feb 2022 12:09:30 GMT | Cleaning Up
Mon 28 Feb 2022 12:09:30 GMT | Writing last modifieddate [Fri, 11 Feb 2022 16:58:01 GMT] to [/Library/Logs/Microsoft/IntuneScripts/FileZilla/FileZilla.meta]
Mon 28 Feb 2022 12:09:30 GMT | Fixing up permissions
Mon 28 Feb 2022 12:09:30 GMT | Application [FileZilla] succesfully installed
```
