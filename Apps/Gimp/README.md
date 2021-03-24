# Installing Gimp

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install DMG applications via [Azure Blob Storage](https://microsofteur-my.sharepoint.com/personal/neiljohn_microsoft_com/Documents/Intune/Blogs/Deploying apps with Intune scripts and Azure blob storage/-%09https:/docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction). In this example the script will download the Gimp dmg file from the Azure servers and then install it onto the Mac. To reduce unnecessary re-downloads, the script monitors the date-modified attrbiute on the HTTP header rather than checking if the file stored there is actually changed.

The public site for the GNU Image Manipulation Program (GIMP) is here.

## Scenarios
The script can be used for two scenarios:

 - Install - The script can be used to install the GNU Image Manipulation Program
 - Update - The script can run once or scheduled to update the installed version of the GNU Image Manipulation Program. You can schedule the script to check for updates.

## Description

The script performs the following actions if the **GNU Image Manipulation Program** is not already installed:
1. Downloads the DMG from Azure blob storage to **/tmp/mee.dmg**.
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
VOLUME="/tmp/GIMP"
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

**log** this is the path of the logfile. It is made up of the **logandmetadir** path and the **appname**. There isn't usually a need to change this but it's provided here in case you specifically want to set the log file path somewhere specific.
```
log="$logandmetadir/$appname.log"
```

**metafile** just in the same way as the **log** path above this value is automatically generated based on the **logandmetadir** path and the **appname**. It's used by the script to store the last update time. You shouldn't need to change this but it's provided here in case you have a need to set it to an explicit location.
```
metafile="$logandmetadir/$appname.meta"
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

##############################################################
# Wed 24 Mar 2021 15:12:08 GMT | Starting install of Gimp
############################################################

Wed 24 Mar 2021 15:12:08 GMT | https://numberwang.blob.core.windows.net/numberwang/gimp.dmg last update on Wed, 24 Mar 2021 11:21:40 GMT
Wed 24 Mar 2021 15:12:08 GMT | Looking for metafile (/Library/Logs/Microsoft/IntuneScripts/installGimp/Gimp.meta)
Wed 24 Mar 2021 15:12:08 GMT | Meta file /Library/Logs/Microsoft/IntuneScripts/installGimp/Gimp.meta notfound, downloading anyway
Wed 24 Mar 2021 15:12:08 GMT | Downloading Gimp
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed

  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0  166M    0 1471k    0     0  1618k      0  0:01:45 --:--:--  0:01:45 1617k
  2  166M    2 3919k    0     0  2183k      0  0:01:18  0:00:01  0:01:17 2182k
  5  166M    5 9840k    0     0  3521k      0  0:00:48  0:00:02  0:00:46 3520k
  9  166M    9 15.5M    0     0  4186k      0  0:00:40  0:00:03  0:00:37 4185k
 12  166M   12 21.3M    0     0  4565k      0  0:00:37  0:00:04  0:00:33 4564k
 16  166M   16 27.2M    0     0  4824k      0  0:00:35  0:00:05  0:00:30 5419k
 19  166M   19 33.1M    0     0  5001k      0  0:00:34  0:00:06  0:00:28 6012k
 23  166M   23 39.1M    0     0  5140k      0  0:00:33  0:00:07  0:00:26 6044k
 26  166M   26 45.0M    0     0  5239k      0  0:00:32  0:00:08  0:00:24 6038k
 30  166M   30 50.8M    0     0  5319k      0  0:00:32  0:00:09  0:00:23 6041k
 34  166M   34 56.7M    0     0  5383k      0  0:00:31  0:00:10  0:00:21 6032k
 37  166M   37 62.6M    0     0  5441k      0  0:00:31  0:00:11  0:00:20 6038k
 41  166M   41 68.5M    0     0  5487k      0  0:00:31  0:00:12  0:00:19 6028k
 44  166M   44 74.4M    0     0  5528k      0  0:00:30  0:00:13  0:00:17 6038k
 48  166M   48 80.3M    0     0  5558k      0  0:00:30  0:00:14  0:00:16 6027k
 51  166M   51 86.2M    0     0  5590k      0  0:00:30  0:00:15  0:00:15 6038k
 55  166M   55 92.0M    0     0  5615k      0  0:00:30  0:00:16  0:00:14 6025k
 58  166M   58 98.0M    0     0  5642k      0  0:00:30  0:00:17  0:00:13 6038k
 62  166M   62  103M    0     0  5661k      0  0:00:30  0:00:18  0:00:12 6025k
 65  166M   65  109M    0     0  5675k      0  0:00:30  0:00:19  0:00:11 6020k
 69  166M   69  115M    0     0  5693k      0  0:00:30  0:00:20  0:00:10 6019k
 72  166M   72  121M    0     0  5703k      0  0:00:29  0:00:21  0:00:08 6000k
 76  166M   76  127M    0     0  5719k      0  0:00:29  0:00:22  0:00:07 5993k
 79  166M   79  133M    0     0  5732k      0  0:00:29  0:00:23  0:00:06 6000k
 83  166M   83  139M    0     0  5745k      0  0:00:29  0:00:24  0:00:05 6024k
 86  166M   86  145M    0     0  5756k      0  0:00:29  0:00:25  0:00:04 6019k
 90  166M   90  150M    0     0  5768k      0  0:00:29  0:00:26  0:00:03 6051k
 94  166M   94  156M    0     0  5777k      0  0:00:29  0:00:27  0:00:02 6044k
 97  166M   97  162M    0     0  5785k      0  0:00:29  0:00:28  0:00:01 6035k
100  166M  100  166M    0     0  5789k      0  0:00:29  0:00:29 --:--:-- 6020k
Wed 24 Mar 2021 15:12:37 GMT | Downloaded https://numberwang.blob.core.windows.net/numberwang/gimp.dmg to /tmp/gimp.dmg
Wed 24 Mar 2021 15:12:38 GMT | Gimp.app isn't running, lets carry on
Wed 24 Mar 2021 15:12:38 GMT | Installing Gimp
Wed 24 Mar 2021 15:12:38 GMT | Mounting /tmp/gimp.dmg to /tmp/GIMP
Checksumming Protective Master Boot Record (MBR : 0)…
Protective Master Boot Record (MBR :: verified CRC32 $599CA830
Checksumming GPT Header (Primary GPT Header : 1)…
 GPT Header (Primary GPT Header : 1): verified CRC32 $D860EC5C
Checksumming GPT Partition Data (Primary GPT Table : 2)…
GPT Partition Data (Primary GPT Tabl: verified CRC32 $605B2BB9
Checksumming  (Apple_Free : 3)…
                    (Apple_Free : 3): verified CRC32 $00000000
Checksumming disk image (Apple_HFS : 4)…
          disk image (Apple_HFS : 4): verified CRC32 $86BA9C3B
Checksumming  (Apple_Free : 5)…
                    (Apple_Free : 5): verified CRC32 $00000000
Checksumming GPT Partition Data (Backup GPT Table : 6)…
GPT Partition Data (Backup GPT Table: verified CRC32 $605B2BB9
Checksumming GPT Header (Backup GPT Header : 7)…
  GPT Header (Backup GPT Header : 7): verified CRC32 $DF2178E5
verified CRC32 $4852FD94
/dev/disk2          	GUID_partition_scheme          	
/dev/disk2s1        	Apple_HFS                      	/private/tmp/GIMP
Wed 24 Mar 2021 15:12:53 GMT | Copying /tmp/GIMP/*.app to /Applications/Gimp.app
Wed 24 Mar 2021 15:14:41 GMT | Un-mounting /tmp/GIMP
Wed 24 Mar 2021 15:14:42 GMT | Gimp Installed
Wed 24 Mar 2021 15:14:42 GMT | Cleaning Up
Wed 24 Mar 2021 15:14:42 GMT | Writing last modifieddate Wed, 24 Mar 2021 11:21:40 GMT to /Library/Logs/Microsoft/IntuneScripts/installGimp/Gimp.meta
Wed 24 Mar 2021 15:14:42 GMT | Fixing up permissions
Wed 24 Mar 2021 15:14:43 GMT | Application [Gimp] succesfully installed

```
