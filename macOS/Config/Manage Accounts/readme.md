# Script to manage accounts

This script is an example showing how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to modify user accounts on macOS. This script provides examples for downgrading existing Admin accounts to standard users and also creating a new Admin account for IT use.

## Script Descriptions

### downgradeAdmintoStandard.sh - Remove admin access from end users

The concept here is that end users should not have Admin permissions over their Mac computers and instead will only have standard user rights. This prevents accidental or malicious changes to macOS but can also provide challenges for IT Admins. The goal is for all Admin tasks to be undertaken via Intune rather than logging on directly to the Mac itself.

There are obvious issues here in that Intune becomes the only way to manage the device. If the Mac loses the ability to be managed, then IT will also lose the ability to manage the device and it will need to be erased and macOS re-installed to recover.

The following variables exist.

```
abmcheck=true   # Only downgrade users if this device is ABM managed
downgrade=true  # If set to false, script will not do anything
```

Note: You will need to remove the # comment at the beginning of line 87, otherwise this script will not downgrade the user. This is to ensure you have read the script and know what it does.

#### Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3

### createAdminAccount.sh - Create temporary admin account

In this scenario, the purpose is to provide an IT Admin with ad-hoc access to macOS device when they require it.  The script would be assigned to an AAD device group such as 'Temporary Admin Access' and devices added to this group when an Admin requires access. Once the script runs, it will create the 'Local Admin' account. Once the IT Admin logs on to the Mac they should change the password.

## WARNING

This script has the potential to do a significant amount of damage to your environment. It is provided as an example and if you wish to achieve a task like this we strongly recommend that you spend significant time testing and modifying to suit your own needs.

The following variables exist. If you set downgradeexistingadmin = true the script will set all user accounts to be standard users.
```
adminaccountname="localadmin"       # This is the accountname of the new admin
adminaccountfullname="Local Admin"  # This is the full name of the new admin user
```

The new Admin account password is controlled by the following cipher based off the device serial number. In this example, the script determines the device serial number, then passes it through two really basic tr ciphers and finally base64 encodes it. This is slightly better than having all of your devices with the same Admin password but is only as secure as the cipher you use.

There are some things to beware of with this approach:

- The password is only as secure as the cipher
- Anyone that has access to this script, also has Admin access to all of your Macs
- As written this example is useful for temporary admin access to specific machines and not something to deploy globally

```
p=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' | tr '[A-Z]' '[K-ZA-J]' | tr 0-9 4-90-3 | base64`
```
#### Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3

### removeLocalAdminAccount.sh - Removes temporary admin account

This script searches for a named account and removes it.

The following variables exist.

```
adminaccountname="localadmin"       # This is the accountname of the new admin
adminaccountfullname="Local Admin"  # This is the full name of the new admin user
```

#### Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3

### serialToAdminPassword.sh - Generates password based on cipher

This is an example script to take a device serial and recalculate the temporary admin password for that device. It is not intended for deployment via Intune and would be run by IT Admin when trying to login to the Mac locally.

Example:

```
% ./serialToAdminPassword.sh
Enter device serial number :ABCD1234
Password: S0xNTjU2NzgK
```
