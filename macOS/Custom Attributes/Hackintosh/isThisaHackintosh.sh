#!/bin/bash
#set -x

############################################################################################
##
## Extension Attribute script to try and test if this is a hackintosh or not
##
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
exec &>/dev/null

#Let's check for a few things..

# If we're running on AMD We're almost certainly on a Hack Mac
processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string)
if [[ "$processor" == *"AMD"* ]]; then

    hackintosh=true
    CPU="AMD"
    echo "this is probably a hackintosh - AMB"
    echo "$(date) | [$processor] found, Rosetta not needed"
    
fi

# If com.apple.drive.AppleSMC isn't loaded, we're likely on a Hack Mac
if [[ ! $(kextstat -b com.apple.driver.AppleSMC | grep "com.apple.driver.AppleSMC" | grep -v grep) ]]; then

    hackintosh=true
    AppleSMCMissing="AppleSMCMissing"

fi

# If FakeSMC.kext is in our kext list, we're likely on a Hack Mac
if [[ $(kextstat -b FakeSMC.kext | grep "FakeSMC.kext" | grep -v grep) ]]; then

    hackintosh=true
    FakeSMC="FakeSMC"

fi


exec > /dev/tty
if [[ $hackintosh == "true" ]]; then

    echo "Hackintosh ($CPU $AppleSMCMissing $FakeSMC)"

    
else

    echo "Real Mac"

fi