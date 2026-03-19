#!/bin/zsh

# Get the current console user
user=$(stat -f '%Su' /dev/console 2>/dev/null)

# Exit if no user is logged in
[[ -z "$user" ]] && { echo "No user logged in"; exit 0; }

# Check if user is in admin group
result=$(dseditgroup -o checkmember -m "$user" -t user admin | awk '{print $1}')

if [[ "$result" == "yes" ]]; then
    echo "admin"
else
    echo "standard"
fi