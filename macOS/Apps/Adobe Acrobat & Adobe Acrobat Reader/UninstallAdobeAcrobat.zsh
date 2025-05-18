#!/bin/zsh
#set -x
############################################################################################
##
## Script to uninstall Adobe Acrobat / Adobe Acrobat Reader 2020, Classic and DC
##
############################################################################################

## Copyright (c) 2025 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables
appname="UninstallAdobeAcrobatAndAdobeAcrobatReader"                                                   # The name of our file deployment script
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"                                         # The location of our logs and last updated data
acrobatreader2020installationpath="/Applications/Adobe Acrobat Reader 2020.app"                        # The first location where Adobe Acrobat Reader 2020 is installed
adobeacrobat2020installationpath="/Applications/Adobe Acrobat 2020/Adobe Acrobat.app"                  # The second location where Adobe Acrobat / Adobe Acrobat Reader 2020 is installed
adobeacrobatclassicinstallationpath="/Applications/Adobe Acrobat Classic/Adobe Acrobat.app"            # The second location where Adobe Acrobat / Adobe Acrobat Reader Classic is installed
adobeacrobatdcinstallationpath="/Applications/Adobe Acrobat DC/Adobe Acrobat.app"                      # The location where Adobe Acrobat / Adobe Acrobat Reader DC is installed         
log="$logandmetadir/$appname.log"                                                                      # The location of the script log file
# The location of Acrobat Uninstaller for Adobe Acrobat / Adobe Acrobat Reader 2020
acrobat2020uninstaller="/Applications/Adobe Acrobat 2020/Adobe Acrobat.app/Contents/Helpers/Acrobat Uninstaller.app/Contents/Library/LaunchServices/com.adobe.Acrobat.RemoverTool"
# The location of Acrobat Uninstaller for Adobe Acrobat / Adobe Acrobat Reader Classic
acrobatclassicuninstaller="/Applications/Adobe Acrobat Classic/Adobe Acrobat.app/Contents/Helpers/Acrobat Uninstaller.app/Contents/Library/LaunchServices/com.adobe.Acrobat.RemoverTool"
# The location of Acrobat Uninstaller for Adobe Acrobat / Adobe Acrobat Reader DC
acrobatdcuninstaller="/Applications/Adobe Acrobat DC/Adobe Acrobat.app/Contents/Helpers/Acrobat Uninstaller.app/Contents/Library/LaunchServices/com.adobe.Acrobat.RemoverTool"

