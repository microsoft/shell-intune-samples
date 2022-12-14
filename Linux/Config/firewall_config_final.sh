#!/bin/bash

# Port information: https://www.speedguide.net/ports.php


#############################################################################################################################
################### CUSTOM INPUT VARIABLES
#############################################################################################################################

# Set this variable to accept, block, or reject all traffic coming onto the loopback interface (machine sending itself connections).
LOOPBACK_INTERFACE=ACCEPT

# Set this variable to accept, block, or reject established and related incoming connections
RELATED_AND_ESTABLISHED_INCOMING_CONNECTIONS=ACCEPT

# Set this variable to accept, block, or reject established and related outgoing connections
RELATED_AND_ESTABLISHED_OUTGOING_CONNECTIONS=ACCEPT

# Set this variable to accept, block, or reject pings from external to internal.
EXTERNAL_TO_INTERNAL_PINGS=ACCEPT 

# Set this variable to accept, block, or reject pings from internal to external
INTERNAL_TO_EXTERNAL_PINGS=ACCEPT

# Set this variable to accept, block, or reject internal network (ethernet card to internal servers) communication with external network (ethernet to external servers).
INTERNAL_TO_EXTERNAL_NETWORK_COMMUNICATION=ACCEPT

# Set this variable to accept, block, or reject DNS connections
DNS_CONNECTIONS=ACCEPT

# Set this variable to accept all connections to or from an IP address.
ACCEPTED_IP=(
    "15.15.15.51"
    )

# Set this variable to block all connections to or from an IP address.
BLOCKED_IP=(
    "15.15.15.51"
    )

# Set this variable to reject all connections to or from an IP address.
REJECTED_IP=(
    "15.15.15.51"
    )

# Set these variables to block all connections from a specific IP address through this interface.
BLOCKED_INTERFACE=(
    "eth0"
    )

BLOCKED_INTERFACE_IP=(
    "temp"        
    )

# Set this variable to a subnet or IP address to allow incoming and outgoing SSH.
INCOMING_SSH=(
    "1"
    )

# Set this variable to a subnet or IP address to allow incoming and outgoing SSH.
OUTGOING_SSH=(
    "1"
    )

# Set this varaible to a subnet or IP address to allow incoming rsync.
RSYNC_IP=(
    "1"
    )

# Set this variable to accept, block, or reject incoming HTTP connections.
INCOMING_HTTP=ACCEPT

# Set this variable to accept, block, or reject incoming HTTPS connections.
INCOMING_HTTPS=ACCEPT

# Set this variable to a subnet or IP adddress to allow incoming mySQL connections.
MYSQL_IP=(
    "temp"
    )

# Set this variable to an interface to allow that network interface to receive MySQL connections
MYSQL_INTERFACE=(
    "eth0"
    )

# Set this variable to a subnet or IP adddress to allow incoming PostgreSQL connections.
POSTGRE_SQL_IP=(
    "temp"
    )

# Set this variable to an interface to allow that network interface to receive PostgreSQL connections
POSTGRE_SQL_INTERFACE=(
    "eth0"
    )

# Set this varialbe to accept, block, or reject incoming SMTP connections (most SMTP for mail comes through port 25, might also use 587 for outbound mail).
INCOMING_SMTP=ACCEPT

# Set this varialbe to accept, block, or reject all incoming IMAP connections.
INCOMING_IMAP=ACCEPT

# Set this varialbe to accept, block, or reject all incoming IMAPS connections. 
INCOMING_IMAPS=ACCEPT

# Set this varialbe to accept, block, or reject all incoming POP3 connections.
INCOMING_POP3=ACCEPT

# Set this varialbe to accept, block, or reject incoming POP3S connections.
INCOMING_POP3S=ACCEPT

# Set this variable to the ports of outgoing mail types (SMTP, IMAP, IMAPS, POP3, POP3S) to be blocked.
    # SMTP: 25  IMAP: 143   IMAPS: 993    POP3: 110   POP3S: 995
BLOCKED_MAIL_PORTS=(
    "25"
    )

# Set this variable to the ports to be blocked (ie: to block incoming connections to a given port)
    # The ports currently included in the ones recommended by the SANS Institute. 
