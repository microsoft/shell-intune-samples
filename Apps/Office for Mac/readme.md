# Scripts for Microsoft Office for Mac

These scripts provide examples of how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to deploy Microsoft Office for Mac

Our recommended method of deploying Office for Mac is to use the [Apple Volume Purchase Program](https://docs.microsoft.com/en-us/mem/intune/apps/vpp-apps-ios) feature within Microsoft Intune. This can be used to individually select the Microsoft Office apps, they'll update automatically via the Mac App Store and automatically be cached if you have a local [Apple Asset Cache](https://support.apple.com/en-gb/guide/mac-help/mchl9388ba1b/mac). Additionally, this method is compatible with macOS 11's 'Managed App' feature coming to Big Sur.

Common scenarios where these scripts might be used:

- Needing to deploy a specific version of Office to some Macs
- Needing to control the update channel for some users (InsiderFast, Slow etc). Note that the apps deployed via VPP will always be the Production channel)
- Needing to control how the Microsoft Autoupdate App is configured. Note that apps delivered via VPP do not use MAU.
- Needing to remove OfficeBusinessPro
- Installing Outlook Support Tools (OutlookResetPreferences, OutlookResetRecentAddresses and OutlookAsDefaultMailClient)


The following scripts are provided as examples of how you could use Intune Shell Scripting to solve unique requirements in your organisation, such as installing a specific version from a local cache or wanting to change the update

>Note: Unless stated, the scripts should be uploaded to Intune and deployed via the Intune Scripting Agent.

## installOfficeBusinessPro.sh

This scripts intended usage scenario is to install Office Business Pro for Mac. It will look for a pre-defined local copy of Office and fail back to the CDN server location if that cannot be found.

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Apps/Office%20for%20Mac/installOfficeBusinessPro.sh)"
```

### Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not Configured
- Number of times to retry if script fails : 3

## installOfficeSuiteIndividualApps.sh

This scripts intended usage scenario is to install the individual apps within Office Business Pro for Mac. It has a defined array of apps that you want to install and the script will download and install only those apps.

The array definition is as follows. The values in the array come from the [XML File published by the Office Team](https://macadmins.software/latest.xml). The script will parse the XML for the 'id' value specified in the array and then attempt to download the URL found for that package.

the intent of this script is to provide control over which apps get deployed.

```
AppsToInstall=(   "com.microsoft.word.standalone.365"
                  "com.microsoft.excel.standalone.365"
                  "com.microsoft.powerpoint.standalone.365"
                  "com.microsoft.outlook.standalone.365"
                  "com.microsoft.onenote.standalone.365"
                  "com.microsoft.onedrive.standalone"
                  "com.microsoft.skypeforbusiness.standalone"
                  "com.microsoft.teams.standalone"
                  )
