#!/bin/bash

# Warna
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# File log
LOGFILE="/tmp/check.log"

# Ambil hostname STB saat ini
HOSTNAME=$(hostname)

# Modem name berdasarkan hostname
MODEM_NAME="STB ${HOSTNAME: -1}"  # Mengambil angka terakhir dari hostname (misal STB8 -> 8)

# Tampilkan pesan monitoring
echo -e "${YELLOW}$(date '+%Y-%m-%d %H:%M:%S') - Monitoring WiFi { $HOSTNAME } modem { $MODEM_NAME }${RESET}" | tee -a "$LOGFILE"

# Cek status koneksi WiFi menggunakan NetworkManager
WIFI_STATUS=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d':' -f2)

# Jika nmcli tidak mendeteksi, gunakan iw sebagai cadangan
if [[ -z "$WIFI_STATUS" ]]; then
    iw dev wlan0 link | grep -q "Connected"
    if [[ $? -eq 0 ]]; then
        WIFI_STATUS="$MODEM_NAME"
    else
        WIFI_STATUS="Disconnected"
    fi
fi

# Cek status koneksi
if [[ "$WIFI_STATUS" == "Disconnected" ]]; then
    echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') - WiFi terputus! Menjalankan AutoConnect.sh...${RESET}" | tee -a "$LOGFILE"
    /home/hg680p/TmuxManager/AutoConnect.sh >> "$LOGFILE" 2>&1
    echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') - AutoConnect.sh selesai dijalankan.${RESET}" | tee -a "$LOGFILE"
else
    echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') - WiFi stabil.${RESET}" | tee -a "$LOGFILE"
fi

# Batasi log hanya 25 baris terakhir
tail -n 25 "$LOGFILE" > "$LOGFILE.tmp" && mv "$LOGFILE.tmp" "$LOGFILE"