BLOCKED_PORTS=(
    "135"
    "137"
    "139"
    "445"
    "69"
    "514"
    "161"
    "162"
    "6660"
    "6661"
    "6662"
    "6663"
    "6664"
    "6665"
    "6666"
    "6667"
    "6668"
    "6669"
    )

# Set this variable to the line number(s) of the firewall rule(s) to be deleted - for INPUT rules only. 
DELETE_RULE_INPUT=(
    "1"
    )    

# Set this variable to the line number(s) of the firewall rule(s) to be deleted - for OUTPUT rules only. 
DELETE_RULE_OUTPUT=(
    "1"
    ) 

# Set this variable to the line number(s) of the firewall rule(s) to be deleted - for FORWARD rules only. 
DELETE_RULE_FORWARD=(
    "1"
    ) 

# Set this variable to the maximum number of connections per minute after the limit burst is exceed. 
MAX_CONNECTIONS_PER_MIN=25/minute

# Set this variable to limit the packet rate per second, per day, etc
LIMT=25/s

# Set this variable to the limit burst for incoming connections
LIMIT_BURST=100

# Set this variable to the port that traffic will be re-routed from (ie: all traffic incoming to this port will be forwarded)
FORWARDED_PORT=422

# Set this variable to the port that will receive all forwarded traffic from a given port. 
RECEIVING_PORT=22

# Set this variable to any bogus tcp flag sets to be blocked. 
BOGUS_TCP_FLAG_LIST=(
    "FIN,SYN,RST,PSH,ACK,URG NONE"
    "FIN,SYN FIN,SYN"
    "SYN,RST SYN,RST"
    "SYN,FIN SYN,FIN"
    "FIN,RST FIN,RST"
    "FIN,ACK FIN"
    "ACK,URG URG"
    "ACK,FIN FIN"
    "ACK,PSH PSH"
)

# Set this variable to the connection limit per source.
CONNECTION_LIMIT_PER_SRC=1100

# Set this variable to the network interface you want to log dropped packets for. 
INTERFACE_DROPPED_LOG=(
    "eth0"
    "eth1"
)

#############################################################################################################################
################### CHECK FOR PROPER VARIABLE STATUS 
#############################################################################################################################

# LOOPBACK INTERFACE
if [[ -z $LOOPBACK_INTERFACE || ($LOOPBACK_INTERFACE != "ACCEPT" && $REALTIME != "REJECT" && $REALTIME != "BLOCK") ]]; then
    echo "Loopback interface settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# RELATED AND ESTABLISHED INCOMING CONNECTIONS
if [[ -z $RELATED_AND_ESTABLISHED_INCOMING_CONNECTIONS || ($RELATED_AND_ESTABLISHED_INCOMING_CONNECTIONS != "ACCEPT" && $RELATED_AND_ESTABLISHED_INCOMING_CONNECTIONS != "REJECT" && $RELATED_AND_ESTABLISHED_INCOMING_CONNECTIONS != "BLOCK") ]]; then
    echo "Related and established incoming connection settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# RELATED AND ESTABLISHED OUTGOING CONNECTIONS
if [[ -z $RELATED_AND_ESTABLISHED_OUTGOING_CONNECTIONS || ($RELATED_AND_ESTABLISHED_OUTGOING_CONNECTIONS != "ACCEPT" && $RELATED_AND_ESTABLISHED_OUTGOING_CONNECTIONS != "REJECT" && $RELATED_AND_ESTABLISHED_OUTGOING_CONNECTIONS != "BLOCK") ]]; then
    echo "Related and established outgoing connection settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# EXTERNAL TO INTERNAL PINGS
if [[ -z $EXTERNAL_TO_INTERNAL_PINGS || ($EXTERNAL_TO_INTERNAL_PINGS != "ACCEPT" && $EXTERNAL_TO_INTERNAL_PINGS != "REJECT" && $EXTERNAL_TO_INTERNAL_PINGS != "BLOCK") ]]; then
    echo "External to internal ping settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# INTERNAL TO EXTERNAL PINGS
if [[ -z $INTERNAL_TO_EXTERNAL_PINGS || ($INTERNAL_TO_EXTERNAL_PINGS != "ACCEPT" && $INTERNAL_TO_EXTERNAL_PINGS != "REJECT" && $INTERNAL_TO_EXTERNAL_PINGS != "BLOCK") ]]; then
    echo "Internal to external ping settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# INTERNAL TO EXTERNAL NETWORK COMMUNICATION
