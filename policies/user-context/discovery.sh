#!/bin/bash

read_jxa_preference() {
  local suite="$1"
  local key="$2"

  /usr/bin/osascript -l JavaScript 2>/dev/null <<EOF
const defaults = $.NSUserDefaults.alloc.initWithSuiteName('$suite');
const value = defaults.objectForKey('$key');
if (value === null || value === undefined) {
  "";
} else {
  ObjC.unwrap(value).toString();
}
EOF
}

bool_literal() {
  if [[ "$1" == "true" ]]; then
    printf 'true'
  else
    printf 'false'
  fi
}

bluetooth_sharing_disabled="false"
bluetooth_sharing_value="$(/usr/bin/defaults -currentHost read com.apple.Bluetooth PrefKeyServicesEnabled 2>/dev/null || true)"
if [[ "$bluetooth_sharing_value" == "0" || "$bluetooth_sharing_value" == "false" ]]; then
  bluetooth_sharing_disabled="true"
fi

airdrop_disabled="false"
airdrop_value="$(read_jxa_preference 'com.apple.applicationaccess' 'allowAirDrop')"
if [[ "$airdrop_value" == "false" ]]; then
  airdrop_disabled="true"
fi

printf '{'
printf '"BluetoothSharingDisabled":%s,' "$(bool_literal "$bluetooth_sharing_disabled")"
printf '"AirDropDisabled":%s' "$(bool_literal "$airdrop_disabled")"
printf '}'
