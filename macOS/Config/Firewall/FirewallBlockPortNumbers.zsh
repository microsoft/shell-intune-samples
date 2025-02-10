#!/bin/zsh
#set -x
############################################################################################
##
## Script to block sselected port numbers from macOS Firewall
##
############################################################################################

## Copyright (c) 2025 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables
appname="FirewallBlockPortNumbers"                                                                          # The name of our script
logandmetadir="$HOME/Library/Logs/Microsoft/IntuneScripts/$appname"                                         # The location of our logs and last updated data
log="$logandmetadir/$appname.log"                                                                           # The location of the script log file
abmcheck=true                                                                                               # Install this application if this device is ABM manage
port135_tcp=true                                                                                            # Blocks Port Number 135 TCP used by Microsoft RPC, which can be exploited for remote code execution.
port135_udp=true                                                                                            # Blocks Port Number 135 UDP used by Microsoft RPC, which can be exploited for remote code execution.
port137_139_tcp=true                                                                                        # Blocks Port Numbers 137-139 TCP used by NetBIOS, which can be a vector for various attacks.
port137_139_udp=true                                                                                        # Blocks Port Numbers 137-139 UDP used by NetBIOS, which can be a vector for various attacks.
port445_tcp=true                                                                                            # Blocks Port Number 445 TCP used by Microsoft-DS (Active Directory, Windows shares), which is often targeted by malware.
port1433-1434_tcp=true                                                                                      # Blocks Port Numbers 1433-1434 TCP used by Microsoft SQL Server, which can be exploited if not properly secured.
port1433-1434_udp=true                                                                                      # Blocks Port Numbers 1433-1434 UDP used by Microsoft SQL Server, which can be exploited if not properly secured.
port3389_tcp=true                                                                                           # Blocks Port Number 3389 TCP used by Remote Desktop Protocol (RDP), which is common target for brute force attacks.
port1900_udp=true                                                                                           # Blocks Port Number 1900 UDP used by Universal Plud and Play (UPnP), which can be exploited for network discovery and attacks.
port20-21_tcp=true                                                                                          # Blocks Port Numbers 20-21 TCP used by FTP, which can be insecure if not properly configured.
port20-21_udp=true                                                                                          # Blocks Port Numbers 20-21 UDP used by FTP, which can be insecure if not properly configured.
port23_tcp=true                                                                                             # Blocks Port Numbers 23 TCP used by Telnet, which transmits data in plaintext and is insecure.

# Check if the log directory has been created
if [ -d $logandmetadir ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# Backup existing pf.conf to cp.conf.backup
backup() {
    echo "$(date) | Backing up firewall configurations..."
    cp -f /etc/pf.conf /etc/pf.conf.backup
    echo "$(date) | Done."
}

# Function for blocking Port Number 135 TCP
port135_tcp() {
    PORT=135
    PROTO="tcp"
    RULE="block in proto $PROTO from any to any port $PORT"

    # Check if the rule already exists in /etc/pf.conf
    if grep -q "$RULE" /etc/pf.conf; then
        echo "$(date) | Port $PORT/$PROTO is already disabled."
    else
        echo "$(date) | Disabling port $PORT/$PROTO permanently..."

        # Append the rule to /etc/pf.conf
        echo "$RULE" | tee -a /etc/pf.conf > /dev/null

        # Reload pf rules
        pfctl -f /etc/pf.conf >/dev/null 2>&1
        pfctl -E >/dev/null 2>&1

        echo "$(date) | Port $PORT/$PROTO has been disabled permanently."
    fi
}

# Function for blocking Port Number 135 UDP
port135_udp() {
    PORT=135
    PROTO="udp"
    RULE="block in proto $PROTO from any to any port $PORT"

    # Check if the rule already exists in /etc/pf.conf
    if grep -q "$RULE" /etc/pf.conf; then
        echo "$(date) | Port $PORT/$PROTO is already disabled."
    else
        echo "$(date) | Disabling port $PORT/$PROTO permanently..."

        # Append the rule to /etc/pf.conf
        echo "$RULE" | tee -a /etc/pf.conf > /dev/null

        # Reload pf rules
        pfctl -f /etc/pf.conf >/dev/null 2>&1
        pfctl -E >/dev/null 2>&1

        echo "$(date) | Port $PORT/$PROTO has been disabled permanently."
    fi
}

# Function for blocking Port Numbers 137-139 TCP
port137_139_tcp() {
    PORTS=(137 138 139)
    PROTO="tcp"
    
    # Check if the ports are already disabled
    for PORT in "${PORTS[@]}"; do
        RULE="block in proto $PROTO from any to any port $PORT"
        if grep -q "$RULE" $PF_CONF; then
            echo "$(date) | Port $PORT/$PROTO is already disabled in pf.conf."
        else
            echo "$(date) | Disabling port $PORT/$PROTO in pf.conf..."
            echo "$RULE" | sudo tee -a $PF_CONF > /dev/null
        fi
    done

    # Reload pf rules
    pfctl -f $PF_CONF >/dev/null 2>&1
    pfctl -E >/dev/null 2>&1

    echo "$(date) | Ports ${PORTS[*]}/$PROTO have been disabled permanently in pf.conf."
}

# Function for blocking Port Numbers 137-139 UDP
port137_139_udp() {
    PORTS=(137 138 139)
    PROTO="udp"
    
    # Check if the ports are already disabled
    for PORT in "${PORTS[@]}"; do
        RULE="block in proto $PROTO from any to any port $PORT"
        if grep -q "$RULE" $PF_CONF; then
            echo "$(date) | Port $PORT/$PROTO is already disabled in pf.conf."
        else
            echo "$(date) | Disabling port $PORT/$PROTO in pf.conf..."
            echo "$RULE" | sudo tee -a $PF_CONF > /dev/null
        fi
    done

    # Reload pf rules
    pfctl -f $PF_CONF >/dev/null 2>&1
    pfctl -E >/dev/null 2>&1

    echo "$(date) | Ports ${PORTS[*]}/$PROTO have been disabled permanently in pf.conf."
}

# Start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $appname"
echo "############################################################"
echo ""

# Is this a ABM DEP device?
if [ "$abmcheck" = false ]; then
  echo "$(date) | Checking MDM Profile Type"
  profiles status -type enrollment | grep "Enrolled via DEP: Yes"
  if [ ! $? == 0 ]; then
    echo "$(date) | This device is not ABM managed. This means that device is BYOD-device. This script needs to be run. Let's continue... "
  else
    echo "$(date) | Device is ABM Managed. No need to run this script. Closing script..."
    exit 0;
  fi
fi

# Backup cp.conf
backup

# Disable Port Number 135 TCP
if [ "$port135_tcp" = true ]; then
  port135_tcp
else
    echo "$(date) | Skipping disabling Port Number 135 TCP..."
fi

# Disable Port Number 135 UDP
if [ "$port135_udp" = true ]; then
    port135_udp
else
    echo "$(date) | Skipping disabling Port Number 135 UDP..."
fi

# Disable Port Number 137-139 TCP
if [ "$port137_139_tcp" = true ]; then
    port137-139_tcp
else
    echo "$(date) | Skipping disabling Port Numbers 137-139 TCP..."
fi

# Disable Port Number 137-139 UDP
if [ "$port137_139_udp" = true ]; then
    port137-139_udp
else
    echo "$(date) | Skipping disabling Port Number 137-139 UDP..."
fi