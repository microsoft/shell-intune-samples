#!/bin/zsh --no-rcs
# shellcheck shell=bash
#
# setDefaultHandlers.sh
#
# Created by Aaron Voges
#
# Sets Microsoft Office apps (Outlook in particular) as the default handlers for
# their URL schemes and file/content types on Intune-managed Macs, WITHOUT any
# user interaction.
#
# Why not utiluti / LSSetDefaultHandler anymore?
#   Starting with macOS 26.4, LaunchServices prompts the user for confirmation on
#   EVERY default-app change for a URL scheme or file type. Any tool that uses the
#   public API (utiluti, duti, NSWorkspace) will therefore stall on a dialog and
#   the user can reject the change. See:
#   https://scriptingosx.com/2026/03/macos-26-4-brings-more-default-app-confirmation-prompts/
#
# What this script does instead:
#   It writes the LaunchServices handler records directly into
#     ~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist
#   for every existing local user, and into the User Template so that any NEW user
#   account created later is pre-configured before lsd ever starts for that user.
#
# Deploy via Intune:
#   Devices > macOS > Shell scripts
#     Run script as signed-in user : No  (must run as root)
#     Hide script notifications    : Yes
#
# Exit codes: 0 = success, 1 = fatal error
#
# Tested on macOS 26.7 and 27.0.

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

#### ---------------------------------------------------------------- config ###

# URL schemes:  "<scheme>|<bundle identifier>"
url_handlers=(
  "mailto|com.microsoft.Outlook"
)

# Content types (UTIs): "<uti>|<bundle identifier>"
# NOTE: do NOT add public.html / https here - macOS ties those to the default
#       browser and they still require an interactive prompt.
type_handlers=(
  # --- Mail / calendar: everything that used to open in Mail.app -------------
  "com.apple.mail.email|com.microsoft.Outlook"                  # .eml
  "public.email-message|com.microsoft.Outlook"                  # generic email message
  "com.microsoft.outlook.msg|com.microsoft.Outlook"             # .msg
  "com.microsoft.outlook15.email-message|com.microsoft.Outlook"
  "com.microsoft.outlook.oft|com.microsoft.Outlook"             # .oft
  "com.microsoft.outlook.template|com.microsoft.Outlook"        # .emltpl
  "com.apple.ical.ics|com.microsoft.Outlook"                    # .ics
  "com.apple.ical.vcs|com.microsoft.Outlook"                    # .vcs
  "com.microsoft.outlook15.icalendar|com.microsoft.Outlook"

  # --- Word -----------------------------------------------------------------
  "com.microsoft.word.doc|com.microsoft.Word"
  "org.openxmlformats.wordprocessingml.document|com.microsoft.Word"
  "org.openxmlformats.wordprocessingml.template|com.microsoft.Word"
  "com.microsoft.word.dot|com.microsoft.Word"
  "public.rtf|com.microsoft.Word"

  # --- Excel ----------------------------------------------------------------
  "com.microsoft.excel.xls|com.microsoft.Excel"
  "org.openxmlformats.spreadsheetml.sheet|com.microsoft.Excel"
  "org.openxmlformats.spreadsheetml.sheet.macroenabled|com.microsoft.Excel"
  "org.openxmlformats.spreadsheetml.template|com.microsoft.Excel"
  "public.comma-separated-values-text|com.microsoft.Excel"

  # --- PowerPoint -----------------------------------------------------------
  "com.microsoft.powerpoint.ppt|com.microsoft.PowerPoint"
  "org.openxmlformats.presentationml.presentation|com.microsoft.PowerPoint"
  "org.openxmlformats.presentationml.slideshow|com.microsoft.PowerPoint"
  "org.openxmlformats.presentationml.template|com.microsoft.PowerPoint"
)

# Minimum uid considered a "real" user account.
min_uid=500

log_dir="/Library/Logs/Microsoft/IntuneScripts/SetDefaultHandlers"
log_file="${log_dir}/setDefaultHandlers.log"

user_template="/Library/User Template/Non_localized"
ls_prefs_subpath="Library/Preferences/com.apple.LaunchServices"
ls_plist_name="com.apple.launchservices.secure.plist"

plistbuddy=/usr/libexec/PlistBuddy

#### ------------------------------------------------------------- functions ###

# Log to stderr (captured by Intune) and to the log file. Never stdout, because
# stdout is used to return values from functions.
logmsg() {
  printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$log_file" >&2
}

# CFAbsoluteTime (seconds since 2001-01-01) used by LSHandlerModificationDate
cf_now() {
  print $(( $(date +%s) - 978307200 ))
}

