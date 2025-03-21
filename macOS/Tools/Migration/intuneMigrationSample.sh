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
# - This script just handles the removal of Jamf/Intune and either starting setup assistant or Company Portal
#   for the user to complete migration. The onboarding process should be configured in Intune separately.
# -------------------------------------------------------------------------------------------------------
#########################################################################################################

#region Configuration

# Set the maximum deferral count for the migration prompt, set to 0 to disable deferrals
# If the deferral count is reached, the Exit button will be disabled
max_deferral_count=0
deferral_count_file="/Library/Preferences/com.microsoft.intune_migration.deferral_count.plist"
# Set if device is being migrated from another Intune tenant
intune_migration=false
# Set if Swift Dialog should be uninstalled after migration
uninstall_swiftdialog=false
# Reset office for the user, uses OfficeReset.com
reset_office=false

# Set to false if you do not want to blur the screen during dialog display
blur_screen=true
blur_screen_string="--blurscreen"
# Set the font options for the dialog title
title_font_options="shadow=0,name=SFProDisplay-Regular"
# Banner colour
banner_colour="blue"

# Messages for the migration prompt and progress dialog
migration_message_intune="Your device is scheduled to be migrated from **current Microsoft Intune tenant** to another **Microsoft Intune tenant**"
migration_message_jamf="Your device is scheduled to be migrated from **Jamf** to **Microsoft Intune**"
progress_message_intune="Your device is being migrated from one Microsoft Intune tenant to another"
progress_message_jamf="Your device is being migrated from Jamf to Microsoft Intune"

# URL of your Jamf Pro server
JAMF_PRO_URL="https://yourenvironment.jamfcloud.com"
# This should be a Jamf Pro user with the Jamf Pro Server Action 'Send Computer Unmanage Command' enabled and Jamf Pro Server Objects 'Computers' Read.
USERNAME="migration_account"
# Password for the above user
PASSWORD="migration_account_password"
LOG="/Library/Logs/Microsoft/IntuneScripts/intuneMigration/intuneMigration.log"
# Set to "classic" for (JSSResource) or new for (api) to use the classic or new API
JAMF_API_VERSION="new"

# Graph API details
# Set the GRAPH_ENDPOINT to the appropriate Intune API endpoint
GRAPH_ENDPOINT="https://graph.microsoft.com/v1.0/deviceManagement/managedDevices"
# Set the client ID, client secret, and tenant ID for the Graph API
CLIENT_ID=""
CLIENT_SECRET=""
TENANT_ID=""

#endregion

# Create deferred count file if it doesn't exist
if [ ! -f "$deferral_count_file" ]; then
  echo "Creating deferral count file..."
  sudo defaults write "$deferral_count_file" deferral_count -int 0
fi

if [ $blur_screen = false ]; then
  blur_screen_string=""
fi

#region Dialogs

# Function to display message to sign in to Company Portal
cp_sign_in_message() {
  /usr/local/bin/dialog \
    --bannertitle "Action Required: Sign in to Company Portal" \
    --message "To complete your device setup, you must sign in to the Company Portal app using your **Entra (Microsoft)** credentials.\n\nFailure to sign in to Company Portal will result in the loss of access to corporate resources such as **e-Mail** and **other essential services**.\n\nWhen you close this dialog, Company Portal will be open your screen, click **Sign-in** and complete the process to avoid service disruptions." \
    --button1text "Got it" \
    $blur_screen_string \
    --bannerimage colour=$banner_colour \
    --titlefont "$title_font_options" \
    --width 750 \
    --height 450 \
    --icon /Applications/Company\ Portal.app/Contents/Resources/AppIcon.icns
}

