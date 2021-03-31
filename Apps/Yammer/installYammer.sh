#!/bin/bash
#set -x

############################################################################################
##
## Script to install the latest Yammer client
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

# Define variables
tempfile="/tmp/yammer.dmg"                                                  # What filename are we going to store the downloaded files in?
volume="/tmp/YAMMER"                                                        # Where are we going to mount the DMG?
weburl="https://neiljohn.blob.core.windows.net/macapps/yammer.dmg"          # What is the Azure Blob Storage URL?
appname="Yammer"                                                            # The name of our App deployment script
app="Yammer.app"                                                            # The actual name of our App once installed
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/installYammer"         # The location of our logs and last updated data
log="$logandmetadir/installyammer.log"                                      # The location of the script log file
metafile="$logandmetadir/$appname.meta"                                     # The location of our meta file (for updates)
processpath="/Applications/Yammer.app/Contents/MacOS/Yammer"                # The process name of the App we are installing
terminateprocess="false"                                                    # Do we want to terminate the running process? If false we'll wait until its not running

echo "# $(date) | Starting install of $appname"

# function to check if we need Rosetta 2
checkForRosetta2 () {

    echo "$(date) | Checking if we need Rosetta 2 or not"

    processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string)
    if [[ "$processor" == *"Intel"* ]]; then

        echo "$(date) | $processor processor detected, no need to install Rosetta."
        
    else

        echo "$(date) | $processor processor detected, lets see if Rosetta 2 already installed"

        # Check Rosetta LaunchDaemon. If no LaunchDaemon is found,
        # perform a non-interactive install of Rosetta.
        
        if [[ ! -f "/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist" ]]; then
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        
            if [[ $? -eq 0 ]]; then
                echo "$(date) | Rosetta has been successfully installed."
            else
                echo "$(date) | Rosetta installation failed!"
                exit 1
            fi
    
        else
            echo "$(date) | Rosetta is already installed. Nothing to do."
        fi
    fi

}

# function to check if app is running and either terminate or wait
isAppRunning () {

    while ps aux | grep $processpath | grep -v grep; do
      if [ $terminateprocess == "false" ]; then
        echo "$(date) | $app running, waiting..."
        sleep 60
      else
        echo "$(date) | $app running, terminating [$processpath]..."
        pkill -f $processpath
      fi
    done

    echo "$(date) | $app isn't running, lets carry on"

}

# generate the last modified date of the file we need to download
lastmodified=$(curl -sIL "$weburl" | grep -i "last-modified" | awk '{$1=""; print $0}' | awk '{ sub(/^[ \t]+/, ""); print }' | tr -d '\r')

## Check if the log directory has been created
if [ -d $logandmetadir ]; then
    ## Already created
    echo "# $(date) | Logging to - $logandmetadir"
else
    ## Creating Metadirectory
    echo "# $(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# start logging
exec 1>> $log 2>&1    # Comment out this line to stop logging to a file.

# Begin Script Body

echo ""
echo "##############################################################"
echo "# $(date) | Starting install of $appname"
echo "############################################################"
echo ""

# Check if we need Rosetta 2
checkForRosetta2

## Is the app already installed?
if [ -d "/Applications/$app" ]; then

  # App is already installed, we need to determine if it requires updating or not
  echo "$(date) | $appname already installed"
  
  ## Let's determine when this file we're about to download was last modified
  echo "$(date) | $weburl last update on $lastmodified"

  ## Did we store the last modified date last time we installed/updated?
  if [ -d $logandmetadir ]; then

      echo "$(date) | Looking for metafile ($metafile)"
      if [ -f "$metafile" ]; then
        previouslastmodifieddate=$(cat "$metafile")
        if [[ "$previouslastmodifieddate" != "$lastmodified" ]]; then
          echo "$(date) | Update found, previous [$previouslastmodifieddate] and current [$lastmodified]"
          install="yes"
        else
          echo "$(date) | No update between previous [$previouslastmodifieddate] and current [$lastmodified]"
          exit 0
        fi
      else
        echo "$(date) | Meta file $metafile notfound, downloading anyway"
        install="yes"
      fi
      
  fi

else

  # App isn't installed, lets download and get ready for install
  install="yes"

fi



#check if we're downloading and installing
if [ $install == "yes" ]; then

    #download the file
    echo "$(date) | Downloading $appname"
    curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -o $tempfile $weburl
    if [ $? == 0 ]; then
         echo "$(date) | Downloaded $weburl to $tempfile"
    else
    
         echo "$(date) | Failure to download $weburl to $tempfile"
         exit 1
    fi

    
    # Check if app is running, if it is we need to wait.
    isAppRunning


    echo "$(date) | Installing $appname"

    # Mount the dmg file...
    echo "$(date) | Mounting $tempfile to $volume"
    hdiutil attach -quiet -nobrowse -mountpoint $volume $tempfile

    # Sync the application and unmount once complete
    echo "$(date) | Copying $volume/*.app to /Applications/$app"
    cp -Rf "$volume"/*.app/ "/Applications/$app"

    # Unmount the dmg
    echo "$(date) | Un-mounting $volume"
    hdiutil detach -quiet "$volume"

    # Checking if the app was installed successfully
    if [ "$?" = "0" ]; then
        if [[ -a "/Applications/$app" ]]; then

            echo "$(date) | $appname Installed"
            echo "$(date) | Cleaning Up"
            rm -rf $tempfile

            echo "$(date) | Writing last modifieddate $lastmodified to $metafile"
            echo "$lastmodified" > "$metafile"

            echo "$(date) | Fixing up permissions"
            sudo chown -R root:wheel "/Applications/$app"
            echo "$(date) | Application [$appname] succesfully installed"
            exit 0
        else
            echo "$(date) | Failed to install $appname"
            exit 1
        fi
    else

        # Something went wrong here, either the download failed or the install Failed
        # intune will pick up the exit status and the IT Pro can use that to determine what went wrong.
        # Intune can also return the log file if requested by the admin
        
        echo "$(date) | Failed to install $appname"
        exit 1
    fi

else
    echo "$(date) | Not downloading or installing $appname"
fi
