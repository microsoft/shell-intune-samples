#!/bin/zsh
#set -x
############################################################################################
##
## Script to ensure access to audit records is controlled
##
############################################################################################

## Copyright (c) 2023 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables
appname="ControlledAuditRecords"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"
log="$logandmetadir/$appname.log"

# Check if the log directory has been created
if [ -d $logandmetadir ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# Enable Security Auditing on macOS Sonoma
EnableSecurityAuditing() {
if [[ ! -e /etc/security/audit_control ]] && [[ -e /etc/security/audit_control.example ]];then
  /bin/cp /etc/security/audit_control.example /etc/security/audit_control
fi

/bin/launchctl enable system/com.apple.auditd
/bin/launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.auditd.plist
/usr/sbin/audit -i
echo  "$(date) | Security Auditing is enabled for devices running macOS Sonoma. Continuing..."
}

# Ensuring access to audit records is controlled
ControlledAuditRecords() {
/usr/sbin/chown -R root:wheel /etc/security/audit_control
/bin/chmod -R o-rw /etc/security/audit_control
/usr/sbin/chown -R root:wheel /var/audit/
/bin/chmod -R o-rw /var/audit/
echo  "$(date) | Access to audit records is now controlled or already controlled. Closing script..."
}

# Start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $appname"
echo "############################################################"
echo ""

# Run function
EnableSecurityAuditing
ControlledAuditRecords