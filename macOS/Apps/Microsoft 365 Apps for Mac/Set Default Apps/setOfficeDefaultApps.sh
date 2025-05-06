#!/bin/zsh
#set -x

############################################################################################
##
## Script to install **utiluti** (if required) and set Microsoft Office / Outlook
## as the default handler for all Office-related document types and URL schemes.  
## Tested on macOS 14 (Sonoma) and macOS 13 (Ventura); requires utiluti ≥ 1.1.
##
## VER 1.0.0
##
## Change Log
##
## 2025-04-25   – Initial public release  
##              • Added detection / silent install of utiluti v1.1  
##              • Added console-user detection and *launchctl asuser* wrapper  
##              • Added explicit *.csv* → Excel association (`ext set csv …`)  
##              • Added verbose tracing (`set -x`) and unified startLog function  
##
############################################################################################
##
## Copyright © 2025 Microsoft Corporation. All rights reserved.
## Scripts are not covered under any Microsoft standard support program or service.
## THE SCRIPTS ARE PROVIDED **“AS IS”** WITHOUT WARRANTY OF ANY KIND. Microsoft disclaims
## all implied warranties including, without limitation, any implied warranties of
## merchantability or fitness for a particular purpose. The entire risk arising out of
## the use or performance of the scripts and documentation remains with you. In no
## event shall Microsoft, its authors, or anyone else involved in the creation,
## production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business
## interruption, loss of business information, or other pecuniary loss) arising out
## of the use of or inability to use the scripts or documentation, even if Microsoft
## has been advised of the possibility of such damages.
##
## Feedback / Issues: neiljohn@microsoft.com
##
############################################################################################

################################################################################
#  CONFIG
################################################################################
UTILUTI_PATH="/usr/local/bin/utiluti"
UTILUTI_PKG_URL="https://github.com/scriptingosx/utiluti/releases/download/v1.1/utiluti-1.1.pkg"
TMP_PKG="/tmp/utiluti.pkg"
LOGFILE="/Library/Logs/IntuneScripts/setOfficeDefaultApps/setOfficeDefaultApps.log"

WORD_APP="/Applications/Microsoft Word.app"
EXCEL_APP="/Applications/Microsoft Excel.app"
POWERPOINT_APP="/Applications/Microsoft PowerPoint.app"
OUTLOOK_APP="/Applications/Microsoft Outlook.app"

################################################################################
#  HELPERS
################################################################################

########################################
# startLog – write to file *and* STDOUT
########################################
function startLog() {

    ###################################################
    ###################################################
    ##
    ##  start logging – output to log file and STDOUT
    ##
    ####################
    ####################

    logandmetadir=$(dirname "$LOGFILE")  # Determine directory from LOGFILE
    if [[ ! -d "$logandmetadir" ]]; then
        ## Creating metadirectory
        echo "$(date) | Creating [$logandmetadir] to store logs"
        mkdir -p "$logandmetadir"
    fi

    exec > >(tee -a "$LOGFILE") 2>&1  # Use LOGFILE variable
}

# Find the GUI (console) user – ignore the background 'loginwindow' pseudo-user
consoleUser=$(
  scutil <<< "show State:/Users/ConsoleUser" \
  | awk '/Name :/ && $3 != "loginwindow" { print $3 }'
)
if [[ -z "$consoleUser" ]]; then
  echo ">>> No console user logged in – cannot set per-user defaults. Exiting."  # Replace _log usage with echo
  exit 0
fi
consoleUID=$(id -u "$consoleUser")

# Wrapper that runs utiluti *as the console user* and shows the exact command
run_utiluti() {
  launchctl asuser "$consoleUID" sudo -u "$consoleUser" "$UTILUTI_PATH" "$@"   # quote $@
}

################################################################################
#  MAIN
################################################################################
# zsh‑compatible “safe shell” options
set -e          # abort on error
set -u          # abort on undefined variable
set -o pipefail # abort if any command in a pipeline fails

# Require root
if [[ $EUID -ne 0 ]]; then
  echo ">>> This script must be run as root."
  exit 1
fi

# Turn on x‑trace *after* variables are defined to keep output readable
# set -x

startLog

# 1. Ensure utiluti is present
if [[ ! -x "$UTILUTI_PATH" ]]; then
  echo ">>> utiluti not found – installing…"
  curl -fL --retry 3 --silent --show-error -o "$TMP_PKG" "$UTILUTI_PKG_URL"
  installer -pkg "$TMP_PKG" -target /
  rm "$TMP_PKG"
  hash -r       # refresh binary cache for the current shell
else
  echo ">>> utiluti already installed."
fi

# 2. Verify Office apps exist
for APP in "$WORD_APP" "$EXCEL_APP" "$POWERPOINT_APP" "$OUTLOOK_APP"; do
  [[ -d "$APP" ]] || { echo ">>> ERROR: $APP not found."; exit 1; }  # Replace _log usage with echo
done

# 3. Resolve bundle IDs (needed by utiluti)
WORD_BID=$(mdls -name kMDItemCFBundleIdentifier -r "$WORD_APP")
EXCEL_BID=$(mdls -name kMDItemCFBundleIdentifier -r "$EXCEL_APP")
PPT_BID=$(mdls -name kMDItemCFBundleIdentifier -r "$POWERPOINT_APP")
OUTLOOK_BID=$(mdls -name kMDItemCFBundleIdentifier -r "$OUTLOOK_APP")

################################################################################
#  Office associations
################################################################################
# Word
run_utiluti type set com.microsoft.word.doc                         "$WORD_BID"
run_utiluti type set org.openxmlformats.wordprocessingml.document   "$WORD_BID"
run_utiluti type set org.openxmlformats.wordprocessingml.template   "$WORD_BID"
run_utiluti type set public.rtf                                     "$WORD_BID"

# Excel
run_utiluti type set com.microsoft.excel.xls                        "$EXCEL_BID"
run_utiluti type set org.openxmlformats.spreadsheetml.sheet         "$EXCEL_BID"
run_utiluti type set public.comma-separated-values-text             "$EXCEL_BID"

# PowerPoint
run_utiluti type set com.microsoft.powerpoint.ppt                   "$PPT_BID"
run_utiluti type set org.openxmlformats.presentationml.presentation "$PPT_BID"
run_utiluti type set org.openxmlformats.presentationml.slideshow    "$PPT_BID"

# Outlook (documents & URL schemes)
run_utiluti type set com.apple.ical.ics         "$OUTLOOK_BID"
run_utiluti type set com.apple.mail.email       "$OUTLOOK_BID"
run_utiluti type set public.email-message       "$OUTLOOK_BID"
run_utiluti url  set mailto                     "$OUTLOOK_BID"
run_utiluti url  set message                    "$OUTLOOK_BID"

################################################################################
echo ">>> All defaults have been successfully set for user $consoleUser."  # Replace _log usage with echo
exit 0