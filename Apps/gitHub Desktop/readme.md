# gitHub Desktop for Mac Installation Script

This script is am example showing how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install an application. In this instance the script downloads the gitHub Desktop files, uncompresses them and installs into the /Applications directory.

## Scenario

This scripts intended usage scenario is to deploy the gitHub Desktop app to Mac devices that need to use it.


## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

## Log File

The log file will output to **/Library/Logs/Microsoft/IntuneScripts/installGitHubDesktop/GitHub Desktop.log** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection).

```
##############################################################
# Fri  9 Apr 2021 13:00:15 BST | Logging install of [GitHub Desktop] to [/Library/Logs/Microsoft/IntuneScripts/installGitHubDesktop/GitHub Desktop.log]
############################################################

Fri  9 Apr 2021 13:00:15 BST | Checking if we need Rosetta 2 or not
Fri  9 Apr 2021 13:00:15 BST | Waiting for other [/usr/sbin/softwareupdate] processes to end
Fri  9 Apr 2021 13:00:15 BST | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Fri  9 Apr 2021 13:00:15 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Fri  9 Apr 2021 13:00:15 BST | Checking if we need to install or update [GitHub Desktop]
Fri  9 Apr 2021 13:00:15 BST | [GitHub Desktop] not installed, need to download and install
Fri  9 Apr 2021 13:00:15 BST | Dock is here, lets carry on
Fri  9 Apr 2021 13:00:15 BST | Starting downlading of [GitHub Desktop]
Fri  9 Apr 2021 13:00:15 BST | Waiting for other [curl] processes to end
Fri  9 Apr 2021 13:00:15 BST | No instances of [curl] found, safe to proceed
Fri  9 Apr 2021 13:00:15 BST | Downloading GitHub Desktop
Fri  9 Apr 2021 13:00:36 BST | Downloaded [GitHub Desktop.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.bAckYiJq/GitHubDesktop.zip]
Fri  9 Apr 2021 13:00:36 BST | Detected install type as [ZIP]
Fri  9 Apr 2021 13:00:36 BST | Waiting for other [/Applications/GitHub Desktop.app/Contents/MacOS/GitHub Desktop] processes to end
Fri  9 Apr 2021 13:00:36 BST | No instances of [/Applications/GitHub Desktop.app/Contents/MacOS/GitHub Desktop] found, safe to proceed
Fri  9 Apr 2021 13:00:36 BST | Waiting for other [installer -pkg] processes to end
Fri  9 Apr 2021 13:00:36 BST | No instances of [installer -pkg] found, safe to proceed
Fri  9 Apr 2021 13:00:36 BST | Waiting for other [cp -Rf] processes to end
Fri  9 Apr 2021 13:00:37 BST | No instances of [cp -Rf] found, safe to proceed
Fri  9 Apr 2021 13:00:37 BST | Waiting for other [unzip] processes to end
Fri  9 Apr 2021 13:00:37 BST | No instances of [unzip] found, safe to proceed
Fri  9 Apr 2021 13:00:37 BST | Installing GitHub Desktop
Fri  9 Apr 2021 13:00:41 BST | /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.bAckYiJq/GitHubDesktop.zip unzipped
Fri  9 Apr 2021 13:00:45 BST | GitHub Desktop moved into /Applications
Fri  9 Apr 2021 13:00:45 BST | Fix up permissions
Fri  9 Apr 2021 13:00:46 BST | correctly applied permissions to GitHub Desktop
Fri  9 Apr 2021 13:00:46 BST | GitHub Desktop Installed
Fri  9 Apr 2021 13:00:46 BST | Cleaning Up
Fri  9 Apr 2021 13:00:46 BST | Writing last modifieddate  to /Library/Logs/Microsoft/IntuneScripts/installGitHubDesktop/GitHub Desktop.meta
Fri  9 Apr 2021 13:00:46 BST | Fixing up permissions
Fri  9 Apr 2021 13:00:46 BST | Application [GitHub Desktop] succesfully installed
```