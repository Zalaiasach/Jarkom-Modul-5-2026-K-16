#!/bin/bash
# Script Router Fuyutsuki - Soal 17

# Pastikan DNS terisi
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# === SOAL 17: SIHIR HITAM DI JALUR PAKET (DNAT) ===
# Alihkan setiap koneksi TCP dari Casper (192.219.4.66) ke Zeruel (192.219.4.90) supaya sampai di Pen-Pen (192.219.3.194)
iptables -t nat -A PREROUTING -s 192.219.4.66 -d 192.219.4.90 -p tcp -j DNAT --to-destination 192.219.3.194
