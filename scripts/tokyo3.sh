#!/bin/bash
/root/setup_ip.sh

# 1. Bersihkan aturan lama
iptables -F INPUT

# 2. Izinkan loopback
iptables -A INPUT -i lo -j ACCEPT

# === ATURAN SOAL 15 (RATE LIMIT PING) ===
# Taruh sebelum conntrack agar tidak ter-bypass oleh state ESTABLISHED
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 5/s --limit-burst 5 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# === ATURAN SOAL 16 (LOG & REJECT DUMMY-PLUG: 192.219.4.51) ===
IP_DUMMY="192.219.4.51"

# Catat percobaan scanning ke log dengan prefix SCAN-NERV:
iptables -A INPUT -s $IP_DUMMY -p tcp -m multiport --dports 22,23,3306 -j LOG --log-prefix "SCAN-NERV: "

# Tolak seketika (tcp-reset)
iptables -A INPUT -s $IP_DUMMY -p tcp -m multiport --dports 22,23,3306 -j REJECT --reject-with tcp-reset

# 3. Izinkan balasan koneksi & port web 80 & 8080
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,8080 -j ACCEPT

# 4. Default policy tetap ACCEPT
iptables -P INPUT ACCEPT
