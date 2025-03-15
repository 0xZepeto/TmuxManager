#!/bin/bash

# Set environment variable untuk DBUS (diperlukan oleh nmcli)
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Warna output terminal
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RESET='\033[0m'

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
CURRENT_HOSTNAME=$(hostname)

# Ambil nama WiFi dari daftar berdasarkan hostname
WIFI_NAME=${STB_MODEM[$CURRENT_HOSTNAME]}

if [[ -z "$WIFI_NAME" ]]; then
    echo -e "${RED}Hostname $CURRENT_HOSTNAME tidak ditemukan dalam daftar STB_MODEM!${RESET}"
    exit 1
fi

LOG_FILE="/home/hg680p/TmuxManager/wifi.log"
WIFI_INTERFACE="wlan0"
GATEWAY_IP="192.168.8.1"  # Sesuaikan dengan IP modem yang digunakan

# Fungsi logging dengan rotasi 10 entri terakhir
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
    tail -n 10 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
}

log "${CYAN}Memantau koneksi WiFi ke ${WIFI_NAME}...${RESET}"

while true; do
    # Cek apakah wlan0 memiliki alamat IP
    WIFI_IP=$(ip -4 addr show "$WIFI_INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    
    if [[ -n "$WIFI_IP" ]]; then
        # Cek koneksi dengan ping ke gateway
        PING_TIME=$(ping -c 1 -W 2 "$GATEWAY_IP" | awk -F'=' '/time=/ {print $NF}' | cut -d' ' -f1)

        if [[ -n "$PING_TIME" ]]; then
            log "${GREEN}Koneksi stabil dengan ping ${PING_TIME}ms.${RESET}"
        else
            log "${YELLOW}WiFi mungkin bermasalah, ping ke gateway gagal.${RESET}"
        fi
        sleep 5
    else
        log "${RED}WiFi Terputus! Mencoba refresh jaringan...${RESET}"

        # Refresh jaringan dengan menonaktifkan dan mengaktifkan kembali wlan0
        sudo ip link set "$WIFI_INTERFACE" down
        sleep 2
        sudo ip link set "$WIFI_INTERFACE" up
        sleep 5

        # Cek lagi apakah WiFi sudah punya IP
        WIFI_IP=$(ip -4 addr show "$WIFI_INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        if [[ -n "$WIFI_IP" ]]; then
            log "${GREEN}Refresh jaringan berhasil, WiFi tersambung kembali.${RESET}"
        else
            log "${YELLOW}Refresh jaringan gagal. Mencoba menyambungkan ke WiFi...${RESET}"

            # Coba menyambungkan kembali menggunakan nmcli
            sudo nmcli connection down "$WIFI_NAME" 2>/dev/null
            sleep 2
            sudo nmcli connection up "$WIFI_NAME" 2>/dev/null

            # Cek lagi apakah WiFi sudah punya IP
            sleep 5
            WIFI_IP=$(ip -4 addr show "$WIFI_INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
            if [[ -n "$WIFI_IP" ]]; then
                log "${GREEN}WiFi tersambung kembali, lanjut memantau ping...${RESET}"
            else
                log "${RED}Gagal menyambung ke WiFi. Menunggu 10 detik sebelum mencoba lagi...${RESET}"
                sleep 10
            fi
        fi
    fi
done