# Resolve an installed app path for a bundle identifier, or empty if not present.
# NOTE: never use a variable named 'path' here - in zsh it is tied to $PATH.
app_path_for_id() {
  local bundleid=$1
  local dir found candidate id
  # mdfind is unreliable right after imaging/enrolment, so check the obvious
  # locations first and only fall back to Spotlight.
  for dir in /Applications /Applications/Utilities /System/Applications; do
    for candidate in "$dir"/*.app(N); do
      [[ -f "$candidate/Contents/Info.plist" ]] || continue
      id=$(${plistbuddy} -c "Print :CFBundleIdentifier" "$candidate/Contents/Info.plist" 2>/dev/null)
      if [[ "${id:l}" == "${bundleid:l}" ]]; then
        print -r -- "$candidate"
        return 0
      fi
    done
  done
  found=$(mdfind "kMDItemCFBundleIdentifier == '${bundleid}'" 2>/dev/null | head -1)
  if [[ -n "$found" && -d "$found" ]]; then
    print -r -- "$found"
    return 0
  fi
  return 1
}

# Number of entries in :LSHandlers
ls_count() {
  local plist=$1 i=0
  while ${plistbuddy} -c "Print :LSHandlers:${i}" "$plist" >/dev/null 2>&1; do
    i=$(( i + 1 ))
  done
  print $i
}

# ls_set_handler <plist> <LSHandlerURLScheme|LSHandlerContentType> <value> <bundleid>
# Removes any existing record for that scheme/type, then appends a fresh one.
# Returns 0 if the plist was modified, 1 if it was already correct.
ls_set_handler() {
  local plist=$1 key=$2 value=$3 bundleid=$4
  local i count current role changed=1

  count=$(ls_count "$plist")

  # already correct?
  for (( i = count - 1; i >= 0; i-- )); do
    current=$(${plistbuddy} -c "Print :LSHandlers:${i}:${key}" "$plist" 2>/dev/null)
    [[ "${current:l}" == "${value:l}" ]] || continue
    role=$(${plistbuddy} -c "Print :LSHandlers:${i}:LSHandlerRoleAll" "$plist" 2>/dev/null)
    if [[ "${role:l}" == "${bundleid:l}" ]]; then
      return 1
    fi
    ${plistbuddy} -c "Delete :LSHandlers:${i}" "$plist" >/dev/null 2>&1
    changed=0
  done

  count=$(ls_count "$plist")
  ${plistbuddy} \
    -c "Add :LSHandlers:${count} dict" \
    -c "Add :LSHandlers:${count}:${key} string ${value}" \
    -c "Add :LSHandlers:${count}:LSHandlerRoleAll string ${bundleid}" \
    -c "Add :LSHandlers:${count}:LSHandlerPreferredVersions dict" \
    -c "Add :LSHandlers:${count}:LSHandlerPreferredVersions:LSHandlerRoleAll string -" \
    -c "Add :LSHandlers:${count}:LSHandlerModificationDate real $(cf_now)" \
    "$plist" >/dev/null 2>&1 || {
      logmsg "    ERROR: failed to add handler ${value} -> ${bundleid}"
      return 1
    }
  return 0
}

# Write a minimal, valid secure.plist containing an empty LSHandlers array.
create_empty_ls_plist() {
  local plist=$1
  cat > "$plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>LSHandlers</key>
	<array/>
</dict>
</plist>
PLIST
}

# apply_to_plist <plist path>  -> sets global $changes_made
apply_to_plist() {
  local plist=$1 entry scheme uti bundleid changes=0

  if [[ ! -f "$plist" ]]; then
    create_empty_ls_plist "$plist"
  fi
  # repair a corrupt/unreadable file rather than failing the whole run
  if ! plutil -lint "$plist" >/dev/null 2>&1; then
    logmsg "    plist is not readable, recreating: $plist"
    create_empty_ls_plist "$plist"
  fi
  ${plistbuddy} -c "Print :LSHandlers" "$plist" >/dev/null 2>&1 || \
    ${plistbuddy} -c "Add :LSHandlers array" "$plist" >/dev/null 2>&1

  for entry in "${url_handlers[@]}"; do
    scheme=${entry%%|*}; bundleid=${entry##*|}
    [[ -n "${available_apps[$bundleid]}" ]] || continue
    if ls_set_handler "$plist" "LSHandlerURLScheme" "$scheme" "$bundleid"; then
      logmsg "    set url scheme  ${scheme} -> ${bundleid}"
      changes=$(( changes + 1 ))
    fi
  done

  for entry in "${type_handlers[@]}"; do
    uti=${entry%%|*}; bundleid=${entry##*|}
    [[ -n "${available_apps[$bundleid]}" ]] || continue
    if ls_set_handler "$plist" "LSHandlerContentType" "$uti" "$bundleid"; then
      logmsg "    set content type ${uti} -> ${bundleid}"
      changes=$(( changes + 1 ))
    fi
  done

  plutil -convert binary1 "$plist" >/dev/null 2>&1
  changes_made=$changes
}

#### ------------------------------------------------------------------ main ###

if [[ $EUID -ne 0 ]]; then
  print -u2 "This script must run as root."
  exit 1
fi

mkdir -p "$log_dir"
logmsg "================================================================"
logmsg "setDefaultHandlers starting on $(sw_vers -productVersion) ($(sw_vers -buildVersion))"

# Work out which of the configured apps are actually installed. Setting a handler
# to a bundle id that is not present leaves a dead record behind, so skip those.
typeset -A available_apps
typeset -a wanted_ids
for entry in "${url_handlers[@]}" "${type_handlers[@]}"; do
  wanted_ids+=("${entry##*|}")
done
for bundleid in ${(u)wanted_ids}; do
  if apppath=$(app_path_for_id "$bundleid"); then
    available_apps[$bundleid]=$apppath
    logmsg "found ${bundleid} at ${apppath}"
  else
    logmsg "NOT INSTALLED, skipping: ${bundleid}"
  fi
done

if [[ ${#available_apps} -eq 0 ]]; then
  logmsg "None of the configured applications are installed. Nothing to do."
  exit 0
fi

# --- 1. User Template: covers every account created from now on ---------------
template_plist="${user_template}/${ls_prefs_subpath}/${ls_plist_name}"
logmsg "applying to user template: ${template_plist}"
mkdir -p "${user_template}/${ls_prefs_subpath}"
apply_to_plist "$template_plist"
chown -R root:wheel "${user_template}/${ls_prefs_subpath}"
chmod 755 "${user_template}/${ls_prefs_subpath}"
chmod 644 "$template_plist"
logmsg "  user template: ${changes_made} change(s)"

# --- 2. Existing local user accounts ------------------------------------------
console_user=$(stat -f %Su /dev/console)
[[ "$console_user" == "root" ]] && console_user=""
logmsg "console user: ${console_user:-<none>}"

for username in $(dscl . -list /Users UniqueID | awk -v m="$min_uid" '$2 >= m {print $1}'); do
  [[ "$username" == _* ]] && continue
  userhome=$(dscl . -read "/Users/${username}" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
  [[ -d "$userhome" ]] || { logmsg "skipping ${username}: no home directory"; continue; }

  logmsg "applying to user: ${username} (${userhome})"
  user_plist="${userhome}/${ls_prefs_subpath}/${ls_plist_name}"

  # Kill lsd BEFORE writing so it cannot flush its cached copy over our changes.
  if [[ "$username" == "$console_user" ]]; then
    killall -u "$username" lsd 2>/dev/null
    sleep 1
  fi

  mkdir -p "${userhome}/${ls_prefs_subpath}"
  apply_to_plist "$user_plist"
  user_changes=$changes_made
  chown -R "${username}:staff" "${userhome}/${ls_prefs_subpath}"
  chmod 755 "${userhome}/${ls_prefs_subpath}"
  chmod 644 "$user_plist"
  logmsg "  ${username}: ${user_changes} change(s)"

  # Make the running LaunchServices daemon re-read the file.
  if [[ "$username" == "$console_user" && "$user_changes" -gt 0 ]]; then
    killall -u "$username" lsd 2>/dev/null
    killall -u "$username" Finder 2>/dev/null
    logmsg "  restarted lsd/Finder for ${username}"
  fi
done

# --- 3. Verify ----------------------------------------------------------------
if [[ -n "$console_user" ]]; then
  userhome=$(dscl . -read "/Users/${console_user}" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
  count=$(plutil -extract LSHandlers json -o - \
    "${userhome}/${ls_prefs_subpath}/${ls_plist_name}" 2>/dev/null | \
    grep -o -i 'com.microsoft.Outlook' | wc -l | tr -d ' ')
  logmsg "verification: ${count} Outlook handler record(s) in ${console_user}'s LaunchServices plist"
fi

logmsg "setDefaultHandlers finished"
logmsg "NOTE: changes for an already-logged-in user take full effect after the"
logmsg "      next log out / log in or restart."
exit 0
