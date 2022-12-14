#!/bin/bash

#############################################################################################################################
################### CUSTOM INPUT VARIABLES
#############################################################################################################################

# Set this variable to either enable or disable real-time protection.
REALTIME=enabled

# Set this variable to an int between 1-64 to configure parallelism for on-demand scans.
ON_DEMAND_PARALLEL=2

# Set this variable to enable or disable archive scanning for on-demand scans. 
SCAN_ARCHIVES=enabled

# Set this variable to enable or disable automatic security intelligence updates.
AUTO_DEFINITIONS_UPDATE=enabled

# Set this variable to enable or disable cloud protection.
CLOUD=enabled

# Set this variable to enable or disable automatic sample submission.
AUTO_SAMPLE_SUB=enabled

# Set this variable to enable or disable mdproduct diagnostics.
CLOUD_DIAGNOSTIC=enabled

# Set this variable log level to either error, warning, info or verbose. 
LOG_LEVEL=error

# Set this variable to the path(s) for desired diagnostic logs.
CREATE_DIAGNOSTIC=

# Set this variable to the path(s) of all folders excluded from scans. 
FOLDER_PATHS=(
    "/path1"
    "/path2"
    "/path3"
    )

# Set this variable to the path(s) of all files excluded from scans.
FILE_PATHS=(
    "/path1"
    "/path2"
    "/path3"
    )

# Set this variable to the file extension(s) excluded from scans. 
FILE_EXTENSIONS=(
    ".txt"
    ".sh"
    ".url"
    )

# Set this variable to the processes excluded from scans. 
PROCESSES=(
    "bash"
    "p2"
    "p3"
    )

# Set this variable to the threat(s) permitted. 
THREATS=(
    "threat1"
    "threat2"
    )

# Set both of these variables to for PUA protection type and protection action. 
    # Possible types include: potentially_unwanted_application and archive_bomb
    # Possible actions include off, audit, and block
    PUA_TYPE=potentially_unwanted_application
    PUA_ACTION=block

# Set this variable to enable or disable antivirus passive mode.
ANTIVIRUS_PMODE=enabled

# Set this variable to enable or disable scans after security intelligence updates.
AFTER_DEF_UPDATE=enabled

#############################################################################################################################
################### CHECK FOR PROPER VARIABLE STATUS 
#############################################################################################################################

# REALTIME
if [[ -z $REALTIME || ($REALTIME != "disabled" && $REALTIME != "enabled") ]]; then
    echo "Real-time protection settings have not been updated or have been set to something other than the allowed values (enabled, disabled). Please correct."
    exit 1
fi

# ON DEMAND PARALLEL
if ! [[ $ON_DEMAND_PARALLEL =~ ^[0-9]+$ && $ON_DEMAND_PARALLEL -ge 1 && $ON_DEMAND_PARALLEL -le 64 ]]; then
    echo "On-demand parallel settings have been set to something other than the accepted values (integer between 1-64). Please correct."  
    exit 1
fi 

# SCAN ARCHIVES
if [[ -z $SCAN_ARCHIVES || ($SCAN_ARCHIVES != "disabled" && $SCAN_ARCHIVES != "enabled") ]]; then
    echo "Scan-archive protection settings have not been updated or have been set to something other than the allowed values (enabled, disabled). Please correct."
    exit 1
fi

# AUTO DEFINITIONS UPDATE
if [[ -z $AUTO_DEFINITIONS_UPDATE || ($AUTO_DEFINITIONS_UPDATE != "disabled" && $AUTO_DEFINITIONS_UPDATE != "enabled") ]]; then
    echo "Automatic security intelligence update settings have not been updated or have been set to something other than the allowed values (enabled, disabled). Please correct."
    exit 1
fi

# CLOUD
if [[ -z $CLOUD || ($CLOUD != "disabled" && $CLOUD != "enabled") ]]; then
    echo "Cloud protection settings have not been updated or have been set to something other than the allowed values (enabled, disabled). Please correct."
    exit 1
fi

# AUTO SAMPLE SUB
if [[ -z $AUTO_SAMPLE_SUB || ($AUTO_SAMPLE_SUB != "disabled" && $AUTO_SAMPLE_SUB != "enabled") ]]; then
    echo "Automatic sample submission settings have not been update or have been set to something other than the allowed values (enabled, disabled). Please correct."
    exit 1
fi

# CLOUD DIAGNOSTIC
if [[ -z $CLOUD_DIAGNOSTIC || ($CLOUD_DIAGNOSTIC != "disabled" && $CLOUD_DIAGNOSTIC != "enabled") ]]; then
    echo "MDProduct diagnostic settings have not been updated or have been set to something other than the allowed values (enabled, disabled). Please correct."
    exit 1
fi

# LOG LEVEL
if [[ -z $LOG_LEVEL || ($LOG_LEVEL != "error" && $LOG_LEVEL != "warning" && $LOG_LEVEL != "verbose" && $LOG_LEVEL != "info") ]]; then
    echo "Log level settings have not been updated or have been set to something other than the allowed values (error, warning, info). Please correct."
    exit 1
