# Enable Safari Fraudulent Website Warning

This script is required when implementing following CIS or NIST Recommendations for macOS:

- **CIS:** Ensure Warn When Visiting A Fraudulent Website in Safari is Enabled (Automated)
- **NIST:** N/A

Safari's fraudulent website warning uses Google Safe Browsing data to alert users when they attempt to visit a known phishing or malware distribution site. This is a CIS Level 1 scored control. While most organisations use Edge or Chrome as their primary browser, Safari is always present on macOS and users may open links in it inadvertently.

There is no MDM restriction payload for this setting — it is a user-level Safari preference that must be configured via script.

## Script Settings

- Run script as signed-in user: **Yes**
- Hide script notifications on devices: **Yes**
- Script frequency: **Every 1 day**
- Number of times to retry if script fails: **3**

## Log File

The log file will output to `~/Library/Logs/Microsoft/IntuneScripts/EnableSafariFraudWarning/EnableSafariFraudWarning.log` by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Mon Mar 17 10:18:33 GMT 2026 | Starting running of script EnableSafariFraudWarning
############################################################

Mon Mar 17 10:18:33 GMT 2026 | Safari fraudulent website warning is not enabled. Enabling now...
Mon Mar 17 10:18:33 GMT 2026 | Successfully enabled Safari fraudulent website warning.
Mon Mar 17 10:18:33 GMT 2026 | Script EnableSafariFraudWarning completed.
```