if [[ -z $INTERNAL_TO_EXTERNAL_NETWORK_COMMUNICATION || ($INTERNAL_TO_EXTERNAL_NETWORK_COMMUNICATION != "ACCEPT" && $INTERNAL_TO_EXTERNAL_NETWORK_COMMUNICATION != "REJECT" && $INTERNAL_TO_EXTERNAL_NETWORK_COMMUNICATION != "BLOCK") ]]; then
    echo "Internal to external network communication settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# DNS CONNECTIONS
if [[ -z $DNS_CONNECTIONS || ($DNS_CONNECTIONS != "ACCEPT" && $DNS_CONNECTIONS != "REJECT" && $DNS_CONNECTIONS != "BLOCK") ]]; then
    echo "DNS connection settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# INCOMING HTTP
if [[ -z $INCOMING_HTTP || ($INCOMING_HTTP != "ACCEPT" && $INCOMING_HTTP != "REJECT" && $INCOMING_HTTP != "BLOCK") ]]; then
    echo "Incoming HTTP connection settings Fhave not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# INCOMING HTTPS
if [[ -z $INCOMING_HTTPS || ($INCOMING_HTTPS != "ACCEPT" && $INCOMING_HTTPS != "REJECT" && $INCOMING_HTTPS != "BLOCK") ]]; then
    echo "Incoming HTTPS connection settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# INCOMING SMTP 
if [[ -z $INCOMING_SMTP || ($INCOMING_SMTP != "ACCEPT" && $INCOMING_SMTP != "REJECT" && $INCOMING_SMTP != "BLOCK") ]]; then
    echo "Incoming SMTP connection settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# INCOMING IMAP
if [[ -z $INCOMING_IMAP || ($INCOMING_IMAP != "ACCEPT" && $INCOMING_IMAP != "REJECT" && $INCOMING_IMAP != "BLOCK") ]]; then
    echo "Incoming IMAP connection settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# INCOMING IMAPS
if [[ -z $INCOMING_IMAPS || ($INCOMING_IMAPS != "ACCEPT" && $INCOMING_IMAPS != "REJECT" && $INCOMING_IMAPS != "BLOCK") ]]; then
    echo "Incoming IMAPS connection settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# INCOMING POP3
if [[ -z $INCOMING_POP3 || ($INCOMING_POP3 != "ACCEPT" && $INCOMING_POP3 != "REJECT" && $INCOMING_POP3 != "BLOCK") ]]; then
    echo "Incoming POP3 connection settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# INCOMING POP3S
if [[ -z $INCOMING_POP3S || ($INCOMING_POP3S != "ACCEPT" && $INCOMING_POP3S != "REJECT" && $INCOMING_POP3S != "BLOCK") ]]; then
    echo "Incoming POP3S connection settings have not been updated or have been set to something other than the allowed values (ACCEPT, BLOCK, REJECT). Please correct."
    exit 1
fi

# BLOCKED MAIL PORTS 
if ! [[ $BLOCKED_MAIL_PORTS =~ ^[0-9]+$ ]]; then
    echo "Blocked mail port setttings have been set to something other than the accepted values (integer value). Please correct."
    exit 1
fi

# BLOCKED PORTS
if ! [[ $BLOCKED_PORTS =~ ^[0-9]+$ ]]; then
    echo "Blocked port setttings have been set to something other than the accepted values (integer value). Please correct."
    exit 1
fi

# DELETE RULE INPUT
if ! [[ $DELETE_RULE_INPUT =~ ^[0-9]+$ ]]; then
    echo "Input rule deletion setttings have been set to something other than the accepted values (integer value). Please correct."
    exit 1
fi

# DELETE RULE OUTPUT
if ! [[ $DELETE_RULE_OUTPUT =~ ^[0-9]+$ ]]; then
    echo "Output rule deletion setttings have been set to something other than the accepted values (integer value). Please correct."
    exit 1
fi

# DELETE RULE FORWARD
if ! [[ $DELETE_RULE_FORWARD =~ ^[0-9]+$ ]]; then
    echo "Forward rule deletion setttings have been set to something other than the accepted values (integer value). Please correct."
    exit 1
fi

