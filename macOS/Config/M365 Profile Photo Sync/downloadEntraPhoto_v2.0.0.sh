#!/bin/bash
Ver="2.0.0"
#set -x

############################################################################################
##
## Script to download the profile photo from Entra ID
##
## Version 2.0.0 - December 2025
## Optimized with improved error handling, logging, and security
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
## Feedback: marc.nahum@microsoft.com

# Exit on error for safer execution
set -o pipefail
set -u  # Exit on undefined variable

#############################################
## User Defined Variables
#############################################
clientID=""
secretValue=""
tenantID=""

#############################################
## Configuration Constants
#############################################
readonly MAX_RETRIES=10
readonly RETRY_DELAY=30
readonly DOCK_CHECK_MAX_DELAY=50
readonly DOCK_CHECK_MIN_DELAY=10
readonly PHOTO_FILENAME="PhotoID.jpg"

#############################################
## Standard Variables
#############################################
# Get current console user (more reliable method)
userName=$(stat -f%Su /dev/console 2>/dev/null || ls -l /dev/console | awk '{print $3}')
logDir="/Library/logs/Microsoft/IntuneScripts/PhotoID"
log="${logDir}/PhotoID.log"

# API endpoints (only set if tenantID is not empty)
if [[ -n "${tenantID:-}" ]]; then
    readonly TOKEN_URL="https://login.microsoftonline.com/${tenantID}/oauth2/v2.0/token"
else
    readonly TOKEN_URL=""
fi
readonly OFFICE_PLIST_PATH="/Library/Managed Preferences/com.microsoft.office.plist"

# Track temporary files for cleanup
TEMP_FILES=()

#############################################
## Functions
#############################################

# Cleanup function for temporary files
cleanup() {
    local exit_code=$?
    if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
        for temp_file in "${TEMP_FILES[@]}"; do
            [[ -f "${temp_file}" ]] && rm -f "${temp_file}" 2>/dev/null
        done
    fi
    return ${exit_code}
}

# Set trap to cleanup on exit
trap cleanup EXIT INT TERM

# Function to log messages with consistent timestamp format
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1"
}

# Function to log errors to stderr
log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | ERROR: $1" >&2
}

# Function to URL encode strings
url_encode() {
    local string="$1"
    local encoded=""
    local pos=0
    local length=${#string}
    
    for ((pos=0; pos<length; pos++)); do
        local char="${string:pos:1}"
        case "$char" in
            [-_.~a-zA-Z0-9])
                encoded+="$char"
                ;;
            *)
                encoded+=$(printf '%%%02X' "'$char")
                ;;
        esac
    done
    
    echo "${encoded}"
}

# Function to validate required credentials
validate_credentials() {
    if [[ -z "${clientID}" ]]; then
        log_error "clientID is not configured"
        return 1
    fi
    
    if [[ -z "${secretValue}" ]]; then
        log_error "secretValue is not configured"
        return 1
    fi
    
    if [[ -z "${tenantID}" ]]; then
        log_error "tenantID is not configured"
        return 1
    fi
    
    log_message "Credentials validated successfully"
    return 0
}

# Function to delay until the user has finished setup assistant
waitForDesktop() {
    log_message "Waiting for Dock to start..."
    
    while ! pgrep -x "Dock" > /dev/null 2>&1; do
        local delay=$((RANDOM % (DOCK_CHECK_MAX_DELAY - DOCK_CHECK_MIN_DELAY + 1) + DOCK_CHECK_MIN_DELAY))
        log_message "Dock not running, waiting ${delay} seconds"
        sleep "${delay}"
    done
    
    log_message "Dock is running, proceeding with script"
}

# Function to wait for Office plist to become available
wait_for_office_plist() {
    local retries=0
    
    log_message "Checking for Office configuration plist"
    
    while [[ ! -e "${OFFICE_PLIST_PATH}" ]]; do
        log_message "Looking for Office Plist File [${OFFICE_PLIST_PATH}] (Attempt $((retries + 1))/${MAX_RETRIES})"
        
        if [[ ${retries} -ge ${MAX_RETRIES} ]]; then
            log_error "Office plist file not found after ${MAX_RETRIES} attempts [${OFFICE_PLIST_PATH}]"
            return 1
        fi
        
        ((retries++))
        sleep "${RETRY_DELAY}"
    done
    
    log_message "Office plist file found [${OFFICE_PLIST_PATH}]"
    return 0
}

