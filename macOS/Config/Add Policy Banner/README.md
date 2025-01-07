# Add Policy Banner
This script is used to push a policy banner for your macOS devices. A policy banner is a banner that displays at the login window that requires you to acknowledge it before proceeding.

<img src="https://github.com/user-attachments/assets/7350976e-80a1-44fd-ba3c-bb99525174d1" alt="image" width="400"/>


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
# Mon Jan  6 15:20:04 CST 2025 | Starting running of script PolicyBanner
############################################################
 
Mon Jan  6 15:20:04 CST 2025 | Creating the Policy Banner file stating:
This is the Policy Banner for the Mac. By logging in you agree to the terms and conditions of the UEMCATLABS. If you do not agree, please log out now.
Mon Jan  6 15:20:09 CST 2025 | Policy Banner file created successfully
Mon Jan  6 15:20:09 CST 2025 | Permissions set on Policy Banner file

```
