#!/bin/zsh
#set -x
############################################################################################
##
## Script to block selected port numbers from macOS Firewall
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
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"                                              # The location of our logs and last updated data
log="$logandmetadir/$appname.log"                                                                           # The location of the script log file
abmcheck=true                                                                                               # Run this script if this device is ABM managed
port135_in_tcp=true                                                                                         # Blocks inbound TCP Port Number 135 used by Microsoft RPC, which can be exploited for remote code execution.
port135_in_udp=true                                                                                         # Blocks inbound UDP Port Number 135 used by Microsoft RPC, which can be exploited for remote code execution.
port137_139_in_tcp=true                                                                                     # Blocks inbound TCP Port Numbers 137-139 used by NetBIOS, which can be a vector for various attacks.
port137_139_in_udp=true                                                                                     # Blocks inbound UDP Port Numbers 137-139 used by NetBIOS, which can be a vector for various attacks.
port445_in_tcp=true                                                                                         # Blocks inbound TCP Port Number 445 used by Microsoft-DS (Active Directory, Windows shares), which is often targeted by malware.
port1433_1434_in_tcp=true                                                                                   # Blocks inbound TCP Port Numbers 1433-1434 used by Microsoft SQL Server, which can be exploited if not properly secured.
port1433_1434_in_udp=true                                                                                   # Blocks inbound TCP Port Numbers 1433-1434 used by Microsoft SQL Server, which can be exploited if not properly secured.
port3389_in_tcp=true                                                                                        # Blocks inbound TCP Port Number 3389 used by Remote Desktop Protocol (RDP), which is common target for brute force attacks.
port1900_in_udp=true                                                                                        # Blocks inbound UDP Port Number 1900 used by Universal Plud and Play (UPnP), which can be exploited for network discovery and attacks.
port20_21_in_tcp=true                                                                                       # Blocks inbound TCP Port Numbers 20-21 used by FTP, which can be insecure if not properly configured.
port20_21_in_udp=true                                                                                       # Blocks inbound UDP Port Numbers 20-21 used by FTP, which can be insecure if not properly configured.
port23_in_tcp=true                                                                                          # Blocks inbound TCP Port Numbers 23 used by Telnet, which transmits data in plaintext and is insecure.
port110_out_tcp=true                                                                                        # Blocks outbound TCP Port Number 110 used by POP3 to prevent retrieval of email via POP3 clients.
port995_out_tcp=true                                                                                        # Blocks outbound TCP Port Number 995 used by secure POP3 to prevent retrieval of email via POP3 clients.
port143_out_tcp=true                                                                                        # Blocks outbound TCP Port Number 143 used by IMAP to prevent retrieval of email via IMAP clients.
port993_out_tcp=true                                                                                        # Blocks outbound TCP Port Number 993 used by secure IMAP to prevent retrieval of email via IMAP clients.

