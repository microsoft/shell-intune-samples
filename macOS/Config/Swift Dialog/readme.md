# Deploying an Onboarding Splash Screen with Swift Dialog and Intune

## Overview

swiftDialog is an [open source](https://github.com/bartreardon/swiftDialog) admin utility app for macOS 11+ written in SwiftUI that displays a popup dialog, displaying content to your users.

swiftDialog's purpose is as a tool for Mac Admins to show informative messages via scripts, and relay back the users actions.

Source: [bartreardon/swiftDialog: Create user-notifications on macOS with swiftDialog (github.com)](https://github.com/bartreardon/swiftDialog)

![Example](https://github.com/microsoft/shell-intune-samples/blob/master/img/Swift%20Dialog/example1.png)

## Setup

The deployment process for Intune is driven by the **onboardingProcess.zsh** script, which should be deployed [via Intune](https://learn.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts).

Once executed, the script performs the following tasks.

1. Installs dependencies ([**Rosetta**](https://support.apple.com/en-gb/HT211861) and [**Aria2c**](https://aria2.github.io/)).
  1. Rosetta2 allows x86 apps to run on Apple Silicon CPUs.
  2. Aria2c is a multi-threaded download utility.
2. Downloads and unzips **onboarding\_scripts.zip.**
3. Launches **1-installSwiftDialog.zsh** in the background.
4. Processes **all scripts in scripts** folder in parallel.

## Getting Started

Note, it's strongly recommended to perform these actions on a Mac if possible.

### Step 1 – Preparing your swiftdialog.json file

In the GitHub repo sample, in the **onboarding\_scripts** folder, there is a sample **swiftdialog.json**. This file contains the information required to tell Swift Dialog how to behave and what to show to the end user.

You can find more information about the Swift Dialog configuration at their [wiki](https://github.com/bartreardon/swiftDialog/wiki). This sample uses the [lists](https://github.com/bartreardon/swiftDialog/wiki/Item-Lists) feature.

As a quick start, you should change the following:

1. title
2. message
3. icon
4. listitem

![swiftdialog.json](https://github.com/microsoft/shell-intune-samples/blob/master/img/Swift%20Dialog/examplejson.png)

It's a good idea to have [Swift Dialog](https://github.com/bartreardon/swiftDialog/releases/latest) installed while working on the json file, you can easily test it out by running:

/usr/local/bin/dialog -–jsonfile \<path to test json\> --width 900 –height 500

Notes:

- Make sure you have icons in the icons folder for each list item that you want to use.
- If you need to change the width or height, you'll need to change lines 28 and 29 in the 1-installSwiftDialog.zsh script later.

### Step 2 - Scripts

The onboarding process will run any scripts that you put in the **scripts** folder. The scripts will run in parallel.

![Example](https://github.com/microsoft/shell-intune-samples/blob/master/img/Swift%20Dialog/scripts.png)

You must have a matching script for each **listitem** defined in your **swiftdialog.json** and also make sure that the scripts writes status updates to the right place for Swift Dialog to process.

#### Custom Scripts

If you're using your own scripts, you'll need to ensure that they write status updates to Swift Dialog.

In the sample scripts provided, there is a function called updateSplashScreen() that handles this for you

![updateSplashScreen function](https://github.com/microsoft/shell-intune-samples/blob/master/img/Swift%20Dialog/updateSplashScreenFunction.png)

With this function, you can update script processing with the following commands:

updateSplashScreen \<status\> \<message\>

- status can be **wait** , **success** , **fail** , **error** , **pending** or **progress**
- message can be any text that you want to display
- **$appname** variable must **match the listitem** title in the **swiftdialog.json**

For example, you could use the following command to show that an app was successfully installed:

updateSplashScreen success Installed

Make sure that you test each script inside the scripts folder.

### Step 3 - Deploying

To deploy you need to create an **onboarding\_scripts.zip** file, which should contain everything under the **onboarding\_scripts** folder

![folder structure](https://github.com/microsoft/shell-intune-samples/blob/master/img/Swift%20Dialog/folderstructure.png)

If you're new to Mac, you can create this zip file by right clicking on the onboarding\_scripts folder and select compress 'onboarding\_scripts'.

You'll also need to host the **onboarding\_scripts.zip** file somewhere. In this sample I am using [Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction). If you're new to blob storage, take a look at [this blog](https://techcommunity.microsoft.com/t5/intune-customer-success/deploying-macos-apps-with-the-microsoft-intune-scripting-agent/ba-p/2298072) which has some more details.

Once you have an internet facing URL for the zip file, edit the **onboardingProcess.zsh** file and replace the **onboardingScriptsURL** path with the url that points to your **onboarding\_scripts.zip** file.

![onboardingScriptsURL](https://github.com/microsoft/shell-intune-samples/blob/master/img/Swift%20Dialog/onBoardingScriptsURL.png)

Note: if you're editing on Windows make sure to save the onboardingProcess.zsh as **Unix (LF)** format otherwise the script will not run and will receive a permission denied which may be found in the log file on the Mac under: /Library/Application Support/Microsoft/IntuneScripts/Swift Dialog/

Once done, you can upload and assign the onboardingProcess.zsh script via Intune to macOS devices.