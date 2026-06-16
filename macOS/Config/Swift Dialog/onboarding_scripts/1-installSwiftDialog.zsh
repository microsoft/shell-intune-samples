#!/bin/zsh
#set -x

############################################################################################
##
## Script to install Swift Dialog
## 
## VER 1.0.0
##
############################################################################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# User Defined variables

weburl="https://github.com/bartreardon/swiftDialog/releases/download/v2.2/dialog-2.2.0-4535.pkg"
swiftdialogJson='https://catlab.blob.core.windows.net/swiftdialog/catlab.json'
appname="Swift Dialog"                                                 
logandmetadir="/Library/Application Support/Microsoft/IntuneScripts/$appname"   # The location of our logs and last updated data
dialogWidth="1024"                                                               # Width of the dialog box
dialogHeight="500"                                                              # Height of the dialog box

# Generated variables
tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"                                               # The location of the script log file
metafile="$logandmetadir/$appname.meta"                                         # The location of our meta file (for updates)

#
# Start Logging
#
if [[ ! -d "$logandmetadir" ]]; then
    ## Creating Metadirectory
    echo "$(date) | Creating [$logandmetadir] to store logs"
    mkdir -p "$logandmetadir"
fi

exec > >(tee -a "$log") 2>&1


## Note, Rosetta detection code from https://derflounder.wordpress.com/2020/11/17/installing-rosetta-2-on-apple-silicon-macs/
OLDIFS=$IFS
IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"
IFS=$OLDIFS

if [[ ${osvers_major} -ge 11 ]]; then

    # Check to see if the Mac needs Rosetta installed by testing the processor

    processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | grep -o "Intel")
    
    if [[ -n "$processor" ]]; then
        echo "$(date) | $processor processor installed. No need to install Rosetta."
    else

        # Check for Rosetta "oahd" process. If not found,
        # perform a non-interactive install of Rosetta.
        
        if /usr/bin/pgrep oahd >/dev/null 2>&1; then
            echo "$(date) | Rosetta is already installed and running. Nothing to do."
        else
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        fi
    fi
    else
        echo "$(date) | Mac is running macOS $osvers_major.$osvers_minor.$osvers_dot_version."
        echo "$(date) | No need to install Rosetta on this version of macOS."
fi

#
# Start Download of Swift Dialog
#
echo "$(date) | Downloading $appname [$weburl]"
cd "$tempdir"
curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 --compressed -L -o "$tempdir/swiftdialog.pkg" "$weburl"

#
# Installing Swift Dialog
#
installer -pkg "$tempdir/swiftdialog.pkg" -target /

# Wait for Dock
until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep &>/dev/null; do
    echo "$(date) |  + Dock not running, waiting..."
    sleep 1
done
echo "$(date) | Dock is here, lets carry on"




#
# Launch Swift Dialog Onboarding
#

max_attempts=5  # Number of maximum attempts to attempt launching Swift Dialog

for ((attempt=1; attempt<=max_attempts; attempt++)); do

    touch /var/tmp/dialog.log
    chmod a+w /var/tmp/dialog.log

    /usr/local/bin/dialog --jsonfile "$logandmetadir/swiftdialog.json" --width $dialogWidth --height $dialogHeight

    # Check the exit status of Swift Dialog
    if [ $? -eq 0 ]; then
        echo "$(date) | Successfully launched $appname."
        # Write the flag file to indicate successful launch
        touch "$logandmetadir/onboarding.flag"
        break
    else
        echo "Attempt $attempt to launch $appname failed. Retrying..."
        # Add a sleep to wait before the next attempt (optional)
        sleep 5
    fi

done






