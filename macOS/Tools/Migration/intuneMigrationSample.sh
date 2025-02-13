#!/bin/bash

#########################################################################################################
#                                                                                                       #
#                                  Microsoft Script Disclaimer                                          #
#                                                                                                       #
# This script is provided "AS IS" without warranty of any kind. Microsoft disclaims all implied         #
# warranties, including, without limitation, any implied warranties of merchantability or fitness       #
# for a particular purpose. The entire risk arising out of the use or performance of this script        #
# and associated documentation remains with you. In no event shall Microsoft, its authors, or any       #
# contributors be liable for any damages whatsoever (including, but not limited to, damages for         #
# loss of business profits, business interruption, loss of business information, or other pecuniary     #
# loss) arising out of the use of or inability to use this script or documentation, even if             #
# Microsoft has been advised of the possibility of such damages.                                        #
#                                                                                                       #
# Feedback: neiljohn@microsoft.com                                                                      #
#                                                                                                       #
#########################################################################################################

# Script: intuneMigration.sh
# -------------------------------------------------------------------------------------------------------
# Description:
# This script removes the Jamf framework from a Mac and prepares the device for migration to Microsoft 
# Intune. It prompts the user to start the migration process, removes the Jamf framework, installs the 
# Microsoft Intune Company Portal app (if needed), checks if the device is ADE-enrolled, and renews 
# profiles as necessary.
# -------------------------------------------------------------------------------------------------------
# Dependencies:
# - ADE: Device must be assigned to Intune before beginning the migration process
# - This script just handles the removal of Jamf and either starting setup assistant or Company Portal
#   for the user to complete migration. The onboarding process should be configured in Intune separately.
#########################################################################################################

# Replace these with your Jamf Pro details
JAMF_PRO_URL="https://yourenvironment.jamfcloud.com"  # URL of your Jamf Pro server
USERNAME="migration_account"                          # This should be a Jamf Pro user with the Jamf Pro Server Action 'Send Computer Unmanage Command' enabled and Jamf Pro Server Objects 'Computers' Read.
PASSWORD="migration_account_password"                 # Password for the above user
LOG="/Library/Logs/Microsoft/IntuneScripts/intuneMigration/intuneMigration.log"
JAMF_API_VERSION="new"     # Set to "classic" for (JSSResource) or new for (api) to use the classic or new API

# Function to check if the device is managed by Jamf
check_if_managed() {
  if profiles -P | grep -q "com.jamfsoftware"; then
    echo "Device is managed by Jamf."
  else
    echo "Device is not managed by Jamf. Exiting script."
    exit 0
  fi
}

function startLog() {

    ###################################################
    ###################################################
    ##
    ##  Start logging - Output to log file and STDOUT
    ##
    ####################
    ####################

    LOG_DIR=$(dirname "$LOG")  # Extract the directory path from the LOG file path

    if [[ ! -d "$LOG_DIR" ]]; then
        ## Creating log directory
        echo "$(date) | Creating directory [$LOG_DIR] to store logs"
        mkdir -p "$LOG_DIR"
    fi

    exec > >(tee -a "$LOG") 2>&1
}

# Function to check and install swiftDialog if not present
install_swiftDialog() {
  if [ ! -f "/usr/local/bin/dialog" ]; then
    echo "swiftDialog not found. Installing swiftDialog..."
    curl -L -o /tmp/dialog.pkg "https://github.com/swiftDialog/swiftDialog/releases/download/v2.5.2/dialog-2.5.2-4777.pkg"
    sudo installer -pkg /tmp/cp.pkg -target /
    rm /tmp/cp.pkg
    echo "swiftDialog installed successfully."
  else
    echo "swiftDialog is already installed."
  fi
}

# Function to check and install Company Portal if not present
install_cp() {
  if [ ! -f "/Applications/Company Portal.app" ]; then
    echo "Company Portal not found. Installing Company Portal..."
    curl -L -o /tmp/cp.pkg "https://go.microsoft.com/fwlink?linkid=853070"
    sudo installer -pkg /tmp/dialog.pkg -target /
    rm /tmp/dialog.pkg
    echo "Company Portal installed successfully."
  else
    echo "Company Portal is already installed."
  fi
}

