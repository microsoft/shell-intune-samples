# Enable Secure Keyboard Entry in Terminal

This script is required when implementing following CIS or NIST Recommendations for macOS:

- **CIS:** Ensure Secure Keyboard Entry terminal.app is Enabled (Automated)
- **NIST:** N/A

Secure Keyboard Entry prevents other applications or processes from intercepting keystrokes entered in Terminal. Without this setting, a malicious process could use the CGEventTap API to capture passwords and other sensitive text typed into Terminal sessions. This is a CIS Level 1 scored control.

There is no MDM restriction payload for this setting — it is a user-level preference that must be configured via script.

## Script Settings

- Run script as signed-in user: **Yes**
- Hide script notifications on devices: **Yes**
- Script frequency: **Every 1 day**
- Number of times to retry if script fails: **3**

## Log File

The log file will output to `~/Library/Logs/Microsoft/IntuneScripts/EnableSecureKeyboardEntry/EnableSecureKeyboardEntry.log` by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Mon Mar 17 10:15:22 GMT 2026 | Starting running of script EnableSecureKeyboardEntry
############################################################

Mon Mar 17 10:15:22 GMT 2026 | Secure Keyboard Entry is not enabled. Enabling now...
Mon Mar 17 10:15:22 GMT 2026 | Successfully enabled Secure Keyboard Entry in Terminal.
Mon Mar 17 10:15:22 GMT 2026 | Script EnableSecureKeyboardEntry completed.
```
