#!/bin/bash
#set -x

#############################
# Password Policy Settings ##
#############################

PolicyValuesToCheck=(   "minimumLength = 6"
                        "minimumNumericCharacters = 0"
                        "minimumAlphaCharactersLowerCase = 0"
                        "minimumAlphaCharacters = 0"
                        "minimumSymbols = 0"
                        "policyAttributePasswordHistoryDepth = 12"
                        "policyAttributeExpiresEveryNDays = 365"
                        "autoEnableInSeconds = 900"
                        "policyAttributeMaximumFailedAuthentications = 5")


function exportPolicy() {

  # Let's see who's logged on here
  echo "$(date) | Looking for logged on user"
  user=$(stat -f %Su /dev/console)
  echo "$(date) | Working with [$user]"

  ## First need to pump the policy to plist
  echo "$(date) | Exporting password policy for $user"
  sudo pwpolicy -u $user -getaccountpolicies | grep -iv "getting account policies for user" > /tmp/pwpolicy.plist

  ## Next we need to process it so that we can parse it
  echo "$(date) | Converting into plist we can use"
  /usr/libexec/PlistBuddy /tmp/pwpolicy.plist -c "Print" > /tmp/pwpolicy.txt

}

function checkPolicy() {

  declare -i policyValue
  declare -i actPolicyValue

  for policy in "${PolicyValuesToCheck[@]}"; do

    policyKey=$(echo $policy | awk -F"=" '{print $1}' | xargs)    # This is the name of the policy
    policyValue=$(echo $policy | awk -F"=" '{print $2}' | xargs)  # This is the value of the policy    
    actPolicyValue=$(cat /tmp/pwpolicy.txt | grep -i "$policyKey =" | awk -F"=" '{print $NF}' | xargs)

    echo "$(date) | Checking $policyKey"

    if [ $actPolicyValue -ge $policyValue ]; then
      echo "$(date) | + Desired:$policyValue Actual: $actPolicyValue [OK]"
    else
      echo "$(date) | - Desired:$policyValue Actual: $actPolicyValue [NOTMATCH]"
    fi


  done

}


# find the current user and export their password policy
exportPolicy

# parse the policy against our target values
checkPolicy



