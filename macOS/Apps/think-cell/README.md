# think-cell Corporate Default Style File Installer

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the think-cell corporate default style file from your Azure Blob Storage or download server and then install it onto the Mac. 

## Things you need to do

1. Modify line 20 with the URL to the storage location you are using for your corporate default style file (Azure Blob Storage is handy for this).
2. Modify line 22 with the name of your corporate default style file.

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/think-cellCorporateDefaultStyleFileInstaller/think-cellCorporateDefaultStyleFileInstaller.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```

##############################################################
# Tue Sep  3 15:32:45 EEST 2024 | Starting running of script think-cellCorporateDefaultStyleFileInstaller
############################################################

Tue Sep  3 15:32:45 EEST 2024 | think-cell is installed. Let's proceed...
Tue Sep  3 15:32:47 EEST 2024 | Corporate default style file to think-cell has not be installed. Let's proceed...
Tue Sep  3 15:33:47 EEST 2024 | Corporate default style file to think-cell has been installed sucessfully. Closing script...
```