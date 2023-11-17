# Gatekeeper Enabler
Even though there is a possibility to enable Gatekeeper via MDM, unfortunately if Mac-user have admin-rights, user can easily override changes via Terminal. As disabling Gatekeeper is definitely NOT RECOMMENDED, we need to have a way to fix this loophole automated way. 

Therefore, this script has been created which will check the status of Gatekeeper and if it is disabled, it will be enabled back immediately when script runs.

![Apu Apustaja giving thumbs up](https://i.kym-cdn.com/photos/images/original/001/221/732/902.jpg)
This script is [Apu Apustaja](https://knowyourmeme.com/memes/apu-apustaja) -approved.

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Every 1 day (if you want to run this script more frequently, that is also possible)
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/GatekeeperEnabler.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Fri Nov 17 10:11:27 PST 2023 | Starting running of script GatekeeperEnabler
############################################################

Fri Nov 17 10:11:27 PST 2023 | Checking status of Gatekeeper...
Fri Nov 17 10:11:27 PST 2023 | Gatekeeper is not enabled. Re-enabling it..."
Fri Nov 17 10:11:28 PST 2023 | Gatekeeper is re-enabled. Closing script..."
```