# Function to display "Waiting for Intune" message with spinner
waiting_for_intune() {
  /usr/local/bin/dialog \
    --bannertitle "Status: Waiting for Intune" \
    --message "Your device setup is in progress.\n\nWe're currently waiting for Intune to complete the necessary setup. This may take a few minutes.\n\nPlease keep this window open until setup is complete." \
    $blur_screen_string \
    --bannerimage colour=$banner_colour \
    --titlefont "$title_font_options" \
    --progress \
    --width 750 \
    --height 450 \
    --icon /Applications/Company\ Portal.app/Contents/Resources/AppIcon.icns \
    --no-buttons
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
    $blur_screen_string \
    --bannerimage colour=$banner_colour \
    --titlefont "$title_font_options" \
    --width 750 \
    --height 450 \
    --icon /Applications/Company\ Portal.app/Contents/Resources/AppIcon.icns
}

# Function to prompt the user to start the migration
prompt_migration() {

    if [ "$intune_migration" = true ]; then
        message=$migration_message_intune
    else
        message=$migration_message_jamf
    fi

    if [ $max_deferral_count -gt 0 ]; then
        button2text="Defer"
        deferral_message="\n\nYou can defer this migration up to **$max_deferral_count** times. After that, the Defer button will be disabled. \n\nYou have **$((max_deferral_count - DEFERRAL_COUNT))** deferral(s) remaining."
    else
        deferral_message=""
        button2text="Exit"
    fi

  # Display the dialog with improved message text
  /usr/local/bin/dialog \
    --bannertitle "Prepare for Device Migration" \
    --message "${message}.\n\nThis process will take approximately **20 minutes**, during which you will **not be able to use your Mac**.${deferral_message}" \
    --button1text "Migrate" \
    $( [[ $((DEFERRAL_COUNT)) -lt $((max_deferral_count)) || $((max_deferral_count)) -eq 0 ]] && echo "--button2text $button2text" ) \
    $blur_screen_string \
    --bannerimage colour=$banner_colour \
    --titlefont "$title_font_options" \
    --width 750 \
    --height 450 \
    --icon /Applications/Company\ Portal.app/Contents/Resources/AppIcon.icns

  # Check which button was clicked based on the exit code
  if [[ "$?" -eq 0 ]]; then
    echo "User chose to migrate the device."
    USER_READY=true
  else
    USER_READY=false
  fi
}

#endregion

#region Helper Functions

# Function to check if the device is managed by Jamf
check_if_managed() {
    if [ "$intune_migration" = true ]; then
        if profiles -P | grep -q "Microsoft.Profiles.MDM"; then
            echo "Checking if the device is managed by Intune..."
        else
            echo "Device is not managed by Intune. Exiting script."
            exit 0
        fi
    elif [ "$intune_migration" = false ]; then
        if profiles -P | grep -q "com.jamfsoftware"; then
            echo "Device is managed by Jamf."
        else
            echo "Device is not managed by Jamf. Exiting script."
            exit 0
        fi
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
    sudo installer -pkg /tmp/dialog.pkg -target /
    rm /tmp/dialog.pkg
    echo "swiftDialog installed successfully."
  else
    echo "swiftDialog is already installed."
  fi
}

uninstall_swiftDialog() {
  if [ "$uninstall_swiftdialog" = true ]; then
    echo "Uninstalling swiftDialog..."
    sudo rm -f /usr/local/bin/dialog
    sudo rm -r "/Library/Application Support/Dialog/"
    sudo pkgutil --forget au.csiro.dialogcli
  fi
}