# Function to display message to sign in to Company Portal
cp_sign_in_message() {
  /usr/local/bin/dialog \
    --bannertitle "Action Required: Sign in to Company Portal" \
    --message "To complete your device setup, you must sign in to the Company Portal app using your **Entra (Microsoft)** credentials.\n\nFailure to sign in to Company Portal will result in the loss of access to corporate resources such as **e-Mail** and **other essential services**.\n\nWhen you close this dialog, Company Portal will be open your screen, click **Sign-in** and complete the process to avoid service disruptions." \
    --button1text "Got it" \
    --blurscreen \
    --bannerimage colour=blue \
    --titlefont shadow=1 \
    --width 750 \
    --height 450 \
    --icon /Applications/Company\ Portal.app/Contents/Resources/AppIcon.icns
}

# Function to display "Waiting for Intune" message with spinner
waiting_for_intune() {
  /usr/local/bin/dialog \
    --bannertitle "Status: Waiting for Intune" \
    --message "Your device setup is in progress.\n\nWe're currently waiting for Intune to complete the necessary setup. This may take a few minutes.\n\nPlease keep this window open until setup is complete." \
    --blurscreen \
    --bannerimage colour=blue \
    --titlefont shadow=1 \
    --progress \
    --width 750 \
    --height 450 \
    --icon /Applications/Company\ Portal.app/Contents/Resources/AppIcon.icns \
    --no-buttons \
    --progress &
  
  # Capture the dialog process ID to close it later if needed
  DIALOG_PID=$!
}

# Function to display message for ADE enrollment
ade_enrollment_message() {
  /usr/local/bin/dialog \
    --bannertitle "Action Required: Complete Device Enrollment" \
    --message "Your device is **ADE-enrolled** and requires additional setup to complete enrollment into **Intune**.\n\nPlease follow the setup assistant screens to sign in with your **Entra (Microsoft)** credentials. This process is necessary to gain access to corporate resources, including **e-Mail** and other essential services.\n\nWhen you close this dialog, the setup assistant will open. Follow the prompts to complete the enrollment process." \
    --button1text "Got it" \
    --blurscreen \
    --bannerimage colour=blue \
    --titlefont shadow=1 \
    --width 750 \
    --height 450 \
    --icon /Applications/Company\ Portal.app/Contents/Resources/AppIcon.icns
}

# Function to prompt the user to start the migration
prompt_migration() {

  # Display the dialog with improved message text
  /usr/local/bin/dialog \
    --bannertitle "Prepare for Device Migration" \
    --message "Your device is scheduled to be migrated from **Jamf** to **Microsoft Intune**.\n\nThis process will take approximately **20 minutes**, during which you will **not be able to use your Mac**." \
    --button1text "Migrate" \
    --button2text "Exit" \
    --blurscreen \
    --bannerimage colour=blue \
    --titlefont shadow=1 \
    --width 750 \
    --height 450 \
    --icon /Applications/Company\ Portal.app/Contents/Resources/AppIcon.icns

  # Check which button was clicked based on the exit code
  if [[ "$?" -eq 0 ]]; then
    echo "User is ready to start the migration."
    return 0  # Proceed with migration
  else
    echo "User chose not to migrate at this time."
    exit 1  # Exit the script
  fi
}

# Function to start the migration dialog in progress mode
start_progress_dialog() {
  COMMAND_FILE="/tmp/dialog_command"
  echo "Initializing migration..." > "$COMMAND_FILE"
  
  /usr/local/bin/dialog \
    --bannertitle "Device Migration in Progress" \
    --icon /Applications/Company\ Portal.app/Contents/Resources/AppIcon.icns \
    --bannerimage colour=blue \
    --titlefont shadow=1 \
    --message "Your device is being migrated from Jamf to Microsoft Intune. Please do not power off or disconnect your device during this process." \
    --blurscreen \
    --force \
    --no-buttons \
    --progress \
    --width 750 \
    --height 450 \
    --commandfile "$COMMAND_FILE" &
  
  DIALOG_PID=$!
}

