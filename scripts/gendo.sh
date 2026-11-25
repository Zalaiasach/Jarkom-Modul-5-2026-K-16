#!/bin/bash

# --- Soal 2: IP Forwarding & Interface ---
sysctl -w net.ipv4.ip_forward=1 > /dev/null

for iface in eth1 eth2 eth3 eth4 eth5 eth6 eth7 eth8; do
    ip addr flush dev $iface 2>/dev/null
    ip link set $iface up
done

# --- Soal 5: Firewall Filter (INPUT & FORWARD = DROP) ---
iptables -F
iptables -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Izinkan Loopback & DHCP dari NAT1 (eth0)
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i eth0 -p udp --dport 67:68 -j ACCEPT

# (a) Izinkan balasan koneksi yang sudah ada (ESTABLISHED,RELATED)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# (d) Izinkan traffic dari jaringan internal ke Gendou sendiri
iptables -A INPUT -s 192.219.0.0/16 -j ACCEPT

# (b) Izinkan traffic dari jaringan internal ke internet (via eth0)
iptables -A FORWARD -s 192.219.0.0/16 -o eth0 -j ACCEPT

# (c) Izinkan traffic antar-LAN / internal
iptables -A FORWARD -s 192.219.0.0/16 -d 192.219.0.0/16 -j ACCEPT

# --- Soal 2 (lanjutan): IP Internet (eth0) & IP Statis Router ---
ip addr replace 192.168.122.100/24 dev eth0
ip link set eth0 up
ip route replace default via 192.168.122.1 dev eth0
echo "nameserver 8.8.8.8" > /etc/resolv.conf

ip addr replace 192.219.4.109/30 dev eth1
ip addr replace 192.219.4.113/30 dev eth2
ip addr replace 192.219.4.117/30 dev eth3
ip addr replace 192.219.4.121/30 dev eth4
ip addr replace 192.219.4.125/30 dev eth5
ip addr replace 192.219.4.129/30 dev eth6
ip addr replace 192.219.4.133/30 dev eth7
ip addr replace 192.219.4.105/30 dev eth8

# --- Soal 3: Static Routing ---
# Cabang Yui (via 192.219.4.110)
ip route replace 192.219.0.0/23 via 192.219.4.110
ip route replace 192.219.3.0/25 via 192.219.4.110
ip route replace 192.219.4.0/27 via 192.219.4.110
ip route replace 192.219.4.32/28 via 192.219.4.110
ip route replace 192.219.4.136/29 via 192.219.4.110
ip route replace 192.219.4.144/30 via 192.219.4.110

# Cabang Hikari (via 192.219.4.114)
ip route replace 192.219.2.0/24 via 192.219.4.114
ip route replace 192.219.3.224/27 via 192.219.4.114
ip route replace 192.219.4.148/30 via 192.219.4.114

# Cabang Asuka (via 192.219.4.118)
ip route replace 192.219.3.128/26 via 192.219.4.118
ip route replace 192.219.4.48/29 via 192.219.4.118
ip route replace 192.219.4.96/30 via 192.219.4.118
ip route replace 192.219.4.152/29 via 192.219.4.118

# Cabang Kaji (via 192.219.4.122)
ip route replace 192.219.4.100/30 via 192.219.4.122

# Cabang Misato (via 192.219.4.126)
ip route replace 192.219.4.72/29 via 192.219.4.126

# Cabang Shigeru (via 192.219.4.130)
ip route replace 192.219.4.56/29 via 192.219.4.130
ip route replace 192.219.4.88/29 via 192.219.4.130
ip route replace 192.219.4.160/30 via 192.219.4.130

# Cabang Fuyutsuki (via 192.219.4.134)
ip route replace 192.219.3.192/27 via 192.219.4.134
ip route replace 192.219.4.64/29 via 192.219.4.134
ip route replace 192.219.4.80/29 via 192.219.4.134
ip route replace 192.219.4.164/30 via 192.219.4.134
ip route replace 192.219.4.168/30 via 192.219.4.134

# --- Soal 4: NAT Masquerade ---
iptables -t nat -F
iptables -t nat -A POSTROUTING -s 192.219.0.0/16 -o eth0 -j MASQUERADE
