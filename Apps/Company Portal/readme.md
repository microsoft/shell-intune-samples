# Intune Company Portal Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Company Portal pkg file from the Microsoft download servers and then install it onto the Mac.

## Scenario

This script has a few scenarios

- DEP/ADE enrolled Macs that need to complete their device registration for conditional access.
- Provide end users with a quick and easy way to get started

>Note
>To deploy via Intune, follow the instructions [here](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts).
>
>To deploy directly, advise the end users to copy and paste the following into a Terminal prompt.

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Company%20Portal/installCompanyPortal.sh)" ; open "/Applications/Company Portal.app"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3
