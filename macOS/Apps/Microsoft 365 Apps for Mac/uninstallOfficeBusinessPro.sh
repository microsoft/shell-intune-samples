#!/bin/bash
#set -x

############################################################################################
##
## Script to remove Microsoft Office for Mac
## includes - Outlook, Word, Excel, PowerPoint, OneDrive, OneNote and Teams
##
###########################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables
##############################

##
## Note: This script will not do anything until the following lines are modified
##
## Line 50 - Uncommenting this will kill all Microsoft apps running on the Mac
## Line 97,98,99 - Uncommenting these will remove the users entire local Outlook data
## Line 109 - Uncommenting this will remove all folders defined in the folders variable
## Line 132 - Uncommenting this will remove any left over icons in the dock


appname="Office Business Pro for Mac"
log="/var/log/uninstallofficebusinesspro.log"

# start logging

exec 1>> $log 2>&1

echo ""
echo "##############################################################"
echo "# $(date) | Starting Removal of $appname"
echo "############################################################"
echo ""

consoleuser=$(ls -l /dev/console | awk '{ print $3 }')

echo "$(date) | logged in user is" $consoleuser

#pkill -f Microsoft

dockitems=(
"/Applications/Microsoft Teams.app"
"/Applications/Microsoft OneNote.app"
"/Applications/Microsoft PowerPoint.app"
"/Applications/Microsoft Excel.app"
"/Applications/Microsoft Word.app"
"/Applications/Microsoft Outlook.app"
"/Applications/OneDrive.app"
)

icons=(
"Microsoft Excel"
"Microsoft OneNote"
"Microsoft Outlook"
"Microsoft PowerPoint"
"Microsoft Word"
"Microsoft Teams"
"OneDrive"
)

folders=(
"/Applications/Microsoft Excel.app"
"/Applications/Microsoft OneNote.app"
"/Applications/Microsoft Outlook.app"
"/Applications/Microsoft PowerPoint.app"
"/Applications/Microsoft Word.app"
"/Applications/Microsoft Teams.app"
"/Applications/OneDrive.app"
#
"/Users/$consoleuser/Library/Containers/com.microsoft.errorreporting"
"/Users/$consoleuser/Library/Containers/com.microsoft.Excel"
"/Users/$consoleuser/Library/Containers/com.microsoft.netlib.shipassertprocess"
"/Users/$consoleuser/Library/Containers/com.microsoft.Office365ServiceV2"
"/Users/$consoleuser/Library/Containers/com.microsoft.Outlook"
"/Users/$consoleuser/Library/Containers/com.microsoft.Powerpoint"
"/Users/$consoleuser/Library/Containers/com.microsoft.RMS-XPCService"
"/Users/$consoleuser/Library/Containers/com.microsoft.Word"
"/Users/$consoleuser/Library/Containers/com.microsoft.onenote.mac"
#
#
#### WARNING: Outlook data will be removed when you move the three folders listed below.
#### You should back up these folders before you delete them.
####
#### Uncomment to remove Outlook data
#
#"/Users/$consoleuser/Library/Group Containers/UBF8T346G9.ms"
#"/Users/$consoleuser/Library/Group Containers/UBF8T346G9.Office"
#"/Users/$consoleuser/Library/Group Containers/UBF8T346G9.OfficeOsfWebHost"
#
)

search="*"


for i in "${folders[@]}"
do
    echo "$(date) | removing folder ${i}"
    #rm -rf "${i}"
done

if [ $? == 0 ]; then
     echo "$(date) | Success"
else
     echo "$(date) | Failure"
     exit 1
fi

echo "$(date) | Removing Dock Items"
sudo rm -rf /tmp/dockutil
git clone https://github.com/kcrawford/dockutil /tmp/dockutil

if [ $? == 0 ]; then
     echo "$(date) | Success"
else
     echo "$(date) | Failured to install dockutil"
fi

for i in "${icons[@]}"
do
    echo "$(date) | removing icon ${i}"
    #/tmp/dockutil/scripts/dockutil --remove "${i}" --allhomes
done
