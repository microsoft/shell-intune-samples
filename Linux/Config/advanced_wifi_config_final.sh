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

# Set this variable to an integer (0-infinity) that can be used to indicate a more preferred network that should be connected to automatically. Higher numbers indicate a higher preference. 
PRIORITY=10

# Set this variable to either "on" to establish a metered connection or "off" to continue using the wifi without restrictions.
METERED=on

# Each of these variables must be set before 802-1x settings can be modified.
EAP=peap
ID=username 
PHASE2AUTH=mschapv2

    # Set this variable to an integer between 1-3600 for the number of seconds to wait after an authentication attempt before failing. Default is 0 unless global default (25) is set.
    AUTH_TIMEOUT=5

# Set this variable to an integer between 1-3600 for the number of seconds between authentication attempts after a failed authentication. Default is 1 second. 
AUTH_SECONDS=5

# Set this variable to an integer between 1-100 for the maximum number of authentication failures for a set of user credentials. Default is 3 attempts.
AUTH_RETRIES=2 


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
    echo "The interface name has not been updated. Please correct."
    exit 1
fi

# AUTOCONNECT
if [[ $AUTOCONNECT != "yes" && $AUTOCONNECT != "no" ]]; then
    echo "Autconnect settings have been set to something other than the allowed values (yes, no). Please correct."
    exit 1
fi

# HIDDEN
if [[ $HIDDEN != "yes" && $HIDDEN != "no" ]]; then
    echo "Autconnect settings have been set to something other than the allowed values (yes, no). Please correct."
    exit 1
fi

# SECURITY
if [[ $SECURITY != "none" && $SECURITY != "ieeee8021x"  && $SECURITY != "wpa-psk" && $SECURITY != "wpa-eap" && $SECURITY != "sae" ]]; then
    echo "Security type settings have been set to something other than the allowed values (none, ieeee8021x, wpa-psk, wpa-eap, sae). Please correct."
    exit 1
fi

# PROXY
 if [[ $PROXY != "none" && $PROXY != "auto" ]]; then
    echo "Proxy settings have been set to something other than the allowed values (none, autoconnect). Please correct."
    exit 1
fi

# PRIORITY
if ! [[ $PRIORITY =~ ^[0-9]+$ ]]; then
    echo "Priority settings have been set to something other than the accepted values (integer value). Please correct."
    exit 1
 fi

# METERED
if [[ $METERED != "on" && $METERED != "off" && $METERED != "unknown" ]]; then 
    echo "Metered connection settings have been set to something other than the accepted values (on, off, unknown). Please correct."
    exit 1
fi 

# EAP
if [[ -z $EAP || ($EAP != "leap" && $EAP != "pwd" && $EAP != "md5" && $EAP != "tls" && $EAP != "ttls" && $EAP != "peap" && $EAP != "fast") ]]; then
    echo "EAP connection settings have been set to something other than the accepted values (md5, tls, ttls, peap, fast, leap, pwd). Please correct."
    exit 1
fi 

# ID
if [[ -z $ID || $IFNAME == "username" ]]; then
    echo "The user ID has not been updated. Please correct."
    exit 1
fi

# PHASE2AUTH
if [ $EAP == "ttls" ]; then 
    if [[ -z $PHASE2AUTH || ($PHASE2AUTH != "pap" && $PHASE2AUTH != "chap" && $PHASE2AUTH != "mschap" && $PHASE2AUTH != "mschapv2") ]]; then
        echo "Phase 2 Authentication settings for TTLS have been set to something other than the accepted values (pap, chap, mschap, mschapv2). Please correct."
        exit 1
    fi
elif [ $EAP == "peap"]; then
    if [[ -z $PHASE2AUTH || ($PHASE2AUTH != "gtc" && $PHASE2AUTH != "otp" && $PHASE2AUTH != "md5" && $PHASE2AUTH != "tls") ]]; then
        echo "Phase 2 Authentication settings for PEAP have been set to something other than the accepted values (gtc, otp, md5, tls). Please correct."
        exit 1
    fi
else
    echo "An error occured with Phase 2 Authentication settings and EAP status. Contact your admin if this issue persists."
    exit 1
fi

