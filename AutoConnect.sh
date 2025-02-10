#!/bin/bash

# Warna untuk output estetika
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

# Daftar STB dan modem yang sesuai
declare -A STB_MODEMS=(
    ["STB1"]="STB 1"
    ["STB2"]="STB 2"
    ["STB3"]="STB 3"
    ["STB4"]="STB 4"
    ["STB5"]="STB 5"
    ["STB6"]="STB 6"
    ["STB7"]="STB 7"
    ["STB8"]="STB 8"
)

# Interface WiFi
WIFI_INTERFACE="wlan0"

# Ping target
PING_TARGET="8.8.8.8"

# Path log
LOG_FILE="/home/hg680p/TmuxManager/wifi.log"

# Ambil hostname STB
HOSTNAME=$(hostname)
CONNECTION_NAME=${STB_MODEMS[$HOSTNAME]}

# Jika STB tidak terdaftar, keluar
if [[ -z "$CONNECTION_NAME" ]]; then
    echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') - STB tidak dikenali! Periksa hostname.${RESET}" | tee -a $LOG_FILE
    exit 1
fi

# Fungsi cek apakah modem tersedia
is_modem_available() {
    nmcli device wifi list | grep -q "$CONNECTION_NAME"
}

# Cek koneksi internet
PING_RESULT=$(ping -c 3 -W 2 $PING_TARGET | awk -F'/' 'END { print ($5+0) }')

# Jika modem tidak terdeteksi, jangan sambung ke jaringan lain
if ! is_modem_available; then
    echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') - Modem $CONNECTION_NAME tidak ditemukan. Tidak menyambung ke jaringan lain.${RESET}" | tee -a $LOG_FILE
    exit 1
fi

# Perbaikan: Bandingkan nilai ping dengan 500 menggunakan `bc`
if [[ -z "$PING_RESULT" || $(echo "$PING_RESULT >= 500" | bc -l) -eq 1 ]]; then
    echo -e "${YELLOW}$(date '+%Y-%m-%d %H:%M:%S') - Ping tinggi (${PING_RESULT}ms) atau koneksi terputus! Reconnecting ke $CONNECTION_NAME...${RESET}" | tee -a $LOG_FILE
    nmcli device disconnect $WIFI_INTERFACE
    sleep 2
    nmcli connection up "$CONNECTION_NAME"
    echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') - Koneksi ke $CONNECTION_NAME diperbarui!${RESET}" | tee -a $LOG_FILE
else
    echo -e "${BLUE}$(date '+%Y-%m-%d %H:%M:%S') - Koneksi stabil dengan ping ${PING_RESULT}ms.${RESET}" | tee -a $LOG_FILE
fi

# Batasi log hanya 5 entri terakhir
tail -n 5 $LOG_FILE > /tmp/wifi_log.tmp && mv /tmp/wifi_log.tmp $LOG_FILE
