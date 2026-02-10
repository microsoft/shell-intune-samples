#!/usr/bin/env bash

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

# Script: removeWorkplaceJoinCerts.sh
# -------------------------------------------------------------------------------------------------------
# Description:
# This script scans the current user's login keychain for Entra ID WorkplaceJoin certificates
# (identified by the "MS-Organization-Access" issuer) and optionally removes them.
#
# These certificates are created when a macOS device is registered in Entra ID for device compliance
# (e.g., while managed by Jamf or another MDM with Intune device compliance). If not removed before
# migrating to Intune, they can block fresh Intune enrollment because the device appears to already
# have an Entra identity.
#
# By default the script runs in dry-run (list) mode and only displays matching certificates.
# Use --delete to actually remove them.
# -------------------------------------------------------------------------------------------------------
# Usage:
#   ./removeWorkplaceJoinCerts.sh              # List matching certs (dry run)
#   ./removeWorkplaceJoinCerts.sh --delete     # Remove matching certs
#   ./removeWorkplaceJoinCerts.sh --debug      # List with verbose debug output
#   ./removeWorkplaceJoinCerts.sh --delete -d  # Remove with verbose debug output
# -------------------------------------------------------------------------------------------------------
# Notes:
# - Run as the logged-in user (not root) so that $HOME resolves to their login keychain.
# - The migration scripts (intuneMigrationSample.sh / IntuneToIntuneMigrationSample.sh) include an
#   integrated version of this logic via the remove_workplacejoin_certs() function, controlled by the
#   REMOVE_WORKPLACE_JOIN_CERTS variable. This standalone script is useful for manual diagnostics,
#   pre-migration audits, and testing.
# - After deletion, it is recommended to restart identity services:
#     killall identityservicesd cloudconfigurationd cfprefsd 2>/dev/null || true
# -------------------------------------------------------------------------------------------------------
# Dependencies:
# - openssl (pre-installed on macOS)
# - security (pre-installed on macOS)
#########################################################################################################

set -euo pipefail

#########################################################################################################
# Configuration
#########################################################################################################

KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"
MODE="list"
DEBUG=false

#########################################################################################################
# Argument parsing
#########################################################################################################

while [[ $# -gt 0 ]]; do
  case "$1" in
    --delete)
      MODE="delete"
      shift
      ;;
    --debug|-d)
      DEBUG=true
      shift
      ;;
    *)
      echo "Usage: $(basename "$0") [--delete] [--debug|-d]"
      exit 2
      ;;
  esac
done

#########################################################################################################
# Helper: conditional debug output
#########################################################################################################

debug() {
  if $DEBUG; then
    echo "[DEBUG] $*" >&2
  fi
}

#########################################################################################################
# Validate keychain exists
#########################################################################################################

if [[ ! -f "$KEYCHAIN" ]]; then
  echo "ERROR: login keychain not found:"
  echo "  $KEYCHAIN"
  exit 1
fi

echo "Scanning login keychain for WorkplaceJoin certificates:"
echo "  $KEYCHAIN"
echo

#########################################################################################################
# Export all certificates from the login keychain and split into individual PEM files
#
# The 'security find-certificate -a -Z -p' command outputs all certificates with their SHA-1 hashes
# and PEM-encoded data. We split this output so each certificate can be inspected individually.
#########################################################################################################

MATCHES=()
MATCH_SUBJECTS=()

TMPDIR=$(mktemp -d)
trap "rm -rf '$TMPDIR'" EXIT

debug "Exporting certificates from keychain..."
security find-certificate -a -Z -p "$KEYCHAIN" 2>/dev/null > "$TMPDIR/all.txt"
debug "Raw output saved to: $TMPDIR/all.txt"
debug "File size: $(wc -c < "$TMPDIR/all.txt") bytes"

debug "Splitting certificates into individual files..."
current_hash=""
cert_num=0
while IFS= read -r line; do
  # Capture the SHA-1 hash that precedes each certificate
  if [[ "$line" =~ ^SHA-1\ hash:\ (.+)$ ]]; then
    current_hash="${BASH_REMATCH[1]}"
    debug "Found hash: $current_hash"
  # Start of a new PEM certificate block
  elif [[ "$line" == "-----BEGIN CERTIFICATE-----" ]]; then
    cert_num=$((cert_num + 1))
    debug "Starting cert #$cert_num with hash: $current_hash"
    echo "$current_hash" > "$TMPDIR/cert${cert_num}.hash"
    echo "$line" > "$TMPDIR/cert${cert_num}.pem"
  # End of the PEM certificate block
  elif [[ "$line" == "-----END CERTIFICATE-----" ]]; then
    echo "$line" >> "$TMPDIR/cert${cert_num}.pem"
  # Body of the PEM certificate (base64 data)
  elif [[ -f "$TMPDIR/cert${cert_num}.pem" ]]; then
    echo "$line" >> "$TMPDIR/cert${cert_num}.pem"
  fi
done < "$TMPDIR/all.txt"

debug "Total certificates found: $cert_num"

#########################################################################################################
# Inspect each certificate for the MS-Organization-Access issuer
#
# WorkplaceJoin certificates issued by Entra ID contain "MS-Organization-Access" in the issuer or
# subject field. We use openssl to extract issuer/subject and grep to match.
#########################################################################################################

debug "Checking each certificate for MS-Organization-Access issuer..."
debug "---"
for pem in "$TMPDIR"/cert*.pem; do
  [[ -f "$pem" ]] || continue
  hashfile="${pem%.pem}.hash"
  hash=$(cat "$hashfile")
  
  # Extract both issuer and subject on one line for matching
  issuer_subject=$(openssl x509 -noout -issuer -subject < "$pem" 2>/dev/null | paste - -)
  
  debug "Cert: $(basename "$pem")"
  debug "  Hash: $hash"
  debug "  Issuer/Subject: $issuer_subject"
  
  if echo "$issuer_subject" | grep -qi "MS-Organization-Access"; then
    debug "  >>> MATCH FOUND! <<<"
    MATCHES+=("$hash")
    MATCH_SUBJECTS+=("$issuer_subject")
  else
    debug "  (no match)"
  fi
  debug "---"
done

debug "Total matches: ${#MATCHES[@]}"

#########################################################################################################
# Report results
#########################################################################################################

if [[ "${#MATCHES[@]}" -eq 0 ]]; then
  echo "No WorkplaceJoin (MS-Organization-Access) certificates found."
  exit 0
fi

echo "WorkplaceJoin (MS-Organization-Access) certificates found:"
echo

for i in "${!MATCHES[@]}"; do
  h="${MATCHES[$i]}"
  info="${MATCH_SUBJECTS[$i]}"
  echo "SHA-1: $h"
  echo "  $info" | tr '\t' '\n' | sed 's/^/  /'
  echo
done

#########################################################################################################
# Dry-run guard — exit here unless --delete was specified
#########################################################################################################

if [[ "$MODE" == "list" ]]; then
  echo "Dry run only. No certificates were removed."
  echo "Re-run with --delete to remove these certificates."
  exit 0
fi

#########################################################################################################
# Delete matching certificates from the login keychain
#########################################################################################################

echo "Deleting WorkplaceJoin certificates..."
echo

for h in "${MATCHES[@]}"; do
  echo "Deleting SHA-1: $h"
  security delete-certificate -Z "$h" "$KEYCHAIN"
done

echo
echo "Done. Removed ${#MATCHES[@]} certificate(s)."
echo
echo "Recommended: restart identity services to clear cached state:"
echo "  killall identityservicesd cloudconfigurationd cfprefsd 2>/dev/null || true"
