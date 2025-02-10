#!/bin/bash

# Warna untuk tampilan
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BLUE='\033[1;34m'
RESET='\033[0m'

# Nama jaringan sesuai hostname STB
HOSTNAME=$(hostname)
WIFI_NAME="STB ${HOSTNAME//STB/}"  # Misal: STB1 -> "STB 1"

# Lokasi log
LOG_FILE="/home/hg680p/TmuxManager/wifi.log"

# Inisialisasi hitungan percobaan
attempt=0

# Fungsi untuk menyambungkan kembali ke WiFi
reconnect_wifi() {
    echo -e "${YELLOW}Menyambungkan ulang ke $WIFI_NAME...${RESET}"
    nmcli con down "$WIFI_NAME" && nmcli con up "$WIFI_NAME"
}

# Loop utama
while true; do
    # Cek apakah terhubung ke WiFi yang sesuai
    CURRENT_WIFI=$(nmcli -t -f NAME c show --active)

    if [[ "$CURRENT_WIFI" == "$WIFI_NAME" ]]; then
        # Cek ping ke gateway
        GATEWAY_IP=$(ip route | awk '/default/ {print $3}')
        if [[ -n "$GATEWAY_IP" ]]; then
            ping_result=$(ping -c 1 -W 1 "$GATEWAY_IP" | awk -F'/' 'END {print $5+0}')

            # Jika ping di bawah 500ms, koneksi stabil
            if [[ "$ping_result" -lt 500 ]]; then
                echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') - Koneksi stabil dengan ping ${ping_result}ms.${RESET}"
                echo "$(date '+%Y-%m-%d %H:%M:%S') - Koneksi stabil dengan ping ${ping_result}ms." >> "$LOG_FILE"
                attempt=0  # Reset percobaan
            else
                # Ping tinggi, coba reconnect
                ((attempt++))
                echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') - Ping tinggi (${ping_result}ms). Percobaan ke-$attempt...${RESET}"
                echo "$(date '+%Y-%m-%d %H:%M:%S') - Ping tinggi (${ping_result}ms). Percobaan ke-$attempt..." >> "$LOG_FILE"
                reconnect_wifi
            fi
        else
            # Tidak bisa mendapatkan gateway, coba reconnect
            ((attempt++))
            echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') - Tidak dapat menemukan gateway. Percobaan ke-$attempt...${RESET}"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Tidak dapat menemukan gateway. Percobaan ke-$attempt..." >> "$LOG_FILE"
            reconnect_wifi
        fi
    else
        # Tidak terhubung ke jaringan yang sesuai, coba reconnect
        ((attempt++))
        echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') - Tidak terhubung ke $WIFI_NAME. Percobaan ke-$attempt...${RESET}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Tidak terhubung ke $WIFI_NAME. Percobaan ke-$attempt..." >> "$LOG_FILE"
        reconnect_wifi
    fi

    # Jika gagal 5 kali, tunggu 15 detik sebelum mencoba lagi
    if [[ "$attempt" -ge 5 ]]; then
        echo -e "${YELLOW}$(date '+%Y-%m-%d %H:%M:%S') - Gagal menyambung 5 kali. Menunggu 15 detik sebelum mencoba lagi...${RESET}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Gagal menyambung 5 kali. Menunggu 15 detik sebelum mencoba lagi..." >> "$LOG_FILE"
        sleep 15
        attempt=0  # Reset hitungan percobaan
    fi

    # Simpan hanya 10 log terakhir
    tail -n 10 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"

    # Tunggu sebelum loop berikutnya
    sleep 2
done
