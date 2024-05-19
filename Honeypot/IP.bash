# Block IPs from a specific country (e.g., China)
iptables -A INPUT -s 203.0.113.0/24 -j DROP
