# Add Policy Banner
This script is used to push a policy banner for your macOS devices. A policy banner is a banner that displays at the login window that requires you to acknowledge it before proceeding.

![image](https://github.com/user-attachments/assets/7350976e-80a1-44fd-ba3c-bb99525174d1)


## Script Settings
Modify the language for the Policy Banner before saving and uploading to Intune. 
- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File
The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/PolicyBanner.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri Nov 29 09:11:27 EET 2024 | Starting running of script PolicyBanner
############################################################

```
