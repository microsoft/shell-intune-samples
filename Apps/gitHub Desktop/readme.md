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

The log file will output to **/Library/Logs/Microsoft/IntuneScripts/installGitHubDesktop/gitHub_Desktop.meta.log** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection).

```
##############################################################
# Fri 26 Mar 2021 17:56:29 GMT | Starting install of gitHub_Desktop
############################################################

Fri 26 Mar 2021 17:56:29 GMT | https://central.github.com/deployments/desktop/desktop/latest/darwin last update on Wed, 10 Mar 2021 10:55:44 GMT
Fri 26 Mar 2021 17:56:29 GMT | Looking for metafile (/Library/Logs/Microsoft/IntuneScripts/installGitHubDesktop/gitHub_Desktop.meta)
Fri 26 Mar 2021 17:56:29 GMT | Meta file /Library/Logs/Microsoft/IntuneScripts/installGitHubDesktop/gitHub_Desktop.meta notfound, downloading anyway
Fri 26 Mar 2021 17:56:29 GMT | Downloading gitHub_Desktop
Fri 26 Mar 2021 17:56:47 GMT | Downloaded https://central.github.com/deployments/desktop/desktop/latest/darwin to /tmp/githubdesktop.zip
Fri 26 Mar 2021 17:56:47 GMT | GitHub Desktop.app isn't running, lets carry on
Fri 26 Mar 2021 17:56:47 GMT | Installing gitHub_Desktop
Fri 26 Mar 2021 17:56:50 GMT | /tmp/githubdesktop.zip unzipped
Fri 26 Mar 2021 17:56:50 GMT | Renoving old installation at /Applications/GitHub Desktop.app
Fri 26 Mar 2021 17:56:51 GMT | gitHub_Desktop moved into /Applications
Fri 26 Mar 2021 17:56:51 GMT | Fix up permissions
Fri 26 Mar 2021 17:56:52 GMT | correctly applied permissions to gitHub_Desktop
Fri 26 Mar 2021 17:56:52 GMT | gitHub_Desktop Installed
Fri 26 Mar 2021 17:56:52 GMT | Cleaning Up
Fri 26 Mar 2021 17:56:52 GMT | Writing last modifieddate Wed, 10 Mar 2021 10:55:44 GMT to /Library/Logs/Microsoft/IntuneScripts/installGitHubDesktop/gitHub_Desktop.meta
Fri 26 Mar 2021 17:56:52 GMT | Fixing up permissions
Fri 26 Mar 2021 17:56:52 GMT | Application [gitHub_Desktop] succesfully installed
```