fi

# CREATE DIAGNOSTIC
if [[ -z $CREATE_DIAGNOSTIC ]]; then
    echo "Diagnostic log settings have not been updated. Please correct."
    exit 1
fi

# PUA TYPE
if [[ -z $PUA_TYPE || ($PUA_TYPE != "potentially_unwanted_application" && $PUA_TYPE != "archive_bomb") ]]; then
    echo "PUA type settings have not been updated or have been set to something other than the allowed values (potentually_unwanted_application, archive_bomb). Please correct."
    exit 1
fi

# PUA ACTION
if [[ -z $PUA_ACTION || ($PUA_ACTION != "off" && $PUA_ACTION != "audit" && $PUA_ACTION != "block") ]]; then
    echo "PUA action settings have not been updated or have been set to something other than the allowed values (off, audit, block). Please correct."
    exit 1
fi

# ANTIVIRUS PASSIVE MODE
if [[ -z $ANTIVIRUS_PMODE || ($ANTIVIRUS_PMODE != "disabled" && $ANTIVIRUS_PMODE != "enabled") ]]; then
    echo "Antivirus passive mode settings have not been updated or have been set to something other than the allowed values (enabled, disabled). Please correct."
    exit 1
fi

# AFTER DEF UPDATE
if [[ -z $AFTER_DEF_UPDATE || ($AFTER_DEF_UPDATE != "disabled" && $AFTER_DEF_UPDATE != "enabled") ]]; then
    echo "After security intelligence update settings have not been updated or have been set to something other than the allowed values (enabled, disabled). Please correct."
    exit 1
fi

#############################################################################################################################
################### SCRIPT 
#############################################################################################################################

# These are files, folders, processes, etc that Microsoft warns against excluding: 
# https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/common-exclusion-mistakes-microsoft-defender-antivirus?view=o365-worldwide


MSFT_FOLDER_WARNING=(
    "%systemdrive%" 
    "C:"
    "C:\*"
    "%ProgramFiles%\Java" 
    "C:\Program Files\Java"
    "%ProgramFiles%\Contoso\*" 
    "C:\Program Files\Contoso\*"
    "%ProgramFiles(x86)%\Contoso\*"
    "C:\Program Files (x86)\Contoso\*"
    "C:\Temp" 
    "C:\Temp\*"
    "C:\Users\*"
    "C:\Users\<UserProfileName>\AppData\Local\Temp\*"
    "C:\Users\<UserProfileName>\AppData\LocalLow\Temp\*"
    "%Windir%\Prefetch"
    "C:\Windows\Prefetch"
    "C:\Windows\Prefetch\*"
    "%Windir%\System32\Spool"
    "C:\Windows\System32\Spool"
    "C:\Windows\System32\CatRoot2"
    "%Windir%\Temp"
    "C:\Windows\Temp"
    "C:\Windows\Temp\*"
    "/"
    "/bin"
    "/sbin"
    "/usr/lib"
)

MSFT_FILE_EXT_WARNING=(
    ".7z"   
    ".bat"
    ".bin"
    ".cab"
    ".cmd"
    ".com"
    ".cpl"
    ".dll"
    ".exe"
    ".fla"
    ".gif"
    ".gz"
    ".hta"
    ".inf"
    ".java"
    ".jar"
    ".job"
    ".jpeg"
    ".jpg"
    ".js"
    ".ko"
    ".ko.gz"
    ".msi"
    ".ocx"
    ".png"
    ".ps1"
    ".py"
    ".rar"
    ".reg"
    ".scr"
    ".sys"
    ".tar"
    ".tmp"
    ".url"
    ".vbe"
    ".vbs"
    ".wsf"
    ".zip"
)

MSFT_PROCESS_WARNING=(
    "bash"
    "java"
    "python"
    "python3"
    "sh"
    "zsh"
    "AcroRd32.exe"
    "addinprocess.exe"
    "addinprocess32.exe"
    "addinutil.exe"
    "bash.exe"
    "bginfo.exe"
    "bitsadmin.exe"
    "cdb.exe"
    "csi.exe"
    "dbghost.exe"
    "dbgsvc.exe"
    "dnx.exe"
    "dotnet.exe"
    "excel.exe"
    "fsi.exe"
    "fsiAnyCpu.exe"
    "iexplore.exe"
    "java.exe"
    "kd.exe"
    "lxssmanager.dll"
    "msbuild.exe"
    "mshta.exe"
    "ntkd.exe"
    "ntsd.exe"
    "outlook.exe"
    "psexec.exe"
    "powerpnt.exe"
    "powershell.exe"
    "rcsi.exe"
    "svchost.exe"
    "schtasks.exe"
    "system.management.automation.dll"
    "windbg.exe"
    "winword.exe"
    "wmic.exe"
    "wuauclt.exe"
)

# Recommended that this script be run using root privileges: 
echo "It is recommended that this script is run with root privileges. Please type the following or contact your administration: sudo -s"

