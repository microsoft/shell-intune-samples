#!/bin/zsh
#set -x
###############################################################################################
##
## Script to uninstall Apple Bloatware Apps (iMovie, GarageBand, Pages, Numbers, and Keynote)
##
###############################################################################################

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
appname="UninstallAppleBloatwareApps"                           # The name of our script deployment as "app"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"  # The location of our logs and last updated data
imovie="/Applications/iMovie.app"                               # Installation location of iMovie -app
garageband="/Applications/GarageBand.app"                       # Installation location of GarageBand -app
pages="/Applications/Pages.app"                                 # Installation location of Pages -app
numbers="/Applications/Numbers.app"                             # Installation location of Numbers -app
keynote="/Applications/Keynote.app"                             # Installation location of Keynote -app
log="$logandmetadir/$appname.log"                               # The location of the script log file
abmcheck=true                                                   # Run this script if this device is ABM managed

# Check if the log directory has been created
if [ -d $logandmetadir ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | Creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# Uninstall iMovie
Uninstallimovie() {
echo "$(date) | Uninstalling iMovie..."
rm -rf $imovie
sleep 2
echo "$(date) | iMovie has been uninstalled."
}

# Uninstall GarageBand
UninstallGarageBand() {
echo "$(date) | Uninstalling GarageBand..."
rm -rf $garageband
sleep 2
echo "$(date) | GarageBand has been uninstalled."
}

# Uninstall Pages
UninstallPages() {
echo "$(date) | Uninstalling Pages..."
rm -rf $pages
sleep 2
echo "$(date) | Pages has been uninstalled."
}

# Uninstall Numbers
UninstallNumbers() {
echo "$(date) | Uninstalling Numbers..."
rm -rf $numbers
sleep 2
echo "$(date) | Numbers has been uninstalled."
}

# Uninstall Keynote
UninstallKeynote() {
echo "$(date) | Uninstalling Keynote..."
rm -rf $keynote
sleep 2
echo "$(date) | Keynote has been uninstalled."
}

# Inform if there is no iMovie installation
NoiMovieInstallation() {
echo "$(date) | There is no iMovie installation on this device."
}

# Inform if there is no GarageBand installation
NoGarageBandInstallation() {
echo "$(date) | There is no GarageBand installation on this device."
}

# Inform if there is no Pages installation
NoPagesInstallation() {
echo "$(date) | There is no Pages installation on this device."
}

# Inform if there is no Numbers installation
NoNumbersInstallation() {
echo "$(date) | There is no Numbers installation on this device."
}

# Inform if there is no Keynote installation
NoKeynoteInstallation() {
echo "$(date) | There is no Keynote installation on this device."
}

# Start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $appname"
echo "############################################################"
echo ""

# Is this a ABM DEP device?
if [ "$abmcheck" = true ]; then
  echo "$(date) | Checking MDM Profile Type"
  profiles status -type enrollment | grep "Enrolled via DEP: Yes"
  if [[ ! $? == 0 ]]; then
    echo "$(date) | This device is not ABM managed"
    exit 0;
  else
    echo "$(date) | Device is ABM Managed"
  fi
fi

# Run functions

# Uninstall iMovie if existed
if test -d $imovie
    then Uninstallimovie
else NoiMovieInstallation
fi

# Uninstall GarageBand if existed
if test -d $garageband
    then UninstallGarageBand
else NoGarageBandInstallation
fi

# Uninstall Pages if existed
if test -d $pages
    then UninstallPages
else NoPagesInstallation
fi

# Uninstall Numbers if existed
if test -d $numbers
    then UninstallNumbers
else NoNumbersInstallation
fi

# Uninstall Keynote if existed
if test -d $keynote
    then UninstallKeynote
else NoKeynoteInstallation
fi

# Closing script
echo "$(date) | Done. Closing script..."
exit 0
