# Script to manage accounts

This script is an example showing how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to modify user accounts on macOS. This script provides examples for downgrading existing Admin accounts to standard users and also creating a new Admin account for IT use.

## Intended Scenarios

### Scenario 1 - Removing Admin Access from end Users [downgradeAdmintoStandard.sh]

The concept here is that end users should not have Admin permissions over their Mac computers and instead will only have standard user rights. This prevents accidental or malicious changes to macOS but can also provide challenges for IT Admins. The goal is for all Admin tasks to be undertaken via Intune rather than logging on directly to the Mac itself.

There are obvious issues here in that Intune becomes the only way to manage the device. If the Mac loses the ability to be managed, then IT will also lose the ability to manage the device and it will need to be erased and macOS re-installed to recover.

### Scenario 2 - Temporary Admin access [createAdminAccount.sh]

In this scenario, the purpose is to provide an IT Admin with ad-hoc access to macOS device when they require it.  The script would be assigned to an AAD device group such as 'Temporary Admin Access' and devices added to this group when an Admin requires access. Once the script runs, it will create the 'Local Admin' account. Once the IT Admin logs on to the Mac they should change the password.

## WARNING

This script has the potential to do a significant amount of damage to your environment. It is provided as an example and if you wish to achieve a task like this we strongly recommend that you spend significant time testing and modifying to suit your own needs.


The following variables exist. If you set downgradeexistingadmin = true the script will set all user accounts to be standard users.
```
downgradeexistingadmin=false
adminaccountname="localadmin"
adminaccountfullname="Local Admin"
scriptname="Create Local Admin Account"
log="/var/log/localadminaccount.log"
```

The new Admin account password is controlled by the following cipher based off the device serial number. In this example, the script determines the device serial number, then passes it through two really basic tr ciphers and finally base64 encodes it. This is slightly better than having all of your devices with the same Admin password but is only as secure as the cipher you use.

There are some things to beware of with this approach:

- The password is only as secure as the cipher
- Anyone that has access to this script, also has Admin access to all of your Macs
- As written this example is useful for temporary admin access to specific machines and not something to deploy globally

```
p=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' | tr '[A-Z]' '[K-ZA-J]' | tr 0-9 4-90-3 | base64`
```


# start logging

exec 1>> $log 2>&1

# Begin Script Body

echo "Creating new local admin account [$adminaccountname]"
p=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' | tr '[A-Z]' '[K-ZA-J]' | tr 0-9 4-90-3 | base64`


## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3