# Function to update the dialog progress bar and text via the command file
update_progress() {
  local progress_value="$1"
  local progress_text="$2"
  
  # Write the progress value and text separately to the command file
  echo "progress: $progress_value" > "$COMMAND_FILE"
  echo "progresstext: $progress_text" >> "$COMMAND_FILE"
  
  # Add a small delay to ensure swiftDialog processes each update properly
  sleep 1
}

# Function to completely remove Jamf framework
remove_jamf_framework() {
  update_progress 50 "Removing Jamf framework..."
  if command -v jamf >/dev/null 2>&1; then
    sudo jamf removeFramework
    if [ $? -eq 0 ]; then
      echo "Jamf framework removed from the Mac."
    else
      echo "Failed to remove Jamf framework."
    fi
  else
    echo "Jamf binary not found; it may have already been removed."
  fi
}

# Function to check if the device is ADE enrolled
check_ade_enrollment() {
  echo "Checking if the device is ADE enrolled..."

  # Run profiles status to check for DEP enrollment
  ade_status=$(profiles status -type enrollment 2>/dev/null | grep -i "Enrolled via DEP: Yes")

  if [ -n "$ade_status" ]; then
    echo "Device is ADE enrolled."
    ADE_ENROLLED=true
  else
    echo "Device is not ADE enrolled."
    ADE_ENROLLED=false
  fi
}

launch_company_portal() {
  # Open the Company Portal app
  open -a "/Applications/Company Portal.app"
  
  # Bring Company Portal to the front
  osascript <<EOF
    tell application "Company Portal" to activate
EOF
}

# Function to renew profiles if the device is ADE enrolled
renew_profiles() {
  sudo profiles renew -type enrollment
  echo "Profiles renewed."
}

# Function to get the serial number of the current Mac
get_serial_number() {
  system_profiler SPHardwareDataType | awk '/Serial Number/ {print $4}'
}

# Function to obtain an authentication token
get_auth_token() {
  auth_token=$(curl -su "$USERNAME:$PASSWORD" -X POST "$JAMF_PRO_URL/api/v1/auth/token" | jq -r '.token')
  echo "$auth_token"
}

# Function to get the computer_id from Jamf Pro based on serial number
get_computer_id() {
  local serial_number="$1"
  local auth_token="$2"
  
  computer_id=$(curl -s -X GET \
    -H "Authorization: Bearer $auth_token" \
    "$JAMF_PRO_URL/api/v1/computers-inventory?filter=hardware.serialNumber==$serial_number" | jq -r '.results[0].id')
  echo "$computer_id"
}

# Function to unmanage from Jamf Pro using new API
unmanage_device_jamf_new() {
    echo "DEBUG: Unmanaging device with computer ID: $computer_id" >&2
    echo "$JAMF_PRO_URL/api/v1/computer-inventory/$computer_id/remove-mdm-profile"
    local computer_id="$1"
    local auth_token="$2"

    echo "DEBUG: Unmanaging device with computer ID: $computer_id" >&2
    echo "$JAMF_PRO_URL/api/v1/computer-inventory/$computer_id/remove-mdm-profile"

    local response
    response=$(curl -s -X POST \
      -H "Authorization: Bearer $auth_token" \
      "$JAMF_PRO_URL/api/v1/computer-inventory/$computer_id/remove-mdm-profile")
      
    echo "DEBUG: unmanage_device response: $response" >&2

    if echo "$response" | jq -e '.commandUuid' >/dev/null; then
        echo "Device successfully unmanaged (MDM profile removed). Command UUID: $(echo "$response" | jq -r '.commandUuid')"
    else
        echo "Failed to unmanage device: $response" >&2
        exit 1
    fi
}

