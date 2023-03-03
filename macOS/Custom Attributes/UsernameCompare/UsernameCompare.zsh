#!/bin/zsh
#set -x

# Script metadata
# ========================
# Description: Collects the Logged in user from the Intune SCEP Certificate & compares it to the logged in user on the Mac
# Description: Can also be used in other scripts to ensure the username passed in is the same as the AAD Record 
# Author: Adam Assaf
# Version: 1.0

# User Defined variables
domain="example.com"    # Change this to your domain
currentuser_cert=$(security find-certificate -a -m | grep "@$domain" | sed q | awk -F": " '{ print $2; }' | awk -F".$domain" '{ print $1; }')
currentuser=$(stat -f "%Su" /dev/console)
delay=$(( $RANDOM % 50 + 10 ))

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    exit 1
fi

# Wait for Desktop

until ps aux | grep /System/Library/CoreServices/Dock.app/Contents/MacOS/Dock | grep -v grep &>/dev/null; do
sleep $delay
done

#compare usernames between AAD & macOS

while [[ -z "$currentuser_cert" ]]; do 
  # echo "Waiting [$delay] seconds"
  sleep $delay
done

if [[ $currentuser_cert == $currentuser ]]; then 
  echo "Match | $currentuser_cert"
  #echo "Username on Mac: [$currentuser] matches SCEP User Certificate: [$currentuser_cert]"
else
  echo "Mismatch | $currentuser"
  #echo "Username on Mac: [$currentuser] doesn't match SCEP User Certificate: [$currentuser_cert]"
fi