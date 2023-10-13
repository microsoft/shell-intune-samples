#!/bin/zsh
#set -x

############################################################################################
##
## Script to perform onboarding operations
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

onboardingScriptsUrl="https://github.com/microsoft/shell-intune-samples/raw/master/macOS/Config/Swift%20Dialog/onboarding_scripts.zip" # Enter your own URL here
appname="onBoarding"                                                 
logandmetadir="/Library/Application Support/Microsoft/IntuneScripts/$appname"   # The location of our logs and last updated data
enrollmentWindowHours=1                                                         # The number of hours after enrollment that the script should run
checkEnrollmentTime=true                                                        # Should we check the enrollment time? (Do NOT set this to false in production!!)

# Generated variables
tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"                                               # The location of the script log file
metafile="$logandmetadir/$appname.meta"                                         # The location of our meta file (for updates)

logandmetadir="/Library/Application Support/Microsoft/IntuneScripts/onBoarding"

# Start logging
if [[ ! -d "$logandmetadir" ]]; then
    ## Creating Metadirectory
    echo "$(date) | Creating [$logandmetadir] to store logs"
    mkdir -p "$logandmetadir"
fi

echo "$(date) | Starting logging to [$logandmetadir/onboarding.log]"
exec > >(tee -a "$logandmetadir/onboard.log") 2>&1

echo "$(date) | Starting Enroll tasks..."
cd "$tempdir"

if [[ $checkEnrollmentTime == true ]]; then

    # Exit if we've run before or this machine was enrolled more than $enrollmentWindowHours ago
    echo "$(date) | Checking if we've run before..."
    if [ -e "/Library/Application Support/Microsoft/IntuneScripts/Swift Dialog/onboarding.flag" ]; then

        echo "$(date) |  + Script has already launched onboarding flow before. Skipping."
        exit 0

    else

        # We haven't run before, but is this a new enrollment?
        echo "$(date) | Checking how long ago this device was enrolled..."

        # Get the installation date of the MDM management profile
        profile_output=$(profiles -P -v | grep -A 10 "Management Profile")
        install_date=$(echo "$profile_output" | grep -oE 'installationDate:.*' | cut -d' ' -f2-)
        install_date_seconds=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$install_date" "+%s")
        echo "$(date) |  + MDM Profile install time [$install_date_seconds]"

        # Get the current time in seconds
        current_time_seconds=$(date "+%s")
        echo "$(date) |  + Current time [$current_time_seconds]"

        # Calculate the time difference in hours
        time_difference_hours=$(( (current_time_seconds - install_date_seconds) / 3600 ))
        echo "$(date) |  + Time difference [$time_difference_hours] hours"

        # Check if the difference is greater than $enrollmentWindowHours
        if [ "$time_difference_hours" -gt $enrollmentWindowHours ]; then
            echo "$(date) |  + Device was enrolled more than [$enrollmentWindowHours] hour(s) ago, skipping onboarding."
            mkdir -p '/Library/Application Support/Microsoft/IntuneScripts/Swift Dialog'
            touch '/Library/Application Support/Microsoft/IntuneScripts/Swift Dialog/onboarding.flag'
            exit 0
        else
            echo "$(date) |  + Device was enrolled less than [$enrollmentWindowHours] hour(s) ago, continuing onboarding."
        fi

    fi
fi

echo "$(date) | Checking if we need Rosetta 2 or not"

# Rosetta
ARCH=$(uname -m)

if [ "$ARCH" = "arm64" ]; then
    # This is an Apple Silicon Mac.
    echo "$(date) | Apple Silicon Mac detected."


    # Rosetta not installed...
    attempt_counter=0
    max_attempts=10

    until /usr/bin/pgrep oahd || [ $attempt_counter -eq $max_attempts ]; do
        attempt_counter=$(($attempt_counter+1))
        echo "$(date) | Attempting to install Rosetta, attempt number: $attempt_counter"
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        sleep 1
    done
    
    if [ $attempt_counter -eq $max_attempts ]; then
        echo "$(date) | Reached max attempts to install Rosetta, moving on..."
    fi

else
    echo "$(date) | This is not an Apple Silicon Mac. No action needed."
fi


