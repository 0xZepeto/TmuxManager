#!/bin/bash

# Ambil hostname STB
STB_HOSTNAME=$(hostname)

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

# Pastikan hostname STB ada dalam daftar
if [[ -z "${STB_MODEM[$STB_HOSTNAME]}" ]]; then
    echo "STB ini tidak terdaftar dalam AutoCheck. Keluar..."
    exit 1
fi

WIFI_NAME="${STB_MODEM[$STB_HOSTNAME]}"
AUTOCONNECT_SCRIPT="/home/hg680p/TmuxManager/AutoConnect.sh"

echo "$(date +'%Y-%m-%d %H:%M:%S') - Memulai pemantauan WiFi untuk $STB_HOSTNAME ($WIFI_NAME)..."

# Loop pengecekan setiap 10 menit
while true; do
    # Cek apakah wlan0 memiliki koneksi
    if ! nmcli device status | grep -q "wlan0.*connected"; then
        echo "$(date +'%Y-%m-%d %H:%M:%S') - WiFi $WIFI_NAME terputus! Menjalankan AutoConnect.sh..."
        bash "$AUTOCONNECT_SCRIPT"
    else
        echo "$(date +'%Y-%m-%d %H:%M:%S') - WiFi $WIFI_NAME stabil, lanjut memantau..."
    fi

    # Tunggu 10 menit sebelum pengecekan berikutnya
    sleep 600
done
