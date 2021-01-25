# Script to rename a Mac device based on model type and serial number

This script renames a Mac device by looking at the model type and at the serial number
This is ideal for devices that are enrolled without user affinity. The script can be further customized to include the user name as part of the device rename.

## DeviceRename.sh

The script consists of three steps:
1) determine the model type and, based on the retrieved type, set a 4 characters variable $ModelCode
    e.g. MacBook Air ==> $ModelCode = MABA
2) collect the serial number and keep the first 10 characters
    e.g. Serial Number = C02BA222DC79 ==> $SerialNum = C02BA222DC
3) build the final name by combining $ModelCode and $serial
    e.g. $NewName = MABAC02BA222DC
    
```
# Define variables
appname="DeviceRename"
logandmetadir="/Library/Logs/Microsoft/Intune/Scripts/$appname"
log="$logandmetadir/$appname.log"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3

### Log file example

>**Note:** The log file will output to **/Library/Logs/Microsoft/Intune/Scripts/DeviceRename/DeviceRename.log** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
 ##############################################################
 # Mon Jan 25 10:00:00 GMT 2021 | Starting DeviceRename
 ############################################################

 Mon Jan 25 10:06:44 GMT 2021 | Checking if renaming is necessary
 Mon Jan 25 10:06:44 GMT 2021 | Serial detected as ABCDEF000017
 Mon Jan 25 10:06:44 GMT 2021 | Current computername detected as Testvm
 Mon Jan 25 10:06:44 GMT 2021 | Old Name: Testvm
 Mon Jan 25 10:06:45 GMT 2021 | Retrieved model name: MacBook Pro
 Mon Jan 25 10:06:45 GMT 2021 | Generating four characters code based on retrieved model name MacBook Pro
 Mon Jan 25 10:06:45 GMT 2021 | ModelCode variable set to MABP
 Mon Jan 25 10:06:45 GMT 2021 | Retrieved serial number: ABCDEF000017
 Mon Jan 25 10:06:45 GMT 2021 | Building the new name...
 Mon Jan 25 10:06:45 GMT 2021 | Generated Name: MABPABCDEF000017
 Device renamed from Testvm to MABPABCDEF000017

```