# Function to retrieve UPN from Office plist
get_upn() {
    log_message "Attempting to determine UPN from OfficeActivationEmailAddress"
    
    local upn
    upn=$(defaults read "${OFFICE_PLIST_PATH}" OfficeActivationEmailAddress 2>/dev/null)
    
    if [[ $? -eq 0 ]] && [[ -n "${upn}" ]]; then
        log_message "UPN found: ${upn}"
        echo "${upn}"
        return 0
    else
        log_error "UPN not found in Office configuration"
        log_error "Ensure Office Activation Email is configured in Settings"
        return 1
    fi
}

# Function to obtain access token from Entra ID
get_access_token() {
    log_message "Requesting access token from Entra ID"
    
    # URL encode credentials for safety
    local encoded_client_id=$(url_encode "${clientID}")
    local encoded_secret=$(url_encode "${secretValue}")
    
    # Build request data
    local data="client_id=${encoded_client_id}&scope=https%3A%2F%2Fgraph.microsoft.com%2F.default&client_secret=${encoded_secret}&grant_type=client_credentials"
    
    # Make token request with timeout and retry options
    local response
    response=$(curl -s -w "\n%{http_code}" -X POST \
        --max-time 30 \
        --retry 2 \
        --retry-delay 5 \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "${data}" \
        "${TOKEN_URL}" 2>&1)
    
    if [[ $? -ne 0 ]]; then
        log_error "Failed to connect to Entra ID token endpoint"
        return 1
    fi
    
    # Extract HTTP code and body
    local http_code=$(echo "${response}" | tail -n1)
    local body=$(echo "${response}" | head -n-1)
    
    # Extract token from response
    local token
    token=$(echo "${body}" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    
    if [[ -n "${token}" ]] && [[ ${#token} -gt 50 ]]; then
        log_message "Access token obtained successfully (HTTP ${http_code}, length: ${#token})"
        echo "${token}"
        return 0
    else
        log_error "Failed to obtain access token (HTTP ${http_code})"
        
        # Extract and log error details without exposing secrets
        if echo "${body}" | grep -q "error"; then
            local error_code=$(echo "${body}" | grep -o '"error":"[^"]*"' | cut -d'"' -f4)
            local error_desc=$(echo "${body}" | grep -o '"error_description":"[^"]*"' | cut -d'"' -f4 | head -c 150)
            log_error "API Error: ${error_code} - ${error_desc}"
        fi
        return 1
    fi
}

# Function to download user photo from Microsoft Graph
download_photo() {
    local token="$1"
    local upn="$2"
    local output_path="$3"
    
    # URL encode the UPN for the API call
    local encoded_upn=$(url_encode "${upn}")
    
    # Use v1.0 endpoint (beta changed to v1.0 for stability)
    local photo_url="https://graph.microsoft.com/v1.0/users/${encoded_upn}/photo/\$value"
    
    log_message "Downloading profile photo for user: ${upn}"
    
    # Download photo with HTTP status code capture and timeout
    local http_code
    http_code=$(curl -s -w "%{http_code}" -o "${output_path}" \
        --max-time 60 \
        --location \
        --request GET "${photo_url}" \
        --header "Authorization: Bearer ${token}")
    
    # Validate download
    if [[ ${http_code} -eq 200 ]] && [[ -f "${output_path}" ]] && [[ -s "${output_path}" ]]; then
        local file_size=$(stat -f%z "${output_path}" 2>/dev/null || echo "unknown")
        
        # Verify it's a valid image file by checking magic bytes
        local file_type=$(file -b --mime-type "${output_path}" 2>/dev/null || echo "unknown")
        if [[ "${file_type}" =~ ^image/ ]]; then
            log_message "Photo downloaded successfully [${output_path}] (${file_size} bytes, ${file_type})"
            TEMP_FILES+=("${output_path}")
            return 0
        else
            log_error "Downloaded file is not a valid image (${file_type})"
            rm -f "${output_path}"
            return 1
        fi
    elif [[ ${http_code} -eq 404 ]]; then
        log_error "No profile photo found for user ${upn} (HTTP 404)"
        [[ -f "${output_path}" ]] && rm -f "${output_path}"
        return 1
    else
        log_error "Failed to download photo (HTTP ${http_code})"
        [[ -f "${output_path}" ]] && rm -f "${output_path}"
        return 1
    fi
}

# Function to set user photo using Directory Services
set_user_photo() {
    local username="$1"
    local photo_path="$2"
    
    log_message "Setting user photo for: ${username}"
    
    # Verify photo file exists and is readable
    if [[ ! -f "${photo_path}" ]]; then
        log_error "Photo file not found: ${photo_path}"
        return 1
    fi
    
    if [[ ! -r "${photo_path}" ]]; then
        log_error "Photo file not readable: ${photo_path}"
        return 1
    fi
    
    # Create temporary import file
    local temp_file
    temp_file=$(mktemp) || {
        log_error "Failed to create temporary file"
        return 1
    }
    TEMP_FILES+=("${temp_file}")
    
    # Define separators for dsimport format
    local ER="0x0A"  # Line Feed (newline)
    local EC="0x5C"  # Backslash
    local FS="0x3A"  # Colon (field separator)
    local VS="0x2C"  # Comma (value separator)
    
    # Write record description (header line) to import file
    log_message "Creating dsimport file"
    echo "${ER} ${EC} ${FS} ${VS} dsRecTypeStandard:Users 2 RecordName externalbinary:JPEGPhoto" > "${temp_file}"
    
    # Write the record (username and photo path)
    echo "${username}:${photo_path}" >> "${temp_file}"
    
    # Delete existing JPEGPhoto attribute
    log_message "Removing existing photo attribute for: ${username}"
    dscl . delete "/Users/${username}" JPEGPhoto 2>/dev/null || true
    
    # Quit System Settings/Preferences to ensure photo updates properly
    local settings_app="System Settings"
    if [[ $(sw_vers -productVersion | cut -d. -f1) -lt 13 ]]; then
        settings_app="System Preferences"
    fi
    
    log_message "Closing ${settings_app} if running"
    pkill -x "${settings_app}" 2>/dev/null || true
    
    # Import the new photo
    log_message "Importing photo via dsimport"
    local import_output
    import_output=$(dsimport "${temp_file}" /Local/Default M 2>&1)
    local import_status=$?
    
    if [[ ${import_status} -eq 0 ]]; then
        log_message "Photo imported successfully for: ${username}"
        
        # Verify the photo was actually set
        if dscl . read "/Users/${username}" JPEGPhoto &>/dev/null; then
            log_message "Photo verified in directory services"
        else
            log_error "Photo import succeeded but verification failed"
        fi
        return 0
    else
        log_error "Failed to import photo via dsimport (exit code: ${import_status})"
        [[ -n "${import_output}" ]] && log_error "dsimport output: ${import_output}"
        return 1
    fi
}

#############################################
## Main Script Execution
#############################################

# Create log directory if it doesn't exist
if [[ -d "${logDir}" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') | Log directory exists [${logDir}]"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') | Creating log directory [${logDir}]"
    mkdir -p "${logDir}" || {
        echo "ERROR: Failed to create log directory [${logDir}]" >&2
        exit 1
    }
fi

# Start logging to file (tee to both console and log file)
exec &> >(tee -a "${log}")

log_message "=========================================="
log_message "PhotoID Profile Sync v${Ver}"
log_message "=========================================="
log_message ""

# Validate that all required credentials are configured
if ! validate_credentials; then
    log_error "Script configuration incomplete - please set clientID, secretValue, and tenantID"
    exit 1
fi

# Validate that we have a username
if [[ -z "${userName}" ]] || [[ "${userName}" == "root" ]] || [[ "${userName}" == "_mbsetupuser" ]]; then
    log_error "Unable to determine valid console user (got: ${userName:-none})"
    exit 1
fi
log_message "Console user detected: ${userName}"

# Verify user home directory exists
if [[ ! -d "/Users/${userName}" ]]; then
    log_error "User home directory does not exist: /Users/${userName}"
    exit 1
fi

# Wait for desktop environment to be ready
waitForDesktop

# Wait for Office plist to become available
if ! wait_for_office_plist; then
    log_error "Office configuration not available"
    exit 1
fi

# Get UPN from Office configuration
UPN=$(get_upn)
if [[ $? -ne 0 ]] || [[ -z "${UPN}" ]]; then
    log_error "Failed to retrieve UPN from Office configuration"
    exit 1
fi

# Obtain access token from Entra ID
TOKEN=$(get_access_token)
if [[ $? -ne 0 ]] || [[ -z "${TOKEN}" ]]; then
    log_error "Failed to obtain access token from Entra ID"
    exit 1
fi

# Set photo path in user's home directory
pathPhoto="/Users/${userName}/${PHOTO_FILENAME}"

# Download the profile photo from Microsoft Graph
if ! download_photo "${TOKEN}" "${UPN}" "${pathPhoto}"; then
    log_error "Failed to download profile photo"
    exit 1
fi

# Set the user photo in the local directory
if ! set_user_photo "${userName}" "${pathPhoto}"; then
    log_error "Failed to set user photo"
    exit 1
fi

# Success!
log_message ""
log_message "=========================================="
log_message "PhotoID completed successfully"
log_message "Photo synchronized for: ${userName}"
log_message "Photo path: ${pathPhoto}"
log_message "=========================================="

# Note: Cleanup will be handled by trap on exit
exit 0
