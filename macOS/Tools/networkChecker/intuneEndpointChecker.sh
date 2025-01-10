#!/bin/bash

################################################################################
# intuneEndpointChecker.sh
#
# Description:
#   This script checks the IPv4 connectivity of a predefined list of endpoints
#   by resolving each hostname to its IPv4 addresses and attempting to establish
#   a TCP or UDP connection on the specified port. The results are displayed in a
#   neatly formatted, color-coded table indicating "SUCCESS" or "FAILURE" for
#   each IP address.
#
# Dependencies:
#   - dig : DNS lookup utility for querying DNS name servers.
#   - nc  : Netcat utility for reading from and writing to network connections.
#
#
# Usage:
#   1. Make the script executable:
#        chmod +x intuneEndpointChecker.sh
#
#   2. Run the script:
#        ./intuneEndpointChecker.sh
#
#   The script will dynamically display the connectivity status of each IPv4
#   address associated with the specified endpoints.
#
# Logging:
#   To log the output to a file while still viewing it in the terminal, use:
#        ./intuneEndpointChecker.sh | tee connectivity_log.txt
#
#
# Author:
#   Neil Johnson
#
# Date:
#   January 2025
#
################################################################################

## Copyright (c) 2025 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Exit immediately if a command exits with a non-zero status
set -e

# Define color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
NC="\033[0m" # No Color

# Function to display error messages in red and exit
function error_exit {
    echo -e "${RED}$1${NC}" >&2
    exit 1
}

# Function to check if required commands are available
function check_commands {
    for cmd in dig nc; do
        if ! command -v "$cmd" &> /dev/null; then
            error_exit "Error: '$cmd' command not found. Please install it before running the script."
        fi
    done
}

