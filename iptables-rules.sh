iptables -F
iptables -t nat -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -L -n | grep policy
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -L INPUT -n -v --line-numbers
iptables -A FORWARD -p tcp --dport 443 -j ACCEPT
iptables -A FORWARD -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -L FORWARD -n -v --line-numbers
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
iptables -t nat -L POSTROUTING -n -v
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 2222 -j DNAT --to-destination 10.0.1.1:22
iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp --dport 22 -d 10.0.1.1 -j ACCEPT
iptables -t nat -L PREROUTING -n -v
