# Script to add apps to the Mac Dock

This script is an example showing how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to modify the macOS dock. In this instance the script has a list of apps that it waits to be present on the device before clearing the dock and adding the apps defined.

![Desktop Image](https://github.com/microsoft/shell-intune-samples/raw/master/img/desktop.png)

## Scenario

This scripts intended usage scenario is to be deployed during the initial app enrolment. It will wait until all of the apps are present before configuring the users dock.

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

Add Network Shares to the Dock ()
```
netshares=(   "smb://192.168.0.12/Data"
              "smb://192.168.0.12/Home"
              "smb://192.168.0.12/Tools")
```

## Script Settings

- Run script as signed-in user : Yes
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3
