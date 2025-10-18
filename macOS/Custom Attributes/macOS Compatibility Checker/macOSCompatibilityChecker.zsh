#!/usr/bin/env zsh

# macOS Compatibility Checker for Microsoft Intune
# This script automatically determines the maximum supported macOS version for the current Mac
# by querying Apple's official GDMF API with the hardware's board ID.
#
# Works with both Intel and Apple Silicon Macs:
# - Apple Silicon: Uses 'target-sub-type' property (e.g., J514sAP)  
# - Intel Macs: Uses 'board-id' property converted to Mac-XXXXXXXXXXXXXXXX format
#
# Requires: curl, jq, and network connectivity to gdmf.apple.com
# Output: Clean version name suitable for Intune Custom Attributes

set -euo pipefail

GDMF_URL="https://gdmf.apple.com/v2/pmv"

# Get the Mac's board ID directly from ioreg
get_board_id() {
    # Try Apple Silicon format first (target-sub-type)
    local board_id
    board_id=$(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice 2>/dev/null | \
               awk -F'"' '/"target-sub-type"/ {print $(NF-1); exit}')
    
    if [[ -n "$board_id" ]]; then
        echo "$board_id"
        return 0
    fi
    
    # Try Intel Mac format (board-id) - extract hex and convert
    local board_id_hex
    board_id_hex=$(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice 2>/dev/null | \
                   awk '/"board-id"/ {gsub(/.*<|>.*/, ""); print; exit}')
    
    if [[ -n "$board_id_hex" ]]; then
        # Convert hex to ASCII string and format as Mac-XXXXXXXXXXXXXXXX
        local board_id_ascii
        board_id_ascii=$(echo "$board_id_hex" | xxd -r -p 2>/dev/null | tr -cd '[:alnum:]')
        if [[ -n "$board_id_ascii" && ${#board_id_ascii} -eq 16 ]]; then
            echo "Mac-$board_id_ascii"
            return 0
        fi
    fi
    
    return 1
}

# Get model ID as fallback
get_model_id() {
    local model
    model=$(sysctl -n hw.model 2>/dev/null)
    echo "$model"
}

# Convert version number to marketing name
normalize_macos_version() {
    local version="$1"
    local major_version="${version%%.*}"
    
    case "$major_version" in
        26) echo "macOS Tahoe" ;;
        15) echo "macOS Sequoia" ;;
        14) echo "macOS Sonoma" ;;
        13) echo "macOS Ventura" ;;
        12) echo "macOS Monterey" ;;
        11) echo "macOS Big Sur" ;;
        10) echo "macOS Catalina" ;;
        *) echo "macOS $version" ;;
    esac
}

# Find maximum supported version using board ID
find_max_supported_version() {
    local device_id="$1"
    
    # Download GDMF data
    local gdmf_data
    if ! gdmf_data=$(curl -fsSL "$GDMF_URL" 2>/dev/null); then
        return 1
    fi
    
    # Find the highest macOS version that supports our device
    local max_version
    max_version=$(echo "$gdmf_data" | jq -r --arg device "$device_id" '
        .PublicAssetSets.macOS[] | 
        select(.SupportedDevices[] | . == $device) | 
        .ProductVersion
    ' 2>/dev/null | sort -V | tail -1)
    
    if [[ -n "$max_version" && "$max_version" != "null" ]]; then
        echo "$max_version"
        return 0
    fi
    
    return 1
}

# Main execution
main() {
    # Try to get board ID first
    local device_id
    if device_id=$(get_board_id); then
        # Board ID found - use it
        :
    else
        # Fallback to model ID
        device_id=$(get_model_id)
    fi
    
    if [[ -z "$device_id" ]]; then
        echo "Unknown Model: Unable to determine"
        exit 1
    fi
    
    # Handle virtual machines
    if [[ "$device_id" == "VirtualMac"* ]]; then
        echo "Virtual Machine"
        exit 0
    fi
    
    # Find maximum supported version
    local max_version
    if max_version=$(find_max_supported_version "$device_id"); then
        normalize_macos_version "$max_version"
        exit 0
    else
        echo "Unknown Model: $device_id"
        exit 1
    fi
}

main "$@"