# LIMIT BURST
if ! [[ $LIMIT_BURST =~ ^[0-9]+$ ]]; then
    echo "Limit burst setttings have been set to something other than the accepted values (integer value). Please correct."
    exit 1
fi

# FORWARDED PORT
if ! [[ $FORWARDED_PORT =~ ^[0-9]+$ ]]; then
    echo "Port forwarding setttings have been set to something other than the accepted values (integer value). Please correct."
    exit 1
fi

# RECEIVING PORT
if ! [[ $RECEIVING_PORT =~ ^[0-9]+$ ]]; then
    echo "Port receiving setttings have been set to something other than the accepted values (integer value). Please correct."
    exit 1
fi

# CONNECTION LIMIT PER SOURCE 
if ! [[ $CONNECTION_LIMIT_PER_SRC =~ ^[0-9]+$ ]]; then
    echo "Source connection limit setttings have been set to something other than the accepted values (integer value). Please correct."
    exit 1
fi

#############################################################################################################################
################### SCRIPT 
#############################################################################################################################


# Recommended that this script be run using root privileges:
echo "It is recommended that this script is run with root privileges. Please type the following or contact your administration: sudo -s"

# Start of a bash "try-catch loop" that will safely exit the script if a command fails or causes an error. 
(
    # Set the error status
    set -e   

    # Install iptables unless already installed
    apt-get install iptables
        # To keep iptables firewall rules post-system reboot: 
        apt-get install iptables-persistent 

    # Allow, block, or reject all traffic coming onto the loopback interface (machine sending itself connections)
    iptables -A INPUT -i lo -j $LOOPBACK_INTERFACE
    iptables -A OUTPUT -o lo -j $LOOPBACK_INTERFACE
    echo "The status of traffic coming onto the loopback interface has been set to: " $LOOPBACK_INTERFACE"."

    # Allow, block, or reject established and related incoming connections
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED, RELATED -j $RELATED_AND_ESTABLISHED_INCOMING_CONNECTIONS
    echo "The status of incoming established or related connections has been set to: " $RELATED_AND_ESTABLISHED_INCOMING_CONNECTIONS"."

    # Allow, block, or reject established and related outgoing connections
    iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED, RELATED -j $RELATED_AND_ESTABLISHED_OUTGOING_CONNECTIONS
    echo "The status of outgoing established or related connections has been set to: " $RELATED_AND_ESTABLISHED_OUTGOING_CONNECTIONS"."

    # Allow, block, or reject pings from external to internal. 
    iptables -A INPUT -p icmp --icmp-type echo-request -j $EXTERNAL_TO_INTERNAL_PINGS
    iptables -A OUTPUT -p icmp --icmp-type echo-reply -j $EXTERNAL_TO_INTERNAL_PINGS
    echo "The status of external to internal pings has been set to: " $EXTERNAL_TO_INTERNAL_PINGS"."

    # Allow, block, or reject pings from internal to external
    iptables -A OUTPUT -p icmp --icmp-type echo-request -j $INTERNAL_TO_EXTERNAL_PINGS
    iptables -A INPUT -p icmp --icmp-type echo-reply -j $INTERNAL_TO_EXTERNAL_PINGS
    echo "The status of internal to external pings has been set to: " $INTERNAL_TO_EXTERNAL_PINGS"."

    # Allow, block, or reject internal network (ethernet card to internal servers) communication with external networks (ethernet to external servers).
    iptables -A FORWARD -i eth0 -o eth1 -j $INTERNAL_TO_EXTERNAL_NETWORK_COMMUNICATION
    echo "The status of internal to external network connections has been set to: " $INTERNAL_TO_EXTERNAL_NETWORK_COMMUNICATION"."

    # Allow, block, or reject outbound DNS connections
    iptables -A OUTPUT -p udp -o eth0 --dport 53 -j $DNS_CONNECTIONS
    iptables -A INPUT -p udp -i eth0 --sport 53 -j $DNS_CONNECTIONS
    echo "The status of outbound DNS connections has been set to: " $DNS_CONNECTIONS"."

    # Drop incoming invalid packets (packets that the network has labeled as invalid)
    iptables -A INPUT -m conntrack --ctstate INVALID -j DROP 
    echo "Firewall rule settings have been updated to drop all incoming invalid packets."

    # Block connections coming from specific IP address. 
        for i in "${ACCEPTED_IP[@]}"; do
            iptables -A INPUT -s $i -j ACCEPT
            echo "Connections coming from IP address " $i " have been accepted."
        done

    # Block connections coming from specific IP address. 
        for i in "${BLOCKED_IP[@]}"; do
            iptables -A INPUT -s $i -j DROP
            echo "Connections coming from IP address " $i " have been blocked."
        done

    # Reject the connection altogether - this sends an error message to the IP address whereas BLOCK does not.
        for i in "${REJECTED_IP[@]}"; do
            iptables -A INPUT -s $i -j REJECT
            echo "Connections coming from IP address " $i " have been rejected."
        done

    # Block connections to a specific interface
        for i in "${BLOCKED_INTERFACE[@]}"; do
            iptables -A INPUT -i $i -s $i -j DROP
            echo "Connections from the interface " $i " have been blocked."
        done

    # Block all incoming telnet conncetions 
    iptables -A INPUT -p tcp --dport telnet -j BLOCK
    echo "Firewall rule settings have been updated to block all incoming telnet connections."

    # Allow incoming SSH from a specific IP or subnet.
        for i in "${INCOMING_SSH[@]}"; do
            iptables -A INPUT -p tcp -s $i --dport 22 -m conntrack --ctstate NEW, ESTABLISHED -j ACCEPT
                # Need this command only if output policy is not set to accept for port 22
                iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
            echo "Incoming SSH from IP address or subnet " $i " allowed."
        done

    # Allow outgoing SSH to a specific IP address, subnet, or network. 
        for i in "${OUTGOING_SSH[@]}"; do
            iptables -A OUTPUT -o eth0 -p tcp -d $i --dport 22  -m conntrack --ctstate NEW, ESTABLISHED -j ACCEPT
                # Need this command only if input policy is not set to accept for port 22
                iptables -A INPUT -i eth0 -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
            echo "Outgoing SSH from IP address or subnet " $i " allowed."
        done

    # Allow ALL outgoing SSH.
    iptables -A OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW, ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
    echo "Firewall rule settings have been updated to allow all outgoing SSH."

    # Allow incoming Rsync from a specific IP or subnet. 
        for i in "${RSYNC_IP[@]}"; do
            iptables -A INPUT -p tcp -s $i --dport 873 -m conntrack --ctstate NEW, ESTABLISHED -j ACCEPT
                # Need this command only if output policy is not set to accept for port 873.
                iptables -A OUTPUT -p tcp --sport 873 -m conntrack --ctstate ESTABLISHED -j ACCEPT
            echo "Incoming Rsync from IP address or subnet " $i " allowed."
        done

    # Allow, block, or reject incoming HTTP connections.
    iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW, ESTABLISHED -j $INCOMING_HTTP
        # Need this command only if output policy is not set to accept for port 80.
        iptables -A OUTPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j $INCOMING_HTTP
    echo "The status of incoming HTTP connections has been set to: " $INCOMING_HTTP"."

    # Allow, block, or reject incoming HTTPS connections.
    iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW, ESTABLISHED -j $INCOMING_HTTPS
        # Need this command only if output policy is not set to accept for port 443.
        iptables -A OUTPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j $INCOMING_HTTPS
    echo "The status of incoming HTTPS connections has been set to: " $INCOMING_HTTPS"."

    # Allow incoming MySQL connections from a specific IP or subnet.
        for i in "${MYSQL_IP[@]}"; do
            iptables -A INPUT -p tcp -s $i --dport 3306 -m conntrack --ctstate NEW, ESTABLISHED -j ACCEPT
                # Need this command only if output policy is not set to accept for port 3306.
                iptables -A OUTPUT -p tcp --sport 3306 -m conntrack --ctstate ESTABLISHED -j ACCEPT
            echo "MySQL connections from IP address or subnet " $i " allowed."
        done

    # Enable MySQL connections to a specific interface.
        for i in "${MYSQL_INTERFACE[@]}"; do
            iptables -A INPUT -i $i -p tcp --dport 3306 -m conntrack --ctstate NEW, ESTABLISHED -j ACCEPT
                # Need this command only if output policy is not set to accept for port 3306.
                iptables -A OUTPUT -o $i -p tcp --sport 3306 -m conntrack --ctstate ESTABLISHED -j ACCEPT
            echo "MySQL connections from interface " $i " enabled."
        done

    # Allow incoming PostgreSQL connections from a specific IP or subnet. 
        for i in "${POSTGRE_SQL_IP[@]}"; do
            iptables -A INPUT -p tcp -s $i --dport 5432 -m conntrack --ctstate NEW, ESTABLISHED -j ACCEPT 
                # Need this command only if output policy is not set to accept for port 5432.
                iptables -A OUTPUT -p tcp --sport 5432 -m conntrack --ctstate ESTABLISHED -j ACCEPT
            echo "Postgre SQL connections from IP address or subnet " $i " allowed."
        done

    # Enable PostgreSQL connections to a specific interface.
        for i in "${POSTGRE_SQL_INTERFACE[@]}"; do
            iptables -A INPUT -i $i -p tcp --dport 5432 -m conntrack --ctstate NEW, ESTABLISHED -j ACCEPT
                # Need this command only if output policy is not set to accept for port 5432.
                iptables -A OUTPUT -o $i -p tcp --sport 5432 -m conntrack ESTABLISHED -j ACCEPT
            echo "PostgreSQL connections from interface " $i " enabled."
        done

    # Allow incoming SMTP connections (most SMTP for mail comes through port 25, might also use 587 for outbound mail).
    iptables -A INPUT -p tcp --dport 25 -m conntrack --ctstate NEW, ESTABLISHED -j $INCOMING_SMTP
        # Need this command only if output policy is not set to accept for port 25.
        iptables -A OUTPUT -p tcp --sport 25 -m conntrack --ctstate ESTABLISHED -j $INCOMING_SMTP
        echo "The status of incoming SMTP connections has been set to: " $INCOMING_SMTP"."

    # Allow, block, or reject all incoming IMAP connections.
    iptables -A INPUT -p tcp --dport 143 -m conntrack --ctstate NEW, ESTABLISHED -j $INCOMING_IMAP
        # Need this command only if output policy is not set to accept for port 143.
        iptables -A OUTPUT -p tcp --sport 143 -m conntrack --ctstate ESTABLISHED -j $INCOMING_IMAP
        echo "The status of incoming IMAP connections has been set to: " $INCOMING_IMAP"."

    # Allow, block, or reject all incoming IMAPS connections.
    iptables -A INPUT -p tcp --dport 993 -m conntrack --ctstate NEW, ESTABLISHED -j $INCOMING_IMAPS
        # Need this command only if output policy is not set to accept for port 993.
        iptables -A OUTPUT -p tcp --sport 3306 -m conntrack --ctstate ESTABLISHED -j $INCOMING_IMAPS
        echo "The status of incoming IMAPS connections has been set to: " $INCOMING_IMAPS"."

    # Allow, block, or reject all incoming POP3 connections.
    iptables -A INPUT -p tcp --dport 110 -m conntrack --ctstate NEW, ESTABLISHED -j $INCOMING_POP3
        # Need this command only if output policy is not set to accept for port 110.
        iptables -A OUTPUT -p tcp --sport 110 -m conntrack --ctstate ESTABLISHED -j $INCOMING_POP3
        echo "The status of incoming POP3 connections has been set to: " $INCOMING_POP3"."

    # Allow, block, or reject incoming POP3S connections.
    iptables -A INPUT -p tcp --sport 995 -m conntrack --ctstate NEW, ESTABLISHED -j $INCOMING_POP3S
        # Need this command only if output policy is not set to accept for port 995.
        iptables -A OUTPUT -p tcp --sport 995 -m conntrack --ctstate ESTABLISHED -j $INCOMING_POP3S
        echo "The status of incoming POP3S connections has been set to: " $INCOMING_POP3S"."

    # Block outgoing mail types.
        for i in "${BLOCKED_MAIL_PORTS[@]}"; do
            iptables -A OUTPUT -p tcp --dport $i -j REJECT 
            echo "Outgoing mail type " $i " has been blocked."
        done

    # Block incoming connections to a specfic port.
        for i in "${BLOCKED_PORTS[@]}"; do
            iptables -A INPUT -p tcp --dport $i -j REJECT 
            echo "Outgoing mail type " $i " has been blocked."
        done

    # Delete an input rule via line numbers.
        for i in "${DELETE_RULE_INPUT[@]}"; do
            iptables -D INPUT $i
            echo "The INPUT firewall rule on line " $i " has been deleted."
        done

    # Delete an output rule via line numbers. 
        for i in "${DELETE_RULE_OUTPUT[@]}"; do
            iptables -D OUTPUT $i
            echo "The OUTPUT firewall rule on line " $i " has been deleted."
        done

    # Delete a forward rule via line numbers. 
        for i in "${DELETE_RULE_FORWARD[@]}"; do
            iptables -D FORWARD $i
            echo "The FORWARD firewall rule on line " $i " has been deleted."
        done

    # Denial of Service (DoS) Attack Prevention
        # Limits connections to a maximum of ____ connections per minute (recommended is ~25).
        # Limit Burst value states that the limit per minute will be enfored only after the total number of connections have reached the limit burst threshold.
        iptables -A INPUT -p tcp --dport 80 -m limit $LIMIT --limit-burst $LIMIT_BURST -j ACCEPT
        echo "The maximum number of connections per minute (known as the limit burst value) has been set to " $LIMIT_BURST"."

    # Port Forwarding (routing all traffic incoming to a specific port to another port; requires SSH connection to come from both ports).
        iptables -t nat -A PREROUTING -p tcp --dport $FORWARDED_PORT -j REDIRECT --to-port $RECEIVING_PORT
            echo "Traffic from IP address or subnet " $i " to port " $FORWARDED_PORT "has been forwarded to port " $RECEIVING_PORT"."

        # In order for this to be succesful, the forwarded port must allow incoming connections.
        iptables -A INPUT -i eth0 -p tcp --dport $FORWARDED_PORT -m conntrack --ctstate NEW, ESTABLISHED -j ACCEPT
        iptables -A OUTPUT -o eth0 -p tcp --sport $FORWARDED_PORT -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Drop TCP packets that are new and are not SYN.
    iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
    echo "Firewall rules have been updated to drop TCP packets that are new and not SYN."

    # Drop SYN packets that have suspicious MSS values.
    iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
    echo "Firewall rules have been updated to drop SYN packets with suspicious MSS values."

    # Block any packets that have BOGUS tcp flags
        for i in "${BOGUS_TCP_FLAG_LIST[@]}"; do
            iptables -t mangle -A PREROUTING -p tcp --tcp-flags $i -j DROP
            echo "Any packets with bogus TCP flags " $i " have been blocked."
        done

    # Limit the possible number of connections for each source IP
    iptables -A INPUT -p tcp -m connlimit --connlimit-above $CONNECTION_LIMIT_PER_SRC -j REJECT
    echo "The possible number of connections for each source IP has been limited to " $CONNECTION_LIMIT_PER_SRC"."

    # Blocking specific website / network (host apple.com   whois ADDR FOR APPLE.COM | grep CIDR    iptables -A OUTPUT -p tcp -d CIDR -j DROP)

    # Keep a log of all dropped backs on a given network interface
        # Messages are logged in /var/log/messsages
        for i in "${INTERFACE_DROPPED_LOG[@]}"; do
            iptables -A INPUT -i $i -j LOG --log-prefix "IPtables Dropped Packets"
            echo "Any packets with bogus TCP flags " $i " have been blocked."
        done

    # Save rule changes ahead of the first restart (Iptables doesn't store unsaved rules after a reboot and changes only apply after the first restart).
    /sbin/iptables-save   
    echo "Firewall rule changes have been saved and will be applied after the next system restart."
)

ERROR_CODE=$?
if [ $ERROR_CODE -ne 0 ]; then
    echo "There was an error. Please restart the script or contact your admin if the error persists."
    exit $ERROR_CODE
fi

# System restart
echo "A system restart is required in order for firewall changes to take place. Please either restart at your earliest convenience or type 'Restart Now' to automatically restart your device."
read RESTART_RESPONSE

# Final output message - to be configured TBD
echo "The script is finished running. The result will be sent in the necessary format."

if [[ $RESTART_RESPONSE == "Restart Now" || $RESTART_RESPONSE == "Restart now" || $RESTART_RESPONSE == "restart now" || $RESTART_RESPONSE == "restart Now"]]; then
    shutdown -r now
fi