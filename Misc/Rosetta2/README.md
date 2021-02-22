# Rosetta 2 Installation Script

This script is am example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install Rosetta 2. In this case the script will check if Rosetta 2 is required and install of necessary.

## Scenario

This scripts intended usage scenario is to detect the processor type and then install Rosetta 2 if required. Rosetta 2 allowws Intel x86 binaries to run on new Apple Silicon Macs. You can find more information about Rosetta 2 here:

- [About the Rosetta Translation Environment](https://developer.apple.com/documentation/apple_silicon/about_the_rosetta_translation_environment)
- [If you need to install Rosetta 2 on your mac](https://support.apple.com/en-gb/HT211861)
- [Rosetta 2 on a Mac with Apple Silicon](https://support.apple.com/en-kw/guide/security/secebb113be1/web)

***Important: ***
This script requires a version of the Intune Company Portal newer than 2103 (March 2021)

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/Misc/Rosetta2/installRosetta2.sh)"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3

