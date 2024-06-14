# Script to add apps to the Mac Dock

This script is an example showing how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to modify the macOS dock. In this instance the script has a list of apps that it waits to be present on the device before clearing the dock and adding the apps defined.

![Desktop Image](https://github.com/microsoft/shell-intune-samples/raw/master/img/dockv2.png)

## Scenario

This scripts intended usage scenario is to be deployed during the initial app enrolment. It will wait until all of the apps are present before configuring the users dock.

>IMPORTANT
>This updated script uses [dockutil](https://github.com/kcrawford/dockutil), without this being installed the script will fail. Download the latest version and deploy via [Intune Unmaged PKG](https://learn.microsoft.com/en-us/mem/intune/apps/macos-unmanaged-pkg).
>This updated script no longer runs as the end user, you need to ensure that you deploy it to **run as root**.

The script searches for Apps listed in the DockItems array and once they are all present it adds them to the Dock in the order they appear in the list. Edit the list as appropriate for your use.

Add Applications to the Dock
```
dockapps=( "/Applications/Microsoft Edge.app"
            "/Applications/Microsoft Outlook.app"
            "/Applications/Microsoft Word.app"
            "/Applications/Microsoft Excel.app"
            "/Applications/Microsoft PowerPoint.app"
            "/Applications/Microsoft OneNote.app"
            "/Applications/Microsoft Teams.app"
            "/Applications/Visual Studio Code.app"
            "/Applications/Company Portal.app"
            "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app"
            "/System/Applications/App Store.app"
            "/System/Applications/Utilities/Terminal.app"
            "/System/Applications/System Preferences.app")
```


## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3
