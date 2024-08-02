# Scripts to re-escrow Bootstrap Tokens
 
Use these scripts to help remediate issues when Intune is missing a Bootstrap Token for a supervised mac.
 
## Scenario
 
There are three scripts provided: `fixBootstrapToken.sh`, `fixBootstrapToken_interactive.sh` and `checkMacBootstrapStatus.ps1`

### checkMacBootstrapStatus.ps1

This is a PowerShell script that helps identify Managed Macs within your environment that have been impacted and require remediation.

To install and start PowerShell on Mac
1.	Install [PowerShell for Mac](https://github.com/PowerShell/PowerShell/releases)
2.	From a Mac terminal, type pwsh to start PowerShell

Once you have PowerShell running on either Mac or Windows:
3.	install-module Microsoft.Graph.Authentication -Scope CurrentUser
4.	install-module Microsoft.Graph.Beta.DeviceManagement -Scope CurrentUser


```
PS /Users/neiljohnson> ./checkMacBootstrapStatus.ps1
Welcome to Microsoft Graph!

Connected via delegated access using 14d82eec-204b-4c2f-b7e8-296a70dab67e
Readme: https://aka.ms/graph/sdk/powershell
SDK Docs: https://aka.ms/graph/sdk/powershell/docs
API Docs: https://aka.ms/graph/docs

NOTE: You can use the -NoWelcome parameter to suppress this message.

10 userless mac devices
8 userless mac devices escrowed
2 userless mac devices missing bootstrap tokens
exported to notEscrowedMac.csv
```

### fixBootStrapToken.sh usage

Use this script in scenarios where local admin credentials are well-known and consistent for all devices requiring remediation.

You will need to overwrite the ADMIN_USERNAME and ADMIN_PASSWORD in the script. This local admin account must have secure token enabled. For more information regarding secure tokens, go to https://support.apple.com/guide/deployment/use-secure-and-bootstrap-tokens-dep24dbdcf9e/web.

### fixBootstrapToken_interactive.sh usage

Use this script in scenarios where you want to prompt users to provide the local admin credentials rather than hard coding them into the script.

The local admin account must have secure token enabled. For more information regarding secure tokens, go to https://support.apple.com/guide/deployment/use-secure-and-bootstrap-tokens-dep24dbdcf9e/web.
 
## Script Settings
 
- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Configure this to any value other than "Not configured" (recommended 15 minutes)
- Mac number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Application Support/Microsoft/IntuneScripts/checkBootstrapEscrow/checkBootstrapEscrow.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)
