#!/bin/sh
#
#
# Script is for stoping Portscan and smurf attack

### first flush all the iptables Rules
iptables -F

# INPUT iptables Rules
# Accept loopback input
iptables -A INPUT -i lo -p all -j ACCEPT

# allow 3 way handshake
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Droping all invalid packets
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP

# flooding of RST packets, smurf attack Rejection
iptables -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT

# Protecting portscans
# Attacking IP will be locked for 24 hours (3600 x 24 = 86400 Seconds)
iptables -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
iptables -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP

# Remove attacking IP after 24 hours
iptables -A INPUT -m recent --name portscan --remove
iptables -A FORWARD -m recent --name portscan --remove

# These rules add scanners to the portscan list, and log the attempt.
iptables -A INPUT -p tcp -m tcp --dport 22 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
iptables -A INPUT -p tcp -m tcp --dport 22 -m recent --name portscan --set -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 22 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
iptables -A FORWARD -p tcp -m tcp --dport 22 -m recent --name portscan --set -j DROP

iptables -A INPUT -p tcp -m tcp --dport 5785 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
iptables -A INPUT -p tcp -m tcp --dport 5785 -m recent --name portscan --set -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 5785 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
iptables -A FORWARD -p tcp -m tcp --dport 5785 -m recent --name portscan --set -j DROP

iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP

# Allow the following ports through from outside
iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 5786 -j ACCEPT

# Allow ping means ICMP port is open (If you do not want ping replace ACCEPT with REJECT)
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

# Lastly reject All INPUT traffic
iptables -A INPUT -j REJECT


################# Below are for OUTPUT iptables rules #############################################

## Allow loopback OUTPUT 
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Allow the following ports through from outside 
# SMTP = 25
# DNS =53
# HTTP = 80
# HTTPS = 443
# SSH = 22
### You can also add or remove port no. as per your requirement

iptables -A OUTPUT -p tcp -m tcp --dport 25 -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 5786 -j ACCEPT

# Allow pings
iptables -A OUTPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

# Lastly Reject all Output traffic
#iptables -A OUTPUT -j REJECT

## Reject Forwarding  traffic
iptables -A FORWARD -j REJECT

# Do not forget to install fail2ban
# If already installed do 
# systemctl restart fail2ban
