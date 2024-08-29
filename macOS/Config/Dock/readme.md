# Script to add apps to the Mac Dock

This script is an example showing how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) and [Unmanaged PKG](https://learn.microsoft.com/en-us/mem/intune/apps/macos-unmanaged-pkg)to modify the macOS dock.

# Script Usage Guide

This script is designed to wait for specific applications to be installed on a Mac before configuring the Mac Dock with those applications. The script includes options to use either `dockutil` or direct manipulation of the Dock's plist file for configuring the Dock. Below is a detailed guide on how to use the script and explanations of the available options.

## Prerequisites

- **Shell Environment**: The script should be run in a Bash shell on a macOS system.
- **User Permissions**: The script needs to be executed with root privileges.

## Configuration Option Variables in the Script

### `useDockUtil`

- **Type**: Boolean (`true` or `false`)
- **Default**: `false`
- **Description**: 
  - When set to `true`, the script will use `dockutil` to configure the Dock. `dockutil` is a utility that simplifies the process of managing Dock items.
  - When set to `false`, the script will directly manipulate the Dock's plist file to configure the Dock.

### `waitForApps`

- **Type**: Boolean (`true` or `false`)
- **Default**: `false`
- **Description**: 
  - When set to `true`, the script will wait for all specified applications to be installed before configuring the Dock. This is useful in environments where apps might be installed asynchronously (e.g., via an MDM solution).
  - When set to `false`, the script will proceed with Dock configuration without waiting for the apps to be installed. Any missing apps will just be skipped and not added to the Dock.

### `dockapps` Array

- **Description**:
  - The `dockapps` array contains a list of application paths that are intended to be added to the Dock. Each path corresponds to a specific application installed on the Mac.
  - The script will iterate over this list and check whether each application is installed on the system. Depending on the configuration, the script will either wait for all these applications to be installed (`waitForApps` is `true`) or proceed immediately to configure the Dock.
  - If `useDockUtil` is `true`, these applications are added to the Dock using `dockutil`. If `useDockUtil` is `false`, the applications are added by directly modifying the Dock's plist file.

```
dockapps=(  "/System/Applications/Launchpad.app"
            "/Applications/Microsoft Edge.app"
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
            "/System/Applications/$settingsApp")
```

## What the Script Does

This script modifies the Mac Dock by adding a predefined list of applications, as specified in the `dockapps` array. It can either use `dockutil` to manage the Dock items or directly edit the Dock's plist file. The script first waits for the Dock process to be running to ensure that it is modifying the Dock for the currently logged-in user. After that, depending on the configuration options, the script either waits for the applications to be installed or proceeds immediately to Dock configuration. The applications are added to the Dock in the order specified in the `dockapps` array, and any existing items can be removed depending on the configuration.

## Usage

1. **Set the Options**: Before running the script, adjust the `useDockUtil` and `waitForApps` variables according to your needs. These are located near the top of the script.

   ```bash
   useDockUtil=true
   waitForApps=true

## Deployment as Self Service via Company Portal

If you don't want to configure the Dock initially, you can make it available via Company Portal. To do this we need to make use of [Intune Unmanaged PKG](https://learn.microsoft.com/en-us/mem/intune/apps/macos-unmanaged-pkg) and [Intune PKG Post Install Script](https://learn.microsoft.com/en-us/mem/intune/apps/macos-unmanaged-pkg#step-2--program).

1. **Upload dock.pkg to Intune**: This is a totally empty PKG that creates a receipt name of com.intune.dock. Documentation to do this is at [Intune Unmanaged PKG](https://learn.microsoft.com/en-us/mem/intune/apps/macos-unmanaged-pkg). When you assign the package, ensure that you do it as **available**.
2. **Paste dock5.sh contents as Post Install Script**: For this flow, ensure that **waitForApps** is set to false.

https://github.com/user-attachments/assets/c565611d-a798-4b64-847f-04f69955b04d

## Deployment as required script

If you do want to configure the Dock automatically, you can deploy `dock5.sh` via a required shell script. Deploying via [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) allows you to assign the script to specific users or groups. 

1. **Upload dock5.sh to Intune**: Follow the instructions for [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts). For this scenario, you should probably ensure that **waitForApps** is set to true so that the script waits for app installation to complete.
