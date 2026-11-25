#!/bin/bash
/root/setup_ip.sh

# 1. Pastikan DNS resolver terisi
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# 2. Matikan listener nc lama jika ada
pkill -f "nc" 2>/dev/null

# 3. Jalankan listener untuk Port 5000 dan 5001
nohup nc -k -l -p 5000 > /root/balthasar_5000.log 2>&1 &
nohup nc -k -l -p 5001 > /root/balthasar_5001.log 2>&1 &

# === ATURAN FIREWALL NOMOR 13 ===
# Bersihkan aturan lama
iptables -F INPUT

# Izinkan loopback & koneksi yang sudah berjalan
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# WHITELIST AKSES PORT 5000 & 5001:
# (a) Izinkan Casper
iptables -A INPUT -p tcp -m multiport --dports 5000,5001 -s 192.219.4.66 -j ACCEPT

# (b) Izinkan Pilot Unit-01, Unit-02, Unit-00 (Subnet Cage)
iptables -A INPUT -p tcp -m multiport --dports 5000,5001 -s 192.219.4.72/29 -j ACCEPT

# (c) Izinkan Pilot Sachiel (Subnet Bunker)
iptables -A INPUT -p tcp -m multiport --dports 5000,5001 -s 192.219.3.128/26 -j ACCEPT

# TOLAK SEKETIKA untuk node lain yang mencoba port 5000 & 5001 (tcp-reset)
iptables -A INPUT -p tcp -m multiport --dports 5000,5001 -j REJECT --reject-with tcp-reset

# Pastikan default policy INPUT tetap ACCEPT
iptables -P INPUT ACCEPT