#####################################
## Aria2c installation
#####################
ARIA2="/usr/local/aria2/bin/aria2c"
aria2Url="https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0-osx-darwin.dmg"
if [[ -f $ARIA2 ]]; then
    echo "$(date) | Aria2 already installed, nothing to do"
else
    echo "$(date) | Aria2 missing, lets download and install"
    filename=$(basename "$aria2Url")
    output="$tempdir/$filename"
    curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -o "$output" "$aria2Url"
    if [ $? -ne 0 ]; then
        echo "$(date) | Aria download failed"
        echo "$(date) | Output: [$output]"
        echo "$(date) | URL [$aria2Url]"
        exit 1
    else
        echo "$(date) | Downloaded aria2"
    fi

    # Mount aria2 DMG
    mountpoint="$tempdir/aria2"
    echo "$(date) | Mounting Aria DMG..."
    hdiutil attach -quiet -nobrowse -mountpoint "$mountpoint" "$output"
    if [ $? -ne 0 ]; then
        echo "$(date) | Aria mount failed"
        echo "$(date) | Mount: [$mountpoint]"
        echo "$(date) | Temp File [$output]"
        exit 1
    else
        echo "$(date) | Mounted DMG"
    fi
    
    # Install aria2 PKG from inside the DMG
    sudo installer -pkg "$mountpoint/aria2.pkg" -target /
    if [ $? -ne 0 ]; then
        echo "$(date) | Install failed"
        echo "$(date) | PKG: [$mountpoint/aria2.pkg]"
        exit 1
    else
        echo "$(date) | Aria2 installed"
        hdiutil detach -quiet "$mountpoint"
    fi

    rm -f "$output"

fi

downloadattempts=0
ariaExitCode=1
unzipExitCode=1

# Loop until the count is 5 or the exitCode is 0
while [[ $ariaExitCode -ne 0  && $unzipExitCode -ne 0 ]]; do
    # Increment count
    downloadattempts=$((downloadattempts + 1))
    echo "$(date) | Attempting to downloading scripts [$downloadattempts]..."
    # Attempt download of onboarding scripts
    $ARIA2 -x16 -s16 -d "$tempdir" -o "onboarding_scripts.zip" "$onboardingScriptsUrl" --download-result=hide --summary-interval=0
    ariaExitCode=$?

    if [[ $ariaExitCode -eq 0 ]]; then
        echo "$(date) | Unzipping scripts..."
        unzip -qq -o onboarding_scripts.zip
        unzipExitCode=$?
    fi

    if [[ $downloadattempts -gt 5 ]]; then
        echo "$(date) | Failed to download and unzip onboardingscripts after 5 attempts, exiting..."
        exit 1
    fi

done

# Moving icons and json file
swiftdialogfolder="/Library/Application Support/Microsoft/IntuneScripts/Swift Dialog"
echo "$(date) | Moving icons and json file to $swiftdialogfolder"
mkdir -p "$swiftdialogfolder"
mv "$tempdir/onboarding_scripts/icons" "$swiftdialogfolder/icons"
mv "$tempdir/onboarding_scripts/swiftdialog.json" "$swiftdialogfolder/swiftdialog.json"

# Launching Swift dialog
echo "$(date) | Starting Swift Dialog installation script"
nice -n -5 "$tempdir/onboarding_scripts/1-installSwiftDialog.zsh" & 

START=$(date +%s)

echo -n "$(date) | Waiting for Swift Dialog to Start..."
# Loop for 5 minutes (300 seconds)
until ps aux | grep /usr/local/bin/dialog | grep -v grep &>/dev/null; do
    # Check if the 5 minutes have passed
    if [[ $(($(date +%s) - $START)) -ge 300 ]]; then
        echo "$(date) | Failed: Swift Dialog did not start within 5 minutes"
        exit 1
    fi
    echo -n "."
    sleep 5
done
echo "OK"

#####################################
## Process Onboarding scripts
#####################

# Lets give Swift Dialog a chance to start
sleep 10

echo "$(date) | Processing scripts..."
for script in $tempdir/onboarding_scripts/scripts/*.*; do
  echo "$(date) | Executing [$script]"
  chmod +x "$script"
  nice -n 10 "$script" &
done

echo "$(date) | Waiting for all scripts to finish..."

