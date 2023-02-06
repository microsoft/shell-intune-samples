# Linux Custom Compliance Sample - Running Processes

These are some sample scripts to show how to make the most of [Linux Custom Compliance Policies and Settings](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-use-custom-settings). Please ensure that you have read the documentation for this feature before making use of these samples.

The samples are provided as samples and include no warranty, implied or otherwise.

## Files Overview

Like all of these samples, this one is made up of two parts.

1. CheckForProcessRunning.sh


This is the shell script and will run during check-in. It is written to look at a list of processes and test to see if they are running. Be aware that compliance scripts must be POSIX compliant, the easiest way to validate this is to try to run them within the dash interpreter on Linux.

As a purely ficticious sample, we're looking for msedge (Edge Browser) and the gnome-shell (Gnome Desktop).

Inside the shell script, you can see the following on line 5. These are the processes that we're going to check for.

```
processes="msedge gnome-shell"
```

If we run the script interactively with both Edge and Gnome running, we see the following...

```
azureuser@CATLABUBUNTU:~$ ./processScript.sh 
{"msedge": "Running","gnome-shell": "Running"}
```

The script also writes a long file to $HOME/compliance.log, which we can see by typing the following

```
azureuser@CATLABUBUNTU:~$ cat compliance.log 
Mon Feb  6 14:24:15 UTC 2023 | Starting compliance script
Mon Feb  6 14:24:15 UTC 2023 |   + Working on process [msedge]...Running
Mon Feb  6 14:24:15 UTC 2023 |   + Working on process [gnome-shell]...Running
Mon Feb  6 14:24:15 UTC 2023 | Ending compliance script
```

You can modify the script to check for any processes that you need to check for.


2. CheckForProcessRunning.json

The second file we require is a json payload that tells Intune what to expect from the script and how to determine if the device is compliant or not.

In our sample, you can see that both processes we are checking for have an entry, along with a value 'Operand' which if we see in the script output, we'll mark the device as compliant.

```
{
    "Rules":[ 
        { 
           "SettingName":"msedge",
           "Operator":"IsEquals",
           "DataType":"String",
           "Operand":"Running",
           "MoreInfoUrl":"https://www.microsoftedgeinsider.com/en-us/download/?platform=linux",
           "RemediationStrings":[ 
              { 
                 "Language": "en_US",
                 "Title": "Microsoft Edge Not Running",
                 "Description": "Please ensure that Microsoft Edge is running at all times"
              }
           ]
         },
         { 
            "SettingName":"gnome-shell",
            "Operator":"IsEquals",
            "DataType":"String",
            "Operand":"Running",
            "MoreInfoUrl":"https://www.gnome.org/",
            "RemediationStrings":[ 
               { 
                  "Language": "en_US",
                  "Title": "Gnome Shell Not Running",
                  "Description": "Please ensure that Gnome Shell is running"
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


- Devices > Linux > Compliance Policies > Create Policy
- Select the discovery script you uploaded for the discovery script
- Select the JSON file that you downloaded in the rules file
- Assign the policy to a test group for now


## Testing

Remember that the sample policy here is checking for gnome-shell and msedge, so for now make sure that Edge is not running.

- Log on to one of your managed Ubuntu Linux devices
- Launch the Intune App
- Tap 'Refresh'

Your device should show as not compliant, if you click on 'View Issues' you should see a warning that Edge must be running.

- [Install Edge](https://www.microsoftedgeinsider.com/en-us/download/?platform=linux-deb) if you don't already have it
- Launch Edge
- Launch the Intune App and click refresh

Your device should now show as Compliant.