# Check if the log directory has been created
if [ -d $logandmetadir ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# Backup original pf.conf to cp.conf.backup
backup() {
    if [ -f /etc/pf.conf.backup ]; then
        echo "$(date) | Backup file already exists. No new backup created."
    else
        echo "$(date) | Backing up firewall configurations..."
        cp -f /etc/pf.conf /etc/pf.conf.backup
        echo "$(date) | Done."
    fi
}

# Function for blocking inbound Port Number 135 TCP
port135_in_tcp() {
    PORT=135
    PROTO="tcp"
    RULE="block in proto $PROTO from any to any port $PORT"
    PF_CONF="/etc/pf.conf"

    # Check if the rule already exists in /etc/pf.conf
    if grep -q "$RULE" $PF_CONF; then
        echo "$(date) | Inbound port $PORT/$PROTO is already disabled."
    else
        echo "$(date) | Disabling inbound port $PORT/$PROTO permanently..."

        # Append the rule to /etc/pf.conf
        echo "$RULE" | tee -a $PF_CONF > /dev/null

        # Reload pf rules
        pfctl -f $PF_CONF >/dev/null 2>&1
        pfctl -E >/dev/null 2>&1

        echo "$(date) | Inbound port $PORT/$PROTO has been disabled permanently."
    fi
}

# Function for blocking inbound Port Number 135 UDP
port135_in_udp() {
    PORT=135
    PROTO="udp"
    RULE="block in proto $PROTO from any to any port $PORT"
    PF_CONF="/etc/pf.conf"

    # Check if the rule already exists in /etc/pf.conf
    if grep -q "$RULE" $PF_CONF; then
        echo "$(date) | Inbound port $PORT/$PROTO is already disabled."
    else
        echo "$(date) | Disabling inbound port $PORT/$PROTO permanently..."

        # Append the rule to /etc/pf.conf
        echo "$RULE" | tee -a $PF_CONF > /dev/null

        # Reload pf rules
        pfctl -f $PF_CONF >/dev/null 2>&1
        pfctl -E >/dev/null 2>&1

        echo "$(date) | Inbound port $PORT/$PROTO has been disabled permanently."
    fi
}

# Function for blocking inbound Port Numbers 137-139 TCP
port137_139_in_tcp() {
    PORTS=(137 138 139)
    PROTO="tcp"
    PF_CONF="/etc/pf.conf"
    
    # Check if the ports are already disabled
    for PORT in "${PORTS[@]}"; do
        RULE="block in proto $PROTO from any to any port $PORT"
        if grep -q "$RULE" $PF_CONF; then
            echo "$(date) | Inbound port $PORT/$PROTO is already disabled."
        else
            echo "$(date) | Disabling inbound port $PORT/$PROTO permanently..."

            # Append the rule to /etc/pf.conf
            echo "$RULE" | sudo tee -a $PF_CONF > /dev/null
            
            # Reload pf rules
            pfctl -f $PF_CONF >/dev/null 2>&1
            pfctl -E >/dev/null 2>&1

            echo "$(date) | Inbound port ${PORT[*]}/$PROTO have been disabled permanently."
        fi
    done
}

# Function for blocking inbound Port Numbers 137-139 UDP
port137_139_in_udp() {
    PORTS=(137 138 139)
    PROTO="udp"
    PF_CONF="/etc/pf.conf"
    
    # Check if the ports are already disabled
    for PORT in "${PORTS[@]}"; do
        RULE="block in proto $PROTO from any to any port $PORT"
        if grep -q "$RULE" $PF_CONF; then
            echo "$(date) | Inbound port $PORT/$PROTO is already disabled."
        else
           echo "$(date) | Disabling inbound port $PORT/$PROTO permanently..."

           # Append the rule to /etc/pf.conf
           echo "$RULE" | sudo tee -a $PF_CONF > /dev/null

           # Reload pf rules
           pfctl -f $PF_CONF >/dev/null 2>&1
           pfctl -E >/dev/null 2>&1

           echo "$(date) | Inbound port ${PORT[*]}/$PROTO have been disabled permanently."
        fi
    done
}

# Function for blocking inbound Port Number 445 TCP
port445_in_tcp() {
    PORT=445
    PROTO="tcp"
    RULE="block in proto $PROTO from any to any port $PORT"
    PF_CONF="/etc/pf.conf"

    # Check if the rule already exists in /etc/pf.conf
    if grep -q "$RULE" $PF_CONF; then
        echo "$(date) | Inbound port $PORT/$PROTO is already disabled."
    else
        echo "$(date) | Disabling inbound port $PORT/$PROTO permanently..."

        # Append the rule to /etc/pf.conf
        echo "$RULE" | tee -a $PF_CONF > /dev/null

        # Reload pf rules
        pfctl -f $PF_CONF >/dev/null 2>&1
        pfctl -E >/dev/null 2>&1

        echo "$(date) | Inbound port $PORT/$PROTO has been disabled permanently."
    fi
}

# Function for blocking inbound Port Numbers 1433-1434 TCP
port1433_1434_in_tcp() {
    PORTS=(1433 1434)
    PROTO="tcp"
    PF_CONF="/etc/pf.conf"
    
    # Check if the ports are already disabled
    for PORT in "${PORTS[@]}"; do
        RULE="block in proto $PROTO from any to any port $PORT"
        if grep -q "$RULE" $PF_CONF; then
            echo "$(date) | Inbound port $PORT/$PROTO is already disabled."
        else
           echo "$(date) | Disabling inbound port $PORT/$PROTO permanently..."

           # Append the rule to /etc/pf.conf
           echo "$RULE" | sudo tee -a $PF_CONF > /dev/null

           # Reload pf rules
           pfctl -f $PF_CONF >/dev/null 2>&1
           pfctl -E >/dev/null 2>&1

           echo "$(date) | Inbound port ${PORT[*]}/$PROTO have been disabled permanently."
        fi
    done
}

# Function for blocking inbound Port Numbers 1433-1434 UDP
port1433_1434_in_udp() {
    PORTS=(1433 1434)
    PROTO="udp"
    PF_CONF="/etc/pf.conf"
    
    # Check if the ports are already disabled
    for PORT in "${PORTS[@]}"; do
        RULE="block in proto $PROTO from any to any port $PORT"
        if grep -q "$RULE" $PF_CONF; then
            echo "$(date) | Inbound port $PORT/$PROTO is already disabled."
        else
           echo "$(date) | Disabling inbound port $PORT/$PROTO permanently..."

           # Append the rule to /etc/pf.conf
           echo "$RULE" | sudo tee -a $PF_CONF > /dev/null

           # Reload pf rules
           pfctl -f $PF_CONF >/dev/null 2>&1
           pfctl -E >/dev/null 2>&1

           echo "$(date) | Inbound port ${PORT[*]}/$PROTO have been disabled permanently."
        fi
    done
}

# Function for blocking inbound Port Number 3389 TCP
port3389_in_tcp() {
    PORT=3389
    PROTO="tcp"
    RULE="block in proto $PROTO from any to any port $PORT"
    PF_CONF="/etc/pf.conf"

    # Check if the rule already exists in /etc/pf.conf
    if grep -q "$RULE" $PF_CONF; then
        echo "$(date) | Inbound port $PORT/$PROTO is already disabled."
    else
        echo "$(date) | Disabling inbound port $PORT/$PROTO permanently..."

        # Append the rule to /etc/pf.conf
        echo "$RULE" | tee -a $PF_CONF > /dev/null

        # Reload pf rules
        pfctl -f $PF_CONF >/dev/null 2>&1
        pfctl -E >/dev/null 2>&1

        echo "$(date) | Inbound port $PORT/$PROTO has been disabled permanently."
    fi
}

# Function for blocking inbound Port Number 1900 UDP
port1900_in_udp() {
    PORT=1900
    PROTO="udp"
    RULE="block in proto $PROTO from any to any port $PORT"
    PF_CONF="/etc/pf.conf"

    # Check if the rule already exists in /etc/pf.conf
    if grep -q "$RULE" $PF_CONF; then
        echo "$(date) | Inbound port $PORT/$PROTO is already disabled."
    else
        echo "$(date) | Disabling inbound port $PORT/$PROTO permanently..."

        # Append the rule to /etc/pf.conf
        echo "$RULE" | tee -a $PF_CONF > /dev/null

        # Reload pf rules
        pfctl -f $PF_CONF >/dev/null 2>&1
        pfctl -E >/dev/null 2>&1

        echo "$(date) | Inbound port $PORT/$PROTO has been disabled permanently."
    fi
}

# Function for blocking inbound Port Numbers 20-21 TCP
port20_21_in_tcp() {
    PORTS=(20 21)
    PROTO="tcp"
    PF_CONF="/etc/pf.conf"
    
    # Check if the ports are already disabled
    for PORT in "${PORTS[@]}"; do
        RULE="block in proto $PROTO from any to any port $PORT"
        if grep -q "$RULE" $PF_CONF; then
            echo "$(date) | Inbound port $PORT/$PROTO is already disabled."
        else
            echo "$(date) | Disabling inbound port $PORT/$PROTO permanently..."

            # Append the rule to /etc/pf.conf
            echo "$RULE" | sudo tee -a $PF_CONF > /dev/null
           
            # Reload pf rules
            pfctl -f $PF_CONF >/dev/null 2>&1
            pfctl -E >/dev/null 2>&1

            echo "$(date) | Inbound port ${PORT[*]}/$PROTO have been disabled permanently."
        fi
    done
}

# Function for blocking inbound Port Numbers 20-21 UDP
port20_21_in_udp() {
    PORTS=(20 21)
    PROTO="udp"
    PF_CONF="/etc/pf.conf"
    
    # Check if the ports are already disabled
    for PORT in "${PORTS[@]}"; do
        RULE="block in proto $PROTO from any to any port $PORT"
        if grep -q "$RULE" $PF_CONF; then
            echo "$(date) | Inbound port $PORT/$PROTO is already disabled."
        else
            echo "$(date) | Disabling inbound port $PORT/$PROTO permanently..."

            # Append the rule to /etc/pf.conf
            echo "$RULE" | sudo tee -a $PF_CONF > /dev/null

            # Reload pf rules
            pfctl -f $PF_CONF >/dev/null 2>&1
            pfctl -E >/dev/null 2>&1

            echo "$(date) | Inbound port ${PORT[*]}/$PROTO have been disabled permanently."
        fi
    done
}

# Function for blocking inbound Port Number 23 TCP
port23_in_tcp() {
    PORT=23
    PROTO="tcp"
    RULE="block in proto $PROTO from any to any port $PORT"
    PF_CONF="/etc/pf.conf"

    # Check if the rule already exists in /etc/pf.conf
    if grep -q "$RULE" $PF_CONF; then
        echo "$(date) | Inbound port $PORT/$PROTO is already disabled."
    else
        echo "$(date) | Disabling inbound port $PORT/$PROTO permanently..."

        # Append the rule to /etc/pf.conf
        echo "$RULE" | tee -a $PF_CONF > /dev/null

        # Reload pf rules
        pfctl -f $PF_CONF >/dev/null 2>&1
        pfctl -E >/dev/null 2>&1

        echo "$(date) | Inbound port $PORT/$PROTO has been disabled permanently."
    fi
}

# Function for blocking outbound Port Number 110 TCP
port110_out_tcp() {
    PORT=110
    PROTO="tcp"
    RULE="block out proto $PROTO from any to any port $PORT"
    PF_CONF="/etc/pf.conf"

    # Check if the rule already exists in /etc/pf.conf
    if grep -q "$RULE" $PF_CONF; then
        echo "$(date) | Outbound port $PORT/$PROTO is already disabled."
    else
        echo "$(date) | Disabling outbound port $PORT/$PROTO permanently..."

        # Append the rule to /etc/pf.conf
        echo "$RULE" | tee -a $PF_CONF > /dev/null

        # Reload pf rules
        pfctl -f $PF_CONF >/dev/null 2>&1
        pfctl -E >/dev/null 2>&1

        echo "$(date) | Outbound port $PORT/$PROTO has been disabled permanently."
    fi
}

# Function for blocking outbound Port Number 995 TCP
port995_out_tcp() {
    PORT=995
    PROTO="tcp"
    RULE="block out proto $PROTO from any to any port $PORT"
    PF_CONF="/etc/pf.conf"

    # Check if the rule already exists in /etc/pf.conf
    if grep -q "$RULE" $PF_CONF; then
        echo "$(date) | Outbound port $PORT/$PROTO is already disabled."
    else
        echo "$(date) | Disabling outbound port $PORT/$PROTO permanently..."

        # Append the rule to /etc/pf.conf
        echo "$RULE" | tee -a $PF_CONF > /dev/null

        # Reload pf rules
        pfctl -f $PF_CONF >/dev/null 2>&1
        pfctl -E >/dev/null 2>&1

        echo "$(date) | Outbound port $PORT/$PROTO has been disabled permanently."
    fi
}

# Function for blocking outbound Port Number 143 TCP
port143_out_tcp() {
    PORT=143
    PROTO="tcp"
    RULE="block out proto $PROTO from any to any port $PORT"
    PF_CONF="/etc/pf.conf"

    # Check if the rule already exists in /etc/pf.conf
    if grep -q "$RULE" $PF_CONF; then
        echo "$(date) | Outbound port $PORT/$PROTO is already disabled."
    else
        echo "$(date) | Disabling outbound port $PORT/$PROTO permanently..."

        # Append the rule to /etc/pf.conf
        echo "$RULE" | tee -a $PF_CONF > /dev/null

        # Reload pf rules
        pfctl -f $PF_CONF >/dev/null 2>&1
        pfctl -E >/dev/null 2>&1

        echo "$(date) | Outbound port $PORT/$PROTO has been disabled permanently."
    fi
}

# Function for blocking outbound Port Number 993 TCP
port993_out_tcp() {
    PORT=993
    PROTO="tcp"
    RULE="block out proto $PROTO from any to any port $PORT"
    PF_CONF="/etc/pf.conf"

    # Check if the rule already exists in /etc/pf.conf
    if grep -q "$RULE" $PF_CONF; then
        echo "$(date) | Outbound port $PORT/$PROTO is already disabled."
    else
        echo "$(date) | Disabling outbound port $PORT/$PROTO permanently..."

        # Append the rule to /etc/pf.conf
        echo "$RULE" | tee -a $PF_CONF > /dev/null

        # Reload pf rules
        pfctl -f $PF_CONF >/dev/null 2>&1
        pfctl -E >/dev/null 2>&1

        echo "$(date) | Outbound port $PORT/$PROTO has been disabled permanently."
    fi
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
if [ "$abmcheck" = true ]; then
  echo "$(date) | Checking MDM Profile Type"
  profiles status -type enrollment | grep "Enrolled via DEP: Yes"
  if [ ! $? == 0 ]; then
    echo "$(date) | This device is not ABM managed"
    exit 0;
  else
    echo "$(date) | Device is ABM Managed"
  fi
fi

# Backup cp.conf
backup

# Disable inbound Port Number 135 TCP
if [ "$port135_in_tcp" = true ]; then
  port135_in_tcp
else
    echo "$(date) | Skipping disabling inbound Port Number 135 TCP..."
fi

# Disable inbound Port Number 135 UDP
if [ "$port135_in_udp" = true ]; then
    port135_in_udp
else
    echo "$(date) | Skipping disabling inbound Port Number 135 UDP..."
fi

# Disable inbound Port Numbers 137-139 TCP
if [ "$port137_139_in_tcp" = true ]; then
    port137_139_in_tcp
else
    echo "$(date) | Skipping disabling inbound Port Numbers 137-139 TCP..."
fi

# Disable inbound Port Numbers 137-139 UDP
if [ "$port137_139_in_udp" = true ]; then
    port137_139_in_udp
else
    echo "$(date) | Skipping disabling inbound Port Numbers 137-139 UDP..."
fi

# Disable inbound Port Number 445 TCP
if [ "$port445_in_tcp" = true ]; then
    port445_in_tcp
else
    echo "$(date) | Skipping disabling inbound Port Number 445 TCP..."
fi

# Disable inbound Port Numbers 1433-1434 TCP
if [ "$port1433_1434_in_tcp" = true ]; then
    port1433_1434_in_tcp
else
    echo "$(date) | Skipping disabling inbound Port Numbers 1433-1434 TCP..."
fi

# Disable inbound Port Numbers 1433-1434 UDP
if [ "$port1433_1434_in_udp" = true ]; then
    port1433_1434_in_udp
else
    echo "$(date) | Skipping disabling inbound Port Numbers 1433-1434 UDP..."
fi

# Disable inbound Port Number 3389 TCP
if [ "$port3389_in_tcp" = true ]; then
    port3389_in_tcp
else
    echo "$(date) | Skipping disabling inbound Port Number 3389 TCP..."
fi

# Disable inbound Port Number 1900 UDP
if [ "$port1900_in_udp" = true ]; then
    port1900_in_udp
else
    echo "$(date) | Skipping disabling inbound Port Number 1900 UDP..."
fi

# Disable inbound Port Numbers 20-21 TCP
if [ "$port20_21_in_tcp" = true ]; then
    port20_21_in_tcp
else
    echo "$(date) | Skipping disabling inbound Port Numbers 120-21 TCP..."
fi

# Disable inbound Port Numbers 20-21 UDP
if [ "$port20_21_in_udp" = true ]; then
    port20_21_in_udp
else
    echo "$(date) | Skipping disabling inbound Port Numbers 20-21 UDP..."
fi

# Disable inbound Port Number 23 TCP
if [ "$port23_in_tcp" = true ]; then
    port23_in_tcp
else
    echo "$(date) | Skipping disabling inbound Port Number 23 TCP..."
fi

# Disable outbound Port Number 110 TCP
if [ "$port110_out_tcp" = true ]; then
    port110_out_tcp
else
    echo "$(date) | Skipping disabling outbound Port Number TCP 110..."
fi

# Disable outbound Port Number 995 TCP
if [ "$port995_out_tcp" = true ]; then
    port995_out_tcp
else
    echo "$(date) | Skipping disabling outbound Port Number TCP 995..."
fi

# Disable outbound Port Number 143 TCP
if [ "$port143_out_tcp" = true ]; then
    port143_out_tcp
else
    echo "$(date) | Skipping disabling outbound Port Number TCP 143..."
fi

# Disable outbound Port Number 993 TCP
if [ "$port993_out_tcp" = true ]; then
    port993_out_tcp
else
    echo "$(date) | Skipping disabling outbound Port Number TCP 993..."
fi

# Closing script
echo "$(date) | Done. Closing script..."
exit 0