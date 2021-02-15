#!/usr/bin/env bash
#set -x

############################################################################################
##
## Script to generate Admin Password from Serial Number
##
###########################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

##
## Notes
##
## This script is to support createAdminAccount.sh the cipher used in that script must match the cipher used here to generate the correct password
## i.e. ABCDEF000009 becomes S0xNTk9QNDQ0NDQzCg==
##
## WARNING: It is strongly recommended to change the cipher on line 45 before deploying into production

echo -ne "Enter device serial number :"
read serial
password=`echo $serial | tr '[A-Z]' '[K-ZA-J]' | tr 0-9 4-90-3 | base64`
echo "Password: $password"