uninstall_sidecar() {
  echo "Uninstalling Sidecar..."
  sidecar_app_path="/Library/Intune"
  sidecar_ld_name="com.microsoft.intuneMDMAgent.daemon"
  sidecar_la_name="com.microsoft.intuneMDMAgent"
  sidecar_db_path="/Library/Application Support/Microsoft/Intune/SideCar"
  sidecar_launchagent_path="/Library/LaunchAgents/$sidecar_la_name.plist"
  sidecar_launchdaemon_path="/Library/LaunchDaemons/$sidecar_ld_name.plist"
  console_user=$(/usr/bin/stat -f "%Su" /dev/console)
  console_user_uid=$(/usr/bin/id -u "$console_user")

  if [ -d "$sidecar_app_path" ]; then
    rm -rf "$sidecar_app_path"
  fi

  if [ -d "$sidecar_db_path" ]; then
    rm -rf "$sidecar_db_path"
  fi

  if [ -f "$sidecar_launchagent_path" ]; then
    /bin/launchctl asuser "${console_user_uid}" /bin/launchctl unload -w  "$sidecar_launchagent_path"
    rm -f "$sidecar_launchagent_path"
  fi

  if [ -f "$sidecar_launchdaemon_path" ]; then
    # is it loaded?
    if launchctl print "system/${sidecar_ld_name}" &> /dev/null ; then
      /bin/launchctl unload "$sidecar_launchdaemon_path"
    fi
    rm -f "$sidecar_launchdaemon_path"
  fi

  killall "IntuneMdmAgent"
}

