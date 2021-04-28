#!/bin/bash
#set -x

############################################################################################
##
## Script to install LaunchDaemon to schedule a MDATP Quick Scan
##
## Note: Edit plist to change time/date.
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
log="/var/log/schedquickscan.log"
plistname="com.microsoft.mdatp.schedquickscan"
plistfile="/Library/LaunchDaemons/com.microsoft.mdatp.schedquickscan.plist"
exec 1>> $log 2>&1

if test -f "$plistfile"; then
    echo "$(date) - Found existing $plistfile"
    echo "$(date) - Unloading $plistname"
    launchctl unload $plistfile
    echo "$(date) - Removing $plistfile"
    rm -rf $plistfile
fi

echo "$(date) - Installing new $plistfile"
cat > $plistfile <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.microsoft.mdatp.schedquickscan</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>-c</string>
		<string>/usr/local/bin/mdatp scan quick</string>
	</array>
	<key>RootDirectory</key>
	<string>/usr/local/bin</string>
	<key>StartCalendarInterval</key>
	<dict>
		<key>Hour</key>
		<integer>3</integer>
		<key>Minute</key>
		<integer>0</integer>
	</dict>
	<key>WorkingDirectory</key>
	<string>/usr/local/bin</string>
</dict>
</plist>
EOF

echo "$(date) - Loading $plistfile"
launchctl load $plistfile

echo "$(date) - Starting $plistname"
launchctl start $plistname

exit 0