# AUTH_TIMEOUT
if ! [[ $AUTH_TIMEOUT =~ ^[0-9]+$ && $AUTH_TIMEOUT -ge -2147483648 && $AUTH_TIMEOUT -le 2147483647 ]]; then
    echo "Authentication timeout settings have been set to something other than the accepted values (32-bit integer). Please correct."  
    exit 1
fi 

# AUTH_SECONDS
if ! [[ $AUTH_SECONDS =~ ^[0-9]+$ && $AUTH_SECONDS -ge 1 && $AUTH_SECONDS -le 3600 ]]; then
    echo "Authentication second settings have been set to something other than the accepted values (integer between 1-3600). Please correct."
    exit 1
fi

# AUTH_RETRIES
if ! [[ $AUTH_RETRIES =~ ^[0-9]+$ && $AUTH_RETRIES -ge 1 && $AUTH_RETRIES -le 100 ]]; then
    echo "Authentication retry settings have been set to something other than the accepted values (integer between 1-100). Please correct."
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
        nmcli connection add type wifi ifname $IFNAME con-name "$WIFI" ssid "$SSID"
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

    # Connect to a more preferred network if available (Only an option when wireless type is Enterprise and automatic connection is enabled))
    # Note: in order to make a particular network more or less preferred, the priortiy value can be set from 0-etc with higher numbers being the most preferred. 
        nmcli connection modify "$WIFI" connection.autoconnect-priority $PRIORITY

        if (nmcli -g connection.autoconnect-priority con show "$WIFI" = $PRIORITY); then
            echo "Network preference settings have been successfully updated to give" $WIFI "a preference of" $PRIORITY"."
        else
            echo "There was an issue updating this connection. Please try again."
        fi

    # Setting a metered connection limit that restricts or permits a device from using the available data on a given Wifi Network.
        # Possible values are on, off, or unknown 
        nmcli connection modify "$WIFI" connection.metered $METERED
            
        if (nmcli -g connection.metered con show "$WIFI" = $METERED); 
            echo "Metered connection settings have been succcessfully updated to" $METERED"."
        else
            echo "There was an issue updating this connection. Please try again."
        fi

    # Set the number of seconds to wait after an authentication attempt before failing between 1-3600. Default is 0 or 25 if global default is not set.
        # Select Extensible Authentication Protocol (EAP) type.
        nmcli con edit "$WIFI"

            # These steps are required before you can edit 802-1x

            # Set EAP type
            set 802-1x.eap $EAP 
            set 802-1x.identity $ID
            set 802-1x.phase2-auth $PHASE2AUTH
            # Set number of seconds for auth-timeout
            set 802-1x.auth-timeout $AUTH_TIMEOUT
            save
            quit
        
        if (nmcli -g 802-1x.auth-timeout con show "$WIFI" = $AUTH_TIMEOUT); then
            echo "Authentication failure settings have been succcessfully updated to" $AUTH_TIMEOUT "seconds between an authentication attempt and an authentication failure."
        else
            echo "There was an issue updating this connection. Please try again."
        fi

    # Set the number of seconds between authentication attempts after a failed authentication between 1-3600. Default is 1 second. 
        nmcli connection modify "$WIFI" connection.auth $AUTH_SECONDS
        echo "Settings related to the number of seconds between authentication attempts have been updated."

        if (nmcli -g connection.auth con show "$WIFI" = $AUTH_SECONDS); then
            echo "Authentication settings have been succcessfully updated to" $AUTH_SECONDS "between attempts following a failed authentication attempt."
        else
            echo "There was an issue updating this connection. Please try again."
        fi

    # Define the maximum number of authentication failures for a set of user credentials between 1-100. Default is 3 attempts. 
        nmcli connection modify "$WIFI" connection.auth-retries $AUTH_RETRIES

        if (nmcli -g connection.auth-retries con show $WIFI = $AUTH_RETRIES); then
            echo "Authentication failure settigs have been succcessfully updated to" $AUTH_RETRIES "attempts for each set of user credentials."
        else
            echo "There was an issue updating this connection. Please try again."
        fi

    # Set the security type for a given profile
    # Possible authentication values are none, ieeee8021x, wpa-psk, wpa-eap, sae.
        nmcli connection modify "$WIFI" 802-11-wireless-security.keym-mgmt $SECURITY

        if (nmcli -g 802-11-wireless-security.keym-mgmt con show "$WIFI" = $SECURITY); then 
            echo "Wifi security type settings have been succcessfully updated to" $SECURITY"."
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