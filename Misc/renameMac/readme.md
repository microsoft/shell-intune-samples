# Script to rename a Mac device based on model type and serial number

This script renames a Mac device by looking at the model type and at the serial number
This is ideal for devices that are enrolled without user affinity. The script can be further customized to include the user name as part of the device rename.

## rename-mac.sh

The script consists of three steps:
1) determine the model type and, based on the retrieved type, set a 4 characters variable $ModelCode
    e.g. MacBook Air ==> $ModelCode = MABA
2) collect the serial number and keep the first 10 characters
    e.g. Serial Number = C02BA222DC79 ==> $SerialNum = C02BA222DC
3) build the final name by combining $ModelCode and $serial
    e.g. $NewName = MABAC02BA222DC
## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3
