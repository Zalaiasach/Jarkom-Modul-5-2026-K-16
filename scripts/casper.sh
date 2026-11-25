#!/bin/bash
/root/setup_ip.sh

# 1. Matikan listener nc lama jika ada
pkill -f "nc" 2>/dev/null

# 2. Jalankan listener port 5000 di background
nohup nc -k -l -p 5000 > /root/casper_5000.log 2>&1 &

# === ATURAN FIREWALL SOAL 11 & 12 ===
iptables -F INPUT

# Izinkan loopback
iptables -A INPUT -i lo -j ACCEPT

# Izinkan balasan koneksi keluar (Stateful)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Pastikan port TCP 5000 tetap terbuka
iptables -A INPUT -p tcp --dport 5000 -j ACCEPT

# Blokir permintaan ping masuk (echo-request)
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# Hardening Soal 12
iptables -P INPUT DROP
