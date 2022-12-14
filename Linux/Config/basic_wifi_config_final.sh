#!/bin/bash

#############################################################################################################################
################### CUSTOM INPUT VARIABLES
#############################################################################################################################

# Set this variables to match the wifi name, password, ssid, and interface for the desired wifi network. 
WIFI=wifi_name
NETWORK_TYPE=network_type
PSWD=wifi_password
SSID=wifi_ssid
IFNAME=wifi_interface

# Set this variable to either "yes" to enable autoconnect or "no" to disable it. 
AUTOCONNECT=yes

# Set this variable to either "yes" to enable connections to hidden wifi networks or "no" to disable it.
HIDDEN=yes

# Set this variable to either none, ieeee8021x, wpa-psk, wpa-eap, sae to update the security type for the given wifi profile. 
SECURITY=none

# Set this variable to either none or auto to update the proxy settings for the given wifi profile. 
PROXY=auto

#############################################################################################################################
################### CHECK FOR PROPER VARIABLE STATUS 
#############################################################################################################################

# WIFI
if [[ -z $WIFI || $WIFI == "wifi_name" ]]; then
    echo "The WIFI name has not been updated. Please correct."
    exit 1
fi

# NETWORK TYPE
if [[ -z $NETWORK_TYPE || ($NETWORK_TYPE != "adsl" && $NETWORK_TYPE != "bond" && $NETWORK_TYPE != "bond-slave" && $NETWORK_TYPE != "bridge" && $NETWORK_TYPE != "bridge-slave" && $NETWORK_TYPE != "bluetooth" && $NETWORK_TYPE != "cdma" && $NETWORK_TYPE != "ethernet" && $NETWORK_TYPE != "generic" && $NETWORK_TYPE != "gsm" && $NETWORK_TYPE != "infiniband" && $NETWORK_TYPE != "olpc-mesh" && $NETWORK_TYPE != "pppoe" && $NETWORK_TYPE != "team" && $NETWORK_TYPE != "team-slave" && $NETWORK_TYPE != "vlan" && $NETWORK_TYPE != "vpn" && $NETWORK_TYPE != "wifi" && $NETWORK_TYPE != "wimax") ]]; then
    echo "The WIFI name has not been updated or set to one of the allowed connection types (adsl, bond, bond-slave, bridge, bridge-slave, bluetooth, cdma, ethernet, generic, gsm, infiniband, olpc-mesh, pppoe, team, team-slave, vlan, vpn, wifi, wimax.). Please correct."
    exit 1
fi

# PSWD
if [[ -z $PSWD || $PSWD == "wifi_password" ]]; then
    echo "The WIFI password has not been updated. Please correct."
    exit 1
fi

# SSID
if [[ -z $SSID || $SSID == "wifi_ssid" ]]; then
    echo "The WIFI name has not been updated. Please correct."
    exit 1
fi

# IFNAME (May be additional requirements)
if [[ -z $IFNAME || $IFNAME == "wifi_interface" || $IFNAME == *" "* || $IFNAME == *"/"* ]]; then
    echo "The interface name has not been updated or does not meet requirements (no spaces, no forward slash). Please correct."
    exit 1
fi

# AUTOCONNECT
if [ $AUTOCONNECT != "yes" && $AUTOCONNECT != "no" ]; then
    echo "Autconnect settings have been set to something other than the allowed values (yes, no). Please correct."
    exit 1
fi

# HIDDEN
if [ $HIDDEN != "yes" && $HIDDEN != "no" ]; then
    echo "Autconnect settings have been set to something other than the allowed values (yes, no). Please correct."
    exit 1
fi

# SECURITY
if [ $SECURITY != "none" && $SECURITY != "ieeee8021x"  && $SECURITY != "wpa-psk" && $SECURITY != "wpa-eap" && $SECURITY != "sae" ]; then
    echo "Security type settings   have been set to something other than the allowed values (none, ieeee8021x, wpa-psk, wpa-eap, sae). Please correct."
    exit 1

# PROXY
 if [ $PROXY != "none" && $PROXY != "auto" ]; then
    echo "Proxy settings have been set to something other than the allowed values (none, auto). Please correct."
    exit 1
fi

#############################################################################################################################
################### SCRIPT 
#############################################################################################################################

# Start of a bash "try-catch loop" that will safely exit the script if a command fails or causes an error. 
(
    # Set the error status
    set -e 

    # Add wifi network according to desired SSID, wifi type (ethernet, wifi, etc) and connection name
        nmcli connection add type $NETWORK_TYPE ifname $IFNAME con-name "$WIFI" ssid "$SSID"
        # Note that interface name is default as wlan0 but is also commonly eth0 or another value. This may need to be changed.     

        if (nmcli con show | grep "$WIFI" ); then
            echo "The connection" $WIFI "has been successfully addded."
        else 
            echo "There was an issue adding this connection. Please try again."
        fi

        # Connect to wifi via set SSID and password (from within /etc/network) 
        nmcli connection up "$WIFI"
        echo "The connection is up."

    # Enable or disable automatic wifi connection to a given wifi SSID
            nmcli connection modify "$WIFI" connection.autoconnect $AUTOCONNECT

        if (nmcli -g conncection.autoconnect con show "$WIFI" = $AUTOCONNECT); then   
            echo "Automatic wifi settings have been successfully udpated to" $AUTOCONNECT"."
        else
            echo "There was an issue updating this connection. Please try again."
        fi

    # Enable wifi connections to a hidden network (knowing only password and SSID and setting new network name for hidden network)
        nmcli dev wifi connect "$WIFI" password "$PSWD" hidden $HIDDEN
        echo "Settings related to hidden automatic wifi have been updated."

    # Set the security type for a given profile
    # Possible authentication values are none, ieeee8021x, wpa-psk, wpa-eap, sae.
        nmcli connection modify "$WIFI" 802-11-wireless-security.keym-mgmt $SECURITY

        if (nmcli -g 802-11-wireless-security.keym-mgmt con show "$WIFI" = $SECURITY); then 
            echo "Wifi security type settigs have been succcessfully updated to" $SECURITY"."
        else
            echo "There was an issue updating this connection. Please try again."
        fi

    # Alter proxy settings: either none or auto
        nmcli connection modify "$WIFI" proxy.method $PROXY

        if (nmcli -g proxy.method con show "$WIFI" = $PROXY); then 
            echo "Proxy settings have been succcessfully updated to" $PROXY"."
        else
            echo "There was an issue updating this connection. Please try again."
        fi
        
    # Apply changes/updates to wifi profile
        nmcli connection up "$SSID"
        echo "Wifi profile has been updated and changes have been applied."
)

ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    echo "There was an error. Please restart the script or contact your admin if the error persists."
    exit $ERROR_CODE
fi

# Final output message - to be configured TBD
echo "The script is finished running. The result will be sent in the necessary format."