#!/bin/bash
set -e

WAN=enp0s3
LAN=enp0s8
LAN_NET=10.0.1.0/24
SSH_HOST=10.0.1.1

#sysctl -w net.ipv4.ip_forward=1

iptables-restore <<EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]

# loopback 127.0.0.1
-A INPUT -i lo -j ACCEPT
-A INPUT -m contract --ctstate ESTABLISHED,RELATED -j ACCEPT

#ping and ssh to router
-A INPUT -p icmp --icmp-type echo-request -j ACCEPT
-A INPUT -p tcp --dport 22 -j ACCEPT

# DNS 
-A FORWARD -i $LAN -o $WAN -p tcp -m multiport --dports 80,443 -j ACCEPT
-A FORWARD -i $LAN -o $WAN -p udp --dport 53 -j ACCEPT
-A FORWARD -i $LAN -o $WAN -p tcp --dport 53 -j ACCPET

-A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCPET
-A FORWARD -i $WAN -o $LAN -p tcp -d $SSH_HOST --dport 22 -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
COMMIT

*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

-A POSTROUTING -s $LAN_NET -o $WAN -j MASQUERADE
-A PREROUTING -i $WAN -p tcp --dport 2222 -j DNAT --to-destination $SSH_HOST:22
COMMIT
EOF