# Function to check if jq is installed, and if not, install it
check_and_install_jq() {
  if ! command -v jq &> /dev/null; then
    echo "jq not found. Installing jq..."

    # If Homebrew is available, use it
    if command -v brew &> /dev/null; then
      echo "Homebrew detected. Installing jq with brew..."
      brew install jq
    else
      # If brew is not installed, attempt a direct download
      echo "Homebrew not detected. Downloading jq binary from GitHub..."
      JQ_TEMP_DIR="/tmp/jq_install"
      mkdir -p "$JQ_TEMP_DIR"
      
      # For Apple Silicon / Intel detection:
      ARCH=$(uname -m)
        if [[ $ARCH == "arm64" ]]; then
        JQ_URL="https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-macos-arm64"
        else
        JQ_URL="https://github.com/stedolan/jq/releases/latest/download/jq-osx-amd64"
        fi

      curl -L "$JQ_URL" -o "$JQ_TEMP_DIR/jq"
      
      # Move the downloaded binary to /usr/local/bin (or /usr/local/bin could be replaced with /usr/bin/local on older systems)
      chmod +x "$JQ_TEMP_DIR/jq"
      sudo mv "$JQ_TEMP_DIR/jq" /usr/local/bin/jq
      rm -rf "$JQ_TEMP_DIR"
    fi

    # Verify installation
    if command -v jq &> /dev/null; then
      echo "jq was successfully installed."
    else
      echo "Failed to install jq. Please install it manually."
      exit 1
    fi
  else
    echo "jq is already installed."
  fi
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

office_reset() {
  if [ "$reset_office" = true ]; then
    update_progress 30 "Resetting Office..."
    echo "Resetting Office..."
    curl -L -o /tmp/OfficeReset.pkg "https://office-reset.com/download/Microsoft_Office_Factory_Reset_1.9.1.pkg"
    sudo installer -pkg /tmp/OfficeReset.pkg -target /
    rm /tmp/OfficeReset.pkg
  fi
}

# Function to start the migration dialog in progress mode
start_progress_dialog() {
  COMMAND_FILE="/tmp/dialog_command"
  echo "Initializing migration..." > "$COMMAND_FILE"

  if [ "$intune_migration" = true ]; then
    message=$progress_message_intune
  else
    message=$progress_message_jamf
  fi
  
  /usr/local/bin/dialog \
    --bannertitle "Device Migration in Progress" \
    --icon /Applications/Company\ Portal.app/Contents/Resources/AppIcon.icns \
    --bannerimage colour=$banner_colour \
    --titlefont "$title_font_options" \
    --message "${message}. Please do not power off or disconnect your device during this process." \
    $blur_screen_string \
    --force \
    --no-buttons \
    --progress \
    --width 750 \
    --height 450 \
    --commandfile "$COMMAND_FILE" &
  
  DIALOG_PID=$!
}

# Function to clean Company Portal app if needed
clean_company_portal() {
  sudo killall "Company Portal"

  currentuser=`stat -f "%Su" /dev/console`
  rm -rf /Users/"$currentuser"/Library/Saved\ Application\ State/com.microsoft.CompanyPortalMac.savedState
  rm -rf /Users/"$currentuser"/Library/Application\ Support/com.microsoft.CompanyPortalMac
  rm -rf /Users/"$currentuser"/Library/Application\ Support/com.microsoft.CompanyPortalMac.usercontext.info
  su "$currentuser" -c "security delete-generic-password -l 'com.microsoft.adalcache'"
  su "$currentuser" -c "security delete-generic-password -l 'enterpriseregistration.windows.net'"
  su "$currentuser" -c "security delete-generic-password -l 'https://device.login.microsoftonline.com'"
  su "$currentuser" -c "security delete-generic-password -l 'https://device.login.microsoftonline.com/' "
  su "$currentuser" -c "security delete-generic-password -l 'https://enterpriseregistration.windows.net' "
  su "$currentuser" -c "security delete-generic-password -l 'https://enterpriseregistration.windows.net/' "
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

# Function to check and install the Intune Company Portal app if not present
install_cp() {
  if [ ! -d "/Applications/Company Portal.app" ]; then
    echo "Company Portal not found. Installing Company Portal..."
    curl -L -C - -o /tmp/cp.pkg "https://go.microsoft.com/fwlink?linkid=853070"
    sudo installer -pkg /tmp/cp.pkg -target /
    rm /tmp/cp.pkg
    echo "Company Portal installed successfully."
  else
    echo "Company Portal is already installed."
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

# Function to get the serial number of the current Mac
get_serial_number() {
  system_profiler SPHardwareDataType | awk '/Serial Number/ {print $4}'
}

#endregion

#region Jamf API Functions

# Function to get the computer_id from Jamf Pro based on serial number
get_computer_id() {
  local serial_number="$1"
  local auth_token="$2"
  
  computer_id=$(curl -s -X GET \
    -H "Authorization: Bearer $auth_token" \
    "$JAMF_PRO_URL/api/v1/computers-inventory?filter=hardware.serialNumber==$serial_number" | jq -r '.results[0].id')
  echo "$computer_id"
}

# Function to obtain an authentication token
get_auth_token() {
  auth_token=$(curl -su "$USERNAME:$PASSWORD" -X POST "$JAMF_PRO_URL/api/v1/auth/token" | jq -r '.token')
  echo "$auth_token"
}

unmanage_device_jamf_new() {
    # Validate input parameters
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: unmanage_device_jamf_new <computer_id> <auth_token>" >&2
        exit 1
    fi

    local computer_id="$1"
    local auth_token="$2"
    local response

    echo "DEBUG: Unmanaging device with computer ID: $computer_id" >&2

    # Send the remove MDM profile command
    response=$(curl -s -X POST \
      -H "Authorization: Bearer $auth_token" \
      "$JAMF_PRO_URL/api/v1/computer-inventory/$computer_id/remove-mdm-profile")
      
    echo "DEBUG: unmanage_device response: $response" >&2

    if echo "$response" | jq -e '.commandUuid' >/dev/null; then
        local unmanage_command_uuid
        unmanage_command_uuid=$(echo "$response" | jq -r '.commandUuid')
        echo "Device successfully unmanaged (MDM profile removed). Command UUID: $unmanage_command_uuid"

        # Remove the Jamf framework
        echo "Removing the Jamf framework..."
        remove_jamf_framework

    else
        echo "Failed to unmanage device: $response" >&2
        exit 1
    fi

}

unmanage_device_jamf_classic() {
    # Validate input parameters
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: unmanage_device_jamf_classic <computer_id> <auth_token>" >&2
        exit 1
    fi

    local computer_id="$1"
    local auth_token="$2"
    local response

    echo "DEBUG: Unmanaging device with computer ID: $computer_id" >&2

    # Send the UnmanageDevice command
    response=$(curl -s -X POST \
      -H "Authorization: Bearer $auth_token" \
      "$JAMF_PRO_URL/JSSResource/computercommands/command/UnmanageDevice/id/$computer_id")

    echo "DEBUG: Unmanage response: $response" >&2

    # Parse the XML response to extract the command UUID
    local command_uuid
    command_uuid=$(echo "$response" | xmllint --xpath 'string(//command_uuid)' - 2>/dev/null)

    if [[ -n "$command_uuid" ]]; then
        echo "Device successfully unmanaged (MDM profile removed). Command UUID: $command_uuid"

        # Remove the Jamf framework
        echo "Removing the Jamf framework..."
        remove_jamf_framework
    else
        echo "Failed to unmanage device: $response" >&2
        exit 1
    fi

}

#endregion

#region Intune API Functions

get_graph_auth_token() {
    local response

    echo "DEBUG: Getting access token..." >&2

    response=$(curl -s -X POST \
        -d "client_id=$CLIENT_ID" \
        -d "scope=https://graph.microsoft.com/.default" \
        -d "client_secret=$CLIENT_SECRET" \
        -d "grant_type=client_credentials" \
        "https://login.microsoftonline.com/$TENANT_ID/oauth2/v2.0/token")
        
    if echo "$response" | jq -e '.error' >/dev/null; then
        echo "Failed to get access token: $response" >&2
        exit 1
    else
        echo "$response" | jq -r '.access_token'
    fi
}

get_intune_device_id() {
    local serial_number="$1"
    local access_token="$2"  # Access token should be passed as an argument
    local response

    echo "DEBUG: Getting device ID..." >&2

    # Ensure the access token is set
    if [ -z "$access_token" ]; then
        echo "Error: Access token is missing!" >&2
        exit 1
    fi

    # Ensure GRAPH_ENDPOINT is set
    if [ -z "$GRAPH_ENDPOINT" ]; then
        echo "Error: GRAPH_ENDPOINT is not set!" >&2
        exit 1
    fi

    # Correct Authorization header and properly format the filter query
    response=$(curl -s -X GET \
        -H "Authorization: Bearer $access_token" \
        -H "Content-Type: application/json" \
        "$GRAPH_ENDPOINT?\$filter=serialNumber%20eq%20'$serial_number'")

    if echo "$response" | jq -e '.error' >/dev/null; then
        echo "Failed to get device ID: $response" >&2
        exit 1
    else
        # verify we only have one device
        if [ $(echo "$response" | jq -r '.value | length') -ne 1 ]; then
            echo "Error: Multiple devices found for serial number: $serial_number" >&2
            exit 1
        fi
        echo "$response" | jq -r '.value[0].id'
    fi
}

unmanage_device_from_intune() {
    local device_id="$1"
    local access_token="$2"
    local response

    echo "DEBUG: Unmanaging device..." >&2

    update_progress 50 "Removing Intune management..."

    # Ensure required parameters are provided
    if [ -z "$device_id" ] || [ -z "$access_token" ]; then
        echo "Error: Missing device ID or access token!" >&2
        exit 1
    fi

    # Send the unmanage device command
    response=$(curl -s -X DELETE \
        -H "Authorization: Bearer $access_token" \
        "$GRAPH_ENDPOINT/$device_id")

    if echo "$response" | jq -e '.error' >/dev/null; then
        echo "Failed to unmanage device: $response" >&2
        exit 1
    else
        echo "Device successfully unmanaged."
    fi
}

#endregion

#region MDM Profile Removal

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

wait_for_management_profile_removal() {
  echo "Waiting for MDM management profile removal..."
  local timeout=1800
  local interval=5
  local elapsed=0

  update_progress 70 "Waiting for MDM management profile removal..."

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

# Function to renew profiles if the device is ADE enrolled
renew_profiles() {
  sudo profiles renew -type enrollment
  echo "Profiles renewed."
}

# Function to unmanage the device from Intune
remove_intune_management() {
  update_progress 50 "Removing Intune management..."
  echo "Removing Intune management..."
  sudo profiles -R -p "Microsoft.Profiles.MDM"
  echo "Intune management removed."
}

#endregion

############################################################
##
## Main Script Execution Begins Here
##
#########################################

#region Main Script Execution

# Start Logging before we do anything else...
startLog

# Flag to track ADE enrollment
ADE_ENROLLED=false

# Flag to track user readiness
USER_READY=false

# Check if the device is managed
check_if_managed

# Install swiftDialog if needed
# Install dependencies if needed
install_cp
install_swiftDialog
check_and_install_jq

#Launch initial migration prompt
DEFERRAL_COUNT=$(defaults read "$deferral_count_file" deferral_count)

prompt_migration

DEFERRAL_COUNT=$((DEFERRAL_COUNT + 1))

# Exit script if user chose not to migrate
if [ "$USER_READY" = false ]; then
  echo "User chose to exit the migration process. Exiting script."
    # Inrement deferral count
    if [ $max_deferral_count -eq 0 ]; then
      echo "Deferral count is disabled. Exiting script."
      exit 0
    fi

    sudo defaults write "$deferral_count_file" deferral_count -int "$DEFERRAL_COUNT"
    echo "Deferral count not reached: $DEFERRAL_COUNT"
    exit 0
fi

#Launch actual migration dialog
start_progress_dialog

# Call the function to reset office
office_reset

# Check ADE enrollment before unmanaging the device
check_ade_enrollment

if [ "$intune_migration" = false ]; then
  # Now that user has agreed, fetch Jamf API details
  serial_number=$(get_serial_number)
  echo "Serial Number: $serial_number"
  auth_token=$(get_auth_token)
  echo "Auth Token: $auth_token"
  computer_id=$(get_computer_id "$serial_number" "$auth_token")
  echo "Computer ID: $computer_id"

  # If computer_id is found, unmanage and remove Jamf
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
else
  if [ $ADE_ENROLLED = true ]; then
    if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ] || [ -z "$TENANT_ID" ]; then
      echo "GRAPH API details are missing!" >&2
      exit 1
    else
      serial_number=$(get_serial_number)
      echo "Serial Number: $serial_number"
      # Get the device ID from Intune
      access_token=$(get_graph_auth_token)
      device_id=$(get_intune_device_id "$serial_number" "$access_token")
      echo "Device ID: $device_id"

      # Unmanage the device from Intune
      unmanage_device_from_intune "$device_id" "$access_token"

      # Clean up the Company Portal app
      clean_company_portal

      # Wait for management profile to be removed
      wait_for_management_profile_removal
    fi
  else
    remove_intune_management
    clean_company_portal
  fi
fi

if [ "$intune_migration" = true ]; then
  uninstall_sidecar
  update_progress 90 "Device removed from Intune, now starting Intune Migration"
  sleep 2
else
  update_progress 90 "Device removed from Jamf, now starting Intune Migration"
  sleep 2
fi

# Close Dialog and any remaining jamf processes
killall Dialog
if [ "$intune_migration" = false ]; then
  killall jamf
fi

# If the device was ADE enrolled, renew profiles
if [ "$ADE_ENROLLED" = true ]; then

    # Show end user dialog about ADE enrollment process
    ade_enrollment_message

    # Renew profiles to trigger Intune setup
    renew_profiles

    # Show waiting for Intune dialog, this will remain open until Intune setup is complete and the onboarding script runs
    sleep 5
    waiting_for_intune
else

    # Show sign-in message for Company Portal
    cp_sign_in_message

    # Launch Company Portal
    launch_company_portal
fi

# Uninstall swiftDialog
uninstall_swiftDialog

# Clean up the deferral count file
sudo rm -f "$deferral_count_file"

#endregion