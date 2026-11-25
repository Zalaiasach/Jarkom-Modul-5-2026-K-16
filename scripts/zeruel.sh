#!/bin/bash
# Script Zeruel - Soal 19

# Blokir komunikasi dari dan ke pengkhianat Armisael (192.219.4.91) di tetangga satu switch
iptables -I INPUT -s 192.219.4.91 -j DROP
iptables -I OUTPUT -d 192.219.4.91 -j DROP
