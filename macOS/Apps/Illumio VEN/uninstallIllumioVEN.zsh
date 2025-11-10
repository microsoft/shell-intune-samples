#!/bin/zsh
#set -x
############################################################################################
##
## Script to uninstall Illumio VEN from macOS
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
appname="IllumioVENUninstaller"                                                                         # The name of our uninstall script
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"                                          # The location of our logs and last updated data
log="$logandmetadir/$appname.log"                                                                       # The location of the script log file
illumiodir="/opt/illumio_ven"                                                                           # Illumio VEN installation directory
ctlpath="$illumiodir/illumio-ven-ctl"                                                                   # Illumio VEN control binary

# Check if the log directory has been created
if [ -d "$logandmetadir" ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | Creating log directory - $logandmetadir"
    mkdir -p "$logandmetadir"
fi

# Check if Illumio VEN is installed
CheckIfIllumioVENIsInstalled() {
if [ -d "$illumiodir" ]; then
    echo "$(date) | Illumio VEN directory detected at $illumiodir. Let's proceed..."
else
    echo "$(date) | Illumio VEN directory not found. Nothing to uninstall. Closing the script..."
    exit 0
fi
}

# Run Illumio VEN unpair command
RunIllumioVENUnpair() {
if [ -x "$ctlpath" ]; then
    echo "$(date) | Running Illumio VEN unpair command..."
    if "$ctlpath" unpair saved; then
        echo "$(date) | Illumio VEN unpair command returned success. Verifying removal..."
    else
        echo "$(date) | ERROR: Illumio VEN unpair command failed. Closing script..."
        exit 1
    fi
else
    echo "$(date) | ERROR: Illumio VEN control binary not found or not executable at $ctlpath. Closing script..."
    exit 1
fi
}

VerifyIllumioVENRemoval() {
if [ -d "$illumiodir" ] || [ -x "$ctlpath" ]; then
    echo "$(date) | ERROR: Illumio VEN components still detected at $illumiodir. Closing script..."
    exit 1
else
    echo "$(date) | Illumio VEN components not detected. Uninstallation verified. Closing script..."
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

# Run functions
CheckIfIllumioVENIsInstalled
RunIllumioVENUnpair
VerifyIllumioVENRemoval