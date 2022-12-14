#!/bin/zsh
#set -x

############################################################################################
##
## Script to enable FileVault
## 
## VER 0.0.1
##
## Change Log
##
## 2022-11-15   - First draft
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

# Get logged in user
USER=$(ls -l /dev/console | awk '{print $3}')

# Check if FileVault is already off - no need to run script if so

    if [[ $(sudo fdesetup isactive | grep "false") ]]; then

        echo "$(date) |  Filevault is not enabled, nothing to do"
        exit 0

    fi

if fdesetup status | grep -q Off; then
/usr/bin/osascript <<EOT
tell application "System Events"
activate
display dialog "FileVault is Off. Exiting" buttons {"OK"} default button 1
if button returned of result is "OK" then
end if
end tell
EOT
exit 0
fi

# Prompt user for credentials

PASS=$(/usr/bin/osascript <<EOT
tell application "System Events"
activate
display dialog "Please enter your computer login password to rotate the FileVault key:" default answer "" with hidden answer
if button returned of result is "OK" then
set pw to text returned of result
return pw
end if
if button returned of result is "Cancel" then
error number -128
end if
end tell
EOT)

# end script if no password is entered or cancel is pressed
if [ -z "$PASS" ]
then
exit 0
fi

# Use fdesetup to rotate the personal recovery key
# Grab result in to OUTPUT to check later.

OUTPUT=$(/usr/bin/expect <<EOT
spawn fdesetup changerecovery -personal
expect ":"
sleep 1
send -- {$USER}
send -- "
"
expect ":"
sleep 1
send -- {$PASS}
send -- "
"
expect "New*"
puts $expect_out(0,string)
return $expect_out
EOT)


# If the output has key = in it, then the key has been rotated
# Running a jamf recon will also submit this new key to jamf
echo $OUTPUT
if [ `echo $OUTPUT | grep -c "key =" ` -gt 0 ]
then 
/usr/bin/osascript <<EOT
tell application "System Events"
activate
display dialog "Recovery key was successfully rotated." buttons {"OK"} default button 1
if button returned of result is "OK" then
end if
end tell
EOT
else
# Most likely the password was wrong, but we can't be fully certain
/usr/bin/osascript <<EOT
tell application "System Events"
activate
display dialog "Your password was incorrect or some other error occurred. Please try again." buttons {"OK"} default button 1
if button returned of result is "OK" then
end if
end tell
EOT
fi