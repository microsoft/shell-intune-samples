# WSL Management Custom Compliance - Distro and Version

This script can be used to calculate compliance against a windows device based on WSL distros and distro versions.

## Files Overview

1. WSLDistroVersionCompliance.ps1


This is the powershell script that will run during check-in. It is written to look at the WSL distro data and confirm whether or not the registered distros and versions are in compliance based on the provided approved distros and versions.

Inside the shell script, you can see the following on line 45. This is the allowed distro and min and max versions, (Ubuntu 20.04 to 22.04).

```
[void]$compliantDistroValues.Add([OSCompliance]::new("Ubuntu", "20.04", "22.04"))
```

If we run the script interactively with only Ubuntu 20.04 registered in WSL, we see the following...

```
{ "WSLInstancesComplianceStatus" = "Not Compliant" }
```

You can modify the script to check allow any distros and versions that you would like as well as a last check in time requirment (Lines 43-48).


2. WSLDetectionRule.json

The second file we require is a json payload that tells Intune what to expect from the script and how to determine if the device is compliant or not.

You can modify the Remediation Strings and More Info URL to your desired details.

```
{
   "Rules":[
      { 
         "SettingName":"WSLInstancesComplianceStatus",
         "Operator":"IsEquals",
         "DataType":"String",
         "Operand":"Compliant",
         "MoreInfoUrl":"",
         "RemediationStrings":[ 
            { 
               "Language": "en_US",
               "Title": "WSL Instance Distros and/or Versions are not in compliance",
               "Description": "Make sure only allowed distros and versions are registered in WSL"
            }
         ]
      }
   ]
}
```

## Deploying

To make use of these files, you'll first need to download them. The best way to do that easily is either to clone the entire repo, or click on the file and then right-click on 'raw' and select save link as.

Once you have both files saved locally, open the Intune console

Upload the shell script by navigating to the following location and pasting the contents of the shell script and saving.


- Devices > Compliance Policies > Scripts > Add


Use the JSON file at:


- Devices > Windows > Compliance Policies > Create Policy
- Select the discovery script you uploaded for the discovery script
- Select the JSON file that you downloaded in the rules file
- Assign the policy to a test group for now


## Testing

Remember that the sample policy here is checking for WSL to only have Ubuntu 20.04 to 22.04 registered.

- Log on to one of your managed Windows devices
- Launch the Intune App
- Tap 'Refresh'

Your device should show as not compliant if you have anything other than Ubuntu 20.04 to 22.04 registered, if you click on 'View Issues' you should see a warning that WSL insttance distros and/or versions are not in compliance.

- Unregister or update instances

Your device should now show as Compliant.