# Check if the log directory has been created
if [ -d $logandmetadir ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# Check if Adobe Acrobat Reader 2020 is already installed
CheckIfAcrobatReader2020IsInstalled() {
if [ -d $acrobatreader2020installationpath ]; then
    # If Adobe Acrobat Reader 2020 is installed, inform this and uninstall the application
    echo "$(date) | Adobe Acrobat Reader 2020 is installed. Making sure, that application is closed..."
    osascript -e 'tell application "Adobe Acrobat Reader 2020" to quit' >/dev/null 2>&1
    killall "AdobeReader" >/dev/null 2>&1
    sleep 10
    echo "$(date) | Done. Uninstalling Adobe Acrobat Reader 2020..."
    rm -rf "$acrobatreader2020installationpath" >/dev/null 2>&1
    sleep 30
    if ! [ -e "$acrobatreader2020installationpath" ]; then
			echo "$(date) | Adobe Acrobat Reader 2020 successfully uninstalled. Let's proceed..."
		fi
else
    # If Adobe Acrobat Reader 2020 is not installed, inform this and continue
    echo "$(date) | Adobe Acrobat Reader 2020 is not installed. Let's proceed..."
fi
}

# Check if Adobe Acrobat / Adobe Acrobat Reader 2020 is already installed
CheckIfAcrobat2020IsInstalled() {
if [ -d $adobeacrobat2020installationpath ]; then
    # If Adobe Acrobat / Adobe Acrobat Reader 2020 is installed, inform this and uninstall the application
    echo "$(date) | Adobe Acrobat / Adobe Acrobat Reader 2020 is installed. Making sure, that application is closed..."
    osascript -e 'tell application "Adobe Acrobat" to quit' >/dev/null 2>&1
    killall "AdobeAcrobat" >/dev/null 2>&1
    sleep 10
    echo "$(date) | Done. Uninstalling Adobe Acrobat / Adobe Acrobat Reader 2020..."
    $acrobat2020uninstaller Uninstall $adobeacrobat2020installationpath > /dev/null 2>&1
    sleep 30
    if ! [ -e "$adobeacrobat2020installationpath" ]; then
			echo "$(date) | Adobe Acrobat / Adobe Acrobat Reader 2020 successfully uninstalled. Let's proceed..."
		fi
else
    # If Adobe Acrobat / Adobe Acrobat Reader 2020 is not installed, inform this and continue
    echo "$(date) | Adobe Acrobat / Adobe Acrobat Reader 2020 is not installed. Let's proceed..."
fi
}

# Check if Adobe Acrobat / Adobe Acrobat Reader Classic is already installed
CheckIfAcrobatClassicIsInstalled() {
if [ -d $adobeacrobatclassicinstallationpath ]; then
    # If Adobe Acrobat / Adobe Acrobat Reader Classic is installed, inform this and uninstall the application
    echo "$(date) | Adobe Acrobat / Adobe Acrobat Reader Classic is installed. Making sure, that application is closed..."
    osascript -e 'tell application "Adobe Acrobat" to quit' >/dev/null 2>&1
    killall "AdobeAcrobat" >/dev/null 2>&1
    sleep 10
    echo "$(date) | Done. Uninstalling Adobe Acrobat / Adobe Acrobat Reader Classic..."
    $acrobatclassicuninstaller Uninstall $adobeacrobatclassicinstallationpath > /dev/null 2>&1
    sleep 30
    if ! [ -e "$adobeacrobatclassicinstallationpath" ]; then
			echo "$(date) | Adobe Acrobat / Adobe Acrobat Reader Classic successfully uninstalled. Let's proceed..."
		fi
else
    # If Adobe Acrobat / Adobe Acrobat Reader Classic is not installed, inform this and continue
    echo "$(date) | Adobe Acrobat / Adobe Acrobat Reader Classic is not installed. Let's proceed..."
fi
}

# Check if Adobe Acrobat / Adobe Acrobat Reader DC is already installed
CheckIfAcrobatDCIsInstalled() {
if [ -d $adobeacrobatdcinstallationpath ]; then
    # If Adobe Acrobat / Adobe Acrobat Reader DC is installed, inform this and uninstall the application
    echo "$(date) | Adobe Acrobat / Adobe Acrobat Reader DC is installed. Making sure, that application is closed..."
    osascript -e 'tell application "Adobe Acrobat" to quit' >/dev/null 2>&1
    killall "AdobeAcrobat" >/dev/null 2>&1
    sleep 10
    echo "$(date) | Done. Uninstalling Adobe Acrobat / Adobe Acrobat Reader DC..."
    $acrobatdcuninstaller Uninstall $adobeacrobatdcinstallationpath > /dev/null 2>&1
    sleep 30
    if ! [ -e "$adobeacrobatdcinstallationpath" ]; then
			echo "$(date) | Adobe Acrobat / Adobe Acrobat Reader DC successfully uninstalled. You can now install it back if needed. Closing script..."
            exit 0
		fi
else
    # If Adobe Acrobat / Adobe Acrobat Reader DC is not installed, inform this and continue
    echo "$(date) | Adobe Acrobat / Adobe Acrobat Reader DC is not installed. You can now install it if needed. Closing script..."
    exit 0
fi
}

# Start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $appname"
echo "############################################################"
echo ""

# Run function
CheckIfAcrobatReader2020IsInstalled
CheckIfAcrobat2020IsInstalled
CheckIfAcrobatClassicIsInstalled
CheckIfAcrobatDCIsInstalled