# Start of a bash "try-catch loop" that will safely exit the script if a command fails or causes an error. 
(
    # Set the error status
    set -e   
            
    # Real Time Protection (Default: Not configured)
        # The three possible settings for enforcement are on demand, real-time, and passive.
            # Real time: real time protection enabled. 
            # On demand: files scanned only on demand. 
            # Passive: real time protetion disabled; on demand scanning is on; automatic threat mediation is off; security intelligence updates are on; status menu icon is hidden

        # Enable or disable real-time protection.
        mdatp config real-time-protection --value $REALTIME  
        echo "Real time protection settings have been updated."

        #  Configure parallelism for on-demand scans. The --value (2) is a numerical value between 1 and 64.
        mdatp config maximum-on-demand-scan-threads --value $ON_DEMAND_PARALLEL
        echo "Parallelism settings for on-demand scans have been updated."

        # Enable or disable archive scanning for on-demand scans.
        mdatp config scan-archives--value $SCAN_ARCHIVES 
        echo "On-demand archive scanning settings have been updated."

        # Cancel an on-going on demand scan. 
        mdatp scan cancel 
        echo "The ongiong on demand scan has been cancelled."

        # Enable or disable automatic security intelligence updates
        mdatp config automatic-definitions-update --value $AUTO_DEFINITIONS_UPDATE
        echo "Automatic security intelligence settings have been updated."

    # Cloud Delivered Protection (Default: Not configured)
        # Enable or disable cloud protection
        mdatp config cloud --value $CLOUD
        echo "Cloud delivered protection settings have been updated."

    # Automatic Sample Submission (Default: Not configured)
        # Enable or disable automatic sample submission
        mdatp config cloud-automatic-sample-submission --value $AUTO_SAMPLE_SUB
        echo "Automatic samlpe submission settings have been updated."

    # Diagnostic Data Collection (Default: Not configured)
        # Enable or disable mdproduct diagnostics
        mdatp config cloud-diagnostic --value $CLOUD_DIAGNOSTIC
        echo "Diagnostic data collection settings have been updated."

        # Alter the log level (options are error, warning, info, or verbose)
        mdatp log level set --level $LOG_LEVEL
        echo "Log level settings have been updated."

        # Generate diagnostic logs (using a path directory)
        mdatp diagnostic create $CREATE_DIAGNOSTIC
        echo "A diagnostic log has been created."

    # Folders Excluded From Scan

        # This method does 2 things: 1) it warns the user if they are excluding something MSFT recommends not excluding
                                # 2) it does exclude the requsted file, path, process, etc. 

        for i in "${FOLDER_PATHS[@]}"; do
            for j in "${MSFT_FOLDER_WARNING[@]}"; do
                if [ "$i" == "$j" ]; then
                    echo "WARNING: you have included a folder that violates Microsoft exclusion recommendations."
                fi
            done
                mdatp exclusion folder add --path $i
                echo "Folder exclusion settings have been updated. The following folder has been excluded: " $i"."
        done

    # Files Excluded From Scan
        for i in "${FILE_PATHS[@]}"; do
            mdatp exclusion file add --path $i
            echo "File exclusion settings have been updated. The following file has been excluded: " $i"."
        done


    # File Types Excluded From Scan
        for i in "${FILE_EXTENSIONS[@]}"; do
            for j in "${MSFT_FILE_EXT_WARNING[@]}"; do
                if [ "$i" == "$j" ]; then
                    echo "WARNING: you have included a file extension that violates Microsoft exclusion recommendations."
                fi
            done
                mdatp exclusion extension add --name $i
                echo "File type exclusion settings have been updated. The following file type has been excluded: " $i"."
        done

    # Process Excluded From Scan
        for i in "${PROCESSES[@]}"; do
            for j in "${MSFT_PROCESS_WARNING[@]}"; do
                if [ "$i" == "$j" ]; then
                    echo "WARNING: you have included a process that violates Microsoft exclusion recommendations."
                fi
            done
                mdatp exclusion process add --name $i
                echo "Process exclusion settings have been updated. The following process has been excluded: " $i"."
        done

    # Threats Permitted
        for i in "${THREATS[@]}"; do
            mdatp threat allowed add --name $i
            echo "Threat permissions have been updated. The following threat has been permitted: " $i"."
        done

    # Turn on PUA protection
        # Possible types include: potentially_unwanted_application and archive_bomb
        # Possible actions include off, audit, and block
        mdatp threat policy set --type $PUA_TYPE --action $PUA_ACTION
        echo "PUA protection settings have been updated."

    # Enable or disable antivirus passive mode
        mdatp config passive-mode --value $ANTIVIRUS_PMODE
        echo "Antivirus passive mode seetings have been updated."

    # Enable or disable scans after security intelligence updates
        mdatp config scan-after-definition-update --value $AFTER_DEF_UPDATE
        echo "After security intelligence scan settings have been updated."
)

ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    echo "There was an error. Please restart the script or contact your admin if the error persists."
    exit $ERROR_CODE
fi

# Final output message - to be configured TBD
echo "The script is finished running. The result will be sent in the necessary format."