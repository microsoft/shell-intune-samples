# Access to Secure User's Home Folders
This Custom Script is required when implementing following CIS or NIST Recommendations for macOS: 
- **CIS**: Ensure Home Folders Are Secure (Automated)
- **NIST**: Secure User's Home Folders

## What it does

The script remediates two things that Microsoft Defender / Secure Score and the CIS macOS benchmark expect to see:

1. Every user home folder under `/Users` (excluding `Shared`, `Guest` and `.localized`) is set to mode `700`, `711` or `750`. The script removes group / other read, write and execute on any folder that does not already match.
2. `/Users/Shared` is set to mode `1777` (sticky bit, world-writable) and owned by `root:wheel`. This was missing from earlier versions of the script and is the most common reason that devices continued to be flagged as vulnerable in Defender even after the script ran successfully — see [this Tech Community thread](https://techcommunity.microsoft.com/discussions/microsoft-security/secure-score---secure-home-folders-in-macos/3930746).

The script must run as `root` and now exits non-zero if any folder could not be remediated, so failures surface in Intune instead of being silently logged.

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/SecureUsersHomeFolders/SecureUsersHomeFolders.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri Apr 24 09:11:27 BST 2026 | Starting running of script SecureUsersHomeFolders
############################################################

Fri Apr 24 09:11:27 BST 2026 | OK    | /Users/alice already mode 700
Fri Apr 24 09:11:27 BST 2026 | FIX   | /Users/bob is mode 755, removing group/other rwx
Fri Apr 24 09:11:27 BST 2026 | OK    | /Users/bob is now mode 700
Fri Apr 24 09:11:27 BST 2026 | FIX   | /Users/Shared is mode 777 owner root:wheel, resetting to 1777 root:wheel
Fri Apr 24 09:11:27 BST 2026 | OK    | /Users/Shared is now mode 1777 root:wheel
Fri Apr 24 09:11:27 BST 2026 | All user home folders and /Users/Shared are secured. Exiting 0.
```