# Function to resolve a hostname to IPv4 addresses, handling CNAMEs
function resolve_hostname {
    local hostname=$1
    # Get IPv4 addresses using dig
    ipv4=$(dig +short A "$hostname")
    # Initialize array
    ips=()

    # Function to recursively resolve CNAMEs
    resolve_cname() {
        local cname=$1
        # Get A records for the CNAME
        local resolved_ips=$(dig +short A "$cname")
        while IFS= read -r resolved_ip; do
            # Remove trailing dot
            resolved_ip=$(echo "$resolved_ip" | sed 's/\.$//')
            # Check if it's an IPv4 address
            if [[ "$resolved_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                ips+=("$resolved_ip")
            fi
        done <<< "$resolved_ips"
    }

    # Iterate through each line returned by dig
    while IFS= read -r line; do
        # Remove trailing dot if present
        ip=$(echo "$line" | sed 's/\.$//')
        # Validate IPv4 format
        if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            ips+=("$ip")
        else
            # If not an IPv4 address, attempt to resolve as CNAME
            resolve_cname "$ip"
        fi
    done <<< "$ipv4"

    # Output unique IPv4 addresses
    printf "%s\n" "${ips[@]}" | sort -u
}

# Function to check connectivity to an IPv4 address on a specific port and protocol
function check_port {
    local ip=$1
    local port=$2
    local protocol=$3

    if [[ "$protocol" == "TCP" ]]; then
        # Use nc for TCP
        if nc -z -w2 "$ip" "$port" > /dev/null 2>&1; then
            echo "SUCCESS"
        else
            echo "FAILURE"
        fi
    elif [[ "$protocol" == "UDP" ]]; then
        # Use nc for UDP
        # Send an empty UDP packet and wait briefly for any response
        echo "" | nc -u -w2 "$ip" "$port" > /dev/null 2>&1
        # Since UDP is connectionless, we can't reliably determine success
        # Here, we assume SUCCESS if no error occurs during send
        if [[ $? -eq 0 ]]; then
            echo "SUCCESS (sent)"
        else
            echo "FAILURE"
        fi
    else
        echo "UNKNOWN_PROTOCOL"
    fi
}

# Function to print table headers
function print_table_header {
    echo -e "\n${PURPLE}=== IPv4 Connectivity ===${NC}"
    printf "%-16s %-35s %-6s %-7s %-15s\n" "IP Address" "Endpoint" "Port" "Protocol" "Status"
    printf "%-16s %-35s %-6s %-7s %-15s\n" "------------" "-----------------------------------" "-----" "--------" "---------------"
}

# Main script execution starts here

# Check for required commands
check_commands

# Define the list of endpoints with protocol (hostname:port:protocol)
ENDPOINTS=(
    "login.microsoftonline.com:443:TCP"
    "graph.microsoft.com:443:TCP"
    "microsoftgraph.chinacloudapi.cn:443:TCP"
    "login.partner.microsoftonline.cn:443:TCP"
    "graph.microsoft.us:443:TCP"
    "login.microsoftonline.us:443:TCP"
    "manage.microsoft.com:443:TCP"
    "powerlift-frontdesk.acompli.net:443:TCP"
    "events.data.microsoft.com:443:TCP"
    "swda01-mscdn.manage.microsoft.com:443:TCP"
    "swda02-mscdn.manage.microsoft.com:443:TCP"
    "swdb01-mscdn.manage.microsoft.com:443:TCP"
    "swdb02-mscdn.manage.microsoft.com:443:TCP"
    "swdc01-mscdn.manage.microsoft.com:443:TCP"
    "swdc02-mscdn.manage.microsoft.com:443:TCP"
    "swdd01-mscdn.manage.microsoft.com:443:TCP"
    "swdd02-mscdn.manage.microsoft.com:443:TCP"
    "swdin01-mscdn.manage.microsoft.com:443:TCP"
    "swdin02-mscdn.manage.microsoft.com:443:TCP"
    "enterpriseregistration.windows.net:443:TCP"
    "config.edge.skype.com:443:TCP"
    "go.microsoft.com:443:TCP"
    "itunes.apple.com:443:TCP"
    "mzstatic.com:443:TCP"
    "phobos.apple.com:443:TCP"
    "phobos.itunes-apple.com.akadns.net:443:TCP"
    "ocsp.apple.com:443:TCP"
    "ax.itunes.apple.com:443:TCP"
    "ax.itunes.apple.com.edgesuite.net:443:TCP"
    "s.mzstatic.com:443:TCP"
    "a1165.phobos.apple.com:443:TCP"
    "macsidecar.manage.microsoft.com:443:TCP"
    "macsidecareu.manage.microsoft.com:443:TCP"
    "macsidecarap.manage.microsoft.com:443:TCP"
    "albert.apple.com:443:TCP"
    "captive.apple.com:443:TCP"
    "gs.apple.com:443:TCP"
    "humb.apple.com:443:TCP"
    "static.ips.apple.com:443:TCP"
    "tbsc.apple.com:443:TCP"
    "time.apple.com:123:UDP"
    "time-macos.apple.com:123:UDP"
    "deviceenrollment.apple.com:443:TCP"
    "deviceservices-external.apple.com:443:TCP"
    "gdmf.apple.com:443:TCP"
    "identity.apple.com:443:TCP"
    "iprofiles.apple.com:443:TCP"
    "mdmenrollment.apple.com:443:TCP"
    "vpp.itunes.apple.com:443:TCP"
    "axm-servicediscovery.apple.com:443:TCP"
)

# Print table header
print_table_header

# Iterate over each endpoint and process connectivity checks
for endpoint in "${ENDPOINTS[@]}"; do
    # Extract hostname, port, and protocol (e.g., "hostname:port:protocol")
    IFS=':' read -r hostname port protocol <<< "$endpoint"
    # Default protocol to TCP if not specified
    protocol=${protocol:-TCP}

    # Resolve hostname to IPv4 addresses
    IPs=$(resolve_hostname "$hostname")

    if [[ -z "$IPs" ]]; then
        # If no IPs found, print a warning row
        # Using "N/A" for IP Address and yellow color for status
        printf "%-16s %-35s %-6s %-7s %-15b\n" "N/A" "$hostname" "$port" "$protocol" "${YELLOW}No IPv4 addresses found${NC}"
    else
        # Iterate over each IPv4 address and check connectivity
        while IFS= read -r ip; do
            if [[ -n "$ip" ]]; then
                status=$(check_port "$ip" "$port" "$protocol")
                # Determine color based on status
                case "$status" in
                    SUCCESS)
                        colored_status="${GREEN}${status}${NC}"
                        ;;
                    SUCCESS*)
                        colored_status="${GREEN}${status}${NC}"
                        ;;
                    FAILURE)
                        colored_status="${RED}${status}${NC}"
                        ;;
                    *)
                        colored_status="${YELLOW}${status}${NC}"
                        ;;
                esac
                # Print the row with interpreted color codes in real-time
                printf "%-16s %-35s %-6s %-7s %-15b\n" "$ip" "$hostname" "$port" "$protocol" "$colored_status"
            fi
        done <<< "$IPs"
    fi
done

echo -e "\n${BLUE}IPv4 connectivity checks completed.${NC}"