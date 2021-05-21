#!/bin/bash
#set -x
OUTPUT='/Library/Logs/Microsoft/Intune/mdmDiagnose'

# Clean up and re-create output directory
sudo rm -r $OUTPUT
mkdir $OUTPUT

exec &> >(tee -a "${OUTPUT}/mdmDiagnose.log")

# Collect sysdiagnose logs
	# Prerequsites to collecting sysdiagnose logs for Apple:
		# Download ManagedClient debug mode mobileconfig - https://developer.apple.com/services-account/download?path=/OS_X/OS_X_Logs/ManagedClient.mobileconfig
		# sudo touch /var/db/MDM_LogConnectionDetails
# sysdiagnose logs cannot be collected from Intune Agent Log upload because the output will exceed the limit of 62914560 bytes
# sudo sysdiagnose -u -f $OUTPUT -A sysdiagnose

# Run mdmclient commands to gather MDM command outputs
echo "$(date) | Gathering QueryDeviceInformation Logs"
sudo /usr/libexec/mdmclient QueryDeviceInformation > ${OUTPUT}/DeviceInformation.txt
echo "$(date) | Gathering QueryInstalledProfiles Logs"
sudo /usr/libexec/mdmclient QueryInstalledProfiles > ${OUTPUT}/InstalledProfiles.txt
echo "$(date) | Gathering QueryCertificates Logs"
sudo /usr/libexec/mdmclient QueryCertificates > ${OUTPUT}/InstalledCerts.txt
echo "$(date) | Gathering QueryInstalledApps Logs"
sudo /usr/libexec/mdmclient QueryInstalledApps > ${OUTPUT}/InstalledApps.txt
echo "$(date) | Gathering QuerySecurityInfo Logs"
sudo /usr/libexec/mdmclient QuerySecurityInfo > ${OUTPUT}/SecurityInfo.txt

# Gather information from enrollment profile
echo "$(date) | Gathering Profiles Logs"
sudo /usr/bin/profiles status -type enrollment > ${OUTPUT}/enrollmentProfileInfo.txt

# Use 'log show' to gather mdmclient logs for the past 30 days
echo "$(date) | Gathering mdmclient Logs"
log show --last 30d --predicate 'process == "mdmclient" OR subsystem == "com.apple.ManagedClient" OR processImagePath contains "mdmclient"' > ${OUTPUT}/mdmclientLogs.txt

# Use 'log show' to gather app install logs for the past 30 days
echo "$(date) | Gathering StoreDownloadd Logs"
log show --last 30d --predicate 'processImagePath contains "storedownloadd" OR processImagePath contains "appstored"' > ${OUTPUT}/appInstallLogs.txt

# Copy ManagedClient logs for mdm logs
echo "$(date) | Gathering ManagedClient Logs"
cp /Library/Logs/ManagedClient/ManagedClient.log ${OUTPUT}

# Copy install.log for app install failures
echo "$(date) | Gathering install Logs"
cp /var/log/install.log ${OUTPUT}

# Copy system.log for past week. Major errors will be logged here
echo "$(date) | Gathering system Logs"
cp /var/log/system.log ${OUTPUT}
cp /var/log/system.log.0.gz ${OUTPUT}
cp /var/log/system.log.1.gz ${OUTPUT}
cp /var/log/system.log.2.gz ${OUTPUT}
cp /var/log/system.log.3.gz ${OUTPUT}
cp /var/log/system.log.4.gz ${OUTPUT}
cp /var/log/system.log.5.gz ${OUTPUT}

# Copy Intune Company Portal Logs from Users homedirectory
echo "$(date) | Gathering Company Portal Logs"
consoleuser=$(ls -l /dev/console | awk '{ print $3 }')
    if [[ $consoleuser ]]; then
		find "/Users/$consoleuser/Library/Logs/Company Portal/" -name '*.log' -exec cp "{}" ${OUTPUT}  \;

    else
		echo "Couldn't determine logged on user"
	fi


# Output log files created
echo "#######################################"
echo "##"
echo "## The following logs were created"
echo "##"
echo "#######################"
echo ""
find "$OUTPUT" -type f | tr '\n' ';'