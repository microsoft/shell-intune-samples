#!/bin/zsh
set -e

############################################################################################
## Install Company Portal for Platform SSO (PSSO) during Setup Assistant
## Maintainer: neiljohn@microsoft.com
##
## Summary: Lightweight Company Portal installer designed to run during macOS Setup
##          Assistant for Platform SSO enrollment. Unlike the standard install script, this
##          variant skips Rosetta 2 checks, desktop readiness waits, and update checks
##          since it runs before the user reaches the desktop and Company Portal will not
##          yet be installed.
##
## Usage:   Deploy via Intune as a shell script assigned to run during Setup Assistant.
##          This ensures Company Portal is available for PSSO registration before the
##          user first logs in.
##
## Exit codes: 0 success, 1 failure.
############################################################################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

## Config
weburl="https://go.microsoft.com/fwlink/?linkid=853070"
logdir="/Library/Logs/Microsoft/IntuneScripts/installCompanyPortalPSSO"
pkg=$(mktemp -t CompanyPortal).pkg

mkdir -p "$logdir"
exec > >(tee -a "$logdir/CompanyPortal.log") 2>&1
trap 'rm -f "$pkg"' EXIT

echo "$(date) | Starting PSSO Setup Assistant install of Company Portal"

curl -fsSL --connect-timeout 30 --retry 5 --retry-delay 60 -o "$pkg" "$weburl"
installer -pkg "$pkg" -target /
