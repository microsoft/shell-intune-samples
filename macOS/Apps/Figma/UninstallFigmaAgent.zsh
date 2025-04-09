#!/bin/zsh
#set -x
############################################################################################
##
## Script to uninstall Figma Agent and other Figma remaining components
##
############################################################################################

## Copyright (c) 2024 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables
appname="UninstallFigmaAgent"                                                       # The name of our deployment script
logandmetadir="$HOME/Library/Logs/Microsoft/IntuneScripts/$appname"                 # The location of our logs and last updated data
figma="/Applications/Figma.app"                                                     # Location where the Figma is installed
figmaagent="$HOME/Library/Application Support/Figma/FigmaAgent.app"                 # Location where the Figma Agent is installed
figmadaemon="$HOME/Library/Application Support/Figma/FigmaDaemon.app"               # Location where the Figma Daemon is installed
daemon_plist_path="$HOME/Library/LaunchAgents/com.figma.daemon.plist"               # Location where the daemon plist is installed
folder="$HOME/Library/Application Support/Figma/"                                   # Location of the Figma-folder
log="$logandmetadir/$appname.log"                                                   # The location of the script log file

# Check if the log directory has been created
if [ -d $logandmetadir ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# Check that if Figma is still installed
CheckFigmaInstallation() {
   if [ -d $figma ]; then
    echo "$(date) | Figma is still installed. Therefore, we cannot proceed. Closing script.."
    exit 1
else
    echo "$(date) | Figma is not installed. We can proceed..."
fi 
}


# Uninstall daemon plist
UninstallDaemonPlist() {
echo "$(date) | Checking if daemon plist exist..."
if [ -e "$daemon_plist_path" ]; then
    echo "$(date) | daemon plist found. Deleting it..."
    launchctl unload "$daemon_plist_path"
    rm "$daemon_plist_path"
sleep 2
echo "$(date) | daemon plist uninstalled. Let's continue..."
fi
}

# Inform if there is no daemon plist
NoDaemonPlist() {
echo "$(date) | There is no daemon plist on this device. Let's continue..."
}

# Uninstall Figma Daemon
UninstallFigmaDaemon() {
echo "$(date) | Uninstalling Figma Daemon..."
rm -rf $figmadaemon
sleep 2
echo "$(date) | Figma Daemon has been uninstalled. Let's continue..."
}

# Inform if there is no Figma installation
NoFigmaDaemonInstallation() {
echo "$(date) | There is no Figma Daemon installation on this device. Let's continue..."
}

# Uninstall Figma Agent
UninstallFigmaAgent() {
echo "$(date) | Uninstalling Figma Agent..."
rm -rf $figmaagent
osascript -e 'tell application "System Events" to delete login item "FigmaAgent"' >/dev/null 2>&1
killall figma_agent figma-node FigmaDaemon >/dev/null 2>&1
sleep 2
rm -rf $folder
echo "$(date) | Figma Agent has been uninstalled. All needed files have been deleted. Closing script..."
exit 0
}

# Inform if there is no Figma installation
NoFigmaAgentInstallation() {
echo "$(date) | There is no Figma Agent installation on this device. All needed files have been deleted. Closing script..."
exit 0
}

# Start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $appname"
echo "############################################################"
echo ""

# Run Function
CheckFigmaInstallation

if test -f $daemon_plist_path
    then UninstallDaemonPlist
else NoDaemonPlist
fi

if test -d $figmadaemon
    then UninstallFigmaDaemon
else NoFigmaDaemonInstallation
fi

if test -d $figmaagent
    then UninstallFigmaAgent
else NoFigmaAgentInstallation
fi