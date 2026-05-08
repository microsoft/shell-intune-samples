#!/bin/zsh
#set -x
############################################################################################
##
## Script to secure user's home folders
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
appname="SecureUsersHomeFolders"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"
log="$logandmetadir/$appname.log"

# Track failures so we can exit non-zero if anything could not be remediated.
# Microsoft Defender / Secure Score will only mark the device as compliant
# once every user home folder is mode 700/711/750 AND /Users/Shared is 1777
# with sticky bit set. See:
#   https://techcommunity.microsoft.com/discussions/microsoft-security/secure-score---secure-home-folders-in-macos/3930746
failures=0

# Check if the log directory has been created
if [ -d $logandmetadir ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# Must run as root - we're chmod'ing other users' home directories.
if [[ $(id -u) -ne 0 ]]; then
    echo "$(date) | ERROR: $appname must be run as root (uid 0). Exiting."
    exit 1
fi

# Secure each user home folder under /Users.
#
# /Users is firmlinked to /System/Volumes/Data/Users on modern macOS, so the
# inodes (and therefore the permissions we set here) are shared. We use the
# /Users path because that is what the Defender for Endpoint posture check
# evaluates.
#
# Acceptable end-state per the CIS macOS benchmark "Ensure Home Folders Are
# Secure": mode 700, 711 or 750. /Users/Shared and Guest are excluded here
# and handled separately below.
SecureUsersHomeFolders() {
  local userDir mode
  while IFS= read -r userDir; do
    [[ -z "$userDir" ]] && continue
    mode=$(/usr/bin/stat -f "%Lp" "$userDir")
    case "$mode" in
      700|711|750)
        echo "$(date) | OK    | $userDir already mode $mode"
        ;;
      *)
        echo "$(date) | FIX   | $userDir is mode $mode, removing group/other rwx"
        if ! /bin/chmod og-rwx "$userDir"; then
          echo "$(date) | ERROR | chmod failed on $userDir"
          failures=$((failures + 1))
          continue
        fi
        mode=$(/usr/bin/stat -f "%Lp" "$userDir")
        case "$mode" in
          700|711|750)
            echo "$(date) | OK    | $userDir is now mode $mode"
            ;;
          *)
            echo "$(date) | ERROR | $userDir is still mode $mode after chmod"
            failures=$((failures + 1))
            ;;
        esac
        ;;
    esac
  done < <(/usr/bin/find /Users -mindepth 1 -maxdepth 1 -type d \
              ! -name Shared ! -name Guest ! -name .localized)
}

# Secure /Users/Shared.
#
# This folder is excluded from the user-folder loop above because it is
# legitimately world-accessible. The CIS / Defender expectation is that it
# is mode 1777 (drwxrwxrwt) with the sticky bit set, owned by root:wheel.
SecureSharedFolder() {
  local sharedDir="/Users/Shared"
  if [[ ! -d "$sharedDir" ]]; then
    echo "$(date) | INFO  | $sharedDir does not exist, skipping"
    return
  fi
  local mode owner
  mode=$(/usr/bin/stat -f "%Lp" "$sharedDir")
  owner=$(/usr/bin/stat -f "%Su:%Sg" "$sharedDir")
  if [[ "$mode" == "1777" && "$owner" == "root:wheel" ]]; then
    echo "$(date) | OK    | $sharedDir already mode 1777 root:wheel"
    return
  fi
  echo "$(date) | FIX   | $sharedDir is mode $mode owner $owner, resetting to 1777 root:wheel"
  /usr/sbin/chown root:wheel "$sharedDir" || failures=$((failures + 1))
  /bin/chmod 1777 "$sharedDir"             || failures=$((failures + 1))
  mode=$(/usr/bin/stat -f "%Lp" "$sharedDir")
  owner=$(/usr/bin/stat -f "%Su:%Sg" "$sharedDir")
  if [[ "$mode" == "1777" && "$owner" == "root:wheel" ]]; then
    echo "$(date) | OK    | $sharedDir is now mode 1777 root:wheel"
  else
    echo "$(date) | ERROR | $sharedDir is mode $mode owner $owner after remediation"
    failures=$((failures + 1))
  fi
}

# Start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $appname"
echo "############################################################"
echo ""

# Run remediation
SecureUsersHomeFolders
SecureSharedFolder

if [[ $failures -gt 0 ]]; then
  echo "$(date) | $failures item(s) could not be remediated. Exiting 1."
  exit 1
fi

echo "$(date) | All user home folders and /Users/Shared are secured. Exiting 0."
exit 0