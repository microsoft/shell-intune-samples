# Minecraft: Education Edition Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install DMG applications. In this example the script will download the Minecraft Education Edition dmg file from the Microsoft download servers (https://aka.ms/meeclientmacos) and then install it onto the Mac. To reduce unnecessary re-downloads, the script monitors the date-modified attrbiute on the HTTP header of https://aka.ms/meeclientmacos rather than checking if the file stored there is actually changed.

For Minecraft: Education Edition support, see [Minecraft: Education Edition Support](https://educommunity.minecraft.net/).

## Scenarios
The script can be used for two scenarios:

 - Install - The script can be used to install Minecraft: Education Edition
 
 - Update - The script can run once or scheduled to update the installed version of Minecraft: Education Edition. You can schedule the script to run once a week to check for updates.

## Description

The script performs the following actions if **Minecraft Education Edition** is not already installed:
1. Downloads the DMG from **https://aka.ms/meeclientmacos** to **/tmp/mee.dmg**.
2. Mounts the DMG file at **/tmp/InstallMEE**.
3. Copies (installs) the application to the **/Applications** directory.
4. Unmounts the DMG file.
5. Deletes the DMG file.
6. Records the date-modified attribute of **https://aka.ms/meeclientmacos** so it can be checked at future script executions.

If **Minecraft Education Edition** is already installed, it will compare the date-modified of **https://aka.ms/meeclientmacos** against the recorded version. 
 - If the date-modified of **https://aka.ms/meeclientmacos** is newer, it will download and install the new version.
 - If no date-modified was previously recorded, it will download and attempt to install.

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : 
  - **Not configured** to run once
  - **Every 1 week** to check for and install updates once a week
- Number of times to retry if script fails : 3

## Log File

The log file will output to **/Library/Intune/Scripts/installMinecraftEducationEdition/installmee.log** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection).
```

##############################################################
# Fri Aug 21 20:23:56 AEST 2020 | Starting install of Minecraft Education Edition
############################################################

Fri Aug 21 20:23:56 AEST 2020 | Downloading Minecraft Education Edition
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed

  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0

  0  224M    0 1915k    0     0   894k      0  0:04:17  0:00:02  0:04:15  894k
  2  224M    2 5932k    0     0  1888k      0  0:02:01  0:00:03  0:01:58 4016k
  4  224M    4  9.9M    0     0  2451k      0  0:01:33  0:00:04  0:01:29 4115k
  6  224M    6 14.1M    0     0  2812k      0  0:01:21  0:00:05  0:01:16 4179k
  8  224M    8 18.2M    0     0  3049k      0  0:01:15  0:00:06  0:01:09 4202k
  9  224M    9 22.4M    0     0  3220k      0  0:01:11  0:00:07  0:01:04 4215k
 11  224M   11 26.6M    0     0  3350k      0  0:01:08  0:00:08  0:01:00 4269k
 13  224M   13 30.8M    0     0  3453k      0  0:01:06  0:00:09  0:00:57 4282k
 15  224M   15 35.0M    0     0  3534k      0  0:01:05  0:00:10  0:00:55 4278k
 17  224M   17 39.1M    0     0  3598k      0  0:01:03  0:00:11  0:00:52 4273k
 18  224M   18 41.6M    0     0  3516k      0  0:01:05  0:00:12  0:00:53 3940k
 19  224M   19 44.2M    0     0  3443k      0  0:01:06  0:00:13  0:00:53 3593k
 20  224M   20 46.7M    0     0  3389k      0  0:01:07  0:00:14  0:00:53 3272k
 22  224M   22 50.8M    0     0  3441k      0  0:01:06  0:00:15  0:00:51 3252k
 24  224M   24 54.3M    0     0  3450k      0  0:01:06  0:00:16  0:00:50 3119k
 26  224M   26 58.4M    0     0  3492k      0  0:01:05  0:00:17  0:00:48 3433k
 27  224M   27 62.5M    0     0  3530k      0  0:01:05  0:00:18  0:00:47 3760k
 29  224M   29 66.6M    0     0  3564k      0  0:01:04  0:00:19  0:00:45 4060k
 31  224M   31 70.7M    0     0  3598k      0  0:01:03  0:00:20  0:00:43 4075k
 33  224M   33 74.8M    0     0  3625k      0  0:01:03  0:00:21  0:00:42 4190k
 34  224M   34 77.7M    0     0  3597k      0  0:01:03  0:00:22  0:00:41 3956k
 36  224M   36 81.3M    0     0  3599k      0  0:01:03  0:00:23  0:00:40 3848k
 37  224M   37 85.3M    0     0  3621k      0  0:01:03  0:00:24  0:00:39 3839k
 39  224M   39 89.4M    0     0  3643k      0  0:01:03  0:00:25  0:00:38 3822k
 41  224M   41 92.5M    0     0  3627k      0  0:01:03  0:00:26  0:00:37 3633k
 42  224M   42 96.4M    0     0  3639k      0  0:01:03  0:00:27  0:00:36 3825k
 44  224M   44  100M    0     0  3639k      0  0:01:03  0:00:28  0:00:35 3825k
 46  224M   46  103M    0     0  3653k      0  0:01:02  0:00:29  0:00:33 3809k
 48  224M   48  108M    0     0  3669k      0  0:01:02  0:00:30  0:00:32 3799k
 49  224M   49  111M    0     0  3663k      0  0:01:02  0:00:31  0:00:31 3857k
 51  224M   51  114M    0     0  3663k      0  0:01:02  0:00:32  0:00:30 3794k
 52  224M   52  117M    0     0  3643k      0  0:01:03  0:00:33  0:00:30 3667k
 54  224M   54  121M    0     0  3659k      0  0:01:02  0:00:34  0:00:28 3689k
 56  224M   56  126M    0     0  3672k      0  0:01:02  0:00:35  0:00:27 3689k
 57  224M   57  130M    0     0  3688k      0  0:01:02  0:00:36  0:00:26 3841k
 59  224M   59  134M    0     0  3700k      0  0:01:02  0:00:37  0:00:25 3935k
 61  224M   61  138M    0     0  3708k      0  0:01:02  0:00:38  0:00:24 4135k
 63  224M   63  142M    0     0  3722k      0  0:01:01  0:00:39  0:00:22 4158k
 65  224M   65  146M    0     0  3736k      0  0:01:01  0:00:40  0:00:21 4190k
 66  224M   66  149M    0     0  3725k      0  0:01:01  0:00:41  0:00:20 3993k
 68  224M   68  153M    0     0  3725k      0  0:01:01  0:00:42  0:00:19 3909k
 69  224M   69  155M    0     0  3701k      0  0:01:02  0:00:43  0:00:19 3646k
 71  224M   71  159M    0     0  3710k      0  0:01:02  0:00:44  0:00:18 3610k
 72  224M   72  164M    0     0  3720k      0  0:01:01  0:00:45  0:00:16 3591k
 74  224M   74  168M    0     0  3732k      0  0:01:01  0:00:46  0:00:15 3789k
 76  224M   76  172M    0     0  3741k      0  0:01:01  0:00:47  0:00:14 3880k
 78  224M   78  176M    0     0  3749k      0  0:01:01  0:00:48  0:00:13 4167k
 79  224M   79  179M    0     0  3741k      0  0:01:01  0:00:49  0:00:12 4023k
 81  224M   81  183M    0     0  3750k      0  0:01:01  0:00:50  0:00:11 4024k
 83  224M   83  187M    0     0  3758k      0  0:01:01  0:00:51  0:00:10 3998k
 85  224M   85  191M    0     0  3754k      0  0:01:01  0:00:52  0:00:09 3872k
 86  224M   86  193M    0     0  3737k      0  0:01:01  0:00:53  0:00:08 3622k
 88  224M   88  197M    0     0  3742k      0  0:01:01  0:00:54  0:00:07 3743k
 89  224M   89  201M    0     0  3744k      0  0:01:01  0:00:55  0:00:06 3676k
 91  224M   91  205M    0     0  3740k      0  0:01:01  0:00:56  0:00:05 3555k
 93  224M   93  209M    0     0  3746k      0  0:01:01  0:00:57  0:00:04 3671k
 94  224M   94  212M    0     0  3751k      0  0:01:01  0:00:58  0:00:03 3897k
 96  224M   96  216M    0     0  3756k      0  0:01:01  0:00:59  0:00:02 3918k
 98  224M   98  220M    0     0  3756k      0  0:01:01  0:01:00  0:00:01 3893k
 99  224M   99  224M    0     0  3756k      0  0:01:01  0:01:01 --:--:-- 3933k
100  224M  100  224M    0     0  3756k      0  0:01:01  0:01:01 --:--:-- 3896k
Fri Aug 21 20:24:57 AEST 2020 | Installing Minecraft Education Edition
Fri Aug 21 20:24:57 AEST 2020 | Mounting /tmp/mee.dmg to /tmp/InstallMEE
Checksumming Protective Master Boot Record (MBR : 0)…
Protective Master Boot Record (MBR :: verified   CRC32 $8EB3A07F
Checksumming GPT Header (Primary GPT Header : 1)…
 GPT Header (Primary GPT Header : 1): verified   CRC32 $73297EF5
Checksumming GPT Partition Data (Primary GPT Table : 2)…
GPT Partition Data (Primary GPT Tabl: verified   CRC32 $1E3736C2
Checksumming  (Apple_Free : 3)…
                    (Apple_Free : 3): verified   CRC32 $00000000
Checksumming disk image (Apple_HFS : 4)…
          disk image (Apple_HFS : 4): verified   CRC32 $F2253BCE
Checksumming  (Apple_Free : 5)…
                    (Apple_Free : 5): verified   CRC32 $00000000
Checksumming GPT Partition Data (Backup GPT Table : 6)…
GPT Partition Data (Backup GPT Table: verified   CRC32 $1E3736C2
Checksumming GPT Header (Backup GPT Header : 7)…
  GPT Header (Backup GPT Header : 7): verified   CRC32 $81FB5DD2
verified   CRC32 $055FB58E
/dev/disk3          	GUID_partition_scheme          	
/dev/disk3s1        	Apple_HFS                      	/private/tmp/InstallMEE
Fri Aug 21 20:25:02 AEST 2020 | Copying /tmp/InstallMEE/*.app to /Applications
Fri Aug 21 20:25:17 AEST 2020 | Un-mounting /tmp/InstallMEE
Fri Aug 21 20:25:18 AEST 2020 | Minecraft Education Edition Installed
Fri Aug 21 20:25:18 AEST 2020 | Cleaning Up
Fri Aug 21 20:25:18 AEST 2020 | Writing last modifieddate Fri, 07 Aug 2020 00:06:25 GMT to /Library/Intune/Scripts/installMinecraftEducationEdition/Minecraft Education Edition.meta
Fri Aug 21 20:25:18 AEST 2020 | Fixing up permissions
```