# Function to unmanage from Jamf Pro using classic API
unmanage_device_jamf_classic() {
  echo "DEBUG: Unmanaging device with computer ID: $computer_id" >&2
  echo "$JAMF_PRO_URL/JSSResource/computercommands/command/UnmanageDevice/id/$computer_id"
    local computer_id="$1"
    local auth_token="$2"
 
    local response
 
    # Classic API
    response=$(curl -s -X POST \
      -H "Authorization: Bearer $auth_token" \
      "$JAMF_PRO_URL/JSSResource/computercommands/command/UnmanageDevice/id/$computer_id")
 
    echo "DEBUG: unmanage_device response: $response" >&2
 
    # Parse the XML response using xmllint to extract the command UUID.
    local command_uuid
    command_uuid=$(echo "$response" | xmllint --xpath 'string(//command_uuid)' - 2>/dev/null)
 
    if [[ -n "$command_uuid" ]]; then
        echo "Device successfully unmanaged (MDM profile removed). Command UUID: $command_uuid"
    else
        echo "Failed to unmanage device: $response" >&2
        exit 1
    fi
}

# Function to wait until management profile is removed...
wait_for_management_profile_removal() {
  echo "Waiting for MDM management profile removal..."
  local timeout=300
  local interval=5
  local elapsed=0

  while true; do
    # Capture the enrollment profiles output.
    local output
    output=$(profiles show type -enrollment 2>/dev/null)

    # Check if there are no enrollment profiles or if the MDM payload is missing.
    if echo "$output" | grep -q "There are no configuration profiles installed" || \
       ! echo "$output" | grep -q "com.apple.mdm"; then
      echo "MDM management profile successfully removed."
      break
    else
      echo "MDM management profile still present. Retrying in ${interval} seconds..."
    fi

    sleep "${interval}"
    elapsed=$((elapsed + interval))
    if [ $elapsed -ge $timeout ]; then
      echo "Timeout waiting for management profile removal." >&2
      exit 1
    fi
  done
}

############################################################
##
## Main Script Execution Begins Here
##
#########################################

# Start Logging before we do anything else...
startLog

# 1. Check if device is Jamf-managed
check_if_managed

# 2. Install dependencies if needed
install_swiftDialog
install_cp

# 3. Prompt user to migrate
prompt_migration  # If they exit here, we do nothing and exit

# 6. Start migration dialog
start_progress_dialog

# 4. Now that user has agreed, fetch Jamf API details
serial_number=$(get_serial_number)
echo "Serial Number: $serial_number"
auth_token=$(get_auth_token)
echo "Auth Token: $auth_token"
computer_id=$(get_computer_id "$serial_number" "$auth_token")
echo "Computer ID: $computer_id"

# 5. If computer_id is found, unmanage and remove Jamf
if [ -n "$computer_id" ]; then
# Call unmanage function based on API version using case statement
  case $JAMF_API_VERSION in
      classic)
          unmanage_device_jamf_classic "$computer_id" "$auth_token"
          
          ;;
      new)
          unmanage_device_jamf_new "$computer_id" "$auth_token"
          ;;
      *)
          echo "Error: Invalid JAMF_API_VERSION specified. Must be 'classic' or 'new'" >&2
          exit 1
          ;;
  esac
else
    echo "Computer ID not found for Serial Number: $serial_number"
    exit 1
fi

# Wait for management profile to be removed
wait_for_management_profile_removal

# 7. Check if ADE enrolled
check_ade_enrollment

# 8. If ADE enrolled, show message + renew profiles; else prompt for CP sign-in
if [ "$ADE_ENROLLED" = true ]; then
    ade_enrollment_message
    renew_profiles
    sleep 5
    waiting_for_intune
else
    cp_sign_in_message
    launch_company_portal
fi

# 9. Cleanup + exit
killall Dialog 2>/dev/null || true
killall jamf 2>/dev/null || true
exit 0