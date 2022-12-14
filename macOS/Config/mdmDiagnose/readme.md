# Intune MDM Log Gather Script

This is a script to help with macOS log gathering. The intent is to use [Intune Shell Script](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to deploy the script and then to download the gathered logs for MDM troubleshooting diagnosis.

The steps to use this script are as follows:

1. Deploy script via [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts)
2. Wait for script to complete
3. Use [Intune Script Agent Log Collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection) to gather the log files
4. Download the logs from Intune to your desktop

---
**NOTE**

It's often useful to target this script to a Log Gathering group in AAD and set it to run daily. 

---

# Tip for log collection

When the script completes, in the output window it will print a semi-colon separated list of log files that it has created. This line can be copied and pasted directly into the log gathering UI of Intune to avoid having to type out each file manually.


```
####################################### ## ## The following logs were created ## ####################### /Library/Logs/Microsoft/Intune/mdmDiagnose/mdmclientLogs.txt;/Library/Logs/Microsoft/Intune/mdmDiagnose/appInstallLogs.txt;/Library/Logs/Microsoft/Intune/mdmDiagnose/InstalledProfiles.txt;/Library/Logs/Microsoft/Intune/mdmDiagnose/enrollmentProfileInfo.txt;/Library/Logs/Microsoft/Intune/mdmDiagnose/system.log.3.gz;/Library/Logs/Microsoft/Intune/mdmDiagnose/InstalledApps.txt;/Library/Logs/Microsoft/Intune/mdmDiagnose/system.log.2.gz;/Library/Logs/Microsoft/Intune/mdmDiagnose/system.log.1.gz;/Library/Logs/Microsoft/Intune/mdmDiagnose/DeviceInformation.txt;/Library/Logs/Microsoft/Intune/mdmDiagnose/system.log.0.gz;/Library/Logs/Microsoft/Intune/mdmDiagnose/system.log;/Library/Logs/Microsoft/Intune/mdmDiagnose/install.log;/Library/Logs/Microsoft/Intune/mdmDiagnose/InstalledCerts.txt;/Library/Logs/Microsoft/Intune/mdmDiagnose/SecurityInfo.txt;
```




# Example set of output logs
```
/Library/Logs/Microsoft/Intune/mdmDiagnose/mdmclientLogs.txt
/Library/Logs/Microsoft/Intune/mdmDiagnose/appInstallLogs.txt
/Library/Logs/Microsoft/Intune/mdmDiagnose/InstalledProfiles.txt
/Library/Logs/Microsoft/Intune/mdmDiagnose/enrollmentProfileInfo.txt
/Library/Logs/Microsoft/Intune/mdmDiagnose/system.log.3.gz
/Library/Logs/Microsoft/Intune/mdmDiagnose/InstalledApps.txt
/Library/Logs/Microsoft/Intune/mdmDiagnose/system.log.2.gz
/Library/Logs/Microsoft/Intune/mdmDiagnose/system.log.1.gz
/Library/Logs/Microsoft/Intune/mdmDiagnose/DeviceInformation.txt
/Library/Logs/Microsoft/Intune/mdmDiagnose/system.log.0.gz
/Library/Logs/Microsoft/Intune/mdmDiagnose/system.log
/Library/Logs/Microsoft/Intune/mdmDiagnose/install.log
/Library/Logs/Microsoft/Intune/mdmDiagnose/InstalledCerts.txt
/Library/Logs/Microsoft/Intune/mdmDiagnose/SecurityInfo.txt
```