```
### Log File

The log file will output to ***/Library/Intune/Scripts/installOfficeSuiteIndividual/installOfficeSuiteIndividual.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | Starting Individual Office App Installs [8] found
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | Downloading latest XML file from [https://macadmins.software/latest.xml]
Tue 16 Feb 2021 21:20:57 GMT | Successfully downloaded [https://macadmins.software/latest.xml] to [/tmp/latest.xml]
Tue 16 Feb 2021 21:20:57 GMT | Looking for download URL for com.microsoft.word.standalone.365
Tue 16 Feb 2021 21:20:57 GMT | Successfully parsed xml file [/tmp/latest.xml] for [com.microsoft.word.standalone.365] -> [https://go.microsoft.com/fwlink/?linkid=525134]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | [1 / 8] Starting install of Word 365/2019 Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | AppName = Word 365/2019 Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT | AppUrl = https://go.microsoft.com/fwlink/?linkid=525134
Tue 16 Feb 2021 21:20:57 GMT | MinOSVer = 10.14
Tue 16 Feb 2021 21:20:57 GMT | Local Temp file = /tmp/com.microsoft.word.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Attempting to download [https://go.microsoft.com/fwlink/?linkid=525134] to /tmp/com.microsoft.word.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully downloaded from [https://go.microsoft.com/fwlink/?linkid=525134] to [/tmp/com.microsoft.word.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Attempting to install [Word 365/2019 Standalone Installer] from /tmp/com.microsoft.word.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully installed [Word 365/2019 Standalone Installer] from [/tmp/com.microsoft.word.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Cleaning up tmp file [/tmp/com.microsoft.word.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | End of Word 365/2019 Standalone Installer install
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | Looking for download URL for com.microsoft.excel.standalone.365
Tue 16 Feb 2021 21:20:57 GMT | Successfully parsed xml file [/tmp/latest.xml] for [com.microsoft.excel.standalone.365] -> [https://go.microsoft.com/fwlink/?linkid=525135]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | [2 / 8] Starting install of Excel 365/2019 Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | AppName = Excel 365/2019 Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT | AppUrl = https://go.microsoft.com/fwlink/?linkid=525135
Tue 16 Feb 2021 21:20:57 GMT | MinOSVer = 10.14
Tue 16 Feb 2021 21:20:57 GMT | Local Temp file = /tmp/com.microsoft.excel.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Attempting to download [https://go.microsoft.com/fwlink/?linkid=525135] to /tmp/com.microsoft.excel.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully downloaded from [https://go.microsoft.com/fwlink/?linkid=525135] to [/tmp/com.microsoft.excel.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Attempting to install [Excel 365/2019 Standalone Installer] from /tmp/com.microsoft.excel.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully installed [Excel 365/2019 Standalone Installer] from [/tmp/com.microsoft.excel.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Cleaning up tmp file [/tmp/com.microsoft.excel.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | End of Excel 365/2019 Standalone Installer install
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | Looking for download URL for com.microsoft.powerpoint.standalone.365
Tue 16 Feb 2021 21:20:57 GMT | Successfully parsed xml file [/tmp/latest.xml] for [com.microsoft.powerpoint.standalone.365] -> [https://go.microsoft.com/fwlink/?linkid=525136]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | [3 / 8] Starting install of PowerPoint 365/2019 Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | AppName = PowerPoint 365/2019 Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT | AppUrl = https://go.microsoft.com/fwlink/?linkid=525136
Tue 16 Feb 2021 21:20:57 GMT | MinOSVer = 10.14
Tue 16 Feb 2021 21:20:57 GMT | Local Temp file = /tmp/com.microsoft.powerpoint.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Attempting to download [https://go.microsoft.com/fwlink/?linkid=525136] to /tmp/com.microsoft.powerpoint.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully downloaded from [https://go.microsoft.com/fwlink/?linkid=525136] to [/tmp/com.microsoft.powerpoint.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Attempting to install [PowerPoint 365/2019 Standalone Installer] from /tmp/com.microsoft.powerpoint.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully installed [PowerPoint 365/2019 Standalone Installer] from [/tmp/com.microsoft.powerpoint.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Cleaning up tmp file [/tmp/com.microsoft.powerpoint.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | End of PowerPoint 365/2019 Standalone Installer install
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | Looking for download URL for com.microsoft.outlook.standalone.365
Tue 16 Feb 2021 21:20:57 GMT | Successfully parsed xml file [/tmp/latest.xml] for [com.microsoft.outlook.standalone.365] -> [https://go.microsoft.com/fwlink/?linkid=525137]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | [4 / 8] Starting install of Outlook 365/2019 Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | AppName = Outlook 365/2019 Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT | AppUrl = https://go.microsoft.com/fwlink/?linkid=525137
Tue 16 Feb 2021 21:20:57 GMT | MinOSVer = 10.14
Tue 16 Feb 2021 21:20:57 GMT | Local Temp file = /tmp/com.microsoft.outlook.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Attempting to download [https://go.microsoft.com/fwlink/?linkid=525137] to /tmp/com.microsoft.outlook.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully downloaded from [https://go.microsoft.com/fwlink/?linkid=525137] to [/tmp/com.microsoft.outlook.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Attempting to install [Outlook 365/2019 Standalone Installer] from /tmp/com.microsoft.outlook.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully installed [Outlook 365/2019 Standalone Installer] from [/tmp/com.microsoft.outlook.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Cleaning up tmp file [/tmp/com.microsoft.outlook.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | End of Outlook 365/2019 Standalone Installer install
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | Looking for download URL for com.microsoft.onenote.standalone.365
Tue 16 Feb 2021 21:20:57 GMT | Successfully parsed xml file [/tmp/latest.xml] for [com.microsoft.onenote.standalone.365] -> [https://go.microsoft.com/fwlink/?linkid=820886]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | [5 / 8] Starting install of OneNote Free Standalone Updater
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | AppName = OneNote Free Standalone Updater
Tue 16 Feb 2021 21:20:57 GMT | AppUrl = https://go.microsoft.com/fwlink/?linkid=820886
Tue 16 Feb 2021 21:20:57 GMT | MinOSVer = 10.14
Tue 16 Feb 2021 21:20:57 GMT | Local Temp file = /tmp/com.microsoft.onenote.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Attempting to download [https://go.microsoft.com/fwlink/?linkid=820886] to /tmp/com.microsoft.onenote.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully downloaded from [https://go.microsoft.com/fwlink/?linkid=820886] to [/tmp/com.microsoft.onenote.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Attempting to install [OneNote Free Standalone Updater] from /tmp/com.microsoft.onenote.standalone.365.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully installed [OneNote Free Standalone Updater] from [/tmp/com.microsoft.onenote.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Cleaning up tmp file [/tmp/com.microsoft.onenote.standalone.365.pkg]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | End of OneNote Free Standalone Updater install
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | Looking for download URL for com.microsoft.onedrive.standalone
Tue 16 Feb 2021 21:20:57 GMT | Successfully parsed xml file [/tmp/latest.xml] for [com.microsoft.onedrive.standalone] -> [https://go.microsoft.com/fwlink/?linkid=823060]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | [6 / 8] Starting install of OneDrive Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | AppName = OneDrive Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT | AppUrl = https://go.microsoft.com/fwlink/?linkid=823060
Tue 16 Feb 2021 21:20:57 GMT | MinOSVer = 10.12
Tue 16 Feb 2021 21:20:57 GMT | Local Temp file = /tmp/com.microsoft.onedrive.standalone.pkg
Tue 16 Feb 2021 21:20:57 GMT | Attempting to download [https://go.microsoft.com/fwlink/?linkid=823060] to /tmp/com.microsoft.onedrive.standalone.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully downloaded from [https://go.microsoft.com/fwlink/?linkid=823060] to [/tmp/com.microsoft.onedrive.standalone.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Attempting to install [OneDrive Standalone Installer] from /tmp/com.microsoft.onedrive.standalone.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully installed [OneDrive Standalone Installer] from [/tmp/com.microsoft.onedrive.standalone.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Cleaning up tmp file [/tmp/com.microsoft.onedrive.standalone.pkg]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | End of OneDrive Standalone Installer install
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | Looking for download URL for com.microsoft.skypeforbusiness.standalone
Tue 16 Feb 2021 21:20:57 GMT | Successfully parsed xml file [/tmp/latest.xml] for [com.microsoft.skypeforbusiness.standalone] -> [https://go.microsoft.com/fwlink/?linkid=832978]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | [7 / 8] Starting install of Skype for Business Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | AppName = Skype for Business Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT | AppUrl = https://go.microsoft.com/fwlink/?linkid=832978
Tue 16 Feb 2021 21:20:57 GMT | MinOSVer = 10.11
Tue 16 Feb 2021 21:20:57 GMT | Local Temp file = /tmp/com.microsoft.skypeforbusiness.standalone.pkg
Tue 16 Feb 2021 21:20:57 GMT | Attempting to download [https://go.microsoft.com/fwlink/?linkid=832978] to /tmp/com.microsoft.skypeforbusiness.standalone.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully downloaded from [https://go.microsoft.com/fwlink/?linkid=832978] to [/tmp/com.microsoft.skypeforbusiness.standalone.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Attempting to install [Skype for Business Standalone Installer] from /tmp/com.microsoft.skypeforbusiness.standalone.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully installed [Skype for Business Standalone Installer] from [/tmp/com.microsoft.skypeforbusiness.standalone.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Cleaning up tmp file [/tmp/com.microsoft.skypeforbusiness.standalone.pkg]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | End of Skype for Business Standalone Installer install
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | Looking for download URL for com.microsoft.teams.standalone
Tue 16 Feb 2021 21:20:57 GMT | Successfully parsed xml file [/tmp/latest.xml] for [com.microsoft.teams.standalone] -> [https://go.microsoft.com/fwlink/?linkid=869428]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | [8 / 8] Starting install of Teams Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | AppName = Teams Standalone Installer
Tue 16 Feb 2021 21:20:57 GMT | AppUrl = https://go.microsoft.com/fwlink/?linkid=869428
Tue 16 Feb 2021 21:20:57 GMT | MinOSVer = 10.11
Tue 16 Feb 2021 21:20:57 GMT | Local Temp file = /tmp/com.microsoft.teams.standalone.pkg
Tue 16 Feb 2021 21:20:57 GMT | Attempting to download [https://go.microsoft.com/fwlink/?linkid=869428] to /tmp/com.microsoft.teams.standalone.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully downloaded from [https://go.microsoft.com/fwlink/?linkid=869428] to [/tmp/com.microsoft.teams.standalone.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Attempting to install [Teams Standalone Installer] from /tmp/com.microsoft.teams.standalone.pkg
Tue 16 Feb 2021 21:20:57 GMT | Successfully installed [Teams Standalone Installer] from [/tmp/com.microsoft.teams.standalone.pkg]
Tue 16 Feb 2021 21:20:57 GMT | Cleaning up tmp file [/tmp/com.microsoft.teams.standalone.pkg]
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT ##############################################################
Tue 16 Feb 2021 21:20:57 GMT | End of Teams Standalone Installer install
Tue 16 Feb 2021 21:20:57 GMT ############################################################
Tue 16 Feb 2021 21:20:57 GMT
Tue 16 Feb 2021 21:20:57 GMT | Cleaning up tmp file [/tmp/latest.xml]
```

### Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not Configured
- Number of times to retry if script fails : 3

## uninstallOfficeBusinessPro.sh

This script is designed to remove Office Business Pro for Mac. It is meant for the following scenarios:

- To remove Office on a Mac having problems prior to re-installing
- To clean Office prior to installing a new version

>**Important**
>In it's default state this script will do nothing. You will need to modify the script and uncomment parts before it will remove any data. Be extremely cautious with this script, it is **data destructive**.
>See script comments for further detail.

### Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not Configured
- Number of times to retry if script fails : 3

## fetchOfficeBusinessPro.sh

This script supports installOfficeBusinessPro.sh. It is intended to run on a webserver on your local network that can be used for both the MAU Cache and provide a local copy of the OfficeBusinessPro install files. More information about Deploying a [MAU Caching Server](https://macadmins.software/docs/MAU_CachingServer.pdf).

>Note:
>This script is not needed to deploy Office, it is intended to allow the installation of a specific version of Office and to speed up the initial download and reduce internet load.

>This is NOT designed to be deployed via Intune. Instead you should schedule this to run via a LaunchDaemon or cron task. Zerowidth have a great [launchd plist generator](http://launched.zerowidth.com) to help with this process on macOS.

## Microsoft AutoUpdate PLIST Examples

Not strictly speaking related to the Intune Scripting Agent but included here because they are part of Office deployment on Mac. These two examples are taken from the excellent documentation provided by Paul Bowden [here](https://docs.google.com/spreadsheets/d/1ESX5td0y0OP3jdzZ-C2SItm-TUi-iA_bcHCBvaoCumw/edit#gid=0).

These files are intended to be deployed via the [Microsoft Intune property list](https://docs.microsoft.com/en-us/mem/intune/configuration/preference-file-settings-macos) feature.

>Note:
>The domain for both example plist files is **com.microsoft.autoupdate2**
>Both of the example plists have the UpdateCache option defined. Information about Deploying a [MAU Caching Server](https://macadmins.software/docs/MAU_CachingServer.pdf). Deploying an MAU Cache is extremely useful if you have a large number of Macs running Office. If the MAU client cannot reach the local MAU Cache it will fetch updates from the public servers however if you do not have a local MAU Cache you should remove the key from the plist.
```
<key>UpdateCache</key>
<string>http://192.168.68.150/MAU</string>
```

### com.microsoft.autoupdate2_InsiderFast.plist

- This plist is intended to be deployed to your early adopter users. They will receive the [Office for Mac Insider Fast build](https://support.office.com/article/b3260859-2c1e-4f12-92a4-62a6997efb3a).
- It is recommended to have a static Azure AD group and add users directly for this assignment.

### com.microsoft.autoupdate2_Production.plist

- This plist is intended to be deployed to your production users. They will receive the [Office for Mac Production build](https://docs.microsoft.com/en-us/officeupdates/release-notes-office-for-mac).
- This plist is intended to be deployed to your production users
- It is recommended to exclude the the InsiderFast assignment group from this policy.
