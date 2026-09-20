#!/bin/bash

info_plist="/Library/Intune/Microsoft Intune Agent.app/Contents/Info.plist"

if [[ -f "$info_plist" ]]; then
  version=$(/usr/bin/plutil -extract CFBundleShortVersionString raw "$info_plist" 2>/dev/null)
  printf '{"IntuneAgentInstalled":"true","IntuneAgentVersion":"%s"}\n' "$version"
else
  printf '{"IntuneAgentInstalled":"false","IntuneAgentVersion":"not installed"}\n'
fi
