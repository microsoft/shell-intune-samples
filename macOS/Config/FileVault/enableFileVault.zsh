#!/bin/zsh
#set -x

############################################################################################
##
## Script to enable FileVault
## 
## VER 0.0.1
##
## Change Log
##
## 2022-11-15   - First draft
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



function checkIfFileVaultEnabled {

    if [[ $(sudo fdesetup isactive | grep "true") ]]; then

            echo "FilaVault is Enabled"

        else

            echo "FilaVault is Disabled"
    fi

}

function promptEndUserToRotateKey {

}

function checkIfRecoveryKeyHasBeenEscrowedToIntune {


}

checkIfFileVaultEnabled