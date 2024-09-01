# Access to Audit Recods is Controlled
This Custom Script is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure Access to Audit Records Is Controlled (Automated)
- **NIST**: 
  - Configure Audit Log Folders to be Owned by Root
  - Configure Audit Log Folders Group to Wheel
  - Configure Audit Log Folders to Mode 700 or Less Permissive

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/ControlledAuditRecords.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri Nov 29 09:11:27 EET 2023 | Starting running of script ControlledAuditRecords
############################################################

Fri Nov 29 09:11:27 EET 2023 | Security Auditing is enabled for devices running macOS Sonoma. Continuing...
Fri Nov 29 09:11:28 EET 2023 | Access to audit records is now controlled or already controlled. Closing script...
```
