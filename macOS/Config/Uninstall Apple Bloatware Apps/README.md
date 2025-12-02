# Uninstall Apple Bloatware Apps (iMovie, GarageBand, Pages, Numbers, and Keynote)
This Custom Script uninstalls following pre-installed bloatware application from Mac-devices that are usually installed when device is purchased from retailer:
- iMovie
- Garageband
- Pages
- Numbers
- Keynote

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/UninstallAppleBloatwareApps/UninstallAppleBloatwareApps.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sat Oct 18 21:51:19 EET 2025 | Starting running of script UninstallAppleBloatwareApps
############################################################

Sat Oct 18 21:51:19 EET 2025 | Checking MDM Profile Type
Enrolled via DEP: Yes
Sat Oct 18 21:51:20 EET 2025 | Device is ABM Managed
Sat Oct 18 21:51:20 EET 2025 | Uninstalling iMovie...
Sat Oct 18 21:51:22 EET 2025 | iMovie has been uninstalled.
Sat Oct 18 21:51:22 EET 2025 | Uninstalling GarageBand...
Sat Oct 18 21:51:24 EET 2025 | GarageBand has been uninstalled.
Sat Oct 18 21:51:24 EET 2025 | Uninstalling Pages...
Sat Oct 18 21:51:26 EET 2025 | Pages has been uninstalled.
Sat Oct 18 21:51:26 EET 2025 | Uninstalling Numbers...
Sat Oct 18 21:51:28 EET 2025 | Numbers has been uninstalled.
Sat Oct 18 21:51:28 EET 2025 | Uninstalling Keynote...
Sat Oct 18 21:51:30 EET 2025 | Keynote has been uninstalled.
Sat Oct 18 21:51:30 EET 2025 | Done. Closing script...
```