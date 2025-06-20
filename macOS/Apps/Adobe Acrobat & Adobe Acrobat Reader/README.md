# Adobe Acrobat & Adobe Acrobat Reader

In this folder we provide you few following script examples of Adobe Acrobat & Adobe Acrobat Reader:

| Type | File | Notes |
| -------- | ------- | ------- |
| Installation script | ```installAcrobatDC.sh```<br> or <br> ```installAcrobatDC.zsh```    | <ul><li>Installation script is provided either sh (Bourne Shell) script or zsh (Z Shell) script.<li> Check more information [here](#installation-script).</li></ul> |
| Uninstallation script | ```UninstallAdobeAcrobat.zsh```    | <ul><li> Suitable for separate uninstallation deployment via [script](https://learn.microsoft.com/en-us/intune/intune-service/apps/macos-shell-scripts) or as [pre-installation script](https://learn.microsoft.com/en-us/intune/intune-service/apps/macos-unmanaged-pkg) when installing company deployed Adobe Acrobat as PKG-package.<li>Check more information [here](#uninstallation-script).</li></ul> |

## Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download the Adobe Acrobat DC DMG file from the Adobe download servers and then install it onto the Mac.

### Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Number of times to retry if script fails : 3

### Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/Adobe Acrobat Reader DC/Adobe Acrobat Reader DC.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
Wed  5 Jan 2022 17:26:50 GMT | Creating [/Library/Logs/Microsoft/IntuneScripts/Adobe Acrobat Reader DC] to store logs

##############################################################
# Wed  5 Jan 2022 17:26:50 GMT | Logging install of [Adobe Acrobat Reader DC] to [/Library/Logs/Microsoft/IntuneScripts/Adobe Acrobat Reader DC/Adobe Acrobat Reader DC.log]
############################################################

Wed  5 Jan 2022 17:26:50 GMT | Checking if we need Rosetta 2 or not
Wed  5 Jan 2022 17:26:50 GMT | Waiting for other [/usr/sbin/softwareupdate] processes to end
Wed  5 Jan 2022 17:26:50 GMT | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Wed  5 Jan 2022 17:26:50 GMT | Intel processor installed. No need to install Rosetta.
Wed  5 Jan 2022 17:26:50 GMT | Checking if we need to install or update [Adobe Acrobat Reader DC]
Wed  5 Jan 2022 17:26:50 GMT | [Adobe Acrobat Reader DC] not installed, need to download and install
Wed  5 Jan 2022 17:26:50 GMT | Dock is here, lets carry on
Wed  5 Jan 2022 17:26:50 GMT | Starting downlading of [Adobe Acrobat Reader DC]
Wed  5 Jan 2022 17:26:50 GMT | Waiting for other [curl -f] processes to end
Wed  5 Jan 2022 17:26:50 GMT | No instances of [curl -f] found, safe to proceed
Wed  5 Jan 2022 17:26:50 GMT | Downloading Adobe Acrobat Reader DC [http://ardownload.adobe.com/pub/adobe/reader/mac/AcrobatDC/2100120155/AcroRdrDC_2100120155_MUI.dmg]
Wed  5 Jan 2022 17:27:42 GMT | Found DMG, looking inside...
Wed  5 Jan 2022 17:27:42 GMT | Mounting Image [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.nwDgUjxG/Adobe Acrobat Reader DC] [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.nwDgUjxG/AcroRdrDC_2100120155_MUI.dmg]
Wed  5 Jan 2022 17:27:44 GMT | Mounted succesfully to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.nwDgUjxG/Adobe Acrobat Reader DC]
Wed  5 Jan 2022 17:27:44 GMT | Detected PKG, setting PackageType to DMGPKG
Wed  5 Jan 2022 17:27:44 GMT | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.nwDgUjxG/Adobe Acrobat Reader DC]
Wed  5 Jan 2022 17:27:46 GMT | Downloaded [Adobe Acrobat Reader DC.app] to [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.nwDgUjxG/AcroRdrDC_2100120155_MUI.dmg]
Wed  5 Jan 2022 17:27:46 GMT | Detected install type as [DMGPKG]
Wed  5 Jan 2022 17:27:46 GMT | Waiting for other [/Applications/Adobe Acrobat Reader DC.app/Contents/MacOS/AdobeReader] processes to end
Wed  5 Jan 2022 17:27:46 GMT | No instances of [/Applications/Adobe Acrobat Reader DC.app/Contents/MacOS/AdobeReader] found, safe to proceed
Wed  5 Jan 2022 17:27:46 GMT | Installing [Adobe Acrobat Reader DC]
Wed  5 Jan 2022 17:27:46 GMT | Mounting Image
Wed  5 Jan 2022 17:27:46 GMT | Starting installer for [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.nwDgUjxG/Adobe Acrobat Reader DC/AcroRdrDC_2100120155_MUI.pkg]
installer: Package name is Adobe Acrobat Reader DC (Continuous)
installer: Installing at base path /
installer: The install was successful.
Wed  5 Jan 2022 17:28:33 GMT | Un-mounting [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.nwDgUjxG/Adobe Acrobat Reader DC]
Wed  5 Jan 2022 17:28:33 GMT | [Adobe Acrobat Reader DC] Installed
Wed  5 Jan 2022 17:28:33 GMT | Cleaning Up
Wed  5 Jan 2022 17:28:33 GMT | Fixing up permissions
Wed  5 Jan 2022 17:28:34 GMT | Application [Adobe Acrobat Reader DC] succesfully installed
Wed  5 Jan 2022 17:28:34 GMT | Writing last modifieddate [Mon, 10 May 2021 07:25:20 GMT] to [/Library/Logs/Microsoft/IntuneScripts/Adobe Acrobat Reader DC/Adobe Acrobat Reader DC.meta]
```
## Uninstallation Script

> [!NOTE]  
> This uninstallation script is suitable for separate uninstallation deployment via [script](https://learn.microsoft.com/en-us/intune/intune-service/apps/macos-shell-scripts) or as [pre-installation script](https://learn.microsoft.com/en-us/intune/intune-service/apps/macos-unmanaged-pkg) when installing company deployed Adobe Acrobat as PKG-package.

This uninstallation script uninstalls following Adobe Acrobat versions from the Mac-device if one of these versions are installed:

- Adobe Acrobat Reader 2020.
- Adobe Acrobat 2020.
- Adobe Acrobat Classic / Adobe Acrobat Reader Classic.
- Adobe Acrobat DC / Adobe Acrobat Reader DC.

### Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Number of times to retry if script fails : 3

### Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/UninstallAdobeAcrobatAndAdobeAcrobatReader/UninstallAdobeAcrobatAndAdobeAcrobatReader.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)
```
Fri Jun 20 19:15:10 EEST 2025 | Creating log directory - /Library/Logs/Microsoft/IntuneScripts/UninstallAdobeAcrobatAndAdobeAcrobatReader

##############################################################
# Fri Jun 20 19:15:10 EEST 2025 | Starting running of script UninstallAdobeAcrobatAndAdobeAcrobatReader
############################################################

Fri Jun 20 19:15:10 EEST 2025 | Adobe Acrobat Reader 2020 is not installed. Let's proceed...
Fri Jun 20 19:15:10 EEST 2025 | Adobe Acrobat / Adobe Acrobat Reader 2020 is not installed. Let's proceed...
Fri Jun 20 19:15:10 EEST 2025 | Adobe Acrobat / Adobe Acrobat Reader Classic is not installed. Let's proceed...
Fri Jun 20 19:15:10 EEST 2025 | Adobe Acrobat / Adobe Acrobat Reader DC is installed. Making sure, that application is closed...
Fri Jun 20 19:15:21 EEST 2025 | Done. Uninstalling Adobe Acrobat / Adobe Acrobat Reader DC...
Fri Jun 20 19:15:53 EEST 2025 | Adobe Acrobat / Adobe Acrobat Reader DC successfully uninstalled. You can now install it back if needed. Closing script...

```