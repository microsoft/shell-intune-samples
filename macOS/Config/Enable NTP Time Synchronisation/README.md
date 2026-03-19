# Enable NTP Time Synchronisation

This script is required when implementing following CIS or NIST Recommendations for macOS:

- **CIS:** Ensure Set Time and Date Automatically Is Enabled (Automated)
- **NIST:** N/A

Accurate time synchronisation is critical for security logging, certificate validation, Kerberos authentication, and Conditional Access evaluation. If the device clock drifts significantly, authentication tokens may be rejected and audit logs become unreliable. This is a CIS Level 1 scored control.

There is no MDM restriction payload to enforce NTP — this must be verified and enabled via script.

## Script Settings

- Run script as signed-in user: **No**
- Hide script notifications on devices: **Yes**
- Script frequency: **Not configured** (run once)
- Number of times to retry if script fails: **3**

## Log File

The log file will output to `/Library/Logs/Microsoft/IntuneScripts/EnableNTPTimeSync/EnableNTPTimeSync.log` by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Mon Mar 17 10:22:05 GMT 2026 | Starting running of script EnableNTPTimeSync
############################################################

Mon Mar 17 10:22:05 GMT 2026 | Network time synchronisation is already enabled. No changes needed.
Mon Mar 17 10:22:05 GMT 2026 | Current time server: Network Time Server: time.apple.com
Mon Mar 17 10:22:05 GMT 2026 | Script EnableNTPTimeSync completed.
```
