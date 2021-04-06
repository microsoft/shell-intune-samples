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
# Tue  6 Apr 2021 18:38:19 BST | Logging install of [GitHub Desktop] to [/Library/Logs/Microsoft/IntuneScripts/installGitHubDesktop/GitHub Desktop.log]
############################################################

Tue  6 Apr 2021 18:38:19 BST | Checking if we need Rosetta 2 or not
Tue  6 Apr 2021 18:38:19 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Tue  6 Apr 2021 18:38:19 BST | Checking if we need to install or update [GitHub Desktop]
Tue  6 Apr 2021 18:38:19 BST | [GitHub Desktop] not installed, need to download and install
Tue  6 Apr 2021 18:38:19 BST | Starting downlading of [GitHub Desktop]
Tue  6 Apr 2021 18:38:19 BST | Waiting for other Curl processes to end
Tue  6 Apr 2021 18:38:19 BST | No instances of Curl found, safe to proceed
Tue  6 Apr 2021 18:38:19 BST | Downloading GitHub Desktop
Tue  6 Apr 2021 18:38:41 BST | Downloaded [GitHub Desktop.app]
Tue  6 Apr 2021 18:38:41 BST | Checking if the application is running
Tue  6 Apr 2021 18:38:42 BST | [GitHub Desktop] isn't running, lets carry on
Tue  6 Apr 2021 18:38:42 BST | Installing GitHub Desktop
Tue  6 Apr 2021 18:38:47 BST | /tmp/githubdesktop.zip unzipped
Tue  6 Apr 2021 18:38:55 BST | GitHub Desktop moved into /Applications
Tue  6 Apr 2021 18:38:55 BST | Fix up permissions
Tue  6 Apr 2021 18:38:55 BST | correctly applied permissions to GitHub Desktop
Tue  6 Apr 2021 18:38:55 BST | GitHub Desktop Installed
Tue  6 Apr 2021 18:38:55 BST | Cleaning Up
Tue  6 Apr 2021 18:38:56 BST | Writing last modifieddate  to /Library/Logs/Microsoft/IntuneScripts/installGitHubDesktop/GitHub Desktop.meta
Tue  6 Apr 2021 18:38:56 BST | Fixing up permissions
Tue  6 Apr 2021 18:38:56 BST | Application [GitHub Desktop] succesfully installed
```