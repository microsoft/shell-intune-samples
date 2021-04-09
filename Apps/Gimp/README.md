# Installing Gimp

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install DMG applications via [Azure Blob Storage](https:/docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction). In this example the script will download the Gimp dmg file from the Azure servers and then install it onto the Mac. To reduce unnecessary re-downloads, the script monitors the date-modified attrbiute on the HTTP header rather than checking if the file stored there is actually changed.

The public site for the GNU Image Manipulation Program (GIMP) is [here](https://www.gimp.org/).

## Scenarios
The script can be used for two scenarios:

 - Install - The script can be used to install the GNU Image Manipulation Program
 - Update - The script can run once or scheduled to update the installed version of the GNU Image Manipulation Program. You can schedule the script to check for updates.

## Description

The script performs the following actions if the **GNU Image Manipulation Program** is not already installed:
1. Downloads the DMG from Azure blob storage.
2. Mounts the DMG file at **/tmp/GIMP**.
3. Copies (installs) the application to the **/Applications** directory.
4. Unmounts the DMG file.
5. Deletes the DMG file.
6. Records the date-modified attribute of so it can be checked at future script executions.

If **GNU Image Manipulation Program** is already installed, it will compare the date-modified against the recorded version. 
 - If the date-modified is newer, it will download and install the new version.
 - If no date-modified was previously recorded, it will download and attempt to install.

## Script Variables

The script has the following variables, which are useful if modifying the script to work with another DMG installation

**tempfile** is the temporary location of the installation files. The path doesn't really matter as long as we can write to it and remove it at the end of the script
```
tempfile="/tmp/gimp.dmg"
```

**volume** is the path we will use to mount the DMG file. For a DMG file we need to mount it as a volume before we can access the files on it. The actual path used here isn't important as long as it's not likely to be used by another process during the installation.
```
volume="/tmp/GIMP"
```

**weburl** is the http url of the installation files that we need. In this example we are using Azure Blob storage to host the file but it could be any http endpoint that will be accessible from the client.
```
weburl="https://numberwang.blob.core.windows.net/numberwang/gimp.dmg"
```

**appname** is mostly used in the status logging, but is also used to generate the metadata file path for storing the last updated date
```
appname="Gimp"
```

**app** is the actual name of the Application. It is used by the script to check if the app is already installed. The script will copy the application files found on the DMG to /Applications/$app. The best way to handle this is to install the application manually on your Mac and then run ls -la /Applications from a terminal prompt amd use the same name.
```
app="Gimp.app"
```

**logandmetadir** this is the directory that the script will use to generate the installation log and also to store the metadata for the last version update. This should be unique for each application that you deploy.
```
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/installGimp"
```

**processpath** this is used to check if the application is running or not. Mac applications have a fairly strict directory format, so one of the quickest methods is to run `ls -Fl /Applications/Gimp.app/Contents/MacOS/*`. This will return a list of files, it's usually pretty easy to guess which one is the main application by the name, in our case **/Applications/Gimp.app/Contents/MacOS/gimp**.

For example, in our case the Gimp directory structure looks like this

```
Neils-MacBook-Pro:~ neiljohnson$ ls -Fl /Applications/Gimp.app/Contents/MacOS/*
-rwxr-xr-x  1 root  wheel    56064 24 Mar 12:13 /Applications/Gimp.app/Contents/MacOS/gegl*
-rwxr-xr-x  1 root  wheel  9452768 24 Mar 12:13 /Applications/Gimp.app/Contents/MacOS/gimp*
lrwxr-xr-x  1 root  wheel       17 24 Mar 12:13 /Applications/Gimp.app/Contents/MacOS/gimp-console@ -> gimp-console-2.10
-rwxr-xr-x  1 root  wheel  3625376 24 Mar 12:13 /Applications/Gimp.app/Contents/MacOS/gimp-console-2.10*
lrwxr-xr-x  1 root  wheel       19 24 Mar 12:13 /Applications/Gimp.app/Contents/MacOS/gimp-debug-tool@ -> gimp-debug-tool-2.0
-rwxr-xr-x  1 root  wheel    78800 24 Mar 12:13 /Applications/Gimp.app/Contents/MacOS/gimp-debug-tool-2.0*
-rwxr-xr-x  1 root  wheel    58720 24 Mar 12:13 /Applications/Gimp.app/Contents/MacOS/gimptool-2.0*
-rwxr-xr-x  1 root  wheel    32352 24 Mar 12:13 /Applications/Gimp.app/Contents/MacOS/python*
lrwxr-xr-x  1 root  wheel        6 24 Mar 12:13 /Applications/Gimp.app/Contents/MacOS/python2@ -> python
-rwxr-xr-x@ 1 root  wheel     1816 24 Mar 12:13 /Applications/Gimp.app/Contents/MacOS/xdg-email*
```
```
processpath="/Applications/Gimp.app/Contents/MacOS/gimp"
```


**terminateprocess** is used to control what the script does if it finds the application is running. If this value is set to false the script will check for the applications process and wait for it to be closed before installing. If the value is set to true the script will detect that the application is running and terminate the main process before installing. For most end user applications leave this set to false.
```
terminateprocess="false"
```


## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : 
  - **Not configured** to run once
  - **Every 1 week** to check for and install updates once a week
- Number of times to retry if script fails : 3

## Log File

The log file will output to **//Library/Logs/Microsoft/IntuneScripts/installGimp/Gimp.log** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection).
```
Tue  6 Apr 2021 17:15:40 BST | Creating [/Library/Logs/Microsoft/IntuneScripts/installGimp] to store logs

##############################################################
# Tue  6 Apr 2021 17:15:40 BST | Logging install of [Gimp] to [/Library/Logs/Microsoft/IntuneScripts/installGimp/Gimp.log]
############################################################

Tue  6 Apr 2021 17:15:40 BST | Checking if we need Rosetta 2 or not
Tue  6 Apr 2021 17:15:40 BST | [Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz] found, Rosetta not needed
Tue  6 Apr 2021 17:15:40 BST | Checking if we need to install or update [Gimp]
Tue  6 Apr 2021 17:15:40 BST | [Gimp] not installed, need to download and install
Tue  6 Apr 2021 17:15:40 BST | Starting downlading of [Gimp]
Tue  6 Apr 2021 17:15:40 BST | Waiting for other Curl processes to end
Tue  6 Apr 2021 17:15:40 BST | No instances of Curl found, safe to proceed
Tue  6 Apr 2021 17:15:40 BST | Downloading Gimp
Tue  6 Apr 2021 17:16:10 BST | Downloaded [Gimp.app]
Tue  6 Apr 2021 17:16:10 BST | Checking if the application is running
Tue  6 Apr 2021 17:16:11 BST | [Gimp] isn't running, lets carry on
Tue  6 Apr 2021 17:16:11 BST | Installing [Gimp]
Tue  6 Apr 2021 17:16:11 BST | Mounting [/tmp/gimp.dmg] to [/tmp/Gimp]
Tue  6 Apr 2021 17:16:31 BST | Copying /tmp/Gimp/*.app to /Applications/Gimp.app
Tue  6 Apr 2021 17:17:07 BST | Un-mounting [/tmp/Gimp]
Tue  6 Apr 2021 17:17:07 BST | [Gimp] Installed
Tue  6 Apr 2021 17:17:07 BST | Cleaning Up
Tue  6 Apr 2021 17:17:07 BST | Fixing up permissions
Tue  6 Apr 2021 17:17:09 BST | Application [Gimp] succesfully installed
Tue  6 Apr 2021 17:17:09 BST | Writing last modifieddate [Tue, 06 Apr 2021 14:04:10 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installGimp/Gimp.meta]

```
