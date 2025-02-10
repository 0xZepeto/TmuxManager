#!/bin/bash

# Warna
GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# File log
LOGFILE="/home/hg680p/TmuxManager/Check.log"

# Daftar STB dan modem yang sesuai
declare -A STB_MODEM=(
    ["STB1"]="STB 1"
    ["STB2"]="STB 2"
    ["STB3"]="STB 3"
    ["STB4"]="STB 4"
    ["STB5"]="STB 5"
    ["STB6"]="STB 6"
    ["STB7"]="STB 7"
    ["STB8"]="STB 8"
)

# Ambil hostname STB saat ini
HOSTNAME=$(hostname)

# Cek apakah hostname ada dalam daftar STB_MODEM
if [[ -z "${STB_MODEM[$HOSTNAME]}" ]]; then
    echo -e "${RED}$(date) - Hostname tidak ditemukan dalam daftar STB. Keluar...${RESET}" | tee -a "$LOGFILE"
    exit 1
fi

MODEM_NAME="${STB_MODEM[$HOSTNAME]}"

echo -e "${YELLOW}$(date) - Monitoring WiFi STB: $HOSTNAME ke modem: $MODEM_NAME.${RESET}" | tee -a "$LOGFILE"

LAST_STATUS="Unknown"

while true; do
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

    # Cek perubahan status untuk menghindari spam log
    if [[ "$WIFI_STATUS" == "Disconnected" && "$LAST_STATUS" != "Disconnected" ]]; then
        echo -e "${RED}$(date) - Koneksi WiFi ke $MODEM_NAME terputus! Run AutoConnect.sh...${RESET}" | tee -a "$LOGFILE"
        /home/hg680p/TmuxManager/AutoConnect.sh >> "$LOGFILE" 2>&1
        echo -e "${GREEN}$(date) - AutoConnect.sh selesai dijalankan.${RESET}" | tee -a "$LOGFILE"
    elif [[ "$WIFI_STATUS" != "Disconnected" && "$LAST_STATUS" == "Disconnected" ]]; then
        echo -e "${GREEN}$(date) - Koneksi WiFi ke $MODEM_NAME telah pulih.${RESET}" | tee -a "$LOGFILE"
    fi

    # Perbarui status terakhir
    LAST_STATUS="$WIFI_STATUS"

    # Batasi log hanya 10 baris terakhir
    tail -n 10 "$LOGFILE" | tee "$LOGFILE.tmp" && mv "$LOGFILE.tmp" "$LOGFILE"

    # Tunggu 10 menit sebelum pengecekan berikutnya
    sleep 600
done
