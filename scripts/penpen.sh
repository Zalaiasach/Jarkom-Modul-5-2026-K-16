#!/bin/bash
/root/setup_ip.sh

# === VARIABEL JADWAL RESMI (FORMAT UTC, WIB - 7 JAM) ===
# Pilot: 08:00 - 16:00 WIB (01:00 - 09:00 UTC), Senin - Jumat
PILOT_START="01:00"
PILOT_STOP="09:00"
PILOT_DAYS="Mon,Tue,Wed,Thu,Fri"

# Staf Geofront: 17:00 - 23:00 WIB (10:00 - 16:00 UTC), Setiap hari
STAF_START="10:00"
STAF_STOP="16:00"

# 1. Jalankan Listener Port 80
pkill -f "nc" 2>/dev/null
nohup nc -k -l -p 80 > /root/penpen_80.log 2>&1 &

# 2. Bersihkan Rule Lama
iptables -F
iptables -X
iptables -P INPUT ACCEPT

# Izinkan Loopback & Koneksi Balasan
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 3. Custom Chain Cek Jadwal Ping & Port 80
iptables -N CEK_JADWAL
iptables -A INPUT -p icmp --icmp-type echo-request -j CEK_JADWAL
iptables -A INPUT -p tcp --dport 80 -j CEK_JADWAL

# --- ATURAN DI DALAM CEK_JADWAL ---

# Kategori Dummy System (SELALU DITOLAK)
# Subnet Lab (Dummy-Plug, Entry-Plug): 192.219.4.48/29
# Subnet Intel (Spy): 192.219.4.100/30
iptables -A CEK_JADWAL -s 192.219.4.48/29 -j DROP
iptables -A CEK_JADWAL -s 192.219.4.100/30 -j DROP

# Kategori Pilot (Unit-01, 02, 00 di 192.219.4.72/29 & Sachiel di 192.219.3.128/26)
iptables -A CEK_JADWAL -s 192.219.4.72/29 -m time --timestart "$PILOT_START" --timestop "$PILOT_STOP" --weekdays "$PILOT_DAYS" -j ACCEPT
iptables -A CEK_JADWAL -s 192.219.3.128/26 -m time --timestart "$PILOT_START" --timestop "$PILOT_STOP" --weekdays "$PILOT_DAYS" -j ACCEPT
iptables -A CEK_JADWAL -s 192.219.4.72/29 -j DROP
iptables -A CEK_JADWAL -s 192.219.3.128/26 -j DROP

# Kategori Staf Geofront (Lilith, Adam di 192.219.4.80/29)
iptables -A CEK_JADWAL -s 192.219.4.80/29 -m time --timestart "$STAF_START" --timestop "$STAF_STOP" -j ACCEPT
iptables -A CEK_JADWAL -s 192.219.4.80/29 -j DROP

# Kategori Lainnya (Bebas)
iptables -A CEK_JADWAL -j ACCEPT
