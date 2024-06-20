# Deploying an Onboarding Splash Screen with swiftDialog and Intune via custom PKG

## Overview

swiftDialog is an [open source](https://github.com/bartreardon/swiftDialog) admin utility app for macOS 11+ written in SwiftUI that displays a popup dialog, displaying content to your users.

swiftDialog's purpose is as a tool for Mac Admins to show informative messages via scripts, and relay back the users actions.

Source: [bartreardon/swiftDialog: Create user-notifications on macOS with swiftDialog (github.com)](https://github.com/bartreardon/swiftDialog)

![Example](https://github.com/microsoft/shell-intune-samples/blob/master/img/Swift%20Dialog%20PKG/SwiftDialogPKG%20-%20Example1.png)

## Dependencies

In this example, we're going to use the Packages App to create a custom PKG that includes all of the resources we need for an oboarding package.

1. Install [Packages App](http://s.sudre.free.fr/Software/files/Packages.dmg) and grant it full disk access
2. Download and expand [SwiftDialog_IntunePKG.zip](https://github.com/microsoft/shell-intune-samples/raw/master/macOS/Config/Swift%20Dialog%20(PKG)/SwiftDialog_IntunePKG.zip) from this repo.

The ZIP file contains the following resources.

```
|____Swift Dialog Onboarding
| |____Swift Dialog Onboarding.pkgproj      <-- This is the Packages project
|____Payload
| |____Application Support
| | |____Dialog
| | | |____Dialog.app
| | |____SwiftDialogResources
| | | |____swiftdialog.json                 <-- This is the SwiftDialog JSON
| | | |____icons
| | | | |____RemoteDesktop.png
| | | | |____CompanyPortal.png
| | | | |____Settings.png
| | | | |____Edge.png
| | | | |____vscode.png
| | | | |____MicrosoftRemoteHelp.png
| | | | |____office.png
| | | | |____catlab.png
| | | | |____GoogleChrome.png
| | | | |____Defender.png
| | | |____scripts                          <-- Any scripts in this folder will be executed by the post script
| | | | |____01-installCompanyPortal.zsh
| | | | |____02-installOffice365Pro.sh
| | | | |____03-installEdge.sh
| | | | |____04-installVSCode.zsh
| | | | |____05-installRemoteDesktop.zsh
| | | | |____06-installDefender.zsh
| | | | |____99-setTZfromIP.sh
| | | | |____99-DeviceRename.sh
| | | | |____99-downloadWallpaper.sh
| |____usr
| | |____local
| | | |____bin
| | | | |____dialog
```

# Getting Started

First we need to check that everything is working as it should, to do this, open the Swift Dialog Onboarding folder and double click on the Swift Dialog Onboarding Packages project. It should open in the Packages app.

Click on the Swift Dialog Package and select the Payload tab, check that none of the files are showing in red and there are no errors. Then press CMD+B to build our package. The most common reason for errors are files missing that are defined in the project and/or lack of permissions for the Packages app.

If succesful you will now have a package created under the Swift Dialog Onboarding/Build folder.

Your next step is to test that the package works by installing on a test machine and then you can run the following command.

```
/usr/local/bin/dialog --jsonfile "/Library/Application Support/SwiftDialogResources/swiftdialog.json" --width 1280 --height 670 --blurscreen --ontop
```

You should see the Swift Dialog UI displayed, but no scripts should execute. All Icons should display the right images.

# Customising

There are three areas to consider when customising the package

1. **swiftdialog.json**: This file contains the information that Dialog will use to create the display. Not everything needs to be included here, you can also specify most things on the command line if you need to. Refer to the excellent [SwiftDialog Wiki](https://github.com/swiftDialog/swiftDialog/wiki) for more information about customising this file.
2. **Icons**: It's important that any icons you reference are available, they can either be included in the package or you can define web URLs.
3. **Scripts**: Any scripts that you put in the scripts folder will be executed in alphanumeric order. Some samples are provided here, but remove what you don't need they are provide to show whats possible.

# Deploying via Intune

Once you have your customised PKG ready, you should test it first and then we can upload to Intune for deployment.

You can find out more detail about the unmanaged PKG deployment process in our [public documentation](https://learn.microsoft.com/en-us/mem/intune/apps/macos-unmanaged-pkg).

Follow these steps from the Intune console:

1. **Apps** > **macOS** > **Add** > **macOS app (PKG)** > **Select** > Select app package file > **OK**
2. Edit App Information as required > **Next**
3. Copy and paste Pre and Post install text from **IntuneScripts** folder (intunePre.sh / intunePost.sh) > **Next**
4. Define minimum operating system version if you need to > **Next**
5. Accept default detection rules > **Next**
6. Assign to initial test group of users > **Next**
7. **Create**
8. Make a note of the appid, it's in the Intune Web URL after appid. We'll need this as we move into testing. https://intune.microsoft.com/#view/Microsoft_Intune_Apps/SettingsMenu/~/0/appId/0b6e87b5-2e4b-4350-b551-bfb99d114c83


# Testing

Now we have everything uploaded to Intune, we need to test it. The quickest way to do that is to trigger the Intune Agent to re-check for updates.

Since this is the first time, it's a good idea to open the logs so that we can see what's going on

1. Open the Mac Console app > Log Reports > search for Intune > Select the latest IntuneMDMDaemon log
2. Double click on the log file and type the appid from above into the search box (it shouldn't return anything yet)

Ok, so we can trigger the Intune agent to check-in and pick up our new PKG

```
sudo pkill IntuneMdmDaemon
```

If things go as expected, you should see the SwiftDialog UI appear and the scripts should start executing.

You should see something like this in your IntuneDaemon log

```
2024-05-15 02:15:12:703 | IntuneMDM-Daemon | I | 11254 | SyncActivityTracer | Validating data Context: mac app policies, Count: 2, PolicyID: ["05088685-1fe8-4107-aaec-a41d4f934a14", "0b6e87b5-2e4b-4350-b551-bfb99d114c83"]
2024-05-15 02:15:12:703 | IntuneMDM-Daemon | I | 11254 | SyncActivityTracer | Processing data Context: mac app policies, Count: 2, PolicyID: ["05088685-1fe8-4107-aaec-a41d4f934a14", "0b6e87b5-2e4b-4350-b551-bfb99d114c83"]
2024-05-15 02:15:12:704 | IntuneMDM-Daemon | I | 11255 | AppPolicyHandler | Handling app policy. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, Primary BundleID: au.csiro.dialog, IgnoreVersion: true, Count: 1, AppType: PKG, App Policy Intent: RequiredInstall
2024-05-15 02:15:12:704 | IntuneMDM-Daemon | I | 11255 | AppDetection | Detecting app with specific bundle ID. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, BundleID: au.csiro.dialog, IgnoreVersion: true
2024-05-15 02:15:12:704 | IntuneMDM-Daemon | I | 11255 | ScriptOrchestrationLogger | Running system script. Domain: apps, User: root, PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 02:15:12:735 | IntuneMDM-Daemon | I | 11255 | ScriptOrchestrationLogger | Finished system script. Domain: apps, User: root, PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 02:15:12:735 | IntuneMDM-Daemon | I | 11255 | AppDetection | Did not find bundle path URL for app. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, BundleID: au.csiro.dialog, IgnoreVersion: true
2024-05-15 02:15:12:735 | IntuneMDM-Daemon | I | 11255 | ScriptOrchestrationLogger | Running system script. Domain: apps, User: root, PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 02:15:12:749 | IntuneMDM-Daemon | I | 11255 | ScriptOrchestrationLogger | Finished system script. Domain: apps, User: root, PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 02:15:12:749 | IntuneMDM-Daemon | I | 11255 | PkgReceiptProvider | No app receipt found PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, BundleID: au.csiro.dialog
2024-05-15 02:15:12:749 | IntuneMDM-Daemon | I | 11255 | AppDetection | App with specific bundle ID is NOT installed on the device. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, BundleID: au.csiro.dialog, IgnoreVersion: true
2024-05-15 02:15:12:749 | IntuneMDM-Daemon | I | 11255 | AppInstallManager | App policy execution plan: Run pre-install script, Install PKG app Swift Dialog Onboarding, Run post-install script PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, AppType: PKG, BundleID: au.csiro.dialog
2024-05-15 02:15:12:749 | IntuneMDM-Daemon | I | 11255 | AppInstallManager | Pre-install script detected. Executing script. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 02:15:12:749 | IntuneMDM-Daemon | I | 11255 | ScriptOrchestrationLogger | Running management script. Domain: policy, User: root, PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 02:15:12:759 | IntuneMDM-Daemon | I | 11255 | ScriptOrchestrationLogger | Finished management script. Domain: policy, User: root, PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 02:15:12:759 | IntuneMDM-Daemon | I | 11255 | AppInstallManager | Pre-install script succeeded PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 02:15:12:759 | IntuneMDM-Daemon | I | 11255 | AppInstallManager | Starting app installation for mac app policy. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, AppType: PKG, BundleID: au.csiro.dialog
2024-05-15 02:15:12:759 | IntuneMDM-Daemon | I | 11255 | AppBinaryDownloader | Start app content info metadata download PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, BundleID: au.csiro.dialog
2024-05-15 02:15:12:759 | IntuneMDM-Daemon | I | 11255 | SidecarService | Getting mac app content info from GW PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding
2024-05-15 02:15:13:230 | IntuneMDM-Daemon | I | 11258 | AppBinaryDownloader | Successfully fetched app content info response from GW. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, BundleID: au.csiro.dialog
2024-05-15 02:15:13:230 | IntuneMDM-Daemon | I | 11258 | AppBinaryDownloader | Starting app binary download for mac app policy. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, Size: 11132265.0
2024-05-15 02:15:13:246 | IntuneMDM-Daemon | I | 11258 | AppBinaryDownloader | Attempt #1 out of 3 to download app binary PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, BundleID: au.csiro.dialog
2024-05-15 02:15:15:147 | IntuneMDM-Daemon | I | 11248 | AppBinaryDownloader | Successfully downloaded app binary content. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, BundleID: au.csiro.dialog
2024-05-15 02:15:15:147 | IntuneMDM-Daemon | I | 11248 | AppInstallManager | Starting app binary decryption for mac app policy. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, AppType: PKG, BundleID: au.csiro.dialog
2024-05-15 02:15:15:200 | IntuneMDM-Daemon | I | 11248 | AppInstallManager | Install required for app PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, AppType: PKG, BundleID: au.csiro.dialog
2024-05-15 02:15:15:200 | IntuneMDM-Daemon | I | 11248 | PkgInstaller | Starting PKG app installation PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, BundleID: au.csiro.dialog, AppName: Swift Dialog Onboarding
2024-05-15 02:15:15:200 | IntuneMDM-Daemon | I | 11248 | ScriptOrchestrationLogger | Running system script. Domain: apps, User: root, PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 02:15:17:541 | IntuneMDM-Daemon | I | 11248 | ScriptOrchestrationLogger | Finished system script. Domain: apps, User: root, PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 02:15:17:541 | IntuneMDM-Daemon | I | 11248 | PkgInstaller | Successful PKG installation - installer completed with success status PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, BundleID: au.csiro.dialog, AppName: Swift Dialog Onboarding
2024-05-15 02:15:17:542 | IntuneMDM-Daemon | I | 11248 | AppInstallManager | Post-install script detected. Executing script. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 02:15:17:542 | IntuneMDM-Daemon | I | 11248 | ScriptOrchestrationLogger | Running management script. Domain: policy, User: root, PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 02:15:17:549 | IntuneMDM-Daemon | I | 11250 | AppInstallManager | App policy file cleanup successful. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding
2024-05-15 02:15:17:549 | IntuneMDM-Daemon | I | 11257 | AppInstallManager | App policy file cleanup successful. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding
2024-05-15 10:25:49:533 | IntuneMDM-Daemon | I | 11248 | ScriptOrchestrationLogger | Finished management script. Domain: policy, User: root, PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 10:25:49:534 | IntuneMDM-Daemon | I | 11248 | AppInstallManager | Post-install script succeeded. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 10:25:49:534 | IntuneMDM-Daemon | I | 11248 | AppInstallManager | Successfully installed all apps PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, AppName: Swift Dialog Onboarding, ComplianceState: Installed, EnforcementState: Success, Product Version (BundleID of primary app): 2.3.2, Primary BundleID: au.csiro.dialog
2024-05-15 10:25:49:534 | IntuneMDM-Daemon | I | 11248 | AppPolicyHandler | Handling app policy finished. PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, Primary BundleID: au.csiro.dialog, IgnoreVersion: true, Count: 1, AppType: PKG, App Policy Intent: RequiredInstall
2024-05-15 10:25:49:534 | IntuneMDM-Daemon | I | 11248 | ExecutionClock | Measurement: Policy Identifier: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, Type: macAppInstall, Duration: 636.8304209709167
2024-05-15 10:25:49:537 | IntuneMDM-Daemon | I | 31568 | AppResultStateChangeManager | This policy has never been executed on this device before the current check-in PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 10:25:49:539 | IntuneMDM-Daemon | I | 31568 | AppResultStateChangeManager | Successfully cached new app policy state change record PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83, PolicyResult: ["ResultCreatedTimeUTC": 2024-05-15T09:15:17Z, "Intent": 3, "EnforcementStateMessage": {
}, "PolicyId": 0b6e87b5-2e4b-4350-b551-bfb99d114c83, "ApplicationName": Swift Dialog Onboarding]
2024-05-15 10:25:49:539 | IntuneMDM-Daemon | I | 31568 | AppStateChangePersistence | Fetch app policy state change records PolicyID: [Optional("05088685-1fe8-4107-aaec-a41d4f934a14"), Optional("0b6e87b5-2e4b-4350-b551-bfb99d114c83")]
2024-05-15 10:25:49:539 | IntuneMDM-Daemon | I | 31568 | AppPolicyResultsReporter | Create state change report for app policies PolicyType: macAppInstall, Count: 1, PolicyID: 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 10:25:49:539 | IntuneMDM-Daemon | I | 31568 | AppPolicyResultsReporter | Number of app policies executed PolicyType: macAppInstall, Count: 2, PolicyID: 05088685-1fe8-4107-aaec-a41d4f934a14, 0b6e87b5-2e4b-4350-b551-bfb99d114c83
2024-05-15 10:25:49:539 | IntuneMDM-Daemon | I | 31568 | SyncActivityTracer | Reporting results Context: mac app policies, Count: 1, PolicyID: ["0b6e87b5-2e4b-4350-b551-bfb99d114c83"]
```
