#!/bin/bash
# Script Router Shigeru - Soal 18 & 19

# === SOAL 19: HUKUMAN ISOLASI UNTUK SANG PENGKHIANAT (ARMISAEL) ===
# Blokir Armisael (192.219.4.91) ke gateway dan sebaliknya
iptables -I INPUT -s 192.219.4.91 -j DROP
iptables -I OUTPUT -d 192.219.4.91 -j DROP

# Blokir Armisael ke seluruh jaringan luar / Seele / Lilith (FORWARD)
iptables -I FORWARD -s 192.219.4.91 -j DROP
iptables -I FORWARD -d 192.219.4.91 -j DROP

# === SOAL 18: GERBANG MONOLITH DAN RADAR ===
# Izinkan balasan koneksi (agar node zona dalam bisa akses keluar & balasannya sampai)
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Pengecualian: Izinkan ping HANYA dari subnet Terminal (192.219.4.64/29) masuk lewat eth0
iptables -A FORWARD -i eth0 -s 192.219.4.64/29 -p icmp --icmp-type echo-request -j ACCEPT

# Blokir semua koneksi baru lainnya yang datang dari arah Gendo (eth0)
iptables -A FORWARD -i eth0 -j DROP
